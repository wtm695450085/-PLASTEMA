# Protokół przekazania — M1 Magazyn surowców

**Data:** 2026-09-25  
**Katalog projektu:** `/PLASTEMA/M1-magazyn-surowców`  
**Stan:** aplikacja działa; dalsze prace zostały wstrzymane na polecenie użytkownika.

## 1. Zakres wykonany i działający produkcyjnie

- Zbudowano aplikację webową Flask/Gunicorn w Dockerze.
- Dodano logowanie sesyjne, ochronę CSRF i nagłówki bezpieczeństwa.
- Dodano formularze dostawców: dodawanie, edycja, usuwanie.
- Dodano wyszukiwanie i filtrowanie dostawców.
- Zastosowano stylistykę kawową i bladożółtą.
- Skonfigurowano Nginx dla `magazyn-surowcow.sigmaquality.pl` na porcie aplikacji `8510`.
- Przygotowano Docker Compose z PostgreSQL 17.
- PostgreSQL działa w kontenerze `m1-magazyn-postgres`.
- Aplikacja działa w kontenerze `m1-magazyn-surowcow`.
- Kontenery mają status `healthy`.
- Endpoint kontrolny zwraca:

  ```json
  {"database":"postgresql","status":"ok"}
  ```

## 2. Aktualny stan danych PostgreSQL

- Tabela `suppliers`: **29 dostawców**.
- Tabela `contacts`: **17 osób kontaktowych**.
- Dostawcy według rodzaju:
  - 25 — `TWORZYWO`;
  - 4 — `BARWNIK`.
- Relacja: `contacts.supplier_id -> suppliers.id`.
- Usuwanie dostawcy ma `ON DELETE CASCADE` dla powiązanych kontaktów.
- Kontakty z pierwszej zakładki kontaktowej są powiązane z dostawcami.
- `DB001–DB004` z zakładki „DOSTAWCY BARWNIKÓW” zostały zsynchronizowane bez duplikatów.
- `DT025 – ULTRA POLYMERS` został utworzony jako uzupełniający dostawca, ponieważ występował w zakładce kontaktowej, ale nie w pierwszej tabeli dostawców.

## 3. Źródła danych Excel

Plik źródłowy: `BAZA DOSTAWCÓW 1.xlsx`.

Obsłużone i zaimportowane produkcyjnie:

- `DOSTAWCY TWORZYW`;
- `DOSTAWCY TWORZ_OSOBY KONTAKT `;
- `DOSTAWCY BARWNIKÓW`.

## 4. Dane dostępowe

- Login aplikacji: `admin`.
- Hasło zostało wygenerowane i przekazane operatorowi w osobnej wiadomości.
- Hash hasła i sekret sesji znajdują się w chronionym pliku `.env` (`chmod 600`).
- Hasła PostgreSQL znajdują się wyłącznie w `.env`; nie są wpisane w kodzie aplikacji.

## 5. Ważne pliki

- `app.py` — backend Flask, import Excel, obsługa dostawców i kontaktów.
- `templates/` — widoki HTML.
- `static/` — style i JavaScript.
- `docker-compose.yml` — aplikacja + PostgreSQL.
- `Dockerfile` — obraz aplikacji.
- `postgres-data/` — trwałe dane PostgreSQL; **nie usuwać**.
- `data/suppliers.sqlite.backup` — kopia poprzedniej bazy SQLite.
- `BAZA DOSTAWCÓW 1.xlsx` — plik źródłowy.
- `nginx.conf` — konfiguracja reverse proxy.

## 6. Prace rozpoczęte, ale niewdrożone

Ostatnie polecenie dotyczyło zakładki `DOSTAWCY BARW._OSOBY KONT. `. Arkusz zawiera 6 osób kontaktowych:

- 2 × `DB001`;
- 1 × `DB002`;
- 1 × `DB003`;
- 2 × `DB004`.

W pliku roboczym przygotowano zmiany modelu kontaktów o pole `position` („Stanowisko”) oraz importer tej zakładki, ale **nie zostały one przebudowane i uruchomione produkcyjnie**. Aktualny działający obraz nadal ma 17 kontaktów i nie zawiera tych 6 nowych kontaktów.

Przed wdrożeniem należy:

1. poprawić i zweryfikować widok formularza kontaktu z polem „Stanowisko”;
2. wykonać migrację PostgreSQL `contacts.position`;
3. zaimportować 6 kontaktów z użyciem bezpiecznego UPSERT/deduplikacji;
4. przebudować kontener aplikacji;
5. wykonać test logowania, wyświetlania, edycji i usuwania kontaktu;
6. sprawdzić końcową liczbę kontaktów (oczekiwane: 23).

## 7. Dostęp publiczny / HTTPS

Nginx jest skonfigurowany dla `magazyn-surowcow.sigmaquality.pl` i przekazuje ruch na `127.0.0.1:8510`.

Do uruchomienia publicznego HTTPS nadal potrzebny jest rekord DNS:

```text
A  magazyn-surowcow  62.72.20.95
```

Po propagacji DNS należy wystawić certyfikat Let's Encrypt i dodać blok SSL w Nginx. Do tego czasu aplikacja jest dostępna lokalnie na VPS przez port `8510` oraz przez konfigurację HTTP Nginx.

## 8. Wznowienie prac

W katalogu projektu:

```bash
docker compose ps
docker compose logs --tail=100 app
docker compose up -d --build
```

Nie wykonywać `docker compose down -v` ani usuwać katalogu `postgres-data`, ponieważ spowoduje to utratę bazy PostgreSQL.

## 9. Addendum — wykaz tworzyw

Dodano osobną tabelę PostgreSQL `materials` dla zakładki `WYKAZ TWORZYW`.

- Zaimportowano 73 rekordy.
- Nadano indeksy `TS001`–`TS073`.
- Każdy rekord ma relację `supplier_id` do tabeli `suppliers`.
- Zachowano nazwę dostawcy z arkusza jako dane źródłowe; przy `DT025` odnotowano rozbieżność nazwy dostawcy (LOOPLIFE w wykazie, ULTRA POLYMERS w bazie dostawców).
- Dodano wyszukiwarkę po indeksie TS, nazwie, symbolu i dostawcy.
- Dodano filtrowanie po rodzaju tworzywa i kolorze.
- Dodano formularze dodawania, edycji i usuwania tworzyw.
- Nowe rekordy otrzymują kolejny indeks, np. `TS074`.
- Dodano link „Wykaz tworzyw” w nawigacji aplikacji.
- Kontener aplikacji i PostgreSQL są aktualnie zdrowe.
- Test wyszukiwania oraz pełny cykl dodanie–edycja–usunięcie rekordu zakończył się poprawnie.

