(() => {
  const { ipcRenderer } = require('electron');
  const TRTCCloud = require('trtc-electron-sdk').default;
  const {
    TRTCAppScene,
    TRTCParams,
    TRTCVideoStreamType,
    TRTCTranscodingConfig,
    TRTCTranscodingConfigMode,
  } = require('trtc-electron-sdk');

  // todo: Examples 设置区
  const userId = '' || window.globalUserId; // 用户名，必填
  const roomId = 0 || window.globalRoomId; // 会议号，数字类型（大于零），必填;
  // SDKAPPID, SECRETKEY 可在 assets/debug/gen-test-user-sig.js 里进行设置
  const info = window.genTestUserSig(userId);
  const sdkAppId = 0 || info.sdkappid; // 应用编号，必填
  const userSig = '' || info.userSig; // 用户签名，必填
  const streamId = `${sdkAppId}_${roomId}_${userId}_main`; // _${new Date().getTime()}

  // CDN旁路直播相关配置
  const cdnLiveAppID = 0 || window.CDN_LIVE_APP_ID;
  const cdnLiveBizID = 0 || window.CDN_LIVE_BIZ_ID;
  const cdnLiveUrlPrefix = '' || window.CDN_LIVE_URL_PREFIX;

  const LOG_PREFIX = '[Video Stream Mix]';
  const trtc = new TRTCCloud();
  console.log(`${LOG_PREFIX} TRTC version:`, trtc.getSDKVersion());
  console.log(`${LOG_PREFIX} stream ID: ${streamId}`);

  let mixedVideoPlayer = null; //

  // 开启屏幕分享
  function startScreenSharing() {
    const localScreenShareWrapper = document.getElementById('localScreenShareWrapper');
    if (localScreenShareWrapper) {
      const screenList = trtc.getScreenCaptureSources(320, 180, 30, 30);
      const selected = screenList[0]; // 为了演示方便，默认分享第一个屏幕
      trtc.selectScreenCaptureTarget(
        selected.type, selected.sourceId, selected.sourceName,
        { top: 0, left: 0, right: 0, bottom: 0 }, true, true,
      );
      trtc.startScreenCapture(localScreenShareWrapper, TRTCVideoStreamType.TRTCVideoStreamTypeSub);
    }
  }

  // 开启混流编码
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
        userId: '$PLACE_HOLDER_LOCAL_MAIN$', // 本地摄像头（主流）
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
        userId: '$PLACE_HOLDER_LOCAL_SUB$', // 本地屏幕分享（辅流）
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
        userId: '$PLACE_HOLDER_REMOTE$', // 远程视频流1
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
        userId: '$PLACE_HOLDER_REMOTE$', // 远程视频流2
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
        userId: '$PLACE_HOLDER_REMOTE$', // 远程视频流3
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
        userId: '$PLACE_HOLDER_REMOTE$', // 远程视频流4
        roomId: String(roomId),
        rect: {
          left: 480,
          top: 0,
          right: 640,
          bottom: 90,
        },
        zOrder: 15, // 15是允许的最大值
        pureAudio: false,
        streamType: TRTCVideoStreamType.TRTCVideoStreamTypeBig,
      },
    ];
    console.log('mix video stream config:', JSON.stringify(mixConfig));
    trtc.setMixTranscodingConfig(mixConfig);
  }

  // 播放混流视频
  function playMixedStream(url) {
    console.warn(`${LOG_PREFIX} mixed stream url: ${url}`);
    if (mixedVideoPlayer) {
      mixedVideoPlayer.destroy();
    }
    // eslint-disable-next-line no-undef
    mixedVideoPlayer = new TcPlayer('mixedVideoPlayer', {
      flv: url, // 实际可用的播放地址
      h5_flv: true,
      autoplay: true, // iOS 下 safari 浏览器，以及大部分移动端浏览器是不开放视频自动播放这个能力的
      width: '640', // 视频的显示宽度，请尽量使用视频分辨率宽度
      height: '360', // 视频的显示高度，请尽量使用视频分辨率高度
    });
  };

  function validParams(
    userId, roomId, sdkAppId, userSig,
    cdnLiveAppID, cdnLiveBizID, cdnLiveUrlPrefix
  ) {
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
    if (!cdnLiveAppID) {
      errors.push('cdnLiveAppID 未设置');
    }
    if (!cdnLiveBizID) {
      errors.push('cdnLiveBizID 未设置');
    }
    if (!cdnLiveUrlPrefix) {
      errors.push('cdnLiveUrlPrefix 未设置');
    }
    if (errors.length) {
      ipcRenderer.send('notification', LOG_PREFIX, errors.join(','));
      console.warn(LOG_PREFIX,  errors.join(','));
      return false;
    }
    return true;
  }
  if (!validParams(userId, roomId, sdkAppId, userSig)) {
    return;
  }

  // 本地用户进入房间事件处理
  function onEnterRoom(elapsed) {
    console.info(`${LOG_PREFIX} onEnterRoom: elapsed: ${elapsed}`);
    if (elapsed < 0) {
      // 小于零表示进房失败
      console.error(`${LOG_PREFIX} enterRoom failed`);
    } else {
      // 不小于零表示进房成功
      // 开启混流编码（前置条件：开启CDN旁路直播。默认会推送混流后的直播视频到CDN网络。)
      startMixVideoStream();

      // 开启本地屏幕分享
      startScreenSharing();

      // 播放推送到CDN的直播视频
      const url = `${cdnLiveUrlPrefix}${streamId}.flv`;
      setTimeout(() => {
        playMixedStream(url);
      }, 3000);
    }
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
  };

  // 取消事件订阅
  const unsubscribeEvents = (rtcCloud) => {
    rtcCloud.off('onError', onError);
    rtcCloud.off('onEnterRoom', onEnterRoom);
    rtcCloud.off('onExitRoom', onExitRoom);
  };

  // 进入房间
  function enterRoom() {
    // 启动本地摄像头采集和预览
    const localVideoWrapper = document.getElementById('localVideoWrapper');
    trtc.startLocalPreview(localVideoWrapper);

    // 启动本地音频采集和上行
    trtc.startLocalAudio();

    const trtcParams = new TRTCParams();
    // 试用、体验时，在以下地址根据 SDKAppID 和 userId 生成 userSig
    // https://console.cloud.tencent.com/trtc/usersigtool
    // 注意：正式生产环境中，userSig需要通过后台生成，前端通过HTTP请求获取
    trtcParams.userId = userId; // 用户名，必填
    trtcParams.sdkAppId = sdkAppId; // 应用编号，必填
    trtcParams.userSig = userSig; // 用户签名，必填
    trtcParams.roomId = roomId; // 会议号，数字类型（大于零），必填
    // trtcParams.streamId = streamId;
    trtc.enterRoom(trtcParams, TRTCAppScene.TRTCAppSceneLIVE);
  }

  // 退出房间
  function exitRoom() {
    if (mixedVideoPlayer) {
      mixedVideoPlayer.destroy();
      mixedVideoPlayer = null;
    }

    trtc.setMixTranscodingConfig(null); // 取消混流编码
    trtc.stopScreenCapture(); // 停止屏幕分享
    trtc.stopLocalPreview();
    trtc.stopLocalAudio();
    trtc.exitRoom();
  }

  // ====== 注册事件监听，进入房间：start =================================
  subscribeEvents(trtc);
  enterRoom();
  // ====== 注册事件监听，进入房间：end ===================================

  // ====== 停止运行后，退出房间，清理事件订阅：start =======================
  // 这里借助 ipcRenderer 获取停止示例代码运行事件，
  // 实际项目中直接在“停止”按钮的点击事件中处理即可
  ipcRenderer.on('stop-example', (event, arg) => {
    if (arg.type === 'video-stream-mix') {
      exitRoom();
      setTimeout(() => {
        unsubscribeEvents(trtc);
        trtc.destroy();
      }, 1000);
    }
  });
  // ====== 停止运行后，退出房间，清理事件订阅：end =========================
})();
