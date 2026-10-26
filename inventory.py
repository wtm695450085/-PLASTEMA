from datetime import date
from decimal import Decimal

from flask import abort, flash, redirect, render_template, request, url_for

from materials import as_decimal, auth, clean, csrf, require_csrf

CATEGORIES = {'SUROWIEC SYPKI': 'Tworzywa (SS)', 'BARWNIK TWORZYWA': 'Barwniki (BT)'}
SCOPES = {'ALL': 'Wszystkie pozycje', **CATEGORIES}
DIFF_REASONS = {
    'NIEAUTORYZOWANY_POBOR': 'Nieautoryzowany pobór surowca z magazynu',
    'BLAD_PRZYJECIA': 'Błąd w przyjęciu dostawy',
    'BLAD_WYDANIA': 'Błąd w wydaniu na produkcję',
    'BLAD_WAZENIA': 'Błąd ważenia / pomiaru przy spisie',
    'STRATY': 'Straty technologiczne, odpad, zanieczyszczenie',
    'BRAK_WYJASNIENIA': 'Brak wyjaśnienia',
}
DEFAULT_THRESHOLD = Decimal('5')

# Stan bieżący = ostatni zatwierdzony spis z natury, w którym pozycja została policzona.
STOCK_SQL = '''
SELECT DISTINCT ON (l.material_id) l.material_id, l.counted_kg, l.unit_price, i.count_date, i.approved_at, i.number, i.id AS inventory_id
FROM inventory_lines l JOIN inventories i ON i.id = l.inventory_id
WHERE i.status = 'ZATWIERDZONA' AND l.counted_kg IS NOT NULL
ORDER BY l.material_id, i.count_date DESC, i.id DESC'''

# Stan bieżący magazynu głównego = ostatni zatwierdzony spis + ruchy z modułu maszyn zrealizowane PO dniu spisu
# (wydania i uzupełnienia pól odkładczych zmniejszają stan, zwroty niezużytego i przyjęcia od dostawców go zwiększają).
CURRENT_STOCK_SQL = f'''
SELECT m.id AS material_id, st.counted_kg AS base_kg, st.unit_price AS base_price, st.count_date, st.number, st.inventory_id,
       COALESCE(mv.delta, 0) AS movement_kg,
       CASE WHEN st.counted_kg IS NULL AND mv.delta IS NULL THEN NULL
            ELSE COALESCE(st.counted_kg, 0) + COALESCE(mv.delta, 0) END AS current_kg
FROM materials m
LEFT JOIN ({STOCK_SQL}) st ON st.material_id = m.id
LEFT JOIN LATERAL (
    SELECT SUM(x.delta) AS delta FROM (
        SELECT CASE d.doc_type WHEN 'ZWROT' THEN l.qty_kg ELSE -l.qty_kg END AS delta, d.realized_at
        FROM machine_doc_lines l JOIN machine_docs d ON d.id = l.doc_id
        WHERE l.material_id = m.id AND d.status = 'ZREALIZOWANY' AND d.doc_type <> 'ZUZYCIE'
        UNION ALL
        SELECT rl.qty_kg AS delta, r.realized_at
        FROM receipt_lines rl JOIN receipts r ON r.id = rl.receipt_id
        WHERE rl.material_id = m.id AND r.status = 'ZREALIZOWANY'
    ) x WHERE st.count_date IS NULL OR x.realized_at::date > st.count_date
) mv ON TRUE'''

# Ilość aktualnie leżąca na polach odkładczych maszyn (wszystkie maszyny łącznie).
ON_MACHINES_SQL = '''
SELECT l.material_id, SUM(CASE WHEN d.doc_type IN ('WYDANIE','UZUPELNIENIE') THEN l.qty_kg ELSE -l.qty_kg END) AS kg
FROM machine_doc_lines l JOIN machine_docs d ON d.id = l.doc_id
WHERE d.status = 'ZREALIZOWANY' GROUP BY l.material_id'''


