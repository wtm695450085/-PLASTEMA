from datetime import date, timedelta
from decimal import Decimal

from flask import abort, flash, redirect, render_template, request, url_for

from inventory import CURRENT_STOCK_SQL, as_qty
from materials import auth, clean, require_csrf

MACHINE_COUNT = 9
SECTIONS = (('SS', 'SUROWIEC SYPKI', 'Tworzywa'), ('BT', 'BARWNIK TWORZYWA', 'Barwniki'))
LOCK_ID = 6102029

# Typy dokumentów pola odkładczego. source: skąd bierze się dostępna ilość (magazyn główny / pole maszyny).
DOC_TYPES = {
    'WYDANIE': {'slug': 'wydanie', 'prefix': 'WM', 'source': 'main', 'label': 'Wydanie na maszynę',
                'button': 'Wydaj surowiec na maszynę', 'done': 'Zrealizowano',
                'hint': 'Surowiec z magazynu głównego, który magazynier przenosi na pole odkładcze maszyny przed produkcją.'},
    'UZUPELNIENIE': {'slug': 'uzupelnienie', 'prefix': 'UZ', 'source': 'main', 'label': 'Uzupełnienie pola odkładczego',
                     'button': 'Uzupełnij pole odkładcze', 'done': 'Zrealizowano',
                     'hint': 'Dodatkowy surowiec w trakcie produkcji, gdy pole odkładcze opróżniło się za szybko (np. z powodu braków).'},
    'ZUZYCIE': {'slug': 'zuzycie', 'prefix': 'ZU', 'source': 'machine', 'label': 'Zużycie surowca',
                'button': 'Zapisz zużycie', 'done': 'Zapisz zużycie',
                'hint': 'Ilość surowca faktycznie zużyta w produkcji. To, co zostanie na polu, trzeba zwrócić do magazynu głównego.'},
    'ZWROT': {'slug': 'zwrot', 'prefix': 'ZW', 'source': 'machine', 'label': 'Zwrot niezużytego do magazynu',
              'button': 'Zwrot niezużytego do magazynu', 'done': 'Przyjęto na magazyn główny',
              'hint': 'Niezużyty surowiec wraca z pola odkładczego do magazynu głównego po zakończeniu szarży.'},
}
SLUGS = {v['slug']: k for k, v in DOC_TYPES.items()}
REFILL_REASONS = {
    'BRAKI': 'Braki / odpad w produkcji',
    'SZYBSZE_ZUZYCIE': 'Szybsze zużycie niż w planie',
    'BLAD_WYDANIA': 'Za mało wydano z magazynu',
    'ZMIANA_PLANU': 'Zmiana planu produkcji',
    'INNY': 'Inny powód (opisz w uwagach)',
}

# Ilość na polu odkładczym: wydania i uzupełnienia dodają, zużycie i zwroty odejmują (tylko dokumenty zrealizowane).
MACHINE_STOCK_SQL = '''
SELECT d.machine_id, l.material_id,
       SUM(CASE WHEN d.doc_type IN ('WYDANIE','UZUPELNIENIE') THEN l.qty_kg ELSE -l.qty_kg END) AS kg
FROM machine_doc_lines l JOIN machine_docs d ON d.id = l.doc_id
WHERE d.status = 'ZREALIZOWANY' GROUP BY d.machine_id, l.material_id'''


def init_machines(db):
    with db() as connection, connection.cursor() as cursor:
        cursor.execute('SELECT pg_advisory_xact_lock(%s)', (LOCK_ID,))
        cursor.execute('CREATE TABLE IF NOT EXISTS machines (id SMALLINT PRIMARY KEY, name TEXT NOT NULL)')
        cursor.execute("INSERT INTO machines (id, name) SELECT g, 'Maszyna ' || g FROM generate_series(1, %s) g ON CONFLICT DO NOTHING", (MACHINE_COUNT,))
        cursor.execute('''CREATE TABLE IF NOT EXISTS machine_docs (
            id BIGSERIAL PRIMARY KEY, number TEXT NOT NULL UNIQUE, doc_type TEXT NOT NULL,
            machine_id SMALLINT NOT NULL REFERENCES machines(id), status TEXT NOT NULL DEFAULT 'OTWARTY',
            doc_date DATE NOT NULL DEFAULT CURRENT_DATE, shift TEXT, order_ref TEXT, reason TEXT, notes TEXT,
            created_by TEXT, realized_by TEXT, realized_at TIMESTAMPTZ, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW())''')
        cursor.execute('''CREATE TABLE IF NOT EXISTS machine_doc_lines (
            id BIGSERIAL PRIMARY KEY, doc_id BIGINT NOT NULL REFERENCES machine_docs(id) ON DELETE CASCADE,
            material_id BIGINT NOT NULL REFERENCES materials(id) ON DELETE RESTRICT,
            qty_kg NUMERIC(14,3) NOT NULL DEFAULT 0 CHECK (qty_kg >= 0), notes TEXT,
            UNIQUE (doc_id, material_id))''')
        cursor.execute('CREATE INDEX IF NOT EXISTS machine_docs_machine_idx ON machine_docs(machine_id, status)')
        cursor.execute('CREATE INDEX IF NOT EXISTS machine_doc_lines_material_idx ON machine_doc_lines(material_id)')


