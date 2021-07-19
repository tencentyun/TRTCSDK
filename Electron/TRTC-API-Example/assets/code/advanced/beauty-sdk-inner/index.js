(function () {
  const { ipcRenderer } = require('electron');
  const TRTCCloud = require('trtc-electron-sdk').default;
  const {
    TRTCAppScene,
    TRTCParams,
    TRTCBeautyStyle,
  } = require('trtc-electron-sdk');

  // todo: Examples 设置区
  const userId = '' || window.globalUserId; // 用户名，必填
  const roomId = 0 || window.globalRoomId; // 会议号，数字类型（大于零），必填;
  // SDKAPPID, SECRETKEY 可在 assets/debug/gen-test-user-sig.js 里进行设置
  const info = window.genTestUserSig(userId);
  const sdkAppId = 0 || info.sdkappid; // 应用编号，必填
  const userSig = '' || info.userSig; // 用户签名，必填

  const LOG_PREFIX = '[Beauty Style(SDK Inner)]';
  const trtc = new TRTCCloud();
  console.log(`${LOG_PREFIX} TRTC version:`, trtc.getSDKVersion());

  // 初始化美颜参数
  let beautyParams = {
    style: TRTCBeautyStyle.TRTCBeautyStyleSmooth,
    beauty: 5, // 美颜级别，取值范围0 - 9，0表示关闭，1 - 9值越大，效果越明显
    white: 5, // 美白级别，取值范围0 - 9，0表示关闭，1 - 9值越大，效果越明显
    ruddiness: 5, // 红润级别，取值范围0 - 9，0表示关闭，1 - 9值越大，效果越明显，该参数 windows 平台暂未生效
  };
  // 初始化美颜参数设置表单
  let paramsForm = document.forms.beautyParamsForm;
  paramsForm.style.value = beautyParams.style;
  paramsForm.beauty.value = beautyParams.beauty;
  paramsForm.white.value = beautyParams.white;
  paramsForm.ruddiness.value = beautyParams.ruddiness;

  // 获取表单数据，并设置美颜参数
  function extractBeautyParams() {
    beautyParams = {
      style: window.parseInt(paramsForm.style.value),
      beauty: window.parseInt(paramsForm.beauty.value),
      white: window.parseInt(paramsForm.white.value),
      ruddiness: window.parseInt(paramsForm.ruddiness.value),
    };

    console.log('beautyParams:', beautyParams);

    // 修改SDK内置美颜功能参数
    trtc.setBeautyStyle(
      beautyParams.style,
      beautyParams.beauty,
      beautyParams.white,
      beautyParams.ruddiness,
    );
  }

  // 注册事件监听，参数设置变化时，更新视频渲染参数
  paramsForm.querySelectorAll('input').forEach((input) => {
    input.addEventListener('change', extractBeautyParams, false);
  });

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
    trtc.enterRoom(trtcParams, TRTCAppScene.TRTCAppSceneVideoCall);

    // 启动SDK内置美颜功能
    trtc.setBeautyStyle(
      beautyParams.style,
      beautyParams.beauty,
      beautyParams.white,
      beautyParams.ruddiness,
    );
  }

  // 退出房间
  function exitRoom() {
    // 取消参数表单上的事件监听
    if (paramsForm && paramsForm.querySelectorAll) {
      paramsForm.querySelectorAll('input').forEach((input) => {
        input.removeEventListener('change', extractBeautyParams, false);
      });
      paramsForm = null;
    }

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
    if (arg.type === 'beauty-sdk-inner') {
      exitRoom();
      setTimeout(() => {
        unsubscribeEvents(trtc);
        trtc.destroy();
      }, 1000);
    }
  });
  // ====== 停止运行后，退出房间，清理事件订阅：end =========================
}());
