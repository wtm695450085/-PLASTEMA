"""Jednorazowo: dokumenty PW (przyjęcie z produkcji) dla ruchów PW dopisanych przez backfill_fg_history.py (WZ ma dokument, PW nie miało)."""
import os
import sys

import psycopg
from psycopg.rows import dict_row

DRY = '--dry' in sys.argv
conn = psycopg.connect(os.environ['DATABASE_URL'], row_factory=dict_row)
cur = conn.cursor()
cur.execute('SELECT pg_advisory_xact_lock(6102035)')
cur.execute('''SELECT d.id AS wz_id, d.zk_order_id, d.client_id, l.order_line_id, l.product_id, COALESCE(l.batch_code, '') AS batch, l.location, l.qty
               FROM fg_docs d JOIN fg_doc_lines l ON l.doc_id = d.id
               WHERE d.doc_type = 'WZ' AND d.created_by = 'import historyczny' ORDER BY d.zk_order_id, l.id''')
wz_lines = cur.fetchall()
cur.execute('''SELECT id, move_date, product_id, COALESCE(batch_code, '') AS batch, qty FROM fg_moves
               WHERE move_type = 'PW' AND doc_id IS NULL AND prod_receipt_id IS NULL ORDER BY move_date, id''')
free = {}
for m in cur.fetchall():
    free.setdefault((m['product_id'], m['batch'], m['qty']), []).append(m)
groups = {}
for l in wz_lines:
    cands = free.get((l['product_id'], l['batch'], l['qty']))
    if not cands:
        continue
    m = cands.pop(0)
    groups.setdefault((l['zk_order_id'], m['move_date']), []).append((l, m))
counters = {}
n_docs = 0
for (order_id, day), items in sorted(groups.items(), key=lambda kv: (kv[0][1], kv[0][0])):
    year = day.year
    if year not in counters:
        cur.execute("SELECT COALESCE(MAX(CAST(SPLIT_PART(number, '/', 3) AS INTEGER)), 0) AS n FROM fg_docs WHERE number LIKE %s", (f'PW/{year}/%',))
        counters[year] = cur.fetchone()['n']
    counters[year] += 1
    number = f'PW/{year}/{counters[year]:03d}'
    cur.execute('''INSERT INTO fg_docs (number, doc_type, client_id, zk_order_id, doc_date, status, notes, created_by, realized_by, realized_at)
                   VALUES (%s,'PW',%s,%s,%s,'ZREALIZOWANY',%s,'import historyczny','import historyczny',%s) RETURNING id''',
                (number, items[0][0]['client_id'], order_id, day,
                 'Dokument historyczny uzupełniony na podstawie raportu produkcyjnego 2026 (data zakończenia produkcji).', f'{day} 08:00+02'))
    doc_id = cur.fetchone()['id']
    for l, m in items:
        cur.execute('''INSERT INTO fg_doc_lines (doc_id, product_id, order_line_id, batch_code, location, qty) VALUES (%s,%s,%s,%s,%s,%s)''',
                    (doc_id, l['product_id'], l['order_line_id'], l['batch'] or None, l['location'], l['qty']))
        cur.execute('UPDATE fg_moves SET doc_id = %s WHERE id = %s', (doc_id, m['id']))
    n_docs += 1
print(f'dokumentów PW: {n_docs}, ruchów: {sum(len(v) for v in groups.values())}')
if DRY:
    conn.rollback(); print('DRY RUN — wycofano')
else:
    conn.commit()
