"""Import startowy modułu zamówień: klienci, produkty, formy, kolory i historia zamówień z plików Excel.

Kody klientów (AAA) i produktów (BBBB) są przejmowane z bazy M2-monika (seed/m2_codes.json),
żeby kody produkcji były identyczne w obu aplikacjach. Dopasowania produkt → tworzywo / barwnik / forma
są robione automatycznie po nazwach i oznaczane jako „AUTO” (do weryfikacji w karcie produktu).
"""
import json
import re
from datetime import date, datetime
from pathlib import Path

from openpyxl import load_workbook

SEED_DIR = Path(__file__).with_name('seed')
CLIENTS_XLSX = 'FIKCYJNA_Baza_klientow_produkcyjnych_dane_fikcyjne.xlsx'
ORDERS_XLSX = 'FIKCYJNE_Zamowienia_klientow_PLASTEMA.xlsx'
PRODUCTS_XLSX = 'Baza_produktow_PLASTEMA.xlsx'
MOLDS_XLSX = 'LISTA FORM     06.10.2026.xlsx'

# Kolory rozpoznawane w nazwach produktów: odmiana z nazwy → nazwa koloru w słowniku.
COLOR_WORDS = {
    'CZARNY': 'CZARNY', 'CZARNA': 'CZARNY', 'CZARNE': 'CZARNY', 'BLACK': 'CZARNY', 'SCHWARZ': 'CZARNY',
    'BIAŁY': 'BIAŁY', 'BIAŁA': 'BIAŁY', 'BIAŁE': 'BIAŁY', 'WHITE': 'BIAŁY',
    'SZARY': 'SZARY', 'SZARA': 'SZARY', 'SZARE': 'SZARY', 'J.SZARY': 'JASNOSZARY', 'JASNOSZARY': 'JASNOSZARY',
    'C.SZARY': 'CIEMNOSZARY', 'CIEMNOSZARY': 'CIEMNOSZARY', 'GRAFIT': 'GRAFITOWY', 'GRAFITOWY': 'GRAFITOWY', 'GRAFITOWA': 'GRAFITOWY',
    'BRĄZ': 'BRĄZOWY', 'BRĄZOWY': 'BRĄZOWY', 'BRĄZOWA': 'BRĄZOWY', 'BEŻ': 'BEŻOWY', 'BEŻOWY': 'BEŻOWY', 'BEŻOWA': 'BEŻOWY',
    'CZERWONY': 'CZERWONY', 'CZERWONA': 'CZERWONY', 'BORDOWY': 'BORDOWY',
    'ZIELONY': 'ZIELONY', 'ZIELONA': 'ZIELONY', 'GREEN': 'ZIELONY', 'MIĘTOWY': 'MIĘTOWY', 'MIĘTA': 'MIĘTOWY', 'LIME': 'LIMONKOWY',
    'NIEBIESKI': 'NIEBIESKI', 'NIEBIESKA': 'NIEBIESKI', 'BLUE': 'NIEBIESKI', 'GRANATOWY': 'GRANATOWY', 'TURKUSOWY': 'TURKUSOWY',
    'ŻÓŁTY': 'ŻÓŁTY', 'ŻÓŁTA': 'ŻÓŁTY', 'POMARAŃCZOWY': 'POMARAŃCZOWY', 'POMARAŃCZOWA': 'POMARAŃCZOWY',
    'RÓŻOWY': 'RÓŻOWY', 'RÓŻOWA': 'RÓŻOWY', 'PINK': 'RÓŻOWY', 'FIOLETOWY': 'FIOLETOWY', 'FIOLETOWA': 'FIOLETOWY',
    'KREMOWY': 'KREMOWY', 'WANILIOWY': 'WANILIOWY', 'KORAL': 'KORALOWY', 'CORAL': 'KORALOWY',
    'NATURALNY': 'NATURALNY', 'NATURAL': 'NATURALNY', 'TRANSPARENT': 'TRANSPARENTNY', 'TRANSPARENTNY': 'TRANSPARENTNY',
}
# Odmiany nazw klientów spotykane w liście form.
CLIENT_ALIASES = {'L&P': ['L&P', 'L*P'], 'COFORMA': ['COFORMA', 'CORFORMA'], 'REGAL TAGS': ['REGALTAGS', 'REGAL TAGS'],
                  'KM': ['K&M'], 'ŁUKASIK': ['ŁUKASIK'], 'ROSA': ['ROSA'], 'HIC': ['HIC'], 'PALISANDER': ['PALISANDER']}
