(async () => {
  const { ipcRenderer } = require('electron');
  const TRTCCloud = require('trtc-electron-sdk').default;
  const {
    TRTCAppScene,
    TRTCParams,
    TRTCVideoStreamType,
    TRTCTranscodingConfig,
    TRTCTranscodingConfigMode,
  } = require('trtc-electron-sdk');

  const userId = '' || window.globalUserId;
  const roomId = 0 || window.globalRoomId;
  const info = await window.genTestUserSig(userId);
  const sdkAppId = 0 || info.sdkappid;
  const userSignature = '' || info.userSig;
  const streamId = `${sdkAppId}_${roomId}_${userId}_main`;

  // 请先在 gen-test-user-sig.js 文件中配置CDN直播相关参数
  // Please set CDN Live Streaming configuration in gen-test-user-sig.js
  const cdnLiveAppID = 0 || info.appId;
  const cdnLiveBizID = 0 || info.bizId;
  const cdnLiveUrlPrefix = '' || `https://${info.liveDomain}/live/`;

  const LOG_PREFIX = '[Video Stream Mix]';
  const trtc = new TRTCCloud();
  console.log(`${LOG_PREFIX} TRTC version:`, trtc.getSDKVersion());
  console.log(`${LOG_PREFIX} stream ID: ${streamId}`);

  let mixedVideoPlayer = null;

  function startScreenSharing() {
    const localScreenShareWrapper = document.getElementById('localScreenShareWrapper');
    if (localScreenShareWrapper) {
      const screenList = trtc.getScreenCaptureSources(320, 180, 30, 30);
      // 为了演示方便，默认分享第一个屏幕
      // For demonstration purposes, the first screen is shared by default
      const selected = screenList[0];
      trtc.selectScreenCaptureTarget(
        selected.type, selected.sourceId, selected.sourceName,
        { top: 0, left: 0, right: 0, bottom: 0 }, true, true,
      );
      trtc.startScreenCapture(localScreenShareWrapper, TRTCVideoStreamType.TRTCVideoStreamTypeSub);
    }
  }

  function startMixVideoStream() {
    const mixConfig = new TRTCTranscodingConfig();
    mixConfig.mode = TRTCTranscodingConfigMode.TRTCTranscodingConfigMode_Template_PresetLayout;
    mixConfig.appId = cdnLiveAppID;
    mixConfig.bizId = cdnLiveBizID;
    mixConfig.videoWidth = 640;
    mixConfig.videoHeight = 360;
    mixConfig.videoBitrate = 1000;
    mixConfig.videoFramerate = 24;
    mixConfig.videoGOP = 3;
    mixConfig.audioSampleRate = 48000;
    mixConfig.audioBitrate = 64;
    mixConfig.audioChannels = 2;
    mixConfig.backgroundColor = 0xff0000;
    mixConfig.backgroundImage = '';
    mixConfig.streamId = streamId;
    mixConfig.mixUsersArray = [
      {
        userId: '$PLACE_HOLDER_LOCAL_MAIN$',
        roomId: String(roomId),
        rect: {
          left: 10,
          top: 10,
          right: 190,
          bottom: 100,
        },
        zOrder: 2,
        pureAudio: false,
        streamType: TRTCVideoStreamType.TRTCVideoStreamTypeBig,
      },
      {
        userId: '$PLACE_HOLDER_LOCAL_SUB$',
        roomId: String(roomId),
        rect: {
          left: 0,
          top: 0,
          right: 640,
          bottom: 360,
        },
        zOrder: 1,
        pureAudio: false,
        streamType: TRTCVideoStreamType.TRTCVideoStreamTypeSub,
      },
      {
        userId: '$PLACE_HOLDER_REMOTE$',
        roomId: String(roomId),
        rect: {
          left: 480,
          top: 270,
          right: 640,
          bottom: 360,
        },
        zOrder: 3,
        pureAudio: false,
        streamType: TRTCVideoStreamType.TRTCVideoStreamTypeBig,
      },
      {
        userId: '$PLACE_HOLDER_REMOTE$',
        roomId: String(roomId),
        rect: {
          left: 480,
          top: 180,
          right: 640,
          bottom: 270,
        },
        zOrder: 4,
        pureAudio: false,
        streamType: TRTCVideoStreamType.TRTCVideoStreamTypeBig,
      },
      {
        userId: '$PLACE_HOLDER_REMOTE$',
        roomId: String(roomId),
        rect: {
          left: 480,
          top: 90,
          right: 640,
          bottom: 180,
        },
        zOrder: 5,
        pureAudio: false,
        streamType: TRTCVideoStreamType.TRTCVideoStreamTypeBig,
      },
      {
        userId: '$PLACE_HOLDER_REMOTE$',
        roomId: String(roomId),
        rect: {
          left: 480,
          top: 0,
          right: 640,
          bottom: 90,
        },
        zOrder: 15,
        pureAudio: false,
        streamType: TRTCVideoStreamType.TRTCVideoStreamTypeBig,
      },
    ];
    console.log('mix video stream config:', JSON.stringify(mixConfig));
    trtc.setMixTranscodingConfig(mixConfig);
  }

  function playMixedStream(url) {
    console.warn(`${LOG_PREFIX} mixed stream url: ${url}`);
    if (mixedVideoPlayer) {
      mixedVideoPlayer.destroy();
    }
    // eslint-disable-next-line no-undef
    mixedVideoPlayer = new TcPlayer('mixedVideoPlayer', {
      flv: url,
      h5_flv: true,
      autoplay: true,
      width: '640',
      height: '360',
    });
  };

  function validParams(
    userId, roomId, sdkAppId, userSig,
    cdnLiveAppID, cdnLiveBizID, cdnLiveUrlPrefix // eslint-disable-line
  ) {
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
    if (cdnLiveAppID === 0) {
      errors.push('"cdnLiveAppID" is not valid');
    }
    if (cdnLiveBizID === 0) {
      errors.push('"cdnLiveBizID" is not valid');
    }
    if (cdnLiveUrlPrefix === '') {
      errors.push('"cdnLiveUrlPrefix" is not valid');
    }
    if (errors.length) {
      ipcRenderer.send('notification', LOG_PREFIX, errors.join(','));
      console.warn(LOG_PREFIX,  errors.join(','));
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
      console.error(`${LOG_PREFIX} enterRoom failed`);
    } else {
      startMixVideoStream();

      startScreenSharing();

      const url = `${cdnLiveUrlPrefix}${streamId}.flv`;
      setTimeout(() => {
        playMixedStream(url);
      }, 3000);
    }
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
  };

  const unsubscribeEvents = () => {
    trtc.off('onError', onError);
    trtc.off('onEnterRoom', onEnterRoom);
    trtc.off('onExitRoom', onExitRoom);
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
    // trtcParams.streamId = streamId;
    trtc.enterRoom(trtcParams, TRTCAppScene.TRTCAppSceneLIVE);
  }

  function exitRoom() {
    if (mixedVideoPlayer) {
      mixedVideoPlayer.destroy();
      mixedVideoPlayer = null;
    }

    trtc.setMixTranscodingConfig(null);
    trtc.stopScreenCapture();
    trtc.stopLocalPreview();
    trtc.stopLocalAudio();
    trtc.exitRoom();
  }

  subscribeEvents();
  enterRoom();

  ipcRenderer.on('stop-example', (event, arg) => {
    if (arg.type === 'video-stream-mix') {
      exitRoom();
      setTimeout(() => {
        unsubscribeEvents();
        trtc.destroy();
      }, 1000);
    }
  });
})();
