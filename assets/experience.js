(function () {
  const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  const intro = document.querySelector("[data-gxe-intro]");
  const hub = document.querySelector("[data-gxe-home-hub]");
  const introSkip = document.querySelector("[data-gxe-intro-skip]");
  const introReplay = document.querySelector("[data-gxe-intro-replay]");
  const introStorageKey = "gxe:intro-seen:v1.2";
  let introTimer = null;
  let revealTimer = null;
  let payoffTimer = null;
  let bloomTimer = null;
  let replayTrigger = null;

  function readIntroSeen() {
    try {
      return window.sessionStorage.getItem(introStorageKey) === "true";
    } catch (error) {
      return false;
    }
  }

  function writeIntroSeen() {
    try {
      window.sessionStorage.setItem(introStorageKey, "true");
    } catch (error) {
      // The intro still works when session storage is unavailable.
    }
  }

  function clearIntroTimers() {
    window.clearTimeout(introTimer);
    window.clearTimeout(revealTimer);
    window.clearTimeout(payoffTimer);
    window.clearTimeout(bloomTimer);
    introTimer = null;
    revealTimer = null;
    payoffTimer = null;
    bloomTimer = null;
  }

  function setIntroStage(stage) {
    if (intro) intro.dataset.stage = stage;
  }

  function showHub(options) {
    if (!intro || !hub) return;

    clearIntroTimers();
    setIntroStage("hub");
    document.body.classList.remove("gxe-intro-active");
    intro.setAttribute("aria-hidden", "true");
    hub.removeAttribute("aria-hidden");
    hub.inert = false;
    writeIntroSeen();

    if (options && options.restoreFocus && replayTrigger) {
      replayTrigger.focus({ preventScroll: true });
    }
  }

  function completeIntro() {
    if (!intro || intro.dataset.stage !== "revealing") return;

    setIntroStage("iced");
    payoffTimer = window.setTimeout(function () {
      setIntroStage("blooming");
      bloomTimer = window.setTimeout(function () {
        showHub();
      }, reduceMotion ? 20 : 720);
    }, reduceMotion ? 20 : 720);
  }

  function beginIntroReveal() {
    if (!intro || intro.dataset.stage !== "arrival") return;

    intro.dataset.engaged = "true";
    setIntroStage("revealing");
    revealTimer = window.setTimeout(completeIntro, reduceMotion ? 80 : 1950);
  }

  function startIntro(trigger) {
    if (!intro || !hub) return;
    if (reduceMotion) {
      showHub({ restoreFocus: Boolean(trigger) });
      return;
    }

    replayTrigger = trigger || null;
    clearIntroTimers();
    delete intro.dataset.engaged;
    setIntroStage("arrival");
    intro.removeAttribute("aria-hidden");
    hub.setAttribute("aria-hidden", "true");
    hub.inert = true;
    document.body.classList.add("gxe-intro-active");
    window.scrollTo({ top: 0, behavior: "instant" });
    if (introSkip) introSkip.focus({ preventScroll: true });

    const configuredDelay = Number.parseInt(intro.dataset.introDelay || "1000", 10);
    const introDelay = Number.isFinite(configuredDelay) ? configuredDelay : 1000;
    introTimer = window.setTimeout(beginIntroReveal, introDelay);
  }

  function prepareStaticProductFrame(video) {
    const configured = Number.parseFloat(video.dataset.videoFinalFrame || "0");
    const target = Number.isFinite(configured) && configured > 0.001 ? configured : 0.04;
    const seek = function () {
      try {
        video.currentTime = Math.min(target, Math.max(0, video.duration - 0.04));
      } catch (error) {
        // The browser's natural first frame remains as the deterministic fallback.
      }
    };

    video.pause();
    if (video.readyState >= 1) seek();
    else video.addEventListener("loadedmetadata", seek, { once: true });
  }

  document.querySelectorAll("[data-gxe-static-product-frame]").forEach(prepareStaticProductFrame);

  if (!intro || !hub) return;

  if (introSkip) {
    introSkip.addEventListener("click", function () {
      showHub();
    });
  }

  if (introReplay) {
    introReplay.addEventListener("click", function () {
      startIntro(introReplay);
    });
  }

  document.addEventListener("keydown", function (event) {
    if (event.key === "Escape" && document.body.classList.contains("gxe-intro-active")) {
      showHub({ restoreFocus: Boolean(replayTrigger) });
    }
  });

  const explicitHubRequest = window.location.hash === "#hub";
  if (explicitHubRequest || readIntroSeen() || reduceMotion) {
    showHub();
  } else {
    startIntro();
  }
})();
