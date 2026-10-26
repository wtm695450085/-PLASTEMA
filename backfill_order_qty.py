"""Jednorazowo: realne (okrągłe) ilości zamówione. Plik zamówień (FIKCYJNE_Zamowienia_klientow) przepisał do „Ilość zamówiona” ilość WYPRODUKOWANĄ
ze statystyki produkcji, a klienci zamawiają okrągłe liczby (np. 5250), produkcja z reguły wychodzi trochę więcej (pełne cykle/kartony).
Ilość zamówiona = ilość produkcji zaokrąglona w dół do okrągłej wielokrotności (krok zależny od wielkości). Produkcja i WZ zostają bez zmian —
klient dostaje całą wyprodukowaną ilość (tolerancja ilościowa). Uruchomienie: python backfill_order_qty.py [--dry]"""
import os
import sys

import psycopg
from psycopg.rows import dict_row


def nice_floor(q):
    unit = 10 if q < 300 else 50 if q < 3000 else 250 if q < 20000 else 1000 if q < 100000 else 5000
    return (q // unit) * unit if q >= unit else q


conn = psycopg.connect(os.environ['DATABASE_URL'], row_factory=dict_row)
cur = conn.cursor()
cur.execute('''SELECT l.id, l.qty, (SELECT SUM(p.qty) FROM productions p JOIN orders o ON o.id = l.order_id
                                     WHERE p.source = 'EXCEL' AND p.product_id = l.product_id
                                       AND COALESCE(p.internal_order, '') = COALESCE(o.internal_no, '')) AS produced
               FROM order_lines l WHERE l.qty > 0 ORDER BY l.id''')
changed = same = 0
for r in cur.fetchall():
    base = int(r['produced'] or r['qty'])
    new = nice_floor(base)
    if new != r['qty']:
        cur.execute('UPDATE order_lines SET qty = %s WHERE id = %s', (new, r['id']))
        changed += 1
    else:
        same += 1
print(f'zmieniono: {changed}, bez zmian (już okrągłe): {same}')
if '--dry' in sys.argv:
    conn.rollback()
    print('DRY RUN')
else:
    conn.commit()
