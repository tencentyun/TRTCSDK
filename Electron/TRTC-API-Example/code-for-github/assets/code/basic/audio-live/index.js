/**
 * 直播场景下，不限制观众数量，为了避免太多事件回调引起的性能损耗，
 * 该场景下只有角色为主播的用户进入/退出房间、开/关摄像头、开/关麦克风
 * 时才会触发事件回调，角色为观众的用户不会触发相应事件回调。
 */
/**
 * Live streaming scenarios have no limit on audience size.
 * Given that frequent callbacks may compromise performance,
 * TRTC triggers callbacks only for anchor events including
 * room entry/exit, camera on/off, and mic on/off, not for
 * audience events.
 */
(async () => {
  const { ipcRenderer } = require('electron');
  const TRTCCloud = require('trtc-electron-sdk').default;
  const {
    TRTCAppScene,
    TRTCParams,
    TRTCRoleType,
  } = require('trtc-electron-sdk');

  const userId =  '' || window.globalUserId;
  const roomId = 0 || window.globalRoomId;
  const info = await window.genTestUserSig(userId);
  const sdkAppId =  0 || info.sdkappid;
  const userSignature = '' || info.userSig;

  const LOG_PREFIX = '[Audio Live]';
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

  const anchorSet = new Set();
  function onRemoteUserEnterRoom(userId) {
    console.info(`${LOG_PREFIX} onRemoteUserEnterRoom: userId: ${userId}`);
    anchorSet.add(userId);
  }

  function onRemoteUserLeaveRoom(userId, reason) {
    console.info(`${LOG_PREFIX} onRemoteUserLeaveRoom: userId: ${userId}, ${reason}`);
    anchorSet.delete(userId);
  }

  function onUserAudioAvailable(userId, available) {
    console.info(`${LOG_PREFIX} onUserAudioAvailable: userId: ${userId}, available: ${available}`);
    if (available) {
      // remote user open camera
      const remoteUserRoleHTML = document.getElementById('remoteUserRole');
      if (anchorSet.has(userId)) {
        remoteUserRoleHTML.innerText = ` - ${window.a18n('主播')}`;
      }
    } else {
      // remote user close camera
      const remoteUserRoleHTML = document.getElementById('remoteUserRole');
      remoteUserRoleHTML && (remoteUserRoleHTML.innerText = '');
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

    /**
     * 直播场景下角色类型设置，非必填，默认是主播类型 ，
     * 合法类型：
     *  - TRTCRoleType.TRTCRoleAnchor：默认值，主播
     *  - TRTCRoleType.TRTCRoleAudience：观众
     */
    /**
     * Role, which is required only in live streaming scenarios.
     * Valid values:
     *  -  TRTCRoleType.TRTCRoleAnchor (default): anchor;
     *  -  TRTCRoleType.TRTCRoleAudience: audience
     */
    trtcParams.role = parseInt(document.forms.roleSelectForm.roleType.value, 10);

    trtc.enterRoom(trtcParams, TRTCAppScene.TRTCAppSceneAudioCall);

    const localUserRoleHTML = document.getElementById('localUserRole');
    localUserRoleHTML.innerText = ` - ${trtcParams.role === TRTCRoleType.TRTCRoleAudience ? window.a18n('观众(音频不上传)') : window.a18n('主播')}`;
  }

  function exitRoom() {
    trtc.stopLocalAudio();
    trtc.exitRoom();
  }

  subscribeEvents();
  enterRoom();

  ipcRenderer.on('stop-example', (event, arg) => {
    if (arg.type === 'audio-live') {
      exitRoom();
      setTimeout(() => {
        unsubscribeEvents();
      }, 1000);
    }
  });
})();
