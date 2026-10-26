"""Moduł MAGAZYN WYROBÓW GOTOWYCH.

Stan = suma ruchów w kartotece `fg_moves` (ilość ze znakiem), prowadzony na produkt (BBBB) i szarżę (N-Z-S-DDMMRR):
  PW  + przyjęcie z produkcji (dok. 10 w rozliczeniu produkcji — ruch powstaje automatycznie przy przyjęciu PW),
  ZW  + zwrot od klienta (dokument ZW),
  WZ  − wydanie do klienta (dokument WZ, zwykle z zamówienia ZK; szarże dobierane FIFO),
  KOR ± różnica inwentaryzacyjna (dokument INW-WG).
Szarża na każdym ruchu daje identyfikowalność: zamówienie klienta ZK ↔ WZ ↔ szarża ↔ zamówienie produkcji ↔ statystyka.
"""
from datetime import date
from urllib.parse import quote

from flask import abort, flash, redirect, render_template, request, url_for

from materials import auth, clean, require_csrf
from orders import to_date, to_int

LOCK_ID = 6102035
DOC_TYPES = {
    'PW': {'label': 'Przyjęcie z produkcji (PW)', 'prefix': 'PW', 'sign': 1, 'move': 'PW'},
    'WZ': {'label': 'Wydanie zewnętrzne (WZ)', 'prefix': 'WZ', 'sign': -1, 'move': 'WZ'},
    'ZW': {'label': 'Zwrot od klienta (ZW)', 'prefix': 'ZW', 'sign': 1, 'move': 'ZW'},
    'INW': {'label': 'Inwentaryzacja wyrobów (INW-WG)', 'prefix': 'INW-WG', 'sign': 0, 'move': 'KOR'},
}
MOVE_LABELS = {'PW': 'przyjęcie z produkcji', 'WZ': 'wydanie do klienta', 'ZW': 'zwrot od klienta', 'KOR': 'korekta inwentaryzacyjna'}
RETURN_REASONS = ['reklamacja jakościowa', 'błędna ilość / pomyłka w wysyłce', 'uszkodzenie w transporcie', 'zwrot handlowy', 'inny']

STOCK_SQL = '''SELECT m.product_id, COALESCE(m.batch_code, '') AS batch_code, SUM(m.qty) AS qty,
                      MIN(m.move_date) FILTER (WHERE m.qty > 0) AS first_in,
                      STRING_AGG(DISTINCT NULLIF(m.location, ''), ', ') AS location
               FROM fg_moves m GROUP BY m.product_id, COALESCE(m.batch_code, '')'''


def init_fg(db):
    with db() as connection, connection.cursor() as cursor:
        cursor.execute('SELECT pg_advisory_xact_lock(%s)', (LOCK_ID,))
        cursor.execute('''CREATE TABLE IF NOT EXISTS fg_docs (
            id BIGSERIAL PRIMARY KEY, number TEXT NOT NULL UNIQUE, doc_type TEXT NOT NULL CHECK (doc_type IN ('WZ','ZW','INW')),
            client_id BIGINT REFERENCES clients(id) ON DELETE RESTRICT, zk_order_id BIGINT REFERENCES orders(id) ON DELETE SET NULL,
            doc_date DATE NOT NULL DEFAULT CURRENT_DATE, status TEXT NOT NULL DEFAULT 'OTWARTY', carrier TEXT, vehicle TEXT,
            delivery_address TEXT, reason TEXT, notes TEXT, created_by TEXT, realized_by TEXT, realized_at TIMESTAMPTZ,
            created_at TIMESTAMPTZ NOT NULL DEFAULT NOW())''')
        cursor.execute('''CREATE TABLE IF NOT EXISTS fg_doc_lines (
            id BIGSERIAL PRIMARY KEY, doc_id BIGINT NOT NULL REFERENCES fg_docs(id) ON DELETE CASCADE,
            product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE RESTRICT, order_line_id BIGINT REFERENCES order_lines(id) ON DELETE SET NULL,
            batch_code TEXT, location TEXT, qty INTEGER, expected INTEGER, cartons INTEGER, notes TEXT)''')
        cursor.execute('''CREATE TABLE IF NOT EXISTS fg_moves (
            id BIGSERIAL PRIMARY KEY, move_date DATE NOT NULL, move_type TEXT NOT NULL CHECK (move_type IN ('PW','WZ','ZW','KOR')),
            product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE RESTRICT, qty INTEGER NOT NULL CHECK (qty <> 0),
            batch_code TEXT, location TEXT, doc_id BIGINT REFERENCES fg_docs(id) ON DELETE CASCADE,
            prod_receipt_id BIGINT UNIQUE REFERENCES prod_receipts(id) ON DELETE CASCADE,
            order_line_id BIGINT REFERENCES order_lines(id) ON DELETE SET NULL, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW())''')
        cursor.execute('CREATE INDEX IF NOT EXISTS fg_moves_product_idx ON fg_moves(product_id, batch_code)')
        cursor.execute('CREATE INDEX IF NOT EXISTS fg_moves_line_idx ON fg_moves(order_line_id)')
        cursor.execute('CREATE INDEX IF NOT EXISTS fg_doc_lines_doc_idx ON fg_doc_lines(doc_id)')
        cursor.execute('ALTER TABLE prod_receipts ADD COLUMN IF NOT EXISTS location TEXT')
        cursor.execute('ALTER TABLE fg_docs DROP CONSTRAINT IF EXISTS fg_docs_doc_type_check')
        cursor.execute("ALTER TABLE fg_docs ADD CONSTRAINT fg_docs_doc_type_check CHECK (doc_type IN ('PW','WZ','ZW','INW'))")
        # PW przyjęte przed uruchomieniem magazynu wyrobów → ruchy w kartotece
        cursor.execute('''INSERT INTO fg_moves (move_date, move_type, product_id, qty, batch_code, location, prod_receipt_id)
                          SELECT r.receipt_date, 'PW', pc.product_id, r.qty, po.batch_code, r.location, r.id
                          FROM prod_receipts r JOIN prod_colors pc ON pc.id = r.prod_color_id JOIN prod_orders po ON po.id = pc.prod_order_id
                          WHERE pc.product_id IS NOT NULL ON CONFLICT (prod_receipt_id) DO NOTHING''')


