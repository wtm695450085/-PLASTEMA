(function () {
  var root = document.documentElement, theme = "light", collapsed = false;
  try {
    theme = localStorage.getItem("plastema-theme") || "light";
    collapsed = localStorage.getItem("plastema-sidebar") === "collapsed";
  } catch (e) {}
  root.setAttribute("data-theme", theme === "dark" ? "dark" : "light");
  if (collapsed && window.innerWidth > 900) root.classList.add("sb-collapsed");
})();
