from datetime import date, timedelta
from decimal import Decimal

from flask import abort, flash, redirect, render_template, request, url_for

from inventory import CURRENT_STOCK_SQL, as_qty
from machines import SECTIONS
from materials import as_decimal, auth, clean, require_csrf

LOCK_ID = 6102030


def init_receipts(db):
    with db() as connection, connection.cursor() as cursor:
        cursor.execute('SELECT pg_advisory_xact_lock(%s)', (LOCK_ID,))
        cursor.execute('''CREATE TABLE IF NOT EXISTS receipts (
            id BIGSERIAL PRIMARY KEY, number TEXT NOT NULL UNIQUE,
            supplier_id BIGINT REFERENCES suppliers(id) ON DELETE SET NULL, supplier_name TEXT,
            doc_date DATE NOT NULL DEFAULT CURRENT_DATE, delivery_doc TEXT, order_ref TEXT, notes TEXT,
            created_by TEXT, received_by TEXT, status TEXT NOT NULL DEFAULT 'OTWARTY', realized_at TIMESTAMPTZ,
            created_at TIMESTAMPTZ NOT NULL DEFAULT NOW())''')
        cursor.execute('''CREATE TABLE IF NOT EXISTS receipt_lines (
            id BIGSERIAL PRIMARY KEY, receipt_id BIGINT NOT NULL REFERENCES receipts(id) ON DELETE CASCADE,
            material_id BIGINT NOT NULL REFERENCES materials(id) ON DELETE RESTRICT,
            qty_kg NUMERIC(14,3) NOT NULL DEFAULT 0 CHECK (qty_kg >= 0), unit_price NUMERIC(12,4), lot TEXT, notes TEXT,
            UNIQUE (receipt_id, material_id))''')
        cursor.execute('CREATE INDEX IF NOT EXISTS receipt_lines_material_idx ON receipt_lines(material_id)')