def next_doc_number(cursor, prefix, year):
    cursor.execute("SELECT COALESCE(MAX(CAST(SPLIT_PART(number,'/',3) AS INTEGER)),0)+1 AS n FROM machine_docs WHERE number LIKE %s", (f'{prefix}/{year}/%',))
    return f'{prefix}/{year}/{cursor.fetchone()["n"]:03d}'


def machine_stock(cursor, machine_id):
    cursor.execute(f'SELECT material_id, kg FROM ({MACHINE_STOCK_SQL}) s WHERE machine_id=%s AND kg<>0', (machine_id,))
    return {row['material_id']: row['kg'] for row in cursor.fetchall()}


def main_stock(cursor, material_ids):
    if not material_ids:
        return {}
    cursor.execute(f'SELECT material_id, current_kg FROM ({CURRENT_STOCK_SQL}) cs WHERE material_id = ANY(%s)', (list(material_ids),))
    return {row['material_id']: row['current_kg'] for row in cursor.fetchall()}


def register_machine_routes(app, db):
    app.jinja_env.globals.update(doc_types=DOC_TYPES, refill_reasons=REFILL_REASONS, machine_count=MACHINE_COUNT)

    def get_machine(machine_id):
        if not 1 <= machine_id <= MACHINE_COUNT:
            abort(404)
        with db() as connection, connection.cursor() as cursor:
            cursor.execute('SELECT * FROM machines WHERE id=%s', (machine_id,))
            machine = cursor.fetchone()
        if machine is None:
            abort(404)
        return machine

    @app.get('/maszyny')
    @auth
    def machines_index():
        with db() as connection, connection.cursor() as cursor:
            cursor.execute(f'''SELECT mc.id, mc.name, COUNT(DISTINCT s.material_id) FILTER (WHERE s.kg > 0) AS items,
                    COALESCE(SUM(s.kg) FILTER (WHERE s.kg > 0), 0) AS kg,
                    COALESCE(SUM(s.kg * COALESCE(mat.price_pln, 0)) FILTER (WHERE s.kg > 0), 0) AS value
                FROM machines mc LEFT JOIN ({MACHINE_STOCK_SQL}) s ON s.machine_id = mc.id
                LEFT JOIN materials mat ON mat.id = s.material_id GROUP BY mc.id ORDER BY mc.id''')
            machines = cursor.fetchall()
            cursor.execute(f'''SELECT s.machine_id, mat.material_index, mat.internal_name, mat.symbol, s.kg
                FROM ({MACHINE_STOCK_SQL}) s JOIN materials mat ON mat.id = s.material_id WHERE s.kg > 0
                ORDER BY s.machine_id, s.kg DESC''')
            top = {}
            for row in cursor.fetchall():
                top.setdefault(row['machine_id'], []).append(row)
            cursor.execute('''SELECT d.*, COUNT(l.id) AS lines, COALESCE(SUM(l.qty_kg), 0) AS kg
                FROM machine_docs d LEFT JOIN machine_doc_lines l ON l.doc_id = d.id
                WHERE d.status = 'OTWARTY' GROUP BY d.id ORDER BY d.created_at''')
            open_docs = cursor.fetchall()
        open_by_machine = {}
        for doc in open_docs:
            open_by_machine[doc['machine_id']] = open_by_machine.get(doc['machine_id'], 0) + 1
        for machine in machines:
            machine['top'] = top.get(machine['id'], [])[:3]
            machine['more'] = max(0, len(top.get(machine['id'], [])) - 3)
            machine['open_docs'] = open_by_machine.get(machine['id'], 0)
        return render_template('machines.html', machines=machines, open_docs=open_docs)

    @app.get('/maszyny/<int:machine_id>')
    @auth
    def machine_detail(machine_id):
        machine = get_machine(machine_id)
        with db() as connection, connection.cursor() as cursor:
            cursor.execute(f'''SELECT s.kg, mat.id, mat.material_index, mat.internal_name, mat.symbol, mat.color,
                    COALESCE(mat.supplier_short_name, mat.supplier_name) AS supplier, COALESCE(mat.price_pln, 0) AS price
                FROM ({MACHINE_STOCK_SQL}) s JOIN materials mat ON mat.id = s.material_id
                WHERE s.machine_id = %s AND s.kg <> 0 ORDER BY mat.material_index''', (machine_id,))
            stock = cursor.fetchall()
            cursor.execute('''SELECT d.*, COUNT(l.id) AS lines, COALESCE(SUM(l.qty_kg), 0) AS kg
                FROM machine_docs d LEFT JOIN machine_doc_lines l ON l.doc_id = d.id
                WHERE d.machine_id = %s GROUP BY d.id ORDER BY d.created_at DESC LIMIT 40''', (machine_id,))
            docs = cursor.fetchall()
        return render_template('machine_detail.html', machine=machine, stock=stock, docs=docs,
                               open_docs=[d for d in docs if d['status'] == 'OTWARTY'],
                               total_kg=sum(r['kg'] for r in stock), total_value=sum(r['kg'] * r['price'] for r in stock))

    @app.post('/maszyny/<int:machine_id>/dokument/<slug>')
    @auth
    def create_machine_doc(machine_id, slug):
        require_csrf()
        get_machine(machine_id)
        doc_type = SLUGS.get(slug)
        if doc_type is None:
            abort(404)
        meta = DOC_TYPES[doc_type]
        with db() as connection, connection.cursor() as cursor:
            cursor.execute('SELECT pg_advisory_xact_lock(%s)', (LOCK_ID,))
            number = next_doc_number(cursor, meta['prefix'], date.today().year)
            cursor.execute('INSERT INTO machine_docs (number, doc_type, machine_id) VALUES (%s,%s,%s) RETURNING id', (number, doc_type, machine_id))
            doc_id = cursor.fetchone()['id']
            if doc_type == 'ZWROT':
                # Zwrot niezużytego: podpowiadamy wszystko, co leży jeszcze na polu odkładczym maszyny.
                for material_id, kg in machine_stock(cursor, machine_id).items():
                    if kg > 0:
                        cursor.execute('INSERT INTO machine_doc_lines (doc_id, material_id, qty_kg) VALUES (%s,%s,%s)', (doc_id, material_id, kg))
        flash(f'Utworzono dokument {number}.', 'success')
        return redirect(url_for('machine_doc', doc_id=doc_id))

    def load_doc(cursor, doc_id):
        cursor.execute('''SELECT d.*, mc.name AS machine_name FROM machine_docs d JOIN machines mc ON mc.id = d.machine_id WHERE d.id=%s''', (doc_id,))
        doc = cursor.fetchone()
        if doc is None:
            abort(404)
        cursor.execute('''SELECT l.*, mat.material_index, mat.material_type, mat.internal_name, mat.symbol, mat.color,
                COALESCE(mat.supplier_short_name, mat.supplier_name) AS supplier
            FROM machine_doc_lines l JOIN materials mat ON mat.id = l.material_id WHERE l.doc_id=%s ORDER BY mat.material_index''', (doc_id,))
        lines = cursor.fetchall()
        ids = [l['material_id'] for l in lines]
        if DOC_TYPES[doc['doc_type']]['source'] == 'machine':
            available = machine_stock(cursor, doc['machine_id'])
        else:
            available = main_stock(cursor, ids)
        for line in lines:
            line['available'] = available.get(line['material_id'])
            line['over'] = doc['status'] == 'OTWARTY' and line['available'] is not None and line['qty_kg'] > line['available']
        return doc, lines

    @app.get('/maszyny/dokument/<int:doc_id>')
    @auth
    def machine_doc(doc_id):
        with db() as connection, connection.cursor() as cursor:
            doc, lines = load_doc(cursor, doc_id)
            if DOC_TYPES[doc['doc_type']]['source'] == 'machine':
                stock = machine_stock(cursor, doc['machine_id'])
                cursor.execute('SELECT id, material_index, internal_name, color, material_type FROM materials WHERE id = ANY(%s) ORDER BY material_index', (list(stock),))
                rows = cursor.fetchall()
                for row in rows:
                    row['kg'] = stock[row['id']]
            else:
                cursor.execute(f'''SELECT m.id, m.material_index, m.internal_name, m.color, m.material_type, cs.current_kg AS kg
                    FROM materials m LEFT JOIN ({CURRENT_STOCK_SQL}) cs ON cs.material_id = m.id ORDER BY m.material_index''')
                rows = cursor.fetchall()
        catalog = {code: [r for r in rows if r['material_type'] == material_type] for code, material_type, _ in SECTIONS}
        meta = DOC_TYPES[doc['doc_type']]
        totals = {'kg': sum(l['qty_kg'] for l in lines), 'over': sum(1 for l in lines if l['over'])}
        sections = [{'code': code, 'label': label, 'lines': [l for l in lines if l['material_type'] == material_type],
                     'catalog': catalog[code]} for code, material_type, label in SECTIONS]
        for section in sections:
            section['kg'] = sum(l['qty_kg'] for l in section['lines'])
        return render_template('machine_doc.html', doc=doc, lines=lines, meta=meta, sections=sections, totals=totals)

    @app.post('/maszyny/dokument/<int:doc_id>')
    @auth
    def save_machine_doc(doc_id):
        require_csrf()
        form = request.form
        action = form.get('action', 'save')
        with db() as connection, connection.cursor() as cursor:
            cursor.execute('SELECT pg_advisory_xact_lock(%s)', (LOCK_ID,))
            doc, lines = load_doc(cursor, doc_id)
            if doc['status'] != 'OTWARTY':
                flash('Zrealizowanego dokumentu nie można już zmieniać.', 'error')
                return redirect(url_for('machine_doc', doc_id=doc_id))
            meta = DOC_TYPES[doc['doc_type']]
            errors = []
            try:
                doc_date = date.fromisoformat(form.get('doc_date', ''))
            except ValueError:
                doc_date = doc['doc_date']
                errors.append('Podaj prawidłową datę dokumentu.')
            reason = form.get('reason', '')
            if doc['doc_type'] == 'UZUPELNIENIE' and reason and reason not in REFILL_REASONS:
                reason = ''
            cursor.execute('''UPDATE machine_docs SET doc_date=%s, shift=%s, order_ref=%s, reason=%s, notes=%s, created_by=%s WHERE id=%s''',
                           (doc_date, clean(form.get('shift')), clean(form.get('order_ref')), reason or None,
                            form.get('notes', '').strip(), clean(form.get('created_by')), doc_id))
            quantities = {}
            for line in lines:
                raw = form.get(f'qty_{line["id"]}')
                if raw is None:
                    quantities[line['id']] = line['qty_kg']
                    continue
                try:
                    quantity = as_qty(raw, line['material_index']) or Decimal(0)
                except ValueError as error:
                    errors.append(str(error)); quantity = line['qty_kg']
                quantities[line['id']] = quantity
                cursor.execute('UPDATE machine_doc_lines SET qty_kg=%s, notes=%s WHERE id=%s', (quantity, clean(form.get(f'note_{line["id"]}')), line['id']))
            if form.get('delete_line'):
                cursor.execute('DELETE FROM machine_doc_lines WHERE id=%s AND doc_id=%s', (form.get('delete_line'), doc_id))
                flash('Usunięto pozycję z dokumentu.', 'success')
            elif action in ('add_SS', 'add_BT'):
                errors += add_line(cursor, doc_id, form, action[4:])
            elif action == 'realize':
                if errors:
                    pass
                else:
                    errors += realize(cursor, doc, lines, quantities, form, meta, reason)
            if errors:
                for error in errors[:6]:
                    flash(error, 'error')
                connection.commit()
                return redirect(url_for('machine_doc', doc_id=doc_id))
        if action == 'save':
            flash('Dokument został zapisany.', 'success')
        if action == 'realize':
            return redirect(url_for('machine_doc', doc_id=doc_id))
        return redirect(url_for('machine_doc', doc_id=doc_id) + (f'#add-{action[4:]}' if action.startswith('add_') else ''))

    def add_line(cursor, doc_id, form, code):
        category = {c: material_type for c, material_type, _ in SECTIONS}[code]
        text = form.get(f'add_material_{code}', '').strip()
        if not text:
            return ['Wpisz lub wybierz pozycję, którą chcesz dodać.']
        token = text.split()[0].upper()
        cursor.execute('SELECT id, material_index, material_type FROM materials WHERE material_index=%s', (token,))
        material = cursor.fetchone()
        if material is None:
            return [f'Nie znaleziono pozycji „{text}”. Wybierz ją z podpowiedzi (np. SS015 lub BT004).']
        if material['material_type'] != category:
            return [f'{material["material_index"]} nie jest z tej sekcji — dodaj ją w sekcji {"Barwniki" if code == "SS" else "Tworzywa"}.']
        try:
            quantity = as_qty(form.get(f'add_qty_{code}'), material['material_index']) or Decimal(0)
        except ValueError as error:
            return [str(error)]
        cursor.execute('''INSERT INTO machine_doc_lines (doc_id, material_id, qty_kg) VALUES (%s,%s,%s)
                          ON CONFLICT (doc_id, material_id) DO UPDATE SET qty_kg = machine_doc_lines.qty_kg + EXCLUDED.qty_kg''',
                       (doc_id, material['id'], quantity))
        flash(f'Dodano {material["material_index"]}. Wpisz ilość w kg albo dodaj kolejne pozycje.', 'success')
        return []

    def realize(cursor, doc, lines, quantities, form, meta, reason):
        errors = []
        performer = clean(form.get('realized_by'))
        if not performer:
            errors.append('Podaj, kto wykonał operację (imię i nazwisko magazyniera).')
        filled = [l for l in lines if quantities[l['id']] > 0]
        if not filled:
            errors.append('Dokument nie ma żadnej pozycji z ilością większą od zera.')
        if doc['doc_type'] == 'UZUPELNIENIE' and not reason:
            errors.append('Wybierz powód uzupełnienia pola odkładczego.')
        if meta['source'] == 'machine':
            available = machine_stock(cursor, doc['machine_id'])
            for line in filled:
                have = available.get(line['material_id'], Decimal(0))
                if quantities[line['id']] > have:
                    errors.append(f'{line["material_index"]}: na polu odkładczym maszyny {doc["machine_id"]} jest tylko {have:f} kg, a wpisano {quantities[line["id"]]:f} kg.')
        if errors:
            return errors
        warnings = []
        if meta['source'] == 'main':
            available = main_stock(cursor, [l['material_id'] for l in filled])
            for line in filled:
                have = available.get(line['material_id'])
                if have is not None and quantities[line['id']] > have:
                    warnings.append(f'{line["material_index"]}: wydano {quantities[line["id"]]:f} kg, a stan magazynu głównego to {have:f} kg — sprawdź stan lub zrób inwentaryzację.')
        cursor.execute('DELETE FROM machine_doc_lines WHERE doc_id=%s AND qty_kg=0', (doc['id'],))
        cursor.execute("UPDATE machine_docs SET status='ZREALIZOWANY', realized_by=%s, realized_at=NOW() WHERE id=%s", (performer, doc['id']))
        flash(f'Dokument {doc["number"]} zrealizowano: {len(filled)} poz., łącznie {sum(quantities[l["id"]] for l in filled):f} kg.', 'success')
        for warning in warnings:
            flash('Uwaga: ' + warning, 'error')
        return []

    @app.post('/maszyny/dokument/<int:doc_id>/usun')
    @auth
    def delete_machine_doc(doc_id):
        require_csrf()
        with db() as connection, connection.cursor() as cursor:
            cursor.execute("DELETE FROM machine_docs WHERE id=%s AND status='OTWARTY' RETURNING number, machine_id", (doc_id,))
            deleted = cursor.fetchone()
        if deleted is None:
            flash('Zrealizowanego dokumentu nie można usunąć.', 'error')
            return redirect(url_for('machine_doc', doc_id=doc_id))
        flash(f'Usunięto otwarty dokument {deleted["number"]}.', 'success')
        return redirect(url_for('machine_detail', machine_id=deleted['machine_id']))

    @app.get('/maszyny/dokumenty')
    @auth
    def machine_docs_index():
        args = request.args
        machine, doc_type, status = args.get('maszyna', ''), args.get('typ', ''), args.get('status', '')
        date_from = args.get('od', '') or (date.today() - timedelta(days=30)).isoformat()
        date_to = args.get('do', '') or date.today().isoformat()
        sql = '''SELECT d.*, COUNT(l.id) AS lines, COALESCE(SUM(l.qty_kg), 0) AS kg
                 FROM machine_docs d LEFT JOIN machine_doc_lines l ON l.doc_id = d.id WHERE d.doc_date BETWEEN %s AND %s'''
        try:
            params = [date.fromisoformat(date_from), date.fromisoformat(date_to)]
        except ValueError:
            abort(400)
        if machine.isdigit():
            sql += ' AND d.machine_id=%s'; params.append(int(machine))
        if doc_type in DOC_TYPES:
            sql += ' AND d.doc_type=%s'; params.append(doc_type)
        if status in ('OTWARTY', 'ZREALIZOWANY'):
            sql += ' AND d.status=%s'; params.append(status)
        sql += ' GROUP BY d.id ORDER BY d.doc_date DESC, d.id DESC LIMIT 500'
        with db() as connection, connection.cursor() as cursor:
            cursor.execute(sql, params); docs = cursor.fetchall()
        return render_template('machine_docs.html', docs=docs, machine=machine, doc_type=doc_type, status=status,
                               date_from=date_from, date_to=date_to)
