"""Moduł FORMY WTRYSKOWE: paszport formy, zdjęcia, historia użyć, dziennik serwisowy.

Kod formy EEE (3 cyfry) jest nadawany każdej formie i wchodzi do pełnego kodu produkcji AAA-BBBB-CCC-EEE-FFF-GGG.
Historia użyć i licznik cykli pochodzą ze statystyki produkcji (dok. 6): cykle z licznika PLC z rozliczenia albo,
dla historii z Excela, (dobre + braki) ÷ krotność. Dla wierszy z Excela forma jest brana z aktualnej karty produktu —
poprawienie formy w produkcie poprawia też historię. Rejestr montaży (jak w „PASZPORT FORMY” .xlsx): montaż, demontaż,
liczba wtrysków, wydanie do narzędziowni i powrót, indeksy zdjęć, numer i opis awarii.
"""
import math
import re
from datetime import date
from io import BytesIO

from flask import Response, abort, flash, redirect, render_template, request, url_for
from psycopg.errors import UniqueViolation

from materials import auth, clean, require_csrf
from orders import MOLD_STATUSES, to_date, to_int, to_num

LOCK_ID = 6102032
FORM_SLOTS = (1, 2, 3, 4, 5)       # zdjęcia formy
DETAIL_SLOTS = (6, 7)              # zdjęcia detalu
SLOT_LABELS = {1: 'Forma — widok ogólny', 2: 'Strona dysz (stała)', 3: 'Strona wypychaczy (ruchoma)', 4: 'Gniazda / wkładki',
               5: 'Tabliczka znamionowa / przyłącza', 6: 'Detal — widok 1', 7: 'Detal — widok 2'}
EVENT_TYPES = ['PRZEGLĄD', 'NAPRAWA', 'MODYFIKACJA', 'CZYSZCZENIE / KONSERWACJA', 'PRÓBA / ODBIÓR', 'WYDANIE POZA ZAKŁAD', 'ZWROT DO ZAKŁADU']
SPI_CLASSES = {'101': '101 — ponad 1 000 000 cykli', '102': '102 — do 1 000 000 cykli', '103': '103 — do 500 000 cykli',
               '104': '104 — do 100 000 cykli', '105': '105 — prototypowa, do 500 cykli'}
USED = ('W PRODUKCJI', 'ZREALIZOWANE')

# Pola paszportu: (kolumna, etykieta, typ, opcje / podpowiedź). Typy: text, int, num, date, select, client, area.
SECTIONS = [
    ('Identyfikacja formy', [
        ('mold_no', 'Kod formy EEE *', 'code', None),
        ('name', 'Nazwa formy / detalu *', 'text', None),
        ('trade_name', 'Nazwa handlowa produktu', 'text', None),
        ('product_index', 'Wewnętrzny indeks produktu (BBBB)', 'text', None),
        ('card_date', 'Data utworzenia karty', 'date', None),
        ('status', 'Status', 'select', MOLD_STATUSES),
        ('client_id', 'Klient (detal dla)', 'client', None),
        ('owner', 'Właściciel formy', 'select', ['', 'PLASTEMA — forma własna', 'KLIENT — forma powierzona', 'LEASING / INNY']),
        ('maker', 'Wykonawca (narzędziownia)', 'text', 'np. narzędziownia PLASTEMA'),
        ('drawing_no', 'Nr rysunku / projektu formy', 'text', None),
        ('inventory_no', 'Nr inwentarzowy / środka trwałego', 'text', None),
        ('made_year', 'Rok wykonania', 'int', None),
        ('received_date', 'Data przyjęcia do zakładu', 'date', None),
        ('value_pln', 'Wartość formy [zł]', 'num', None),
        ('storage', 'Miejsce składowania (pole)', 'text', 'np. Z6'),
    ]),
    ('Konstrukcja', [
        ('mold_type', 'Typ formy', 'select', ['', 'dwupłytowa', 'trzypłytowa', 'z gorącymi kanałami', 'piętrowa', 'dwukomponentowa (2K)',
                                              'z obrotową matrycą', 'z wymiennymi wkładkami']),
        ('cavities', 'Krotność (liczba gniazd)', 'int', None),
        ('runner', 'Układ wlewowy', 'select', ['', 'zimny kanał', 'gorące kanały', 'gorąca dysza + zimny rozdzielacz', 'wlew bezpośredni']),
        ('hot_zones', 'Strefy grzania gorących kanałów', 'int', None),
        ('gate_type', 'Rodzaj przewężki', 'text', 'punktowa, tunelowa, filmowa, bezpośrednia…'),
        ('slides', 'Suwaki / rdzenie', 'text', 'np. 2 suwaki mechaniczne, rdzenie hydrauliczne'),
        ('ejection', 'System wypychania', 'text', 'wypychacze, płyta zgarniająca, powietrze…'),
        ('inserts', 'Wymienne wkładki / matryce / stemple', 'text', None),
        ('steel', 'Stal płyt / wkładek', 'text', 'np. 1.2311 / 1.2343'),
        ('hardness_hrc', 'Twardość wkładek [HRC]', 'text', None),
        ('surface', 'Powierzchnia gniazda', 'text', 'polerowana, VDI 3400 Ref 27, tekstura…'),
    ]),
    ('Montaż na wtryskarce i technologia', [
        ('dim_1', 'Wymiar 1 [mm]', 'num', None), ('dim_2', 'Wymiar 2 [mm]', 'num', None), ('dim_3', 'Wymiar 3 [mm]', 'num', None),
        ('weight_kg', 'Masa formy [kg]', 'num', None),
        ('mold_height_mm', 'Wysokość zabudowy [mm]', 'num', None),
        ('opening_stroke_mm', 'Wymagany skok otwarcia [mm]', 'num', None),
        ('centering_ring_mm', 'Pierścień centrujący Ø [mm]', 'num', None),
        ('nozzle_radius_mm', 'Promień kulisty dyszy [mm]', 'num', None),
        ('clamp_force_t', 'Wymagana siła zwarcia [t]', 'num', None),
        ('machines', 'Wtryskarki (na których pracuje)', 'text', 'np. 2, 7'),
        ('cooling_circuits', 'Obiegi chłodzenia', 'int', None),
        ('tool_temp_c', 'Temperatura formy [°C]', 'text', 'np. 40 / 60 (stała / ruchoma)'),
        ('connections', 'Przyłącza (woda, hydraulika, pneumatyka, elektryka)', 'text', None),
        ('cycle_s', 'Nominalny czas cyklu [s]', 'num', None),
        ('shot_weight_g', 'Masa wtrysku [g]', 'num', None),
        ('material_hint', 'Tworzywo zalecane', 'text', None),
    ]),
    ('Żywotność i przeglądy', [
        ('spi_class', 'Klasa formy (SPI)', 'select', [''] + list(SPI_CLASSES)),
        ('guaranteed_cycles', 'Gwarantowana żywotność [cykli]', 'int', None),
        ('initial_cycles', 'Stan początkowy — liczba cykli', 'int', None),
        ('service_interval_cycles', 'Przegląd co [cykli]', 'int', 'np. 50 000'),
        ('service_plan', 'Sugerowane przeglądy — opis (co ile cykli, zakres)', 'area', None),
    ]),
]
FIELDS = [f for _, fields in SECTIONS for f in fields]
COLUMNS = {'text': 'TEXT', 'code': 'TEXT', 'select': 'TEXT', 'int': 'INTEGER', 'num': 'NUMERIC(14,2)', 'date': 'DATE',
           'client': 'BIGINT REFERENCES clients(id) ON DELETE SET NULL', 'area': 'TEXT'}
