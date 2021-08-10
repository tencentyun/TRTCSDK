(async () => {
  const { ipcRenderer } = require('electron');
  const TRTCCloud = require('trtc-electron-sdk').default;
  const {
    TRTCAppScene,
    TRTCParams,
    TRTCVideoStreamType,
    TRTCScreenCaptureSourceType,
    Rect,
    TRTCVideoEncParam,
    TRTCVideoResolution,
    TRTCVideoResolutionMode,
  } = require('trtc-electron-sdk');

  const userId =  '' || window.globalUserId;
  const roomId = 0 || window.globalRoomId;
  const info = await window.genTestUserSig(userId);
  const sdkAppId =  0 || info.sdkappid;
  const userSignature = '' || info.userSig;

  const screenListPreviewNode = document.querySelector('.basic-screen-share .screen-list');
  const localScreenShareNode = document.querySelector('.basic-screen-share .localScreenShareWrapper');
  const remoteScreenShareNode = document.querySelector('.basic-screen-share .remoteScreenShareWrapper');

  let screenCaptureList = [];

  const LOG_PREFIX = '[Screen Share]';
  const trtc = new TRTCCloud();
  console.log(`${LOG_PREFIX} TRTC version:`, trtc.getSDKVersion());

  if (!validParams(userId, roomId, sdkAppId, userSignature)) {
    return;
  }

  function onEnterRoom(elapsed) {
    console.info(`${LOG_PREFIX} onEnterRoom: elapsed: ${elapsed}`);
    if (elapsed < 0) {
      ipcRenderer.send('notification', LOG_PREFIX, `${window.a18n('进房失败')}, errorCode: ${elapsed}`);
      return;
    }
    displayScreenShare();
  }

  function onExitRoom(reason) {
    console.info(`${LOG_PREFIX} onExitRoom: reason: ${reason}`);
  }

  function onError(errCode, errMsg) {
    console.info(`${LOG_PREFIX} onError: errCode: ${errCode}, errMsg: ${errMsg}`);
    if (errCode === -102016) {
      // https://cloud.tencent.com/document/product/647/38552#.E5.B1.8F.E5.B9.95.E5.88.86.E4.BA.AB.E7.9B.B8.E5.85.B3.E9.94.99.E8.AF.AF.E7.A0.81
      ipcRenderer.send('notification', LOG_PREFIX, window.a18n('其他用户正在上行辅路画面'));
    }
  }

  const subscribeEvents = () => {
    trtc.on('onError', onError);
    trtc.on('onEnterRoom', onEnterRoom);
    trtc.on('onExitRoom', onExitRoom);
    trtc.on('onRemoteUserEnterRoom', onRemoteUserEnterRoom);
    trtc.on('onFirstVideoFrame', onFirstVideoFrame);
    trtc.on('onRemoteUserLeaveRoom', onRemoteUserLeaveRoom);
    trtc.on('onUserSubStreamAvailable', onUserSubStreamAvailable);
  };

  const unsubscribeEvents = () => {
    trtc.off('onError', onError);
    trtc.off('onEnterRoom', onEnterRoom);
    trtc.off('onExitRoom', onExitRoom);
    trtc.off('onRemoteUserEnterRoom', onRemoteUserEnterRoom);
    trtc.off('onFirstVideoFrame', onFirstVideoFrame);
    trtc.off('onRemoteUserLeaveRoom', onRemoteUserLeaveRoom);
    trtc.off('onUserSubStreamAvailable', onUserSubStreamAvailable);
  };

  function enterRoom() {
    const trtcParams = new TRTCParams();
    trtcParams.userId =  userId;
    trtcParams.sdkAppId = sdkAppId;
    trtcParams.userSig = userSignature;
    trtcParams.roomId = roomId;

    trtc.enterRoom(trtcParams, TRTCAppScene.TRTCAppSceneAudioCall);
  }

  function displayScreenShare() {
    screenCaptureList = trtc.getScreenCaptureSources(100, 75, 30, 30);
    const screenTypeList = screenCaptureList.filter(screen => (
      screen.type === TRTCScreenCaptureSourceType.TRTCScreenCaptureSourceTypeScreen
    ));
    const windowTypeList = screenCaptureList.filter(screen => (
      screen.type === TRTCScreenCaptureSourceType.TRTCScreenCaptureSourceTypeWindow
    ));
    const screenTitleHtml = createDom(`<div class="screen-share-title">${window.a18n('桌面')}</div>`);
    const windowTitleHtml = createDom(`<div class="screen-share-title">${window.a18n('窗口')}</div>`);
    const screenTypeListNode = getScreenListNode(screenTypeList);
    const windowTypeListNode = getScreenListNode(windowTypeList);

    screenListPreviewNode.appendChild(screenTitleHtml);
    screenListPreviewNode.appendChild(screenTypeListNode);
    screenListPreviewNode.appendChild(windowTitleHtml);
    screenListPreviewNode.appendChild(windowTypeListNode);
  }

  function getScreenListNode(screens) {
    const screenListNode = createDom('<div class="screen-share-list"></div>');
    screens.slice(0, 4).forEach((screen) => {
      const canvas = createDom(`
        <canvas width="${screen.thumbBGRA.width}" height="${screen.thumbBGRA.height}"></canvas>
      `);
      const ctx = canvas.getContext('2d');
      const img = new ImageData(
        new Uint8ClampedArray(screen.thumbBGRA.buffer),
        screen.thumbBGRA.width,
        screen.thumbBGRA.height,
      );
      if (ctx !== null) {
        ctx.putImageData(img, 0, 0);
      }

      const itemNameNode = createDom(`<div class="share-item-name">${screen.sourceName}</div>`);
      const shareBtnNode = createDom(`<button data-screenid=${screen.sourceId} class="share-btn">${window.a18n('分享')}</button>`);
      const screenNode = createDom(`
        <div class="share-item">
        </div>
      `);
      screenNode.appendChild(canvas);
      screenNode.appendChild(itemNameNode);
      screenNode.appendChild(shareBtnNode);
      screenListNode.appendChild(screenNode);
    });
    return screenListNode;
  }

  function createDom(domStr) {
    const doc = new DOMParser().parseFromString(domStr, 'text/html');
    return doc.body.firstChild;
  }

  function onRemoteUserEnterRoom(userId) {
    console.info(`${LOG_PREFIX} onRemoteUserEnterRoom: userId: ${userId}`);
  }

  function onFirstVideoFrame(uid, type, width, height) {
    console.log(`onFirstVideoFrame: ${uid} ${type} ${width} ${height}`);
  }

  function onRemoteUserLeaveRoom(userId, reason) {
    console.info(`${LOG_PREFIX} onRemoteUserLeaveRoom: userId: ${userId}, reason: ${reason}`);
  }

  function onUserSubStreamAvailable(userId, available) {
    if (available === 1) {
      remoteScreenShareNode.innerHTML = '';
      trtc.startRemoteView(userId, remoteScreenShareNode, TRTCVideoStreamType.TRTCVideoStreamTypeSub);
    } else {
      trtc.stopRemoteView(userId, TRTCVideoStreamType.TRTCVideoStreamTypeSub);
      remoteScreenShareNode.innerHTML = window.a18n('远程屏幕分享预览区');
    }
  }

  function exitRoom() {
    trtc.stopLocalPreview();
    trtc.stopLocalAudio();
    trtc.exitRoom();
  }

  function handleScreenListClick(e) {
    const clickNode = e.target;
    const allShareBtns = [...document.querySelectorAll('.basic-screen-share .share-btn')];
    if ([...clickNode.classList].indexOf('share-btn') !== -1) {
      if (clickNode.textContent === window.a18n('分享')) {
        allShareBtns.forEach((item) => {
          if (item.textContent === window.a18n('停止分享')) {
            trtc.stopScreenCapture();
            // eslint-disable-next-line
            item.textContent = window.a18n('分享');
          }
        });
        clickNode.textContent = window.a18n('停止分享');
        const selectScreenId = clickNode.dataset.screenid;
        const currentScreen = screenCaptureList.find(item => item.sourceId === selectScreenId);
        if (currentScreen) {
          localScreenShareNode.innerHTML = '';
          const selectRect = new Rect();
          const screenShareEncParam = new TRTCVideoEncParam(
            TRTCVideoResolution.TRTCVideoResolution_1280_720,
            TRTCVideoResolutionMode.TRTCVideoResolutionModeLandscape,
            15,
            1600,
            0,
            true,
          );
          trtc.selectScreenCaptureTarget(
            currentScreen.type, currentScreen.sourceId, currentScreen.sourceName, selectRect,
            true, true,
          );
          trtc.startScreenCapture(
            localScreenShareNode,
            TRTCVideoStreamType.TRTCVideoStreamTypeSub,
            screenShareEncParam,
          );
        }
      } else {
        clickNode.textContent = window.a18n('分享');
        trtc.stopScreenCapture();
        localScreenShareNode.textContent = window.a18n('本地屏幕分享预览区');
      }
    }
  }

  function bindEvents() {
    screenListPreviewNode.addEventListener('click', handleScreenListClick, false);
  }

  function unBindEvents() {
    screenListPreviewNode.removeEventListener('click', handleScreenListClick, false);
  }

  function validParams(userId, roomId, sdkAppId, userSignature) {
    const errors = [];
    if (!userId) {
      errors.push('"userId" is not valid');
    }
    if (roomId === 0) {
      errors.push('"roomId" is not valid');
    }
    if (sdkAppId === 0) {
      errors.push('"sdkAppId" is not valid');
    }
    if (userSignature === '') {
      errors.push('"userSignature" is not valid');
    }
    if (errors.length) {
      ipcRenderer.send('notification', LOG_PREFIX, errors.join(','));
      return false;
    }
    return true;
  }

  subscribeEvents();
  enterRoom();
  bindEvents();

  ipcRenderer.on('stop-example', (event, arg) => {
    if (arg.type === 'screen-share') {
      exitRoom();
      unBindEvents();
      setTimeout(() => {
        unsubscribeEvents();
        trtc.destroy();
      }, 1000);
    }
  });
})();