# --- wywoływane z rozliczenia produkcji ------------------------------------------------------

def ensure_product(cursor, order, color):
    """Kolor bez wariantu produktu → znajdź albo załóż produkt (BBBB) „PRODUKT KOLOR” u klienta (nowa para klient–produkt)."""
    if color['product_id']:
        return color['product_id']
    name = f'{order["product_name"]} {color["color_name"]}'.strip()
    cursor.execute('SELECT id FROM products WHERE client_id = %s AND UPPER(name) = UPPER(%s)', (order['client_id'], name))
    row = cursor.fetchone()
    if row is None:
        cursor.execute('SELECT COALESCE(MAX(code), 0) + 1 AS code FROM products')
        code = cursor.fetchone()['code']
        cursor.execute('''INSERT INTO products (code, client_id, name, color_id, colorant_id, colorant_pct, mold_id, mold_match, material_id,
                                                net_g, cavities, per_shift, pcs_per_carton, carton_type, carton_kg, machines, notes)
                          VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) RETURNING id''',
                       (code, order['client_id'], name, color['color_id'], color['colorant_id'], color['dosage_pct'], order['mold_id'],
                        'POTWIERDZONA' if order['mold_id'] else None, order['material_id'], color['net_g'] or order['net_g'], order['cavities'],
                        order['per_shift'], order['pcs_per_carton'], order['carton_type'], order['carton_kg'],
                        str(order['machine_no'] or ''), f'Założony automatycznie przy przyjęciu PW z zamówienia {order["number"]}'))
        row = cursor.fetchone()
        flash(f'Założono produkt {code:04d} {name} (nowa para klient–produkt).', 'success')
    cursor.execute('UPDATE prod_colors SET product_id = %s WHERE id = %s', (row['id'], color['id']))
    cursor.execute('UPDATE productions SET product_id = %s WHERE prod_color_id = %s AND product_id IS NULL', (row['id'], color['id']))
    return row['id']


def register_pw(cursor, receipt_id, order, color, day, qty, location):
    product_id = ensure_product(cursor, order, color)
    cursor.execute('''INSERT INTO fg_moves (move_date, move_type, product_id, qty, batch_code, location, prod_receipt_id)
                      VALUES (%s, 'PW', %s, %s, %s, %s, %s)''', (day, product_id, qty, order['batch_code'], location, receipt_id))