EXISTING = {'mold_no', 'name', 'status', 'storage', 'dim_1', 'dim_2', 'dim_3', 'weight_kg', 'notes'}

# Użycia formy = wiersze statystyki produkcji (dok. 6). Wiersze z Excela biorą formę z aktualnej karty produktu.
STAT_MOLD = "(CASE WHEN s.source = 'EXCEL' THEN pr.mold_id ELSE s.mold_id END)"
USAGE_SQL = f'''
SELECT {STAT_MOLD} AS mold_id, s.id, s.source, s.prod_color_id, s.product_name, s.internal_order, s.machine_no, s.batch_code,
       s.start_date AS date_start, s.end_date AS date_end, s.qty, s.scrap_pcs, s.cavities, s.cycles AS plc_cycles,
       s.mounted_by, s.dismounted_by, s.pattern_at_end, c.short_name, c.code AS client_code, pr.code AS product_code
FROM productions s JOIN clients c ON c.id = s.client_id LEFT JOIN products pr ON pr.id = s.product_id'''
# cykle wiersza: licznik PLC z rozliczenia, inaczej (dobre + braki) ÷ krotność
ROW_CYCLES = "COALESCE(u.plc_cycles, CEIL((COALESCE(u.qty, 0) + COALESCE(u.scrap_pcs, 0)) / NULLIF(COALESCE(u.cavities, m.cavities, 1), 0)))"


def row_cycles(u, mold_cavities):
    if u['plc_cycles'] is not None:
        return int(u['plc_cycles'])
    cav = u['cavities'] or mold_cavities or 1
    return math.ceil(((u['qty'] or 0) + (u['scrap_pcs'] or 0)) / cav) if (u['qty'] or u['scrap_pcs']) else None


def cycles(qty, cavities):
    return math.ceil(qty / cavities) if qty and cavities else None


def parse_value(kind, raw, label):
    if kind in ('int',):
        return to_int(raw, label)
    if kind == 'num':
        return to_num(raw, label)
    if kind == 'date':
        return to_date(raw, label)
    if kind == 'client':
        return int(raw) if (raw or '').isdigit() else None
    return clean(raw)


def make_images(data):
    """Zdjęcie z telefonu → JPEG max 1800 px + miniatura 480 px (obrót wg EXIF)."""
    from PIL import Image, ImageOps
    try:
        from pillow_heif import register_heif_opener
        register_heif_opener()
    except ImportError:
        pass
    try:
        image = Image.open(BytesIO(data))
        image = ImageOps.exif_transpose(image).convert('RGB')
    except Exception as error:
        raise ValueError('Nie udało się odczytać zdjęcia — wgraj plik JPG, PNG, WEBP lub HEIC.') from error
    out = []
    for size, quality in ((1800, 85), (480, 78)):
        copy = image.copy()
        copy.thumbnail((size, size))
        buffer = BytesIO()
        copy.save(buffer, 'JPEG', quality=quality, optimize=True)
        out.append(buffer.getvalue())
    return out[0], out[1], image.size