### Aktualny stan po addendum

- `suppliers`: 29
- `contacts`: 17
- `materials`: 73

Nadal otwartym punktem z wcześniejszego przekazania pozostaje produkcyjny import 6 kontaktów z zakładki `DOSTAWCY BARW._OSOBY KONT. ` oraz wdrożenie HTTPS po ustawieniu DNS.

## 10. Addendum — indeksacja SS / BT

Indeksacja tabeli `materials` została zmieniona zgodnie z nomenklaturą użytkownika:

- `SS001…` — **Surowiec Sypki**;
- `BT001…` — **Barwnik Tworzywa**.

Wykonano migrację istniejących pozycji `TS001…TS073` na `SS001…SS073` oraz ustawiono kategorię `SUROWIEC SYPKI`. Formularz dodawania i edycji ma teraz wybór kategorii SS/BT; nowe rekordy otrzymują następny indeks w odpowiedniej serii. Test utworzenia i usunięcia `BT001` zakończył się poprawnie, bez pozostawienia rekordu testowego.

## 11. Addendum — HTTPS

Domena `magazyn-surowcow.sigmaquality.pl` otrzymała rekord DNS A wskazujący na `62.72.20.95`. Wystawiono i wdrożono certyfikat Let's Encrypt.

- Adres produkcyjny: https://magazyn-surowcow.sigmaquality.pl/
- Certyfikat: `/etc/letsencrypt/live/magazyn-surowcow.sigmaquality.pl/`
- Ważność certyfikatu: do 2026-12-24.
- Certbot skonfigurował automatyczne odnowienie.
- HTTP przekierowuje do HTTPS.
- HTTPS trafia do aplikacji magazynu surowców, nie do domyślnej aplikacji Nginx.

## 12. Addendum — nawigacja główna

Na brązowym pasku aplikacji dodano cztery przyciski nawigacyjne:

- Wykaz tworzyw — lista kategorii `SS`;
- Wykaz dostawców tworzyw — filtr `TWORZYWO`;
- Wykaz dostawców barwników — filtr `BARWNIK`;
- Wykaz barwników — lista kategorii `BT`.

Wszystkie przyciski i trasy zostały sprawdzone po zalogowaniu.

## 13. Korekta klasyfikacji barwników

Żółte rekordy z arkusza są dostawcami barwników, a nie pozycjami materiałowymi barwników. Usunięto techniczne rekordy `BT001–BT004` z tabeli `materials`.

- `suppliers`: dostawcy `DB001–DB004` pozostają w kategorii `BARWNIK` i są dostępni przez „Wykaz dostawców barwników”;
- `materials`: pozostaje 73 pozycji `SS001–SS073`;
- „Wykaz barwników” informuje, że nie ma jeszcze osobnych pozycji barwnikowych;
- seria `BT` jest zarezerwowana dla przyszłych rzeczywistych danych barwników.

## 14. Addendum — import barwników z inwentury (2026-09-29)

Źródło: `ikony/Inwentura_09.2026_TUTAJ_UZUPENIA.xlsx`, zakładka `Barwniki`.

- Zaimportowano 109 pozycji do `materials` jako `BARWNIK TWORZYWA`, indeksy `BT001–BT109` (kolejność jak w arkuszu).
- Relacje z dostawcami: GABRIEL CHEMIE → DB002 (20), GM COLOR → DB003 (44), WEST → DB004 (29), LIFO COLOR → DB001 (5).
- 11 pozycji nie ma dostawcy w bazie `suppliers` (COLOR TONE 4, COLOR PLAST 4, GLOBAL COLORS 2, TER PLASTICS 1). Mają nazwę dostawcy z arkusza, a `supplier_id` jest pusty.
- Cena z arkusza trafiła do `unit_price`/`price_pln` (PLN/KG). Stan z 31.08.2026 i uwagi z arkusza są w polu `notes`. Kolumna stanu na 25.09.2026 w arkuszu była pusta.
- Pominięto luźne wiersze pod sumą arkusza (191384, 191385, 191378, „GM 81071P”), bo nie mają pełnych danych.
- Kopia bazy sprzed importu: `data/backup_przed_barwnikami_20260929_085649.sql`.

Stan: `materials` = 182 (73 SS + 109 BT).

## 15. Addendum — nowi dostawcy barwników (2026-09-29)

- Dodano dostawców: `DB005` COLOR TONE, `DB006` COLOR PLAST, `DB007` GLOBAL COLORS. Każdy ma w nazwie dopisek „(wymaga uzupełnienia)”, a w uwagach listę brakujących danych (adres, NIP, telefon, www, warunki płatności, kontakt). Po uzupełnieniu danych dopisek należy usunąć z nazwy.
- TER PLASTICS nie został zdublowany: barwnik `TEREZ XG DE 9000` (BT100) jest powiązany z istniejącym dostawcą `DT005` TER Plastics.
- Wszystkie 109 barwników z arkusza mają teraz relację z dostawcą.
- Dodano pozycje spod sumy arkusza: `BT110` 191384 BEŻOWY (50 kg), `BT111` 191385 SZARY (13 kg), `BT112` 191378 J.SZARY (0 kg). Mają dostawcę „(wymaga uzupełnienia)” i nie mają ceny. „GM 81071P” pominięto, bo to już `BT034` (GM-81071P).
- Kopia bazy sprzed zmian: `data/backup_przed_dostawcami_barwnikow_20260929_085947.sql`.

Stan: `suppliers` = 32, `materials` = 185 (73 SS + 112 BT).

## 16. Addendum — moduł ANIA (2026-09-29)

- Aplikacja nazywa się **moduł ANIA**. W lewym górnym rogu paska jest okrągła ikona (dziewczyna z ciemnymi włosami, `static/ania.png`) z podpisem „ANIA / PLASTEMA · Magazyn surowców”. Ta sama ikona służy jako favicon (`static/favicon.png`), a karta przeglądarki ma tytuł „ANIA · Magazyn surowców”.
- Kolejność przycisków: Tworzywa → Barwniki → Dostawcy tworzyw → Dostawcy barwników.
- Kontener aplikacji przebudowano; ma status healthy.

## 17. Addendum — stany magazynowe i inwentaryzacja (2026-09-29)

