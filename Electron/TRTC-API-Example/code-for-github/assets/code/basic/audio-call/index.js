(async () => {
  const { ipcRenderer } = require('electron');
  const TRTCCloud = require('trtc-electron-sdk').default;
  const {
    TRTCAppScene,
    TRTCParams,
  } = require('trtc-electron-sdk');

  const userId =  '' || window.globalUserId;
  const roomId = 0 || window.globalRoomId;
  const info = await window.genTestUserSig(userId);
  const sdkAppId =  0 || info.sdkappid;
  const userSignature = '' || info.userSig;

  const LOG_PREFIX = '[Audio Call]';
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

  function onUserAudioAvailable(userId, available) {
    console.info(`${LOG_PREFIX} onUserAudioAvailable: userId: ${userId}, available: ${available}`);
    if (available) {
      // ...
    } else {
      // ...
    }
  }

  function onFirstAudioFrame(userId) {
    console.info(`${LOG_PREFIX} onFirstAudioFrame: userId: ${userId}`);
  }

  function onUserVoiceVolume(userVolumes, userVolumesCount, totalVolume) {
    console.info(`${LOG_PREFIX} onUserVoiceVolume: userVolumesCount: ${userVolumesCount} totalVolume: ${totalVolume} userVolumes:`, userVolumes);
    userVolumes.forEach((item) => {
      if (item.userId) {
        // 远端用户(remote user)
        const remoteAudioIcon = document.getElementById('remoteUserAudioIcon');
        remoteAudioIcon && (remoteAudioIcon.style.opacity = 0.2 + item.volume / 100);
      } else {
        // 本地用户(local user)
        const localAudioIcon = document.getElementById('localUserAudioIcon');
        localAudioIcon && (localAudioIcon.style.opacity = 0.2 + item.volume / 100);
      }
    });
  }

  const subscribeEvents = () => {
    trtc.on('onError', onError);
    trtc.on('onEnterRoom', onEnterRoom);
    trtc.on('onExitRoom', onExitRoom);
    trtc.on('onRemoteUserEnterRoom', onRemoteUserEnterRoom);
    trtc.on('onRemoteUserLeaveRoom', onRemoteUserLeaveRoom);
    trtc.on('onUserAudioAvailable', onUserAudioAvailable);
    trtc.on('onFirstAudioFrame', onFirstAudioFrame);
    trtc.on('onUserVoiceVolume', onUserVoiceVolume);
  };

  const unsubscribeEvents = () => {
    trtc.off('onError', onError);
    trtc.off('onEnterRoom', onEnterRoom);
    trtc.off('onExitRoom', onExitRoom);
    trtc.off('onRemoteUserEnterRoom', onRemoteUserEnterRoom);
    trtc.off('onRemoteUserLeaveRoom', onRemoteUserLeaveRoom);
    trtc.off('onUserAudioAvailable', onUserAudioAvailable);
    trtc.off('onFirstAudioFrame', onFirstAudioFrame);
    trtc.off('onUserVoiceVolume', onUserVoiceVolume);
  };

  function enterRoom() {
    // 启动音量大小提示，调用此接口只为获取音量大小，用于UI演示，实际业务如果不需要，可以不调用
    // Enable the volume reminder. You can call this API if you want to display volume information on the UI.
    trtc.enableAudioVolumeEvaluation(300);

    trtc.startLocalAudio();

    const trtcParams = new TRTCParams();
    trtcParams.userId =  userId;
    trtcParams.sdkAppId = sdkAppId;
    trtcParams.userSig = userSignature;
    trtcParams.roomId = roomId;

    trtc.enterRoom(trtcParams, TRTCAppScene.TRTCAppSceneAudioCall);
  }

  function exitRoom() {
    trtc.stopLocalAudio();
    trtc.exitRoom();
  }

  subscribeEvents();
  enterRoom();

  ipcRenderer.on('stop-example', (event, arg) => {
    if (arg.type === 'audio-call') {
      exitRoom();
      setTimeout(() => {
        unsubscribeEvents();
      }, 1000);
    }
  });
})();
