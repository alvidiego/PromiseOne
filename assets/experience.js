(function () {
  const experience = document.querySelector(".gxe-experience");
  const holdTarget = document.querySelector(".gxe-hold");
  const arrivalScene = document.querySelector(".gxe-arrival-scene");
  const productScene = document.querySelector(".gxe-product-scene");
  const productMedia = document.querySelector("[data-product-media]");
  const productVideo = document.querySelector(".piece-video");

  if (!experience || !holdTarget || !arrivalScene || !productScene) return;

  const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  const holdDuration = reduceMotion ? 400 : 1950;
  const payoffDuration = reduceMotion ? 100 : 720;
  const bloomDuration = reduceMotion ? 180 : 720;
  let holdTimer = null;
  let payoffTimer = null;
  let bloomTimer = null;
  let resetTimer = null;
  let productPlayCount = 0;
  let productInfoTimer = null;
  let productSegmentSettled = false;
  const maxProductPlays = 2;
  const productInfoDelay = 2000;

  function getProductRevealTime() {
    if (!productVideo || !productMedia) return 0;

    const configuredTime = Number.parseFloat(productMedia.dataset.videoStart || "0");
    return Number.isFinite(configuredTime) ? configuredTime : 0;
  }

  function getProductSegmentDuration() {
    if (!productVideo || !productMedia) return 6;

    const configuredDuration = Number.parseFloat(productMedia.dataset.videoDuration || "6");
    return Number.isFinite(configuredDuration) && configuredDuration > 0 ? configuredDuration : 6;
  }

  function playProductVideo() {
    const playback = productVideo.play();
    if (playback) playback.catch(function () {});
  }

  function completeProductPresentation() {
    productScene.dataset.productComplete = "true";
  }

  function scheduleProductPresentation() {
    window.clearTimeout(productInfoTimer);
    productInfoTimer = window.setTimeout(completeProductPresentation, productInfoDelay);
  }

  function pauseOnProductFinalFrame() {
    if (!productVideo || !productMedia) return;

    productSegmentSettled = true;
    productVideo.pause();
    productVideo.playbackRate = 1;
    productMedia.dataset.ready = "true";
    completeProductPresentation();
  }
  function beginVisibleProductPlayback() {
    if (!productVideo || !productMedia || productSegmentSettled) return;

    if (productPlayCount === 0) productPlayCount = 1;
    productVideo.playbackRate = 1;
    productMedia.dataset.ready = "true";
    playProductVideo();
  }

  function replayProductSegment() {
    if (!productVideo || !productMedia || productSegmentSettled) return;

    if (productPlayCount >= maxProductPlays) {
      pauseOnProductFinalFrame();
      return;
    }

    productPlayCount += 1;
    productVideo.playbackRate = 1;
    productVideo.currentTime = getProductRevealTime();
    productMedia.dataset.ready = "true";
    playProductVideo();
  }

  function primeProductVideo() {
    if (!productVideo || !productMedia) return;

    productVideo.load();
    productVideo.addEventListener("timeupdate", function () {
      const revealTime = getProductRevealTime();

      if (
        !reduceMotion &&
        productVideo.currentTime >= revealTime - 1.2 &&
        productVideo.currentTime + 0.08 < revealTime
      ) {
        productVideo.playbackRate = 1;
        return;
      }

      if (productVideo.currentTime + 0.08 < revealTime) return;
      if (reduceMotion) return;

      productVideo.playbackRate = 1;
      productMedia.dataset.ready = "true";
      if (experience.dataset.stage !== "product") {
        productVideo.pause();
        return;
      }

      if (productVideo.currentTime >= revealTime + getProductSegmentDuration()) {
        replayProductSegment();
        return;
      }

      beginVisibleProductPlayback();
    });
    productVideo.addEventListener("ended", function () {
      productVideo.playbackRate = 1;
      productMedia.dataset.ready = "true";

      if (experience.dataset.stage === "product" && !reduceMotion) {
        replayProductSegment();
        return;
      }

      completeProductPresentation();
    });
    productVideo.addEventListener("error", function () {
      productMedia.dataset.failed = "true";
      completeProductPresentation();
    });
  }

  function startProductVideo() {
    if (!productVideo || !productMedia) return;
    productPlayCount = 0;
    productSegmentSettled = false;
    delete productMedia.dataset.ready;
    delete productScene.dataset.productComplete;
    productVideo.playbackRate = reduceMotion ? 16 : 4;
    playProductVideo();
  }

  function resetProductVideo() {
    if (!productVideo || !productMedia) return;
    productPlayCount = 0;
    productSegmentSettled = false;
    window.clearTimeout(productInfoTimer);
    productInfoTimer = null;
    productVideo.pause();
    productVideo.load();
    delete productMedia.dataset.ready;
    delete productScene.dataset.productComplete;
  }

  function revealProductVideo() {
    if (!productVideo || !productMedia) return;

    if (reduceMotion) {
      if (productVideo.ended) productMedia.dataset.ready = "true";
      else playProductVideo();
      return;
    }

    if (productVideo.currentTime + 0.08 >= getProductRevealTime() || productVideo.ended) {
      productVideo.playbackRate = 1;
      productMedia.dataset.ready = "true";
      if (!productVideo.ended) beginVisibleProductPlayback();
      return;
    }

    productVideo.playbackRate = reduceMotion ? 16 : 4;
    playProductVideo();
  }

  function clearTimers() {
    window.clearTimeout(holdTimer);
    window.clearTimeout(payoffTimer);
    window.clearTimeout(bloomTimer);
    window.clearTimeout(resetTimer);
    window.clearTimeout(productInfoTimer);
    holdTimer = null;
    payoffTimer = null;
    bloomTimer = null;
    resetTimer = null;
    productInfoTimer = null;
  }

  function setStage(stage) {
    experience.dataset.stage = stage;

    const productIsVisible = stage === "product";
    arrivalScene.setAttribute("aria-hidden", String(productIsVisible));
    productScene.setAttribute("aria-hidden", String(!productIsVisible));

    if (productIsVisible) {
      revealProductVideo();
      scheduleProductPresentation();
    }
  }

  function resetHold() {
    if (experience.dataset.stage !== "holding") return;

    clearTimers();
    resetProductVideo();
    setStage("resetting");

    resetTimer = window.setTimeout(function () {
      delete experience.dataset.engaged;
      setStage("arrival");
    }, reduceMotion ? 1 : 240);
  }

  function completeHold() {
    if (experience.dataset.stage !== "holding") return;

    setStage("iced");
    holdTarget.disabled = true;

    payoffTimer = window.setTimeout(function () {
      setStage("blooming");

      bloomTimer = window.setTimeout(function () {
        setStage("product");
      }, bloomDuration);
    }, payoffDuration);
  }

  function beginHold(event) {
    if (experience.dataset.stage !== "arrival") return;
    if (event.type === "pointerdown" && event.button !== 0) return;

    event.preventDefault();
    experience.dataset.engaged = "true";
    setStage("holding");
    startProductVideo();
    holdTimer = window.setTimeout(completeHold, holdDuration);
  }

  function releaseHold(event) {
    if (event) event.preventDefault();
    resetHold();
  }

  holdTarget.addEventListener("pointerdown", beginHold);
  window.addEventListener("pointerup", releaseHold);
  window.addEventListener("pointercancel", releaseHold);
  window.addEventListener("blur", releaseHold);

  window.addEventListener("keydown", function (event) {
    if ((event.key === "Enter" || event.key === " ") && !event.repeat) {
      beginHold(event);
    }
  });

  window.addEventListener("keyup", function (event) {
    if (event.key === "Enter" || event.key === " ") {
      releaseHold(event);
    }
  });

  holdTarget.addEventListener("click", function (event) {
    event.preventDefault();
  });

  holdTarget.addEventListener("contextmenu", function (event) {
    event.preventDefault();
  });

  primeProductVideo();
})();
