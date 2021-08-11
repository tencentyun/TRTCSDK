(async () => {
  const { ipcRenderer } = require('electron');
  const TRTCCloud = require('trtc-electron-sdk').default;
  const {
    TRTCAppScene,
    TRTCParams,
    TRTCVideoStreamType,
    TRTCVideoRotation,
    TRTCVideoFillMode,
    TRTCVideoMirrorType,
  } = require('trtc-electron-sdk');

  const userId = '' || window.globalUserId;
  const roomId = 0 || window.globalRoomId;
  const info = await window.genTestUserSig(userId);
  const sdkAppId = 0 || info.sdkappid;
  const userSignature = '' || info.userSig;

  const LOG_PREFIX = '[Video Render Params]';
  const trtc = new TRTCCloud();
  console.log(`${LOG_PREFIX} TRTC version:`, trtc.getSDKVersion());

  let remoteUserId = null;
  let remoteStreamType = null;
  let renderParams = {
    mirrorType: TRTCVideoMirrorType.TRTCVideoMirrorType_Enable,
    rotation: TRTCVideoRotation.TRTCVideoRotation90,
    fillMode: TRTCVideoFillMode.TRTCVideoFillMode_Fit,
  };

  let paramsForm = document.forms.renderParamsForm;
  paramsForm.mirrorType.value = renderParams.mirrorType;
  paramsForm.rotation.value = renderParams.rotation;
  paramsForm.fillMode.value = renderParams.fillMode;

  function extractRenderParams() {
    renderParams = {
      mirrorType: window.parseInt(paramsForm.mirrorType.value),
      rotation: window.parseInt(paramsForm.rotation.value),
      fillMode: window.parseInt(paramsForm.fillMode.value),
    };

    trtc.setLocalRenderParams(renderParams);

    if (remoteUserId !== null  && remoteStreamType !== null) {
      trtc.setRemoteRenderParams(remoteUserId, remoteStreamType, renderParams);
    }
  }

  paramsForm.querySelectorAll('input').forEach((input) => {
    input.addEventListener('change', extractRenderParams, false);
  });

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
    console.info(`${LOG_PREFIX} onRemoteUserLeaveRoom: userId: ${userId}, reason: ${reason}`);
  }

  function onUserVideoAvailable(userId, available) {
    console.info(`${LOG_PREFIX} onUserVideoAvailable: userId: ${userId}, available: ${available}`);
    if (available) {
      const remoteVideoWrapper = document.getElementById('remoteVideoWrapper');
      trtc.startRemoteView(userId, remoteVideoWrapper, TRTCVideoStreamType.TRTCVideoStreamTypeBig);
    } else {
      // ...
    }
  }

  function onFirstVideoFrame(userId, streamType, width, height) {
    console.info(`${LOG_PREFIX} onFirstVideoFrame: userId: ${userId} streamType: ${streamType} width: ${width} height: ${height}`);
    if (userId) {
      remoteUserId = userId;
      remoteStreamType = streamType;
      trtc.setRemoteRenderParams(userId, streamType, renderParams);
    } else {
      trtc.setLocalRenderParams(renderParams);
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
    trtcParams.userId = userId;
    trtcParams.sdkAppId = sdkAppId;
    trtcParams.userSig = userSignature;
    trtcParams.roomId = roomId;
    trtc.enterRoom(trtcParams, TRTCAppScene.TRTCAppSceneVideoCall);
  }

  function exitRoom() {
    if (paramsForm && paramsForm.querySelectorAll) {
      paramsForm.querySelectorAll('input').forEach((input) => {
        input.removeEventListener('change', extractRenderParams, false);
      });
      paramsForm = null;
    }

    trtc.stopLocalPreview();
    trtc.stopLocalAudio();
    trtc.exitRoom();
  }

  subscribeEvents();
  enterRoom();

  ipcRenderer.on('stop-example', (event, arg) => {
    if (arg.type === 'render-control') {
      exitRoom();
      setTimeout(() => {
        unsubscribeEvents();
        trtc.destroy();
      }, 1000);
    }
  });
})();