Nowy moduł `inventory.py`, tabele `inventories` (nagłówek spisu) i `inventory_lines` (pozycje: poprzedni stan, policzono kg, cena, uwagi).

- **Stany magazynowe** (`/stany`): stan każdej pozycji pochodzi z ostatniego zatwierdzonego spisu, w którym ją policzono. Strona pokazuje kafelki kg/wartość dla SS i BT, filtry i link do spisu źródłowego.
- **Inwentaryzacja** (`/inwentaryzacje`): nowy arkusz (data, zakres: wszystko / SS / BT, spisujący). Formularz ma wyszukiwarkę, filtr „tylko niepoliczone”, liczy na bieżąco różnicę i wartość, a Enter przechodzi do następnej pozycji. Arkusz można zapisywać wielokrotnie. „Zapisz i zatwierdź” aktualizuje stany i blokuje arkusz. Otwarty arkusz można usunąć, zatwierdzonego nie. Jest też wydruk A4 poziomo z miejscem na podpisy (`?druk=1`).
- Import historii z `ikony/Inwentura_09.2026_TUTAJ_UZUPENIA.xlsx` (4 zatwierdzone spisy):
  - `INW/2026/001` 31.08.2026 — wszystko: 77 tworzyw (kolumna J — druga „KG”, z nią zgadza się wartość w arkuszu) + 112 barwników;
  - `INW/2026/002` 11.09, `003` 18.09, `004` 25.09 — tylko tworzywa.
  - Sumy wartości tworzyw zgadzają się z Excelem co do grosza. Barwniki: 137 591,34 zł w aplikacji, a w Excelu 136 093,84 zł, bo formuła `I113 =SUM(I4:I110)` pomija 2 ostatnie wiersze (GM-53578E, GM-50977).
- Nowe karty z inwentury (nie było ich w kartotece): `SS074` PLASTOPLAN ABS HI121H, `SS075` PLASTOPLAN ASA LI911, `SS076` BCD TIPPLEN R960A, `SS077` EKOCHEM TPE (druga partia 8,70 zł/kg), `SS078` HEXPOL DRYFLEX PCR-403621-2. Uwagi: „wymaga uzupełnienia”.
- Wiersz 29 bez nazwy (POLIMER, PA6 bez włókna B1) przypisano do `SS012`. `SS011` (PC 12.20 UR) nie występuje w inwenturze — „brak spisu”.
- Nawigacja: dodano zielone przyciski „Stany magazynowe” i „Inwentaryzacja”. Poprawiono filtr w wykazie barwników (nie przeskakuje już do tworzyw).
- Kopia bazy sprzed zmian: `data/backup_przed_inwentaryzacja_20260929_094542.sql`.

Stan po imporcie: `materials` = 190 (78 SS + 112 BT), wartość magazynu 1 013 801,62 zł (SS 876 210,28 wg 25.09 + BT 137 591,34 wg 31.08).

## 18. Addendum — różnice inwentaryzacyjne (2026-09-29)

- **Próg dużej różnicy**: pole „Próg dużej różnicy inwentaryzacyjnej” (w %) na arkuszu spisu, zapisywane w tabeli `app_settings` (`diff_threshold_pct`, domyślnie 5). Pozycja z różnicą ≥ progu jest zaznaczona na czerwono (także na żywo podczas wpisywania), a nad tabelą jest licznik dużych różnic i tych bez wyjaśnienia. Jest filtr „Tylko duże różnice”.
- **Różnica** = policzono − poprzedni stan (`expected_kg`). System nie rejestruje jeszcze przyjęć ani wydań, więc różnica obejmuje też normalne zużycie między spisami. Przy dodaniu przyjęć/wydań zmienić należy tylko źródło stanu oczekiwanego (`expected_kg` przy tworzeniu arkusza).
- **Formularz różnicy** (`/inwentaryzacje/<id>/roznice/<linia>`): u góry duża kwota różnicy w kg, w % i w zł, potem wybór jednego z 6 powodów: nieautoryzowany pobór, błąd przyjęcia, błąd wydania, błąd ważenia, straty technologiczne, brak wyjaśnienia. Poniżej duże pole opisu i pole „wyjaśnił(a)”. Przycisk „Zapisz i następna” przechodzi do kolejnej niewyjaśnionej różnicy. Dane w kolumnach `diff_*` tabeli `inventory_lines`. Nie da się zatwierdzić spisu bez ostrzeżenia, gdy są niewyjaśnione duże różnice.
- **Analiza różnic** (`/analiza-roznic`): tylko zatwierdzone spisy, zakres dat od–do i kategoria. Pokazuje wartość braków i nadwyżek, przyczyny (wykres), różnice w kolejnych spisach, ranking surowców z największą liczbą braków oraz listę dużych różnic bez wyjaśnienia.
- Uwaga techniczna: CSP aplikacji blokuje style inline, więc słupki wykresów są ustawiane przez `data-w` + `static/inventory.js`.
- Kopia bazy przed zmianą: `data/backup_przed_roznicami_20260929_100507.sql`.
- W bazie jest otwarty, pusty arkusz `INW/2026/005` (zakres: wszystko), założony w przeglądarce 29.09 ok. 09:55 — nie jest testowy.

## 19. Addendum — strona kontaktów dostawcy (2026-09-29)

- W listach „Dostawcy tworzyw” i „Dostawcy barwników” kolumna „Kontakty” ma teraz przycisk z liczbą osób, który otwiera stronę `/dostawcy/<id>/kontakty`.
- Strona pokazuje każdą osobę jako osobny formularz (imię i nazwisko, stanowisko, telefon, e-mail, uwagi) z przyciskami Zapisz i Usuń, a na dole formularz „Dodaj nową osobę kontaktową”.
- Dodawanie, edycja i usuwanie kontaktu wracają na tę stronę. Poprawiono zepsuty cudzysłów w polu „Stanowisko” w `contact_form.html`, a potwierdzenie usunięcia kontaktu ma własny komunikat.
- Nadal otwarte: import 6 kontaktów barwników z zakładki `DOSTAWCY BARW._OSOBY KONT. ` (punkt 6).

Korekta punktu 19: strona kontaktów pokazuje osoby jako czytelne karty tylko do odczytu (telefon = link `tel:`, e-mail = link `mailto:`, uruchamiający domyślny program pocztowy użytkownika). „Edytuj” otwiera osobny formularz kontaktu, a pod kartami jest mały przycisk „+ Dodaj osobę kontaktową” (bez formularzy na stronie).

## 20. Addendum — moduł „Magazyny przy maszynach” (2026-09-29)

