"""Moduł ROZLICZENIE PRODUKCJI — ściśle wg „Instrukcja rozliczania produkcji Plastema, wersja 1”.

Dokumenty instrukcji → tabele:
  dok. 2 Zamówienie produkcji     → prod_orders   (1 zamówienie = 1 produkt, 1 maszyna, 1 forma; numer kolejny/rok)
  dok. 3 Specyfikacja (kolory)      → prod_colors   (ilość zamówiona koloru, barwnik, dół specyfikacji)
  dok. 4 Raport zmianowy            ┐
  dok. 7 Raport dnia maszyny (PLC)  ├→ prod_shifts  (jeden wiersz = jedna zmiana jednego koloru)
  dok. 9 Notatki kartonów           ┘
  dok. 6 Statystyka                 → productions   (wiersz dopisywany przy rozliczeniu koloru, moduł prod_stats)
  dok. 10 Przyjęcie na magazyn      → prod_receipts (numer PW = miesiąc/kolejny)
  etykieta kartonu                  → wydruk etykiet (data + pieczątka QC z numerem pracownika)
Zasady: dobre sztuki z kartonów, cykle z licznika PLC (zmiana koloru zeruje licznik), braki = cykle × krotność − dobre
dla całego koloru, nadwyżka „0 + N”, średnia na zmianę = 28 800 s ÷ czas cyklu × krotność (w dół).
Kod szarży N-Z-S-DDMMRR: szarża = całe zamówienie produkcji; N maszyna, Z zmiana startu, S kolejna szarża maszyny
na tej zmianie w dniu startu, DDMMRR data startu (pierwsza zmiana z raportu).
"""
import math
import re
from datetime import date, datetime, timedelta
from decimal import Decimal

from flask import abort, flash, redirect, render_template, request, url_for

from inventory import CURRENT_STOCK_SQL
from machines import MACHINE_COUNT, next_doc_number
from materials import auth, clean, require_csrf
from orders import to_date, to_int, to_num
from prod_stats import code3
from fg import check_pw_delete, register_pw

LOCK_ID = 6102034
SHIFT_SECONDS = 28800  # zmiana 8 h
SHIFTS = ['I', 'II', 'III']
ORDER_STATUSES = {'PLANOWANE': 'zaplanowane — przed startem', 'W PRODUKCJI': 'w produkcji', 'ZAKOŃCZONE': 'wszystkie kolory rozliczone',
                  'ANULOWANE': 'anulowane'}
COLOR_STATUSES = {'DO PRODUKCJI': 'do produkcji', 'W PRODUKCJI': 'w produkcji', 'ROZLICZONY': 'rozliczony', 'X': 'X — nie produkowany'}
RECEIVERS = ['G.P. (Grzegorz)', 'K.SZ (Karol)']
CHECKS = {
    'K1': 'Suma kolorów (dok. 3) = ilość zamówienia produkcji (dok. 2)',
    'K2': 'Kilogramy w planie = sztuki × waga detalu × udział',
    'K3': 'Materiał przed startem: stan w magazynie ≥ potrzeba',
    'K4': 'Ciąg „zostało” w raporcie zmianowym: poprzednie − wykonano',
    'K5': 'Kartony × sztuki w kartonie = wykonano (dok. 9 = dok. 4)',
    'K6': 'Licznik PLC: licznik − poprzedni licznik tego koloru ≥ 0',
    'K7': 'Braki nie mniejsze od zera (cykle − dobre, cały kolor)',
    'K8': 'Trzy zapisy dobrych sztuk: dół dok. 3 = suma dok. 4 = statystyka dok. 6',
    'K9': 'Braki w statystyce = cykle − dobre',
    'K10': 'Przyjęcie na magazyn (dok. 10) = ilość w statystyce (dok. 6)',
    'K11': 'Zużycie materiału ≈ ubytek w inwenturze (raport zużycia)',
    'K12': 'Etykiety: data i pieczątka QC z numerem pracownika',
}


def dec(value):
    return Decimal(value) if value is not None else None