def init_molds(db):
    with db() as connection, connection.cursor() as cursor:
        cursor.execute('SELECT pg_advisory_xact_lock(%s)', (LOCK_ID,))
        for column, _, kind, _ in FIELDS:
            if column not in EXISTING:
                cursor.execute(f'ALTER TABLE molds ADD COLUMN IF NOT EXISTS {column} {COLUMNS[kind]}')
        cursor.execute('''CREATE TABLE IF NOT EXISTS mold_photos (
            id BIGSERIAL PRIMARY KEY, mold_id BIGINT NOT NULL REFERENCES molds(id) ON DELETE CASCADE,
            slot SMALLINT NOT NULL CHECK (slot BETWEEN 1 AND 7), filename TEXT, width INTEGER, height INTEGER,
            data BYTEA NOT NULL, thumb BYTEA NOT NULL, uploaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), UNIQUE (mold_id, slot))''')
        cursor.execute('''CREATE TABLE IF NOT EXISTS mold_events (
            id BIGSERIAL PRIMARY KEY, mold_id BIGINT NOT NULL REFERENCES molds(id) ON DELETE CASCADE,
            event_date DATE NOT NULL DEFAULT CURRENT_DATE, event_type TEXT NOT NULL, description TEXT, performed_by TEXT,
            cost_pln NUMERIC(12,2), downtime_h NUMERIC(8,1), cycles_at INTEGER, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW())''')
        cursor.execute('CREATE INDEX IF NOT EXISTS mold_events_mold_idx ON mold_events(mold_id, event_date)')
        cursor.execute('''CREATE TABLE IF NOT EXISTS mold_mounts (
            id BIGSERIAL PRIMARY KEY, mold_id BIGINT NOT NULL REFERENCES molds(id) ON DELETE CASCADE,
            prod_order_id BIGINT UNIQUE, stat_ref TEXT, mount_date DATE, dismount_date DATE, shots INTEGER, machine_no SMALLINT,
            mounted_by TEXT, dismounted_by TEXT, toolroom_out DATE, toolroom_back DATE, photo_refs TEXT, failure_no TEXT,
            failure_desc TEXT, notes TEXT, manual_edit BOOLEAN NOT NULL DEFAULT FALSE, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            UNIQUE (mold_id, stat_ref))''')
        cursor.execute('CREATE INDEX IF NOT EXISTS mold_mounts_mold_idx ON mold_mounts(mold_id, mount_date)')
        cursor.execute("SELECT 1 FROM app_settings WHERE key = 'molds_passport_v1'")
        if cursor.fetchone() is None:
            prefill_passports(cursor)
            cursor.execute("INSERT INTO app_settings (key, value) VALUES ('molds_passport_v1', '1')")
        cursor.execute("SELECT 1 FROM app_settings WHERE key = 'molds_passport_v2'")
        if cursor.fetchone() is None:
            prefill_passport_v2(cursor)
            cursor.execute("INSERT INTO app_settings (key, value) VALUES ('molds_passport_v2', '1')")


def prefill_passports(cursor):
    """Jednorazowe uzupełnienie paszportów z danych, które już są: produkty formy i uwagi z listy form."""
    cursor.execute('''SELECT m.id, m.notes,
            MAX(p.cavities) AS cavities, MAX(p.cycle_s) AS cycle_s,
            MODE() WITHIN GROUP (ORDER BY p.client_id) AS client_id,
            STRING_AGG(DISTINCT p.machines, ', ') AS machines,
            MAX(p.gross_g * p.cavities) AS shot,
            MODE() WITHIN GROUP (ORDER BY p.material_text) AS material
        FROM molds m LEFT JOIN products p ON p.mold_id = m.id GROUP BY m.id''')
    for m in cursor.fetchall():
        notes = (m['notes'] or '').upper()
        machines = sorted({int(x) for x in re.findall(r'\d+', m['machines'] or '') if 1 <= int(x) <= 9})
        hot = re.search(r'(\d+)\s*GRZAN', notes)
        cursor.execute('''UPDATE molds SET cavities = COALESCE(cavities, %s), cycle_s = COALESCE(cycle_s, %s),
                client_id = COALESCE(client_id, %s), machines = COALESCE(machines, %s), shot_weight_g = COALESCE(shot_weight_g, %s),
                material_hint = COALESCE(material_hint, %s), runner = COALESCE(runner, %s), hot_zones = COALESCE(hot_zones, %s),
                slides = COALESCE(slides, %s), inserts = COALESCE(inserts, %s),
                mold_type = COALESCE(mold_type, %s) WHERE id = %s''',
                       (m['cavities'], m['cycle_s'], m['client_id'], ', '.join(map(str, machines)) or None,
                        round(m['shot'], 1) if m['shot'] else None, m['material'],
                        'gorące kanały' if 'GRZAN' in notes else None, int(hot.group(1)) if hot else None,
                        'rdzenie hydrauliczne' if 'RDZENIE HYDRAULICZNE' in notes else None,
                        m['notes'] if re.search(r'WYMIENN|MATRYC|STEMP', notes) else None,
                        'z gorącymi kanałami' if 'GRZAN' in notes else ('dwukomponentowa (2K)' if '2K' in notes else None), m['id']))


