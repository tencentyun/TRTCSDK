(async () => {
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

  const localUserId = '' || window.globalUserId;
  const roomId = 0 || window.globalRoomId;
  let connectRoomId = 0;
  let connectUserId = '';
  const info = await window.genTestUserSig(localUserId);
  const sdkAppId = 0 || info.sdkappid;
  const userSignature = '' || info.userSig;

  const LOG_PREFIX = '[Connect Other Room]';
  const trtc = new TRTCCloud();
  console.log(`${LOG_PREFIX} TRTC version:`, trtc.getSDKVersion());

  const roomIdContainer = document.querySelector('.connect-other-room .room-id');
  const localUserIdContainer = document.querySelector('.connect-other-room .user-id');
  const connectRoomIdInput = document.querySelector('.connect-other-room .connect-room-id');
  const connectUserIdInput = document.querySelector('.connect-other-room .connect-user-id');
  const connectRoomBtn = document.querySelector('.connect-other-room .connect-room-btn');
  const localVideoContainer = document.querySelector('.connect-other-room #localVideoWrapper');
  const remoteVideoContainer = document.querySelector('.connect-other-room #remoteVideoWrapper');

  let isConnectedRoom = false;

  if (!validParams(localUserId, roomId, sdkAppId, userSignature)) {
    return;
  }

  function enterRoom() {
    const trtcParams = new TRTCParams();
    trtcParams.userId = localUserId;
    trtcParams.sdkAppId = sdkAppId;
    trtcParams.userSig = userSignature;
    trtcParams.roomId = roomId;
    trtcParams.role = TRTCRoleType.TRTCRoleAnchor;

    trtc.enterRoom(trtcParams, TRTCAppScene.TRTCAppSceneVideoCall);
  }

  function exitRoom() {
    trtc.stopLocalPreview();
    trtc.stopLocalAudio();
    trtc.exitRoom();
  }

  function onEnterRoom(elapsed) {
    console.info(`${LOG_PREFIX} onEnterRoom: elapsed: ${elapsed}`);
    if (elapsed < 0) {
      ipcRenderer.send('notification', LOG_PREFIX, `${window.a18n('进房失败')}, errorCode: ${elapsed}`);
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


    trtc.startLocalAudio(TRTCAudioQuality.TRTCAudioQualityDefault);
  }

  function onExitRoom(reason) {
    console.info(`${LOG_PREFIX} onExitRoom: reason: ${reason}`);
  }

  function onError(errCode, errMsg) {
    console.info(`${LOG_PREFIX} onError: errCode: ${errCode}, errMsg: ${errMsg}`);
  }

  function onRemoteUserEnterRoom(userId) {
    console.info(`${LOG_PREFIX} onRemoteUserEnterRoom: userId: ${userId}`);
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

  function onRemoteUserLeaveRoom(userId, reason) {
    console.info(`${LOG_PREFIX} onRemoteUserLeaveRoom: userId: ${userId}, reason: ${reason}`);
  }

  function onConnectOtherRoom(userId, errCode, errMsg) {
    console.log(`onConnectOtherRoom userId: ${userId}, errCode: ${errCode}, errMsg: ${errMsg}`);
  }

  function onDisconnectOtherRoom(errCode, errMsg) {
    console.log(`onDisconnectOtherRoom errCode: ${errCode}, errMsg: ${errMsg}`);
  }

  const subscribeEvents = () => {
    trtc.on('onError', onError);
    trtc.on('onEnterRoom', onEnterRoom);
    trtc.on('onConnectOtherRoom', onConnectOtherRoom);
    trtc.on('onDisconnectOtherRoom', onDisconnectOtherRoom);
    trtc.on('onExitRoom', onExitRoom);
    trtc.on('onRemoteUserEnterRoom', onRemoteUserEnterRoom);
    trtc.on('onFirstVideoFrame', onFirstVideoFrame);
    trtc.on('onUserVideoAvailable', onUserVideoAvailable);
    trtc.on('onRemoteUserLeaveRoom', onRemoteUserLeaveRoom);
  };

  const unsubscribeEvents = () => {
    trtc.off('onError', onError);
    trtc.off('onEnterRoom', onEnterRoom);
    trtc.off('onConnectOtherRoom', onConnectOtherRoom);
    trtc.off('onDisconnectOtherRoom', onDisconnectOtherRoom);
    trtc.off('onExitRoom', onExitRoom);
    trtc.off('onRemoteUserEnterRoom', onRemoteUserEnterRoom);
    trtc.off('onFirstVideoFrame', onFirstVideoFrame);
    trtc.off('onUserVideoAvailable', onUserVideoAvailable);
    trtc.off('onRemoteUserLeaveRoom', onRemoteUserLeaveRoom);
  };

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
      ipcRenderer.send('notification', LOG_PREFIX, window.a18n('必须为有效的连麦房间号'));
      return;
    }
    if (!isConnectedRoom) {
      connectRoomBtn.textContent = window.a18n('取消连麦');
      const connectParams = JSON.stringify({ roomId: connectRoomId, userId: connectUserId });
      trtc.connectOtherRoom(connectParams);
    } else {
      connectRoomBtn.textContent = window.a18n('连麦');
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

  subscribeEvents();
  enterRoom();
  bindDomEvent();
  renderConnectSection();

  ipcRenderer.on('stop-example', (event, arg) => {
    if (arg.type === 'connect-other-room') {
      exitRoom();
      unBindDomEvent();
      setTimeout(() => {
        unsubscribeEvents();
        trtc.destroy();
      }, 1000);
    }
  });
})();
