(() => {
  // CSP blokuje style inline — pozycje i szerokości pasków planu ustawiamy z atrybutów data-*.
  document.querySelectorAll("[data-left]").forEach((el) => { el.style.left = el.dataset.left + "%"; });
  document.querySelectorAll(".job[data-w]").forEach((el) => { el.style.width = el.dataset.w + "%"; });

  // Zdjęcie formy: wgraj od razu po wybraniu pliku / zrobieniu zdjęcia.
  document.querySelectorAll("input[data-autosubmit]").forEach((input) => {
    input.addEventListener("change", () => {
      if (!input.files.length) return;
      input.closest("figure")?.classList.add("uploading");
      input.form.submit();
    });
  });
  document.querySelectorAll("[data-print]").forEach((b) => b.addEventListener("click", () => window.print()));

  document.querySelectorAll("[data-hist]").forEach((b) => b.addEventListener("click", () => {
    const row = document.getElementById(b.dataset.hist);
    if (row) row.classList.toggle("hidden");
  }));

  document.addEventListener("click", (event) => {
    const button = event.target.closest("button[type=submit][data-confirm]");
    if (button && !window.confirm(button.dataset.confirm)) event.preventDefault();
  });
})();