def prefill_passport_v2(cursor):
    """Pola z wzoru paszportu: nazwa handlowa (wspólna nazwa produktów formy), indeks produktu (kody BBBB), data karty."""
    from settlement import base_name
    cursor.execute('''SELECT m.id, m.created_at, ARRAY_AGG(p.name ORDER BY p.code) FILTER (WHERE p.id IS NOT NULL) AS names,
                             ARRAY_AGG(LPAD(p.code::text, 4, '0') ORDER BY p.code) FILTER (WHERE p.id IS NOT NULL) AS codes
                      FROM molds m LEFT JOIN products p ON p.mold_id = m.id GROUP BY m.id''')
    for m in cursor.fetchall():
        codes = m['codes'] or []
        cursor.execute('''UPDATE molds SET trade_name = COALESCE(trade_name, %s), product_index = COALESCE(product_index, %s),
                          card_date = COALESCE(card_date, %s) WHERE id = %s''',
                       (base_name(m['names']) if m['names'] else None,
                        (', '.join(codes[:6]) + (f' … (+{len(codes) - 6})' if len(codes) > 6 else '')) if codes else None,
                        m['created_at'].date(), m['id']))


def mold_stats(cursor, mold_ids=None):
    """Statystyki użycia form ze statystyki produkcji: ostatnie użycie, użycia (zamówienia), sztuki, cykle, cykle od przeglądu."""
    cursor.execute(f'''SELECT u.mold_id, COUNT(DISTINCT COALESCE(u.internal_order, u.id::text)) AS uses, SUM(u.qty) AS qty,
                              MAX(COALESCE(u.date_end, u.date_start)) AS last_used, SUM({ROW_CYCLES}) AS cycles,
                              SUM({ROW_CYCLES}) FILTER (WHERE ev.last_service IS NULL OR COALESCE(u.date_end, u.date_start) > ev.last_service) AS cycles_since,
                              MAX(ev.last_service) AS last_service
                       FROM ({USAGE_SQL}) u JOIN molds m ON m.id = u.mold_id
                       LEFT JOIN (SELECT mold_id, MAX(event_date) AS last_service FROM mold_events
                                  WHERE event_type IN ('PRZEGLĄD', 'NAPRAWA') GROUP BY mold_id) ev ON ev.mold_id = u.mold_id
                       WHERE u.mold_id IS NOT NULL {"AND u.mold_id = ANY(%s)" if mold_ids else ""}
                       GROUP BY u.mold_id''', [mold_ids] if mold_ids else [])
    return {r['mold_id']: r for r in cursor.fetchall()}


MOUNT_FIELDS = [('mount_date', 'Data montażu', 'date'), ('dismount_date', 'Data demontażu', 'date'), ('shots', 'Liczba wtrysków', 'int'),
                ('machine_no', 'Wtryskarka', 'int'), ('mounted_by', 'Kto zakładał', 'text'), ('dismounted_by', 'Kto demontował', 'text'),
                ('toolroom_out', 'Wydano do narzędziowni', 'date'), ('toolroom_back', 'Powrót z narzędziowni', 'date'),
                ('photo_refs', 'Indeksy zdjęć', 'text'), ('failure_no', 'Numer awarii', 'text'), ('failure_desc', 'Opis awarii', 'text'),
                ('notes', 'Uwagi', 'text')]


def mount_register(cursor, mold, usage):
    """Rejestr montaży: wpisy z rozliczenia produkcji i ręczne (mold_mounts) + montaże odtworzone ze statystyki z Excela
    (jedno zamówienie wewnętrzne na maszynie = jeden montaż; liczba wtrysków = suma cykli kolorów)."""
    cursor.execute('''SELECT mm.*, po.number AS order_number FROM mold_mounts mm LEFT JOIN prod_orders po ON po.id = mm.prod_order_id
                      WHERE mm.mold_id = %s''', (mold['id'],))
    rows = []
    taken = set()
    for m in cursor.fetchall():
        m = dict(m)
        m['source'] = 'rozliczenie' if m['prod_order_id'] else ('statystyka + uzupełnienie' if m['stat_ref'] else 'wpis ręczny')
        m['internal_order'] = m['order_number'] or (m['stat_ref'] or '').split('|')[0] or None
        taken.add(m['stat_ref'])
        rows.append(m)
    groups = {}
    for u in usage:
        if u['source'] != 'EXCEL':
            continue
        ref = f'{u["internal_order"] or "?"}|{u["machine_no"] or "?"}'
        groups.setdefault(ref, []).append(u)
    for ref, items in groups.items():
        if ref in taken:
            continue
        items.sort(key=lambda u: (u['date_start'] or date.min, u['id']))
        shots = [row_cycles(u, mold['cavities']) for u in items]
        rows.append({'id': None, 'stat_ref': ref, 'source': 'statystyka', 'internal_order': items[0]['internal_order'],
                     'mount_date': min((u['date_start'] for u in items if u['date_start']), default=None),
                     'dismount_date': max((u['date_end'] for u in items if u['date_end']), default=None),
                     'shots': sum(x for x in shots if x) or None, 'machine_no': items[0]['machine_no'],
                     'mounted_by': next((u['mounted_by'] for u in items if u['mounted_by']), None),
                     'dismounted_by': next((u['dismounted_by'] for u in reversed(items) if u['dismounted_by']), None),
                     'toolroom_out': None, 'toolroom_back': None, 'photo_refs': None, 'failure_no': None, 'failure_desc': None,
                     'notes': ('wzór na formie: ' + items[-1]['pattern_at_end']) if items[-1]['pattern_at_end'] else None})
    rows.sort(key=lambda r: (r['mount_date'] or date.min), reverse=True)
    return rows


