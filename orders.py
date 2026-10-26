"""Moduł ZAMÓWIENIA: klienci, produkty, kolory, zamówienia ZK i plan wtryskarek.

Logika według instrukcji „kodowanie Plastema K2”:
  1. nadanie kodu zamówienia  ZK AAA RR MM DD NNN  (AAA klient, RR MM DD data, NNN kolejne zamówienie klienta w roku),
  2. sprawdzenie pary klient–produkt w historii (stara / nowa para),
  3. sprawdzenie dostępności formy, surowca i barwnika (stany magazynu M1) oraz wtryskarek (plan obciążenia),
  4. ustalenie daty produkcji i daty dostawy, nadanie kodu produkcji AAA-BBBB-CCC i pełnego kodu AAA-BBBB-CCC-EEE-FFF-GGG,
  5. przy starcie produkcji — kod szarży N-Z-S-DDMMRR.
"""
import base64
import re
from datetime import date, datetime, time, timedelta
from decimal import Decimal
from io import BytesIO
from pathlib import Path
from urllib.parse import quote

from flask import abort, current_app, flash, redirect, render_template, request, url_for
from markupsafe import Markup
from psycopg.errors import ForeignKeyViolation, UniqueViolation

from inventory import CURRENT_STOCK_SQL
from machines import MACHINE_COUNT
from materials import auth, clean, require_csrf

LOCK_ID = 6102031
STATUSES = {
    'NOWE': 'nowe — do weryfikacji', 'PRZYJĘTE': 'przyjęte — zaplanowane', 'W PRODUKCJI': 'w produkcji',
    'ZREALIZOWANE': 'zrealizowane', 'ANULOWANE': 'anulowane',
}
CHANNELS = ['e-mail', 'telefon + potwierdzenie e-mail', 'formularz zamówieniowy (strona WWW)', 'platforma B2B / EDI', 'osobiście']
RECEIVERS = ['zamowienia@plastema.pl', 'Jakub Majchrzak', 'Ania Kwiatek', 'biuro handlowe Fiboo']
MOLD_STATUSES = ['SPRAWNA', 'W PRZEGLĄDZIE', 'W NAPRAWIE', 'POZA ZAKŁADEM', 'WYCOFANA']
ACTIVE = ('PRZYJĘTE', 'W PRODUKCJI')  # zamówienia zajmujące wtryskarki i formy
PLAN_DEFAULTS = {'plan_shifts': '3', 'plan_days': '5', 'plan_setup_h': '4', 'plan_delivery_days': '2',
                 'plan_lead_days': '7', 'plan_scrap_pct': '3'}
PLAN_LABELS = {'plan_shifts': 'Zmiany 8 h na dobę (1–3)', 'plan_days': 'Dni pracy w tygodniu (5–7)',
               'plan_setup_h': 'Przezbrojenie formy [h]', 'plan_delivery_days': 'Transport do klienta [dni robocze]',
               'plan_lead_days': 'Domyślny czas dostawy surowca [dni]', 'plan_scrap_pct': 'Naddatek na odpad / rozruch [%]'}
CLIENT_FIELDS = ['code', 'short_name', 'name', 'industry', 'contact_person', 'contact_position', 'phone', 'phone_central', 'email',
                 'website', 'street', 'postal_code', 'city', 'voivodeship', 'nip', 'regon', 'krs', 'iban', 'notes']
PRODUCT_TEXT = ['name', 'material_text', 'colorant_text', 'pattern_no', 'carton_type', 'machines', 'notes']
PRODUCT_NUM = ['net_g', 'gross_g', 'cavities', 'cycle_s', 'per_shift', 'pcs_per_carton', 'carton_kg', 'colorant_pct']


# --- pomocnicze -------------------------------------------------------------------------------

def to_num(value, label):
    value = clean(value).replace(' ', '').replace(',', '.')
    if not value:
        return None
    try:
        return Decimal(value)
    except Exception as error:
        raise ValueError(f'{label}: wpisz liczbę.') from error


def to_int(value, label, minimum=None):
    number = to_num(value, label)
    if number is None:
        return None
    if number != int(number) or (minimum is not None and number < minimum):
        raise ValueError(f'{label}: wpisz liczbę całkowitą{" ≥ " + str(minimum) if minimum is not None else ""}.')
    return int(number)


def to_date(value, label, required=False):
    value = clean(value)
    if not value:
        if required:
            raise ValueError(f'{label}: podaj datę.')
        return None
    try:
        return date.fromisoformat(value)
    except ValueError as error:
        raise ValueError(f'{label}: nieprawidłowa data.') from error


def digits(code):
    return re.sub(r'\D', '', code or '')


def index_number(material_index):
    """SS032 → '032' (FFF), BT021 → '021' (GGG); brak → '000'."""
    return f'{int(material_index[2:]):03d}' if material_index and material_index[2:].isdigit() else '000'


def barcode_uri(code, module_width=0.25, module_height=9):
    """Kod kreskowy Code 128 jako obraz SVG w data URI (CSP pozwala na img-src data:)."""
    value = digits(code)
    if not value:
        return ''
    try:
        from barcode import Code128
        from barcode.writer import SVGWriter
    except ImportError:
        return ''
    buffer = BytesIO()
    Code128(value, writer=SVGWriter()).write(buffer, {'module_width': module_width, 'module_height': module_height, 'quiet_zone': 2,
                                                       'write_text': False})
    return 'data:image/svg+xml;base64,' + base64.b64encode(buffer.getvalue()).decode()


def mailto(email, subject, body):
    return f'mailto:{quote(email or "")}?subject={quote(subject)}&body={quote(body)}'


def settings(cursor):
    cursor.execute("SELECT key, value FROM app_settings WHERE key LIKE 'plan_%'")
    values = dict(PLAN_DEFAULTS)
    values.update({r['key']: r['value'] for r in cursor.fetchall()})
    return {k: Decimal(v) for k, v in values.items()}


# --- kalendarz pracy wtryskarek ---------------------------------------------------------------

class Calendar:
    """Czas pracy: N zmian po 8 h od 6:00, wybrane dni tygodnia (5 = pn–pt, 6 = pn–sob, 7 = cały tydzień)."""

    def __init__(self, shifts, days):
        self.hours = max(1, min(3, int(shifts))) * 8
        self.days = max(5, min(7, int(days)))

    def workday(self, d):
        return d.weekday() < self.days

    def window(self, d):
        start = datetime.combine(d, time(6, 0))
        return start, start + timedelta(hours=self.hours)

    def shift_end(self, moment):
        """Koniec okna pracy zawierającego moment (przy 3 zmianach okno dnia sięga 6:00 dnia następnego) albo None."""
        for d in (moment.date() - timedelta(days=1), moment.date()):
            if self.workday(d):
                start, end = self.window(d)
                if start <= moment < end:
                    return end
        return None

    def normalize(self, moment):
        """Najbliższa chwila pracy ≥ moment."""
        if self.shift_end(moment):
            return moment
        d = moment.date()
        while True:
            start, _ = self.window(d)
            if self.workday(d) and start >= moment:
                return start
            d += timedelta(days=1)

    def add_hours(self, moment, hours):
        moment = self.normalize(moment)
        left = timedelta(hours=float(hours))
        while True:
            end = self.shift_end(moment)
            if moment + left <= end:
                return moment + left
            left -= end - moment
            moment = self.normalize(end)

    def add_workdays(self, d, days):
        while days > 0:
            d += timedelta(days=1)
            if self.workday(d):
                days -= 1
        return d


# --- weryfikacja zamówienia i plan ------------------------------------------------------------

def load_order(cursor, order_id):
    cursor.execute('''SELECT o.*, c.code AS client_code, c.short_name, c.name AS client_name, c.email AS client_email,
                             c.contact_person
                      FROM orders o JOIN clients c ON c.id = o.client_id WHERE o.id = %s''', (order_id,))
    order = cursor.fetchone()
    if order is None:
        abort(404)
    cursor.execute('''SELECT l.*, p.code AS product_code, p.name AS catalog_name, p.gross_g, p.net_g, p.cavities, p.cycle_s,
                             p.per_shift, p.machines AS product_machines, p.colorant_pct, p.orders_count, p.colorant_text,
                             p.material_text, p.mold_match,
                             col.code AS color_code, col.name AS color_name, mo.mold_no, mo.name AS mold_name, mo.status AS mold_status,
                             ma.material_index AS material_index, ma.internal_name AS material_name, ma.lead_time_days AS material_lead,
                             ma.supplier_short_name AS material_supplier,
                             cb.material_index AS colorant_index, cb.symbol AS colorant_symbol, cb.lead_time_days AS colorant_lead,
                             cb.supplier_short_name AS colorant_supplier
                      FROM order_lines l
                      LEFT JOIN products p ON p.id = l.product_id
                      LEFT JOIN colors col ON col.id = l.color_id
                      LEFT JOIN molds mo ON mo.id = l.mold_id
                      LEFT JOIN materials ma ON ma.id = l.material_id
                      LEFT JOIN materials cb ON cb.id = l.colorant_id
                      WHERE l.order_id = %s ORDER BY l.lp, l.id''', (order_id,))
    return order, cursor.fetchall()


