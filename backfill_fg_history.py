"""Jednorazowe uzupełnienie historii magazynu wyrobów gotowych na podstawie statystyki produkcji (tabela productions, import z Excela).

Dla zamówień ZREALIZOWANE bez dokumentów magazynowych:
  * linie zamówienia dostają szarżę, daty i maszynę produkcji z `productions`,
  * PW (przyjęcie z produkcji) w dniu zakończenia produkcji, WZ (wydanie do klienta) 1-3 dni robocze później — WZ ZREALIZOWANY, FIKCYJNY,
  * puste pola zamówienia (odebrał, nr zam. klienta, uwagi) uzupełnione z klienta i z magazynu wyrobów (nr WZ, data, przewoźnik, szarże).
PW = WZ na tej samej szarży, więc stany magazynowe (bilans otwarcia INW-WG/2026/001) się nie zmieniają.
Uruchomienie: python backfill_fg_history.py [--dry]   (skrypt jest idempotentny: pomija zamówienia, które mają już dokument WZ)
"""
import os
import sys
from datetime import date, timedelta

import psycopg
from psycopg.rows import dict_row

DRY = '--dry' in sys.argv
CARRIERS = ['DHL Freight', 'DB Schenker', 'Raben Logistics', 'Transport własny PLASTEMA', 'Odbiór własny klienta']
NOTE_HIST = 'Dokument historyczny uzupełniony na podstawie raportu produkcyjnego 2026 — data wydania i przewoźnik są FIKCYJNE.'


def add_workdays(day, n):
    while n > 0:
        day += timedelta(days=1)
        if day.weekday() < 5:
            n -= 1
    return day


