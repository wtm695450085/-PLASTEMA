document.addEventListener("click", (event) => {
  const button = event.target.closest("[data-delete-form]");
  if (!button) return;
  if (window.confirm(button.dataset.confirm || "Czy na pewno usunąć tego dostawcę? Tej operacji nie można cofnąć.")) {
    document.getElementById(button.dataset.deleteForm).submit();
  }
});
