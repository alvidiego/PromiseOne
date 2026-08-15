(() => {
  "use strict";

  const compactNavigation = window.matchMedia("(max-width: 82.5rem)");

  document.querySelectorAll(".structured-menu").forEach((menu) => {
    const toggle = menu.querySelector(".structured-menu__toggle");
    const navigation = menu.querySelector(".structured-nav");

    if (!toggle || !navigation) {
      return;
    }

    const closeMenu = (restoreFocus = false) => {
      menu.removeAttribute("open");
      if (restoreFocus) {
        toggle.focus();
      }
    };

    menu.addEventListener("keydown", (event) => {
      if (compactNavigation.matches && event.key === "Escape" && menu.open) {
        event.preventDefault();
        closeMenu(true);
      }
    });

    navigation.addEventListener("click", (event) => {
      if (compactNavigation.matches && event.target.closest("a")) {
        closeMenu();
      }
    });

    compactNavigation.addEventListener("change", (event) => {
      if (!event.matches) {
        menu.setAttribute("open", "");
      } else if (navigation.contains(document.activeElement)) {
        menu.setAttribute("open", "");
      } else {
        closeMenu();
      }
    });

    if (compactNavigation.matches && !navigation.contains(document.activeElement)) {
      closeMenu();
    } else {
      menu.setAttribute("open", "");
    }
  });
})();