def register_mold_routes(app, db):
    app.jinja_env.globals.update(mold_event_types=EVENT_TYPES, spi_classes=SPI_CLASSES)
    app.config.setdefault('MAX_CONTENT_LENGTH', 40 * 1024 * 1024)

    @app.get('/formy')
    @auth
    def molds_index():
        query, status, flag = request.args.get('q', '').strip(), request.args.get('status', ''), request.args.get('flaga', '')
        sql = '''SELECT m.*, c.short_name AS client_name, COUNT(DISTINCT p.id) AS products,
                        (SELECT MIN(slot) FROM mold_photos ph WHERE ph.mold_id = m.id) AS photo_slot,
                        (SELECT MAX(l.planned_end) FROM order_lines l JOIN orders o ON o.id = l.order_id
                         WHERE l.mold_id = m.id AND o.status IN ('PRZYJĘTE','W PRODUKCJI')) AS busy_until
                 FROM molds m LEFT JOIN products p ON p.mold_id = m.id LEFT JOIN clients c ON c.id = m.client_id WHERE TRUE'''
        params = []
        if query:
            sql += ' AND (m.name ILIKE %s OR m.mold_no = %s OR m.storage ILIKE %s OR m.notes ILIKE %s OR c.short_name ILIKE %s OR m.drawing_no ILIKE %s)'
            term = f'%{query}%'
            params += [term, query.zfill(3) if query.isdigit() else query, term, term, term, term]
        if status in MOLD_STATUSES:
            sql += ' AND m.status = %s'; params.append(status)
        sql += ' GROUP BY m.id, c.short_name ORDER BY m.mold_no'
        with db() as connection, connection.cursor() as cursor:
            cursor.execute(sql, params)
            molds = cursor.fetchall()
            stats = mold_stats(cursor)
            cursor.execute('SELECT status, COUNT(*) AS n FROM molds GROUP BY status')
            counts = {r['status']: r['n'] for r in cursor.fetchall()}
        rows = []
        for m in molds:
            s = stats.get(m['id'], {})
            counter = (m['initial_cycles'] or 0) + int(s.get('cycles') or 0)
            since = int(s.get('cycles_since') or 0) + (0 if s.get('last_service') else (m['initial_cycles'] or 0))
            due = m['service_interval_cycles'] and since >= m['service_interval_cycles']
            row = {'m': m, 's': s, 'counter': counter, 'due': due}
            if flag == 'przeglad' and not due:
                continue
            if flag == 'bez-produktow' and m['products']:
                continue
            if flag == 'nieuzywane' and s.get('uses'):
                continue
            rows.append(row)
        if request.args.get('sort') == 'uzycie':
            rows.sort(key=lambda r: r['s'].get('last_used') or date.min, reverse=True)
        return render_template('molds.html', rows=rows, query=query, status=status, counts=counts, flag=flag,
                               sort=request.args.get('sort', ''), today=date.today())

    def load(cursor, mold_id):
        cursor.execute('SELECT m.*, c.short_name AS client_name, c.code AS client_code FROM molds m LEFT JOIN clients c ON c.id = m.client_id WHERE m.id = %s', (mold_id,))
        mold = cursor.fetchone()
        if mold is None:
            abort(404)
        return mold

    @app.get('/formy/<int:mold_id>')
    @auth
    def mold_passport(mold_id):
        with db() as connection, connection.cursor() as cursor:
            mold = load(cursor, mold_id)
            cursor.execute('SELECT slot, filename, width, height, uploaded_at FROM mold_photos WHERE mold_id = %s', (mold_id,))
            photos = {r['slot']: r for r in cursor.fetchall()}
            cursor.execute(f'SELECT * FROM ({USAGE_SQL}) u WHERE u.mold_id = %s ORDER BY u.date_start DESC NULLS LAST, u.id DESC', (mold_id,))
            usage = cursor.fetchall()
            cursor.execute('''SELECT o.id AS order_id, o.number, o.status, c.short_name, l.product_name, l.qty, l.machine_no,
                                     l.planned_start::date AS date_start, l.planned_end::date AS date_end
                              FROM order_lines l JOIN orders o ON o.id = l.order_id JOIN clients c ON c.id = o.client_id
                              WHERE l.mold_id = %s AND o.status = 'PRZYJĘTE' ORDER BY l.planned_start''', (mold_id,))
            planned = cursor.fetchall()
            cursor.execute('''SELECT po.id, po.number, po.status, po.product_name, po.qty_total, po.machine_no, po.planned_start, po.batch_code
                              FROM prod_orders po WHERE po.mold_id = %s AND po.status IN ('PLANOWANE','W PRODUKCJI') ORDER BY po.seq''', (mold_id,))
            prod_orders = cursor.fetchall()
            mounts = mount_register(cursor, mold, usage)
            cursor.execute('SELECT * FROM mold_events WHERE mold_id = %s ORDER BY event_date DESC, id DESC', (mold_id,))
            events = cursor.fetchall()
            cursor.execute('''SELECT p.id, p.code, p.name, p.mold_match, p.cavities, p.cycle_s, p.gross_g, c.code AS client_code, c.short_name,
                                     col.code AS color_code, col.name AS color_name, ma.material_index, cb.material_index AS colorant_index
                              FROM products p JOIN clients c ON c.id = p.client_id LEFT JOIN colors col ON col.id = p.color_id
                              LEFT JOIN materials ma ON ma.id = p.material_id LEFT JOIN materials cb ON cb.id = p.colorant_id
                              WHERE p.mold_id = %s ORDER BY c.short_name, p.name''', (mold_id,))
            products = cursor.fetchall()
            cursor.execute("""SELECT MAX(l.planned_end) AS busy FROM order_lines l JOIN orders o ON o.id = l.order_id
                              WHERE l.mold_id = %s AND o.status IN ('PRZYJĘTE','W PRODUKCJI')""", (mold_id,))
            busy_until = cursor.fetchone()['busy']
        done = []
        for u in usage:
            u = dict(u)
            u['cycles'] = row_cycles(u, mold['cavities'])
            done.append(u)
        last_service = next((e for e in events if e['event_type'] in ('PRZEGLĄD', 'NAPRAWA')), None)
        total_cycles = sum(u['cycles'] or 0 for u in done)
        since = sum(u['cycles'] or 0 for u in done
                    if not last_service or (u['date_end'] or u['date_start'] or date.min) > last_service['event_date'])
        if not last_service:
            since += mold['initial_cycles'] or 0
        summary = {
            'last_used': max((u['date_end'] or u['date_start'] for u in done if (u['date_end'] or u['date_start'])), default=None),
            'uses': len({u['internal_order'] or u['id'] for u in done}), 'qty': sum(u['qty'] or 0 for u in done), 'cycles': total_cycles,
            'scrap': sum(u['scrap_pcs'] or 0 for u in done),
            'counter': (mold['initial_cycles'] or 0) + total_cycles, 'since': since, 'last_service': last_service,
            'to_service': (mold['service_interval_cycles'] - since) if mold['service_interval_cycles'] else None,
            'life_pct': round(((mold['initial_cycles'] or 0) + total_cycles) / mold['guaranteed_cycles'] * 100, 1) if mold['guaranteed_cycles'] else None,
            'busy_until': busy_until, 'machines_used': sorted({u['machine_no'] for u in done if u['machine_no']}, key=str),
        }
        for p in products:
            p['production_code'] = f'{p["client_code"]}-{p["code"]:04d}-{p["color_code"] or "000"}'
            ff = lambda idx: f'{int(idx[2:]):03d}' if idx and idx[2:].isdigit() else '000'
            p['full_code'] = f'{p["production_code"]}-{mold["mold_no"]}-{ff(p["material_index"])}-{ff(p["colorant_index"])}'
        return render_template('mold_passport.html', mold=mold, photos=photos, done=done, planned=planned, events=events,
                               prod_orders=prod_orders, mounts=mounts,
                               products=products, summary=summary, sections=SECTIONS, slot_labels=SLOT_LABELS,
                               form_slots=FORM_SLOTS, detail_slots=DETAIL_SLOTS, today=date.today(),
                               print_mode=request.args.get('druk') == '1')

    @app.route('/formy/nowa', methods=['GET', 'POST'])
    @app.route('/formy/<int:mold_id>/edytuj', methods=['GET', 'POST'])
    @auth
    def mold_form(mold_id=None):
        with db() as connection, connection.cursor() as cursor:
            if mold_id:
                mold = load(cursor, mold_id)
            else:
                cursor.execute("SELECT LPAD((COALESCE(MAX(mold_no::int), 0) + 1)::text, 3, '0') AS n FROM molds")
                mold = {'mold_no': cursor.fetchone()['n'], 'status': 'SPRAWNA'}
            if request.method == 'POST':
                require_csrf()
                form = request.form
                try:
                    values = {}
                    for column, label, kind, _ in FIELDS:
                        values[column] = parse_value(kind, form.get(column), label.rstrip(' *'))
                    values['notes'] = form.get('notes', '').strip()
                    values['mold_no'] = values['mold_no'].zfill(3)
                    if not re.fullmatch(r'\d{3}', values['mold_no']):
                        raise ValueError('Kod formy EEE musi mieć dokładnie 3 cyfry (np. 245).')
                    if not values['name']:
                        raise ValueError('Podaj nazwę formy.')
                    if values['status'] not in MOLD_STATUSES:
                        values['status'] = 'SPRAWNA'
                    columns = list(values)
                    if mold_id:
                        cursor.execute(f'UPDATE molds SET {", ".join(c + " = %s" for c in columns)}, updated_at = NOW() WHERE id = %s',
                                       [values[c] for c in columns] + [mold_id])
                        flash('Paszport formy zapisany.', 'success')
                    else:
                        cursor.execute(f'INSERT INTO molds ({", ".join(columns)}) VALUES ({", ".join("%s" for _ in columns)}) RETURNING id',
                                       [values[c] for c in columns])
                        mold_id = cursor.fetchone()['id']
                        flash(f'Nadano kod formy {values["mold_no"]}. Dodaj zdjęcia formy i detalu.', 'success')
                    return redirect(url_for('mold_passport', mold_id=mold_id))
                except ValueError as error:
                    flash(str(error), 'error'); mold = form
                except UniqueViolation:
                    connection.rollback(); flash('Ten kod formy jest już zajęty — każda forma musi mieć własny kod EEE.', 'error'); mold = form
            cursor.execute('SELECT id, code, short_name FROM clients ORDER BY short_name')
            clients = cursor.fetchall()
        return render_template('mold_form.html', mold=mold, mold_id=mold_id, sections=SECTIONS, clients=clients)

    @app.post('/formy/<int:mold_id>/usun')
    @auth
    def mold_delete(mold_id):
        require_csrf()
        with db() as connection, connection.cursor() as cursor:
            cursor.execute('SELECT COUNT(*) AS n FROM products WHERE mold_id = %s', (mold_id,))
            products = cursor.fetchone()['n']
            cursor.execute('SELECT COUNT(*) AS n FROM order_lines WHERE mold_id = %s', (mold_id,))
            lines = cursor.fetchone()['n']
            if products or lines:
                flash('Forma ma produkty lub historię produkcji — zmień jej status na WYCOFANA zamiast usuwać (paszport zostaje).', 'error')
                return redirect(url_for('mold_passport', mold_id=mold_id))
            cursor.execute('DELETE FROM molds WHERE id = %s', (mold_id,))
        flash('Usunięto formę.', 'success')
        return redirect(url_for('molds_index'))

    # ---------------- zdjęcia ----------------
    @app.get('/formy/<int:mold_id>/zdjecie/<int:slot>')
    @auth
    def mold_photo(mold_id, slot):
        mini = request.args.get('mini') == '1'
        with db() as connection, connection.cursor() as cursor:
            cursor.execute(f'SELECT {"thumb" if mini else "data"} AS img, uploaded_at FROM mold_photos WHERE mold_id = %s AND slot = %s',
                           (mold_id, slot))
            row = cursor.fetchone()
        if row is None:
            abort(404)
        etag = f'{mold_id}-{slot}-{int(row["uploaded_at"].timestamp())}-{int(mini)}'
        if request.if_none_match.contains(etag):
            return Response(status=304)
        response = Response(bytes(row['img']), mimetype='image/jpeg')
        response.set_etag(etag)
        response.headers['Cache-Control'] = 'private, max-age=86400'
        return response

    @app.post('/formy/<int:mold_id>/zdjecie/<int:slot>')
    @auth
    def mold_photo_upload(mold_id, slot):
        require_csrf()
        if slot not in SLOT_LABELS:
            abort(404)
        anchor = url_for('mold_passport', mold_id=mold_id) + '#zdjecia'
        if request.form.get('action') == 'delete':
            with db() as connection, connection.cursor() as cursor:
                cursor.execute('DELETE FROM mold_photos WHERE mold_id = %s AND slot = %s', (mold_id, slot))
            flash(f'Usunięto zdjęcie: {SLOT_LABELS[slot]}.', 'success')
            return redirect(anchor)
        upload = request.files.get('photo')
        if not upload or not upload.filename:
            flash('Wybierz plik zdjęcia.', 'error')
            return redirect(anchor)
        try:
            data, thumb, (width, height) = make_images(upload.read())
        except ValueError as error:
            flash(str(error), 'error')
            return redirect(anchor)
        with db() as connection, connection.cursor() as cursor:
            load(cursor, mold_id)
            cursor.execute('''INSERT INTO mold_photos (mold_id, slot, filename, width, height, data, thumb) VALUES (%s,%s,%s,%s,%s,%s,%s)
                              ON CONFLICT (mold_id, slot) DO UPDATE SET filename = EXCLUDED.filename, width = EXCLUDED.width,
                              height = EXCLUDED.height, data = EXCLUDED.data, thumb = EXCLUDED.thumb, uploaded_at = NOW()''',
                           (mold_id, slot, clean(upload.filename)[:200], width, height, data, thumb))
        flash(f'Zapisano zdjęcie: {SLOT_LABELS[slot]}.', 'success')
        return redirect(anchor)

    # ---------------- rejestr montaży (wzór „PASZPORT FORMY”) ----------------
    @app.route('/formy/<int:mold_id>/montaz', methods=['GET', 'POST'])
    @auth
    def mold_mount(mold_id):
        mount_id = request.values.get('id', '')
        ref = request.values.get('ref', '')
        with db() as connection, connection.cursor() as cursor:
            mold = load(cursor, mold_id)
            mount = {}
            if mount_id.isdigit():
                cursor.execute('SELECT * FROM mold_mounts WHERE id = %s AND mold_id = %s', (int(mount_id), mold_id))
                mount = cursor.fetchone() or abort(404)
            elif ref:
                cursor.execute(f'SELECT * FROM ({USAGE_SQL}) u WHERE u.mold_id = %s', (mold_id,))
                mount = next((r for r in mount_register(cursor, mold, cursor.fetchall()) if r['stat_ref'] == ref), None) or abort(404)
            if request.method == 'POST':
                require_csrf()
                try:
                    values = {c: parse_value(k, request.form.get(c), label) for c, label, k in MOUNT_FIELDS}
                    if values['machine_no'] is not None and not 1 <= values['machine_no'] <= 9:
                        raise ValueError('Wtryskarka 1–9.')
                    if not values['mount_date'] and not values['toolroom_out'] and not values['failure_no']:
                        raise ValueError('Wpisz datę montażu, wydania do narzędziowni albo numer awarii.')
                    columns = list(values)
                    if mount.get('id'):
                        cursor.execute(f'UPDATE mold_mounts SET {", ".join(c + " = %s" for c in columns)}, manual_edit = TRUE WHERE id = %s',
                                       [values[c] for c in columns] + [mount['id']])
                    else:
                        cursor.execute(f'''INSERT INTO mold_mounts (mold_id, stat_ref, manual_edit, {", ".join(columns)})
                                           VALUES (%s, %s, TRUE, {", ".join("%s" for _ in columns)})''',
                                       [mold_id, ref or None] + [values[c] for c in columns])
                    flash('Zapisano wpis w rejestrze montaży formy.', 'success')
                    return redirect(url_for('mold_passport', mold_id=mold_id) + '#montaze')
                except ValueError as error:
                    flash(str(error), 'error'); mount = dict(mount, **{k: v for k, v in request.form.items()})
            cursor.execute("SELECT COUNT(*) + 1 AS n FROM mold_mounts WHERE failure_no IS NOT NULL AND EXTRACT(YEAR FROM created_at) = %s",
                           (date.today().year,))
            next_failure = f'AW/{date.today().year}/{cursor.fetchone()["n"]:03d}'
        return render_template('mold_mount_form.html', mold=mold, mount=mount, fields=MOUNT_FIELDS, ref=ref, next_failure=next_failure)

    @app.post('/formy/<int:mold_id>/montaz/<int:mount_id>/usun')
    @auth
    def mold_mount_delete(mold_id, mount_id):
        require_csrf()
        with db() as connection, connection.cursor() as cursor:
            cursor.execute('DELETE FROM mold_mounts WHERE id = %s AND mold_id = %s AND prod_order_id IS NULL RETURNING id', (mount_id, mold_id))
            ok = cursor.fetchone()
        flash('Usunięto wpis z rejestru montaży.' if ok else 'Wpisu z rozliczenia produkcji nie usuwa się — popraw go albo cofnij rozliczenie.',
              'success' if ok else 'error')
        return redirect(url_for('mold_passport', mold_id=mold_id) + '#montaze')

    # ---------------- dziennik serwisowy ----------------
    @app.post('/formy/<int:mold_id>/dziennik')
    @auth
    def mold_event(mold_id):
        require_csrf()
        form = request.form
        anchor = url_for('mold_passport', mold_id=mold_id) + '#dziennik'
        with db() as connection, connection.cursor() as cursor:
            load(cursor, mold_id)
            if form.get('delete', '').isdigit():
                cursor.execute('DELETE FROM mold_events WHERE id = %s AND mold_id = %s', (int(form['delete']), mold_id))
                flash('Usunięto wpis z dziennika.', 'success')
                return redirect(anchor)
            try:
                event_type = form.get('event_type', '')
                if event_type not in EVENT_TYPES:
                    raise ValueError('Wybierz rodzaj wpisu.')
                description = form.get('description', '').strip()
                if not description:
                    raise ValueError('Opisz, co zostało zrobione.')
                cursor.execute('''INSERT INTO mold_events (mold_id, event_date, event_type, description, performed_by, cost_pln, downtime_h, cycles_at)
                                  VALUES (%s,%s,%s,%s,%s,%s,%s,%s)''',
                               (mold_id, to_date(form.get('event_date'), 'Data', required=True), event_type, description,
                                clean(form.get('performed_by')), to_num(form.get('cost_pln'), 'Koszt'),
                                to_num(form.get('downtime_h'), 'Przestój'), to_int(form.get('cycles_at'), 'Licznik cykli')))
                new_status = form.get('new_status', '')
                if new_status in MOLD_STATUSES:
                    cursor.execute('UPDATE molds SET status = %s, updated_at = NOW() WHERE id = %s', (new_status, mold_id))
                flash(f'Dodano wpis: {event_type}.' + (f' Status formy: {new_status}.' if new_status in MOLD_STATUSES else ''), 'success')
            except ValueError as error:
                flash(str(error), 'error')
        return redirect(anchor)
