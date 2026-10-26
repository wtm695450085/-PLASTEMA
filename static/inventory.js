(() => {
  document.querySelectorAll("[data-w]").forEach((el) => el.style.setProperty("--w", el.dataset.w));
  const printButton = document.getElementById("print-button");
  if (printButton) printButton.addEventListener("click", () => window.print());

  document.addEventListener("click", (event) => {
    const button = event.target.closest("[data-confirm]");
    if (button && !window.confirm(button.dataset.confirm)) event.preventDefault();
  });

  const form = document.getElementById("inventory-form");
  if (!form) return;
  const threshold = Number(form.dataset.threshold) || 5;
  const rows = [...form.querySelectorAll(".inv-row")];
  const search = document.getElementById("inv-search");
  const category = document.getElementById("inv-category");
  const onlyEmpty = document.getElementById("inv-empty");
  const onlyBig = document.getElementById("inv-big");
  const progress = document.getElementById("inv-progress");
  const fmt = (n, digits = 2) => n.toLocaleString("pl-PL", { minimumFractionDigits: 0, maximumFractionDigits: digits });
  const parse = (text) => {
    const value = text.replace(/\s/g, "").replace(",", ".");
    return value === "" ? null : Number(value);
  };

  function recalc(row) {
    const input = row.querySelector(".qty-input");
    if (!input) return;
    const qty = parse(input.value);
    const diffCell = row.querySelector(".diff");
    const valueCell = row.querySelector(".value");
    const invalid = qty !== null && (Number.isNaN(qty) || qty < 0);
    input.classList.toggle("invalid", invalid);
    row.classList.toggle("is-counted", qty !== null && !invalid);
    const pctCell = row.querySelector(".pct");
    const diffValCell = row.querySelector(".diffval");
    if (qty === null || invalid) {
      diffCell.textContent = "—"; valueCell.textContent = "—"; pctCell.textContent = "—"; diffValCell.textContent = "—";
      row.classList.remove("row-big"); return;
    }
    const expected = row.dataset.expected === "" ? 0 : Number(row.dataset.expected);
    const diff = qty - expected;
    const pct = diff === 0 ? 0 : expected > 0 ? Math.abs(diff) / expected * 100 : 100;
    pctCell.textContent = fmt(pct) + "%";
    row.classList.toggle("row-big", pct >= threshold);
    const price = row.dataset.price === "" ? null : Number(row.dataset.price);
    diffValCell.innerHTML = "";
    if (price !== null) {
      const dv = document.createElement("span");
      dv.className = diff > 0 ? "plus" : diff < 0 ? "minus" : "";
      dv.textContent = (diff > 0 ? "+" : "") + fmt(diff * price);
      diffValCell.appendChild(dv);
    } else diffValCell.textContent = "—";
    const slot = row.querySelector(".explain-slot");
    if (slot) slot.textContent = pct >= threshold ? "Zapisz arkusz, aby wyjaśnić różnicę" : "";
    diffCell.innerHTML = "";
    const span = document.createElement("span");
    span.className = diff > 0 ? "plus" : diff < 0 ? "minus" : "";
    span.textContent = (diff > 0 ? "+" : "") + fmt(diff, 3);
    diffCell.appendChild(span);
    valueCell.textContent = row.dataset.price === "" ? "—" : fmt(qty * Number(row.dataset.price));
  }

  function updateProgress() {
    if (!progress) return;
    const inputs = form.querySelectorAll(".qty-input");
    const done = [...inputs].filter((i) => i.value.trim() !== "").length;
    progress.textContent = `Wypełniono ${done} z ${inputs.length} pozycji. Puste pole = pozycja niepoliczona (zostaje poprzedni stan). Wpisz 0, jeśli towaru nie ma.`;
  }

  function applyFilters() {
    const term = search.value.trim().toLowerCase();
    rows.forEach((row) => {
      const input = row.querySelector(".qty-input");
      const empty = input ? input.value.trim() === "" : false;
      row.hidden = (term && !row.dataset.search.includes(term)) ||
        (category.value && row.dataset.category !== category.value) ||
        (onlyEmpty.checked && !empty) ||
        (onlyBig.checked && !row.classList.contains("row-big"));
    });
  }

  form.addEventListener("input", (event) => {
    if (event.target.classList.contains("qty-input")) { recalc(event.target.closest(".inv-row")); updateProgress(); }
  });
  form.addEventListener("keydown", (event) => {
    if (event.key !== "Enter" || !event.target.classList.contains("qty-input")) return;
    event.preventDefault();
    const visible = [...form.querySelectorAll(".inv-row:not([hidden]) .qty-input")];
    const next = visible[visible.indexOf(event.target) + 1];
    if (next) { next.focus(); next.select(); }
  });
  [search, category, onlyEmpty, onlyBig].forEach((el) => el.addEventListener("input", applyFilters));
  rows.forEach(recalc);
  updateProgress();

  let dirty = false;
  form.addEventListener("input", () => { dirty = true; });
  form.addEventListener("submit", () => { dirty = false; });
  window.addEventListener("beforeunload", (event) => { if (dirty) event.preventDefault(); });
})();
