(function () {
  const experience = document.querySelector(".gxe-experience");
  const arrivalScene = document.querySelector(".gxe-arrival-scene");
  const productScene = document.querySelector(".gxe-product-scene");
  const productMedia = document.querySelector("[data-product-media]");
  const productVideo = document.querySelector(".piece-video");

  if (!experience || !arrivalScene || !productScene) return;

  const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  const configuredIntroDelay = Number.parseInt(experience.dataset.introDelay || "1000", 10);
  const introDelay = reduceMotion ? 420 : (Number.isFinite(configuredIntroDelay) ? configuredIntroDelay : 1000);
  const revealDuration = reduceMotion ? 320 : 1950;
  const payoffDuration = reduceMotion ? 80 : 720;
  const bloomDuration = reduceMotion ? 140 : 720;
  const videoFadeDuration = reduceMotion ? 20 : 190;
  let introTimer = null;
  let revealTimer = null;
  let payoffTimer = null;
  let bloomTimer = null;
  let videoGeneration = 0;
  let productCuePromise = null;
  let productPlaybackStarted = false;
  let productSettling = false;

  function getProductRevealTime() {
    if (!productMedia) return 0;

    const configuredTime = Number.parseFloat(productMedia.dataset.videoStart || "0");
    return Number.isFinite(configuredTime) ? configuredTime : 0;
  }

  function getProductSegmentDuration() {
    if (!productMedia) return 6;

    const configuredDuration = Number.parseFloat(productMedia.dataset.videoDuration || "6");
    return Number.isFinite(configuredDuration) && configuredDuration > 0 ? configuredDuration : 6;
  }

  function getProductFinalFrame() {
    if (!productMedia) return 0;

    const configuredTime = Number.parseFloat(productMedia.dataset.videoFinalFrame || "0");
    return Number.isFinite(configuredTime) && configuredTime >= 0 ? configuredTime : 0;
  }

  function clearExperienceTimers() {
    window.clearTimeout(introTimer);
    window.clearTimeout(revealTimer);
    window.clearTimeout(payoffTimer);
    window.clearTimeout(bloomTimer);
    introTimer = null;
    revealTimer = null;
    payoffTimer = null;
    bloomTimer = null;
  }

  function waitForVideoMetadata(generation) {
    if (!productVideo || productVideo.readyState >= 1) return Promise.resolve();

    return new Promise(function (resolve) {
      const finish = function () {
        productVideo.removeEventListener("loadedmetadata", finish);
        productVideo.removeEventListener("error", finish);
        resolve(generation === videoGeneration);
      };
      productVideo.addEventListener("loadedmetadata", finish, { once: true });
      productVideo.addEventListener("error", finish, { once: true });
    });
  }

  function waitForVideoData(generation) {
    if (!productVideo || productVideo.readyState >= 2) return Promise.resolve(true);

    return new Promise(function (resolve) {
      const finish = function () {
        productVideo.removeEventListener("loadeddata", finish);
        productVideo.removeEventListener("error", finish);
        resolve(generation === videoGeneration && !productVideo.error);
      };
      productVideo.addEventListener("loadeddata", finish, { once: true });
      productVideo.addEventListener("error", finish, { once: true });
    });
  }

  function waitForSeek(generation) {
    if (!productVideo) return Promise.resolve(false);

    return new Promise(function (resolve) {
      let settled = false;
      const finish = function () {
        if (settled) return;
        settled = true;
        productVideo.removeEventListener("seeked", finish);
        productVideo.removeEventListener("error", finish);
        resolve(generation === videoGeneration);
      };
      productVideo.addEventListener("seeked", finish, { once: true });
      productVideo.addEventListener("error", finish, { once: true });
      window.setTimeout(finish, 1200);
    });
  }

  function waitForPaintedVideoFrame(generation) {
    if (!productVideo) return Promise.resolve(false);

    return new Promise(function (resolve) {
      let settled = false;
      const finish = function () {
        if (settled) return;
        settled = true;
        resolve(generation === videoGeneration);
      };

      if (typeof productVideo.requestVideoFrameCallback === "function") {
        productVideo.requestVideoFrameCallback(finish);
        window.setTimeout(finish, 180);
        return;
      }

      window.requestAnimationFrame(function () {
        window.requestAnimationFrame(finish);
      });
    });
  }

  async function seekProductVideo(targetTime, generation) {
    if (!productVideo || generation !== videoGeneration) return false;

    await waitForVideoMetadata(generation);
    await waitForVideoData(generation);
    if (generation !== videoGeneration || productVideo.error) return false;

    const maximumTime = Number.isFinite(productVideo.duration)
      ? Math.max(0, productVideo.duration - 0.04)
      : targetTime;
    const safeTime = Math.min(Math.max(0, targetTime), maximumTime);
    if (Math.abs(productVideo.currentTime - safeTime) < 0.025 && productVideo.readyState >= 2) {
      return true;
    }

    const seekComplete = waitForSeek(generation);
    try {
      productVideo.currentTime = safeTime;
    } catch (error) {
      return false;
    }
    const seeked = await seekComplete;
    return seeked && Math.abs(productVideo.currentTime - safeTime) < 0.08;
  }

  function playConcealedToRevealTime(generation) {
    if (!productVideo) return Promise.resolve(false);

    const revealTime = getProductRevealTime();
    if (revealTime <= 0.08) return Promise.resolve(true);

    return new Promise(function (resolve) {
      let settled = false;
      const finish = function (reachedTarget) {
        if (settled) return;
        settled = true;
        window.clearTimeout(timeout);
        productVideo.removeEventListener("timeupdate", checkProgress);
        productVideo.pause();
        productVideo.playbackRate = 1;
        resolve(Boolean(reachedTarget && generation === videoGeneration));
      };
      const checkProgress = function () {
        if (generation !== videoGeneration) {
          finish(false);
          return;
        }
        if (productVideo.currentTime + 0.08 >= revealTime) finish(true);
      };
      const timeout = window.setTimeout(function () {
        finish(false);
      }, 6000);

      productVideo.addEventListener("timeupdate", checkProgress);
      productVideo.playbackRate = 4;
      let playback;
      try {
        playback = productVideo.play();
      } catch (error) {
        finish(false);
        return;
      }
      if (playback) playback.catch(function () { finish(false); });
    });
  }

  async function cueProductReveal(generation) {
    const directlySeeked = await seekProductVideo(getProductRevealTime(), generation);
    if (directlySeeked || generation !== videoGeneration) return directlySeeked;
    return playConcealedToRevealTime(generation);
  }

  async function restoreOpeningVideoFrame(generation) {
    if (!productVideo || generation !== videoGeneration) return false;

    productVideo.load();
    await waitForVideoMetadata(generation);
    const loaded = await waitForVideoData(generation);
    return Boolean(loaded && generation === videoGeneration && !productVideo.error);
  }

  function completeProductPresentation() {
    productScene.dataset.productComplete = "true";
  }

  async function settleOnOpeningFrame() {
    if (!productVideo || !productMedia || productSettling) return;

    productSettling = true;
    productPlaybackStarted = false;
    const generation = videoGeneration;
    productVideo.pause();
    productVideo.playbackRate = 1;
    delete productMedia.dataset.playing;
    productMedia.dataset.transitioning = "true";

    await new Promise(function (resolve) {
      window.setTimeout(resolve, videoFadeDuration);
    });
    if (generation !== videoGeneration) return;

    const finalFrameTime = getProductFinalFrame();
    const frameReady = finalFrameTime <= 0.08
      ? await restoreOpeningVideoFrame(generation)
      : await seekProductVideo(finalFrameTime, generation);
    if (!frameReady || generation !== videoGeneration) {
      productMedia.dataset.failed = "true";
      delete productMedia.dataset.transitioning;
      completeProductPresentation();
      return;
    }

    await waitForPaintedVideoFrame(generation);
    if (generation !== videoGeneration) return;

    productMedia.dataset.ready = "true";
    productMedia.dataset.finalFrame = "true";
    delete productMedia.dataset.transitioning;
    completeProductPresentation();
  }

  function getProductEndTime() {
    const configuredEnd = getProductRevealTime() + getProductSegmentDuration();
    if (!productVideo || !Number.isFinite(productVideo.duration)) return configuredEnd;
    return Math.min(configuredEnd, Math.max(0, productVideo.duration - 0.08));
  }

  async function startVisibleProductPlayback() {
    if (!productVideo || !productMedia || productPlaybackStarted || productSettling) return;

    const generation = videoGeneration;
    let productCued = productCuePromise ? await productCuePromise : false;
    if (generation !== videoGeneration || experience.dataset.stage !== "product") return;

    if (!productCued) {
      productCued = await cueProductReveal(generation);
    }
    if (!productCued || generation !== videoGeneration) {
      await settleOnOpeningFrame();
      return;
    }

    if (reduceMotion) {
      await settleOnOpeningFrame();
      return;
    }

    productPlaybackStarted = true;
    productVideo.playbackRate = 1;
    productMedia.dataset.ready = "true";

    let playback;
    try {
      playback = productVideo.play();
    } catch (error) {
      productPlaybackStarted = false;
      await settleOnOpeningFrame();
      return;
    }

    if (playback) {
      playback.catch(function () {
        if (generation === videoGeneration) {
          productPlaybackStarted = false;
          settleOnOpeningFrame();
        }
      });
    }

    await waitForPaintedVideoFrame(generation);
    if (generation === videoGeneration && productPlaybackStarted) {
      productMedia.dataset.playing = "true";
    }
  }

  function prepareProductVideo() {
    if (!productVideo || !productMedia) return;

    const generation = ++videoGeneration;
    productPlaybackStarted = false;
    productSettling = false;
    productVideo.pause();
    productVideo.playbackRate = 1;
    delete productMedia.dataset.ready;
    delete productMedia.dataset.playing;
    delete productMedia.dataset.transitioning;
    delete productMedia.dataset.finalFrame;
    delete productMedia.dataset.failed;
    delete productScene.dataset.productComplete;
    productVideo.load();

    productCuePromise = cueProductReveal(generation).then(function (cued) {
      if (!cued || generation !== videoGeneration) return false;
      productMedia.dataset.ready = "true";
      if (experience.dataset.stage === "product") startVisibleProductPlayback();
      return true;
    });
  }

  function setStage(stage) {
    experience.dataset.stage = stage;

    const productIsVisible = stage === "product";
    arrivalScene.setAttribute("aria-hidden", String(productIsVisible));
    productScene.setAttribute("aria-hidden", String(!productIsVisible));

    if (productIsVisible) startVisibleProductPlayback();
  }

  function completeAutomaticReveal() {
    if (experience.dataset.stage !== "revealing") return;

    setStage("iced");
    payoffTimer = window.setTimeout(function () {
      setStage("blooming");
      bloomTimer = window.setTimeout(function () {
        setStage("product");
      }, bloomDuration);
    }, payoffDuration);
  }

  function beginAutomaticReveal() {
    if (experience.dataset.stage !== "arrival") return;

    experience.dataset.engaged = "true";
    setStage("revealing");
    revealTimer = window.setTimeout(completeAutomaticReveal, revealDuration);
  }

  function scheduleAutomaticReveal() {
    window.clearTimeout(introTimer);
    introTimer = window.setTimeout(beginAutomaticReveal, introDelay);
  }

  function replayIntroduction() {
    if (detailDialog && detailDialog.open) detailDialog.close();
    clearExperienceTimers();
    delete experience.dataset.engaged;
    setStage("arrival");
    prepareProductVideo();
    scheduleAutomaticReveal();
  }

  if (productVideo && productMedia) {
    productVideo.muted = true;
    productVideo.addEventListener("timeupdate", function () {
      if (
        experience.dataset.stage === "product" &&
        productPlaybackStarted &&
        !productSettling &&
        productVideo.currentTime >= getProductEndTime() - 0.06
      ) {
        settleOnOpeningFrame();
      }
    });
    productVideo.addEventListener("ended", function () {
      if (experience.dataset.stage === "product" && !productSettling) {
        settleOnOpeningFrame();
      }
    });
    productVideo.addEventListener("error", function () {
      productMedia.dataset.failed = "true";
      delete productMedia.dataset.transitioning;
      completeProductPresentation();
    });
  }

  const replayButton = document.querySelector("[data-gxe-replay]");
  const detailDialog = document.querySelector("[data-gxe-dialog]");
  const dialogTitle = document.getElementById("gxe-dialog-title");
  const dialogShell = document.querySelector(".gxe-dialog-shell");
  const panelButtons = Array.from(document.querySelectorAll("[data-gxe-panel]"));
  const dialogViews = Array.from(document.querySelectorAll("[data-gxe-view]"));
  const closeButtons = Array.from(document.querySelectorAll("[data-gxe-close]"));
  const reservationForm = document.querySelector("[data-gxe-reservation-form]");
  const reservationSuccess = document.querySelector("[data-gxe-reservation-success]");
  const reservationReference = document.querySelector("[data-gxe-reservation-reference]");
  const reservationReset = document.querySelector("[data-gxe-reservation-reset]");

  function openPanel(panelName) {
    if (!detailDialog) return;

    const activeView = dialogViews.find(function (view) {
      return view.dataset.gxeView === panelName;
    });
    if (!activeView) return;

    dialogViews.forEach(function (view) {
      view.hidden = view !== activeView;
    });
    panelButtons.forEach(function (button) {
      const isCurrent = button.dataset.gxePanel === panelName;
      button.setAttribute("aria-current", isCurrent ? "page" : "false");
    });

    if (!detailDialog.open) detailDialog.showModal();
    window.requestAnimationFrame(function () {
      if (dialogShell) dialogShell.scrollTop = 0;
      if (dialogTitle) dialogTitle.focus({ preventScroll: true });
    });
  }

  if (replayButton) replayButton.addEventListener("click", replayIntroduction);

  panelButtons.forEach(function (button) {
    button.addEventListener("click", function () {
      openPanel(button.dataset.gxePanel);
    });
  });

  closeButtons.forEach(function (button) {
    button.addEventListener("click", function () {
      if (detailDialog && detailDialog.open) detailDialog.close();
    });
  });

  if (detailDialog) {
    detailDialog.addEventListener("click", function (event) {
      if (event.target === detailDialog) detailDialog.close();
    });
  }

  if (reservationForm && reservationSuccess && reservationReference) {
    reservationForm.addEventListener("submit", function (event) {
      event.preventDefault();
      if (!reservationForm.reportValidity()) return;

      const formData = new FormData(reservationForm);
      const reference = "GXE-" + Date.now().toString(36).slice(-6).toUpperCase();
      const previewRequest = {
        reference: reference,
        name: String(formData.get("name") || ""),
        email: String(formData.get("email") || ""),
        size: String(formData.get("size") || ""),
        fit: String(formData.get("fit") || ""),
        note: String(formData.get("note") || ""),
        saved_at: new Date().toISOString(),
        mode: "local-preview"
      };

      try {
        window.localStorage.setItem("gxe:first-drop-preview-request", JSON.stringify(previewRequest));
      } catch (error) {
        previewRequest.storage = "unavailable";
      }

      reservationReference.textContent = "Reference " + reference;
      reservationForm.hidden = true;
      reservationSuccess.hidden = false;
      reservationSuccess.focus();
    });
  }

  if (reservationReset && reservationForm && reservationSuccess) {
    reservationReset.addEventListener("click", function () {
      reservationSuccess.hidden = true;
      reservationForm.hidden = false;
      reservationForm.reset();
      const firstField = reservationForm.querySelector("input");
      if (firstField) firstField.focus();
    });
  }

  prepareProductVideo();
  scheduleAutomaticReveal();
})();