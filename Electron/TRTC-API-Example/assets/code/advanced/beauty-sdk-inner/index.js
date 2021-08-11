(async () => {
  const { ipcRenderer } = require('electron');
  const TRTCCloud = require('trtc-electron-sdk').default;
  const {
    TRTCAppScene,
    TRTCParams,
    TRTCBeautyStyle,
  } = require('trtc-electron-sdk');

  const userId = '' || window.globalUserId;
  const roomId = 0 || window.globalRoomId;
  const info = await window.genTestUserSig(userId);
  const sdkAppId = 0 || info.sdkappid;
  const userSignature = '' || info.userSig;

  const LOG_PREFIX = '[Beauty Style(SDK Inner)]';
  const trtc = new TRTCCloud();
  console.log(`${LOG_PREFIX} TRTC version:`, trtc.getSDKVersion());

  let beautyParams = {
    style: TRTCBeautyStyle.TRTCBeautyStyleSmooth,
    beauty: 5,
    white: 5,
    ruddiness: 5,
  };

  let paramsForm = document.forms.beautyParamsForm;
  paramsForm.style.value = beautyParams.style;
  paramsForm.beauty.value = beautyParams.beauty;
  paramsForm.white.value = beautyParams.white;
  paramsForm.ruddiness.value = beautyParams.ruddiness;

  function setBeautyParams() {
    beautyParams = {
      style: window.parseInt(paramsForm.style.value),
      beauty: window.parseInt(paramsForm.beauty.value),
      white: window.parseInt(paramsForm.white.value),
      ruddiness: window.parseInt(paramsForm.ruddiness.value),
    };

    console.log(`${LOG_PREFIX} new beauty params:`, beautyParams);
    trtc.setBeautyStyle(
      beautyParams.style,
      beautyParams.beauty,
      beautyParams.white,
      beautyParams.ruddiness,
    );
  }

  paramsForm.querySelectorAll('input').forEach((input) => {
    input.addEventListener('change', setBeautyParams, false);
  });

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
  if (!validParams(userId, roomId, sdkAppId, userSignature)) {
    return;
  }

  function onEnterRoom(elapsed) {
    console.info(`${LOG_PREFIX} onEnterRoom: elapsed: ${elapsed}`);
    if (elapsed < 0) {
      ipcRenderer.send('notification', LOG_PREFIX, `${window.a18n('进房失败')}, errorCode: ${elapsed}`);
      return;
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
    // 试用、体验时，在以下地址根据 SDKAppID 和 userId 生成 userSig
    // https://console.cloud.tencent.com/trtc/usersigtool
    // 注意：生产环境中，userSig需要通过后台生成，前端通过HTTP请求获取
    trtcParams.userId = userId;
    trtcParams.sdkAppId = sdkAppId;
    trtcParams.userSig = userSignature;
    trtcParams.roomId = roomId;
    trtc.enterRoom(trtcParams, TRTCAppScene.TRTCAppSceneVideoCall);

    trtc.setBeautyStyle(
      beautyParams.style,
      beautyParams.beauty,
      beautyParams.white,
      beautyParams.ruddiness,
    );
  }

  function exitRoom() {
    if (paramsForm && paramsForm.querySelectorAll) {
      paramsForm.querySelectorAll('input').forEach((input) => {
        input.removeEventListener('change', setBeautyParams, false);
      });
      paramsForm = null;
    }

    trtc.stopLocalPreview();
    trtc.stopLocalAudio();
    trtc.exitRoom();
  }

  subscribeEvents();
  enterRoom();

  ipcRenderer.on('stop-example', (event, arg) => {
    if (arg.type === 'beauty-sdk-inner') {
      exitRoom();
      setTimeout(() => {
        unsubscribeEvents();
        trtc.destroy();
      }, 1000);
    }
  });
})();