def line_codes(order, line):
    if not line['product_code']:
        return None, None
    production = f'{order["client_code"]}-{line["product_code"]:04d}-{line["color_code"] or "000"}'
    full = f'{production}-{line["mold_no"] or "000"}-{index_number(line["material_index"])}-{index_number(line["colorant_index"])}'
    return production, full


def plan_order(cursor, order, lines):
    """Sprawdza zasoby dla każdej pozycji i proponuje wtryskarkę oraz terminy. Nic nie zapisuje."""
    cfg = settings(cursor)
    cal = Calendar(cfg['plan_shifts'], cfg['plan_days'])
    now = datetime.now().replace(second=0, microsecond=0)
    earliest_start = cal.normalize(datetime.combine(date.today() + timedelta(days=1), time(6, 0)))

    cursor.execute(f'SELECT material_id, current_kg FROM ({CURRENT_STOCK_SQL}) cs')
    stock = {r['material_id']: (r['current_kg'] or Decimal(0)) for r in cursor.fetchall()}
    # Rezerwacje: zamówienia przyjęte (surowiec jeszcze w magazynie głównym, ale już obiecany).
    cursor.execute('''SELECT l.material_id AS id, SUM(l.material_kg) AS kg FROM order_lines l JOIN orders o ON o.id = l.order_id
                      WHERE o.status = 'PRZYJĘTE' AND o.id <> %s AND l.material_id IS NOT NULL GROUP BY l.material_id
                      UNION ALL
                      SELECT l.colorant_id, SUM(l.colorant_kg) FROM order_lines l JOIN orders o ON o.id = l.order_id
                      WHERE o.status = 'PRZYJĘTE' AND o.id <> %s AND l.colorant_id IS NOT NULL GROUP BY l.colorant_id''',
                   (order['id'], order['id']))
    reserved = {}
    for r in cursor.fetchall():
        reserved[r['id']] = reserved.get(r['id'], Decimal(0)) + (r['kg'] or Decimal(0))
    # Zajętość wtryskarek i form przez inne aktywne zamówienia.
    cursor.execute('''SELECT l.machine_no, l.mold_id, l.planned_end FROM order_lines l JOIN orders o ON o.id = l.order_id
                      WHERE o.status = ANY(%s) AND o.id <> %s AND l.planned_end IS NOT NULL AND l.planned_end > %s''',
                   (list(ACTIVE), order['id'], now))
    machine_free, mold_free = {}, {}
    for r in cursor.fetchall():
        if r['machine_no']:
            machine_free[r['machine_no']] = max(machine_free.get(r['machine_no'], now), r['planned_end'])
        if r['mold_id']:
            mold_free[r['mold_id']] = max(mold_free.get(r['mold_id'], now), r['planned_end'])
    # Historia pary klient–produkt: wcześniejsze zamówienia (poza anulowanymi) albo produkcja w raporcie.
    product_ids = [l['product_id'] for l in lines if l['product_id']]
    history = set()
    if product_ids:
        cursor.execute('''SELECT DISTINCT l.product_id FROM order_lines l JOIN orders o ON o.id = l.order_id
                          WHERE l.product_id = ANY(%s) AND o.id <> %s AND o.status <> 'ANULOWANE' ''', (product_ids, order['id']))
        history = {r['product_id'] for r in cursor.fetchall()}

    scrap = 1 + cfg['plan_scrap_pct'] / 100
    used, mold_here = {}, set()
    results, ends = [], []
    for line in lines:
        checks = []
        res = {'line': line, 'checks': checks, 'machine': None, 'start': None, 'end': None, 'hours': None,
               'material_kg': None, 'colorant_kg': None, 'new_pair': None, 'level': 'ok'}

        def add(level, title, text):
            checks.append({'level': level, 'title': title, 'text': text})
            if level == 'error' or (level == 'warn' and res['level'] == 'ok'):
                res['level'] = level

        if not line['product_id']:
            add('error', 'Produkt', 'Pozycja nie jest powiązana z bazą produktów — dodaj produkt i wybierz go w pozycji.')
            results.append(res)
            continue
        qty = Decimal(line['qty'] or 0)
        if qty <= 0:
            add('error', 'Ilość', 'Wpisz zamawianą ilość sztuk.')
        # 1. stara / nowa para klient–produkt
        res['new_pair'] = not (line['product_id'] in history or (line['orders_count'] or 0) > 0)
        if res['new_pair']:
            add('warn', 'Para klient–produkt', 'NOWA para — produkt nie był jeszcze produkowany dla klienta. Sprawdź próby, karton i parametry.')
        else:
            add('ok', 'Para klient–produkt', 'Stara para — produkt był już produkowany dla tego klienta.')

        # 2. forma wtryskowa
        start_floor = earliest_start
        if not line['mold_id']:
            add('error', 'Forma', 'Brak przypisanej formy w karcie produktu — przypisz formę albo zleć wykonanie w narzędziowni.')
        elif line['mold_status'] != 'SPRAWNA':
            add('error', 'Forma', f'Forma {line["mold_no"]} ma status „{line["mold_status"]}” — przywróć zdolność produkcyjną (narzędziownia).')
        else:
            busy = mold_free.get(line['mold_id'])
            note = ' (przypisanie automatyczne — potwierdź w karcie produktu)' if line['mold_match'] == 'AUTO' else ''
            if busy and busy > start_floor:
                start_floor = busy
                if line['mold_id'] in mold_here:
                    add('ok', 'Forma', f'Forma {line["mold_no"]} — produkcja po wcześniejszej pozycji tego zamówienia, od {busy:%d.%m.%Y %H:%M}{note}.')
                else:
                    add('warn', 'Forma', f'Forma {line["mold_no"]} jest zajęta przez inne zamówienie do {busy:%d.%m.%Y %H:%M}{note}.')
            else:
                add('ok', 'Forma', f'Forma {line["mold_no"]} {line["mold_name"]} — sprawna i wolna{note}.')

        # 3. surowiec i barwnik (magazyn M1)
        weight = line['gross_g'] or line['net_g']
        if not weight:
            add('warn', 'Surowiec', 'Brak wagi detalu w karcie produktu — nie da się policzyć zapotrzebowania.')
        else:
            total_kg = qty * Decimal(weight) / 1000 * scrap
            pct = Decimal(line['colorant_pct'] or 0) if line['colorant_id'] else Decimal(0)
            res['colorant_kg'] = (total_kg * pct / 100).quantize(Decimal('0.001')) if line['colorant_id'] else None
            res['material_kg'] = (total_kg - (res['colorant_kg'] or 0)).quantize(Decimal('0.001'))
            for kind, mid, need, index, name, lead, supplier, text_hint in (
                    ('Surowiec', line['material_id'], res['material_kg'], line['material_index'], line['material_name'],
                     line['material_lead'], line['material_supplier'], line['material_text']),
                    ('Barwnik', line['colorant_id'], res['colorant_kg'], line['colorant_index'], line['colorant_symbol'],
                     line['colorant_lead'], line['colorant_supplier'], line['colorant_text'])):
                if not mid:
                    if kind == 'Barwnik' and not text_hint:
                        add('ok', kind, 'Produkt bez barwnika (GGG = 000).')
                    else:
                        add('warn', kind, f'„{text_hint or "—"}” nie jest powiązany z kartoteką magazynu — wybierz pozycję w karcie produktu.')
                    continue
                available = stock.get(mid, Decimal(0)) - reserved.get(mid, Decimal(0)) - used.get(mid, Decimal(0))
                used[mid] = used.get(mid, Decimal(0)) + need
                if available >= need:
                    add('ok', kind, f'{index} {name}: potrzeba {need:.1f} kg, dostępne {available:.1f} kg.')
                else:
                    days = int(lead or cfg['plan_lead_days'])
                    ready = cal.normalize(datetime.combine(date.today() + timedelta(days=days), time(6, 0)))
                    start_floor = max(start_floor, ready)
                    add('warn', kind, f'{index} {name}: potrzeba {need:.1f} kg, dostępne {max(available, 0):.1f} kg — brakuje '
                        f'{need - max(available, 0):.1f} kg. Uzupełnij magazyn ({supplier or "dostawca"}, ok. {days} dni) — '
                        f'start nie wcześniej niż {ready:%d.%m.%Y}.')

        # 4. wtryskarka
        rate = None
        if line['per_shift']:
            rate = Decimal(line['per_shift']) / 8
        elif line['cycle_s'] and line['cavities']:
            rate = Decimal(3600) / Decimal(line['cycle_s']) * Decimal(line['cavities'])
        if not rate or qty <= 0:
            add('warn', 'Wtryskarka', 'Brak czasu cyklu / wydajności w karcie produktu — nie da się zaplanować maszyny.')
        else:
            hours = (qty / rate + cfg['plan_setup_h']).quantize(Decimal('0.1'))
            history_machines = [int(m) for m in re.findall(r'\d+', line['product_machines'] or '') if 1 <= int(m) <= MACHINE_COUNT]
            candidates = history_machines or list(range(1, MACHINE_COUNT + 1))
            best = None
            for machine in candidates:
                start = cal.normalize(max(start_floor, machine_free.get(machine, now)))
                end = cal.add_hours(start, hours)
                if best is None or end < best[2]:
                    best = (machine, start, end)
            machine, start, end = best
            machine_free[machine] = end
            if line['mold_id']:
                mold_free[line['mold_id']] = end
                mold_here.add(line['mold_id'])
            res.update(machine=machine, start=start, end=end, hours=hours)
            ends.append(end)
            source = 'z historii produkcji' if history_machines else 'brak historii — sprawdzono wszystkie 9'
            add('ok', 'Wtryskarka', f'Maszyna {machine} ({source}): {start:%d.%m %H:%M} → {end:%d.%m %H:%M}, ok. {hours} h pracy.')
        results.append(res)

    delivery = cal.add_workdays(max(ends).date(), int(cfg['plan_delivery_days'])) if ends else None
    warnings = []
    if delivery and order['requested_date'] and delivery > order['requested_date']:
        warnings.append(f'Termin żądany przez klienta {order["requested_date"]:%d.%m.%Y} jest wcześniejszy niż możliwa dostawa '
                        f'{delivery:%d.%m.%Y}.')
    return {'lines': results, 'start': min((r['start'] for r in results if r['start']), default=None),
            'end': max(ends, default=None), 'delivery': delivery, 'warnings': warnings,
            'errors': sum(1 for r in results if r['level'] == 'error'),
            'warns': sum(1 for r in results if r['level'] == 'warn')}


