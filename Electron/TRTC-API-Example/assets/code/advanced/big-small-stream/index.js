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
  } = require('trtc-electron-sdk');

  // ====== todo: Examples 设置区 start =================================
  const localUserId = '' || window.globalUserId; // 用户名，必填
  const roomId = 0 || window.globalRoomId; // 会议号，数字类型（大于零），必填;
  // SDKAPPID, SECRETKEY 可在 assets/debug/gen-test-user-sig.js 里进行设置
  const info = window.genTestUserSig(localUserId);
  const sdkAppId = 0 || info.sdkappid; // 应用编号，必填
  const userSig = '' || info.userSig; // 用户签名，必填
  // ====== todo: Examples 设置区 end =================================

  const LOG_PREFIX = 'Big small stream';
  const trtc = new TRTCCloud();
  console.log('TRTC version:', trtc.getSDKVersion());

  // 远端高清或者远端低清 (远端需同时开启大流和小流)
  const userPreferenceContainer = document.querySelector('.big-small-stream .remote-preference');
  const localVideoContainer = document.querySelector('.big-small-stream #localVideoWrapper');
  const remoteVideoContainer = document.querySelector('.big-small-stream #remoteVideoWrapper');

  const localStatisticUserIdNode = document.querySelector('.big-small-stream .local-statistic .statistic-userid');
  const localStatisticWidthNode = document.querySelector('.big-small-stream .local-statistic .statistic-width');
  const localStatisticHeightNode = document.querySelector('.big-small-stream .local-statistic .statistic-height');
  const localStatisticFrameRateNode = document.querySelector('.big-small-stream .local-statistic .statistic-frameRate');
  const localStatisticVideoBitrateNode = document.querySelector('.big-small-stream .local-statistic .statistic-videoBitrate');
  const localStatisticStreamTypeNode = document.querySelector('.big-small-stream .local-statistic .statistic-streamType');

  const remoteStatisticUserIdNode = document.querySelector('.big-small-stream .remote-statistic .statistic-userid');
  const remoteStatisticWidthNode = document.querySelector('.big-small-stream .remote-statistic .statistic-width');
  const remoteStatisticHeightNode = document.querySelector('.big-small-stream .remote-statistic .statistic-height');
  const remoteStatisticFrameRateNode = document.querySelector('.big-small-stream .remote-statistic .statistic-frameRate');
  const remoteStatisticVideoBitrateNode = document.querySelector('.big-small-stream .remote-statistic .statistic-videoBitrate');
  const remoteStatisticStreamTypeNode = document.querySelector('.big-small-stream .remote-statistic .statistic-streamType');

  let remoteStreamType = TRTCVideoStreamType.TRTCVideoStreamTypeBig;
  let remoteUserId = '';

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
    const bigStreamParams = new TRTCVideoEncParam(
      TRTCVideoResolution.TRTCVideoResolution_1280_720,
      TRTCVideoResolutionMode.TRTCVideoResolutionModeLandscape,
      15,
      1200,
      0,
      false,
    );
    const smallStreamParams = new TRTCVideoEncParam(
      TRTCVideoResolution.TRTCVideoResolution_480_360,
      TRTCVideoResolutionMode.TRTCVideoResolutionModeLandscape,
      15,
      400,
      0,
      false,
    );
    trtc.setVideoEncoderParam(bigStreamParams);
    trtc.enableSmallVideoStream(true, smallStreamParams);

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

  // 订阅事件
  const subscribeEvents = (rtcCloud) => {
    rtcCloud.on('onError', onError);
    rtcCloud.on('onEnterRoom', onEnterRoom);
    rtcCloud.on('onExitRoom', onExitRoom);
    rtcCloud.on('onRemoteUserEnterRoom', onRemoteUserEnterRoom);
    rtcCloud.on('onStatistics', onStatistics);
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
    rtcCloud.off('onStatistics', onStatistics);
    rtcCloud.off('onFirstVideoFrame', onFirstVideoFrame);
    rtcCloud.off('onUserVideoAvailable', onUserVideoAvailable);
    rtcCloud.off('onRemoteUserLeaveRoom', onRemoteUserLeaveRoom);
  };

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

    trtc.enterRoom(trtcParams, TRTCAppScene.TRTCAppSceneAudioCall);
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

  function onStatistics(statistic) {
    if (statistic.localStatisticsArray.length) {
      const localStatistic = statistic.localStatisticsArray[0];
      localStatisticUserIdNode.textContent = localUserId;
      localStatisticWidthNode.textContent = localStatistic.width;
      localStatisticHeightNode.textContent = localStatistic.height;
      localStatisticFrameRateNode.textContent = localStatistic.frameRate;
      localStatisticVideoBitrateNode.textContent = localStatistic.videoBitrate;
      localStatisticStreamTypeNode.textContent = localStatistic.streamType;
    }
    if (statistic.remoteStatisticsArray.length) {
      const remoteStatistic = statistic.remoteStatisticsArray.find(item => item.userId === remoteUserId);
      if (remoteStatistic) {
        remoteStatisticUserIdNode.textContent = remoteStatistic.userId;
        remoteStatisticWidthNode.textContent = remoteStatistic.width;
        remoteStatisticHeightNode.textContent = remoteStatistic.height;
        remoteStatisticFrameRateNode.textContent = remoteStatistic.frameRate;
        remoteStatisticVideoBitrateNode.textContent = remoteStatistic.videoBitrate;
        remoteStatisticStreamTypeNode.textContent = remoteStatistic.streamType;
      }
    }
  }

  function onUserVideoAvailable(userid, available) {
    console.log(`onUserVideoAvailable ${userid} ${available}`);
    if (available === 1) {
      trtc.startRemoteView(userid, remoteVideoContainer, remoteStreamType);
    } else {
      trtc.stopRemoteView(localUserId, remoteStreamType);
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

  // 退出房间
  function exitRoom() {
    trtc.stopLocalPreview();
    trtc.stopLocalAudio();
    trtc.exitRoom();
  }

  function renderRemoteStreamPreference() {
    const priHigNode = createDom(`
      <div class="preference-wrapper">
        <input type="radio" id="stream-preference-high" name="stream-preference" value="high" checked></input>
        <label for="stream-preference-high">远端高清</label>
      </div>
    `);
    const priLowNode = createDom(`
      <div class="preference-wrapper">
        <input type="radio" id="stream-preference-low" name="stream-preference" value="low"></input>
        <label for="stream-preference-low">远端低清</label>
      </div>
    `);
    userPreferenceContainer.appendChild(priHigNode);
    userPreferenceContainer.appendChild(priLowNode);
    bindEvents();
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

  function createDom(domStr) {
    const doc = new DOMParser().parseFromString(domStr, 'text/html');
    return doc.body.firstChild;
  }

  function handleRemoteStreamTypeChange(e) {
    if (e.target) {
      if (e.target.value === 'high') {
        remoteStreamType = TRTCVideoStreamType.TRTCVideoStreamTypeBig;
      }
      if (e.target.value === 'low') {
        remoteStreamType = TRTCVideoStreamType.TRTCVideoStreamTypeSmall;
      }
      if (remoteUserId) {
        // 远端用户存在， 才进行大小流切换
        trtc.startRemoteView(remoteUserId, remoteVideoContainer, remoteStreamType);
      }
    }
  }

  function bindEvents() {
    const radios = document.querySelectorAll('.big-small-stream input[type=radio][name="stream-preference"]');
    Array.prototype.forEach.call(radios, (radio) => {
      radio.addEventListener('change', handleRemoteStreamTypeChange);
    });
  }

  function unBindEvents() {
    const radios = document.querySelectorAll('.big-small-stream input[type=radio][name="stream-preference"]');
    Array.prototype.forEach.call(radios, (radio) => {
      radio.removeEventListener('change', handleRemoteStreamTypeChange);
    });
  }

  // ====== 注册事件监听，进入房间：start =================================
  subscribeEvents(trtc);
  enterRoom();
  renderRemoteStreamPreference();
  // ====== 注册事件监听，进入房间：end ===================================

  // ====== 停止运行后，退出房间，清理事件订阅：start =======================
  // 这里借助 ipcRenderer 获取停止示例代码运行事件，
  // 实际项目中直接在“停止”按钮的点击事件中处理即可
  ipcRenderer.on('stop-example', (event, arg) => {
    if (arg.type === 'big-small-stream') {
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