def check_pw_delete(cursor, receipt_id):
    """Nie pozwól usunąć PW, jeśli towar z tej szarży już wydano (stan zszedłby poniżej zera)."""
    cursor.execute('SELECT product_id, COALESCE(batch_code, \'\') AS batch, qty FROM fg_moves WHERE prod_receipt_id = %s', (receipt_id,))
    move = cursor.fetchone()
    if move is None:
        return
    cursor.execute("SELECT COALESCE(SUM(qty), 0) AS qty FROM fg_moves WHERE product_id = %s AND COALESCE(batch_code, '') = %s",
                   (move['product_id'], move['batch']))
    if cursor.fetchone()['qty'] - move['qty'] < 0:
        raise ValueError('Z tego przyjęcia część towaru została już wydana (WZ) — PW nie można usunąć. Zrób korektę inwentaryzacyjną.')


# --- pomocnicze -------------------------------------------------------------------------------

def next_number(cursor, doc_type, year):
    prefix = DOC_TYPES[doc_type]['prefix']
    cursor.execute("SELECT COALESCE(MAX(CAST(SPLIT_PART(number, '/', 3) AS INTEGER)), 0) + 1 AS n FROM fg_docs WHERE number LIKE %s",
                   (f'{prefix}/{year}/%',))
    return f'{prefix}/{year}/{cursor.fetchone()["n"]:03d}'


def stock_batches(cursor, product_id):
    cursor.execute(f'SELECT * FROM ({STOCK_SQL}) s WHERE s.product_id = %s AND s.qty > 0 ORDER BY s.first_in NULLS LAST, s.batch_code',
                   (product_id,))
    return cursor.fetchall()


def shipped_by_line(cursor, line_ids):
    if not line_ids:
        return {}
    cursor.execute("SELECT order_line_id, -SUM(qty) AS qty FROM fg_moves WHERE order_line_id = ANY(%s) AND move_type IN ('WZ','ZW') GROUP BY order_line_id",
                   (line_ids,))
    return {r['order_line_id']: int(r['qty']) for r in cursor.fetchall()}


def allocate_fifo(cursor, product_id, qty, taken):
    """Podział ilości na szarże od najstarszej; taken = już przydzielone w tym dokumencie {(produkt, szarża): szt}."""
    parts = []
    for b in stock_batches(cursor, product_id):
        free = int(b['qty']) - taken.get((product_id, b['batch_code']), 0)
        if free <= 0 or qty <= 0:
            continue
        use = min(free, qty)
        parts.append((b['batch_code'] or None, use, b['location']))
        taken[(product_id, b['batch_code'])] = taken.get((product_id, b['batch_code']), 0) + use
        qty -= use
    if qty > 0:
        parts.append((None, qty, None))  # brak towaru — pozycja do uzupełnienia
    return parts


DOC_SQL = '''SELECT d.*, c.short_name, c.name AS client_name, c.code AS client_code, c.email AS client_email, c.street, c.postal_code, c.city,
                    o.number AS zk_number, o.client_ref, o.ordered_email
             FROM fg_docs d LEFT JOIN clients c ON c.id = d.client_id LEFT JOIN orders o ON o.id = d.zk_order_id'''
LINES_SQL = '''SELECT l.*, p.code AS product_code, p.name AS product_name, p.pcs_per_carton, col.code AS color_code, c.code AS client_code,
                      ol.qty AS ordered_qty
               FROM fg_doc_lines l JOIN products p ON p.id = l.product_id JOIN clients c ON c.id = p.client_id
               LEFT JOIN colors col ON col.id = p.color_id LEFT JOIN order_lines ol ON ol.id = l.order_line_id'''


