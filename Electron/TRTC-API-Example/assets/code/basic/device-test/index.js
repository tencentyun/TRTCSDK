(function () {
  const { ipcRenderer } = require('electron');
  const TRTCCloud = require('trtc-electron-sdk').default;
  const {
    TRTCQuality,
  } = require('trtc-electron-sdk');

  // todo: Examples 设置区
  const userId =  '' || window.globalUserId; // 用户名，必填
  // SDKAPPID, SECRETKEY 可在 assets/debug/gen-test-user-sig.js 里进行设置
  const info = window.genTestUserSig(userId);
  const sdkAppId =  0 || info.sdkappid; // 应用编号，必填
  const userSig = '' || info.userSig; // 用户签名，必填

  const LOG_PREFIX = '[Device Test]';
  const trtc = new TRTCCloud();
  console.log('TRTC version:', trtc.getSDKVersion());

  function validParams(userId, sdkAppId, userSig) {
    const errors = [];
    if (!userId) {
      errors.push('userId 未设置');
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
  if (!validParams(userId, sdkAppId, userSig)) {
    return;
  }

  // Error事件处理
  function onError(errCode, errMsg) {
    console.info(`${LOG_PREFIX} onError: errCode: ${errCode}, errMsg: ${errMsg}`);
  }

  // 处理网络测速回调事件
  let previousNetQuality = -1;
  function onSpeedTest(currentResult, finishedCount, totalCount) {
    console.log(`${LOG_PREFIX} currentResult:`, currentResult, `finishedCount: ${finishedCount} totalCount: ${totalCount}`);
    let netQuality = '未知';
    if (previousNetQuality < currentResult.quality) {
      previousNetQuality = currentResult.quality;
    }
    switch (previousNetQuality) {
      case TRTCQuality.TRTCQuality_Excellent:
        netQuality = '极佳';
        break;
      case TRTCQuality.TRTCQuality_Good:
        netQuality = '很好';
        break;
      case TRTCQuality.TRTCQuality_Poor:
        netQuality = '一般';
        break;
      case TRTCQuality.TRTCQuality_Bad:
        netQuality = '差';
        break;
      case TRTCQuality.TRTCQuality_Vbad:
        netQuality = '很差';
        break;
      case TRTCQuality.TRTCQuality_Down:
        netQuality = '不可用';
        break;
    }
    const networkSpeedEl = document.getElementById('networkSpeed');
    networkSpeedEl && (networkSpeedEl.innerText = netQuality);
  }

  // 处理摄像头检测回调事件
  function onFirstVideoFrame(userId, streamType, width, height) {
    console.info(`${LOG_PREFIX} onFirstVideoFrame: userId: ${userId} streamType: ${streamType} width: ${width} height: ${height}`);
    if (userId) {
      // 远程用户
    } else {
      // 本地用户，本示例只关注本地用户
    }
  }

  // 处理麦克分检测音量回调事件
  function onTestMicVolume(volume) {
    console.info(`${LOG_PREFIX} onTestMicVolume: volume: ${volume}`);
    const microphoneVolumeEl = document.getElementById('microphoneVolume');
    if (microphoneVolumeEl) {
      microphoneVolumeEl.innerText = volume;
    }
  }

  // 处理扬声器检测音量回调事件
  function onTestSpeakerVolume(volume) {
    console.info(`${LOG_PREFIX} onTestSpeakerVolume: volume: ${volume}`);
    const speakerVolumeEl = document.getElementById('speakerVolume');
    if (speakerVolumeEl) {
      speakerVolumeEl.innerText = volume;
    }
  }

  // 订阅事件
  const subscribeEvents = () => {
    trtc.on('onError', onError);
    trtc.on('onSpeedTest', onSpeedTest);
    trtc.on('onFirstVideoFrame', onFirstVideoFrame);
    trtc.on('onTestMicVolume', onTestMicVolume);
    trtc.on('onTestSpeakerVolume', onTestSpeakerVolume);
  };

  // 取消事件订阅
  const unsubscribeEvents = () => {
    trtc.off('onError', onError);
    trtc.off('onSpeedTest', onSpeedTest);
    trtc.off('onSpeedTest', onSpeedTest);
    trtc.off('onFirstVideoFrame', onFirstVideoFrame);
    trtc.off('onTestMicVolume', onTestMicVolume);
    trtc.off('onTestSpeakerVolume', onTestSpeakerVolume);
  };

  function startDeviceTest() {
    // 启动网络测试
    trtc.startSpeedTest(sdkAppId, userId, userSig);

    // 启动本地摄像检测
    const localVideoWrapper = document.getElementById('localVideoWrapper');
    trtc.startCameraDeviceTest(localVideoWrapper);

    // 启动麦克风检测
    trtc.startMicDeviceTest(500);

    // 启动扬声器检测
    const testFilePath = `${window.ROOT_PATH}/testspeak.mp3`;
    console.log(`Speaker test file path: ${testFilePath}`);
    trtc.startSpeakerDeviceTest(testFilePath);
  }

  function stopDeviceTest() {
    trtc.stopSpeedTest();
    trtc.stopCameraDeviceTest();
    trtc.stopMicDeviceTest();
    trtc.stopSpeakerDeviceTest();
  }
  // ====== 注册事件监听，进入房间：start =================================
  subscribeEvents();
  startDeviceTest();
  // ====== 注册事件监听，进入房间：end ===================================

  // ====== 停止运行后，退出房间，清理事件订阅：start =======================
  // 这里借助 ipcRenderer 获取停止示例代码运行事件，
  // 实际项目中直接在“停止”按钮的点击事件中处理即可
  ipcRenderer.on('stop-example', (event, arg) => {
    if (arg.type === 'device-test') {
      stopDeviceTest();
      setTimeout(() => {
        unsubscribeEvents();
        trtc.destroy();
      }, 1000);
    }
  });
  // ====== 停止运行后，退出房间，清理事件订阅：end =========================
}());
