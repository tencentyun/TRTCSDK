(async () => {
  const { ipcRenderer } = require('electron');
  const TRTCCloud = require('trtc-electron-sdk').default;
  const {
    TRTCQuality,
  } = require('trtc-electron-sdk');

  const userId =  '' || window.globalUserId;
  const info = await window.genTestUserSig(userId);
  const sdkAppId =  0 || info.sdkappid;
  const userSignature = '' || info.userSig;

  const LOG_PREFIX = '[Device Test]';
  const trtc = new TRTCCloud();
  console.log(`${LOG_PREFIX} TRTC version:`, trtc.getSDKVersion());

  function validParams(userId, sdkAppId, userSignature) {
    const errors = [];
    if (!userId) {
      errors.push('"userId" is not valid');
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
  if (!validParams(userId, sdkAppId, userSignature)) {
    return;
  }

  function onError(errCode, errMsg) {
    console.info(`${LOG_PREFIX} onError: errCode: ${errCode}, errMsg: ${errMsg}`);
  }

  let previousNetQuality = -1;
  function onSpeedTest(currentResult, finishedCount, totalCount) {
    console.log(`${LOG_PREFIX} currentResult:`, currentResult, `finishedCount: ${finishedCount} totalCount: ${totalCount}`);
    let netQuality = window.a18n('未知');
    if (previousNetQuality < currentResult.quality) {
      previousNetQuality = currentResult.quality;
    }
    switch (previousNetQuality) {
      case TRTCQuality.TRTCQuality_Excellent:
        netQuality = window.a18n('极佳');
        break;
      case TRTCQuality.TRTCQuality_Good:
        netQuality = window.a18n('很好');
        break;
      case TRTCQuality.TRTCQuality_Poor:
        netQuality = window.a18n('一般');
        break;
      case TRTCQuality.TRTCQuality_Bad:
        netQuality = window.a18n('差');
        break;
      case TRTCQuality.TRTCQuality_Vbad:
        netQuality = window.a18n('很差');
        break;
      case TRTCQuality.TRTCQuality_Down:
        netQuality = window.a18n('不可用');
        break;
    }
    const networkSpeedEl = document.getElementById('networkSpeed');
    networkSpeedEl && (networkSpeedEl.innerText = netQuality);
  }

  function onFirstVideoFrame(userId, streamType, width, height) {
    console.info(`${LOG_PREFIX} onFirstVideoFrame: userId: ${userId} streamType: ${streamType} width: ${width} height: ${height}`);
    if (userId) {
      // 远程用户(remote user)
    } else {
      // 本地用户(local user)
    }
  }

  function onTestMicVolume(volume) {
    console.info(`${LOG_PREFIX} onTestMicVolume: volume: ${volume}`);
    const microphoneVolumeEl = document.getElementById('microphoneVolume');
    if (microphoneVolumeEl) {
      microphoneVolumeEl.innerText = volume;
    }
  }

  function onTestSpeakerVolume(volume) {
    console.info(`${LOG_PREFIX} onTestSpeakerVolume: volume: ${volume}`);
    const speakerVolumeEl = document.getElementById('speakerVolume');
    if (speakerVolumeEl) {
      speakerVolumeEl.innerText = volume;
    }
  }

  const subscribeEvents = () => {
    trtc.on('onError', onError);
    trtc.on('onSpeedTest', onSpeedTest);
    trtc.on('onFirstVideoFrame', onFirstVideoFrame);
    trtc.on('onTestMicVolume', onTestMicVolume);
    trtc.on('onTestSpeakerVolume', onTestSpeakerVolume);
  };

  const unsubscribeEvents = () => {
    trtc.off('onError', onError);
    trtc.off('onSpeedTest', onSpeedTest);
    trtc.off('onSpeedTest', onSpeedTest);
    trtc.off('onFirstVideoFrame', onFirstVideoFrame);
    trtc.off('onTestMicVolume', onTestMicVolume);
    trtc.off('onTestSpeakerVolume', onTestSpeakerVolume);
  };

  function startDeviceTest() {
    trtc.startSpeedTest(sdkAppId, userId, userSignature);

    const localVideoWrapper = document.getElementById('localVideoWrapper');
    trtc.startCameraDeviceTest(localVideoWrapper);

    trtc.startMicDeviceTest(500);

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

  subscribeEvents();
  startDeviceTest();

  ipcRenderer.on('stop-example', (event, arg) => {
    if (arg.type === 'device-test') {
      stopDeviceTest();
      setTimeout(() => {
        unsubscribeEvents();
        trtc.destroy();
      }, 1000);
    }
  });
})();