Nowy moduł `machines.py` w ciemnozielonym motywie (`body.theme-green`), przycisk „Maszyny” na pasku. Tabele: `machines` (9 maszyn), `machine_docs` (dokumenty), `machine_doc_lines` (pozycje: surowiec + kg).

- **Pulpit** (`/maszyny`): 9 kart maszyn (kg i wartość na polu odkładczym, trzy największe pozycje) oraz lista „Do zrealizowania przez magazyniera” (otwarte dokumenty).
- **Strona maszyny** (`/maszyny/<1-9>`): zawartość pola odkładczego, 4 przyciski tworzące dokument i historia dokumentów maszyny.
- **4 typy dokumentów** (numeracja WM/UZ/ZU/ZW/rok/nr):
  - **Wydanie na maszynę (WM)** — magazyn główny → pole; surowiec wyszukuje się po indeksie/nazwie/kolorze (podpowiedzi), wpisuje kg; na dole przycisk **„Zrealizowano”** (magazynier faktycznie przeniósł surowiec, wpisuje swoje imię i nazwisko).
  - **Uzupełnienie pola (UZ)** — jak wydanie, ale w trakcie produkcji; wymagany powód (braki, szybsze zużycie, za mało wydano, zmiana planu, inny) — dane pod przyszłą analizę.
  - **Zużycie (ZU)** — zapis, ile faktycznie zużyto; nie można zapisać więcej, niż leży na polu.
  - **Zwrot niezużytego (ZW)** — procedura zwrotu: dokument podpowiada wszystko, co zostało na polu; przycisk „Przyjęto na magazyn główny” zwraca surowiec do magazynu głównego.
- Ruch następuje dopiero po realizacji dokumentu; zrealizowanego dokumentu nie można zmienić ani usunąć. Wydanie ponad stan magazynu głównego jest dozwolone, ale system ostrzega.
- **Integracja ze stanami**: stan magazynu głównego = ostatni spis + zrealizowane ruchy po dniu spisu (wydania/uzupełnienia −, zwroty +). Strona „Stany magazynowe” ma kolumnę „Na maszynach”, a nowy arkusz inwentaryzacji bierze jako „poprzedni stan” już stan z ruchami (dzięki temu różnice inwentaryzacyjne nie obejmują normalnego wydania na produkcję).
- Historia dokumentów: `/maszyny/dokumenty` (zakres dat, maszyna, typ, status).
- Surowca z historią ruchów na maszynach nie można usunąć z kartoteki (komunikat zamiast błędu).
- Kopia bazy sprzed zmiany: `data/backup_przed_maszynami_20260929_103615.sql`. Dane testowe usunięto.
- Brak jeszcze powiązania z planem produkcji: numer zlecenia/pozycji planu wpisuje się ręcznie w polu „Zlecenie / plan produkcji”.

## 21. Addendum — podział pól, przyjęcie towaru (2026-09-29)

- **Dokument maszyny** (`/maszyny/dokument/<id>`): pozycje są podzielone na dwie osobne sekcje — **Tworzywa (SS)** i **Barwniki (BT)** — każda z własną tabelą, własnym polem wyszukiwania/dodawania i sumą. Próba dodania barwnika w sekcji tworzyw (i odwrotnie) daje czytelny komunikat. Dla wydań i uzupełnień jest kolumna „Zostanie w magazynie kg” liczona na żywo; lista podpowiedzi pokazuje stan magazynu głównego (dla zużycia i zwrotu — tylko to, co leży na polu maszyny).
- **Zmniejszanie magazynu głównego** po realizacji wydania/uzupełnienia działa bez inwentaryzacji (stan = ostatni spis + ruchy po dniu spisu, patrz pkt 20). Stan ujemny (np. BT014: −115,5 kg) oznacza, że w spisie było mniej, niż wydano — brakuje zapisu dostaw (przyjęć).
- **Przyjęcie towaru od dostawcy zewnętrznego** (`receipts.py`, tabele `receipts`, `receipt_lines`, przycisk „Przyjęcie towaru”, `/przyjecia`): dokument PZ/rok/nr z dostawcą (lista dostawców tworzyw i barwników), datą, nr WZ/faktury dostawcy, nr zamówienia i uwagami. Osobne sekcje Tworzywa i Barwniki; przy pozycji ilość kg, cena zł/kg (domyślnie z kartoteki), nr partii/LOT, uwagi. Podpowiedzi ograniczają się do surowców wybranego dostawcy (można pokazać wszystkie). Przycisk „Przyjęto na magazyn” (wymaga dostawcy, pozycji z ilością i osoby przyjmującej) zwiększa stan magazynu głównego od razu; dokumentu przyjętego nie można zmienić ani usunąć.
- Cena z przyjęcia jest tylko zapisana w dokumencie (wartość dostawy) — nie zmienia ceny w kartotece ani wyceny stanów.
- Nawigacja zawija się do drugiego wiersza, gdy przycisków jest za dużo.
- Kopie bazy: `data/backup_przed_przyjeciami_20260929_104829.sql`. Dane testowe usunięto; dokumenty użytkownika (WM/2026/001 zrealizowany, WM/2026/002 otwarty, maszyna 1) pozostawiono.

## 22. Addendum — moduł ZAMÓWIENIA (2026-10-16)

Aplikacja jest teraz jednym modułem **Zamówienia i magazyn**: nowe tabele w tej samej bazie PostgreSQL M1, niebieski motyw (`body.theme-blue`), przyciski na pasku: Zamówienia, Plan maszyn, Klienci, Produkty, Formy, Kolory. Kod: `orders.py` (trasy, planowanie), `order_seed.py` (import startowy), `seed/m2_codes.json`, `static/orders.js`. Logika według `ikony/kodowanie Plastema K2.odt`.

**Źródła importu** (katalog `ikony/` montowany tylko do odczytu jako `/app/source/ikony`; import uruchamia się tylko przy pustej tabeli `clients`):
- `FIKCYJNA_Baza_klientow_produkcyjnych_dane_fikcyjne.xlsx` → `clients` (26). Dane są fikcyjne, poza FIBOO.
- `Baza_produktow_PLASTEMA.xlsx` → `products` (548).
- `LISTA FORM 06.10.2026.xlsx` → `molds` (231, numer formy EEE = „Indeks formy”, pominięto wiersze bez indeksu).
- `FIKCYJNE_Zamowienia_klientow_PLASTEMA.xlsx` → `orders` (353) + `order_lines` (706). Historyczne statusy: 342 zrealizowane, 11 w produkcji.
- Słownik kolorów `colors` (23) wyprowadzono z nazw produktów; `000` = naturalny / bez barwnika.