def next_order_number(cursor, client_id, client_code, order_date):
    cursor.execute('SELECT COALESCE(MAX(seq), 0) + 1 AS n FROM orders WHERE client_id = %s AND EXTRACT(YEAR FROM order_date) = %s',
                   (client_id, order_date.year))
    seq = cursor.fetchone()['n']
    return seq, f'ZK {client_code} {order_date:%y %m %d} {seq:03d}'


# --- schemat bazy -----------------------------------------------------------------------------

def init_orders(db, source_dir):
    with db() as connection, connection.cursor() as cursor:
        cursor.execute('SELECT pg_advisory_xact_lock(%s)', (LOCK_ID,))
        cursor.execute('''CREATE TABLE IF NOT EXISTS clients (
            id BIGSERIAL PRIMARY KEY, code CHAR(3) NOT NULL UNIQUE CHECK (code ~ '^[0-9]{3}$'), short_name TEXT NOT NULL,
            name TEXT NOT NULL, industry TEXT, contact_person TEXT, contact_position TEXT, phone TEXT, phone_central TEXT,
            email TEXT, website TEXT, street TEXT, postal_code TEXT, city TEXT, voivodeship TEXT, nip TEXT, regon TEXT, krs TEXT,
            iban TEXT, since DATE, data_status TEXT, notes TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW())''')
        cursor.execute('''CREATE TABLE IF NOT EXISTS colors (
            id BIGSERIAL PRIMARY KEY, code CHAR(3) NOT NULL UNIQUE CHECK (code ~ '^[0-9]{3}$'), name TEXT NOT NULL UNIQUE, notes TEXT)''')
        cursor.execute('''CREATE TABLE IF NOT EXISTS molds (
            id BIGSERIAL PRIMARY KEY, mold_no CHAR(3) NOT NULL UNIQUE CHECK (mold_no ~ '^[0-9]{3}$'), ordinal INTEGER,
            name TEXT NOT NULL, dim_1 NUMERIC(10,1), dim_2 NUMERIC(10,1), dim_3 NUMERIC(10,1), weight_kg NUMERIC(10,1),
            storage TEXT, status TEXT NOT NULL DEFAULT 'SPRAWNA', notes TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW())''')
        cursor.execute('''CREATE TABLE IF NOT EXISTS products (
            id BIGSERIAL PRIMARY KEY, code INTEGER NOT NULL UNIQUE CHECK (code BETWEEN 1 AND 9999),
            client_id BIGINT NOT NULL REFERENCES clients(id) ON DELETE RESTRICT, name TEXT NOT NULL,
            material_text TEXT, colorant_text TEXT,
            material_id BIGINT REFERENCES materials(id) ON DELETE SET NULL, colorant_id BIGINT REFERENCES materials(id) ON DELETE SET NULL,
            colorant_pct NUMERIC(6,2), color_id BIGINT REFERENCES colors(id) ON DELETE SET NULL,
            mold_id BIGINT REFERENCES molds(id) ON DELETE SET NULL, mold_match TEXT,
            pattern_no TEXT, net_g NUMERIC(12,3), gross_g NUMERIC(12,3), cavities NUMERIC(6,0), cycle_s NUMERIC(10,2),
            per_shift NUMERIC(12,0), pcs_per_carton NUMERIC(12,0), carton_type TEXT, carton_kg NUMERIC(10,2), machines TEXT,
            orders_count INTEGER, produced_total NUMERIC(14,0), first_production DATE, last_production DATE, notes TEXT,
            created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            UNIQUE (client_id, name))''')
        cursor.execute('''CREATE TABLE IF NOT EXISTS orders (
            id BIGSERIAL PRIMARY KEY, number TEXT NOT NULL UNIQUE, client_id BIGINT NOT NULL REFERENCES clients(id) ON DELETE RESTRICT,
            seq INTEGER NOT NULL, order_date DATE NOT NULL, requested_date DATE, channel TEXT, received_by TEXT,
            ordered_by TEXT, ordered_email TEXT, client_ref TEXT, source_ref TEXT, internal_no TEXT,
            status TEXT NOT NULL DEFAULT 'NOWE', planned_start TIMESTAMP, planned_end TIMESTAMP, delivery_date DATE,
            notes TEXT, accepted_at TIMESTAMPTZ, started_at TIMESTAMPTZ, finished_at TIMESTAMPTZ,
            created_at TIMESTAMPTZ NOT NULL DEFAULT NOW())''')
        cursor.execute('''CREATE TABLE IF NOT EXISTS order_lines (
            id BIGSERIAL PRIMARY KEY, order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE, lp INTEGER NOT NULL DEFAULT 1,
            product_id BIGINT REFERENCES products(id) ON DELETE RESTRICT, product_name TEXT NOT NULL, qty INTEGER,
            color_id BIGINT REFERENCES colors(id) ON DELETE SET NULL, mold_id BIGINT REFERENCES molds(id) ON DELETE SET NULL,
            material_id BIGINT REFERENCES materials(id) ON DELETE SET NULL, colorant_id BIGINT REFERENCES materials(id) ON DELETE SET NULL,
            material_kg NUMERIC(14,3), colorant_kg NUMERIC(14,3), machine_no SMALLINT, planned_start TIMESTAMP, planned_end TIMESTAMP,
            is_new_pair BOOLEAN, production_code TEXT, full_code TEXT, batch_code TEXT, prod_start DATE, prod_end DATE, notes TEXT)''')
        cursor.execute('CREATE INDEX IF NOT EXISTS orders_client_idx ON orders(client_id, order_date)')
        cursor.execute('CREATE INDEX IF NOT EXISTS orders_status_idx ON orders(status)')
        cursor.execute('CREATE INDEX IF NOT EXISTS order_lines_order_idx ON order_lines(order_id)')
        cursor.execute('CREATE INDEX IF NOT EXISTS order_lines_product_idx ON order_lines(product_id)')
        cursor.execute('CREATE INDEX IF NOT EXISTS products_client_idx ON products(client_id)')
        for k, v in PLAN_DEFAULTS.items():
            cursor.execute('INSERT INTO app_settings (key, value) VALUES (%s,%s) ON CONFLICT DO NOTHING', (k, v))
        cursor.execute('SELECT COUNT(*) AS n FROM clients')
        if cursor.fetchone()['n'] == 0 and Path(source_dir).is_dir():
            from order_seed import seed_orders_module
            report = seed_orders_module(cursor, source_dir)
            print('Import modułu zamówień:', report, flush=True)
        cursor.execute("SELECT 1 FROM app_settings WHERE key = 'colors_v2'")
        if cursor.fetchone() is None:
            fix_product_colors(cursor)
            cursor.execute("INSERT INTO app_settings (key, value) VALUES ('colors_v2', '1')")
        cursor.execute("SELECT 1 FROM app_settings WHERE key = 'colors_v3'")
        if cursor.fetchone() is None:
            fix_product_colors(cursor, from_colorant=True)
            cursor.execute("INSERT INTO app_settings (key, value) VALUES ('colors_v3', '1')")


