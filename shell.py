"""Szkielet interfejsu: lewe menu (sekcje, aktywna pozycja), ikony SVG i dane pulpitu."""
import os

from markupsafe import Markup

ICONS = {
    'arrow-left': '<path d="m12 19-7-7 7-7"/><path d="M19 12H5"/>',
    'plus': '<path d="M5 12h14"/><path d="M12 5v14"/>',
    'orders': '<rect width="18" height="18" x="3" y="3" rx="3"/><path d="M12 8v8"/><path d="M8 12h8"/>',
    'home': '<path d="M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8"/><path d="M3 10a2 2 0 0 1 .709-1.528l7-5.999a2 2 0 0 1 2.582 0l7 5.999A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>',
    'list': '<path d="M3 5h.01"/><path d="M3 12h.01"/><path d="M3 19h.01"/><path d="M8 5h13"/><path d="M8 12h13"/><path d="M8 19h13"/>',
    'grid': '<rect width="7" height="7" x="3" y="3" rx="1"/><rect width="7" height="7" x="14" y="3" rx="1"/><rect width="7" height="7" x="14" y="14" rx="1"/><rect width="7" height="7" x="3" y="14" rx="1"/>',
    'tasks': '<path d="m3 17 2 2 4-4"/><path d="m3 7 2 2 4-4"/><path d="M13 6h8"/><path d="M13 12h8"/><path d="M13 18h8"/>',
    'user': '<path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>',
    'package': '<path d="m7.5 4.27 9 5.15"/><path d="M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z"/><path d="m3.3 7 8.7 5 8.7-5"/><path d="M12 22V12"/>',
    'swap': '<path d="M8 3 4 7l4 4"/><path d="M4 7h16"/><path d="m16 21 4-4-4-4"/><path d="M20 17H4"/>',
    'search': '<circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/>',
    'chevron-down': '<path d="m6 9 6 6 6-6"/>',
    'chevron-right': '<path d="m9 18 6-6-6-6"/>',
    'panel': '<rect width="18" height="18" x="3" y="3" rx="2"/><path d="M9 3v18"/>',
    'logout': '<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><path d="m10 17 5-5-5-5"/><path d="M15 12H3"/>',
    'sun': '<circle cx="12" cy="12" r="4"/><path d="M12 2v2"/><path d="M12 20v2"/><path d="m4.93 4.93 1.41 1.41"/><path d="m17.66 17.66 1.41 1.41"/><path d="M2 12h2"/><path d="M20 12h2"/><path d="m6.34 17.66-1.41 1.41"/><path d="m19.07 4.93-1.41 1.41"/>',
    'moon': '<path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z"/>',
    'bell': '<path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/>',
    'check': '<path d="M20 6 9 17l-5-5"/>',
    'alert': '<circle cx="12" cy="12" r="10"/><path d="M12 8v4"/><path d="M12 16h.01"/>',
    'menu': '<path d="M4 12h16"/><path d="M4 6h16"/><path d="M4 18h16"/>',
    'calendar': '<path d="M8 2v4"/><path d="M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18"/>',
    'layers': '<path d="M12.83 2.18a2 2 0 0 0-1.66 0L2.6 6.08a1 1 0 0 0 0 1.83l8.58 3.91a2 2 0 0 0 1.66 0l8.58-3.9a1 1 0 0 0 0-1.83Z"/><path d="m22 17.65-9.17 4.16a2 2 0 0 1-1.66 0L2 17.65"/><path d="m22 12.65-9.17 4.16a2 2 0 0 1-1.66 0L2 12.65"/>',
    'palette': '<circle cx="13.5" cy="6.5" r=".5"/><circle cx="17.5" cy="10.5" r=".5"/><circle cx="8.5" cy="7.5" r=".5"/><circle cx="6.5" cy="12.5" r=".5"/><path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10c.926 0 1.648-.746 1.648-1.688 0-.437-.18-.835-.437-1.125-.29-.289-.438-.652-.438-1.125a1.64 1.64 0 0 1 1.668-1.668h1.996c3.051 0 5.555-2.503 5.555-5.554C21.965 6.012 17.461 2 12 2z"/>',
    'clipboard-list': '<rect width="8" height="4" x="8" y="2" rx="1"/><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><path d="M12 11h4"/><path d="M12 16h4"/><path d="M8 11h.01"/><path d="M8 16h.01"/>',
    'clipboard-check': '<rect width="8" height="4" x="8" y="2" rx="1"/><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><path d="m9 14 2 2 4-4"/>',
    'chart': '<path d="M3 3v16a2 2 0 0 0 2 2h16"/><path d="M18 17V9"/><path d="M13 17V5"/><path d="M8 17v-3"/>',
    'file': '<path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"/><path d="M14 2v4a2 2 0 0 0 2 2h4"/><path d="M10 9H8"/><path d="M16 13H8"/><path d="M16 17H8"/>',
    'gauge': '<path d="m12 14 4-4"/><path d="M3.34 19a10 10 0 1 1 17.32 0"/>',
    'cog': '<path d="M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z"/><circle cx="12" cy="12" r="3"/>',
    'download': '<path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><path d="m7 10 5 5 5-5"/><path d="M12 15V3"/>',
    'warehouse': '<path d="M22 8.35V20a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V8.35A2 2 0 0 1 3.26 6.5l8-3.2a2 2 0 0 1 1.48 0l8 3.2A2 2 0 0 1 22 8.35Z"/><path d="M6 18h12"/><path d="M6 14h12"/><rect width="12" height="12" x="6" y="10"/>',
    'repeat': '<path d="m16 3 4 4-4 4"/><path d="M20 7H4"/><path d="m8 21-4-4 4-4"/><path d="M4 17h16"/>',
    'truck': '<path d="M14 18V6a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2v11a1 1 0 0 0 1 1h2"/><path d="M15 18H9"/><path d="M19 18h2a1 1 0 0 0 1-1v-3.65a1 1 0 0 0-.22-.624l-3.48-4.35A1 1 0 0 0 17.52 8H14"/><circle cx="17" cy="18" r="2"/><circle cx="7" cy="18" r="2"/>',
    'factory': '<path d="M2 20a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V8l-7 5V8l-7 5V4a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2Z"/><path d="M17 18h1"/><path d="M12 18h1"/><path d="M7 18h1"/>',
    'droplet': '<path d="M12 22a7 7 0 0 0 7-7c0-2-1-3.9-3-5.5s-3.5-4-4-6.5c-.5 2.5-2 4.9-4 6.5C6 11.1 5 13 5 15a7 7 0 0 0 7 7z"/>',
    'link': '<circle cx="6" cy="12" r="3.5"/><circle cx="18" cy="12" r="3.5"/><path d="M9.5 12h5"/>',
}


