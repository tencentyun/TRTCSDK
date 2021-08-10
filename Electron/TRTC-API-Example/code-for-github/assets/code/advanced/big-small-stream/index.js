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
  } = require('trtc-electron-sdk');

  const localUserId = '' || window.globalUserId;
  const roomId = 0 || window.globalRoomId;
  const info = await window.genTestUserSig(localUserId);
  const sdkAppId = 0 || info.sdkappid;
  const userSignature = '' || info.userSig;

  const LOG_PREFIX = '[Big Small Stream]';
  const trtc = new TRTCCloud();
  console.log(`${LOG_PREFIX} TRTC version:`, trtc.getSDKVersion());

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

    trtc.startLocalAudio(TRTCAudioQuality.TRTCAudioQualityDefault);
  }

  function onExitRoom(reason) {
    console.info(`${LOG_PREFIX} onExitRoom: reason: ${reason}`);
  }

  function onError(errCode, errMsg) {
    console.info(`${LOG_PREFIX} onError: errCode: ${errCode}, errMsg: ${errMsg}`);
  }

  const subscribeEvents = () => {
    trtc.on('onError', onError);
    trtc.on('onEnterRoom', onEnterRoom);
    trtc.on('onExitRoom', onExitRoom);
    trtc.on('onRemoteUserEnterRoom', onRemoteUserEnterRoom);
    trtc.on('onStatistics', onStatistics);
    trtc.on('onFirstVideoFrame', onFirstVideoFrame);
    trtc.on('onUserVideoAvailable', onUserVideoAvailable);
    trtc.on('onRemoteUserLeaveRoom', onRemoteUserLeaveRoom);
  };

  const unsubscribeEvents = () => {
    trtc.off('onError', onError);
    trtc.off('onEnterRoom', onEnterRoom);
    trtc.off('onExitRoom', onExitRoom);
    trtc.off('onRemoteUserEnterRoom', onRemoteUserEnterRoom);
    trtc.off('onStatistics', onStatistics);
    trtc.off('onFirstVideoFrame', onFirstVideoFrame);
    trtc.off('onUserVideoAvailable', onUserVideoAvailable);
    trtc.off('onRemoteUserLeaveRoom', onRemoteUserLeaveRoom);
  };

  function enterRoom() {
    const trtcParams = new TRTCParams();
    trtcParams.userId = localUserId;
    trtcParams.sdkAppId = sdkAppId;
    trtcParams.userSig = userSignature;
    trtcParams.roomId = roomId;

    trtc.enterRoom(trtcParams, TRTCAppScene.TRTCAppSceneAudioCall);
  }

  function onRemoteUserEnterRoom(userId) {
    console.info(`${LOG_PREFIX} onRemoteUserEnterRoom: userId: ${userId}`);
    remoteUserId = userId;
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

  function onRemoteUserLeaveRoom(userId, reason) {
    if (remoteUserId === userId) {
      remoteUserId = '';
    }
    console.info(`${LOG_PREFIX} onRemoteUserLeaveRoom: userId: ${userId}, reason: ${reason}`);
  }

  function exitRoom() {
    trtc.stopLocalPreview();
    trtc.stopLocalAudio();
    trtc.exitRoom();
  }

  function renderRemoteStreamPreference() {
    const priHigNode = createDom(`
      <div class="preference-wrapper">
        <input type="radio" id="stream-preference-high" name="stream-preference" value="high" checked></input>
        <label for="stream-preference-high">${window.a18n('远端高清')}</label>
      </div>
    `);
    const priLowNode = createDom(`
      <div class="preference-wrapper">
        <input type="radio" id="stream-preference-low" name="stream-preference" value="low"></input>
        <label for="stream-preference-low">${window.a18n('远端低清')}</label>
      </div>
    `);
    userPreferenceContainer.appendChild(priHigNode);
    userPreferenceContainer.appendChild(priLowNode);
    bindEvents();
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
        // 远端用户存在， 才能进行大小流切换
        // You can switch between the big and small images for playback only when there are remote users
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

  subscribeEvents();
  enterRoom();
  renderRemoteStreamPreference();

  ipcRenderer.on('stop-example', (event, arg) => {
    if (arg.type === 'big-small-stream') {
      exitRoom();
      unBindEvents();
      setTimeout(() => {
        unsubscribeEvents();
        trtc.destroy();
      }, 1000);
    }
  });
})();