def register_receipt_routes(app, db):
    def next_number(cursor, year):
        cursor.execute("SELECT COALESCE(MAX(CAST(SPLIT_PART(number,'/',3) AS INTEGER)),0)+1 AS n FROM receipts WHERE number LIKE %s", (f'PZ/{year}/%',))
        return f'PZ/{year}/{cursor.fetchone()["n"]:03d}'

    @app.get('/przyjecia')
    @auth
    def receipts_index():
        date_from = request.args.get('od', '') or (date.today() - timedelta(days=90)).isoformat()
        date_to = request.args.get('do', '') or date.today().isoformat()
        status = request.args.get('status', '')
        sql = '''SELECT r.*, COALESCE(s.name, r.supplier_name) AS supplier, COUNT(l.id) AS lines, COALESCE(SUM(l.qty_kg), 0) AS kg,
                        COALESCE(SUM(l.qty_kg * l.unit_price), 0) AS value
                 FROM receipts r LEFT JOIN receipt_lines l ON l.receipt_id = r.id LEFT JOIN suppliers s ON s.id = r.supplier_id
                 WHERE r.doc_date BETWEEN %s AND %s'''
        try:
            params = [date.fromisoformat(date_from), date.fromisoformat(date_to)]
        except ValueError:
            abort(400)
        if status in ('OTWARTY', 'ZREALIZOWANY'):
            sql += ' AND r.status=%s'; params.append(status)
        sql += ' GROUP BY r.id, s.name ORDER BY r.doc_date DESC, r.id DESC LIMIT 500'
        with db() as connection, connection.cursor() as cursor:
            cursor.execute(sql, params); receipts = cursor.fetchall()
        return render_template('receipts.html', receipts=receipts, date_from=date_from, date_to=date_to, status=status)

    @app.post('/przyjecia/nowe')
    @auth
    def create_receipt():
        require_csrf()
        with db() as connection, connection.cursor() as cursor:
            cursor.execute('SELECT pg_advisory_xact_lock(%s)', (LOCK_ID,))
            number = next_number(cursor, date.today().year)
            cursor.execute('INSERT INTO receipts (number) VALUES (%s) RETURNING id', (number,))
            receipt_id = cursor.fetchone()['id']
        flash(f'Utworzono przyjęcie {number}. Wybierz dostawcę i dodaj przyjmowane pozycje.', 'success')
        return redirect(url_for('receipt_sheet', receipt_id=receipt_id))

    def load(cursor, receipt_id):
        cursor.execute('''SELECT r.*, s.name AS linked_supplier FROM receipts r LEFT JOIN suppliers s ON s.id = r.supplier_id WHERE r.id=%s''', (receipt_id,))
        receipt = cursor.fetchone()
        if receipt is None:
            abort(404)
        cursor.execute('''SELECT l.*, m.material_index, m.material_type, m.internal_name, m.symbol, m.color,
                COALESCE(m.supplier_short_name, m.supplier_name) AS supplier
            FROM receipt_lines l JOIN materials m ON m.id = l.material_id WHERE l.receipt_id=%s ORDER BY m.material_index''', (receipt_id,))
        return receipt, cursor.fetchall()

    @app.get('/przyjecia/<int:receipt_id>')
    @auth
    def receipt_sheet(receipt_id):
        show_all = request.args.get('wszystkie') == '1'
        with db() as connection, connection.cursor() as cursor:
            receipt, lines = load(cursor, receipt_id)
            cursor.execute('SELECT id, name, short_name, supplier_no, material_type FROM suppliers ORDER BY supplier_no')
            suppliers = cursor.fetchall()
            cursor.execute(f'''SELECT m.id, m.material_index, m.internal_name, m.color, m.material_type, m.supplier_id, cs.current_kg AS kg
                FROM materials m LEFT JOIN ({CURRENT_STOCK_SQL}) cs ON cs.material_id = m.id ORDER BY m.material_index''')
            rows = cursor.fetchall()
        sections, restricted = [], False
        for code, material_type, label in SECTIONS:
            catalog = [r for r in rows if r['material_type'] == material_type]
            own = [r for r in catalog if receipt['supplier_id'] and r['supplier_id'] == receipt['supplier_id']]
            if own and not show_all:
                catalog, restricted = own, True
            section_lines = [l for l in lines if l['material_type'] == material_type]
            sections.append({'code': code, 'label': label, 'lines': section_lines, 'catalog': catalog,
                             'kg': sum(l['qty_kg'] for l in section_lines),
                             'value': sum(l['qty_kg'] * l['unit_price'] for l in section_lines if l['unit_price'] is not None)})
        totals = {'kg': sum(s['kg'] for s in sections), 'value': sum(s['value'] for s in sections)}
        return render_template('receipt_doc.html', receipt=receipt, sections=sections, suppliers=suppliers,
                               totals=totals, restricted=restricted, show_all=show_all)

    def add_line(cursor, receipt_id, form, code):
        category = {c: material_type for c, material_type, _ in SECTIONS}[code]
        text = form.get(f'add_material_{code}', '').strip()
        if not text:
            return ['Wpisz lub wybierz pozycję, którą chcesz przyjąć.']
        cursor.execute('SELECT id, material_index, material_type, price_pln FROM materials WHERE material_index=%s', (text.split()[0].upper(),))
        material = cursor.fetchone()
        if material is None:
            return [f'Nie znaleziono pozycji „{text}”. Wybierz ją z podpowiedzi (np. SS015 lub BT004).']
        if material['material_type'] != category:
            return [f'{material["material_index"]} nie jest z tej sekcji — dodaj ją w sekcji {"Barwniki" if code == "SS" else "Tworzywa"}.']
        try:
            quantity = as_qty(form.get(f'add_qty_{code}'), material['material_index']) or Decimal(0)
        except ValueError as error:
            return [str(error)]
        cursor.execute('''INSERT INTO receipt_lines (receipt_id, material_id, qty_kg, unit_price) VALUES (%s,%s,%s,%s)
                          ON CONFLICT (receipt_id, material_id) DO UPDATE SET qty_kg = receipt_lines.qty_kg + EXCLUDED.qty_kg''',
                       (receipt_id, material['id'], quantity, material['price_pln']))
        flash(f'Dodano {material["material_index"]}. Wpisz ilość, cenę i numer partii.', 'success')
        return []

    @app.post('/przyjecia/<int:receipt_id>')
    @auth
    def save_receipt(receipt_id):
        require_csrf()
        form = request.form
        action = form.get('action', 'save')
        with db() as connection, connection.cursor() as cursor:
            cursor.execute('SELECT pg_advisory_xact_lock(%s)', (LOCK_ID,))
            receipt, lines = load(cursor, receipt_id)
            if receipt['status'] != 'OTWARTY':
                flash('Zrealizowanego przyjęcia nie można już zmieniać.', 'error')
                return redirect(url_for('receipt_sheet', receipt_id=receipt_id))
            errors = []
            try:
                doc_date = date.fromisoformat(form.get('doc_date', ''))
            except ValueError:
                doc_date = receipt['doc_date']; errors.append('Podaj prawidłową datę przyjęcia.')
            supplier_id, supplier_name = None, None
            if form.get('supplier_id', '').isdigit():
                cursor.execute('SELECT id, name FROM suppliers WHERE id=%s', (int(form['supplier_id']),))
                supplier = cursor.fetchone()
                if supplier:
                    supplier_id, supplier_name = supplier['id'], supplier['name']
            cursor.execute('''UPDATE receipts SET doc_date=%s, supplier_id=%s, supplier_name=%s, delivery_doc=%s, order_ref=%s,
                              notes=%s, created_by=%s WHERE id=%s''',
                           (doc_date, supplier_id, supplier_name, clean(form.get('delivery_doc')), clean(form.get('order_ref')),
                            form.get('notes', '').strip(), clean(form.get('created_by')), receipt_id))
            quantities = {}
            for line in lines:
                key = str(line['id'])
                if f'qty_{key}' not in form:
                    quantities[line['id']] = line['qty_kg']; continue
                try:
                    quantity = as_qty(form.get(f'qty_{key}'), line['material_index']) or Decimal(0)
                    price = as_decimal(form.get(f'price_{key}'))
                    if price is not None and price < 0:
                        raise ValueError(f'{line["material_index"]}: cena nie może być ujemna.')
                except ValueError as error:
                    errors.append(str(error)); quantity, price = line['qty_kg'], line['unit_price']
                quantities[line['id']] = quantity
                cursor.execute('UPDATE receipt_lines SET qty_kg=%s, unit_price=%s, lot=%s, notes=%s WHERE id=%s',
                               (quantity, price, clean(form.get(f'lot_{key}')), clean(form.get(f'note_{key}')), line['id']))
            if form.get('delete_line'):
                cursor.execute('DELETE FROM receipt_lines WHERE id=%s AND receipt_id=%s', (form['delete_line'], receipt_id))
                flash('Usunięto pozycję z przyjęcia.', 'success')
            elif action in ('add_SS', 'add_BT'):
                errors += add_line(cursor, receipt_id, form, action[4:])
            elif action == 'realize' and not errors:
                receiver = clean(form.get('received_by'))
                filled = [l for l in lines if quantities[l['id']] > 0]
                if supplier_id is None:
                    errors.append('Wybierz dostawcę, od którego przyjmujesz towar.')
                if not filled:
                    errors.append('Przyjęcie nie ma żadnej pozycji z ilością większą od zera.')
                if not receiver:
                    errors.append('Podaj, kto przyjął towar na magazyn (imię i nazwisko).')
                if not errors:
                    cursor.execute('DELETE FROM receipt_lines WHERE receipt_id=%s AND qty_kg=0', (receipt_id,))
                    cursor.execute("UPDATE receipts SET status='ZREALIZOWANY', received_by=%s, realized_at=NOW() WHERE id=%s", (receiver, receipt_id))
                    flash(f'Przyjęto {receipt["number"]}: {len(filled)} poz., łącznie {sum(quantities[l["id"]] for l in filled):f} kg. Stany magazynu głównego zostały zwiększone.', 'success')
            if errors:
                for error in errors[:6]:
                    flash(error, 'error')
                connection.commit()
                return redirect(url_for('receipt_sheet', receipt_id=receipt_id))
        if action == 'save':
            flash('Przyjęcie zostało zapisane.', 'success')
        return redirect(url_for('receipt_sheet', receipt_id=receipt_id, wszystkie='1' if form.get('all') == '1' else None) + (f'#add-{action[4:]}' if action.startswith('add_') else ''))

    @app.post('/przyjecia/<int:receipt_id>/usun')
    @auth
    def delete_receipt(receipt_id):
        require_csrf()
        with db() as connection, connection.cursor() as cursor:
            cursor.execute("DELETE FROM receipts WHERE id=%s AND status='OTWARTY' RETURNING number", (receipt_id,))
            deleted = cursor.fetchone()
        if deleted is None:
            flash('Zrealizowanego przyjęcia nie można usunąć.', 'error')
            return redirect(url_for('receipt_sheet', receipt_id=receipt_id))
        flash(f'Usunięto otwarte przyjęcie {deleted["number"]}.', 'success')
        return redirect(url_for('receipts_index'))