SIZES = {'S', 'M', 'L', 'XL', 'MINI'}
STATUS_MAP = {'Zrealizowane': 'ZREALIZOWANE', 'W realizacji (produkcja w toku)': 'W PRODUKCJI'}


def text(value):
    if value is None:
        return ''
    if isinstance(value, float) and value.is_integer():
        value = int(value)
    return re.sub(r'\s+', ' ', str(value).replace(' ', ' ')).strip()


def key(value):
    return text(value).upper()


def number(value):
    if value in (None, ''):
        return None
    if isinstance(value, (int, float)):
        return value
    try:
        return float(text(value).replace(',', '.'))
    except ValueError:
        return None


def as_date(value):
    if isinstance(value, datetime):
        return value.date()
    if isinstance(value, date):
        return value
    try:
        return date.fromisoformat(text(value)[:10])
    except ValueError:
        return None


def compact(value):
    """Symbol bez spacji, myślników i ukośników — do porównań 'GM-378E' = 'GM 378E'."""
    return re.sub(r'[^0-9A-ZĄĆĘŁŃÓŚŹŻ]', '', key(value))


def tokens(value):
    return [t for t in re.split(r'[^0-9A-ZĄĆĘŁŃÓŚŹŻ]+', key(value)) if t]


COLOR_STEMS = [  # rdzeń słowa → kolor (sprawdzane po kolei, złożenia najpierw)
    ('SZAROFIOLET', 'SZAROFIOLETOWY'), ('SZAROZIELON', 'SZAROZIELONY'), ('CZARN', 'CZARNY'), ('BLACK', 'CZARNY'),
    ('SCHWARZ', 'CZARNY'), ('BIAŁ', 'BIAŁY'), ('WHITE', 'BIAŁY'), ('WEISS', 'BIAŁY'), ('GRAFIT', 'GRAFITOWY'), ('SZAR', 'SZARY'),
    ('BRĄZ', 'BRĄZOWY'), ('BEŻ', 'BEŻOWY'), ('CZERWON', 'CZERWONY'), ('BORDO', 'BORDOWY'), ('ZIELE', 'ZIELONY'),
    ('ZIELON', 'ZIELONY'), ('GREEN', 'ZIELONY'), ('MIĘT', 'MIĘTOWY'), ('NIEBIESK', 'NIEBIESKI'), ('BLUE', 'NIEBIESKI'),
    ('GRANAT', 'GRANATOWY'), ('TURKUS', 'TURKUSOWY'), ('ŻÓŁT', 'ŻÓŁTY'), ('ŻÓLT', 'ŻÓŁTY'), ('POMARAŃCZ', 'POMARAŃCZOWY'),
    ('POARAŃCZ', 'POMARAŃCZOWY'), ('RÓŻ', 'RÓŻOWY'), ('RÓZ', 'RÓŻOWY'), ('PINK', 'RÓŻOWY'), ('FIOLET', 'FIOLETOWY'),
    ('KREM', 'KREMOWY'), ('WANILI', 'WANILIOWY'), ('KORAL', 'KORALOWY'), ('CORAL', 'KORALOWY'), ('LIMON', 'LIMONKOWY'),
    ('LIME', 'LIMONKOWY'), ('NATURAL', 'NATURALNY'), ('TRANSPAR', 'TRANSPARENTNY'),
]
NOT_COLORS = {'SZARPAK', 'SZARPAKI', 'RÓŻNE', 'RÓŻNY', 'BIAŁYSTOK'}
SHADES = {'C': 'CIEMNO', 'CIEMNO': 'CIEMNO', 'CIEMNY': 'CIEMNO', 'J': 'JASNO', 'JASNO': 'JASNO', 'JASNY': 'JASNO'}


def base_color(word):
    word = word.strip('.')
    if not word or word in NOT_COLORS:
        return None
    if word in COLOR_WORDS:
        return COLOR_WORDS[word]
    for stem, color in COLOR_STEMS:
        if word.startswith(stem) and len(word) <= len(stem) + 5:
            return color
    return None


def color_of(name):
    """Kolor z nazwy produktu: ostatnie słowo-kolor, z odcieniem (C./J., CIEMNO/JASNO), np. 'MISKA M C.NIEBIESKI' → CIEMNONIEBIESKI."""
    words = [w for w in re.split(r'[\s,;()/]+', key(name)) if w]
    for i in range(len(words) - 1, -1, -1):
        word, shade = words[i], None
        if '.' in word.strip('.'):  # C.NIEBIESKI, J.SZARA, C.SZ
            prefix, word = word.split('.', 1)
            shade = SHADES.get(prefix)
            if shade and word == 'SZ':
                word = 'SZARY'
        color = base_color(word)
        if color is None:
            continue
        if shade is None and i > 0:
            shade = SHADES.get(words[i - 1].strip('.'))
        if shade and color not in ('NATURALNY', 'TRANSPARENTNY', 'CZARNY', 'BIAŁY') and not color.startswith('SZARO'):
            return shade + color
        return color
    return None