def pattern_letter(n):
    letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    return letters[n] if n < 26 else letters[n // 26 - 1] + letters[n % 26]


# --- obliczenia rozliczenia koloru -----------------------------------------------------------

def summarize_color(order, color, shifts):
    """Liczy raport zmianowy i licznik koloru: zostało, cykle na zmianie, sumy i punkty K4–K9."""
    cav = int(order['cavities'] or 1)
    ordered = int(color['qty_ordered'] or 0)
    ppc_default = int(order['pcs_per_carton'] or 0)
    rows, cumulative, total_cycles, prev_counter, checks = [], 0, 0, None, {}
    counters_seen = False
    for i, s in enumerate(shifts):
        good = int(s['qty_good'] or 0)
        cumulative += good
        remaining = ordered - cumulative
        row = {'s': s, 'good': good, 'remaining': remaining, 'cycles': None, 'flags': []}
        # K4 — „zostało” wpisane przez operatora
        if s['remaining_entered'] is not None:
            expected = max(remaining, 0)
            if int(s['remaining_entered']) != expected:
                row['flags'].append(('K4', f'operator wpisał „zostało” {s["remaining_entered"]}, a z raportu wychodzi {expected}'))
        # K5 — kartony
        ppc = int(s['pcs_per_carton'] or ppc_default or 0)
        if s['cartons'] is not None and ppc:
            from_cartons = int(s['cartons']) * ppc
            if from_cartons != good:
                rest = good - from_cartons
                last = i == len(shifts) - 1
                if last and 0 < rest < ppc:
                    row['flags'].append(('K5i', f'{s["cartons"]} × {ppc} = {from_cartons} + {rest} szt. w niepełnym kartonie (koniec koloru)'))
                else:
                    row['flags'].append(('K5', f'{s["cartons"]} kart. × {ppc} = {from_cartons} ≠ wykonano {good}'))
        # K6 — licznik PLC (zeruje się przy zmianie koloru; pierwsza zmiana koloru liczy od 0)
        if s['plc_counter'] is not None:
            counters_seen = True
            counter = int(s['plc_counter'])
            if s['counter_reset'] or prev_counter is None:
                cycles = counter
            else:
                cycles = counter - prev_counter
            if cycles < 0:
                row['flags'].append(('K6', f'licznik {counter} mniejszy od poprzedniego {prev_counter} — brak wyzerowania albo pomyłka w odczycie'))
            else:
                total_cycles += cycles
            row['cycles'] = cycles
            prev_counter = counter
        row['bad'] = any(code in ('K4', 'K5', 'K6') for code, _ in row['flags'])
        rows.append(row)
    good_total = cumulative
    surplus = good_total - ordered
    missing = [r for r in rows if r['s']['plc_counter'] is None and r['good']]
    partial = counters_seen and bool(missing)  # część zmian bez odczytu (np. cykle na kartce z poprzedniego tygodnia)
    cycles = total_cycles if counters_seen else None
    scrap = cycles * cav - good_total if cycles is not None and not partial else None
    for code in ('K4', 'K5', 'K6'):
        bad = [f'{r["s"]["shift_date"]:%d.%m} {r["s"]["shift"]}: {msg}' for r in rows for c, msg in r['flags'] if c == code]
        checks[code] = ('error', '; '.join(bad)) if bad else (('ok', 'zgodne') if rows else ('none', 'brak zmian'))
    if partial:
        checks['K7'] = ('warn', f'licznik niepełny: {len(missing)} zmian bez odczytu PLC ({", ".join(r["s"]["shift_date"].strftime("%d.%m") + " " + r["s"]["shift"] for r in missing[:4])}{" …" if len(missing) > 4 else ""}) — '
                                f'dolicz odczyty z kartki raportu maszyny, zanim policzysz braki; inaczej braki zostaną puste')
    elif scrap is None:
        checks['K7'] = ('warn', 'brak odczytów licznika PLC — braków nie da się policzyć') if rows else ('none', 'brak zmian')
    elif scrap < 0:
        checks['K7'] = ('error', f'cykle {cycles} × {cav} − dobre {good_total} = {scrap} < 0 — szukaj pomyłki w zapisie, zanim trafi do statystyki')
    else:
        checks['K7'] = ('ok', f'{cycles} × {cav} − {good_total} = {scrap} szt.')
    if color['spec_good'] is not None:
        if int(color['spec_good']) == good_total:
            checks['K8'] = ('ok', f'dół specyfikacji {color["spec_good"]} = raport zmianowy {good_total}')
        else:
            checks['K8'] = ('error', f'dół specyfikacji {color["spec_good"]} ≠ suma raportu zmianowego {good_total}')
    else:
        checks['K8'] = ('none', 'wpisz ilość z dołu specyfikacji (dok. 3) po zakończeniu koloru')
    return {
        'rows': rows, 'good': good_total, 'ordered': ordered, 'surplus': surplus, 'cycles': cycles, 'scrap': scrap, 'partial': partial,
        'scrap_pct': round(scrap / (cycles * cav) * 100, 1) if scrap is not None and cycles else None,
        'remaining_label': (f'0 + {surplus}' if surplus > 0 else ('0' if surplus == 0 else str(-surplus))) if rows else str(ordered),
        'start': shifts[0]['shift_date'] if shifts else None, 'end': shifts[-1]['shift_date'] if shifts else None,
        'last_cycle_s': next((s['cycle_s'] for s in reversed(shifts) if s['cycle_s']), None),
        'cartons': (good_total // int(order['pcs_per_carton'])) if order['pcs_per_carton'] else None,
        'carton_rest': (good_total % int(order['pcs_per_carton'])) if order['pcs_per_carton'] else None,
        'checks': checks,
    }


def stat_values(order, color, summary, form=None):
    """Wartości wiersza statystyki (dok. 6) wg tabeli „Skąd wziąć każdą kolumnę”."""
    form = form or {}
    cav = Decimal(order['cavities'] or 1)
    cycle_s = dec(color['stat_cycle_s']) or dec(summary['last_cycle_s'])
    avg = math.floor(Decimal(SHIFT_SECONDS) / cycle_s * cav) if cycle_s else None  # wpisuje się w dół
    real = (Decimal(SHIFT_SECONDS) * cav / avg) if avg else None
    shot = dec(color['shot_g'])
    return {'cycle_s': cycle_s, 'avg_per_shift': avg, 'real_cycle_s': real, 'piece_gross_g': (shot / cav) if shot else None}


def material_use(order, color, summary):
    """Zużycie = cykle × waga brutto całego wtrysku; barwnik = dozowanie % z tego."""
    shot = dec(color['shot_g'])
    cycles = summary['cycles'] if summary['cycles'] is not None and not summary['partial'] else (math.ceil(summary['good'] / int(order['cavities'] or 1)) if summary['good'] else 0)
    if not shot or not cycles:
        return None
    total = Decimal(cycles) * shot / 1000
    dosage = dec(color['dosage_pct']) or Decimal(0)
    colorant = (total * dosage / 100).quantize(Decimal('0.001'))
    return {'total': total.quantize(Decimal('0.001')), 'colorant': colorant, 'material': (total - colorant).quantize(Decimal('0.001')),
            'cycles': cycles}


# --- schemat --------------------------------------------------------------------------------

def init_settlement(db):
    with db() as connection, connection.cursor() as cursor:
        cursor.execute('SELECT pg_advisory_xact_lock(%s)', (LOCK_ID,))
        cursor.execute('''CREATE TABLE IF NOT EXISTS prod_orders (
            id BIGSERIAL PRIMARY KEY, number TEXT NOT NULL UNIQUE, seq INTEGER NOT NULL, year INTEGER NOT NULL,
            client_id BIGINT NOT NULL REFERENCES clients(id) ON DELETE RESTRICT, zk_order_id BIGINT REFERENCES orders(id) ON DELETE SET NULL,
            product_name TEXT NOT NULL, machine_no SMALLINT CHECK (machine_no BETWEEN 1 AND 9),
            mold_id BIGINT REFERENCES molds(id) ON DELETE SET NULL, order_date DATE NOT NULL DEFAULT CURRENT_DATE,
            planned_start DATE, planned_end DATE, qty_total INTEGER NOT NULL DEFAULT 0,
            material_id BIGINT REFERENCES materials(id) ON DELETE SET NULL, material_text TEXT, material_share NUMERIC(5,1) DEFAULT 100,
            material2_id BIGINT REFERENCES materials(id) ON DELETE SET NULL, material2_share NUMERIC(5,1),
            material_kg NUMERIC(14,1), net_g NUMERIC(12,3), per_shift INTEGER, cavities INTEGER DEFAULT 1,
            pcs_per_carton INTEGER, carton_kg NUMERIC(8,2), carton_type TEXT, notes TEXT, issued_by TEXT, accepted_by TEXT,
            status TEXT NOT NULL DEFAULT 'PLANOWANE', batch_code TEXT, start_shift TEXT,
            created_at TIMESTAMPTZ NOT NULL DEFAULT NOW())''')
        cursor.execute('''CREATE TABLE IF NOT EXISTS prod_colors (
            id BIGSERIAL PRIMARY KEY, prod_order_id BIGINT NOT NULL REFERENCES prod_orders(id) ON DELETE CASCADE, lp INTEGER NOT NULL,
            color_id BIGINT REFERENCES colors(id) ON DELETE SET NULL, color_name TEXT NOT NULL,
            product_id BIGINT REFERENCES products(id) ON DELETE SET NULL, zk_line_id BIGINT REFERENCES order_lines(id) ON DELETE SET NULL,
            colorant_id BIGINT REFERENCES materials(id) ON DELETE SET NULL, colorant_text TEXT, dosage_pct NUMERIC(5,2),
            qty_ordered INTEGER NOT NULL DEFAULT 0, spec_good INTEGER, status TEXT NOT NULL DEFAULT 'DO PRODUKCJI',
            pattern_no TEXT, net_g NUMERIC(12,3), shot_g NUMERIC(12,3), stat_cycle_s NUMERIC(8,2), mounted_by TEXT, dismounted_by TEXT,
            pattern_at_end TEXT, notes TEXT, settled_at TIMESTAMPTZ, settled_by TEXT,
            label_date DATE, qc_no TEXT, labels_printed INTEGER, zu_doc_id BIGINT REFERENCES machine_docs(id) ON DELETE SET NULL)''')
        cursor.execute('''CREATE TABLE IF NOT EXISTS prod_shifts (
            id BIGSERIAL PRIMARY KEY, prod_color_id BIGINT NOT NULL REFERENCES prod_colors(id) ON DELETE CASCADE,
            shift_date DATE NOT NULL, shift TEXT NOT NULL CHECK (shift IN ('I','II','III')), operator TEXT,
            qty_good INTEGER NOT NULL DEFAULT 0 CHECK (qty_good >= 0), remaining_entered INTEGER,
            cartons INTEGER, pcs_per_carton INTEGER, plc_counter INTEGER, counter_reset BOOLEAN NOT NULL DEFAULT FALSE,
            cycle_s NUMERIC(8,2), notes TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW())''')
        cursor.execute('''CREATE TABLE IF NOT EXISTS prod_receipts (
            id BIGSERIAL PRIMARY KEY, prod_color_id BIGINT NOT NULL REFERENCES prod_colors(id) ON DELETE CASCADE,
            receipt_date DATE NOT NULL DEFAULT CURRENT_DATE, receipt_time TEXT, qty INTEGER NOT NULL CHECK (qty > 0),
            pw_number TEXT NOT NULL UNIQUE, received_by TEXT, notes TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW())''')
        cursor.execute('CREATE INDEX IF NOT EXISTS prod_colors_order_idx ON prod_colors(prod_order_id)')
        cursor.execute('CREATE INDEX IF NOT EXISTS prod_shifts_color_idx ON prod_shifts(prod_color_id, shift_date)')
        cursor.execute('CREATE INDEX IF NOT EXISTS prod_receipts_color_idx ON prod_receipts(prod_color_id)')
        # Instrukcja: „plan zakłada 2 zmiany dziennie” — jednorazowo ustaw planowanie maszyn na 2 zmiany.
        cursor.execute("SELECT 1 FROM app_settings WHERE key = 'settlement_v1'")
        if cursor.fetchone() is None:
            cursor.execute("UPDATE app_settings SET value = '2' WHERE key = 'plan_shifts'")
            cursor.execute("INSERT INTO app_settings (key, value) VALUES ('settlement_v1', '1')")


# --- pomocnicze zapytania --------------------------------------------------------------------

ORDER_SQL = '''SELECT po.*, c.code AS client_code, c.short_name, c.name AS client_name, mo.mold_no, mo.name AS mold_name,
                      mo.storage AS mold_storage, ma.material_index, COALESCE(ma.internal_name, ma.symbol) AS material_name,
                      m2.material_index AS material2_index, COALESCE(m2.internal_name, m2.symbol) AS material2_name, o.number AS zk_number
               FROM prod_orders po JOIN clients c ON c.id = po.client_id LEFT JOIN molds mo ON mo.id = po.mold_id
               LEFT JOIN materials ma ON ma.id = po.material_id LEFT JOIN materials m2 ON m2.id = po.material2_id
               LEFT JOIN orders o ON o.id = po.zk_order_id'''
COLOR_SQL = '''SELECT pc.*, col.code AS color_code, col.name AS dict_color, pr.code AS product_code, pr.name AS product_variant,
                      cb.material_index AS colorant_index, cb.symbol AS colorant_symbol,
                      (SELECT COALESCE(SUM(qty), 0) FROM prod_receipts r WHERE r.prod_color_id = pc.id) AS received,
                      st.id AS stat_id, st.qty AS stat_qty, st.scrap_pcs AS stat_scrap, st.cycles AS stat_cycles
               FROM prod_colors pc LEFT JOIN colors col ON col.id = pc.color_id LEFT JOIN products pr ON pr.id = pc.product_id
               LEFT JOIN materials cb ON cb.id = pc.colorant_id LEFT JOIN productions st ON st.prod_color_id = pc.id'''


def load_order(cursor, order_id):
    cursor.execute(ORDER_SQL + ' WHERE po.id = %s', (order_id,))
    order = cursor.fetchone()
    if order is None:
        abort(404)
    cursor.execute(COLOR_SQL + ' WHERE pc.prod_order_id = %s ORDER BY pc.lp, pc.id', (order_id,))
    colors = cursor.fetchall()
    cursor.execute('''SELECT s.* FROM prod_shifts s JOIN prod_colors pc ON pc.id = s.prod_color_id WHERE pc.prod_order_id = %s
                      ORDER BY s.shift_date, array_position(ARRAY['I','II','III'], s.shift), s.id''', (order_id,))
    shifts = {}
    for s in cursor.fetchall():
        shifts.setdefault(s['prod_color_id'], []).append(s)
    for color in colors:
        color['summary'] = summarize_color(order, color, shifts.get(color['id'], []))
        color['codes'] = codes_for(order, color)
    return order, colors


def codes_for(order, color):
    if not color['product_code']:
        return {'production': None, 'full': None}
    production = f'{order["client_code"]}-{color["product_code"]:04d}-{color["color_code"] or "000"}'
    full = f'{production}-{order["mold_no"] or "000"}-{code3(order["material_index"])}-{code3(color["colorant_index"])}'
    return {'production': production, 'full': full}


def next_internal_number(cursor, year):
    """Numer zamówienia produkcji „kolejny/rok” — kontynuacja numeracji ze statystyki."""
    cursor.execute('''SELECT COALESCE(MAX(n), 0) + 1 AS n FROM (
                        SELECT seq AS n FROM prod_orders WHERE year = %s
                        UNION ALL SELECT substring(internal_order from '^([0-9]+)/')::int FROM productions
                        WHERE internal_order ~ ('^[0-9]+/' || %s::text || '$')) x''', (year, year))
    seq = cursor.fetchone()['n']
    return seq, f'{seq}/{year}'


def order_checks(cursor, order, colors):
    """Punkty kontrolne na poziomie zamówienia: K1, K2, K3, K9, K10, K12."""
    checks = {}
    active = [c for c in colors if c['status'] != 'X']
    total = sum(int(c['qty_ordered'] or 0) for c in active)
    checks['K1'] = ('ok', f'{total:,} = {order["qty_total"]:,}'.replace(',', ' ')) if total == order['qty_total'] else \
        ('error', f'suma kolorów {total:,} ≠ zamówienie {order["qty_total"]:,}'.replace(',', ' '))
    if order['net_g']:
        kg = (Decimal(order['qty_total']) * Decimal(order['net_g']) / 1000)
        share1 = Decimal(order['material_share'] or 100)
        need1 = (kg * share1 / 100).quantize(Decimal('0.1'))
        text = f'{order["qty_total"]:,} × {Decimal(order["net_g"]).normalize():f} g × {share1.normalize():f}% = {need1:,} kg'.replace(',', ' ')
        if order['material2_id'] and order['material2_share']:
            need2 = (kg * Decimal(order['material2_share']) / 100).quantize(Decimal('0.1'))
            text += f' + {need2:,} kg ({Decimal(order["material2_share"]).normalize():f}%)'.replace(',', ' ')
        if order['material_kg'] is not None and abs(Decimal(order['material_kg']) - need1) > max(Decimal(1), need1 / 100):
            checks['K2'] = ('error', f'{text}, a w zamówieniu wpisano {order["material_kg"]:,} kg'.replace(',', ' '))
        else:
            checks['K2'] = ('ok', text)
    else:
        checks['K2'] = ('none', 'brak wagi detalu w zamówieniu')
    # K3 — stan magazynu M1 minus potrzeba (tworzywo i barwniki z każdego koloru)
    cursor.execute(f'SELECT material_id, current_kg FROM ({CURRENT_STOCK_SQL}) cs')
    stock = {r['material_id']: r['current_kg'] for r in cursor.fetchall()}
    problems, parts = [], []
    if order['net_g'] and order['material_id']:
        need = Decimal(order['qty_total']) * Decimal(order['net_g']) / 1000 * Decimal(order['material_share'] or 100) / 100
        have = stock.get(order['material_id'])
        parts.append(f'{order["material_index"]}: {have or 0:,.0f} kg ≥ {need:,.0f} kg'.replace(',', ' '))
        if have is None or have < need:
            problems.append(f'{order["material_index"]} brakuje {need - (have or 0):,.0f} kg'.replace(',', ' '))
    elif not order['material_id']:
        problems.append('tworzywo nie jest wybrane z magazynu')
    for c in active:
        if c['colorant_id'] and order['net_g'] and c['status'] != 'ROZLICZONY':
            need = Decimal(c['qty_ordered']) * Decimal(order['net_g']) / 1000 * Decimal(c['dosage_pct'] or 0) / 100
            have = stock.get(c['colorant_id'])
            parts.append(f'{c["colorant_index"]}: {have or 0:,.1f} ≥ {need:,.1f} kg'.replace(',', ' '))
            if have is None or have < need:
                problems.append(f'{c["colorant_index"]} ({c["color_name"]}) brakuje {need - (have or 0):,.1f} kg'.replace(',', ' '))
    checks['K3'] = ('warn', '; '.join(problems)) if problems else ('ok', '; '.join(parts[:4]) + (' …' if len(parts) > 4 else ''))
    settled = [c for c in active if c['status'] == 'ROZLICZONY']
    bad9 = [c['color_name'] for c in settled if c['summary']['scrap'] is not None and c['stat_scrap'] is not None
            and int(c['stat_scrap']) != c['summary']['scrap']]
    checks['K9'] = ('error', 'różnica w: ' + ', '.join(bad9)) if bad9 else (('ok', f'{len(settled)} rozliczonych kolorów zgodnych') if settled else ('none', 'brak rozliczonych kolorów'))
    diff10 = [f'{c["color_name"]}: przyjęto {c["received"]} ≠ {c["stat_qty"]:.0f}' for c in settled if c['stat_qty'] is not None and int(c['received']) != int(c['stat_qty'])]
    checks['K10'] = ('warn', '; '.join(diff10)) if diff10 else (('ok', 'przyjęcia = statystyka') if settled else ('none', 'brak rozliczonych kolorów'))
    no_labels = [c['color_name'] for c in active if c['summary']['good'] and not (c['label_date'] and c['qc_no'])]
    checks['K12'] = ('warn', 'bez etykiet z datą i QC: ' + ', '.join(no_labels)) if no_labels else ('ok', 'etykiety z datą i pieczątką QC') if any(c['summary']['good'] for c in active) else ('none', '—')
    return checks


def refresh_order_status(cursor, order_id):
    cursor.execute('SELECT status FROM prod_orders WHERE id = %s', (order_id,))
    if cursor.fetchone()['status'] == 'ANULOWANE':
        return
    cursor.execute('''SELECT COUNT(*) FILTER (WHERE status NOT IN ('ROZLICZONY','X')) AS open, COUNT(*) AS total,
                             (SELECT COUNT(*) FROM prod_shifts s JOIN prod_colors pc ON pc.id = s.prod_color_id WHERE pc.prod_order_id = %s) AS shifts
                      FROM prod_colors WHERE prod_order_id = %s''', (order_id, order_id))
    r = cursor.fetchone()
    status = 'ZAKOŃCZONE' if r['total'] and r['open'] == 0 else ('W PRODUKCJI' if r['shifts'] else 'PLANOWANE')
    cursor.execute('UPDATE prod_orders SET status = %s WHERE id = %s', (status, order_id))
    sync_mold_mount(cursor, order_id)


def sync_mold_mount(cursor, order_id):
    """Rejestr montaży formy (paszport): montaż = pierwsza zmiana, demontaż = ostatnia zmiana po zakończeniu zamówienia,
    liczba wtrysków = cykle z licznika PLC wszystkich kolorów."""
    cursor.execute('SELECT * FROM prod_orders WHERE id = %s', (order_id,))
    order = cursor.fetchone()
    if not order['mold_id']:
        return
    cursor.execute('''SELECT MIN(s.shift_date) AS first, MAX(s.shift_date) AS last FROM prod_shifts s
                      JOIN prod_colors pc ON pc.id = s.prod_color_id WHERE pc.prod_order_id = %s''', (order_id,))
    span = cursor.fetchone()
    if not span['first']:
        cursor.execute('DELETE FROM mold_mounts WHERE prod_order_id = %s AND manual_edit = FALSE', (order_id,))
        return
    _, colors = load_order(cursor, order_id)
    shots = sum(c['summary']['cycles'] or 0 for c in colors)
    mounted = next((c['mounted_by'] for c in colors if c['mounted_by']), None)
    dismounted = next((c['dismounted_by'] for c in reversed(colors) if c['dismounted_by']), None)
    dismount = span['last'] if order['status'] == 'ZAKOŃCZONE' else None
    cursor.execute('SELECT id, manual_edit FROM mold_mounts WHERE prod_order_id = %s', (order_id,))
    existing = cursor.fetchone()
    if existing is None:
        cursor.execute('''INSERT INTO mold_mounts (mold_id, prod_order_id, mount_date, dismount_date, shots, machine_no, mounted_by, dismounted_by)
                          VALUES (%s,%s,%s,%s,%s,%s,%s,%s)''',
                       (order['mold_id'], order_id, span['first'], dismount, shots or None, order['machine_no'], mounted, dismounted))
    else:
        cursor.execute('''UPDATE mold_mounts SET mold_id = %s, mount_date = %s, dismount_date = COALESCE(%s, CASE WHEN manual_edit THEN dismount_date END),
                          shots = %s, machine_no = %s, mounted_by = COALESCE(mounted_by, %s), dismounted_by = COALESCE(dismounted_by, %s)
                          WHERE id = %s''',
                       (order['mold_id'], span['first'], dismount, shots or None, order['machine_no'], mounted, dismounted, existing['id']))


def assign_batch(cursor, order_id):
    """Kod szarży przy pierwszej zmianie zamówienia: N-Z-S-DDMMRR."""
    cursor.execute('SELECT * FROM prod_orders WHERE id = %s', (order_id,))
    order = cursor.fetchone()
    cursor.execute('''SELECT s.shift_date, s.shift FROM prod_shifts s JOIN prod_colors pc ON pc.id = s.prod_color_id
                      WHERE pc.prod_order_id = %s ORDER BY s.shift_date, array_position(ARRAY['I','II','III'], s.shift), s.id LIMIT 1''', (order_id,))
    first = cursor.fetchone()
    if first is None:
        cursor.execute('UPDATE prod_orders SET batch_code = NULL, start_shift = NULL WHERE id = %s', (order_id,))
        return
    z = SHIFTS.index(first['shift']) + 1
    suffix = first['shift_date'].strftime('%d%m%y')
    if order['batch_code'] and order['batch_code'].startswith(f'{order["machine_no"]}-{z}-') and order['batch_code'].endswith(suffix):
        return
    prefix = f'{order["machine_no"]}-{z}-'
    cursor.execute('''SELECT COUNT(*) AS n FROM (SELECT batch_code FROM prod_orders WHERE id <> %s AND batch_code LIKE %s
                      UNION SELECT batch_code FROM productions WHERE source = 'EXCEL' AND batch_code LIKE %s) x''',
                   (order_id, f'{prefix}%-{suffix}', f'{prefix}%-{suffix}'))
    code = f'{prefix}{cursor.fetchone()["n"] + 1}-{suffix}'
    cursor.execute('UPDATE prod_orders SET batch_code = %s, start_shift = %s WHERE id = %s', (code, first['shift'], order_id))
    cursor.execute('UPDATE productions SET batch_code = %s WHERE prod_color_id IN (SELECT id FROM prod_colors WHERE prod_order_id = %s)',
                   (code, order_id))


def base_name(names):
    """Wspólna nazwa produktu bez koloru: ['LOLLIPOP WALLY GRANATOWY', 'LOLLIPOP WALLY BORDOWY'] → 'LOLLIPOP WALLY'."""
    from order_seed import color_of
    split = [n.split() for n in names if n]
    if not split:
        return ''
    common = split[0]
    for words in split[1:]:
        k = 0
        while k < min(len(common), len(words)) and common[k].upper() == words[k].upper():
            k += 1
        common = common[:k]
    if len(split) == 1 or not common:
        words = split[0]
        while len(words) > 1 and color_of(words[-1]):
            words = words[:-1]
        if len(words) > 1 and words[-1].upper().rstrip('.') in ('C', 'J', 'JASNO', 'CIEMNO'):
            words = words[:-1]
        common = words
    return ' '.join(common)


# --- trasy ------------------------------------------------------------------------------------

def register_settlement_routes(app, db):
    app.extensions['issue_internal_orders'] = lambda cursor, zk: issue_internal_orders(cursor, zk)
    app.jinja_env.globals.update(prod_order_statuses=ORDER_STATUSES, prod_color_statuses=COLOR_STATUSES, settlement_checks=CHECKS,
                                 shift_names=SHIFTS, fg_receivers=RECEIVERS)

    def option_lists(cursor, client_id=None):
        cursor.execute('SELECT id, code, short_name FROM clients ORDER BY short_name')
        clients = cursor.fetchall()
        cursor.execute("SELECT id, mold_no, name, status FROM molds ORDER BY mold_no")
        molds = cursor.fetchall()
        cursor.execute("""SELECT id, material_index, material_type, COALESCE(internal_name, symbol) AS name, symbol, color
                          FROM materials ORDER BY material_index""")
        mats = cursor.fetchall()
        cursor.execute('SELECT id, code, name FROM colors ORDER BY code')
        colors = cursor.fetchall()
        products = []
        if client_id:
            cursor.execute('''SELECT p.id, p.code, p.name, p.color_id, p.colorant_id, p.colorant_pct, p.mold_id, p.material_id,
                                     p.net_g, p.per_shift, p.cavities, p.pcs_per_carton, p.carton_kg, p.carton_type, p.machines
                              FROM products p WHERE p.client_id = %s ORDER BY p.name''', (client_id,))
            products = cursor.fetchall()
        return {'clients': clients, 'molds': molds, 'ss': [m for m in mats if m['material_type'] == 'SUROWIEC SYPKI'],
                'bt': [m for m in mats if m['material_type'] == 'BARWNIK TWORZYWA'], 'colors': colors, 'products': products}

    @app.get('/rozliczenie')
    @auth
    def settlement_index():
        status, machine, query = request.args.get('status', ''), request.args.get('maszyna', ''), request.args.get('q', '').strip()
        sql = ORDER_SQL.replace('SELECT po.*', '''SELECT po.*,
                 (SELECT COUNT(*) FROM prod_colors x WHERE x.prod_order_id = po.id AND x.status <> 'X') AS colors,
                 (SELECT COUNT(*) FROM prod_colors x WHERE x.prod_order_id = po.id AND x.status = 'ROZLICZONY') AS settled,
                 (SELECT COALESCE(SUM(s.qty_good), 0) FROM prod_shifts s JOIN prod_colors x ON x.id = s.prod_color_id WHERE x.prod_order_id = po.id) AS good,
                 (SELECT MAX(s.shift_date) FROM prod_shifts s JOIN prod_colors x ON x.id = s.prod_color_id WHERE x.prod_order_id = po.id) AS last_shift''') + ' WHERE TRUE'
        params = []
        if status in ORDER_STATUSES:
            sql += ' AND po.status = %s'; params.append(status)
        elif not status:
            sql += " AND po.status IN ('PLANOWANE','W PRODUKCJI')"
        if machine.isdigit():
            sql += ' AND po.machine_no = %s'; params.append(int(machine))
        if query:
            sql += ' AND (po.number ILIKE %s OR po.product_name ILIKE %s OR c.short_name ILIKE %s OR po.batch_code ILIKE %s)'
            params += [f'%{query}%'] * 4
        sql += ' ORDER BY po.year DESC, po.seq DESC LIMIT 600'
        with db() as connection, connection.cursor() as cursor:
            cursor.execute(sql, params)
            orders = cursor.fetchall()
            cursor.execute('SELECT status, COUNT(*) AS n FROM prod_orders GROUP BY status')
            counts = {r['status']: r['n'] for r in cursor.fetchall()}
            cursor.execute('''SELECT o.id, o.number, c.short_name, o.delivery_date FROM orders o JOIN clients c ON c.id = o.client_id
                              WHERE o.status = 'PRZYJĘTE' AND NOT EXISTS (SELECT 1 FROM prod_orders po WHERE po.zk_order_id = o.id)
                              ORDER BY o.delivery_date NULLS LAST''')
            waiting = cursor.fetchall()
        return render_template('settlement_index.html', orders=orders, counts=counts, status=status, machine=machine, query=query,
                               waiting=waiting)

    # ---------- nowe zamówienie produkcji (dok. 2 + dok. 3) ----------
    @app.route('/rozliczenie/nowe', methods=['GET', 'POST'])
    @auth
    def settlement_new():
        with db() as connection, connection.cursor() as cursor:
            client_id = request.values.get('klient', '')
            client_id = int(client_id) if client_id.isdigit() else None
            options = option_lists(cursor, client_id)
            form = request.form if request.method == 'POST' else {}
            if request.method == 'POST' and client_id:
                require_csrf()
                try:
                    order_id = create_order_from_form(cursor, client_id, form, options)
                    flash('Utworzono zamówienie produkcji. Sprawdź punkty kontrolne K1–K3 przed wydaniem na halę.', 'success')
                    return redirect(url_for('settlement_order', order_id=order_id))
                except ValueError as error:
                    connection.rollback()
                    flash(str(error), 'error')
            _, number = next_internal_number(cursor, date.today().year)
        return render_template('settlement_new.html', form=form, client_id=client_id, number=number, today=date.today(), **options)

    def create_order_from_form(cursor, client_id, form, options):
        by_code = {f'{p["code"]:04d}': p for p in options['products']}
        colors = []
        for i in range(1, 16):
            variant = clean(form.get(f'variant_{i}'))
            qty = to_int(form.get(f'qty_{i}'), f'Kolor {i} — ilość', minimum=0)
            color_id = form.get(f'color_{i}', '')
            if not variant and not qty and not color_id:
                continue
            product = by_code.get(variant.split()[0].zfill(4)) if variant else None
            if variant and product is None:
                raise ValueError(f'Kolor {i}: nie znaleziono produktu „{variant}” u tego klienta.')
            if not qty:
                raise ValueError(f'Kolor {i}: wpisz ilość zamówioną koloru.')
            color_id = int(color_id) if color_id.isdigit() else (product and product['color_id'])
            colorant = form.get(f'colorant_{i}', '')
            colorant_id = int(colorant) if colorant.isdigit() else (product and product['colorant_id'])
            name = next((c['name'] for c in options['colors'] if c['id'] == color_id), None) or clean(form.get(f'color_name_{i}'))
            if not name:
                raise ValueError(f'Kolor {i}: wybierz kolor.')
            dosage = to_num(form.get(f'dosage_{i}'), f'Kolor {i} — dozowanie')
            if dosage is None and product and product['colorant_pct'] is not None:
                dosage = product['colorant_pct']
            colors.append({'color_id': color_id, 'color_name': name, 'product_id': product and product['id'], 'colorant_id': colorant_id,
                           'dosage_pct': dosage, 'qty_ordered': qty})
        if not colors:
            raise ValueError('Dodaj co najmniej jeden kolor (specyfikacja, dok. 3).')
        header = order_header(form)
        if not header['product_name']:
            raise ValueError('Podaj nazwę produktu.')
        if header['qty_total'] is None:
            header['qty_total'] = sum(c['qty_ordered'] for c in colors)
        return insert_order(cursor, client_id, header, colors)

    def order_header(form):
        machine = to_int(form.get('machine_no'), 'Wtryskarka')
        if machine is not None and not 1 <= machine <= MACHINE_COUNT:
            raise ValueError('Numer wtryskarki 1–9.')
        values = {
            'product_name': clean(form.get('product_name')).upper(), 'machine_no': machine,
            'mold_id': int(form['mold_id']) if form.get('mold_id', '').isdigit() else None,
            'order_date': to_date(form.get('order_date'), 'Data zamówienia') or date.today(),
            'planned_start': to_date(form.get('planned_start'), 'Planowany start'),
            'planned_end': to_date(form.get('planned_end'), 'Planowany koniec'),
            'qty_total': to_int(form.get('qty_total'), 'Ilość zamówienia', minimum=1),
            'material_id': int(form['material_id']) if form.get('material_id', '').isdigit() else None,
            'material_text': clean(form.get('material_text')),
            'material_share': to_num(form.get('material_share'), 'Udział tworzywa') or Decimal(100),
            'material2_id': int(form['material2_id']) if form.get('material2_id', '').isdigit() else None,
            'material2_share': to_num(form.get('material2_share'), 'Udział tworzywa 2'),
            'material_kg': to_num(form.get('material_kg'), 'Zapotrzebowanie kg'),
            'net_g': to_num(form.get('net_g'), 'Waga detalu'), 'per_shift': to_int(form.get('per_shift'), 'Wydajność na zmianę'),
            'cavities': to_int(form.get('cavities'), 'Krotność', minimum=1) or 1,
            'pcs_per_carton': to_int(form.get('pcs_per_carton'), 'Sztuk w kartonie', minimum=1),
            'carton_kg': to_num(form.get('carton_kg'), 'Waga kartonu'), 'carton_type': clean(form.get('carton_type')),
            'notes': form.get('notes', '').strip(), 'issued_by': clean(form.get('issued_by')), 'accepted_by': clean(form.get('accepted_by')),
        }
        if values['material2_id'] and values['material2_share'] and values['material_share'] + values['material2_share'] != 100:
            raise ValueError('Udziały tworzyw muszą sumować się do 100%.')
        return values

    def insert_order(cursor, client_id, header, colors, zk_order_id=None):
        cursor.execute('SELECT pg_advisory_xact_lock(%s)', (LOCK_ID,))
        year = header['order_date'].year
        seq, number = next_internal_number(cursor, year)
        if header['material_kg'] is None and header['net_g']:
            header['material_kg'] = (Decimal(header['qty_total']) * Decimal(header['net_g']) / 1000 * Decimal(header['material_share'] or 100) / 100).quantize(Decimal('0.1'))
        fields = list(header)
        cursor.execute(f'''INSERT INTO prod_orders (number, seq, year, client_id, zk_order_id, {", ".join(fields)})
                           VALUES (%s,%s,%s,%s,%s,{", ".join("%s" for _ in fields)}) RETURNING id''',
                       [number, seq, year, client_id, zk_order_id] + [header[f] for f in fields])
        order_id = cursor.fetchone()['id']
        for lp, c in enumerate(colors, start=1):
            cursor.execute('''INSERT INTO prod_colors (prod_order_id, lp, color_id, color_name, product_id, colorant_id, dosage_pct, qty_ordered, zk_line_id)
                              VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)''',
                           (order_id, lp, c['color_id'], c['color_name'], c['product_id'], c['colorant_id'], c['dosage_pct'], c['qty_ordered'],
                            c.get('zk_line_id')))
        return order_id

    def issue_internal_orders(cursor, zk):
        """Nadanie kodu produkcji (przyjęcie ZK) = wystawienie zamówień produkcji (dok. 2): pozycje grupowane wg formy i maszyny.
        Idempotentne — jeśli ZK ma już zamówienia produkcji, nic nie robi. Zwraca listę id zleceń."""
        zk_id = zk['id']
        cursor.execute('SELECT id FROM prod_orders WHERE zk_order_id = %s ORDER BY seq', (zk_id,))
        existing = [r['id'] for r in cursor.fetchall()]
        if existing:
            return existing
        cursor.execute('''SELECT l.*, p.name AS pname, p.net_g, p.per_shift, p.cavities, p.pcs_per_carton, p.carton_kg, p.carton_type,
                                 p.material_text, p.colorant_pct, col.name AS color_name
                          FROM order_lines l JOIN products p ON p.id = l.product_id LEFT JOIN colors col ON col.id = l.color_id
                          WHERE l.order_id = %s ORDER BY l.planned_start NULLS LAST, l.lp''', (zk_id,))
        groups = {}
        for line in cursor.fetchall():
            groups.setdefault((line['mold_id'], line['machine_no']), []).append(line)
        created = []
        for (mold_id, machine), lines in groups.items():
            first = lines[0]
            header = {'product_name': base_name([l['pname'] for l in lines]).upper(), 'machine_no': machine, 'mold_id': mold_id,
                      'order_date': date.today(), 'planned_start': first['planned_start'] and first['planned_start'].date(),
                      'planned_end': max((l['planned_end'] for l in lines if l['planned_end']), default=None),
                      'qty_total': sum(l['qty'] or 0 for l in lines), 'material_id': first['material_id'],
                      'material_text': first['material_text'], 'material_share': Decimal(100), 'material2_id': None,
                      'material2_share': None, 'material_kg': None, 'net_g': first['net_g'], 'per_shift': first['per_shift'],
                      'cavities': int(first['cavities'] or 1), 'pcs_per_carton': first['pcs_per_carton'] and int(first['pcs_per_carton']),
                      'carton_kg': first['carton_kg'], 'carton_type': first['carton_type'],
                      'notes': f'Z zamówienia klienta {zk["number"]}' + (f' (nr klienta {zk["client_ref"]})' if zk['client_ref'] else ''),
                      'issued_by': '', 'accepted_by': ''}
            if header['planned_end']:
                header['planned_end'] = header['planned_end'].date()
            colors = [{'color_id': l['color_id'], 'color_name': l['color_name'] or l['pname'], 'product_id': l['product_id'],
                       'colorant_id': l['colorant_id'], 'dosage_pct': l['colorant_pct'], 'qty_ordered': l['qty'] or 0, 'zk_line_id': l['id']}
                      for l in lines]
            created.append(insert_order(cursor, zk['client_id'], header, colors, zk_id))
        return created

    @app.post('/rozliczenie/z-zamowienia/<int:zk_id>')
    @auth
    def settlement_from_zk(zk_id):
        """Przyjęte zamówienie klienta ZK → zamówienia produkcji: pozycje grupowane wg formy i maszyny (1 forma = 1 zamówienie)."""
        require_csrf()
        with db() as connection, connection.cursor() as cursor:
            cursor.execute("SELECT * FROM orders WHERE id = %s AND status = 'PRZYJĘTE' FOR UPDATE", (zk_id,))
            zk = cursor.fetchone()
            if zk is None:
                flash('Zamówienia produkcji tworzy się z zamówienia o statusie PRZYJĘTE.', 'error')
                return redirect(url_for('order_detail', order_id=zk_id))
            created = issue_internal_orders(cursor, zk)
            if not created:
                flash('Zamówienie nie ma pozycji powiązanych z produktami.', 'error')
                return redirect(url_for('order_detail', order_id=zk_id))
            cursor.execute("UPDATE orders SET status = 'W PRODUKCJI', started_at = NOW() WHERE id = %s", (zk_id,))
            cursor.execute('SELECT id, number FROM prod_orders WHERE id = ANY(%s) ORDER BY seq', (created,))
            numbers = [r['number'] for r in cursor.fetchall()]
        flash(f'Utworzono zamówienia produkcji: {", ".join(numbers)}. Zamówienie {zk["number"]} jest teraz w produkcji.', 'success')
        return redirect(url_for('settlement_order', order_id=created[0]) if len(created) == 1 else url_for('settlement_index'))

    @app.get('/rozliczenie/<int:order_id>/zlecenie')
    @auth
    def settlement_zlecenie(order_id):
        """Dokument: zamówienie produkcji na realizację produkcji — wystawiane przy nadaniu kodu produkcji (przyjęcie ZK)."""
        with db() as connection, connection.cursor() as cursor:
            order, colors = load_order(cursor, order_id)
            zk = None
            if order['zk_order_id']:
                cursor.execute('SELECT number, order_date, accepted_at, delivery_date, client_ref FROM orders WHERE id = %s', (order['zk_order_id'],))
                zk = cursor.fetchone()
        return render_template('zlecenie_print.html', order=order, colors=[c for c in colors if c['status'] != 'X'], zk=zk, today=date.today())

    # ---------- karta zamówienia produkcji ----------
    @app.get('/rozliczenie/<int:order_id>')
    @auth
    def settlement_order(order_id):
        with db() as connection, connection.cursor() as cursor:
            order, colors = load_order(cursor, order_id)
            checks = order_checks(cursor, order, colors)
            options = option_lists(cursor, order['client_id'])
        options['palette'] = options.pop('colors')
        active = [c for c in colors if c['status'] != 'X']
        totals = {'ordered': sum(c['summary']['ordered'] for c in active), 'good': sum(c['summary']['good'] for c in active),
                  'surplus': sum(c['summary']['surplus'] for c in active if c['summary']['good']),
                  'cycles': sum(c['summary']['cycles'] or 0 for c in active if c['summary']['scrap'] is not None),
                  'scrap': sum(c['summary']['scrap'] or 0 for c in active if c['summary']['scrap'] is not None),
                  'received': sum(int(c['received']) for c in active)}
        cav = int(order['cavities'] or 1)
        totals['scrap_pct'] = round(totals['scrap'] / (totals['cycles'] * cav) * 100, 1) if totals['cycles'] else None
        return render_template('settlement_order.html', order=order, colors=colors, checks=checks, totals=totals,
                               print_mode=request.args.get('druk'), today=date.today(), **options)

    @app.post('/rozliczenie/<int:order_id>')
    @auth
    def settlement_order_save(order_id):
        require_csrf()
        form, action = request.form, request.form.get('action', 'save')
        with db() as connection, connection.cursor() as cursor:
            order, colors = load_order(cursor, order_id)
            try:
                if action == 'cancel':
                    if any(c['status'] == 'ROZLICZONY' for c in colors):
                        raise ValueError('Zamówienie ma rozliczone kolory — najpierw cofnij rozliczenia.')
                    cursor.execute("UPDATE prod_orders SET status = 'ANULOWANE' WHERE id = %s", (order_id,))
                    flash(f'Anulowano zamówienie produkcji {order["number"]}.', 'success')
                    return redirect(url_for('settlement_index'))
                if action == 'delete':
                    cursor.execute('SELECT COUNT(*) AS n FROM prod_shifts s JOIN prod_colors pc ON pc.id = s.prod_color_id WHERE pc.prod_order_id = %s', (order_id,))
                    if cursor.fetchone()['n']:
                        raise ValueError('Zamówienie ma wpisane zmiany — można je tylko anulować.')
                    cursor.execute('DELETE FROM prod_orders WHERE id = %s', (order_id,))
                    flash(f'Usunięto zamówienie produkcji {order["number"]}.', 'success')
                    return redirect(url_for('settlement_index'))
                if action == 'reopen' and order['status'] == 'ANULOWANE':
                    cursor.execute("UPDATE prod_orders SET status = 'PLANOWANE' WHERE id = %s", (order_id,))
                    refresh_order_status(cursor, order_id)
                    flash('Przywrócono zamówienie.', 'success')
                    return redirect(url_for('settlement_order', order_id=order_id))
                header = order_header(form)
                if header['qty_total'] is None:
                    raise ValueError('Podaj ilość całego zamówienia.')
                fields = list(header)
                cursor.execute(f'UPDATE prod_orders SET {", ".join(f + " = %s" for f in fields)} WHERE id = %s', [header[f] for f in fields] + [order_id])
                for c in colors:
                    key = str(c['id'])
                    if f'qty_{key}' not in form:
                        continue
                    qty = to_int(form.get(f'qty_{key}'), f'{c["color_name"]} — ilość', minimum=0) or 0
                    colorant = form.get(f'colorant_{key}', '')
                    color_id = form.get(f'color_{key}', '')
                    name = clean(form.get(f'color_name_{key}')) or c['color_name']
                    cursor.execute('''UPDATE prod_colors SET qty_ordered = %s, colorant_id = %s, dosage_pct = %s, color_id = %s, color_name = %s,
                                      status = CASE WHEN %s AND status <> 'ROZLICZONY' THEN 'X'
                                                    WHEN NOT %s AND status = 'X' THEN 'DO PRODUKCJI' ELSE status END WHERE id = %s''',
                                   (qty, int(colorant) if colorant.isdigit() else None, to_num(form.get(f'dosage_{key}'), 'Dozowanie'),
                                    int(color_id) if color_id.isdigit() else None, name,
                                    form.get(f'x_{key}') == '1', form.get(f'x_{key}') == '1', c['id']))
                if action == 'add_color':
                    color_id = form.get('new_color', '')
                    qty = to_int(form.get('new_qty'), 'Ilość nowego koloru', minimum=1)
                    if not color_id.isdigit() or not qty:
                        raise ValueError('Nowy kolor: wybierz kolor i wpisz ilość.')
                    variant = clean(form.get('new_variant'))
                    product_id, colorant_id, dosage = None, None, None
                    if variant:
                        cursor.execute('SELECT id, colorant_id, colorant_pct FROM products WHERE client_id = %s AND code = %s',
                                       (order['client_id'], int(variant.split()[0]) if variant.split()[0].isdigit() else -1))
                        p = cursor.fetchone()
                        if p:
                            product_id, colorant_id, dosage = p['id'], p['colorant_id'], p['colorant_pct']
                    cursor.execute('SELECT name FROM colors WHERE id = %s', (int(color_id),))
                    name = cursor.fetchone()['name']
                    cursor.execute('SELECT COALESCE(MAX(lp), 0) + 1 AS lp FROM prod_colors WHERE prod_order_id = %s', (order_id,))
                    cursor.execute('''INSERT INTO prod_colors (prod_order_id, lp, color_id, color_name, product_id, colorant_id, dosage_pct, qty_ordered)
                                      VALUES (%s,%s,%s,%s,%s,%s,%s,%s)''',
                                   (order_id, cursor.fetchone()['lp'], int(color_id), name, product_id, colorant_id, dosage, qty))
                    flash(f'Dodano kolor {name} do specyfikacji.', 'success')
                elif action.startswith('delete_color:'):
                    cid = int(action.split(':')[1])
                    cursor.execute('SELECT COUNT(*) AS n FROM prod_shifts WHERE prod_color_id = %s', (cid,))
                    if cursor.fetchone()['n']:
                        raise ValueError('Kolor ma wpisane zmiany — oznacz go jako X (nie produkowany) zamiast usuwać.')
                    cursor.execute('DELETE FROM prod_colors WHERE id = %s AND prod_order_id = %s', (cid, order_id))
                    flash('Usunięto kolor ze specyfikacji.', 'success')
                else:
                    flash('Zapisano zamówienie produkcji i specyfikację.', 'success')
                refresh_order_status(cursor, order_id)
                assign_batch(cursor, order_id)
            except ValueError as error:
                connection.rollback()
                flash(str(error), 'error')
        return redirect(url_for('settlement_order', order_id=order_id))

    # ---------- kolor: raport zmianowy, licznik, rozliczenie, przyjęcie, etykiety ----------
    def load_color(cursor, color_id):
        cursor.execute('SELECT prod_order_id FROM prod_colors WHERE id = %s', (color_id,))
        row = cursor.fetchone()
        if row is None:
            abort(404)
        order, colors = load_order(cursor, row['prod_order_id'])
        color = next(c for c in colors if c['id'] == color_id)
        return order, colors, color

    @app.get('/rozliczenie/kolor/<int:color_id>')
    @auth
    def settlement_color(color_id):
        with db() as connection, connection.cursor() as cursor:
            order, colors, color = load_color(cursor, color_id)
            cursor.execute('SELECT * FROM prod_receipts WHERE prod_color_id = %s ORDER BY receipt_date, id', (color_id,))
            receipts = cursor.fetchall()
            cursor.execute('SELECT * FROM productions WHERE prod_color_id = %s', (color_id,))
            stat = cursor.fetchone()
            zu = None
            if color['zu_doc_id']:
                cursor.execute('SELECT id, number, status FROM machine_docs WHERE id = %s', (color['zu_doc_id'],))
                zu = cursor.fetchone()
        summary = color['summary']
        values = stat_values(order, color, summary)
        use = material_use(order, color, summary)
        checks = dict(summary['checks'])
        if stat:
            checks['K9'] = ('ok', f'{stat["scrap_pcs"]} = {summary["scrap"]}') if stat['scrap_pcs'] is None or summary['scrap'] is None or int(stat['scrap_pcs']) == summary['scrap'] else ('error', f'statystyka {stat["scrap_pcs"]} ≠ {summary["scrap"]}')
            received = sum(r['qty'] for r in receipts)
            checks['K10'] = ('ok', f'przyjęto {received} = statystyka {int(stat["qty"])}') if received == int(stat['qty']) else \
                ('warn', f'przyjęto {received} ≠ statystyka {int(stat["qty"])} — różnica {received - int(stat["qty"])} szt. do wyjaśnienia')
        checks['K12'] = ('ok', f'etykiety z {color["label_date"]:%d.%m.%Y}, QC nr {color["qc_no"]}') if color['label_date'] and color['qc_no'] else ('warn', 'wydrukuj etykiety z datą i numerem pracownika QC')
        # podpowiedź wzoru produkcyjnego: rok/miesiąc-kolejna litera koloru w zamówieniu
        suggested_pattern = color['pattern_no']
        if not suggested_pattern and summary['start']:
            prefix = summary['start'].strftime('%y/%m')
            used = sum(1 for c in colors if c['id'] != color_id and (c['pattern_no'] or '').startswith(prefix))
            suggested_pattern = f'{prefix}-{pattern_letter(used)}'
        last = summary['rows'][-1]['s'] if summary['rows'] else None
        next_shift = {'date': date.today().isoformat(), 'shift': 'I'}
        if last:
            idx = SHIFTS.index(last['shift'])
            if idx + 1 < 2:
                next_shift = {'date': last['shift_date'].isoformat(), 'shift': SHIFTS[idx + 1]}
            else:
                d = last['shift_date'] + timedelta(days=1)
                while d.weekday() >= 5:
                    d += timedelta(days=1)
                next_shift = {'date': d.isoformat(), 'shift': 'I'}
        return render_template('settlement_color.html', order=order, colors=colors, color=color, summary=summary, values=values, use=use,
                               checks=checks, receipts=receipts, stat=stat, zu=zu, suggested_pattern=suggested_pattern,
                               next_shift=next_shift, last=last, today=date.today())

    @app.post('/rozliczenie/kolor/<int:color_id>')
    @auth
    def settlement_color_save(color_id):
        require_csrf()
        form, action = request.form, request.form.get('action', '')
        anchor = ''
        with db() as connection, connection.cursor() as cursor:
            cursor.execute('SELECT pg_advisory_xact_lock(%s)', (LOCK_ID,))
            order, colors, color = load_color(cursor, color_id)
            settled = color['status'] == 'ROZLICZONY'
            try:
                if action in ('add_shift', 'save_shifts') or action.startswith('delete_shift:'):
                    if settled:
                        raise ValueError('Kolor jest rozliczony — cofnij rozliczenie, żeby zmienić raport zmianowy.')
                    if order['status'] == 'ANULOWANE':
                        raise ValueError('Zamówienie jest anulowane.')
                    anchor = '#zmiany'
                    save_shifts(cursor, color_id, form)
                    if action == 'add_shift':
                        add_shift(cursor, order, color, form)
                    elif action.startswith('delete_shift:'):
                        cursor.execute('DELETE FROM prod_shifts WHERE id = %s AND prod_color_id = %s', (int(action.split(':')[1]), color_id))
                        flash('Usunięto wpis zmiany.', 'success')
                    else:
                        flash('Zapisano raport zmianowy.', 'success')
                    cursor.execute("UPDATE prod_colors SET status = CASE WHEN EXISTS (SELECT 1 FROM prod_shifts WHERE prod_color_id = %s) THEN 'W PRODUKCJI' ELSE 'DO PRODUKCJI' END WHERE id = %s AND status NOT IN ('ROZLICZONY','X')",
                                   (color_id, color_id))
                    assign_batch(cursor, order['id'])
                elif action in ('save_end', 'settle'):
                    if settled:
                        raise ValueError('Kolor jest już rozliczony.')
                    anchor = '#rozliczenie'
                    save_end(cursor, color_id, form)
                    if action == 'settle':
                        order, colors, color = load_color(cursor, color_id)
                        settle(cursor, order, color, form)
                    else:
                        flash('Zapisano dane końca koloru.', 'success')
                elif action == 'unsettle':
                    cursor.execute('SELECT COUNT(*) AS n FROM prod_receipts WHERE prod_color_id = %s', (color_id,))
                    if cursor.fetchone()['n']:
                        raise ValueError('Kolor ma przyjęcia na magazyn (PW) — najpierw je usuń.')
                    cursor.execute('DELETE FROM productions WHERE prod_color_id = %s', (color_id,))
                    cursor.execute("UPDATE prod_colors SET status = 'W PRODUKCJI', settled_at = NULL, settled_by = NULL WHERE id = %s", (color_id,))
                    flash('Cofnięto rozliczenie — wiersz usunięto ze statystyki.', 'success')
                elif action == 'add_receipt':
                    anchor = '#przyjecie'
                    if not settled:
                        raise ValueError('Na magazyn przyjmuje się kolor rozliczony (wiersz w statystyce).')
                    add_receipt(cursor, color, form)
                elif action.startswith('delete_receipt:'):
                    anchor = '#przyjecie'
                    check_pw_delete(cursor, int(action.split(':')[1]))
                    cursor.execute('DELETE FROM prod_receipts WHERE id = %s AND prod_color_id = %s', (int(action.split(':')[1]), color_id))
                    flash('Usunięto przyjęcie PW.', 'success')
                elif action == 'zu':
                    anchor = '#zuzycie'
                    create_zu(cursor, order, color)
                else:
                    raise ValueError('Nieznana operacja.')
                refresh_order_status(cursor, order['id'])
            except ValueError as error:
                connection.rollback()
                flash(str(error), 'error')
        return redirect(url_for('settlement_color', color_id=color_id) + anchor)

    def shift_values(form, prefix=''):
        shift = form.get(prefix + 'shift', '')
        if shift not in SHIFTS:
            raise ValueError('Wybierz zmianę I, II lub III.')
        return {
            'shift_date': to_date(form.get(prefix + 'shift_date'), 'Data zmiany', required=True), 'shift': shift,
            'operator': clean(form.get(prefix + 'operator')).upper(),
            'qty_good': to_int(form.get(prefix + 'qty_good'), 'Wykonano (dobre sztuki)', minimum=0) or 0,
            'remaining_entered': to_int(form.get(prefix + 'remaining_entered'), 'Zostało (wpis operatora)', minimum=0),
            'cartons': to_int(form.get(prefix + 'cartons'), 'Kartony', minimum=0),
            'pcs_per_carton': to_int(form.get(prefix + 'pcs_per_carton'), 'Sztuk w kartonie', minimum=1),
            'plc_counter': to_int(form.get(prefix + 'plc_counter'), 'Licznik PLC', minimum=0),
            'counter_reset': form.get(prefix + 'counter_reset') == '1',
            'cycle_s': to_num(form.get(prefix + 'cycle_s'), 'Czas cyklu'), 'notes': clean(form.get(prefix + 'notes')),
        }

    def add_shift(cursor, order, color, form):
        values = shift_values(form, 'new_')
        if not values['qty_good'] and values['plc_counter'] is None and values['cartons'] is None:
            raise ValueError('Wpisz co najmniej wykonane sztuki, kartony albo licznik PLC.')
        if values['cartons'] is not None and not values['qty_good']:
            ppc = values['pcs_per_carton'] or order['pcs_per_carton']
            if ppc:
                values['qty_good'] = values['cartons'] * ppc
        cursor.execute('''SELECT 1 FROM prod_shifts WHERE prod_color_id = %s AND shift_date = %s AND shift = %s''',
                       (color['id'], values['shift_date'], values['shift']))
        if cursor.fetchone():
            raise ValueError(f'Zmiana {values["shift_date"]:%d.%m} {values["shift"]} jest już wpisana dla tego koloru — popraw istniejący wiersz.')
        fields = list(values)
        cursor.execute(f'INSERT INTO prod_shifts (prod_color_id, {", ".join(fields)}) VALUES (%s, {", ".join("%s" for _ in fields)})',
                       [color['id']] + [values[f] for f in fields])
        flash(f'Dodano zmianę {values["shift_date"]:%d.%m} {values["shift"]}: {values["qty_good"]} szt.', 'success')

    def save_shifts(cursor, color_id, form):
        cursor.execute('SELECT id FROM prod_shifts WHERE prod_color_id = %s', (color_id,))
        for row in cursor.fetchall():
            prefix = f's{row["id"]}_'
            if prefix + 'shift_date' not in form:
                continue
            values = shift_values(form, prefix)
            cursor.execute(f'UPDATE prod_shifts SET {", ".join(f + " = %s" for f in values)} WHERE id = %s', list(values.values()) + [row['id']])

    def save_end(cursor, color_id, form):
        pattern_end = form.get('pattern_at_end', '')
        cursor.execute('''UPDATE prod_colors SET spec_good = %s, net_g = %s, shot_g = %s, stat_cycle_s = %s, mounted_by = %s, dismounted_by = %s,
                          pattern_at_end = %s, pattern_no = %s, notes = %s, settled_by = %s WHERE id = %s''',
                       (to_int(form.get('spec_good'), 'Dół specyfikacji', minimum=0), to_num(form.get('net_g'), 'Waga netto'),
                        to_num(form.get('shot_g'), 'Waga brutto wtrysku'), to_num(form.get('stat_cycle_s'), 'Czas cyklu'),
                        clean(form.get('mounted_by')).upper() or None, clean(form.get('dismounted_by')).upper() or None,
                        pattern_end if pattern_end in ('TAK', 'NIE') else None, clean(form.get('pattern_no')) or None,
                        form.get('notes', '').strip() or None, clean(form.get('settled_by')) or None, color_id))

    def settle(cursor, order, color, form):
        s = color['summary']
        errors = []
        if not s['rows']:
            errors.append('brak wpisanych zmian (raport zmianowy, dok. 4)')
        if not s['good']:
            errors.append('brak dobrych sztuk')
        for code in ('K6', 'K7', 'K8'):
            level, text = s['checks'][code]
            if level == 'error':
                errors.append(f'{code}: {text}')
        if color['spec_good'] is None:
            errors.append('wpisz ilość z dołu specyfikacji (dok. 3) — K8')
        if not color['net_g'] or not color['shot_g']:
            errors.append('zważ detal netto i cały wtrysk z wlewkiem (waga w biurze)')
        if s['scrap'] is None and form.get('no_counter') != '1':
            errors.append('licznik PLC niepełny albo brak odczytów — dolicz odczyty albo zaznacz „rozlicz z pustymi brakami”')
        if errors:
            raise ValueError('Nie można rozliczyć koloru: ' + ' | '.join(errors))
        values = stat_values(order, color, s)
        material = order['material_name'] or order['material_text'] or ''
        if order['material2_id']:
            material += f' {Decimal(order["material_share"]).normalize():f}% {order["material2_name"]} {Decimal(order["material2_share"]).normalize():f}%'
        record = {
            'client_id': order['client_id'], 'product_id': color['product_id'], 'mold_id': order['mold_id'], 'colorant_id': color['colorant_id'],
            'source': 'ROZLICZENIE', 'prod_color_id': color['id'],
            'product_name': color['product_variant'] or f'{order["product_name"]} {color["color_name"]}',
            'start_date': s['start'], 'end_date': s['end'], 'internal_order': order['number'], 'machine_no': str(order['machine_no'] or ''),
            'qty': s['good'], 'cycle_s': values['cycle_s'], 'avg_per_shift': values['avg_per_shift'], 'cavities': order['cavities'],
            'real_cycle_s': values['real_cycle_s'], 'scrap_pcs': s['scrap'], 'cycles': None if s['partial'] else s['cycles'], 'net_g': color['net_g'],
            'shot_g': color['shot_g'], 'piece_gross_g': values['piece_gross_g'], 'pcs_per_carton': order['pcs_per_carton'],
            'carton_kg': order['carton_kg'], 'carton_type': order['carton_type'], 'pattern_no': color['pattern_no'],
            'material': material.strip(), 'colorant': color['colorant_symbol'] or color['colorant_text'], 'dosage_pct': color['dosage_pct'],
            'mounted_by': color['mounted_by'], 'dismounted_by': color['dismounted_by'], 'pattern_at_end': color['pattern_at_end'],
            'notes': color['notes'], 'batch_code': order['batch_code'], 'source_sheet': 'ROZLICZENIE',
        }
        fields = list(record)
        cursor.execute(f'INSERT INTO productions ({", ".join(fields)}) VALUES ({", ".join("%s" for _ in fields)})', [record[f] for f in fields])
        cursor.execute("UPDATE prod_colors SET status = 'ROZLICZONY', settled_at = NOW() WHERE id = %s", (color['id'],))
        if color['product_id']:
            # karta produktu dostaje najnowsze parametry z rozliczenia (jak w bazie produktów — „z najnowszego zlecenia”)
            cursor.execute('''UPDATE products SET net_g = COALESCE(%s, net_g), gross_g = COALESCE(%s, gross_g), cycle_s = COALESCE(%s, cycle_s),
                              per_shift = COALESCE(%s, per_shift), orders_count = COALESCE(orders_count, 0) + 1,
                              produced_total = COALESCE(produced_total, 0) + %s, last_production = %s,
                              first_production = COALESCE(first_production, %s) WHERE id = %s''',
                           (color['net_g'], values['piece_gross_g'], values['cycle_s'], values['avg_per_shift'], s['good'], s['end'], s['start'],
                            color['product_id']))
        scrap = f', braki {s["scrap"]} szt. ({s["scrap_pct"]}%)' if s['scrap'] is not None else ', braki puste (brak licznika)'
        flash(f'Kolor {color["color_name"]} rozliczony: {s["good"]} dobrych szt.{scrap}. Wiersz dopisano do statystyki (dok. 6). '
              'Przekaż kartony na magazyn (dok. 10).', 'success')

    def add_receipt(cursor, color, form):
        qty = to_int(form.get('qty'), 'Ilość przyjęta', minimum=1)
        if not qty:
            raise ValueError('Wpisz ilość przyjętą w sztukach.')
        day = to_date(form.get('receipt_date'), 'Data przyjęcia', required=True)
        prefix = day.strftime('%m/')
        cursor.execute('''SELECT COALESCE(MAX(CAST(SPLIT_PART(pw_number, '/', 2) AS INTEGER)), 0) + 1 AS n FROM prod_receipts
                          WHERE pw_number LIKE %s AND EXTRACT(YEAR FROM receipt_date) = %s''', (prefix + '%', day.year))
        pw = clean(form.get('pw_number')) or f'{prefix}{cursor.fetchone()["n"]:04d}'
        location = clean(form.get('location')) or None
        cursor.execute('''INSERT INTO prod_receipts (prod_color_id, receipt_date, receipt_time, qty, pw_number, received_by, notes, location)
                          VALUES (%s,%s,%s,%s,%s,%s,%s,%s) RETURNING id''',
                       (color['id'], day, clean(form.get('receipt_time')), qty, pw, clean(form.get('received_by')), clean(form.get('notes')), location))
        receipt_id = cursor.fetchone()['id']
        order, _, color = load_color(cursor, color['id'])
        register_pw(cursor, receipt_id, order, color, day, qty, location)
        flash(f'Przyjęto na magazyn wyrobów gotowych {qty} szt. — PW {pw}' + (f', miejsce {location}' if location else '') + '.', 'success')

    def create_zu(cursor, order, color):
        """Dokument zużycia (ZU) dla magazyniera: cykle × waga wtrysku, podział tworzywo / barwnik wg dozowania."""
        if color['zu_doc_id']:
            raise ValueError('Dokument zużycia dla tego koloru już istnieje.')
        if not order['machine_no']:
            raise ValueError('Zamówienie nie ma wtryskarki.')
        use = material_use(order, color, color['summary'])
        if not use:
            raise ValueError('Brak cykli lub wagi wtrysku — nie da się policzyć zużycia.')
        lines = []
        if order['material_id']:
            share2 = Decimal(order['material2_share'] or 0) if order['material2_id'] else Decimal(0)
            lines.append((order['material_id'], (use['material'] * (100 - share2) / 100).quantize(Decimal('0.001'))))
            if share2:
                lines.append((order['material2_id'], (use['material'] * share2 / 100).quantize(Decimal('0.001'))))
        if color['colorant_id'] and use['colorant']:
            lines.append((color['colorant_id'], use['colorant']))
        if not lines:
            raise ValueError('Tworzywo i barwnik nie są wybrane z kartoteki magazynu.')
        number = next_doc_number(cursor, 'ZU', date.today().year)
        cursor.execute('''INSERT INTO machine_docs (number, doc_type, machine_id, doc_date, order_ref, notes, created_by)
                          VALUES (%s, 'ZUZYCIE', %s, %s, %s, %s, 'rozliczenie produkcji') RETURNING id''',
                       (number, order['machine_no'], color['summary']['end'] or date.today(), f'{order["number"]} / {order["batch_code"] or ""}',
                        f'{order["product_name"]} {color["color_name"]}: {use["cycles"]} cykli × {color["shot_g"]} g'))
        doc_id = cursor.fetchone()['id']
        for material_id, kg in lines:
            cursor.execute('''INSERT INTO machine_doc_lines (doc_id, material_id, qty_kg) VALUES (%s,%s,%s)
                              ON CONFLICT (doc_id, material_id) DO UPDATE SET qty_kg = machine_doc_lines.qty_kg + EXCLUDED.qty_kg''',
                           (doc_id, material_id, kg))
        cursor.execute('UPDATE prod_colors SET zu_doc_id = %s WHERE id = %s', (doc_id, color['id']))
        flash(f'Utworzono dokument zużycia {number} na maszynę {order["machine_no"]} — magazynier zatwierdza go w module Maszyny.', 'success')

    @app.route('/rozliczenie/kolor/<int:color_id>/etykiety', methods=['GET', 'POST'])
    @auth
    def settlement_labels(color_id):
        with db() as connection, connection.cursor() as cursor:
            order, colors, color = load_color(cursor, color_id)
            if request.method == 'POST':
                require_csrf()
                try:
                    qc = clean(request.form.get('qc_no'))
                    if not qc:
                        raise ValueError('Podaj numer pracownika do pieczątki Q.C.')
                    day = to_date(request.form.get('label_date'), 'Data etykiety', required=True)
                    count = to_int(request.form.get('count'), 'Liczba etykiet', minimum=1) or 1
                    cursor.execute('UPDATE prod_colors SET label_date = %s, qc_no = %s, labels_printed = %s WHERE id = %s', (day, qc, count, color_id))
                    connection.commit()
                    order, colors, color = load_color(cursor, color_id)
                    return render_template('settlement_labels.html', order=order, color=color, count=count, per_carton=order['pcs_per_carton'],
                                           print_now=True)
                except ValueError as error:
                    flash(str(error), 'error')
        s = color['summary']
        default = s['cartons'] + (1 if s['carton_rest'] else 0) if s['cartons'] is not None else 1
        return render_template('settlement_labels.html', order=order, color=color, count=max(default, 1), per_carton=order['pcs_per_carton'],
                               print_now=False, today=date.today())

    # ---------- przyjęcia wyrobów na magazyn (dok. 10) ----------
    @app.get('/przyjecia-wyrobow')
    @auth
    def finished_receipts():
        month = request.args.get('miesiac', '') or date.today().strftime('%Y-%m')
        try:
            first = date.fromisoformat(month + '-01')
        except ValueError:
            abort(400)
        last = (first.replace(day=28) + timedelta(days=4)).replace(day=1)
        with db() as connection, connection.cursor() as cursor:
            cursor.execute('''SELECT r.*, pc.color_name, pc.id AS color_id, po.number, po.product_name, c.short_name, st.qty AS stat_qty,
                                     (SELECT SUM(x.qty) FROM prod_receipts x WHERE x.prod_color_id = pc.id) AS color_received
                              FROM prod_receipts r JOIN prod_colors pc ON pc.id = r.prod_color_id JOIN prod_orders po ON po.id = pc.prod_order_id
                              JOIN clients c ON c.id = po.client_id LEFT JOIN productions st ON st.prod_color_id = pc.id
                              WHERE r.receipt_date >= %s AND r.receipt_date < %s ORDER BY r.receipt_date, r.pw_number''', (first, last))
            receipts = cursor.fetchall()
            cursor.execute('''SELECT pc.id AS color_id, pc.color_name, po.number, po.product_name, c.short_name, st.qty AS stat_qty, st.end_date,
                                     COALESCE((SELECT SUM(x.qty) FROM prod_receipts x WHERE x.prod_color_id = pc.id), 0) AS received
                              FROM prod_colors pc JOIN prod_orders po ON po.id = pc.prod_order_id JOIN clients c ON c.id = po.client_id
                              JOIN productions st ON st.prod_color_id = pc.id
                              WHERE pc.status = 'ROZLICZONY' AND COALESCE((SELECT SUM(x.qty) FROM prod_receipts x WHERE x.prod_color_id = pc.id), 0) <> st.qty
                              ORDER BY st.end_date''')
            open_items = cursor.fetchall()
        return render_template('finished_receipts.html', receipts=receipts, open_items=open_items, month=month)

    # ---------- K11: zużycie materiału vs ubytek w inwenturze ----------
    @app.get('/zuzycie-materialow')
    @auth
    def material_consumption():
        with db() as connection, connection.cursor() as cursor:
            cursor.execute("SELECT id, number, count_date, scope FROM inventories WHERE status = 'ZATWIERDZONA' ORDER BY count_date")
            inventories = cursor.fetchall()
            ids = [i['id'] for i in inventories]
            a = int(request.args['od']) if request.args.get('od', '').isdigit() else (ids[-2] if len(ids) > 1 else None)
            b = int(request.args['do']) if request.args.get('do', '').isdigit() else (ids[-1] if ids else None)
            rows, inv_a, inv_b = [], None, None
            if a and b:
                inv_a = next((i for i in inventories if i['id'] == a), None)
                inv_b = next((i for i in inventories if i['id'] == b), None)
            if inv_a and inv_b and inv_a['count_date'] < inv_b['count_date']:
                cursor.execute('''
                    WITH ca AS (SELECT material_id, counted_kg FROM inventory_lines WHERE inventory_id = %(a)s AND counted_kg IS NOT NULL),
                         cb AS (SELECT material_id, counted_kg FROM inventory_lines WHERE inventory_id = %(b)s AND counted_kg IS NOT NULL),
                         dl AS (SELECT rl.material_id, SUM(rl.qty_kg) AS kg FROM receipt_lines rl JOIN receipts r ON r.id = rl.receipt_id
                                WHERE r.status = 'ZREALIZOWANY' AND r.realized_at::date > %(da)s AND r.realized_at::date <= %(db)s GROUP BY rl.material_id),
                         pr AS (SELECT COALESCE(po.material_id, p.material_id) AS material_id, s.id, s.product_name, s.internal_order,
                                       COALESCE(s.cycles, CEIL((COALESCE(s.qty,0) + COALESCE(s.scrap_pcs,0)) / NULLIF(COALESCE(s.cavities,1),0))) AS cycles,
                                       s.shot_g, COALESCE(s.dosage_pct, 0) AS dosage, s.end_date
                                FROM productions s LEFT JOIN products p ON p.id = s.product_id
                                LEFT JOIN prod_colors pc ON pc.id = s.prod_color_id LEFT JOIN prod_orders po ON po.id = pc.prod_order_id
                                WHERE s.end_date > %(da)s AND s.end_date <= %(db)s),
                         use AS (SELECT material_id, SUM(cycles * shot_g / 1000 * (1 - dosage / 100)) AS kg, COUNT(*) AS rows,
                                        COUNT(*) FILTER (WHERE shot_g IS NULL OR cycles IS NULL) AS incomplete
                                 FROM pr WHERE material_id IS NOT NULL GROUP BY material_id)
                    SELECT m.id, m.material_index, COALESCE(m.internal_name, m.symbol) AS name, ca.counted_kg AS kg_a, cb.counted_kg AS kg_b,
                           COALESCE(dl.kg, 0) AS delivered, use.kg AS used, use.rows, use.incomplete
                    FROM materials m LEFT JOIN ca ON ca.material_id = m.id LEFT JOIN cb ON cb.material_id = m.id
                    LEFT JOIN dl ON dl.material_id = m.id LEFT JOIN use ON use.material_id = m.id
                    WHERE m.material_type = 'SUROWIEC SYPKI' AND (ca.counted_kg IS NOT NULL OR cb.counted_kg IS NOT NULL OR use.kg IS NOT NULL)
                    ORDER BY m.material_index''', {'a': a, 'b': b, 'da': inv_a['count_date'], 'db': inv_b['count_date']})
                for r in cursor.fetchall():
                    loss = (r['kg_a'] + r['delivered'] - r['kg_b']) if r['kg_a'] is not None and r['kg_b'] is not None else None
                    r['loss'] = loss
                    r['diff'] = (loss - (r['used'] or 0)) if loss is not None else None
                    r['pct'] = round(float((r['used'] or 0) / loss * 100), 0) if loss and loss > 0 else None
                    r['flag'] = r['diff'] is not None and bool(loss) and abs(r['diff']) > abs(loss) / 4 and abs(r['diff']) > 100
                    rows.append(r)
            detail = []
            material = request.args.get('material', '')
            if material.isdigit() and inv_a and inv_b:
                cursor.execute('''SELECT s.*, c.short_name FROM productions s JOIN clients c ON c.id = s.client_id
                                  LEFT JOIN products p ON p.id = s.product_id LEFT JOIN prod_colors pc ON pc.id = s.prod_color_id
                                  LEFT JOIN prod_orders po ON po.id = pc.prod_order_id
                                  WHERE COALESCE(po.material_id, p.material_id) = %s AND s.end_date > %s AND s.end_date <= %s ORDER BY s.end_date''',
                               (int(material), inv_a['count_date'], inv_b['count_date']))
                detail = cursor.fetchall()
                for d in detail:
                    cav = d['cavities'] or 1
                    d['cycles_calc'] = d['cycles'] if d['cycles'] is not None else math.ceil(((d['qty'] or 0) + (d['scrap_pcs'] or 0)) / cav)
                    d['kg'] = (Decimal(d['cycles_calc']) * Decimal(d['shot_g']) / 1000 * (1 - Decimal(d['dosage_pct'] or 0) / 100)) if d['shot_g'] else None
        return render_template('consumption.html', inventories=inventories, a=a, b=b, rows=rows, inv_a=inv_a, inv_b=inv_b,
                               detail=detail, material=material)
