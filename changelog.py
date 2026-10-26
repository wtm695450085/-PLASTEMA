"""Wpisy „Co nowego” na pulpicie — najnowsze na górze. Format punktu: „<b>Obszar</b> — było: …; obecnie: …”."""

CHANGELOG = [
    {
        'version': 'v2.0.0', 'module': 'Interfejs', 'date': '2026-10-25',
        'items': [
            '<b>Wygląd</b> — było: osobny styl; obecnie: ten sam język graficzny co w pozostałych aplikacjach Plastema — logo-sześcian, niebieski akcent, okruszki nawigacji u góry, awatar użytkownika, plakietki rodzajów i kody w żółtych znacznikach.',
            '<b>Menu</b> — było: kilkanaście przycisków w pasku u góry; obecnie: lewe menu z grupami (Zamówienia, Produkcja, Magazyn surowców, Magazyn wyrobów, Dostawcy). Grupy się zwijają, a aktywna pozycja jest podświetlona na niebiesko.',
            '<b>Zwijanie menu</b> — było: stały pasek; obecnie: przycisk przy logo chowa menu do wąskiego paska ikon, a na telefonie menu wysuwa się z boku. Wybór zapamiętuje się w przeglądarce.',
            '<b>Jasność</b> — było: jeden kolorowy motyw zależny od modułu; obecnie: jednolity jasny wygląd i tryb ciemny przełączany ikoną słońca/księżyca u góry.',
            '<b>Szukaj w menu</b> — było: brak; obecnie: pole „Szukaj…” (skrót Ctrl/⌘ + K) filtruje pozycje menu, a Enter otwiera pierwszą z nich.',
            '<b>Pulpit</b> — było: strona startowa z listą dostawców; obecnie: pulpit „Wymaga Twojej uwagi” z liczbami z całej aplikacji oraz ten dziennik zmian. Lista dostawców jest w grupie „Dostawcy” i ma teraz stronicowanie po 10, 25, 50 lub 100 pozycji.',
            '<b>Adres</b> — było: magazyn-surowcow.sigmaquality.pl; obecnie: prototyp.sigmaquality.pl (stary adres przekierowuje automatycznie, trzeba się zalogować ponownie).',
        ],
    },
    {
        'version': 'v1.3.0', 'module': 'Magazyn wyrobów', 'date': '2026-10-19',
        'items': [
            '<b>Historia wydań</b> — było: zamówienia zrealizowane z importu bez dokumentów magazynowych; obecnie: mają szarżę, PW i WZ (daty wydania i przewoźnik w tych dokumentach są fikcyjne i opisane w uwagach).',
            '<b>Ilości zamówione</b> — było: ilość zamówiona równa ilości wyprodukowanej; obecnie: okrągłe ilości, jak zamawiają klienci (produkcja i WZ bez zmian).',
            '<b>Zamówienia produkcji</b> — było: zamówienia z importu bez zlecenia wewnętrznego; obecnie: każde ma zlecenie ZP z numerem ze statystyki, maszyną, datami i szarżą.',
            '<b>Karta ZK</b> — było: panel magazynu wyrobów bez danych o produkcji; obecnie: kolumny „Wyprodukowano” i „Szarża”.',
        ],
    },
    {
        'version': 'v1.2.0', 'module': 'Rozliczenie produkcji', 'date': '2026-10-16',
        'items': [
            '<b>Rozliczenie</b> — było: arkusze i ręczne liczenie; obecnie: pełny obieg według instrukcji v1 — zamówienie wewnętrzne, specyfikacja kolorów, raporty zmianowe, przyjęcie PW, etykiety z pieczątką Q.C. i punkty kontrolne K1–K12.',
            '<b>Szarża</b> — było: brak jednego kodu; obecnie: kod N-Z-S-DDMMRR, a całe zamówienie wewnętrzne to jedna szarża.',
            '<b>Statystyka</b> — było: osobna aplikacja M2; obecnie: 706 wierszy w bazie M1, powiązanych z produktami i formami.',
            '<b>Plan maszyn</b> — było: 3 zmiany dziennie; obecnie: 2 zmiany.',
        ],
    },
    {
        'version': 'v1.1.0', 'module': 'Formy', 'date': '2026-10-16',
        'items': [
            '<b>Paszport formy</b> — było: sama lista form; obecnie: pełny paszport (konstrukcja, montaż, technologia, żywotność SPI), zdjęcia, licznik cykli, rejestr montaży i awarii, dziennik serwisowy oraz wydruk A4.',
        ],
    },
    {
        'version': 'v1.0.0', 'module': 'Zamówienia', 'date': '2026-10-16',
        'items': [
            '<b>Zamówienia klientów</b> — było: brak; obecnie: kody ZK AAA RR MM DD NNN, kontrola formy, surowca, barwnika i wtryskarki przy przyjęciu oraz statusy NOWE → PRZYJĘTE → W PRODUKCJI → ZREALIZOWANE.',
            '<b>Dane startowe</b> — było: puste; obecnie: 26 klientów, 548 produktów, 231 form i 353 zamówienia historyczne.',
            '<b>Do uzupełnienia</b> — 435 automatycznych przypisań form czeka na weryfikację, a 113 produktów nie ma formy.',
        ],
    },
    {
        'version': 'v0.9.0', 'module': 'Magazyn surowców', 'date': '2026-09-29',
        'items': [
            '<b>Magazyn</b> — było: sama baza dostawców; obecnie: wykaz tworzyw i barwników, przyjęcie towaru, stany, inwentaryzacja z analizą różnic oraz magazyny przy maszynach.',
        ],
    },
]
