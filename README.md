# M1 — Magazyn surowców

Aplikacja Docker do zarządzania relacyjną bazą dostawców i osób kontaktowych.

## Dane

- suppliers — dostawcy z arkusza DOSTAWCY TWORZYW
- contacts — osoby z arkusza DOSTAWCY TWORZ_OSOBY KONTAKT
- relacja: contacts.supplier_id do suppliers.id z ON DELETE CASCADE
- PostgreSQL przechowuje dane w katalogu postgres-data/

## Uruchomienie

Polecenie: docker compose up -d --build

Excel jest importowany transakcyjnie tylko przy pustej bazie. Kolejne uruchomienia nie nadpisują zmian użytkowników.