**Kody** (spójne z aplikacją M2-monika — kody AAA i BBBB przejęte z jej bazy, `seed/m2_codes.json`):
- Zamówienie: `ZK AAA RR MM DD NNN` (NNN = kolejne zamówienie klienta w danym roku). Historyczne `ZK/OKIDAY/001/2026` przekodowano, a stary numer jest w `source_ref`.
- Kod produkcji `AAA-BBBB-CCC`, pełny kod `AAA-BBBB-CCC-EEE-FFF-GGG`: EEE = forma, FFF = numer tworzywa SS z magazynu (SS032 → 032), GGG = numer barwnika BT (BT021 → 021, bez barwnika 000).
- Kod szarży `N-Z-S-DDMMRR` nadawany przy starcie produkcji (maszyna, zmiana, kolejna szarża na zmianie, data).
- Kody kreskowe Code 128 (biblioteka `python-barcode`, SVG w data URI).

**Przebieg zamówienia** (statusy NOWE → PRZYJĘTE → W PRODUKCJI → ZREALIZOWANE / ANULOWANE):
1. Formularz `/zamowienia/nowe`: klient, a potem pozycje z podpowiedzią produktów tego klienta. Zapis nadaje kod ZK.
2. Karta zamówienia (status NOWE) na żywo sprawdza dla każdej pozycji: parę klient–produkt (stara/nowa), formę (przypisana, status SPRAWNA, wolna), surowiec i barwnik (stan magazynu M1 − rezerwacje zamówień PRZYJĘTYCH; przy braku start przesuwa się o czas dostawy z kartoteki, domyślnie 7 dni) oraz wtryskarkę (maszyny z historii produktu, pierwsza wolna). Brak formy albo forma w naprawie blokuje przyjęcie.
3. „Przyjmij do realizacji” zapisuje maszynę, terminy, zapotrzebowanie kg i kody; rezerwuje surowiec i czas maszyny/formy. Daje się to cofnąć („Cofnij przyjęcie”).
4. Linki ✉ otwierają program pocztowy z gotową wiadomością do klienta: o odebraniu zamówienia i o dacie dostawy. Nic nie jest wysyłane automatycznie.
5. „Rozpocznij produkcję” nadaje kody szarży. Surowiec wydaje magazynier dokumentem WM w module Maszyny (bez automatycznego powiązania). Rezerwacja surowca obowiązuje tylko w statusie PRZYJĘTE.

**Planowanie** (`/plan-maszyn`, parametry w `app_settings`, `plan_*`): 3 zmiany od 6:00, pn–pt, przezbrojenie 4 h, transport 2 dni robocze, naddatek na odpad 3%. Czas = ilość ÷ (detale na zmianę ÷ 8 h) + przezbrojenie. Zapotrzebowanie = ilość × waga brutto × (1 + naddatek), z podziałem na tworzywo i barwnik wg dozowania (z M2, domyślnie 2%).

**Uwaga — dopasowania automatyczne do weryfikacji:**
- Waga w bazie produktów jest w nagłówku opisana jako [kg], ale wartości to gramy (np. 143 g). Pola nazwano `net_g` / `gross_g`.
- Forma została dopasowana po nazwie dla 435 z 548 produktów i każde takie dopasowanie jest oznaczone „do weryfikacji” (`mold_match = 'AUTO'`). Potwierdza się je checkboxem w karcie produktu. 113 produktów nie ma formy, więc ich zamówienia będą blokowane do czasu przypisania (filtr „Bez formy” na liście produktów).
- Tworzywo SS przypisano dla 426 produktów, barwnik BT dla 380. Pozostałe (głównie regranulaty bez karty w magazynie) mają tylko opis tekstowy z raportu.
- 11 historycznych zamówień „w produkcji” nie ma terminów maszyn, więc nie obciążają planu.

Kopia bazy sprzed zmiany: `data/backup_przed_zamowieniami_20261016_081749.sql`. Test pełnego cyklu (nowe → przyjęte → produkcja → zrealizowane) wykonano, a dane testowe usunięto.

Stan: `clients` 26, `products` 548, `molds` 231, `colors` 23, `orders` 353, `order_lines` 706; dane magazynu bez zmian (`suppliers` 32, `materials` 190).

## 23. Addendum — paszport formy wtryskowej (2026-10-16)

Nowy moduł `molds.py` (trasy form usunięte z `orders.py`). Szablony: `molds.html` (lista), `mold_passport.html` (paszport), `mold_form.html` (edycja paszportu).

- **Kod formy EEE**: wymagany, 3 cyfry, unikalny. Przy nowej formie system proponuje kolejny wolny numer. Na paszporcie jest duży kod z kodem kreskowym. Wchodzi do pełnego kodu produkcji AAA-BBBB-CCC-EEE-FFF-GGG.
- **Paszport** (nowe kolumny w `molds`):
  - identyfikacja: klient, właściciel (własna / powierzona), wykonawca, nr rysunku, nr inwentarzowy, rok, data przyjęcia, wartość, pole;
  - konstrukcja: typ, gniazda, układ wlewowy, strefy gorących kanałów, przewężka, suwaki/rdzenie, wypychanie, wkładki, stal, HRC, powierzchnia;
  - montaż i technologia: gabaryty, masa, wysokość zabudowy, skok, pierścień centrujący, promień dyszy, siła zwarcia, wtryskarki, obiegi chłodzenia, temperatura formy, przyłącza, cykl, masa wtrysku, tworzywo;
  - żywotność: klasa SPI, gwarantowane cykle, licznik startowy, interwał przeglądów;
  - uwagi.