def short_client(full_name, shorts):
    """Pełna nazwa z bazy klientów → krótka nazwa używana w bazie produktów ('HIC Sp. z o.o.' → 'HIC', nie 'HICTRANS')."""
    upper = key(full_name)
    hits = [s for s in shorts if upper == s or upper.startswith(s + ' ')]
    return max(hits, key=len) if hits else None


# --- dopasowania do kartoteki M1 -------------------------------------------------------------

GENERIC = {'PP', 'PE', 'PA', 'PA6', 'PC', 'PS', 'ABS', 'POM', 'TPE', 'TPU', 'HDPE', 'ASA', 'PLA', 'PET', 'PVC', 'GF',
           'NATURAL', 'NATURALNY', 'CZARNY', 'BIAŁY', 'BK', 'UV', 'STABILIZATOR', 'POLIMER', 'S', 'R', 'G', 'HOMO',
           'RANDOM', 'BEZ', 'WŁÓKNA', 'TRANSPARENT', 'NP'}


def match_material(symbol, materials):
    """Najlepsze tworzywo (SS) dla symbolu z raportu produkcyjnego albo None.

    Liczy wspólne tokeny „znaczące” (z cyfrą lub nazwy handlowe), ignorując ogólne nazwy polimerów."""
    wanted = {t for t in tokens(symbol) if t not in GENERIC and len(t) >= 2}
    wanted_compact = compact(symbol)
    if not wanted:
        return None
    best, best_score = None, 0
    for m in materials:
        if m['material_type'] != 'SUROWIEC SYPKI':
            continue
        have = set(tokens(m['symbol'])) | set(tokens(m['internal_name'])) | set(tokens(m['supplier_short_name']))
        score = 0
        for t in wanted:
            if t in have:
                score += 1 if t.isdigit() and len(t) <= 2 else (3 if any(c.isdigit() for c in t) else 1)
            elif any(c.isdigit() for c in t) and len(t) >= 4 and any(t in compact(h) or compact(h) in t for h in have if len(h) >= 4):
                score += 2
        if compact(m['symbol']) and len(compact(m['symbol'])) >= 5 and compact(m['symbol']) in wanted_compact:
            score += 2
        if score > best_score:
            best, best_score = m, score
    return best if best_score >= 3 else None


def match_colorant(symbols, materials):
    """Pierwszy barwnik (BT) z listy symboli (rozdzielonych przecinkiem/średnikiem), którego symbol zgadza się z kartoteką."""
    by_symbol = {compact(m['symbol']): m for m in materials if m['material_type'] == 'BARWNIK TWORZYWA' and m['symbol']}
    for part in re.split(r'[;,]', text(symbols)):
        c = compact(part)
        if not c:
            continue
        if c in by_symbol:
            return by_symbol[c]
        for sym, m in by_symbol.items():
            if len(c) >= 5 and (c.startswith(sym) or sym.startswith(c)) and len(sym) >= 5:
                return m
    return None


def match_mold(client, product_name, molds):
    """Forma dla produktu: forma musi wymieniać klienta, potem liczą się wspólne słowa nazwy (bez koloru)."""
    aliases = CLIENT_ALIASES.get(client, [client])
    all_tokens = tokens(product_name)
    name_tokens = [t for t in all_tokens if t not in COLOR_WORDS and len(t) >= 3]
    sizes = {t for t in all_tokens if t in SIZES}
    if not name_tokens:
        return None
    best, best_score = None, 0
    for mold in molds:
        mold_name = key(mold['name'])
        if not any(re.search(r'(^|[^A-ZĄĆĘŁŃÓŚŹŻ])' + re.escape(a) + r'($|[^A-ZĄĆĘŁŃÓŚŹŻ])', mold_name) for a in aliases):
            continue
        mold_tokens = [t for t in tokens(mold_name) if t not in aliases and len(t) >= 3]
        score = 0
        for t in name_tokens:
            if t in mold_tokens:
                score += 2
            elif len(t) >= 5 and any(m.startswith(t[:5]) for m in mold_tokens if len(m) >= 5):
                score += 1
        mold_sizes = {t for t in tokens(mold_name) if t in SIZES}
        if sizes and mold_sizes:
            score += 2 if sizes & mold_sizes else -3
        if score > best_score:
            best, best_score = mold, score
    return best if best_score >= 2 else None


