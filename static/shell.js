(function () {
  var root = document.documentElement;
  function store(key, value) { try { localStorage.setItem(key, value); } catch (e) {} }
  function read(key) { try { return localStorage.getItem(key); } catch (e) { return null; } }
  var mobile = function () { return window.innerWidth <= 900; };

  /* jasny / ciemny */
  var themeBtn = document.getElementById("theme-toggle");
  if (themeBtn) themeBtn.addEventListener("click", function () {
    var next = root.getAttribute("data-theme") === "dark" ? "light" : "dark";
    root.setAttribute("data-theme", next);
    store("plastema-theme", next);
  });

  /* zwijanie całego menu */
  function setCollapsed(on) {
    root.classList.toggle("sb-collapsed", on);
    store("plastema-sidebar", on ? "collapsed" : "open");
  }
  document.querySelectorAll("[data-sidebar-toggle]").forEach(function (btn) {
    btn.addEventListener("click", function () {
      if (mobile()) { root.classList.toggle("sb-open"); return; }
      setCollapsed(!root.classList.contains("sb-collapsed"));
    });
  });
  document.querySelectorAll("[data-sidebar-close]").forEach(function (el) {
    el.addEventListener("click", function () { root.classList.remove("sb-open"); });
  });

  /* zwijane sekcje (stan pamiętany; sekcja z aktywną pozycją zawsze rozwinięta przy wejściu) */
  var saved = {};
  try { saved = JSON.parse(read("plastema-sections") || "{}"); } catch (e) {}
  document.querySelectorAll(".sb-section").forEach(function (sec) {
    var key = sec.getAttribute("data-section"), head = sec.querySelector(".sb-section-head");
    var has = sec.classList.contains("has-active");
    var closed = !has && (saved[key] === undefined ? true : saved[key] === false);
    sec.classList.toggle("is-closed", closed);
    head.setAttribute("aria-expanded", String(!closed));
    head.addEventListener("click", function () {
      var nowClosed = !sec.classList.contains("is-closed");
      sec.classList.toggle("is-closed", nowClosed);
      head.setAttribute("aria-expanded", String(!nowClosed));
      saved[key] = !nowClosed;
      store("plastema-sections", JSON.stringify(saved));
    });
  });

  /* wyszukiwarka w menu: ⌘K / Ctrl+K */
  var input = document.getElementById("nav-search");
  function openSearch() {
    if (root.classList.contains("sb-collapsed")) setCollapsed(false);
    if (mobile()) root.classList.add("sb-open");
    if (input) { input.focus(); input.select(); }
  }
  document.querySelectorAll("[data-search-open]").forEach(function (b) { b.addEventListener("click", openSearch); });
  document.addEventListener("keydown", function (e) {
    if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === "k") { e.preventDefault(); openSearch(); }
    if (e.key === "Escape") {
      closeMenus();
      if (input && document.activeElement === input) { input.value = ""; filter(); input.blur(); }
    }
  });
  function norm(s) { return s.toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "").replace(/ł/g, "l"); }
  function filter() {
    var q = norm(input.value.trim()), shown = 0;
    document.querySelectorAll(".sb-nav .sb-item").forEach(function (a) {
      var ok = !q || norm(a.getAttribute("data-label") || "").indexOf(q) !== -1;
      a.classList.toggle("is-filtered", !ok);
      if (ok) shown++;
    });
    document.querySelectorAll(".sb-section").forEach(function (sec) {
      var any = sec.querySelector(".sb-item:not(.is-filtered)");
      sec.classList.toggle("is-hidden", !any);
      sec.classList.toggle("is-searching", !!q);
    });
    var empty = document.querySelector(".sb-empty");
    if (empty) empty.hidden = shown > 0;
  }
  if (input) {
    input.addEventListener("input", filter);
    input.addEventListener("keydown", function (e) {
      if (e.key === "Enter") {
        var first = document.querySelector(".sb-nav .sb-item:not(.is-filtered)");
        if (first) window.location.href = first.getAttribute("href");
      }
    });
  }

  /* rozwijane menu u góry (język, powiadomienia) */
  function closeMenus(except) {
    document.querySelectorAll("[data-dd]").forEach(function (dd) {
      if (dd === except) return;
      dd.querySelector(".dd-menu").hidden = true;
      dd.querySelector("[data-dd-toggle]").setAttribute("aria-expanded", "false");
    });
  }
  document.querySelectorAll("[data-dd]").forEach(function (dd) {
    var toggle = dd.querySelector("[data-dd-toggle]"), menu = dd.querySelector(".dd-menu");
    toggle.addEventListener("click", function (e) {
      e.stopPropagation();
      var open = menu.hidden;
      closeMenus(dd);
      menu.hidden = !open;
      toggle.setAttribute("aria-expanded", String(open));
    });
    menu.addEventListener("click", function (e) { e.stopPropagation(); });
  });
  document.addEventListener("click", function () { closeMenus(); });
})();
document.addEventListener("click", function (e) {
  var btn = e.target.closest("[data-wn-more]");
  if (!btn) return;
  var box = document.getElementById("whatsnew");
  var on = box.classList.toggle("show-all");
  btn.textContent = on ? "Pokaż mniej" : "Pokaż starsze zmiany";
});
(function () {
  var active = document.querySelector(".sb-nav .sb-item.is-active");
  if (active && active.scrollIntoView) active.scrollIntoView({ block: "nearest" });
})();

/* prosta paginacja tabel: <table data-paginate="10"> + <div data-pager> */
(function () {
  document.querySelectorAll("table[data-paginate]").forEach(function (table) {
    var holder = table.closest(".table-card"), bar = holder && holder.querySelector("[data-pager]");
    var rows = Array.prototype.slice.call(table.tBodies[0].rows).filter(function (r) { return r.cells.length > 1; });
    if (!bar || !rows.length) return;
    var size = parseInt(table.getAttribute("data-paginate"), 10) || 10, page = 1;
    bar.hidden = false;
    function render() {
      var pages = Math.max(1, Math.ceil(rows.length / size));
      page = Math.min(page, pages);
      rows.forEach(function (r, i) { r.hidden = !(i >= (page - 1) * size && i < page * size); });
      var html = '<span>Strona <b>' + page + '</b> z <b>' + pages + '</b> · ' + rows.length + ' pozycji</span><div class="pager-pages">';
      html += '<button class="pg" type="button" data-go="' + (page - 1) + '"' + (page === 1 ? " disabled" : "") + ' aria-label="Poprzednia">‹</button>';
      var from = Math.max(1, page - 2), to = Math.min(pages, from + 4); from = Math.max(1, to - 4);
      for (var n = from; n <= to; n++) html += '<button class="pg' + (n === page ? " is-current" : "") + '" type="button" data-go="' + n + '">' + n + '</button>';
      html += '<button class="pg" type="button" data-go="' + (page + 1) + '"' + (page === pages ? " disabled" : "") + ' aria-label="Następna">›</button>';
      html += '<select class="pager-size" aria-label="Wierszy na stronę">';
      [10, 25, 50, 100].forEach(function (v) { html += '<option value="' + v + '"' + (v === size ? " selected" : "") + '>' + v + '</option>'; });
      html += '</select></div>';
      bar.innerHTML = html;
    }
    bar.addEventListener("click", function (e) {
      var b = e.target.closest("[data-go]");
      if (b && !b.disabled) { page = parseInt(b.getAttribute("data-go"), 10); render(); }
    });
    bar.addEventListener("change", function (e) {
      if (e.target.classList.contains("pager-size")) { size = parseInt(e.target.value, 10); page = 1; render(); }
    });
    render();
  });
})();
