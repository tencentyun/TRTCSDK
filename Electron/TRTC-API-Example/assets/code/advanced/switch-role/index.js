(() => {
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

  // ====== todo: Examples 设置区 start =================================
  const localUserId = '' || window.globalUserId; // 用户名，必填
  const roomId = 0 || window.globalRoomId; // 会议号，数字类型（大于零），必填;
  // SDKAPPID, SECRETKEY 可在 assets/debug/gen-test-user-sig.js 里进行设置
  const info = window.genTestUserSig(localUserId);
  const sdkAppId = 0 || info.sdkappid; // 应用编号，必填
  const userSig = '' || info.userSig; // 用户签名，必填
  // 切换角色，仅适用于直播场景（TRTCAppSceneLIVE 和 TRTCAppSceneVoiceChatRoom）
  const appScene = TRTCAppScene.TRTCAppSceneLIVE;

  // ====== todo: Examples 设置区 end =================================

  const LOG_PREFIX = 'Switch role';
  const trtc = new TRTCCloud();
  console.log('TRTC version:', trtc.getSDKVersion());

  // 本地视频展示区
  const localVideoContainer = document.querySelector('.switch-role #localVideoWrapper');
  // 远端视频展示区
  const remoteVideoContainer = document.querySelector('.switch-role #remoteVideoWrapper');
  const userRoleSectionContainer = document.querySelector('.switch-role .user-role-section');

  let remoteUserId = '';
  let userRole = TRTCRoleType.TRTCRoleAnchor;

  if (!validParams(localUserId, roomId, sdkAppId, userSig)) {
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
    trtcParams.role = userRole;

    trtc.enterRoom(trtcParams, appScene);
  }

  // 远程用户进入房间事件处理
  function onRemoteUserEnterRoom(userId) {
    remoteUserId = userId;
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
    if (remoteUserId === userId) {
      // 有可能有多个 user, 这里只存最后一个进房 user 的 userid 作为 remoteUserId
      remoteUserId = '';
    }
    console.info(`${LOG_PREFIX} onRemoteUserLeaveRoom: userId: ${userId}, reason: ${reason}`);
  }

  // 订阅事件
  const subscribeEvents = (rtcCloud) => {
    rtcCloud.on('onError', onError);
    rtcCloud.on('onEnterRoom', onEnterRoom);
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

  function createDom(domStr) {
    const doc = new DOMParser().parseFromString(domStr, 'text/html');
    return doc.body.firstChild;
  }

  // 本地用户退出房间事件处理
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
        <label htmlFor="user-role-anchor">主播</label>
      </div>
    `);
    const audienceNode = createDom(`
      <div className="role-item">
        <input type="radio" id="user-role-audience" name="user-role" value="audience"></input>
        <label htmlFor="user-role-audience">观众</label>
      </div>
    `);
    userRoleSectionContainer.appendChild(anchorNode);
    userRoleSectionContainer.appendChild(audienceNode);
    bindDomEvents();
  }

  // ====== 注册事件监听，进入房间：start =================================
  subscribeEvents(trtc);
  enterRoom();
  renderUserRole();
  // ====== 注册事件监听，进入房间：end ===================================

  // ====== 停止运行后，退出房间，清理事件订阅：start =======================
  // 这里借助 ipcRenderer 获取停止示例代码运行事件，
  // 实际项目中直接在“停止”按钮的点击事件中处理即可
  ipcRenderer.on('stop-example', (event, arg) => {
    if (arg.type === 'switch-role') {
      exitRoom();
      unBindDomEvents();
      setTimeout(() => {
        unsubscribeEvents(trtc);
        trtc.destroy();
      }, 1000);
    }
  });
  // ====== 停止运行后，退出房间，清理事件订阅：end =========================
})();