- **Zdjęcia** (`mold_photos`, w bazie jako BYTEA, więc są w `pg_dump`): 5 slotów formy (ogólny, strona dysz, strona wypychaczy, gniazda, tabliczka/przyłącza) i 2 sloty detalu. Plik wgrywa się od razu po wybraniu i jest pomniejszany do JPEG 1800 px z miniaturą 480 px. Obsługa JPG/PNG/WEBP/HEIC (Pillow + pillow-heif).
- **Historia użyć**: z pozycji zamówień W PRODUKCJI / ZREALIZOWANE (daty od–do, zamówienie ZK, produkt, ilość, cykle = ilość ÷ gniazda, maszyna, szarża) oraz osobno zaplanowane. Dla zamówień zaimportowanych forma jest brana z aktualnej karty produktu, więc poprawienie formy w produkcie poprawia historię.
- **Wskaźniki**: ostatnie użycie, liczba użyć, sztuki, licznik cykli (startowy + z historii), % żywotności, cykle do przeglądu, zajętość w planie.
- **Dziennik serwisowy** (`mold_events`): przegląd, naprawa, modyfikacja, czyszczenie, próba/odbiór, wydanie/zwrot; koszt, przestój, licznik; opcjonalna zmiana statusu. Przegląd lub naprawa zeruje licznik „do przeglądu”.
- **Statusy formy**: SPRAWNA, W PRZEGLĄDZIE, W NAPRAWIE, POZA ZAKŁADEM, WYCOFANA. Każdy inny niż SPRAWNA blokuje przyjęcie zamówienia.
- **Produkty z formy** z gotowymi kodami produkcji i pełnymi kodami (FFF = tworzywo SS, GGG = barwnik BT).
- Wydruk paszportu A4 (przycisk „Drukuj paszport”).
- Jednorazowe wstępne wypełnienie paszportów z istniejących danych: gniazda, cykl, klient, wtryskarki i tworzywo z produktów, gorące kanały, rdzenie i matryce z uwag listy form.

**Poprawka kolorów (CCC)**: lepsze rozpoznawanie koloru z nazwy produktu (C./J., JASNO/CIEMNO, odmiany: RÓŻ, POMARAŃCZ, FIOLET, ŻÓLTY…). Jednorazowo poprawiono 68 produktów. Bez koloru zostało 17 (nazwy bez koloru, np. „FIBOOWL M PSI BUFET”). Doszły kolory 023–028.

Kopia bazy: `data/backup_przed_paszportem_form_20261016_100007.sql`. Testy na produkcji (logowanie, wgranie zdjęć, odrzucenie złego pliku, wpis serwisowy) wykonano, a dane testowe usunięto.

## 23. Addendum — paszport formy wtryskowej (2026-10-16)

Nowy plik `molds.py` (trasy form przeniesione z `orders.py`) oraz szablony `molds.html`, `mold_passport.html`, `mold_form.html`.

- **Kod formy EEE**: każda forma ma unikalny 3-cyfrowy kod, nowa forma dostaje kolejny wolny numer. Kod jest pokazany z kodem kreskowym i wchodzi do pełnego kodu produkcji AAA-BBBB-CCC-**EEE**-FFF-GGG. Na paszporcie jest tabela produktów formy z gotowymi kodami produkcji i kodami tworzywa FFF / barwnika GGG.
- **Paszport** (`/formy/<id>`, edycja `/formy/<id>/edytuj`), cztery sekcje:
  - identyfikacja: klient, właściciel (forma własna / powierzona), wykonawca, nr rysunku, nr inwentarzowy, rok, data przyjęcia, wartość, miejsce składowania;
  - konstrukcja: typ, gniazda, układ wlewowy, strefy gorących kanałów, przewężka, suwaki/rdzenie, wypychanie, wkładki/matryce, stal, HRC, powierzchnia;
  - montaż i technologia: gabaryty, masa, wysokość zabudowy, skok, pierścień centrujący, promień dyszy, siła zwarcia, wtryskarki, obiegi chłodzenia, temperatura formy, przyłącza, cykl, masa wtrysku, zalecane tworzywo;
  - żywotność: klasa SPI, gwarantowana liczba cykli, licznik przy wprowadzeniu, interwał przeglądów.