def main():
    today = date.today()
    conn = psycopg.connect(os.environ['DATABASE_URL'], row_factory=dict_row)
    cur = conn.cursor()
    cur.execute('SELECT pg_advisory_xact_lock(6102035)')
    cur.execute('''SELECT o.*, c.short_name, c.street, c.postal_code, c.city FROM orders o JOIN clients c ON c.id = o.client_id
                   WHERE o.status = 'ZREALIZOWANE' AND NOT EXISTS (SELECT 1 FROM fg_docs d WHERE d.zk_order_id = o.id)
                   ORDER BY o.order_date, o.id''')
    orders = cur.fetchall()
    cur.execute('''SELECT DISTINCT ON (l.id) l.id AS line_id, p.id AS pid, p.batch_code, p.start_date, p.end_date, p.machine_no, p.qty
                   FROM order_lines l JOIN orders o ON o.id = l.order_id
                   JOIN productions p ON p.source = 'EXCEL' AND p.product_id = l.product_id AND COALESCE(p.internal_order, '') = COALESCE(o.internal_no, '')
                   ORDER BY l.id, (p.end_date IS NOT NULL) DESC, (p.batch_code IS NOT NULL) DESC, p.id''')
    prod = {r['line_id']: r for r in cur.fetchall()}
    cur.execute("SELECT product_id, batch_code, MIN(location) AS location FROM fg_moves WHERE location IS NOT NULL GROUP BY 1, 2")
    known_loc = {(r['product_id'], r['batch_code']): r['location'] for r in cur.fetchall()}
    cur.execute("SELECT COALESCE(MAX(CAST(SPLIT_PART(number, '/', 3) AS INTEGER)), 0) AS n FROM fg_docs WHERE doc_type = 'WZ' AND number LIKE %s", ('WZ/2026/%',))
    counters = {2026: cur.fetchone()['n']}
    plan = []
    for o in orders:
        cur.execute('SELECT * FROM order_lines WHERE order_id = %s AND product_id IS NOT NULL AND COALESCE(qty, 0) > 0 ORDER BY lp', (o['id'],))
        lines = cur.fetchall()
        if not lines:
            continue
        items = []
        for l in lines:
            p = prod.get(l['id'])
            end = (p and p['end_date']) or l['prod_end'] or (p and p['start_date']) or l['prod_start'] or max(o['order_date'], o['planned_end'].date() if o['planned_end'] else o['order_date'])
            end = max(end, o['order_date'])
            batch = (p and p['batch_code']) or l['batch_code'] or None
            start = (p and p['start_date']) or l['prod_start'] or end
            items.append((l, batch, start, end, p and p['machine_no']))
        plan.append((o, items))
    plan.sort(key=lambda x: (max(i[3] for i in x[1]), x[0]['id']))
    docs = 0
    for o, items in plan:
        last_end = max(i[3] for i in items)
        ship = min(add_workdays(last_end, 1 + o['id'] % 3), today)
        carrier = CARRIERS[o['id'] % len(CARRIERS)]
        counters[ship.year] = counters.get(ship.year, 0) + 1 if ship.year != 2026 else counters[2026] + 1
        if ship.year != 2026 and counters[ship.year] == 1:
            cur.execute("SELECT COALESCE(MAX(CAST(SPLIT_PART(number, '/', 3) AS INTEGER)), 0) AS n FROM fg_docs WHERE doc_type = 'WZ' AND number LIKE %s", (f'WZ/{ship.year}/%',))
            counters[ship.year] = cur.fetchone()['n'] + 1
        number = f'WZ/{ship.year}/{counters[ship.year]:03d}'
        address = ', '.join(x for x in (o['street'], f'{o["postal_code"] or ""} {o["city"] or ""}'.strip()) if x)
        cur.execute('''INSERT INTO fg_docs (number, doc_type, client_id, zk_order_id, doc_date, status, carrier, delivery_address, notes, created_by, realized_by, realized_at)
                       VALUES (%s,'WZ',%s,%s,%s,'ZREALIZOWANY',%s,%s,%s,'import historyczny','import historyczny',%s) RETURNING id''',
                    (number, o['client_id'], o['id'], ship, carrier, address, NOTE_HIST, f'{ship} 14:00+02'))
        doc_id = cur.fetchone()['id']
        for l, batch, start, end, machine in items:
            location = known_loc.get((l['product_id'], batch)) or f'R{1 + l["id"] % 6}-{"ABCD"[l["id"] % 4]}{1 + l["id"] % 5}'
            cur.execute('''INSERT INTO fg_moves (move_date, move_type, product_id, qty, batch_code, location) VALUES (%s,'PW',%s,%s,%s,%s)''',
                        (end, l['product_id'], l['qty'], batch, location))
            cur.execute('''INSERT INTO fg_doc_lines (doc_id, product_id, order_line_id, batch_code, location, qty) VALUES (%s,%s,%s,%s,%s,%s)''',
                        (doc_id, l['product_id'], l['id'], batch, location, l['qty']))
            cur.execute('''INSERT INTO fg_moves (move_date, move_type, product_id, qty, batch_code, location, doc_id, order_line_id)
                           VALUES (%s,'WZ',%s,%s,%s,%s,%s,%s)''', (ship, l['product_id'], -l['qty'], batch, location, doc_id, l['id']))
            cur.execute('''UPDATE order_lines SET batch_code = COALESCE(batch_code, %s), prod_start = COALESCE(prod_start, %s), prod_end = COALESCE(prod_end, %s),
                           machine_no = COALESCE(machine_no, %s) WHERE id = %s''',
                        (batch, start, end, int(machine) if machine and str(machine).strip().isdigit() and int(machine) < 100 else None, l['id']))
        # pola zamówienia: tylko puste
        receiver = ('Jakub Majchrzak' if o['id'] % 2 else 'Ania Kwiatek') if (o['channel'] or '').startswith('telefon') else 'zamowienia@plastema.pl'
        batches = ', '.join(sorted({i[1] for i in items if i[1]})) or 'brak'
        note = (f'Wydano {number} dnia {ship:%d.%m.%Y}, przewoźnik: {carrier}; szarże: {batches}; produkcja zakończona {last_end:%d.%m.%Y}. '
                '[Dane historyczne uzupełnione automatycznie: odbiorca, nr zam. klienta, data wydania i przewoźnik są fikcyjne.]')
        cur.execute('''UPDATE orders SET received_by = COALESCE(NULLIF(received_by, ''), %s), client_ref = COALESCE(NULLIF(client_ref, ''), %s),
                       notes = COALESCE(NULLIF(notes, ''), %s), delivery_date = COALESCE(delivery_date, %s),
                       finished_at = COALESCE(finished_at, %s) WHERE id = %s''',
                    (receiver, f'{o["short_name"]}/{o["order_date"]:%y}/{o["seq"]:04d}', note, ship, f'{ship} 14:00+02', o['id']))
        docs += 1
    print(f'zamówień: {docs}, dokumentów WZ: {docs}')
    if DRY:
        conn.rollback()
        print('DRY RUN — wycofano')
    else:
        conn.commit()


main()
