(async () => {
  const { ipcRenderer } = require('electron');
  const TRTCCloud = require('trtc-electron-sdk').default;
  const {
    TRTCAppScene,
    TRTCParams,
    AudioMusicParam,
    TRTCVideoStreamType,
  } = require('trtc-electron-sdk');

  const userId = '' || window.globalUserId;
  const roomId = 0 || window.globalRoomId;
  const info = await window.genTestUserSig(userId);
  const sdkAppId = 0 || info.sdkappid;
  const userSignature = '' || info.userSig;

  const LOG_PREFIX = '[Volume Control]';
  const trtc = new TRTCCloud();
  console.log(`${LOG_PREFIX} TRTC version:`, trtc.getSDKVersion());

  const audioMusicParam = new AudioMusicParam();
  audioMusicParam.id = 1;
  audioMusicParam.path = `${window.ROOT_PATH}/testbgm.mp3`;
  audioMusicParam.publish = true;
  audioMusicParam.loopCount = 100;

  let lastRemoteUserId = null;
  const volumeParams = {
    audioCaptureVolume: 40,
    audioPlayoutVolume: 40,
    remoteAudioVolume: 40,
    currentMicDeviceVolume: 40,
    currentSpeakerVolume: 40,
    systemAudioLoopbackVolume: 40,
    musicPlayoutVolume: 40,
    musicPublishVolume: 40,
  };

  let { volumeControlForm } = document.forms;
  volumeControlForm.audioCaptureVolume.value = volumeParams.audioCaptureVolume;
  volumeControlForm.audioPlayoutVolume.value = volumeParams.audioPlayoutVolume;
  volumeControlForm.remoteAudioVolume.value = volumeParams.remoteAudioVolume;
  volumeControlForm.currentMicDeviceVolume.value = volumeParams.currentMicDeviceVolume;
  volumeControlForm.currentSpeakerVolume.value = volumeParams.currentSpeakerVolume;
  volumeControlForm.systemAudioLoopbackVolume.value = volumeParams.systemAudioLoopbackVolume;
  volumeControlForm.musicPlayoutVolume.value = volumeParams.musicPlayoutVolume;
  volumeControlForm.musicPublishVolume.value = volumeParams.musicPublishVolume ;

  function updateVolume(e) {
    const { name } = e.target;
    const value = window.parseInt(e.target.value);

    volumeParams[name] = value;

    const funcName = `set${name.substring(0, 1).toUpperCase()}${name.substring(1)}`;
    if (['musicPlayoutVolume', 'musicPublishVolume'].indexOf(name) !== -1) {
      trtc[funcName](audioMusicParam.id, value);
    } else if ('remoteAudioVolume' === name) {
      lastRemoteUserId && trtc[funcName](lastRemoteUserId, value);
    } else {
      trtc[funcName](value);
    }
  }
  volumeControlForm.querySelectorAll('input').forEach((input) => {
    input.addEventListener('change', updateVolume, false);
  });

  function onEnterRoom(elapsed) {
    console.info(`${LOG_PREFIX} onEnterRoom: elapsed: ${elapsed}`);
    if (elapsed < 0) {
      ipcRenderer.send('notification', LOG_PREFIX, `${window.a18n('进房失败')}, errorCode: ${elapsed}`);
      return;
    }
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
  if (!validParams(userId, roomId, sdkAppId, userSignature)) {
    return;
  }

  function onExitRoom(reason) {
    console.info(`${LOG_PREFIX} onExitRoom: reason: ${reason}`);
  }

  function onError(errCode, errMsg) {
    console.info(`${LOG_PREFIX} onError: errCode: ${errCode}, errMsg: ${errMsg}`);
  }

  function onRemoteUserEnterRoom(userId) {
    console.info(`${LOG_PREFIX} onRemoteUserEnterRoom: userId: 1${userId}1`);
    if (userId) {
      lastRemoteUserId = userId;
      trtc.setRemoteAudioVolume(userId, volumeParams.remoteAudioVolume);
    }
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
      // 远端用户(remote user)
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
    trtcParams.userId = userId;
    trtcParams.sdkAppId = sdkAppId;
    trtcParams.userSig = userSignature;
    trtcParams.roomId = roomId;
    trtc.enterRoom(trtcParams, TRTCAppScene.TRTCAppSceneVideoCall);

    trtc.setAudioCaptureVolume(volumeParams.audioCaptureVolume);
    trtc.setAudioPlayoutVolume(volumeParams.audioPlayoutVolume);
    trtc.setCurrentMicDeviceVolume(volumeParams.currentMicDeviceVolume);
    trtc.setCurrentSpeakerVolume(volumeParams.currentSpeakerVolume);

    trtc.startSystemAudioLoopback();
    trtc.setSystemAudioLoopbackVolume(volumeParams.systemAudioLoopbackVolume);

    trtc.startPlayMusic(audioMusicParam);
    trtc.setMusicPlayoutVolume(audioMusicParam.id, volumeParams.musicPlayoutVolume);
    trtc.setMusicPublishVolume(audioMusicParam.id, volumeParams.musicPublishVolume);
  }

  function exitRoom() {
    if (volumeControlForm && volumeControlForm.querySelectorAll) {
      volumeControlForm.querySelectorAll('input').forEach((input) => {
        input.removeEventListener('change', updateVolume, false);
      });
      volumeControlForm = null;
    }

    trtc.stopSystemAudioLoopback();
    trtc.stopPlayMusic(audioMusicParam.id);

    trtc.stopLocalPreview();
    trtc.stopLocalAudio();
    trtc.exitRoom();
  }

  subscribeEvents();
  enterRoom();

  ipcRenderer.on('stop-example', (event, arg) => {
    if (arg.type === 'volume-control') {
      exitRoom();
      setTimeout(() => {
        unsubscribeEvents();
        trtc.destroy();
      }, 1000);
    }
  });
})();