def init_inventory(db):
    with db() as connection, connection.cursor() as cursor:
        cursor.execute('SELECT pg_advisory_xact_lock(6102028)')
        cursor.execute('''CREATE TABLE IF NOT EXISTS inventories (
            id BIGSERIAL PRIMARY KEY, number TEXT NOT NULL UNIQUE, count_date DATE NOT NULL,
            scope TEXT NOT NULL DEFAULT 'ALL', status TEXT NOT NULL DEFAULT 'OTWARTA',
            counted_by TEXT, notes TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            approved_at TIMESTAMPTZ)''')
        cursor.execute('''CREATE TABLE IF NOT EXISTS inventory_lines (
            id BIGSERIAL PRIMARY KEY,
            inventory_id BIGINT NOT NULL REFERENCES inventories(id) ON DELETE CASCADE,
            material_id BIGINT NOT NULL REFERENCES materials(id) ON DELETE CASCADE,
            expected_kg NUMERIC(14,3), counted_kg NUMERIC(14,3), unit_price NUMERIC(12,4), notes TEXT,
            updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), UNIQUE (inventory_id, material_id))''')
        cursor.execute('CREATE INDEX IF NOT EXISTS inventory_lines_material_idx ON inventory_lines(material_id)')
        for column in ('diff_reason TEXT', 'diff_explanation TEXT', 'diff_explained_by TEXT', 'diff_explained_at TIMESTAMPTZ'):
            cursor.execute(f'ALTER TABLE inventory_lines ADD COLUMN IF NOT EXISTS {column}')
        cursor.execute('CREATE TABLE IF NOT EXISTS app_settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)')
        cursor.execute("INSERT INTO app_settings (key, value) VALUES ('diff_threshold_pct', %s) ON CONFLICT DO NOTHING", (str(DEFAULT_THRESHOLD),))


def get_threshold(cursor):
    cursor.execute("SELECT value FROM app_settings WHERE key='diff_threshold_pct'")
    row = cursor.fetchone()
    return Decimal(row['value']) if row else DEFAULT_THRESHOLD


def annotate(line, threshold):
    """Różnica inwentaryzacyjna pozycji: kg, %, wartość i flaga przekroczenia progu."""
    counted, expected = line['counted_kg'], line['expected_kg'] or Decimal(0)
    line['diff'] = counted - expected if counted is not None else None
    line['diff_pct'] = None
    if line['diff'] is not None and line['diff'] != 0:
        line['diff_pct'] = abs(line['diff']) / expected * 100 if expected > 0 else Decimal(100)
    price = line['unit_price']
    line['value'] = counted * price if counted is not None and price is not None else None
    line['diff_value'] = line['diff'] * price if line['diff'] is not None and price is not None else None
    line['big'] = line['diff_pct'] is not None and line['diff_pct'] >= threshold
    line['reason_label'] = DIFF_REASONS.get(line.get('diff_reason') or '')
    return line


def next_number(cursor, year):
    cursor.execute("SELECT COALESCE(MAX(CAST(SPLIT_PART(number,'/',3) AS INTEGER)),0)+1 AS n FROM inventories WHERE number LIKE %s", (f'INW/{year}/%',))
    return f'INW/{year}/{cursor.fetchone()["n"]:03d}'


def as_qty(value, label):
    try:
        qty = as_decimal(value)
    except ValueError as error:
        raise ValueError(f'{label}: ilość musi być liczbą.') from error
    if qty is not None and qty < 0:
        raise ValueError(f'{label}: ilość nie może być ujemna.')
    return qty


def fmt_number(value, places=2):
    if value is None or value == '':
        return '—'
    text = f'{Decimal(value):,.{places}f}'.replace(',', ' ').replace('.', ',')
    return text[:-3] if places == 2 and text.endswith(',00') else text


def input_number(value):
    if value is None:
        return ''
    return format(Decimal(value).normalize(), 'f').replace('.', ',')