def icon(name, size=18):
    body = ICONS.get(name, ICONS['package'])
    return Markup(f'<svg class="ic" width="{size}" height="{size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" '
                  f'stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">{body}</svg>')


def logo(size=34):
    return Markup(f'<svg class="logo-mark" width="{size}" height="{size}" viewBox="0 0 32 32" aria-hidden="true">'
                  '<path d="M16 1.8 28.6 9v14L16 30.2 3.4 23V9z" fill="currentColor"/>'
                  '<path d="M16 8.6 22.4 12.3v7.4L16 23.4 9.6 19.7v-7.4z" fill="none" stroke="#fff" stroke-width="1.7" stroke-linejoin="round"/>'
                  '<path d="m9.8 12.4 6.2 3.6 6.2-3.6M16 16v7.2" fill="none" stroke="#fff" stroke-width="1.7" stroke-linejoin="round" stroke-linecap="round"/></svg>')


# (etykieta, ikona, endpoint, parametry linku, prefiksy ścieżek uznawane za tę pozycję, wymagane parametry zapytania)
TOP = [('Pulpit', 'home', 'dashboard', {}, ['/pulpit'], {})]
SECTIONS = [
    ('zamowienia', 'Zamówienia', 'orders', [
        ('Zamówienia', 'swap', 'orders_index', {}, ['/zamowienia'], {}),
        ('Plan maszyn', 'calendar', 'machine_plan', {}, ['/plan-maszyn'], {}),
        ('Klienci', 'user', 'clients_index', {}, ['/klienci'], {}),
        ('Produkty', 'package', 'products_index', {}, ['/produkty'], {}),
        ('Formy', 'layers', 'molds_index', {}, ['/formy'], {}),
        ('Kolory', 'palette', 'colors_index', {}, ['/kolory'], {}),
    ]),
    ('produkcja', 'Produkcja', 'factory', [
        ('Zamówienia produkcji', 'file', 'settlement_index', {'status': 'ALL'}, ['/rozliczenie'], {'status': 'ALL'}),
        ('Rozliczenie produkcji', 'clipboard-list', 'settlement_index', {}, ['/rozliczenie'], {}),
        ('Statystyka', 'chart', 'stats_index', {}, ['/statystyka'], {}),
        ('Przyjęcia wyrobów', 'download', 'finished_receipts', {}, ['/przyjecia-wyrobow'], {}),
        ('Zużycie materiałów', 'gauge', 'material_consumption', {}, ['/zuzycie-materialow'], {}),
        ('Maszyny', 'cog', 'machines_index', {}, ['/maszyny'], {}),
    ]),
    ('surowce', 'Magazyn surowców', 'package', [
        ('Przyjęcie towaru', 'download', 'receipts_index', {}, ['/przyjecia'], {}),
        ('Stany magazynowe', 'warehouse', 'stock_index', {}, ['/stany'], {}),
        ('Inwentaryzacja', 'clipboard-check', 'inventory_index', {}, ['/inwentaryzacje'], {}),
        ('Analiza różnic', 'repeat', 'difference_analysis', {}, ['/analiza-roznic'], {}),
    ]),
    ('wyroby', 'Magazyn wyrobów', 'warehouse', [
        ('Magazyn wyrobów', 'package', 'fg_stock', {}, ['/magazyn-wyrobow'], {}),
        ('WZ / ZW / INW', 'truck', 'fg_docs', {}, ['/magazyn-wyrobow/dokumenty', '/magazyn-wyrobow/dokument'], {}),
    ]),
    ('dostawcy', 'Dostawcy', 'truck', [
        ('Tworzywa', 'layers', 'materials_index', {'category': 'SUROWIEC SYPKI'}, ['/tworzywa'], {'category': 'SUROWIEC SYPKI'}),
        ('Barwniki', 'droplet', 'materials_index', {'category': 'BARWNIK TWORZYWA'}, ['/tworzywa'], {'category': 'BARWNIK TWORZYWA'}),
        ('Dostawcy tworzyw', 'factory', 'index', {'material': 'TWORZYWO'}, ['/', '/dostawy', '/dostawcy', '/kontakty'], {'material': 'TWORZYWO'}),
        ('Dostawcy barwników', 'droplet', 'index', {'material': 'BARWNIK'}, ['/', '/dostawcy', '/kontakty'], {'material': 'BARWNIK'}),
    ]),
]
FALLBACK_LABEL = {'/tworzywa': 'Tworzywa', '/': 'Dostawcy tworzyw', '/dostawcy': 'Dostawcy tworzyw', '/kontakty': 'Dostawcy tworzyw',
                  '/rozliczenie': 'Rozliczenie produkcji', '/magazyn-wyrobow': 'Magazyn wyrobów'}


