(async () => {
  const { ipcRenderer } = require('electron');
  const TRTCCloud = require('trtc-electron-sdk').default;
  const {
    TRTCAppScene,
    TRTCParams,
    TRTCVideoStreamType,
  } = require('trtc-electron-sdk');

  const userId =  '' || window.globalUserId;
  const roomId = 0 || window.globalRoomId;
  const info = await window.genTestUserSig(userId);
  const sdkAppId =  0 || info.sdkappid;
  const userSignature = '' || info.userSig;

  const LOG_PREFIX = '[Video Call]';
  const trtc = new TRTCCloud();
  console.log(`${LOG_PREFIX} TRTC version:`, trtc.getSDKVersion());

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
  if (!validParams(userId, roomId, sdkAppId, userSignature)) {
    return;
  }

  function onEnterRoom(elapsed) {
    console.info(`${LOG_PREFIX} onEnterRoom: elapsed: ${elapsed}`);
    if (elapsed < 0) {
      ipcRenderer.send('notification', LOG_PREFIX, `${window.a18n('进房失败')}, errorCode: ${elapsed}`);
      return;
    }
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

  function onRemoteUserLeaveRoom(userId, reason) {
    console.info(`${LOG_PREFIX} onRemoteUserLeaveRoom: userId: ${userId}, ${reason}`);
  }

  function onUserVideoAvailable(userId, available) {
    console.info(`${LOG_PREFIX} onUserVideoAvailable: userId: ${userId}, available: ${available}`);
    if (available) {
      const remoteVideoWrapper = document.getElementById('remoteVideoWrapper');
      trtc.startRemoteView(userId, remoteVideoWrapper, TRTCVideoStreamType.TRTCVideoStreamTypeBig);
    } else {
    }
  }

  function onFirstVideoFrame(userId, streamType, width, height) {
    console.info(`${LOG_PREFIX} onFirstVideoFrame: userId: ${userId} streamType: ${streamType} width: ${width} height: ${height}`);
    if (userId) {
      // 远程用户(remote user)
    } else {
      // 本地用户(local user)
    }
  }

  const subscribeEvents = () => {
    trtc.on('onError', onError);
    trtc.on('onEnterRoom', onEnterRoom);
    trtc.on('onExitRoom', onExitRoom);
    trtc.on('onRemoteUserEnterRoom', onRemoteUserEnterRoom);
    trtc.on('onRemoteUserLeaveRoom', onRemoteUserLeaveRoom);
    trtc.on('onUserVideoAvailable', onUserVideoAvailable);
    trtc.on('onFirstVideoFrame', onFirstVideoFrame);
  };

  const unsubscribeEvents = () => {
    trtc.off('onError', onError);
    trtc.off('onEnterRoom', onEnterRoom);
    trtc.off('onExitRoom', onExitRoom);
    trtc.off('onRemoteUserEnterRoom', onRemoteUserEnterRoom);
    trtc.off('onRemoteUserLeaveRoom', onRemoteUserLeaveRoom);
    trtc.off('onUserVideoAvailable', onUserVideoAvailable);
    trtc.off('onFirstVideoFrame', onFirstVideoFrame);
  };

  function enterRoom() {
    const localVideoWrapper = document.getElementById('localVideoWrapper');
    trtc.startLocalPreview(localVideoWrapper);

    trtc.startLocalAudio();

    const trtcParams = new TRTCParams();
    trtcParams.userId =  userId;
    trtcParams.sdkAppId = sdkAppId;
    trtcParams.userSig = userSignature;
    trtcParams.roomId = roomId;

    trtc.enterRoom(trtcParams, TRTCAppScene.TRTCAppSceneVideoCall);
  }

  function exitRoom() {
    trtc.stopLocalPreview();
    trtc.stopLocalAudio();
    trtc.exitRoom();
  }

  subscribeEvents();
  enterRoom();

  /**
   * 停止示例代码运行，退出房间，清理事件订阅
   *
   * 注意：此处通过 ipcRenderer 获取停止示例代码运行的事件，在事件回调中处理退房并清理事件订阅，
   * 实际项目中直接在“停止”按钮的点击事件回调中处理即可。
   */
  /**
   * Stop running the sample code, exit the room, and clear event subscriptions.
   *
   * Note: In the example, the event of stopping running the sample code is received
   * via ipcRenderer, and room exit and the clearing of event subscriptions are
   * performed in the callback. In actual applications, you can perform the operations
   * in the callback for the "Stop" button clicking event.
   */
  ipcRenderer.on('stop-example', (event, arg) => {
    if (arg.type === 'video-call') {
      exitRoom();
      setTimeout(() => {
        unsubscribeEvents();
        trtc.destroy();
      }, 1000);
    }
  });
})();