def register_inventory_routes(app, db):
    app.jinja_env.globals.update(inventory_scopes=SCOPES, inventory_categories=CATEGORIES)
    app.jinja_env.filters['num'] = fmt_number
    app.jinja_env.filters['qty_input'] = input_number

    @app.get('/stany')
    @auth
    def stock_index():
        q = request.args.get('q', '').strip(); category = request.args.get('category', '').strip()
        only_stock = request.args.get('tylko') == '1'
        sql = f'''SELECT m.id, m.material_index, m.material_type, m.internal_name, m.symbol, m.color, m.kind,
                   m.supplier_no, COALESCE(m.supplier_short_name, m.supplier_name) AS supplier, m.price_pln,
                   cs.current_kg AS counted_kg, cs.base_kg, cs.movement_kg, COALESCE(om.kg, 0) AS on_machines,
                   COALESCE(cs.base_price, m.price_pln) AS unit_price, cs.count_date, cs.number, cs.inventory_id
                  FROM materials m LEFT JOIN ({CURRENT_STOCK_SQL}) cs ON cs.material_id = m.id
                  LEFT JOIN ({ON_MACHINES_SQL}) om ON om.material_id = m.id WHERE TRUE'''
        params = []
        if q:
            sql += ' AND (m.material_index ILIKE %s OR m.internal_name ILIKE %s OR m.symbol ILIKE %s OR m.color ILIKE %s OR m.supplier_name ILIKE %s)'
            params += [f'%{q}%'] * 5
        if category:
            sql += ' AND m.material_type = %s'; params.append(category)
        if only_stock:
            sql += ' AND cs.current_kg > 0'
        sql += ' ORDER BY m.material_index'
        with db() as connection, connection.cursor() as cursor:
            cursor.execute(sql, params); rows = cursor.fetchall()
        for r in rows:
            r['value'] = (r['counted_kg'] * r['unit_price']) if r['counted_kg'] is not None and r['unit_price'] is not None else None
        summary = {}
        for key, label in CATEGORIES.items():
            part = [r for r in rows if r['material_type'] == key]
            summary[key] = {'label': label, 'count': len(part),
                            'kg': sum((r['counted_kg'] or 0) for r in part),
                            'value': sum((r['value'] or 0) for r in part),
                            'missing': sum(1 for r in part if r['counted_kg'] is None)}
        total_value = sum((r['value'] or 0) for r in rows)
        return render_template('stock.html', rows=rows, summary=summary, total_value=total_value,
                               query=q, selected_category=category, only_stock=only_stock)

    @app.get('/inwentaryzacje')
    @auth
    def inventory_index():
        with db() as connection, connection.cursor() as cursor:
            cursor.execute('''SELECT i.*, COUNT(l.id) AS lines, COUNT(l.counted_kg) AS counted,
                              COALESCE(SUM(l.counted_kg * l.unit_price),0) AS value
                              FROM inventories i LEFT JOIN inventory_lines l ON l.inventory_id = i.id
                              GROUP BY i.id ORDER BY i.count_date DESC, i.id DESC''')
            inventories = cursor.fetchall()
        return render_template('inventories.html', inventories=inventories)

    @app.route('/inwentaryzacje/nowa', methods=['GET', 'POST'])
    @auth
    def create_inventory():
        form = {'count_date': date.today().isoformat(), 'scope': 'ALL', 'counted_by': '', 'notes': ''}
        if request.method == 'POST':
            require_csrf()
            form = {k: request.form.get(k, '').strip() for k in form}
            try:
                count_date = date.fromisoformat(form['count_date'])
            except ValueError:
                flash('Podaj prawidłową datę spisu.', 'error')
                return render_template('inventory_new.html', form=form)
            if form['scope'] not in SCOPES:
                abort(400)
            with db() as connection, connection.cursor() as cursor:
                number = next_number(cursor, count_date.year)
                cursor.execute('''INSERT INTO inventories (number,count_date,scope,counted_by,notes)
                                  VALUES (%s,%s,%s,%s,%s) RETURNING id''',
                               (number, count_date, form['scope'], form['counted_by'], form['notes']))
                inventory_id = cursor.fetchone()['id']
                cursor.execute(f'''INSERT INTO inventory_lines (inventory_id, material_id, expected_kg, unit_price)
                    SELECT %s, m.id, cs.current_kg, m.price_pln FROM materials m
                    LEFT JOIN ({CURRENT_STOCK_SQL}) cs ON cs.material_id = m.id
                    WHERE %s = 'ALL' OR m.material_type = %s''', (inventory_id, form['scope'], form['scope']))
            flash(f'Utworzono arkusz spisu {number}. Wpisz ilości policzone na magazynie.', 'success')
            return redirect(url_for('inventory_sheet', inventory_id=inventory_id))
        return render_template('inventory_new.html', form=form)

    def load(inventory_id):
        with db() as connection, connection.cursor() as cursor:
            cursor.execute('SELECT * FROM inventories WHERE id=%s', (inventory_id,)); inventory = cursor.fetchone()
            if inventory is None:
                abort(404)
            cursor.execute('''SELECT l.*, m.material_index, m.material_type, m.internal_name, m.symbol, m.color,
                              COALESCE(m.supplier_short_name, m.supplier_name) AS supplier
                              FROM inventory_lines l JOIN materials m ON m.id = l.material_id
                              WHERE l.inventory_id=%s ORDER BY m.material_index''', (inventory_id,))
            lines = cursor.fetchall()
            threshold = get_threshold(cursor)
        for line in lines:
            annotate(line, threshold)
        return inventory, lines, threshold

    @app.get('/inwentaryzacje/<int:inventory_id>')
    @auth
    def inventory_sheet(inventory_id):
        inventory, lines, threshold = load(inventory_id)
        totals = {'counted': sum(1 for l in lines if l['counted_kg'] is not None),
                  'value': sum((l['value'] or 0) for l in lines),
                  'kg': sum((l['counted_kg'] or 0) for l in lines),
                  'big': sum(1 for l in lines if l['big']),
                  'big_open': sum(1 for l in lines if l['big'] and not l['diff_reason']),
                  'diff_value': sum((l['diff_value'] or 0) for l in lines)}
        template = 'inventory_print.html' if request.args.get('druk') == '1' else 'inventory_sheet.html'
        return render_template(template, inventory=inventory, lines=lines, totals=totals, threshold=threshold)

    @app.post('/inwentaryzacje/<int:inventory_id>')
    @auth
    def save_inventory(inventory_id):
        require_csrf()
        inventory, lines, _ = load(inventory_id)
        if inventory['status'] != 'OTWARTA':
            flash('Zatwierdzonego spisu nie można już zmieniać.', 'error')
            return redirect(url_for('inventory_sheet', inventory_id=inventory_id))
        updates, errors = [], []
        for line in lines:
            key = str(line['id'])
            if f'qty_{key}' not in request.form:
                continue
            try:
                qty = as_qty(request.form.get(f'qty_{key}'), line['material_index'])
            except ValueError as error:
                errors.append(str(error)); continue
            updates.append((qty, clean(request.form.get(f'note_{key}')), line['id']))
        with db() as connection, connection.cursor() as cursor:
            cursor.executemany('UPDATE inventory_lines SET counted_kg=%s, notes=%s, updated_at=NOW() WHERE id=%s', updates)
            cursor.execute('UPDATE inventories SET counted_by=%s, notes=%s WHERE id=%s',
                           (request.form.get('counted_by', '').strip(), request.form.get('notes', '').strip(), inventory_id))
        for error in errors[:5]:
            flash(error, 'error')
        if errors:
            flash(f'Pominięto {len(errors)} błędnych wpisów — popraw je i zapisz ponownie.', 'error')
        elif request.form.get('action') == 'approve':
            return approve(inventory_id)
        else:
            flash('Arkusz spisu został zapisany.', 'success')
        return redirect(url_for('inventory_sheet', inventory_id=inventory_id))

    def approve(inventory_id):
        with db() as connection, connection.cursor() as cursor:
            cursor.execute('SELECT COUNT(*) AS n FROM inventory_lines WHERE inventory_id=%s AND counted_kg IS NOT NULL', (inventory_id,))
            if cursor.fetchone()['n'] == 0:
                flash('Nie można zatwierdzić pustego spisu — wpisz przynajmniej jedną ilość.', 'error')
                return redirect(url_for('inventory_sheet', inventory_id=inventory_id))
            cursor.execute("UPDATE inventories SET status='ZATWIERDZONA', approved_at=NOW() WHERE id=%s AND status='OTWARTA'", (inventory_id,))
        flash('Spis z natury został zatwierdzony — stany magazynowe zostały zaktualizowane.', 'success')
        return redirect(url_for('stock_index'))

    @app.post('/inwentaryzacje/<int:inventory_id>/usun')
    @auth
    def delete_inventory(inventory_id):
        require_csrf()
        with db() as connection, connection.cursor() as cursor:
            cursor.execute("DELETE FROM inventories WHERE id=%s AND status='OTWARTA' RETURNING number", (inventory_id,))
            deleted = cursor.fetchone()
        flash(f"Usunięto otwarty arkusz {deleted['number']}." if deleted else 'Zatwierdzonego spisu nie można usunąć.',
              'success' if deleted else 'error')
        return redirect(url_for('inventory_index'))


    @app.post('/inwentaryzacje/prog')
    @auth
    def save_threshold():
        require_csrf()
        try:
            value = as_decimal(request.form.get('threshold'))
            if value is None or value <= 0 or value > 1000:
                raise ValueError
        except ValueError:
            flash('Próg różnicy musi być liczbą większą od 0, np. 5.', 'error')
        else:
            with db() as connection, connection.cursor() as cursor:
                cursor.execute("INSERT INTO app_settings (key,value) VALUES ('diff_threshold_pct',%s) ON CONFLICT (key) DO UPDATE SET value=EXCLUDED.value", (str(value.normalize()),))
            flash(f'Próg dużej różnicy inwentaryzacyjnej ustawiono na {fmt_number(value)}%.', 'success')
        target = request.form.get('next', '')
        return redirect(target if target.startswith('/') and not target.startswith('//') else url_for('inventory_index'))

    @app.route('/inwentaryzacje/<int:inventory_id>/roznice/<int:line_id>', methods=['GET', 'POST'])
    @auth
    def explain_difference(inventory_id, line_id):
        inventory, lines, threshold = load(inventory_id)
        line = next((l for l in lines if l['id'] == line_id), None)
        if line is None:
            abort(404)
        if request.method == 'POST':
            require_csrf()
            reason = request.form.get('diff_reason', '')
            explanation = request.form.get('diff_explanation', '').strip()
            explained_by = request.form.get('diff_explained_by', '').strip()
            if reason not in DIFF_REASONS:
                flash('Wybierz powód różnicy.', 'error')
            elif reason != 'BRAK_WYJASNIENIA' and len(explanation) < 5:
                flash('Opisz wyjaśnienie różnicy (co najmniej kilka słów).', 'error')
            else:
                with db() as connection, connection.cursor() as cursor:
                    cursor.execute('''UPDATE inventory_lines SET diff_reason=%s, diff_explanation=%s, diff_explained_by=%s,
                                      diff_explained_at=NOW() WHERE id=%s AND inventory_id=%s''',
                                   (reason, explanation, explained_by, line_id, inventory_id))
                flash(f"Zapisano wyjaśnienie różnicy dla {line['material_index']}.", 'success')
                pending = [l for l in lines if l['big'] and not l['diff_reason'] and l['id'] != line_id]
                if request.form.get('then') == 'next' and pending:
                    return redirect(url_for('explain_difference', inventory_id=inventory_id, line_id=pending[0]['id']))
                return redirect(url_for('inventory_sheet', inventory_id=inventory_id) + f'#line-{line_id}')
            line = {**line, 'diff_reason': reason, 'diff_explanation': explanation, 'diff_explained_by': explained_by}
        pending = [l for l in lines if l['big'] and not l['diff_reason'] and l['id'] != line_id]
        return render_template('difference_form.html', inventory=inventory, line=line, threshold=threshold,
                               reasons=DIFF_REASONS, pending=len(pending))

    @app.get('/analiza-roznic')
    @auth
    def difference_analysis():
        args = request.args
        date_from, date_to = args.get('od', ''), args.get('do', '')
        category = args.get('category', '')
        sql = '''SELECT l.*, i.number, i.count_date, i.id AS inventory_id, m.material_index, m.material_type,
                  m.internal_name, m.symbol, m.color, COALESCE(m.supplier_short_name, m.supplier_name) AS supplier
                  FROM inventory_lines l JOIN inventories i ON i.id=l.inventory_id JOIN materials m ON m.id=l.material_id
                  WHERE i.status='ZATWIERDZONA' AND l.counted_kg IS NOT NULL AND l.expected_kg IS NOT NULL
                    AND l.counted_kg <> l.expected_kg'''
        params = []
        try:
            if date_from:
                sql += ' AND i.count_date >= %s'; params.append(date.fromisoformat(date_from))
            if date_to:
                sql += ' AND i.count_date <= %s'; params.append(date.fromisoformat(date_to))
        except ValueError:
            abort(400)
        if category in CATEGORIES:
            sql += ' AND m.material_type=%s'; params.append(category)
        sql += ' ORDER BY i.count_date, m.material_index'
        with db() as connection, connection.cursor() as cursor:
            cursor.execute(sql, params); lines = cursor.fetchall()
            threshold = get_threshold(cursor)
            cursor.execute("SELECT MIN(count_date) AS first, MAX(count_date) AS last FROM inventories WHERE status='ZATWIERDZONA'")
            span = cursor.fetchone()
        for line in lines:
            annotate(line, threshold)
        shortages = [l for l in lines if l['diff'] < 0]
        surpluses = [l for l in lines if l['diff'] > 0]
        big = [l for l in lines if l['big']]

        def total(items):
            return sum((l['diff_value'] or 0) for l in items)

        # Surowce, których najczęściej brakuje: liczba braków i łączna wartość braków.
        by_material = {}
        for l in shortages:
            m = by_material.setdefault(l['material_id'], {'index': l['material_index'], 'name': l['internal_name'] or l['symbol'],
                                                           'color': l['color'], 'supplier': l['supplier'],
                                                           'count': 0, 'big': 0, 'kg': 0, 'value': 0})
            m['count'] += 1; m['big'] += 1 if l['big'] else 0
            m['kg'] += l['diff']; m['value'] += l['diff_value'] or 0
        top_materials = sorted(by_material.values(), key=lambda m: (-m['count'], m['value']))[:15]

        explained = [l for l in big if l['diff_reason']]
        reasons = []
        for key, label in DIFF_REASONS.items():
            items = [l for l in lines if l['diff_reason'] == key]
            reasons.append({'key': key, 'label': label, 'count': len(items), 'value': total(items),
                            'kg': sum(l['diff'] for l in items)})
        reasons.sort(key=lambda r: -r['count'])
        max_reason = max([r['count'] for r in reasons] + [1])

        by_inventory = {}
        for l in lines:
            row = by_inventory.setdefault(l['inventory_id'], {'number': l['number'], 'date': l['count_date'], 'id': l['inventory_id'],
                                                              'count': 0, 'big': 0, 'short': 0, 'surplus': 0})
            row['count'] += 1; row['big'] += 1 if l['big'] else 0
            row['short' if l['diff'] < 0 else 'surplus'] += l['diff_value'] or 0
        inventories = sorted(by_inventory.values(), key=lambda r: r['date'])
        max_inv = max([abs(r['short']) for r in inventories] + [r['surplus'] for r in inventories] + [1])

        stats = {'count': len(lines), 'big': len(big), 'short_value': total(shortages), 'surplus_value': total(surpluses),
                 'net': total(lines), 'explained_pct': (len(explained) * 100 / len(big)) if big else None,
                 'unexplained': [l for l in big if not l['diff_reason']]}
        return render_template('difference_analysis.html', stats=stats, top_materials=top_materials, reasons=reasons,
                               max_reason=max_reason, inventories=inventories, max_inv=max_inv, threshold=threshold,
                               date_from=date_from, date_to=date_to, category=category, span=span,
                               max_short=max([abs(m['value']) for m in top_materials] + [1]))
