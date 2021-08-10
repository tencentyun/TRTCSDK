(async () => {
  const { ipcRenderer } = require('electron');
  const TRTCCloud = require('trtc-electron-sdk').default;
  const {
    TRTCParams,
    TRTCVideoEncParam,
    TRTCVideoResolution,
    TRTCVideoResolutionMode,
    TRTCAudioQuality,
    TRTCVideoStreamType,
    TRTCRoleType,
    TRTCAppScene,
  } = require('trtc-electron-sdk');

  const localUserId = '' || window.globalUserId;
  const roomId = 0 || window.globalRoomId;
  const info = await window.genTestUserSig(localUserId);
  const sdkAppId = 0 || info.sdkappid;
  const userSignature = '' || info.userSig;

  const LOG_PREFIX = '[Call Statistic]';
  const trtc = new TRTCCloud();
  console.log(`${LOG_PREFIX} TRTC version:`, trtc.getSDKVersion());

  const localVideoContainer = document.querySelector('.call-statistics #localVideoWrapper');
  const remoteVideoContainer = document.querySelector('.call-statistics #remoteVideoWrapper');
  const upLossNode = document.querySelector('.call-statistics .statistic-upLoss');
  const downLossNode = document.querySelector('.call-statistics .statistic-downLoss');
  const appCpuNode = document.querySelector('.call-statistics .statistic-app-cpu');
  const systemCpuNode = document.querySelector('.call-statistics .statistic-system-cpu');
  const rttNode = document.querySelector('.call-statistics .statistic-rtt');
  const receivedBytesNode = document.querySelector('.call-statistics .statistic-received-bytes');

  const localStatisticUserIdNode = document.querySelector('.call-statistics .local-statistic .statistic-userid');
  const localStatisticWidthNode = document.querySelector('.call-statistics .local-statistic .statistic-width');
  const localStatisticHeightNode = document.querySelector('.call-statistics .local-statistic .statistic-height');
  const localStatisticFrameRateNode = document.querySelector('.call-statistics .local-statistic .statistic-frameRate');
  const localStatisticVideoBitrateNode = document.querySelector('.call-statistics .local-statistic .statistic-videoBitrate');
  const localStatisticStreamTypeNode = document.querySelector('.call-statistics .local-statistic .statistic-streamType');

  const remoteStatisticUserIdNode = document.querySelector('.call-statistics .remote-statistic .statistic-userid');
  const remoteStatisticWidthNode = document.querySelector('.call-statistics .remote-statistic .statistic-width');
  const remoteStatisticHeightNode = document.querySelector('.call-statistics .remote-statistic .statistic-height');
  const remoteStatisticFrameRateNode = document.querySelector('.call-statistics .remote-statistic .statistic-frameRate');
  const remoteStatisticVideoBitrateNode = document.querySelector('.call-statistics .remote-statistic .statistic-videoBitrate');
  const remoteStatisticStreamTypeNode = document.querySelector('.call-statistics .remote-statistic .statistic-streamType');

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
    trtcParams.role = TRTCRoleType.TRTCRoleAnchor;

    trtc.enterRoom(trtcParams, TRTCAppScene.TRTCAppSceneVideoCall);
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
    if (remoteUserId === userId) {
      remoteUserId = '';
    }
    console.info(`${LOG_PREFIX} onRemoteUserLeaveRoom: userId: ${userId}, reason: ${reason}`);
  }

  function normalizeDataSize(originSize) {
    if (originSize > 1024 * 1024) {
      return `${(originSize / (1024 * 1024)).toFixed(2)}MB`;
    }
    if (originSize > 1024) {
      return `${(originSize / 1024).toFixed(2)}KB`;
    }
    return `${originSize}B`;
  }

  function onStatistics(statistic) {
    upLossNode.textContent = `${statistic.upLoss}%`;
    downLossNode.textContent = `${statistic.downLoss}%`;
    appCpuNode.textContent = `${statistic.appCpu}%`;
    systemCpuNode.textContent = `${statistic.systemCpu}%`;
    rttNode.textContent = `${statistic.rtt}ms`;
    receivedBytesNode.textContent = normalizeDataSize(statistic.receivedBytes);

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

  const subscribeEvents = () => {
    trtc.on('onError', onError);
    trtc.on('onEnterRoom', onEnterRoom);
    trtc.on('onExitRoom', onExitRoom);
    trtc.on('onStatistics', onStatistics);
    trtc.on('onRemoteUserEnterRoom', onRemoteUserEnterRoom);
    trtc.on('onFirstVideoFrame', onFirstVideoFrame);
    trtc.on('onUserVideoAvailable', onUserVideoAvailable);
    trtc.on('onRemoteUserLeaveRoom', onRemoteUserLeaveRoom);
  };

  const unsubscribeEvents = () => {
    trtc.off('onError', onError);
    trtc.off('onEnterRoom', onEnterRoom);
    trtc.off('onExitRoom', onExitRoom);
    trtc.off('onStatistics', onStatistics);
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

  function exitRoom() {
    trtc.stopLocalPreview();
    trtc.stopLocalAudio();
    trtc.exitRoom();
  }

  subscribeEvents();
  enterRoom();

  ipcRenderer.on('stop-example', (event, arg) => {
    if (arg.type === 'call-statistics') {
      exitRoom();
      setTimeout(() => {
        unsubscribeEvents();
        trtc.destroy();
      }, 1000);
    }
  });
})();
