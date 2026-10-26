"""Jednorazowo: zlecenia wewnętrzne (zamówienia produkcji, ZP) dla zamówień klientów, które powstały z importu Excela (ZREALIZOWANE i W PRODUKCJI).
Numer ZP = „zam. wewn.” ze statystyki produkcji (np. 328/2026), wystawił(a) — osoba z biura (FIKCYJNIE, naprzemiennie), przyjął(ęła) — kto zakładał formę
wg statystyki produkcji (dane rzeczywiste). Daty, maszyna, ilości, szarża — ze statystyki. Idempotentne (pomija ZK, które mają już ZP). Uruchomienie: python backfill_prod_orders.py [--dry]"""
import os
import re
import sys

import psycopg
from psycopg.rows import dict_row

ISSUERS = ['Jakub Majchrzak', 'Ania Kwiatek']
conn = psycopg.connect(os.environ['DATABASE_URL'], row_factory=dict_row)
cur = conn.cursor()
cur.execute('SELECT pg_advisory_xact_lock(6102035)')
cur.execute('''SELECT o.* FROM orders o WHERE o.status IN ('ZREALIZOWANE','W PRODUKCJI') AND o.internal_no IS NOT NULL
               AND NOT EXISTS (SELECT 1 FROM prod_orders po WHERE po.zk_order_id = o.id) ORDER BY o.order_date, o.id''')
orders = cur.fetchall()
cur.execute('SELECT number FROM prod_orders')
used = {r['number'] for r in cur.fetchall()}
created = skipped = 0
for o in orders:
    cur.execute('''SELECT l.*, col.name AS color_name, p.name AS pname, p.colorant_pct FROM order_lines l LEFT JOIN colors col ON col.id = l.color_id
                   LEFT JOIN products p ON p.id = l.product_id WHERE l.order_id = %s ORDER BY l.lp, l.id''', (o['id'],))
    lines = cur.fetchall()
    if not lines:
        skipped += 1
        continue
    cur.execute('''SELECT DISTINCT ON (l.id) l.id AS line_id, p.* FROM order_lines l JOIN productions p ON p.source = 'EXCEL' AND p.product_id = l.product_id
                   AND COALESCE(p.internal_order, '') = COALESCE(%s, '') WHERE l.order_id = %s
                   ORDER BY l.id, (p.end_date IS NOT NULL) DESC, p.id''', (o['internal_no'], o['id']))
    prods = {r['line_id']: r for r in cur.fetchall()}
    first = next((prods[l['id']] for l in lines if l['id'] in prods), None)
    number = o['internal_no']
    if number in used:
        number = f'{number}-B'
    used.add(number)
    m = re.match(r'^(\d+)/(\d{4})', o['internal_no'])
    seq, year = (int(m.group(1)), int(m.group(2))) if m else (0, o['order_date'].year)
    starts = [p['start_date'] for p in prods.values() if p['start_date']] or [l['prod_start'] for l in lines if l['prod_start']]
    ends = [p['end_date'] for p in prods.values() if p['end_date']] or [l['prod_end'] for l in lines if l['prod_end']]
    machine = None
    if first and first['machine_no'] and str(first['machine_no']).strip().isdigit() and 1 <= int(first['machine_no']) <= 9:
        machine = int(first['machine_no'])
    names = [l['pname'] or l['product_name'] for l in lines]
    base = min(names, key=len) if len(lines) > 1 else names[0]
    finished = o['status'] == 'ZREALIZOWANE'
    qty_total = sum(l['qty'] or 0 for l in lines)
    cur.execute('''INSERT INTO prod_orders (number, seq, year, client_id, zk_order_id, product_name, machine_no, mold_id, order_date, planned_start, planned_end,
                       qty_total, material_id, material_text, material_share, net_g, per_shift, cavities, pcs_per_carton, carton_kg, carton_type,
                       notes, issued_by, accepted_by, status, batch_code)
                   VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,100,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) RETURNING id''',
                (number, seq, year, o['client_id'], o['id'], base.upper(), machine, lines[0]['mold_id'], o['order_date'],
                 min(starts) if starts else None, max(ends) if ends else None, qty_total, lines[0]['material_id'],
                 first and first['material'], first and first['net_g'], first and first['avg_per_shift'] and int(first['avg_per_shift']),
                 int(first['cavities']) if first and first['cavities'] else 1, first and first['pcs_per_carton'] and int(first['pcs_per_carton']),
                 first and first['carton_kg'], first and first['carton_type'],
                 f'Z zamówienia klienta {o["number"]}. Zlecenie historyczne uzupełnione ze statystyki produkcji 2026 (osoba wystawiająca fikcyjna).',
                 ISSUERS[o['id'] % 2], (first and (first['mounted_by'] or first['dismounted_by'])) or None,
                 'ZAKOŃCZONE' if finished else 'W PRODUKCJI', lines[0]['batch_code'] or (first and first['batch_code'])))
    po_id = cur.fetchone()['id']
    for lp, l in enumerate(lines, start=1):
        p = prods.get(l['id'])
        cur.execute('''INSERT INTO prod_colors (prod_order_id, lp, color_id, color_name, product_id, zk_line_id, colorant_id, dosage_pct, qty_ordered, spec_good,
                           status, mounted_by, dismounted_by, settled_at, settled_by)
                       VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)''',
                    (po_id, lp, l['color_id'], l['color_name'] or l['product_name'], l['product_id'], l['id'], l['colorant_id'],
                     (p and p['dosage_pct']) or l['colorant_pct'], l['qty'] or 0, int(p['qty']) if p and p['qty'] else None,
                     'ROZLICZONY' if finished else 'W PRODUKCJI', p and p['mounted_by'], p and p['dismounted_by'],
                     (p['end_date'].isoformat() + ' 15:00+02') if finished and p and p['end_date'] else None,
                     'import historyczny' if finished else None))
    created += 1
print(f'zleceń wewnętrznych: {created}, pominięte (brak pozycji): {skipped}')
if '--dry' in sys.argv:
    conn.rollback(); print('DRY RUN')
else:
    conn.commit()