def fix_product_colors(cursor, from_colorant=False):
    """Jednorazowo: lepsze rozpoznanie koloru z nazwy (C./J., JASNO/CIEMNO, odmiany). Zmienia tylko produkty bez koloru
    albo z kolorem ogólniejszym (np. SZARY → JASNOSZARY), więc ręczne zmiany zostają."""
    from order_seed import color_of
    cursor.execute('SELECT id, code, name FROM colors')
    colors = {r['name']: r for r in cursor.fetchall()}
    natural = next((c for c in colors.values() if c['code'] == '000'), None)
    if natural:
        colors['NATURALNY'] = natural
    cursor.execute('''SELECT p.id, p.name, c.name AS color, b.color AS colorant_color FROM products p
                      LEFT JOIN colors c ON c.id = p.color_id LEFT JOIN materials b ON b.id = p.colorant_id''')
    changed = 0
    for p in cursor.fetchall():
        if from_colorant:  # produkty bez koloru w nazwie: kolor barwnika z kartoteki BT, np. '(F) RÓŻOWY'
            if p['color'] is not None or not p['colorant_color']:
                continue
            new = color_of(p['colorant_color'].replace('(F)', ' '))
        else:
            new = color_of(p['name'])
        if not new or new == p['color'] or not (p['color'] is None or new.endswith(p['color'])):
            continue
        if new not in colors:
            cursor.execute("SELECT LPAD((COALESCE(MAX(code::int), 0) + 1)::text, 3, '0') AS n FROM colors")
            cursor.execute('INSERT INTO colors (code, name) VALUES (%s, %s) RETURNING id, code, name', (cursor.fetchone()['n'], new))
            colors[new] = cursor.fetchone()
        cursor.execute('UPDATE products SET color_id = %s WHERE id = %s', (colors[new]['id'], p['id']))
        changed += 1
    print(f'Poprawiono kolory {changed} produktów{" (z barwnika)" if from_colorant else ""}.', flush=True)


# --- trasy ------------------------------------------------------------------------------------

