(async () => {
  const { ipcRenderer } = require('electron');
  const TRTCCloud = require('trtc-electron-sdk').default;
  const {
    TRTCAppScene,
    TRTCParams,
    TRTCVideoEncParam,
    TRTCVideoResolution,
    TRTCVideoResolutionMode,
    TRTCAudioQuality,
    TRTCVideoStreamType,
    TRTCRoleType,
  } = require('trtc-electron-sdk');

  const localUserId = '' || window.globalUserId;
  const roomId = 0 || window.globalRoomId;
  const info = await window.genTestUserSig(localUserId);
  const sdkAppId = 0 || info.sdkappid;
  const userSignature = '' || info.userSig;
  // 切换角色，仅适用于直播场景（TRTCAppSceneLIVE 和 TRTCAppSceneVoiceChatRoom）
  // Switch roles. This feature works only in live streaming scenarios (TRTCAppSceneLIVE and TRTCAppSceneVoiceChatRoom)
  const appScene = TRTCAppScene.TRTCAppSceneLIVE;

  const LOG_PREFIX = '[Switch Role]';
  const trtc = new TRTCCloud();
  console.log(`${LOG_PREFIX} TRTC version:`, trtc.getSDKVersion());

  const localVideoContainer = document.querySelector('.switch-role #localVideoWrapper');
  const remoteVideoContainer = document.querySelector('.switch-role #remoteVideoWrapper');
  const userRoleSectionContainer = document.querySelector('.switch-role .user-role-section');

  let remoteUserId = '';
  let userRole = TRTCRoleType.TRTCRoleAnchor;

  if (!validParams(localUserId, roomId, sdkAppId, userSignature)) {
    return;
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
      TRTCVideoResolution.TRTCVideoResolution_640_480,
      TRTCVideoResolutionMode.TRTCVideoResolutionModeLandscape,
      15,
      600,
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

  function enterRoom() {
    const trtcParams = new TRTCParams();
    trtcParams.userId = localUserId;
    trtcParams.sdkAppId = sdkAppId;
    trtcParams.userSig = userSignature;
    trtcParams.roomId = roomId;
    trtcParams.role = userRole;

    trtc.enterRoom(trtcParams, appScene);
  }

  function onRemoteUserEnterRoom(userId) {
    console.info(`${LOG_PREFIX} onRemoteUserEnterRoom: userId: ${userId}`);
    remoteUserId = userId;
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
    if (remoteUserId === userId) {
      remoteUserId = '';
    }
  }

  const subscribeEvents = () => {
    trtc.on('onError', onError);
    trtc.on('onEnterRoom', onEnterRoom);
    trtc.on('onExitRoom', onExitRoom);
    trtc.on('onRemoteUserEnterRoom', onRemoteUserEnterRoom);
    trtc.on('onFirstVideoFrame', onFirstVideoFrame);
    trtc.on('onUserVideoAvailable', onUserVideoAvailable);
    trtc.on('onRemoteUserLeaveRoom', onRemoteUserLeaveRoom);
  };

  const unsubscribeEvents = () => {
    trtc.off('onError', onError);
    trtc.off('onEnterRoom', onEnterRoom);
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

  function createDom(domStr) {
    const doc = new DOMParser().parseFromString(domStr, 'text/html');
    return doc.body.firstChild;
  }

  function exitRoom() {
    trtc.stopLocalPreview();
    trtc.stopLocalAudio();
    trtc.exitRoom();
  }

  function handleUserRoleChange(e) {
    if (e.target) {
      if (e.target.value === 'anchor') {
        userRole = TRTCRoleType.TRTCRoleAnchor;
      }
      if (e.target.value === 'audience') {
        userRole = TRTCRoleType.TRTCRoleAudience;
      }
      trtc.switchRole(userRole);
    }
  }

  function bindDomEvents() {
    const radios = document.querySelectorAll('.switch-role input[type=radio][name="user-role"]');
    Array.prototype.forEach.call(radios, (radio) => {
      radio.addEventListener('change', handleUserRoleChange);
    });
  }

  function unBindDomEvents() {
    const radios = document.querySelectorAll('.switch-role input[type=radio][name="user-role"]');
    Array.prototype.forEach.call(radios, (radio) => {
      radio.removeEventListener('change', handleUserRoleChange);
    });
  }

  function renderUserRole() {
    const anchorNode = createDom(`
      <div className="role-item">
        <input type="radio" id="user-role-anchor" name="user-role" value="anchor" checked></input>
        <label htmlFor="user-role-anchor">${window.a18n('主播')}</label>
      </div>
    `);
    const audienceNode = createDom(`
      <div className="role-item">
        <input type="radio" id="user-role-audience" name="user-role" value="audience"></input>
        <label htmlFor="user-role-audience">${window.a18n('观众')}</label>
      </div>
    `);
    userRoleSectionContainer.appendChild(anchorNode);
    userRoleSectionContainer.appendChild(audienceNode);
    bindDomEvents();
  }

  subscribeEvents();
  enterRoom();
  renderUserRole();

  ipcRenderer.on('stop-example', (event, arg) => {
    if (arg.type === 'switch-role') {
      exitRoom();
      unBindDomEvents();
      setTimeout(() => {
        unsubscribeEvents();
        trtc.destroy();
      }, 1000);
    }
  });
})();