- **Zdjęcia**: 5 zdjęć formy (widok ogólny, strona dysz, strona wypychaczy, gniazda, tabliczka/przyłącza) i 2 zdjęcia detalu. Tabela `mold_photos` (BYTEA, JPEG max 1800 px + miniatura 480 px, obrót wg EXIF, obsługa HEIC z iPhone'a). Zdjęcia są w bazie, więc trafiają do `pg_dump`. Wgrywają się od razu po wybraniu pliku.
- **Historia użyć**: z pozycji zamówień W PRODUKCJI / ZREALIZOWANE (daty od–do, zamówienie ZK, produkt, ilość, cykle = ilość ÷ gniazda, maszyna, szarża) oraz osobno pozycje zaplanowane. Dla zamówień z importu forma jest brana z aktualnej karty produktu, więc poprawienie formy w produkcie poprawia też historię. Kafelki: ostatnie użycie, liczba użyć i sztuk, licznik cykli, % żywotności, cykle do przeglądu, zajętość w planie.
- **Dziennik serwisowy** (`mold_events`): przegląd, naprawa, modyfikacja, czyszczenie, próba/odbiór, wydanie poza zakład i zwrot. Wpis ma koszt, przestój i stan licznika, a przy okazji wpisu można zmienić status formy. Przegląd/naprawa zeruje licznik „do przeglądu”.
- **Statusy formy**: SPRAWNA, W PRZEGLĄDZIE, W NAPRAWIE, POZA ZAKŁADEM, WYCOFANA. Każdy status inny niż SPRAWNA blokuje przyjęcie zamówienia.
- Wydruk paszportu (A4 pionowo) — przycisk „Drukuj paszport”.
- Jednorazowe wypełnienie paszportów z istniejących danych (flaga `molds_passport_v1`): gniazda, cykl, klient, wtryskarki, masa wtrysku, tworzywo z produktów formy; gorące kanały, rdzenie hydrauliczne i matryce z uwag listy form.

**Korekta kolorów CCC** (flagi `colors_v2`, `colors_v3`): rozpoznawanie koloru z nazwy obsługuje teraz skróty C./J., JASNO/CIEMNO i odmiany (RÓŻ, POMARAŃCZ, FIOLET, ŻÓLTY…). Poprawiono 68 produktów, a 67 kolejnych bez koloru w nazwie dostało kolor z barwnika BT. Nowe kolory: 023–028. Bez koloru zostało 17 produktów (barwnik spoza kartoteki) — do ustawienia ręcznie (filtr „bez koloru”).

Kontrola kodów: wszystkie 353 numery ZK mają poprawny format, a ich części zgadzają się z kodem klienta, datą i numerem kolejnym.

Kopia bazy sprzed zmiany: `data/backup_przed_paszportem_form_20261016_100007.sql`. Testy na produkcji (zdjęcia, dziennik, zmiana statusu) wykonane, dane testowe usunięte.

## 24. Addendum — moduł ROZLICZENIE PRODUKCJI (2026-10-16)

Według „Instrukcja_rozliczania_produkcji_Plastema_wersja_1”, kodowania K2 i statystyki produkcji. Nowe pliki: `settlement.py` (rozliczenie), `prod_stats.py` (statystyka, przeniesiona z M2-monika). Szablony: `settlement_*.html`, `_prod_order_header.html`, `statistics.html`, `finished_receipts.html`, `consumption.html`, `mold_mount_form.html`. Nawigacja: brązowe przyciski Rozliczenie produkcji, Statystyka, Przyjęcia wyrobów, Zużycie materiałów.

**Dokumenty instrukcji → system:**
- dok. 2 Zamówienie wewnętrzne → `prod_orders`: numer kolejny/rok, kontynuacja numeracji ze statystyki (pierwszy nowy to 362/2026). Zasada: 1 produkt, 1 maszyna, 1 forma.
- dok. 3 Specyfikacja (kolory) → `prod_colors`: ilość koloru, barwnik BT, dozowanie, dół specyfikacji, kolor „X” = nie produkowany.
- dok. 4 + 7 + 9 → `prod_shifts`: jeden wiersz = zmiana koloru (data, I/II/III, operator, kartony, szt./karton, wykonano, „zostało” wpisane przez operatora, licznik PLC, „od 0”, cykl s).
- dok. 6 Statystyka → `productions`: 706 wierszy z „2026 RAPORT_PRODUKCYJNY-STATYSTYKA (4).xlsx` (ten sam plik co w M2-monika), wszystkie powiązane z produktami. Rozliczenie koloru dopisuje wiersz (`source = 'ROZLICZENIE'`).
- dok. 10 Przyjęcie na magazyn → `prod_receipts`: numer PW MM/NNNN, godzina, przyjmujący.
- Etykiety kartonów (klient, produkt, kolor, ilość, data, pieczątka Q.C. z numerem pracownika, kod produkcji). Ostatni karton niepełny dostaje resztę.

**Obliczenia (zgodne z przykładem 296/2026, bordowy):**
- zostało = poprzednie − wykonano, nadwyżka „0 + N”;
- cykle zmiany = licznik − poprzedni licznik koloru (pierwsza zmiana koloru i „od 0” liczą od zera);
- braki = cykle × krotność − dobre, dla całego koloru (858 − 846 = 12, 1,4%);
- średnia na zmianę = ⌊28 800 ÷ cykl × krotność⌋ (660), realny cykl (43,636), waga 1 szt. brutto = wtrysk ÷ krotność;
- zużycie = cykle × wtrysk (109,6 kg, barwnik 2,2 kg).
- Licznik niepełny (zmiany bez odczytu): braki puste, a kolor można rozliczyć tylko po zaznaczeniu „z pustymi brakami” (jak granatowy w instrukcji).
- Blokada rozliczenia przy błędach K6, K7 lub K8 albo bez ważenia.
- Punkty kontrolne K1–K12 liczone automatycznie na zamówieniu i na kolorze. K11 to osobny raport: ubytek w inwenturze vs Σ cykle × wtrysk wyrobów zakończonych w okresie.

**Kod szarży N-Z-S-DDMMRR**: szarża = całe zamówienie wewnętrzne. Kod nadawany przy pierwszej wpisanej zmianie (maszyna, zmiana startu, kolejna szarża maszyny na tej zmianie w dniu, data). Dla historii z Excela zmiana startu nie jest znana, więc przyjęto Z = 1 (np. 296/2026 → `1-1-1-090926`).

**Powiązania:**
- Przyjęte ZK → „Przekaż do produkcji”: zamówienia wewnętrzne grupowane wg formy i maszyny, a ZK przechodzi w status W PRODUKCJI.
- Rozliczony kolor:
  - aktualizuje kartę produktu (wagi, cykl, wydajność, licznik zleceń);
  - tworzy na żądanie dokument zużycia ZU na maszynę, który magazynier zatwierdza w module Maszyny;
  - zasila rejestr montaży formy.
- Paszport formy: historia użyć i licznik cykli liczone teraz ze statystyki (licznik PLC; dla historii (dobre + braki) ÷ krotność).
- Planowanie maszyn: zmienione na 2 zmiany dziennie („plan zakłada 2 zmiany dziennie”).

**Paszport formy wg wzoru `PASZPORT_FORMY_KLIENT_NAZWA-PRODUKTU.xlsx`** — dodano:
- nazwę handlową produktu, wewnętrzny indeks produktu (BBBB) i datę utworzenia karty;
- opis sugerowanych przeglądów, przy czym „Stan początkowy — liczba cykli” już był;
- **rejestr montaży** (`mold_mounts`): data montażu i demontażu, liczba wtrysków, wydano do narzędziowni, powrót z narzędziowni, indeksy zdjęć, numer awarii (podpowiedź AW/RRRR/NNN), opis awarii, kto zakładał i demontował. Wpisy z rozliczenia tworzą się same, a montaże sprzed systemu są odtworzone ze statystyki i można je uzupełnić.

**Rozbieżności znalezione w danych źródłowych:**
- 296/2026 jasny szary: instrukcja podaje 836 dobrych (860 cykli, 24 braki), a statystyka (4) ma 874 szt. i 24 braki (874 > 860 cykli).
- SLOW FIBOOWL C.NIEBIESKI (311/2026): data końca wpisana tekstem „14,09.2026” (zaimportowana jako 14.09.2026), wzór „29/09-B” zamiast 26/09-….
- K11, SS015 HRC9480/230, 18.09→25.09: ubytek w inwenturze 1 540 kg, a zużycie wyrobów zakończonych w tym tygodniu 1 732 kg (113%). Kolor wlicza się w całości do tygodnia zakończenia, więc część zużycia przypada na tydzień 11–18.09.

Kopia bazy: `data/backup_przed_rozliczeniem_20261016_103141.sql`. Pełny scenariusz 296/2026 przetestowano na kopii bazy produkcyjnej (wyniki zgodne z instrukcją), a środowisko testowe usunięto. Produkcja nie zawiera danych testowych.

## 25. Addendum — MAGAZYN WYROBÓW GOTOWYCH (2026-10-16)

Nowy moduł `fg.py`, turkusowy motyw (`body.theme-teal`), przyciski „Magazyn wyrobów” i „WZ / ZW / INW”. Szablony `fg_stock.html`, `fg_product.html`, `fg_docs.html`, `fg_doc.html`.

- **Kartoteka `fg_moves`** jest jedynym źródłem stanu (ilość ze znakiem), na produkt (BBBB) i szarżę (N-Z-S-DDMMRR):
  - PW + przyjęcie z produkcji. Powstaje automatycznie przy przyjęciu PW w rozliczeniu koloru (dok. 10). Doszło pole „miejsce” (regał/paleta). Kolor bez wariantu produktu dostaje przy PW automatycznie nowy produkt BBBB „PRODUKT KOLOR” (nowa para klient–produkt).
  - WZ − wydanie do klienta.
  - ZW + zwrot od klienta (powód: reklamacja, pomyłka, transport…).
  - KOR ± korekta z inwentaryzacji INW-WG.
- **Dokumenty `fg_docs` / `fg_doc_lines`**: numeracja WZ/RRRR/NNN, ZW/RRRR/NNN, INW-WG/RRRR/NNN. Statusy OTWARTY → ZREALIZOWANY (realizacja wymaga osoby). Zrealizowanego nie można zmienić.
- **WZ z zamówienia ZK** (przycisk na karcie ZK albo lista „do wydania” na stanie magazynu):
  - pozostałe do wydania ilości pozycji ZK, szarże dobrane FIFO;
  - brak towaru to pozycja „bez szarży” i blokada realizacji;
  - po wydaniu całości ZK przechodzi automatycznie w ZREALIZOWANE, wydanie częściowe zostawia W PRODUKCJI;
  - link ✉ powiadamia klienta o wysyłce;
  - wydruk WZ z miejscem na podpisy.
- **Inwentaryzacja INW-WG**: arkusz z bieżącym stanem wszystkich szarż, ilości policzone, różnica liczona względem stanu w chwili zatwierdzenia. Pierwsza inwentaryzacja = bilans otwarcia (historia produkcji z Excela nie mówi, co dziś leży na magazynie).
- **Stan magazynu**: na stanie, kartony, szarże, miejsce, zamówione w otwartych ZK, wolne. Kartoteka produktu pokazuje ruchy ze stanem po każdym ruchu i powiązania PW ↔ zamówienie wewnętrzne, WZ ↔ ZK.
- **Zabezpieczenie**: nie można usunąć PW, z którego towar już wydano (stan zszedłby poniżej zera).

Kopia bazy: `data/backup_przed_magazynem_wyrobow_20261016_104350.sql`. Pełny obieg przetestowano na kopii bazy produkcyjnej (ZK → produkcja → PW → WZ częściowe i końcowe → ZW → INW), a środowisko testowe usunięto. Produkcja startuje z pustym magazynem wyrobów.

### 25a. Bilans otwarcia magazynu wyrobów — dane FIKCYJNE (2026-10-16)

Dokument **INW-WG/2026/001** (zrealizowany, wystawił „bilans otwarcia (dane fikcyjne)”) wprowadził demonstracyjne stany: **83 pozycje** (produkt + prawdziwa szarża ze statystyki), **338 708 szt.**, 17 klientów (FIBOO 49 pozycji).

Reguły (dzień odniesienia 16.10.2026, stałe ziarno losowania 2026):
- kolor zakończony ≤ 21 dni temu: 75% szans, 30–70% wyprodukowanej ilości;
- 22–60 dni: 40%, 10–35%;
- 61–120 dni: 12%, 3–15%;
- starsze: 3%, resztka 1–3 kartonów;
- kolory w produkcji (start ≤ 45 dni): 80%, 40–90%.

Ilości zaokrąglone w dół do pełnych kartonów (bez danych o kartonie: do 10 szt.). Miejsca R1–R8 wg klienta. Największa pozycja: 46L PA6 (EVR, detal 1,3 g) — 243 080 szt. ≈ 316 kg.

Aby zastąpić dane fikcyjne rzeczywistymi: zrobić nowy arkusz INW-WG i wpisać faktycznie policzone ilości. Różnice skorygują stan. Kopia bazy sprzed bilansu: `data/backup_przed_bilansem_otwarcia_wg_20261016_104933.sql`.

## 26. Addendum — nowy układ graficzny i domena (2026-10-25)

- **Domena:** aplikacja działa pod **https://prototyp.sigmaquality.pl/** (Nginx `/etc/nginx/sites-available/prototyp.sigmaquality.pl`, certyfikat Let's Encrypt, port 8510). `magazyn-surowcow.sigmaquality.pl` przekierowuje 301 na nową domenę; poprzednia konfiguracja: `/root/magazyn-surowcow.vhost.bak-20261025`. Sesje logowania są per domena, więc trzeba zalogować się ponownie.
- **Układ wg wzorów klienta** (`materiały2/a1–a11.png`): lewe menu z zwijanymi sekcjami, wyszukiwarką Ctrl/⌘+K i stopką użytkownika; zwijanie całego menu do paska ikon; górny pasek z tytułem strony, przełącznikiem jasny/ciemny, wyborem języka (EN jeszcze nieaktywny) i dzwonkiem powiadomień; font Inter hostowany lokalnie (CSP zabrania zewnętrznych).
- **Pliki:** `shell.py` (menu, ikony), `changelog.py` (wpisy „Co nowego”), `templates/base.html`, `templates/dashboard.html` (trasa `/pulpit`, po zalogowaniu), `static/shell.css`, `static/shell.js`, `static/theme.js`. Z `static/style.css` usunięto stare motywy kolorystyczne i styl „szkło”; kolory całej aplikacji idą ze zmiennych w `shell.css`.
- **Bez zmian:** dane, trasy, logika i szablony modułów. Dostawcy są teraz w sekcji „Dostawcy i materiały”.
- Kopie sprzed zmiany: `Protokół` nie dotyczy; stary `base.html` i `style.css` zachowano w katalogu roboczym sesji (scratchpad).

### 26a. Korekta wyglądu wg drugiej partii makiet (2026-10-25)

Klient dosłał 4 makiety siostrzanej aplikacji (`materiały2/`: Panel dostawców surowców, Karta produktu, Karta jakości, Karta technologiczna). Dopasowano: logo-sześcian i napis PLASTEMA / Magazyn surowców, niebieski akcent (#1763FF, w trybie ciemnym jaśniejszy), menu jako grupy z ikonami i podmenu (aktywna grupa otwarta, reszta zwinięta), okruszki i awatar w górnym pasku, plakietki rodzajów i żółte znaczniki kodów, stronicowanie listy dostawców (10/25/50/100), nagłówek strony z przyciskiem „wstecz” i kodem produktu (karta produktu). Nie dodawano funkcji z makiet, których aplikacja nie ma (cenniki, dokumenty, karta jakości i technologii, Logi, Ustawienia).