def _path_match(path, prefixes):
    best = -1
    for prefix in prefixes:
        if prefix == '/':
            if path == '/':
                best = max(best, 1)
        elif path == prefix or path.startswith(prefix + '/'):
            best = max(best, len(prefix))
    return best


def build_nav(request, url_for):
    """Zwraca (pozycje główne, sekcje, etykieta aktywnej pozycji). Aktywna jest jedna pozycja: najdłuższy pasujący prefiks,
    a przy równości ta, której wymagane parametry zapytania zgadzają się z adresem."""
    path = request.path
    candidates = []
    for group in [TOP] + [s[3] for s in SECTIONS]:
        for item in group:
            label, _, _, _, prefixes, query = item
            score = _path_match(path, prefixes)
            if score < 0:
                continue
            if query:
                if all(request.args.get(k) == v for k, v in query.items()):
                    score += 1000
                else:
                    continue
            candidates.append((score, label))
    if not any(s >= 1000 for s, _ in candidates):
        # pozycje bez dopasowanych parametrów zapytania: wybierz pozycję domyślną dla ścieżki
        for key, label in FALLBACK_LABEL.items():
            if _path_match(path, [key]) >= 0 and not (key == '/' and path != '/'):
                candidates.append((1, label))
                break
    active = max(candidates)[1] if candidates else None
    if active:
        # pozycja z parametrami ma pierwszeństwo, ale pozycja „ogólna” (bez parametrów) tej samej ścieżki nie świeci razem z nią
        pass

    def make(item):
        label, ic, endpoint, kwargs, _, _ = item
        return {'label': label, 'icon': ic, 'href': url_for(endpoint, **kwargs), 'active': label == active}

    top = [make(i) for i in TOP]
    sections = []
    crumbs = []
    for key, title, ico, items in SECTIONS:
        built = [make(i) for i in items]
        sections.append({'key': key, 'title': title, 'icon': ico, 'items': built, 'has_active': any(i['active'] for i in built)})
        if any(i['active'] for i in built):
            crumbs = [title, active]
    if not crumbs and active:
        crumbs = [active]
    return top, sections, active, crumbs


def user_info():
    name = os.getenv('UI_USER_NAME', 'Wojciech Moszczyński').strip()
    parts = [p for p in name.split() if p]
    initials = ''.join(p[0] for p in parts[:2]).upper() or 'U'
    return {'name': name, 'first': parts[0] if parts else name, 'initials': initials, 'role': os.getenv('UI_USER_ROLE', 'Użytkownik')}
