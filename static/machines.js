document.addEventListener("click", (event) => {
  const button = event.target.closest("[data-confirm]");
  if (button && !window.confirm(button.dataset.confirm)) event.preventDefault();
});

// Enter w polu dodawania pozycji = przycisk „Dodaj” właściwej sekcji (a nie zapis całego dokumentu).
document.addEventListener("keydown", (event) => {
  if (event.key !== "Enter" || !event.target.matches("[data-add-for]")) return;
  event.preventDefault();
  document.getElementById("add-button-" + event.target.dataset.addFor).click();
});

// Na żywo: ile zostanie w magazynie głównym po wydaniu.
const fmt = (n) => n.toLocaleString("pl-PL", { minimumFractionDigits: 0, maximumFractionDigits: 3 });
document.addEventListener("input", (event) => {
  const input = event.target.closest(".doc-row .qty-input");
  if (!input) return;
  const row = input.closest(".doc-row");
  if (row.dataset.available === "") return;
  const qty = Number(input.value.replace(/\s/g, "").replace(",", "."));
  const left = Number(row.dataset.available) - (Number.isNaN(qty) ? 0 : qty);
  row.classList.toggle("row-big", left < 0);
  const after = row.querySelector(".after");
  if (after) {
    after.textContent = "";
    const span = document.createElement("span");
    span.className = left < 0 ? "minus" : "";
    span.textContent = fmt(left);
    after.appendChild(span);
  }
});
