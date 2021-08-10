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

  // https://web.sdk.qcloud.com/trtc/electron/doc/zh-cn/trtc_electron_sdk/TRTCVideoEncParam.html
  const videoResolution = TRTCVideoResolution.TRTCVideoResolution_1280_720;
  const resMode = TRTCVideoResolutionMode.TRTCVideoResolutionModeLandscape;
  const videoFps = 15;
  const videoBitrate = 1200;
  const minVideoBitrate = 0;
  const enableAdjustRes = false;

  const LOG_PREFIX = '[Video Quality]';
  const trtc = new TRTCCloud();
  console.log(`${LOG_PREFIX} TRTC version:`, trtc.getSDKVersion());

  const localVideoContainer = document.querySelector('.video-quality #localVideoWrapper');
  const remoteVideoContainer = document.querySelector('.video-quality #remoteVideoWrapper');

  const localStatisticUserIdNode = document.querySelector('.video-quality .local-statistic .statistic-userid');
  const localStatisticWidthNode = document.querySelector('.video-quality .local-statistic .statistic-width');
  const localStatisticHeightNode = document.querySelector('.video-quality .local-statistic .statistic-height');
  const localStatisticFrameRateNode = document.querySelector('.video-quality .local-statistic .statistic-frameRate');
  const localStatisticVideoBitrateNode = document.querySelector('.video-quality .local-statistic .statistic-videoBitrate');
  const localStatisticStreamTypeNode = document.querySelector('.video-quality .local-statistic .statistic-streamType');

  const remoteStatisticUserIdNode = document.querySelector('.video-quality .remote-statistic .statistic-userid');
  const remoteStatisticWidthNode = document.querySelector('.video-quality .remote-statistic .statistic-width');
  const remoteStatisticHeightNode = document.querySelector('.video-quality .remote-statistic .statistic-height');
  const remoteStatisticFrameRateNode = document.querySelector('.video-quality .remote-statistic .statistic-frameRate');
  const remoteStatisticVideoBitrateNode = document.querySelector('.video-quality .remote-statistic .statistic-videoBitrate');
  const remoteStatisticStreamTypeNode = document.querySelector('.video-quality .remote-statistic .statistic-streamType');

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
      videoResolution,
      resMode,
      videoFps,
      videoBitrate,
      minVideoBitrate,
      enableAdjustRes,
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

    trtc.enterRoom(trtcParams, TRTCAppScene.TRTCAppSceneAudioCall);
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
    if (arg.type === 'video-quality') {
      exitRoom();
      setTimeout(() => {
        unsubscribeEvents();
        trtc.destroy();
      }, 1000);
    }
  });
})();