# --- import -----------------------------------------------------------------------------------

def rows(path, sheet=None, min_row=4):
    workbook = load_workbook(path, read_only=True, data_only=True)
    worksheet = workbook[sheet] if sheet else workbook.active
    data = [r for r in worksheet.iter_rows(min_row=min_row, values_only=True) if any(c not in (None, '') for c in r)]
    workbook.close()
    return data


def seed_orders_module(cursor, source_dir):
    source_dir = Path(source_dir)
    m2 = json.loads((SEED_DIR / 'm2_codes.json').read_text(encoding='utf-8'))
    m2_client_codes = {c['name']: c['code'] for c in m2['clients']}
    m2_product_codes = {(p['client'], p['name_key']): p['code'] for p in m2['products']}
    m2_dosage = {(d['client'], d['name_key']): d for d in m2['dosage']}
    report = {}

    # Klienci
    shorts = sorted(m2_client_codes)
    client_ids = {}
    for r in rows(source_dir / CLIENTS_XLSX):
        if not isinstance(r[0], (int, float)):
            continue
        short = short_client(r[1], shorts)
        code = m2_client_codes.get(short)
        if code is None:
            continue
        since = as_date(r[17])
        cursor.execute('''INSERT INTO clients (code, short_name, name, industry, contact_person, contact_position, phone, phone_central,
                email, website, street, postal_code, city, voivodeship, nip, regon, krs, iban, since, data_status)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) RETURNING id''',
                       (code, short, text(r[1]), *[text(v) for v in r[2:17]], since, text(r[18])))
        client_ids[short] = cursor.fetchone()['id']
    report['klienci'] = len(client_ids)

    # Słownik kolorów: 000 = naturalny / bez barwnika, dalej kolory z nazw produktów (w kolejności alfabetycznej).
    product_rows = [r for r in rows(source_dir / PRODUCTS_XLSX) if isinstance(r[0], (int, float))]
    colors = sorted({c for r in product_rows for c in [color_of(r[2])] if c and c != 'NATURALNY'})
    color_ids = {}
    cursor.execute("INSERT INTO colors (code, name) VALUES ('000', 'NATURALNY / BEZ BARWNIKA') RETURNING id")
    color_ids['NATURALNY'] = cursor.fetchone()['id']
    for n, name in enumerate(colors, start=1):
        cursor.execute('INSERT INTO colors (code, name) VALUES (%s,%s) RETURNING id', (f'{n:03d}', name))
        color_ids[name] = cursor.fetchone()['id']
    report['kolory'] = len(color_ids)

    # Formy wtryskowe
    molds = []
    seen = set()
    for r in rows(source_dir / MOLDS_XLSX, min_row=10):
        name, index = text(r[1]), text(r[6])
        if not name or not re.fullmatch(r'\d{1,3}', index):
            continue
        mold_no = f'{int(index):03d}'
        if mold_no in seen:
            continue
        seen.add(mold_no)
        storage = text(r[7])
        notes = text(r[8])
        if storage and not re.fullmatch(r'[A-Z]\d', storage):
            notes, storage = (storage + ('; ' + notes if notes else '')), ''
        dims = [number(v) for v in r[2:5]]
        cursor.execute('''INSERT INTO molds (mold_no, ordinal, name, dim_1, dim_2, dim_3, weight_kg, storage, notes)
                          VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s) RETURNING id''',
                       (mold_no, len(molds) + 1, name, *dims, number(r[5]), storage, notes))
        molds.append({'id': cursor.fetchone()['id'], 'name': name, 'mold_no': mold_no})
    report['formy'] = len(molds)

    # Produkty
    cursor.execute('SELECT id, material_index, material_type, symbol, internal_name, supplier_short_name FROM materials')
    materials = cursor.fetchall()
    used_codes = set(m2_product_codes.values())
    next_code = max(used_codes, default=0) + 1
    product_ids = {}
    stats = {'tworzywo': 0, 'barwnik': 0, 'forma': 0}
    for r in product_rows:
        client, name = key(r[1]), text(r[2])
        if client not in client_ids or not name or (client, key(name)) in product_ids:
            continue
        code = m2_product_codes.get((client, key(name)))
        if code is None:
            code, next_code = next_code, next_code + 1
        material = match_material(r[3], materials)
        colorant = match_colorant(r[4], materials)
        mold = match_mold(client, name, molds)
        stats['tworzywo'] += material is not None
        stats['barwnik'] += colorant is not None
        stats['forma'] += mold is not None
        dosage = m2_dosage.get((client, key(name)), {}).get('colorant_dosage')
        dosage_pct = round(dosage * 100, 2) if dosage and dosage < 1 else (dosage if dosage else (2 if colorant else None))
        color = color_of(name) or ('NATURALNY' if not text(r[4]) else None)
        cursor.execute('''INSERT INTO products (code, client_id, name, material_text, colorant_text, material_id, colorant_id,
                colorant_pct, color_id, mold_id, mold_match, pattern_no, net_g, gross_g, cavities, cycle_s, per_shift,
                pcs_per_carton, carton_type, carton_kg, machines, orders_count, produced_total, first_production, last_production)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) RETURNING id''',
                       (code, client_ids[client], name, text(r[3]), text(r[4]), material and material['id'], colorant and colorant['id'],
                        dosage_pct, color_ids.get(color), mold and mold['id'], 'AUTO' if mold else None, text(r[5]),
                        number(r[6]), number(r[7]), number(r[8]), number(r[9]), number(r[10]), number(r[11]), text(r[12]),
                        number(r[13]), text(r[14]), number(r[15]), number(r[16]), as_date(r[17]), as_date(r[18])))
        product_ids[(client, key(name))] = cursor.fetchone()['id']
    report['produkty'] = len(product_ids)
    report['dopasowano'] = stats

    # Zamówienia historyczne (numer ZK nadawany według instrukcji: ZK AAA RR MM DD NNN)
    full_to_short = {}
    cursor.execute('SELECT id, short_name, name, code FROM clients')
    for c in cursor.fetchall():
        full_to_short[key(c['name'])] = c
    order_ids, numbers = {}, set()
    for r in rows(source_dir / ORDERS_XLSX, 'Zamówienia'):
        source_ref = text(r[0])
        client = full_to_short.get(key(r[1]))
        order_date = as_date(r[3])
        if not source_ref.startswith('ZK/') or client is None or order_date is None:
            continue
        seq_match = re.search(r'/(\d+)/(\d{4})$', source_ref)
        seq = int(seq_match.group(1)) if seq_match else 1
        number_text = f'ZK {client["code"]} {order_date:%y %m %d} {seq:03d}'
        if number_text in numbers:
            continue
        numbers.add(number_text)
        status = STATUS_MAP.get(text(r[7]), 'ZREALIZOWANE')
        cursor.execute('''INSERT INTO orders (number, client_id, seq, order_date, requested_date, channel, ordered_by, ordered_email,
                source_ref, internal_no, status, accepted_at)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) RETURNING id''',
                       (number_text, client['id'], seq, order_date, as_date(r[4]), text(r[8]), text(r[9]), text(r[10]),
                        source_ref, text(r[2]), status, order_date))
        order_ids[source_ref] = (cursor.fetchone()['id'], client['short_name'])
    report['zamowienia'] = len(order_ids)

    line_count = 0
    cursor.execute('SELECT id, client_id, name, color_id, mold_id, material_id, colorant_id, machines FROM products')
    products = {p['id']: p for p in cursor.fetchall()}
    for r in rows(source_dir / ORDERS_XLSX, 'Pozycje zamówień'):
        ref = text(r[0])
        if ref not in order_ids:
            continue
        order_id, client = order_ids[ref]
        name = text(r[3])
        product_id = product_ids.get((client, key(name)))
        product = products.get(product_id, {})
        qty_raw = r[4]
        qty = int(qty_raw) if isinstance(qty_raw, (int, float)) else sum(int(x) for x in re.findall(r'\d+', text(qty_raw)))
        notes = '' if isinstance(qty_raw, (int, float)) else f'Ilość w zamówieniu: {text(qty_raw)}'
        machines = re.findall(r'\d+', product.get('machines') or '')
        cursor.execute('''INSERT INTO order_lines (order_id, lp, product_id, product_name, qty, color_id, mold_id, material_id,
                colorant_id, machine_no, prod_start, prod_end, notes)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)''',
                       (order_id, int(r[2] or 1), product_id, name, qty, product.get('color_id'), product.get('mold_id'),
                        product.get('material_id'), product.get('colorant_id'), int(machines[0]) if len(machines) == 1 else None,
                        as_date(r[9]), as_date(r[10]), notes))
        line_count += 1
    report['pozycje'] = line_count
    return report
