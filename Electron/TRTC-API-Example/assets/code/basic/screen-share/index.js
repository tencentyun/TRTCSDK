(() => {
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
  // todo: Examples 设置区
  const userId =  '' || window.globalUserId; // 用户名，必填
  const roomId = 0 || window.globalRoomId; // 会议号，数字类型（大于零），必填;
  // SDKAPPID, SECRETKEY 可在 assets/debug/gen-test-user-sig.js 里进行设置
  const info = window.genTestUserSig(userId);
  const sdkAppId =  0 || info.sdkappid; // 应用编号，必填
  const userSig = '' || info.userSig; // 用户签名，必填

  // 屏幕窗口列表区域
  const screenListPreviewNode = document.querySelector('.basic-screen-share .screen-list');
  // 本地屏幕分享预览区域
  const localScreenShareNode = document.querySelector('.basic-screen-share .localScreenShareWrapper');
  // 远端屏幕分享预览区域
  const remoteScreenShareNode = document.querySelector('.basic-screen-share .remoteScreenShareWrapper');

  // 获取的所有屏幕分享窗口
  let screenCaptureList = [];

  const LOG_PREFIX = 'Screen share';
  const trtc = new TRTCCloud();
  console.log('TRTC version:', trtc.getSDKVersion());

  if (!validParams(userId, roomId, sdkAppId, userSig)) {
    return;
  }

  // 本地用户进入房间事件处理
  function onEnterRoom(elapsed) {
    console.info(`${LOG_PREFIX} onEnterRoom: elapsed: ${elapsed}`);
    if (elapsed < 0) {
      // 小于零表示进房失败
      ipcRenderer.send('notification', LOG_PREFIX, `进房失败, errorCode: ${elapsed}`);
      return;
    }
    displayScreenShare();
  }

  // 本地用户退出房间事件处理
  function onExitRoom(reason) {
    console.info(`${LOG_PREFIX} onExitRoom: reason: ${reason}`);
  }

  // Error事件处理
  function onError(errCode, errMsg) {
    console.info(`${LOG_PREFIX} onError: errCode: ${errCode}, errMsg: ${errMsg}`);
    if (errCode === -102016) {
      // https://cloud.tencent.com/document/product/647/38552#.E5.B1.8F.E5.B9.95.E5.88.86.E4.BA.AB.E7.9B.B8.E5.85.B3.E9.94.99.E8.AF.AF.E7.A0.81
      ipcRenderer.send('notification', LOG_PREFIX, '其他用户正在上行辅路');
    }
  }

  // 订阅事件
  const subscribeEvents = (rtcCloud) => {
    rtcCloud.on('onError', onError);
    rtcCloud.on('onEnterRoom', onEnterRoom);
    rtcCloud.on('onExitRoom', onExitRoom);
    rtcCloud.on('onRemoteUserEnterRoom', onRemoteUserEnterRoom);
    rtcCloud.on('onFirstVideoFrame', onFirstVideoFrame);
    rtcCloud.on('onRemoteUserLeaveRoom', onRemoteUserLeaveRoom);
    rtcCloud.on('onUserSubStreamAvailable', onUserSubStreamAvailable);
  };

  // 取消事件订阅
  const unsubscribeEvents = (rtcCloud) => {
    rtcCloud.off('onError', onError);
    rtcCloud.off('onEnterRoom', onEnterRoom);
    rtcCloud.off('onExitRoom', onExitRoom);
    rtcCloud.off('onRemoteUserEnterRoom', onRemoteUserEnterRoom);
    rtcCloud.off('onFirstVideoFrame', onFirstVideoFrame);
    rtcCloud.off('onRemoteUserLeaveRoom', onRemoteUserLeaveRoom);
    rtcCloud.off('onUserSubStreamAvailable', onUserSubStreamAvailable);
  };

  // 进入房间
  function enterRoom() {
    const trtcParams = new TRTCParams();
    // 试用、体验时，在以下地址根据 SDKAppID 和 userId 生成 userSig
    // https://console.cloud.tencent.com/trtc/usersigtool
    // 注意：正式生产环境中，userSig需要通过后台生成，前端通过HTTP请求获取
    trtcParams.userId =  userId; // 用户名，必填
    trtcParams.sdkAppId = sdkAppId; // 应用编号，必填
    trtcParams.userSig = userSig; // 用户签名，必填
    trtcParams.roomId = roomId; // 会议号，数字类型（大于零），必填

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
    const screenTitleHtml = createDom('<div class="screen-share-title">桌面</div>');
    const windowTitleHtml = createDom('<div class="screen-share-title">窗口</div>');
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
      const shareBtnNode = createDom(`<button data-screenid=${screen.sourceId} class="share-btn">分享</button>`);
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

  // 远程用户进入房间事件处理
  function onRemoteUserEnterRoom(userId) {
    console.info(`${LOG_PREFIX} onRemoteUserEnterRoom: userId: ${userId}`);
    // 这里可以收集所有远程人员，放入列表进行管理
  }

  function onFirstVideoFrame(uid, type, width, height) {
    console.log(`onFirstVideoFrame: ${uid} ${type} ${width} ${height}`);
  }

  // 远程用户退出房间事件处理
  function onRemoteUserLeaveRoom(userId, reason) {
    console.info(`${LOG_PREFIX} onRemoteUserLeaveRoom: userId: ${userId}, reason: ${reason}`);
  }

  // 远端用户是否开启了辅路画面
  function onUserSubStreamAvailable(userId, available) {
    if (available === 1) {
      remoteScreenShareNode.innerHTML = '';
      trtc.startRemoteView(userId, remoteScreenShareNode, TRTCVideoStreamType.TRTCVideoStreamTypeSub);
    } else {
      trtc.stopRemoteView(userId, TRTCVideoStreamType.TRTCVideoStreamTypeSub);
      remoteScreenShareNode.innerHTML = 'Remote Screen Share Preview';
    }
  }

  // 退出房间
  function exitRoom() {
    trtc.stopLocalPreview();
    trtc.stopLocalAudio();
    trtc.exitRoom();
  }

  function handleScreenListClick(e) {
    const clickNode = e.target;
    const allShareBtns = [...document.querySelectorAll('.basic-screen-share .share-btn')];
    if ([...clickNode.classList].indexOf('share-btn') !== -1) {
      if (clickNode.textContent === '分享') {
        allShareBtns.forEach((item) => {
          if (item.textContent === '停止分享') {
            // 有其他的正在分享
            trtc.stopScreenCapture();
            // eslint-disable-next-line
            item.textContent = '分享';
          }
        });
        clickNode.textContent = '停止分享';
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
        clickNode.textContent = '分享';
        trtc.stopScreenCapture();
        localScreenShareNode.textContent = 'Local Screen Share Preview';
      }
    }
  }

  function bindEvents() {
    // 屏幕分享按钮点击
    screenListPreviewNode.addEventListener('click', handleScreenListClick, false);
  }

  function unBindEvents() {
    screenListPreviewNode.removeEventListener('click', handleScreenListClick, false);
  }

  function validParams(userId, roomId, sdkAppId, userSig) {
    const errors = [];
    if (!userId) {
      errors.push('userId 未设置');
    }
    if (roomId === 0) {
      errors.push('roomId 未设置');
    }
    if (sdkAppId === 0) {
      errors.push('sdkAppId 未设置');
    }
    if (userSig === '') {
      errors.push('userSig 未设置');
    }
    if (errors.length) {
      ipcRenderer.send('notification', LOG_PREFIX, errors.join(','));
      return false;
    }
    return true;
  }

  // ====== 注册事件监听，进入房间：start =================================
  subscribeEvents(trtc);
  enterRoom();
  bindEvents();
  // ====== 注册事件监听，进入房间：end ===================================

  // ====== 停止运行后，退出房间，清理事件订阅：start =======================
  // 这里借助 ipcRenderer 获取停止示例代码运行事件，
  // 实际项目中直接在“停止”按钮的点击事件中处理即可
  ipcRenderer.on('stop-example', (event, arg) => {
    if (arg.type === 'screen-share') {
      exitRoom();
      unBindEvents();
      setTimeout(() => {
        unsubscribeEvents(trtc);
        trtc.destroy();
      }, 1000);
    }
  });
  // ====== 停止运行后，退出房间，清理事件订阅：end =========================
})();