def register_order_routes(app, db):
    app.jinja_env.globals.update(order_statuses=STATUSES, order_channels=CHANNELS, order_receivers=RECEIVERS,
                                 mold_statuses=MOLD_STATUSES, barcode_uri=barcode_uri)
    app.jinja_env.filters['dt'] = lambda v, f='%d.%m.%Y': v.strftime(f) if v else '—'
    app.jinja_env.filters['n0'] = lambda v: '—' if v is None else f'{v:,.0f}'.replace(',', ' ')

    def option_lists(cursor):
        cursor.execute('SELECT id, code, short_name FROM clients ORDER BY short_name')
        clients = cursor.fetchall()
        cursor.execute('SELECT id, code, name FROM colors ORDER BY code')
        colors = cursor.fetchall()
        cursor.execute("SELECT id, mold_no, name, status FROM molds ORDER BY mold_no")
        molds = cursor.fetchall()
        cursor.execute("""SELECT id, material_index, material_type, COALESCE(internal_name, symbol) AS name, symbol, color
                          FROM materials ORDER BY material_index""")
        materials = cursor.fetchall()
        return {'clients': clients, 'colors': colors, 'molds': molds,
                'ss': [m for m in materials if m['material_type'] == 'SUROWIEC SYPKI'],
                'bt': [m for m in materials if m['material_type'] == 'BARWNIK TWORZYWA']}

    # ---------------- zamówienia ----------------
    @app.get('/zamowienia')
    @auth
    def orders_index():
        status, client_id, query = request.args.get('status', ''), request.args.get('klient', ''), request.args.get('q', '').strip()
        date_from, date_to = request.args.get('od', ''), request.args.get('do', '')
        sql = '''SELECT o.*, c.short_name, c.code AS client_code, COUNT(l.id) AS lines, COALESCE(SUM(l.qty), 0) AS qty
                 FROM orders o JOIN clients c ON c.id = o.client_id LEFT JOIN order_lines l ON l.order_id = o.id WHERE TRUE'''
        params = []
        if status in STATUSES:
            sql += ' AND o.status = %s'; params.append(status)
        if client_id.isdigit():
            sql += ' AND o.client_id = %s'; params.append(int(client_id))
        if query:
            sql += ''' AND (o.number ILIKE %s OR REPLACE(o.number, ' ', '') ILIKE %s OR o.source_ref ILIKE %s OR o.client_ref ILIKE %s
                       OR EXISTS (SELECT 1 FROM order_lines x WHERE x.order_id = o.id AND (x.product_name ILIKE %s OR x.production_code ILIKE %s)))'''
            term = f'%{query}%'
            params += [term, f'%{digits(query) or query}%', term, term, term, term]
        try:
            if date_from:
                sql += ' AND o.order_date >= %s'; params.append(date.fromisoformat(date_from))
            if date_to:
                sql += ' AND o.order_date <= %s'; params.append(date.fromisoformat(date_to))
        except ValueError:
            abort(400)
        sql += ''' GROUP BY o.id, c.id ORDER BY CASE o.status WHEN 'NOWE' THEN 0 WHEN 'PRZYJĘTE' THEN 1 WHEN 'W PRODUKCJI' THEN 2 ELSE 3 END,
                   o.order_date DESC, o.id DESC LIMIT 600'''
        with db() as connection, connection.cursor() as cursor:
            cursor.execute(sql, params)
            orders = cursor.fetchall()
            cursor.execute('SELECT status, COUNT(*) AS n FROM orders GROUP BY status')
            counts = {r['status']: r['n'] for r in cursor.fetchall()}
            cursor.execute('SELECT id, short_name FROM clients ORDER BY short_name')
            clients = cursor.fetchall()
        return render_template('orders.html', orders=orders, counts=counts, clients=clients, status=status, client_id=client_id,
                               query=query, date_from=date_from, date_to=date_to)

    @app.route('/zamowienia/nowe', methods=['GET', 'POST'])
    @auth
    def order_new():
        with db() as connection, connection.cursor() as cursor:
            cursor.execute('SELECT id, code, short_name, name, contact_person, email FROM clients ORDER BY short_name')
            clients = cursor.fetchall()
            client_id = request.values.get('klient', '')
            client = next((c for c in clients if str(c['id']) == client_id), None)
            products, colors = [], []
            if client:
                cursor.execute('''SELECT p.id, p.code, p.name, p.color_id, col.name AS color_name FROM products p
                                  LEFT JOIN colors col ON col.id = p.color_id WHERE p.client_id = %s ORDER BY p.name''', (client['id'],))
                products = cursor.fetchall()
                cursor.execute('SELECT id, code, name FROM colors ORDER BY code')
                colors = cursor.fetchall()
            if request.method == 'POST' and client:
                require_csrf()
                form = request.form
                try:
                    order_date = to_date(form.get('order_date'), 'Data złożenia zamówienia', required=True)
                    requested = to_date(form.get('requested_date'), 'Żądany termin')
                    by_code = {str(p['code']): p for p in products}
                    lines = []
                    for i in range(1, 13):
                        text = clean(form.get(f'product_{i}'))
                        if not text:
                            continue
                        product = by_code.get(text.split()[0].lstrip('0') or '0') or by_code.get(text.split()[0])
                        if product is None:
                            raise ValueError(f'Pozycja {i}: nie znaleziono produktu „{text}” u klienta {client["short_name"]}. '
                                             'Wybierz go z podpowiedzi albo dodaj nowy produkt.')
                        qty = to_int(form.get(f'qty_{i}'), f'Pozycja {i} — ilość', minimum=1)
                        if not qty:
                            raise ValueError(f'Pozycja {i}: wpisz ilość sztuk.')
                        color = form.get(f'color_{i}', '')
                        lines.append((product, qty, int(color) if color.isdigit() else product['color_id'], clean(form.get(f'note_{i}'))))
                    if not lines:
                        raise ValueError('Dodaj co najmniej jedną pozycję zamówienia.')
                except ValueError as error:
                    flash(str(error), 'error')
                    return render_template('order_new.html', clients=clients, client=client, products=products, colors=colors,
                                           form=form, today=date.today())
                cursor.execute('SELECT pg_advisory_xact_lock(%s)', (LOCK_ID,))
                seq, number = next_order_number(cursor, client['id'], client['code'], order_date)
                cursor.execute('''INSERT INTO orders (number, client_id, seq, order_date, requested_date, channel, received_by, ordered_by,
                                    ordered_email, client_ref, notes) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) RETURNING id''',
                               (number, client['id'], seq, order_date, requested, clean(form.get('channel')), clean(form.get('received_by')),
                                clean(form.get('ordered_by')), clean(form.get('ordered_email')), clean(form.get('client_ref')),
                                form.get('notes', '').strip()))
                order_id = cursor.fetchone()['id']
                for lp, (product, qty, color_id, note) in enumerate(lines, start=1):
                    insert_line(cursor, order_id, lp, product['id'], qty, color_id, note)
                flash(f'Nadano kod zamówienia {number}. Sprawdź weryfikację zasobów i przyjmij zamówienie do realizacji.', 'success')
                return redirect(url_for('order_detail', order_id=order_id))
        return render_template('order_new.html', clients=clients, client=client, products=products, colors=colors,
                               form={'ordered_by': client['contact_person'] if client else '', 'ordered_email': client['email'] if client else ''},
                               today=date.today())

    def insert_line(cursor, order_id, lp, product_id, qty, color_id, note=''):
        cursor.execute('SELECT name, mold_id, material_id, colorant_id, color_id FROM products WHERE id = %s', (product_id,))
        p = cursor.fetchone()
        cursor.execute('''INSERT INTO order_lines (order_id, lp, product_id, product_name, qty, color_id, mold_id, material_id, colorant_id, notes)
                          VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)''',
                       (order_id, lp, product_id, p['name'], qty, color_id or p['color_id'], p['mold_id'], p['material_id'],
                        p['colorant_id'], note))

    def refresh_lines_from_products(cursor, order_id):
        """Zamówienie NOWE zawsze bierze aktualną formę / tworzywo / barwnik z karty produktu."""
        cursor.execute('''UPDATE order_lines l SET mold_id = p.mold_id, material_id = p.material_id, colorant_id = p.colorant_id,
                          product_name = p.name FROM products p WHERE p.id = l.product_id AND l.order_id = %s''', (order_id,))

    @app.get('/zamowienia/<int:order_id>')
    @auth
    def order_detail(order_id):
        with db() as connection, connection.cursor() as cursor:
            cursor.execute('SELECT status FROM orders WHERE id = %s', (order_id,))
            row = cursor.fetchone()
            if row is None:
                abort(404)
            if row['status'] == 'NOWE':
                refresh_lines_from_products(cursor, order_id)
            order, lines = load_order(cursor, order_id)
            plan = plan_order(cursor, order, lines) if order['status'] == 'NOWE' else None
            products = []
            if order['status'] == 'NOWE':
                cursor.execute('SELECT id, code, name FROM products WHERE client_id = %s ORDER BY name', (order['client_id'],))
                products = cursor.fetchall()
            cursor.execute('SELECT id, code, name FROM colors ORDER BY code')
            colors = cursor.fetchall()
            cursor.execute('''SELECT po.id, po.number, po.product_name, po.machine_no, po.status, po.batch_code, po.qty_total,
                                     (SELECT COUNT(*) FROM prod_colors x WHERE x.prod_order_id = po.id AND x.status = 'ROZLICZONY') AS settled,
                                     (SELECT COUNT(*) FROM prod_colors x WHERE x.prod_order_id = po.id AND x.status <> 'X') AS colors
                              FROM prod_orders po WHERE po.zk_order_id = %s ORDER BY po.seq''', (order_id,))
            prod_orders = cursor.fetchall()
            cursor.execute('''SELECT d.id, d.number, d.doc_type, d.doc_date, d.status, d.carrier,
                                     (SELECT COALESCE(SUM(l.qty), 0) FROM fg_doc_lines l WHERE l.doc_id = d.id) AS qty
                              FROM fg_docs d WHERE d.zk_order_id = %s ORDER BY d.doc_date, d.id''', (order_id,))
            fg_docs = cursor.fetchall()
            cursor.execute('''SELECT order_line_id, -SUM(qty) AS qty FROM fg_moves WHERE order_line_id = ANY(%s) GROUP BY order_line_id''',
                           ([l['id'] for l in lines],))
            shipped = {r['order_line_id']: int(r['qty']) for r in cursor.fetchall()}
            cursor.execute('SELECT product_id, SUM(qty) AS qty FROM fg_moves WHERE product_id = ANY(%s) GROUP BY product_id',
                           ([l['product_id'] for l in lines if l['product_id']],))
            fg_stock = {r['product_id']: int(r['qty']) for r in cursor.fetchall()}
            # Wyprodukowano: statystyka (Excel: ten sam nr zam. prod. i produkt; zamówienie bez numeru — produkcja bez numeru)
            # albo kolor rozliczony w module rozliczenia, powiązany z pozycją ZK
            cursor.execute('''SELECT l.id AS line_id, SUM(p.qty) AS qty,
                                     string_agg(DISTINCT p.batch_code, ', ' ORDER BY p.batch_code) AS batches,
                                     string_agg(DISTINCT p.machine_no, ', ' ORDER BY p.machine_no) AS machines,
                                     MIN(p.start_date) AS start_date, MAX(p.end_date) AS end_date
                              FROM order_lines l JOIN orders o ON o.id = l.order_id
                              JOIN productions p ON (p.source = 'EXCEL' AND o.source_ref IS NOT NULL AND p.product_id = l.product_id
                                                     AND COALESCE(p.internal_order, '') = COALESCE(o.internal_no, ''))
                                                 OR EXISTS (SELECT 1 FROM prod_colors pc WHERE pc.id = p.prod_color_id AND pc.zk_line_id = l.id)
                              WHERE l.order_id = %s GROUP BY l.id''', (order_id,))
            produced = {r['line_id']: r for r in cursor.fetchall()}
        with db() as connection, connection.cursor() as cursor:
            cursor.execute('''SELECT l.id AS line_id, p.* FROM order_lines l JOIN orders o ON o.id = l.order_id
                              JOIN productions p ON (p.source = 'EXCEL' AND o.source_ref IS NOT NULL AND p.product_id = l.product_id
                                                     AND COALESCE(p.internal_order, '') = COALESCE(o.internal_no, ''))
                                                 OR EXISTS (SELECT 1 FROM prod_colors pc WHERE pc.id = p.prod_color_id AND pc.zk_line_id = l.id)
                              WHERE l.order_id = %s ORDER BY p.start_date, p.id''', (order_id,))
            prod_rows = {}
            for pr in cursor.fetchall():
                prod_rows.setdefault(pr['line_id'], []).append(pr)
        with db() as connection, connection.cursor() as cursor:
            cursor.execute('''SELECT pc.zk_line_id AS line_id, po.id, po.number, po.status, po.issued_by, po.accepted_by, po.order_date, po.machine_no
                              FROM prod_colors pc JOIN prod_orders po ON po.id = pc.prod_order_id WHERE pc.zk_line_id = ANY(%s) ORDER BY po.seq''',
                           ([l['id'] for l in lines],))
            zp_by_line = {}
            for z in cursor.fetchall():
                zp_by_line.setdefault(z['line_id'], z)
        # Historia ruchów w magazynie wyrobów dla szarży każdej pozycji (PW, WZ, ZW, KOR) z saldem narastającym
        cursor_rows = []
        with db() as connection, connection.cursor() as cursor:
            cursor.execute('''SELECT m.product_id, COALESCE(m.batch_code, '') AS batch, m.move_date, m.move_type, m.qty, m.location, m.doc_id,
                                     d.number AS doc_number, d.doc_type, o.number AS zk_number
                              FROM fg_moves m LEFT JOIN fg_docs d ON d.id = m.doc_id LEFT JOIN orders o ON o.id = d.zk_order_id
                              WHERE m.product_id = ANY(%s) ORDER BY m.move_date, m.id''', ([l['product_id'] for l in lines if l['product_id']],))
            cursor_rows = cursor.fetchall()
        moves_by_batch = {}
        for m in cursor_rows:
            moves_by_batch.setdefault((m['product_id'], m['batch']), []).append(m)
        # Zamówienie historyczne zrealizowane przed uruchomieniem magazynu wyrobów: wydane w całości, bez dokumentu WZ
        legacy_shipped = bool(order['source_ref']) and order['status'] == 'ZREALIZOWANE' and not fg_docs
        rows = []
        for i, line in enumerate(lines):
            production, full = line_codes(order, line)
            rows.append({'line': line, 'production_code': line['production_code'] or production, 'full_code': line['full_code'] or full,
                         'plan': plan['lines'][i] if plan else None,
                         'shipped': (line['qty'] or 0) if legacy_shipped else shipped.get(line['id'], 0),
                         'produced': produced.get(line['id']), 'fg_stock': fg_stock.get(line['product_id'], 0)})
            produced_batches = (produced.get(line['id']) or {}).get('batches') or ''
            batch = line['batch_code'] or (produced_batches if produced_batches and ',' not in produced_batches else '')
            history, balance = [], 0
            for m in moves_by_batch.get((line['product_id'], batch), []):
                balance += int(m['qty'])
                history.append({**m, 'balance': balance})
            rows[-1]['prod_rows'] = prod_rows.get(line['id'], [])
            rows[-1]['zp'] = zp_by_line.get(line['id'])
            rows[-1]['history'] = history
            rows[-1]['history_batch'] = batch
        delivery = plan['delivery'] if plan else order['delivery_date']
        contact = order['ordered_email'] or order['client_email']
        items = '\n'.join(f'  {r["line"]["lp"]}. {r["line"]["product_name"]} — {r["line"]["qty"] or 0} szt.' for r in rows)
        mails = {
            'received': mailto(contact, f'Potwierdzenie odebrania zamówienia {order["number"]}',
                               f'Dzień dobry,\n\npotwierdzamy odebranie zamówienia w skrzynce zamowienia@plastema.pl.\n'
                               f'Nadany numer zamówienia: {order["number"]}'
                               f'{" (Państwa nr: " + order["client_ref"] + ")" if order["client_ref"] else ""}\n\nPozycje:\n{items}\n\n'
                               'Termin dostawy potwierdzimy po sprawdzeniu zdolności produkcyjnych.\n\nPozdrawiamy,\nPLASTEMA'),
            'delivery': mailto(contact, f'Termin dostawy — zamówienie {order["number"]}',
                               f'Dzień dobry,\n\nzamówienie {order["number"]} zostało zaplanowane do produkcji.\n'
                               f'Przewidywana data dostawy: {delivery:%d.%m.%Y}.\n\nPozycje:\n{items}\n\nPozdrawiamy,\nPLASTEMA') if delivery else None,
        }
        return render_template('order_detail.html', order=order, rows=rows, plan=plan, products=products, colors=colors, prod_orders=prod_orders,
                               fg_docs=fg_docs, legacy_shipped=legacy_shipped,
                               mails=mails, delivery=delivery, today=date.today())

    @app.get('/zamowienia/<int:order_id>/wydruk')
    @auth
    def order_print(order_id):
        with db() as connection, connection.cursor() as cursor:
            cursor.execute('SELECT 1 FROM orders WHERE id = %s', (order_id,))
            if cursor.fetchone() is None:
                abort(404)
            order, lines = load_order(cursor, order_id)
        rows = []
        for line in lines:
            production, full = line_codes(order, line)
            rows.append({'line': line, 'production_code': line['production_code'] or production, 'full_code': line['full_code'] or full})
        return render_template('order_print.html', order=order, rows=rows, today=date.today())

    @app.get('/zamowienia/<int:order_id>/dokument')
    @auth
    def order_document(order_id):
        with db() as connection, connection.cursor() as cursor:
            cursor.execute('SELECT 1 FROM orders WHERE id = %s', (order_id,))
            if cursor.fetchone() is None:
                abort(404)
            order, lines = load_order(cursor, order_id)
        total = sum(l['qty'] or 0 for l in lines)
        return render_template('order_document.html', order=order, lines=lines, total=total, today=date.today())

    @app.post('/zamowienia/<int:order_id>')
    @auth
    def order_action(order_id):
        require_csrf()
        form, action = request.form, request.form.get('action', '')
        with db() as connection, connection.cursor() as cursor:
            cursor.execute('SELECT pg_advisory_xact_lock(%s)', (LOCK_ID,))
            cursor.execute('SELECT * FROM orders WHERE id = %s FOR UPDATE', (order_id,))
            order = cursor.fetchone()
            if order is None:
                abort(404)
            status = order['status']
            back = redirect(url_for('order_detail', order_id=order_id))
            try:
                if action in ('save', 'add_line', 'accept') or action.startswith('delete_line'):
                    if status != 'NOWE':
                        raise ValueError('Zmieniać można tylko zamówienie o statusie NOWE.')
                    save_header(cursor, order, form)
                    if action == 'add_line':
                        add_line(cursor, order, form)
                    elif action.startswith('delete_line'):
                        cursor.execute('DELETE FROM order_lines WHERE id = %s AND order_id = %s', (int(action.split(':')[1]), order_id))
                        flash('Usunięto pozycję zamówienia.', 'success')
                    elif action == 'accept':
                        accept(cursor, order_id)
                        return back
                    if action == 'save':
                        flash('Zamówienie zapisane.', 'success')
                elif action == 'unaccept' and status == 'PRZYJĘTE':
                    cursor.execute('''SELECT COUNT(*) AS n FROM prod_shifts s JOIN prod_colors pc ON pc.id = s.prod_color_id
                                      JOIN prod_orders po ON po.id = pc.prod_order_id WHERE po.zk_order_id = %s''', (order_id,))
                    if cursor.fetchone()['n']:
                        raise ValueError('Zamówienia produkcji tego zamówienia mają już wpisaną produkcję — nie można cofnąć przyjęcia.')
                    cursor.execute('DELETE FROM prod_orders WHERE zk_order_id = %s', (order_id,))
                    cursor.execute('''UPDATE order_lines SET machine_no = NULL, planned_start = NULL, planned_end = NULL, material_kg = NULL,
                                      colorant_kg = NULL, production_code = NULL, full_code = NULL WHERE order_id = %s''', (order_id,))
                    cursor.execute("UPDATE orders SET status = 'NOWE', accepted_at = NULL, planned_start = NULL, planned_end = NULL, "
                                   "delivery_date = NULL WHERE id = %s", (order_id,))
                    flash('Cofnięto przyjęcie — rezerwacje surowców i terminy maszyn zostały zwolnione.', 'success')
                elif action == 'start' and status == 'PRZYJĘTE':
                    start_production(cursor, order_id, form)
                elif action == 'finish' and status == 'W PRODUKCJI':
                    cursor.execute("UPDATE orders SET status = 'ZREALIZOWANE', finished_at = NOW() WHERE id = %s", (order_id,))
                    cursor.execute('UPDATE order_lines SET prod_end = CURRENT_DATE WHERE order_id = %s AND prod_end IS NULL', (order_id,))
                    flash(f'Zamówienie {order["number"]} zrealizowane.', 'success')
                elif action == 'cancel' and status in ('NOWE', 'PRZYJĘTE', 'W PRODUKCJI'):
                    cursor.execute("UPDATE orders SET status = 'ANULOWANE' WHERE id = %s", (order_id,))
                    flash(f'Zamówienie {order["number"]} anulowane — zwolniono rezerwacje i terminy.', 'success')
                elif action == 'delete' and status == 'NOWE':
                    cursor.execute('DELETE FROM orders WHERE id = %s', (order_id,))
                    flash(f'Usunięto zamówienie {order["number"]}.', 'success')
                    return redirect(url_for('orders_index'))
                else:
                    raise ValueError('Tej operacji nie można wykonać przy obecnym statusie zamówienia.')
            except ValueError as error:
                connection.rollback()
                flash(str(error), 'error')
        return back

    def save_header(cursor, order, form):
        requested = to_date(form.get('requested_date'), 'Żądany termin')
        cursor.execute('''UPDATE orders SET requested_date = %s, channel = %s, received_by = %s, ordered_by = %s, ordered_email = %s,
                          client_ref = %s, notes = %s WHERE id = %s''',
                       (requested, clean(form.get('channel')), clean(form.get('received_by')), clean(form.get('ordered_by')),
                        clean(form.get('ordered_email')), clean(form.get('client_ref')), form.get('notes', '').strip(), order['id']))
        cursor.execute('SELECT id FROM order_lines WHERE order_id = %s', (order['id'],))
        for line in cursor.fetchall():
            key = str(line['id'])
            if f'qty_{key}' in form:
                qty = to_int(form.get(f'qty_{key}'), 'Ilość', minimum=0)
                color = form.get(f'color_{key}', '')
                cursor.execute('UPDATE order_lines SET qty = %s, color_id = %s, notes = %s WHERE id = %s',
                               (qty, int(color) if color.isdigit() else None, clean(form.get(f'note_{key}')), line['id']))

    def add_line(cursor, order, form):
        text = clean(form.get('add_product'))
        if not text:
            raise ValueError('Wybierz produkt z podpowiedzi.')
        cursor.execute('SELECT id, name FROM products WHERE client_id = %s AND code = %s',
                       (order['client_id'], int(text.split()[0]) if text.split()[0].isdigit() else -1))
        product = cursor.fetchone()
        if product is None:
            raise ValueError(f'Nie znaleziono produktu „{text}” u tego klienta.')
        qty = to_int(form.get('add_qty'), 'Ilość', minimum=1)
        if not qty:
            raise ValueError('Wpisz ilość sztuk nowej pozycji.')
        cursor.execute('SELECT COALESCE(MAX(lp), 0) + 1 AS lp FROM order_lines WHERE order_id = %s', (order['id'],))
        insert_line(cursor, order['id'], cursor.fetchone()['lp'], product['id'], qty, None)
        flash(f'Dodano pozycję: {product["name"]}.', 'success')

    def accept(cursor, order_id):
        refresh_lines_from_products(cursor, order_id)
        order, lines = load_order(cursor, order_id)
        if not lines:
            raise ValueError('Zamówienie nie ma pozycji.')
        plan = plan_order(cursor, order, lines)
        blocking = [f'poz. {r["line"]["lp"]}: ' + '; '.join(c['text'] for c in r['checks'] if c['level'] == 'error')
                    for r in plan['lines'] if r['level'] == 'error']
        if blocking:
            raise ValueError('Nie można przyjąć zamówienia — ' + ' | '.join(blocking))
        for res in plan['lines']:
            line = res['line']
            production, full = line_codes(order, line)
            cursor.execute('''UPDATE order_lines SET machine_no = %s, planned_start = %s, planned_end = %s, material_kg = %s, colorant_kg = %s,
                              is_new_pair = %s, production_code = %s, full_code = %s WHERE id = %s''',
                           (res['machine'], res['start'], res['end'], res['material_kg'], res['colorant_kg'], res['new_pair'],
                            production, full, line['id']))
        cursor.execute('''UPDATE orders SET status = 'PRZYJĘTE', accepted_at = NOW(), planned_start = %s, planned_end = %s, delivery_date = %s
                          WHERE id = %s''', (plan['start'], plan['end'], plan['delivery'], order_id))
        # Nadanie kodu produkcji = wystawienie zamówień produkcji na realizację produkcji (dok. 2)
        issue = current_app.extensions.get('issue_internal_orders')
        internal = []
        if issue:
            cursor.execute('SELECT * FROM orders WHERE id = %s', (order_id,))
            ids = issue(cursor, cursor.fetchone())
            cursor.execute('SELECT number FROM prod_orders WHERE id = ANY(%s) ORDER BY seq', (ids,))
            internal = [r['number'] for r in cursor.fetchall()]
        flash(f'Zamówienie {order["number"]} przyjęte do realizacji. Nadano kody produkcji'
              f'{", wystawiono zamówienia produkcji: " + ", ".join(internal) if internal else ""}. Zarezerwowano surowce i terminy maszyn'
              f'{", dostawa " + plan["delivery"].strftime("%d.%m.%Y") if plan["delivery"] else ""}. '
              'Wyślij klientowi informację o terminie dostawy.', 'success')

    def start_production(cursor, order_id, form):
        shift = form.get('shift', '1')
        if shift not in ('1', '2', '3'):
            raise ValueError('Wybierz zmianę 1, 2 lub 3.')
        day = to_date(form.get('start_date'), 'Data startu', required=True)
        cursor.execute('SELECT id, machine_no FROM order_lines WHERE order_id = %s ORDER BY lp, id', (order_id,))
        for line in cursor.fetchall():
            if not line['machine_no']:
                continue
            prefix = f'{line["machine_no"]}-{shift}-'
            suffix = f'-{day:%d%m%y}'
            cursor.execute('SELECT COUNT(*) AS n FROM order_lines WHERE batch_code LIKE %s', (prefix + '%' + suffix,))
            batch = f'{prefix}{cursor.fetchone()["n"] + 1}{suffix}'
            cursor.execute('UPDATE order_lines SET batch_code = %s, prod_start = %s WHERE id = %s', (batch, day, line['id']))
        cursor.execute("UPDATE orders SET status = 'W PRODUKCJI', started_at = NOW() WHERE id = %s", (order_id,))
        flash('Produkcja rozpoczęta — nadano kody szarży. Magazynier wydaje surowiec dokumentem WM na wskazaną maszynę.', 'success')

    # ---------------- plan wtryskarek ----------------
    @app.route('/plan-maszyn', methods=['GET', 'POST'])
    @auth
    def machine_plan():
        with db() as connection, connection.cursor() as cursor:
            if request.method == 'POST':
                require_csrf()
                try:
                    for k in PLAN_DEFAULTS:
                        value = to_num(request.form.get(k), PLAN_LABELS[k])
                        if value is None or value < 0:
                            raise ValueError(f'{PLAN_LABELS[k]}: wpisz liczbę ≥ 0.')
                        cursor.execute('INSERT INTO app_settings (key, value) VALUES (%s,%s) ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value',
                                       (k, str(value)))
                    flash('Zapisano parametry planowania.', 'success')
                except ValueError as error:
                    connection.rollback()
                    flash(str(error), 'error')
                return redirect(url_for('machine_plan'))
            cfg = settings(cursor)
            horizon = int(request.args.get('dni', '28') or 28)
            horizon = max(7, min(horizon, 120))
            start = datetime.combine(date.today(), time(0, 0))
            end = start + timedelta(days=horizon)
            cursor.execute('''SELECT l.*, o.number, o.id AS order_id, o.status, c.short_name, mo.mold_no FROM order_lines l
                              JOIN orders o ON o.id = l.order_id JOIN clients c ON c.id = o.client_id LEFT JOIN molds mo ON mo.id = l.mold_id
                              WHERE o.status = ANY(%s) AND l.planned_end > %s ORDER BY l.machine_no, l.planned_start''', (list(ACTIVE), start))
            jobs = cursor.fetchall()
        span = (end - start).total_seconds()
        machines = []
        for m in range(1, MACHINE_COUNT + 1):
            items = []
            for j in (j for j in jobs if j['machine_no'] == m):
                left = max(0, (j['planned_start'] - start).total_seconds()) / span * 100
                right = min(span, (j['planned_end'] - start).total_seconds()) / span * 100
                items.append({'job': j, 'left': round(left, 2), 'width': round(max(right - left, 0.6), 2)})
            busy_until = max((j['planned_end'] for j in jobs if j['machine_no'] == m), default=None)
            machines.append({'no': m, 'items': items, 'busy_until': busy_until})
        ticks = [{'label': (start + timedelta(days=d)).strftime('%d.%m'), 'left': round(d / horizon * 100, 2),
                  'weekend': (start + timedelta(days=d)).weekday() >= 5} for d in range(0, horizon, 1 if horizon <= 31 else 7)]
        return render_template('plan.html', machines=machines, ticks=ticks, jobs=jobs, cfg=cfg, labels=PLAN_LABELS, horizon=horizon)

    # ---------------- klienci ----------------
    @app.get('/klienci')
    @auth
    def clients_index():
        query = request.args.get('q', '').strip()
        sql = '''SELECT c.*, (SELECT COUNT(*) FROM orders o WHERE o.client_id = c.id) AS orders,
                        (SELECT COUNT(*) FROM products p WHERE p.client_id = c.id) AS products
                 FROM clients c WHERE TRUE'''
        params = []
        if query:
            sql += ' AND (c.name ILIKE %s OR c.short_name ILIKE %s OR c.code = %s OR c.city ILIKE %s OR c.nip ILIKE %s OR c.contact_person ILIKE %s)'
            term = f'%{query}%'
            params = [term, term, query, term, term, term]
        sql += ' ORDER BY c.code'
        with db() as connection, connection.cursor() as cursor:
            cursor.execute(sql, params)
            clients = cursor.fetchall()
        return render_template('clients.html', clients=clients, query=query)

    def client_values(form):
        values = {f: clean(form.get(f)) for f in CLIENT_FIELDS}
        values['notes'] = form.get('notes', '').strip()
        if not re.fullmatch(r'\d{3}', values['code']):
            raise ValueError('Kod klienta (AAA) musi mieć dokładnie 3 cyfry, np. 027.')
        if not values['name'] or not values['short_name']:
            raise ValueError('Podaj pełną i skróconą nazwę klienta.')
        values['short_name'] = values['short_name'].upper()
        values['since'] = to_date(form.get('since'), 'Data rozpoczęcia współpracy')
        return values

    @app.route('/klienci/nowy', methods=['GET', 'POST'])
    @app.route('/klienci/<int:client_id>', methods=['GET', 'POST'])
    @auth
    def client_form(client_id=None):
        with db() as connection, connection.cursor() as cursor:
            client = {}
            if client_id:
                cursor.execute('SELECT * FROM clients WHERE id = %s', (client_id,))
                client = cursor.fetchone() or abort(404)
            else:
                cursor.execute("SELECT LPAD((COALESCE(MAX(code::int), -1) + 1)::text, 3, '0') AS code FROM clients")
                client = {'code': cursor.fetchone()['code']}
            if request.method == 'POST':
                require_csrf()
                try:
                    values = client_values(request.form)
                    fields = CLIENT_FIELDS + ['since']
                    if client_id:
                        cursor.execute(f'UPDATE clients SET {", ".join(f + " = %s" for f in fields)}, updated_at = NOW() WHERE id = %s',
                                       [values[f] for f in fields] + [client_id])
                        flash('Dane klienta zapisane.', 'success')
                    else:
                        cursor.execute(f'INSERT INTO clients ({", ".join(fields)}) VALUES ({", ".join("%s" for _ in fields)}) RETURNING id',
                                       [values[f] for f in fields])
                        client_id = cursor.fetchone()['id']
                        flash(f'Dodano klienta {values["short_name"]} z kodem {values["code"]}.', 'success')
                    return redirect(url_for('client_form', client_id=client_id))
                except ValueError as error:
                    flash(str(error), 'error'); client = request.form
                except UniqueViolation:
                    connection.rollback(); flash('Kod klienta jest już zajęty — wybierz inny.', 'error'); client = request.form
            orders, products = [], []
            if client_id:
                cursor.execute('''SELECT o.id, o.number, o.order_date, o.status, o.delivery_date, COUNT(l.id) AS lines, COALESCE(SUM(l.qty),0) AS qty
                                  FROM orders o LEFT JOIN order_lines l ON l.order_id = o.id WHERE o.client_id = %s
                                  GROUP BY o.id ORDER BY o.order_date DESC LIMIT 30''', (client_id,))
                orders = cursor.fetchall()
                cursor.execute('SELECT COUNT(*) AS n FROM products WHERE client_id = %s', (client_id,))
                products = cursor.fetchone()['n']
        return render_template('client_form.html', client=client, client_id=client_id, orders=orders, products=products)

    @app.post('/klienci/<int:client_id>/usun')
    @auth
    def client_delete(client_id):
        require_csrf()
        try:
            with db() as connection, connection.cursor() as cursor:
                cursor.execute('DELETE FROM clients WHERE id = %s RETURNING short_name', (client_id,))
                row = cursor.fetchone()
            flash(f'Usunięto klienta {row["short_name"]}.' if row else 'Nie znaleziono klienta.', 'success')
            return redirect(url_for('clients_index'))
        except ForeignKeyViolation:
            flash('Klient ma produkty lub zamówienia — nie można go usunąć.', 'error')
            return redirect(url_for('client_form', client_id=client_id))

    # ---------------- produkty ----------------
    @app.get('/produkty')
    @auth
    def products_index():
        query, client_id, missing = request.args.get('q', '').strip(), request.args.get('klient', ''), request.args.get('brak', '')
        sql = '''SELECT p.*, c.short_name, c.code AS client_code, col.code AS color_code, col.name AS color_name, mo.mold_no,
                        ma.material_index, cb.material_index AS colorant_index
                 FROM products p JOIN clients c ON c.id = p.client_id LEFT JOIN colors col ON col.id = p.color_id
                 LEFT JOIN molds mo ON mo.id = p.mold_id LEFT JOIN materials ma ON ma.id = p.material_id
                 LEFT JOIN materials cb ON cb.id = p.colorant_id WHERE TRUE'''
        params = []
        if query:
            sql += ' AND (p.name ILIKE %s OR p.material_text ILIKE %s OR p.colorant_text ILIKE %s OR LPAD(p.code::text, 4, \'0\') = %s)'
            term = f'%{query}%'
            params += [term, term, term, query.zfill(4) if query.isdigit() else query]
        if client_id.isdigit():
            sql += ' AND p.client_id = %s'; params.append(int(client_id))
        missing_sql = {'forma': 'p.mold_id IS NULL', 'auto': "p.mold_match = 'AUTO'", 'tworzywo': 'p.material_id IS NULL',
                       'barwnik': "p.colorant_id IS NULL AND COALESCE(p.colorant_text, '') <> ''", 'kolor': 'p.color_id IS NULL'}
        if missing in missing_sql:
            sql += ' AND ' + missing_sql[missing]
        sql += ' ORDER BY c.short_name, p.name LIMIT 800'
        with db() as connection, connection.cursor() as cursor:
            cursor.execute(sql, params)
            products = cursor.fetchall()
            cursor.execute('SELECT id, short_name FROM clients ORDER BY short_name')
            clients = cursor.fetchall()
            cursor.execute(f'''SELECT COUNT(*) AS total, {", ".join(f"COUNT(*) FILTER (WHERE {v}) AS {k}" for k, v in missing_sql.items())}
                               FROM products p''')
            counts = cursor.fetchone()
        return render_template('products.html', products=products, clients=clients, query=query, client_id=client_id,
                               missing=missing, counts=counts)

    def product_values(cursor, form):
        values = {f: clean(form.get(f)) for f in PRODUCT_TEXT}
        values['notes'] = form.get('notes', '').strip()
        if not values['name']:
            raise ValueError('Podaj nazwę produktu.')
        for f in PRODUCT_NUM:
            values[f] = to_num(form.get(f), f)
        for f in ('client_id', 'color_id', 'mold_id', 'material_id', 'colorant_id'):
            v = form.get(f, '')
            values[f] = int(v) if v.isdigit() else None
        if not values['client_id']:
            raise ValueError('Wybierz klienta.')
        code = to_int(form.get('code'), 'Kod produktu (BBBB)', minimum=1)
        if not code or code > 9999:
            raise ValueError('Kod produktu (BBBB) musi być liczbą 1–9999.')
        values['code'] = code
        values['mold_match'] = None if not values['mold_id'] else ('AUTO' if form.get('mold_auto') == '1' and not form.get('mold_confirm') else 'POTWIERDZONA')
        return values

    @app.route('/produkty/nowy', methods=['GET', 'POST'])
    @app.route('/produkty/<int:product_id>', methods=['GET', 'POST'])
    @auth
    def product_form(product_id=None):
        with db() as connection, connection.cursor() as cursor:
            if product_id:
                cursor.execute('SELECT * FROM products WHERE id = %s', (product_id,))
                product = cursor.fetchone() or abort(404)
            else:
                cursor.execute('SELECT COALESCE(MAX(code), 0) + 1 AS code FROM products')
                product = {'code': cursor.fetchone()['code'], 'client_id': int(request.args['klient']) if request.args.get('klient', '').isdigit() else None,
                           'colorant_pct': 2}
            if request.method == 'POST':
                require_csrf()
                try:
                    values = product_values(cursor, request.form)
                    fields = ['code', 'client_id', 'color_id', 'mold_id', 'mold_match', 'material_id', 'colorant_id'] + PRODUCT_TEXT + PRODUCT_NUM
                    if product_id:
                        cursor.execute(f'UPDATE products SET {", ".join(f + " = %s" for f in fields)}, updated_at = NOW() WHERE id = %s',
                                       [values[f] for f in fields] + [product_id])
                        flash('Karta produktu zapisana.', 'success')
                    else:
                        cursor.execute(f'INSERT INTO products ({", ".join(fields)}) VALUES ({", ".join("%s" for _ in fields)}) RETURNING id',
                                       [values[f] for f in fields])
                        product_id = cursor.fetchone()['id']
                        flash(f'Dodano produkt {values["code"]:04d} {values["name"]} (nowa para klient–produkt).', 'success')
                    return redirect(url_for('product_form', product_id=product_id))
                except ValueError as error:
                    flash(str(error), 'error'); product = request.form
                except UniqueViolation:
                    connection.rollback(); flash('Kod produktu jest zajęty albo klient ma już produkt o tej nazwie.', 'error'); product = request.form
            options = option_lists(cursor)
            history = []
            if product_id:
                cursor.execute('''SELECT o.id, o.number, o.order_date, o.status, l.qty, l.production_code FROM order_lines l
                                  JOIN orders o ON o.id = l.order_id WHERE l.product_id = %s ORDER BY o.order_date DESC LIMIT 20''', (product_id,))
                history = cursor.fetchall()
        return render_template('product_form.html', product=product, product_id=product_id, history=history, **options)

    @app.post('/produkty/<int:product_id>/usun')
    @auth
    def product_delete(product_id):
        require_csrf()
        try:
            with db() as connection, connection.cursor() as cursor:
                cursor.execute('DELETE FROM products WHERE id = %s RETURNING name', (product_id,))
                row = cursor.fetchone()
            flash(f'Usunięto produkt {row["name"]}.' if row else 'Nie znaleziono produktu.', 'success')
            return redirect(url_for('products_index'))
        except ForeignKeyViolation:
            flash('Produkt występuje w zamówieniach — nie można go usunąć.', 'error')
            return redirect(url_for('product_form', product_id=product_id))

    # ---------------- kolory ----------------
    @app.route('/kolory', methods=['GET', 'POST'])
    @auth
    def colors_index():
        with db() as connection, connection.cursor() as cursor:
            if request.method == 'POST':
                require_csrf()
                form = request.form
                try:
                    code, name = clean(form.get('code')).zfill(3), clean(form.get('name')).upper()
                    if not re.fullmatch(r'\d{3}', code) or not name:
                        raise ValueError('Kod koloru (CCC) to 3 cyfry, nazwa jest wymagana.')
                    if form.get('id', '').isdigit():
                        cursor.execute('UPDATE colors SET code = %s, name = %s, notes = %s WHERE id = %s',
                                       (code, name, clean(form.get('notes')), int(form['id'])))
                    else:
                        cursor.execute('INSERT INTO colors (code, name, notes) VALUES (%s,%s,%s)', (code, name, clean(form.get('notes'))))
                    flash(f'Zapisano kolor {code} {name}.', 'success')
                except ValueError as error:
                    flash(str(error), 'error')
                except UniqueViolation:
                    connection.rollback(); flash('Kod albo nazwa koloru już istnieje.', 'error')
                return redirect(url_for('colors_index'))
            cursor.execute('''SELECT col.*, COUNT(p.id) AS products FROM colors col LEFT JOIN products p ON p.color_id = col.id
                              GROUP BY col.id ORDER BY col.code''')
            colors = cursor.fetchall()
            cursor.execute("SELECT LPAD((COALESCE(MAX(code::int), 0) + 1)::text, 3, '0') AS n FROM colors")
            next_code = cursor.fetchone()['n']
        return render_template('colors.html', colors=colors, next_code=next_code)
