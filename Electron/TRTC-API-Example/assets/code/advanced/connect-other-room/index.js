(() => {
  const { ipcRenderer } = require('electron');
  const TRTCCloud = require('trtc-electron-sdk').default;
  const {
    TRTCAppScene,
    TRTCParams,
    TRTCVideoEncParam,
    TRTCVideoResolution,
    TRTCAudioQuality,
    TRTCVideoResolutionMode,
    TRTCVideoStreamType,
    TRTCRoleType,
  } = require('trtc-electron-sdk');

  // ====== todo: Examples 设置区 start =================================
  const localUserId = '' || window.globalUserId; // 用户名，必填
  const roomId = 0 || window.globalRoomId; // 会议号，数字类型（大于零），必填;
  let connectRoomId = 0;
  let connectUserId = '';
  // SDKAPPID, SECRETKEY 可在 assets/debug/gen-test-user-sig.js 里进行设置
  const info = window.genTestUserSig(localUserId);
  const sdkAppId = 0 || info.sdkappid; // 应用编号，必填
  const userSig = '' || info.userSig; // 用户签名，必填
  // ====== todo: Examples 设置区 end =================================

  const LOG_PREFIX = 'Connect other room';
  const trtc = new TRTCCloud();
  console.log('TRTC version:', trtc.getSDKVersion());

  const roomIdContainer = document.querySelector('.connect-other-room .room-id');
  const localUserIdContainer = document.querySelector('.connect-other-room .user-id');
  const connectRoomIdInput = document.querySelector('.connect-other-room .connect-room-id');
  const connectUserIdInput = document.querySelector('.connect-other-room .connect-user-id');
  const connectRoomBtn = document.querySelector('.connect-other-room .connect-room-btn');
  const localVideoContainer = document.querySelector('.connect-other-room #localVideoWrapper');
  const remoteVideoContainer = document.querySelector('.connect-other-room #remoteVideoWrapper');

  let isConnectedRoom = false;

  if (!validParams(localUserId, roomId, sdkAppId, userSig)) {
    return;
  }

  // 进入房间
  function enterRoom() {
    const trtcParams = new TRTCParams();
    // 试用、体验时，在以下地址根据 SDKAppID 和 localUserId 生成 userSig
    // https://console.cloud.tencent.com/trtc/usersigtool
    // 注意：正式生产环境中，userSig需要通过后台生成，前端通过HTTP请求获取
    trtcParams.userId = localUserId; // 用户名，必填
    trtcParams.sdkAppId = sdkAppId; // 应用编号，必填
    trtcParams.userSig = userSig; // 用户签名，必填
    trtcParams.roomId = roomId; // 会议号，数字类型（大于零），必填
    trtcParams.role = TRTCRoleType.TRTCRoleAnchor;

    trtc.enterRoom(trtcParams, TRTCAppScene.TRTCAppSceneVideoCall);
  }

  // 退出房间
  function exitRoom() {
    trtc.stopLocalPreview();
    trtc.stopLocalAudio();
    trtc.exitRoom();
  }

  // 本地用户进入房间事件处理
  function onEnterRoom(elapsed) {
    console.info(`${LOG_PREFIX} onEnterRoom: elapsed: ${elapsed}`);
    if (elapsed < 0) {
      // 小于零表示进房失败
      ipcRenderer.send('notification', LOG_PREFIX, `进房失败, errorCode: ${elapsed}`);
      return;
    }
    start();
  }

  function start() {
    const streamParams = new TRTCVideoEncParam(
      TRTCVideoResolution.TRTCVideoResolution_640_360,
      TRTCVideoResolutionMode.TRTCVideoResolutionModeLandscape,
      15,
      400,
      0,
      false,
    );
    trtc.setVideoEncoderParam(streamParams);
    trtc.startLocalPreview(localVideoContainer);

    // 启动本地音频采集和上行
    trtc.startLocalAudio(TRTCAudioQuality.TRTCAudioQualityDefault);
  }

  // 本地用户退出房间事件处理
  function onExitRoom(reason) {
    console.info(`${LOG_PREFIX} onExitRoom: reason: ${reason}`);
  }

  // Error事件处理
  function onError(errCode, errMsg) {
    console.info(`${LOG_PREFIX} onError: errCode: ${errCode}, errMsg: ${errMsg}`);
  }

  // 远程用户进入房间事件处理
  function onRemoteUserEnterRoom(userId) {
    console.info(`${LOG_PREFIX} onRemoteUserEnterRoom: userId: ${userId}`);
    // 这里可以收集所有远程人员，放入列表进行管理
  }

  function onFirstVideoFrame(uid, type, width, height) {
    console.log(`onFirstVideoFrame: ${uid} ${type} ${width} ${height}`);
  }

  function onUserVideoAvailable(userid, available) {
    console.log(`onUserVideoAvailable ${userid} ${available}`);
    if (available === 1) {
      trtc.startRemoteView(userid, remoteVideoContainer, TRTCVideoStreamType.TRTCVideoStreamTypeBig);
    } else {
      trtc.stopRemoteView(localUserId, TRTCVideoStreamType.TRTCVideoStreamTypeBig);
    }
  }

  // 远程用户退出房间事件处理
  function onRemoteUserLeaveRoom(userId, reason) {
    console.info(`${LOG_PREFIX} onRemoteUserLeaveRoom: userId: ${userId}, reason: ${reason}`);
  }

  function onConnectOtherRoom(userId, errCode, errMsg) {
    console.log(`onConnectOtherRoom userId: ${userId}, errCode: ${errCode}, errMsg: ${errMsg}`);
  }

  function onDisconnectOtherRoom(errCode, errMsg) {
    console.log(`onDisconnectOtherRoom errCode: ${errCode}, errMsg: ${errMsg}`);
  }

  // 订阅事件
  const subscribeEvents = (rtcCloud) => {
    rtcCloud.on('onError', onError);
    rtcCloud.on('onEnterRoom', onEnterRoom);
    rtcCloud.on('onConnectOtherRoom', onConnectOtherRoom);
    rtcCloud.on('onDisconnectOtherRoom', onDisconnectOtherRoom);
    rtcCloud.on('onExitRoom', onExitRoom);
    rtcCloud.on('onRemoteUserEnterRoom', onRemoteUserEnterRoom);
    rtcCloud.on('onFirstVideoFrame', onFirstVideoFrame);
    rtcCloud.on('onUserVideoAvailable', onUserVideoAvailable);
    rtcCloud.on('onRemoteUserLeaveRoom', onRemoteUserLeaveRoom);
  };

  // 取消事件订阅
  const unsubscribeEvents = (rtcCloud) => {
    rtcCloud.off('onError', onError);
    rtcCloud.off('onEnterRoom', onEnterRoom);
    rtcCloud.off('onConnectOtherRoom', onConnectOtherRoom);
    rtcCloud.on('onDisconnectOtherRoom', onDisconnectOtherRoom);
    rtcCloud.off('onExitRoom', onExitRoom);
    rtcCloud.off('onRemoteUserEnterRoom', onRemoteUserEnterRoom);
    rtcCloud.off('onFirstVideoFrame', onFirstVideoFrame);
    rtcCloud.off('onUserVideoAvailable', onUserVideoAvailable);
    rtcCloud.off('onRemoteUserLeaveRoom', onRemoteUserLeaveRoom);
  };

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

  function renderConnectSection() {
    roomIdContainer.textContent = `${roomId}`;
    localUserIdContainer.textContent = `${localUserId}`;
  }

  function handleConnectRoomIdChange(e) {
    connectRoomId = +e.target.value;
  }

  function handleConnectUserIdChange(e) {
    connectUserId = e.target.value;
  }

  function handleConnectBtnClick() {
    if (!isConnectedRoom && !connectRoomId) {
      ipcRenderer.send('notification', LOG_PREFIX, '必须为有效的连麦房间号');
      return;
    }
    if (!isConnectedRoom) {
      connectRoomBtn.textContent = '取消连麦';
      const connectParams = JSON.stringify({ roomId: connectRoomId, userId: connectUserId });
      trtc.connectOtherRoom(connectParams);
    } else {
      connectRoomBtn.textContent = '连麦';
      trtc.disconnectOtherRoom();
    }
    isConnectedRoom = !isConnectedRoom;
  }

  function bindDomEvent() {
    connectRoomIdInput.addEventListener('blur', handleConnectRoomIdChange);
    connectUserIdInput.addEventListener('blur', handleConnectUserIdChange);
    connectRoomBtn.addEventListener('click', handleConnectBtnClick);
  }

  function unBindDomEvent() {
    connectRoomIdInput.removeEventListener('blur', handleConnectRoomIdChange);
    connectUserIdInput.removeEventListener('blur', handleConnectUserIdChange);
    connectRoomBtn.removeEventListener('click', handleConnectBtnClick);
  }

  // ====== 注册事件监听，进入房间：start =================================
  subscribeEvents(trtc);
  enterRoom();
  bindDomEvent();
  renderConnectSection();
  // ====== 注册事件监听，进入房间：end ===================================

  // ====== 停止运行后，退出房间，清理事件订阅：start =======================
  // 这里借助 ipcRenderer 获取停止示例代码运行事件，
  // 实际项目中直接在“停止”按钮的点击事件中处理即可
  ipcRenderer.on('stop-example', (event, arg) => {
    if (arg.type === 'connect-other-room') {
      exitRoom();
      unBindDomEvent();
      setTimeout(() => {
        unsubscribeEvents(trtc);
        trtc.destroy();
      }, 1000);
    }
  });
  // ====== 停止运行后，退出房间，清理事件订阅：end =========================
})();