def register_fg_routes(app, db):
    app.jinja_env.globals.update(fg_doc_types=DOC_TYPES, fg_move_labels=MOVE_LABELS, fg_return_reasons=RETURN_REASONS)

    # ---------- stan magazynu ----------
    @app.get('/magazyn-wyrobow')
    @auth
    def fg_stock():
        query, client_id, show = request.args.get('q', '').strip(), request.args.get('klient', ''), request.args.get('pokaz', '')
        sql = f'''SELECT p.id, p.code, p.name, p.pcs_per_carton, c.id AS client_id, c.code AS client_code, c.short_name, col.code AS color_code,
                         COALESCE(st.qty, 0) AS qty, st.batches, st.location, st.last_move,
                         COALESCE(dm.demand, 0) AS demand
                  FROM products p JOIN clients c ON c.id = p.client_id LEFT JOIN colors col ON col.id = p.color_id
                  LEFT JOIN (SELECT product_id, SUM(qty) AS qty, COUNT(*) FILTER (WHERE qty > 0) AS batches,
                                    STRING_AGG(DISTINCT location, ', ') AS location, MAX(first_in) AS last_move
                             FROM ({STOCK_SQL}) s GROUP BY product_id) st ON st.product_id = p.id
                  LEFT JOIN (SELECT l.product_id, SUM(GREATEST(l.qty - COALESCE(sh.qty, 0), 0)) AS demand
                             FROM order_lines l JOIN orders o ON o.id = l.order_id
                             LEFT JOIN (SELECT order_line_id, -SUM(qty) AS qty FROM fg_moves WHERE order_line_id IS NOT NULL GROUP BY order_line_id) sh
                                    ON sh.order_line_id = l.id
                             WHERE o.status IN ('PRZYJĘTE', 'W PRODUKCJI') GROUP BY l.product_id) dm ON dm.product_id = p.id
                  WHERE TRUE'''
        params = []
        if show != 'wszystkie':
            sql += ' AND (COALESCE(st.qty, 0) <> 0 OR COALESCE(dm.demand, 0) > 0)'
        if query:
            sql += " AND (p.name ILIKE %s OR LPAD(p.code::text, 4, '0') = %s OR st.location ILIKE %s)"
            params += [f'%{query}%', query.zfill(4), f'%{query}%']
        if client_id.isdigit():
            sql += ' AND p.client_id = %s'; params.append(int(client_id))
        sql += ' ORDER BY c.short_name, p.name LIMIT 1000'
        with db() as connection, connection.cursor() as cursor:
            cursor.execute(sql, params)
            items = cursor.fetchall()
            cursor.execute('SELECT id, short_name FROM clients ORDER BY short_name')
            clients = cursor.fetchall()
            cursor.execute(f'''SELECT COALESCE(SUM(qty) FILTER (WHERE qty > 0), 0) AS pcs, COUNT(DISTINCT product_id) FILTER (WHERE qty > 0) AS products,
                                      COUNT(*) FILTER (WHERE qty > 0) AS batches, COUNT(*) FILTER (WHERE qty < 0) AS negative FROM ({STOCK_SQL}) s''')
            totals = cursor.fetchone()
            cursor.execute("SELECT doc_type, COUNT(*) AS n FROM fg_docs WHERE status = 'OTWARTY' GROUP BY doc_type")
            open_docs = {r['doc_type']: r['n'] for r in cursor.fetchall()}
            cursor.execute('''SELECT o.id, o.number, c.short_name, o.delivery_date FROM orders o JOIN clients c ON c.id = o.client_id
                              WHERE o.status IN ('PRZYJĘTE', 'W PRODUKCJI')
                                AND EXISTS (SELECT 1 FROM order_lines l JOIN (SELECT product_id, SUM(qty) AS q FROM fg_moves GROUP BY product_id) s
                                            ON s.product_id = l.product_id AND s.q > 0 WHERE l.order_id = o.id)
                                AND NOT EXISTS (SELECT 1 FROM fg_docs d WHERE d.zk_order_id = o.id AND d.status = 'OTWARTY')
                              ORDER BY o.delivery_date NULLS LAST LIMIT 30''')
            ready = cursor.fetchall()
        for i in items:
            i['available'] = int(i['qty']) - int(i['demand'])
            i['cartons'] = (int(i['qty']) // i['pcs_per_carton'], int(i['qty']) % i['pcs_per_carton']) if i['pcs_per_carton'] and i['qty'] > 0 else None
        return render_template('fg_stock.html', items=items, clients=clients, totals=totals, open_docs=open_docs, ready=ready,
                               query=query, client_id=client_id, show=show)

    @app.get('/magazyn-wyrobow/produkt/<int:product_id>')
    @auth
    def fg_product(product_id):
        with db() as connection, connection.cursor() as cursor:
            cursor.execute('''SELECT p.*, c.code AS client_code, c.short_name, col.code AS color_code, col.name AS color_name
                              FROM products p JOIN clients c ON c.id = p.client_id LEFT JOIN colors col ON col.id = p.color_id WHERE p.id = %s''',
                           (product_id,))
            product = cursor.fetchone() or abort(404)
            cursor.execute(f'SELECT * FROM ({STOCK_SQL}) s WHERE s.product_id = %s AND s.qty <> 0 ORDER BY s.first_in', (product_id,))
            batches = cursor.fetchall()
            cursor.execute('''SELECT m.*, d.number AS doc_number, d.doc_type, r.pw_number, pc.id AS color_id, po.number AS internal_order,
                                     o.number AS zk_number, o.id AS zk_id
                              FROM fg_moves m LEFT JOIN fg_docs d ON d.id = m.doc_id LEFT JOIN prod_receipts r ON r.id = m.prod_receipt_id
                              LEFT JOIN prod_colors pc ON pc.id = r.prod_color_id LEFT JOIN prod_orders po ON po.id = pc.prod_order_id
                              LEFT JOIN order_lines ol ON ol.id = m.order_line_id LEFT JOIN orders o ON o.id = ol.order_id
                              WHERE m.product_id = %s ORDER BY m.move_date, m.id''', (product_id,))
            moves = cursor.fetchall()
        balance = 0
        for m in moves:
            balance += m['qty']
            m['balance'] = balance
        moves.reverse()
        return render_template('fg_product.html', product=product, batches=batches, moves=moves, balance=balance)

    # ---------- dokumenty ----------
    @app.get('/magazyn-wyrobow/dokumenty')
    @auth
    def fg_docs():
        doc_type, status = request.args.get('typ', ''), request.args.get('status', '')
        sql = DOC_SQL.replace('SELECT d.*', '''SELECT d.*, (SELECT COUNT(*) FROM fg_doc_lines l WHERE l.doc_id = d.id) AS lines,
                 (SELECT COALESCE(SUM(l.qty), 0) FROM fg_doc_lines l WHERE l.doc_id = d.id) AS qty''') + ' WHERE TRUE'
        params = []
        if doc_type in DOC_TYPES:
            sql += ' AND d.doc_type = %s'; params.append(doc_type)
        if status in ('OTWARTY', 'ZREALIZOWANY'):
            sql += ' AND d.status = %s'; params.append(status)
        sql += ' ORDER BY d.doc_date DESC, d.id DESC LIMIT 400'
        with db() as connection, connection.cursor() as cursor:
            cursor.execute(sql, params)
            docs = cursor.fetchall()
            cursor.execute('''SELECT m.move_date, m.qty, m.batch_code, m.location, r.pw_number, p.code, p.name, c.short_name, pc.id AS color_id
                              FROM fg_moves m JOIN prod_receipts r ON r.id = m.prod_receipt_id JOIN products p ON p.id = m.product_id
                              JOIN clients c ON c.id = p.client_id JOIN prod_colors pc ON pc.id = r.prod_color_id
                              ORDER BY m.move_date DESC, m.id DESC LIMIT 50''')
            pw = cursor.fetchall()
            cursor.execute('SELECT id, short_name, code FROM clients ORDER BY short_name')
            clients = cursor.fetchall()
        return render_template('fg_docs.html', docs=docs, pw=pw, clients=clients, doc_type=doc_type, status=status, today=date.today())

    @app.post('/magazyn-wyrobow/dokumenty/nowy')
    @auth
    def fg_doc_new():
        require_csrf()
        form = request.form
        doc_type = form.get('doc_type', '')
        if doc_type not in DOC_TYPES or doc_type == 'PW':  # PW powstaje przy przyjęciu z produkcji, nie ręcznie
            abort(400)
        with db() as connection, connection.cursor() as cursor:
            cursor.execute('SELECT pg_advisory_xact_lock(%s)', (LOCK_ID,))
            zk = None
            client_id = int(form['client_id']) if form.get('client_id', '').isdigit() else None
            if form.get('zk', '').isdigit():
                cursor.execute('SELECT * FROM orders WHERE id = %s', (int(form['zk']),))
                zk = cursor.fetchone() or abort(404)
                client_id = zk['client_id']
            if doc_type in ('WZ', 'ZW') and not client_id:
                flash('Wybierz klienta.', 'error')
                return redirect(url_for('fg_docs'))
            number = next_number(cursor, doc_type, date.today().year)
            address = None
            if client_id:
                cursor.execute('SELECT street, postal_code, city FROM clients WHERE id = %s', (client_id,))
                c = cursor.fetchone()
                address = ', '.join(x for x in (c['street'], f'{c["postal_code"] or ""} {c["city"] or ""}'.strip()) if x)
            cursor.execute('''INSERT INTO fg_docs (number, doc_type, client_id, zk_order_id, delivery_address) VALUES (%s,%s,%s,%s,%s) RETURNING id''',
                           (number, doc_type, client_id, zk and zk['id'], address))
            doc_id = cursor.fetchone()['id']
            if doc_type == 'WZ' and zk:
                cursor.execute('SELECT id, product_id, qty FROM order_lines WHERE order_id = %s AND product_id IS NOT NULL ORDER BY lp', (zk['id'],))
                lines = cursor.fetchall()
                shipped = shipped_by_line(cursor, [l['id'] for l in lines])
                taken, added = {}, 0
                for l in lines:
                    rest = int(l['qty'] or 0) - shipped.get(l['id'], 0)
                    if rest <= 0:
                        continue
                    for batch, qty, location in allocate_fifo(cursor, l['product_id'], rest, taken):
                        cursor.execute('''INSERT INTO fg_doc_lines (doc_id, product_id, order_line_id, batch_code, location, qty)
                                          VALUES (%s,%s,%s,%s,%s,%s)''', (doc_id, l['product_id'], l['id'], batch, location, qty))
                        added += 1
                flash(f'Utworzono {number} z zamówienia {zk["number"]}: {added} poz., szarże dobrane od najstarszej (FIFO).', 'success')
            elif doc_type == 'INW':
                cursor.execute(f'SELECT * FROM ({STOCK_SQL}) s WHERE s.qty <> 0 ORDER BY s.product_id, s.first_in')
                for s in cursor.fetchall():
                    cursor.execute('''INSERT INTO fg_doc_lines (doc_id, product_id, batch_code, location, expected) VALUES (%s,%s,%s,%s,%s)''',
                                   (doc_id, s['product_id'], s['batch_code'] or None, s['location'], int(s['qty'])))
                flash(f'Utworzono arkusz {number} z bieżącym stanem — wpisz ilości policzone.', 'success')
            else:
                flash(f'Utworzono dokument {number}. Dodaj pozycje.', 'success')
        return redirect(url_for('fg_doc', doc_id=doc_id))

    def load_doc(cursor, doc_id):
        cursor.execute(DOC_SQL + ' WHERE d.id = %s', (doc_id,))
        doc = cursor.fetchone()
        if doc is None:
            abort(404)
        cursor.execute(LINES_SQL + ' WHERE l.doc_id = %s ORDER BY p.name, l.batch_code NULLS LAST, l.id', (doc_id,))
        lines = cursor.fetchall()
        cursor.execute(f'SELECT * FROM ({STOCK_SQL}) s WHERE s.product_id = ANY(%s)', ([l['product_id'] for l in lines],))
        stock = {(s['product_id'], s['batch_code']): int(s['qty']) for s in cursor.fetchall()}
        for l in lines:
            l['stock'] = stock.get((l['product_id'], l['batch_code'] or ''))
            l['stock_total'] = sum(q for (p, _), q in stock.items() if p == l['product_id'])
            l['production_code'] = f'{l["client_code"]}-{l["product_code"]:04d}-{l["color_code"] or "000"}'
        return doc, lines

    @app.get('/magazyn-wyrobow/dokument/<int:doc_id>')
    @auth
    def fg_doc(doc_id):
        with db() as connection, connection.cursor() as cursor:
            doc, lines = load_doc(cursor, doc_id)
            products, zk_lines = [], []
            if doc['status'] == 'OTWARTY':
                cursor.execute(f'''SELECT p.id, p.code, p.name, COALESCE(s.qty, 0) AS qty FROM products p
                                   LEFT JOIN (SELECT product_id, SUM(qty) AS qty FROM ({STOCK_SQL}) x GROUP BY product_id) s ON s.product_id = p.id
                                   WHERE (%s::bigint IS NULL OR p.client_id = %s) ORDER BY p.name''', (doc['client_id'], doc['client_id']))
                products = cursor.fetchall()
            if doc['zk_order_id']:
                cursor.execute('''SELECT l.id, l.lp, l.product_name, l.qty, l.product_id FROM order_lines l WHERE l.order_id = %s ORDER BY l.lp''',
                               (doc['zk_order_id'],))
                zk_lines = cursor.fetchall()
                shipped = shipped_by_line(cursor, [l['id'] for l in zk_lines])
                for l in zk_lines:
                    l['shipped'] = shipped.get(l['id'], 0)
                    l['in_doc'] = sum(x['qty'] or 0 for x in lines if x['order_line_id'] == l['id'])
        meta = DOC_TYPES[doc['doc_type']]
        totals = {'qty': sum(l['qty'] or 0 for l in lines), 'expected': sum(l['expected'] or 0 for l in lines),
                  'diff': sum((l['qty'] - l['expected']) for l in lines if l['qty'] is not None and l['expected'] is not None)}
        mail = None
        if doc['doc_type'] == 'WZ' and doc['status'] == 'ZREALIZOWANY':
            items = '\n'.join(f'  {l["product_name"]} — {l["qty"]} szt.' + (f' (szarża {l["batch_code"]})' if l['batch_code'] else '')
                              for l in lines if l['qty'])
            ref = f' do zamówienia {doc["zk_number"]}' if doc['zk_number'] else ''
            if doc['zk_number'] and doc['client_ref']:
                ref += f' (Państwa nr {doc["client_ref"]})'
            body = (f'Dzień dobry,\n\ninformujemy, że wydaliśmy towar dokumentem {doc["number"]} z dnia {doc["doc_date"]:%d.%m.%Y}{ref}.\n\n'
                    f'{items}\n\nPrzewoźnik: {doc["carrier"] or "—"}\n\nPozdrawiamy,\nPLASTEMA')
            mail = (f'mailto:{quote(doc["ordered_email"] or doc["client_email"] or "")}'
                    f'?subject={quote("Wysyłka " + (doc["zk_number"] or doc["number"]))}&body={quote(body)}')
        return render_template('fg_doc.html', doc=doc, lines=lines, meta=meta, products=products, zk_lines=zk_lines, totals=totals,
                               mail=mail, today=date.today())

    @app.post('/magazyn-wyrobow/dokument/<int:doc_id>')
    @auth
    def fg_doc_save(doc_id):
        require_csrf()
        form, action = request.form, request.form.get('action', 'save')
        with db() as connection, connection.cursor() as cursor:
            cursor.execute('SELECT pg_advisory_xact_lock(%s)', (LOCK_ID,))
            doc, lines = load_doc(cursor, doc_id)
            try:
                if doc['status'] != 'OTWARTY':
                    raise ValueError('Zrealizowanego dokumentu nie można zmieniać.')
                if action == 'delete':
                    cursor.execute('DELETE FROM fg_docs WHERE id = %s', (doc_id,))
                    flash(f'Usunięto dokument {doc["number"]}.', 'success')
                    return redirect(url_for('fg_docs'))
                cursor.execute('''UPDATE fg_docs SET doc_date = %s, carrier = %s, vehicle = %s, delivery_address = %s, reason = %s, notes = %s,
                                  created_by = %s WHERE id = %s''',
                               (to_date(form.get('doc_date'), 'Data', required=True), clean(form.get('carrier')), clean(form.get('vehicle')),
                                clean(form.get('delivery_address')), clean(form.get('reason')), form.get('notes', '').strip(),
                                clean(form.get('created_by')), doc_id))
                for l in lines:
                    key = str(l['id'])
                    if f'qty_{key}' not in form:
                        continue
                    qty = to_int(form.get(f'qty_{key}'), f'{l["product_name"]} — ilość', minimum=0)
                    keep = lambda field, current: (clean(form.get(f'{field}_{key}')) or None) if f'{field}_{key}' in form else current
                    cartons = to_int(form.get(f'cartons_{key}'), 'Kartony', minimum=0) if f'cartons_{key}' in form else l['cartons']
                    cursor.execute('UPDATE fg_doc_lines SET qty = %s, cartons = %s, batch_code = %s, location = %s, notes = %s WHERE id = %s',
                                   (qty, cartons, keep('batch', l['batch_code']), keep('location', l['location']), keep('note', l['notes']), l['id']))
                if action.startswith('delete_line:'):
                    cursor.execute('DELETE FROM fg_doc_lines WHERE id = %s AND doc_id = %s', (int(action.split(':')[1]), doc_id))
                    flash('Usunięto pozycję.', 'success')
                elif action == 'add_line':
                    add_line(cursor, doc, form)
                elif action == 'realize':
                    realize(cursor, doc_id, form)
                    return redirect(url_for('fg_doc', doc_id=doc_id))
                else:
                    flash('Zapisano dokument.', 'success')
            except ValueError as error:
                connection.rollback()
                flash(str(error), 'error')
        return redirect(url_for('fg_doc', doc_id=doc_id))

    def add_line(cursor, doc, form):
        text = clean(form.get('add_product'))
        code = text.split()[0] if text else ''
        if not code.isdigit():
            raise ValueError('Wybierz produkt z podpowiedzi.')
        cursor.execute('SELECT id, name FROM products WHERE code = %s AND (%s::bigint IS NULL OR client_id = %s)',
                       (int(code), doc['client_id'], doc['client_id']))
        product = cursor.fetchone()
        if product is None:
            raise ValueError(f'Nie znaleziono produktu „{text}”' + (' u tego klienta.' if doc['client_id'] else '.'))
        qty = to_int(form.get('add_qty'), 'Ilość', minimum=1)
        batch = clean(form.get('add_batch')) or None
        order_line = int(form['add_order_line']) if form.get('add_order_line', '').isdigit() else None
        if doc['doc_type'] == 'WZ' and not batch:
            parts = allocate_fifo(cursor, product['id'], qty or 0, {}) if qty else [(None, None, None)]
        else:
            parts = [(batch, qty, clean(form.get('add_location')) or None)]
        for b, q, loc in parts:
            if doc['doc_type'] == 'INW':
                cursor.execute('INSERT INTO fg_doc_lines (doc_id, product_id, batch_code, location, expected, qty) VALUES (%s,%s,%s,%s,0,%s)',
                               (doc['id'], product['id'], b, loc, q))
            else:
                cursor.execute('INSERT INTO fg_doc_lines (doc_id, product_id, order_line_id, batch_code, location, qty) VALUES (%s,%s,%s,%s,%s,%s)',
                               (doc['id'], product['id'], order_line, b, loc, q))
        flash(f'Dodano {product["name"]}.', 'success')

    def realize(cursor, doc_id, form):
        doc, lines = load_doc(cursor, doc_id)
        person = clean(form.get('realized_by'))
        if not person:
            raise ValueError('Podaj, kto realizuje dokument (imię i nazwisko).')
        meta = DOC_TYPES[doc['doc_type']]
        moves = []
        if doc['doc_type'] == 'INW':
            cursor.execute(f'SELECT * FROM ({STOCK_SQL}) s')
            stock = {(s['product_id'], s['batch_code']): int(s['qty']) for s in cursor.fetchall()}
            for l in lines:
                if l['qty'] is None:
                    continue
                diff = l['qty'] - stock.get((l['product_id'], l['batch_code'] or ''), 0)
                if diff:
                    moves.append((l, diff))
            if not any(l['qty'] is not None for l in lines):
                raise ValueError('Arkusz nie ma żadnej policzonej pozycji.')
        else:
            filled = [l for l in lines if l['qty']]
            if not filled:
                raise ValueError('Dokument nie ma pozycji z ilością.')
            if doc['doc_type'] == 'WZ':
                need = {}
                for l in filled:
                    need[(l['product_id'], l['batch_code'] or '')] = need.get((l['product_id'], l['batch_code'] or ''), 0) + l['qty']
                cursor.execute(f'SELECT * FROM ({STOCK_SQL}) s')
                stock = {(s['product_id'], s['batch_code']): int(s['qty']) for s in cursor.fetchall()}
                short = []
                for (pid, batch), qty in need.items():
                    have = stock.get((pid, batch), 0)
                    if have < qty:
                        name = next(l['product_name'] for l in filled if l['product_id'] == pid)
                        short.append(f'{name}{" szarża " + batch if batch else " (bez szarży)"}: na stanie {have}, na WZ {qty}')
                if short:
                    raise ValueError('Za mało towaru na magazynie — ' + '; '.join(short) + '. Zmień szarżę albo ilość.')
            for l in filled:
                moves.append((l, meta['sign'] * l['qty']))
        for l, qty in moves:
            cursor.execute('''INSERT INTO fg_moves (move_date, move_type, product_id, qty, batch_code, location, doc_id, order_line_id)
                              VALUES (%s,%s,%s,%s,%s,%s,%s,%s)''',
                           (doc['doc_date'], meta['move'], l['product_id'], qty, l['batch_code'], l['location'], doc_id, l['order_line_id']))
        cursor.execute("UPDATE fg_docs SET status = 'ZREALIZOWANY', realized_by = %s, realized_at = NOW() WHERE id = %s", (person, doc_id))
        message = f'Zrealizowano {doc["number"]}: {len(moves)} ruchów w kartotece.'
        if doc['doc_type'] == 'WZ' and doc['zk_order_id']:
            cursor.execute('SELECT id, qty FROM order_lines WHERE order_id = %s AND product_id IS NOT NULL', (doc['zk_order_id'],))
            zk_lines = cursor.fetchall()
            shipped = shipped_by_line(cursor, [l['id'] for l in zk_lines])
            if zk_lines and all(shipped.get(l['id'], 0) >= (l['qty'] or 0) for l in zk_lines):
                cursor.execute("UPDATE orders SET status = 'ZREALIZOWANE', finished_at = NOW() WHERE id = %s AND status IN ('PRZYJĘTE','W PRODUKCJI')",
                               (doc['zk_order_id'],))
                message += f' Zamówienie {doc["zk_number"]} wydane w całości — status ZREALIZOWANE.'
            else:
                message += f' Zamówienie {doc["zk_number"]} wydane częściowo.'
        flash(message, 'success')
