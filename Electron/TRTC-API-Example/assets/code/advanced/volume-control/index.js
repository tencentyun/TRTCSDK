(function () {
  const { ipcRenderer } = require('electron');
  const TRTCCloud = require('trtc-electron-sdk').default;
  const {
    TRTCAppScene,
    TRTCParams,
    AudioMusicParam,
    TRTCVideoStreamType,
  } = require('trtc-electron-sdk');

  // todo: Examples 设置区
  const userId = '' || window.globalUserId; // 用户名，必填
  const roomId = 0 || window.globalRoomId; // 会议号，数字类型（大于零），必填;
  // SDKAPPID, SECRETKEY 可在 assets/debug/gen-test-user-sig.js 里进行设置
  const info = window.genTestUserSig(userId);
  const sdkAppId = 0 || info.sdkappid; // 应用编号，必填
  const userSig = '' || info.userSig; // 用户签名，必填

  const LOG_PREFIX = '[Volume Control]';
  const trtc = new TRTCCloud();
  console.log(`${LOG_PREFIX} TRTC version:`, trtc.getSDKVersion());

  const audioMusicParam = new AudioMusicParam();
  audioMusicParam.id = 1;
  audioMusicParam.path = `${window.ROOT_PATH}/testbgm.mp3`;
  audioMusicParam.publish = true;
  audioMusicParam.loopCount = 100;

  let lastRemoteUserId = null;
  // 音量初始化参数
  const volumeParams = {
    audioCaptureVolume: 40,
    audioPlayoutVolume: 40,
    remoteAudioVolume: 40,
    currentMicDeviceVolume: 40,
    currentSpeakerVolume: 40,
    systemAudioLoopbackVolume: 40,
    musicPlayoutVolume: 40,
    musicPublishVolume: 40,
  };
  // 初始化音量设置表单
  let { volumeControlForm } = document.forms;
  volumeControlForm.audioCaptureVolume.value = volumeParams.audioCaptureVolume;
  volumeControlForm.audioPlayoutVolume.value = volumeParams.audioPlayoutVolume;
  volumeControlForm.remoteAudioVolume.value = volumeParams.remoteAudioVolume;
  volumeControlForm.currentMicDeviceVolume.value = volumeParams.currentMicDeviceVolume;
  volumeControlForm.currentSpeakerVolume.value = volumeParams.currentSpeakerVolume;
  volumeControlForm.systemAudioLoopbackVolume.value = volumeParams.systemAudioLoopbackVolume;
  volumeControlForm.musicPlayoutVolume.value = volumeParams.musicPlayoutVolume;
  volumeControlForm.musicPublishVolume.value = volumeParams.musicPublishVolume ;
  // 音量值修改事件的处理函数
  function updateVolume(e) {
    const { name } = e.target;
    const value = window.parseInt(e.target.value);

    volumeParams[name] = value;

    const funcName = `set${name.substring(0, 1).toUpperCase()}${name.substring(1)}`;
    if (['musicPlayoutVolume', 'musicPublishVolume'].indexOf(name) !== -1) {
      trtc[funcName](audioMusicParam.id, value);
    } else if ('remoteAudioVolume' === name) {
      trtc[funcName](lastRemoteUserId, value);
    } else {
      trtc[funcName](value);
    }
  }
  // 注册事件监听，音量设置变化时，调用接口更新相应音量
  volumeControlForm.querySelectorAll('input').forEach((input) => {
    input.addEventListener('change', updateVolume, false);
  });

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

  // 本地用户退出房间事件处理
  function onExitRoom(reason) {
    console.info(`${LOG_PREFIX} onExitRoom: reason: ${reason}`);
  }

  // Error事件处理
  function onError(errCode, errMsg) {
    console.info(`${LOG_PREFIX} onError: errCode: ${errCode}, errMsg: ${errMsg}`);
  }

  // 远程用户进入房间事件处理
  function onRemoteUserEnterRoom(userId) {
    console.info(`${LOG_PREFIX} onRemoteUserEnterRoom: userId: ${userId}`);
    // 这里可以收集所有远程人员，放入列表进行管理
    lastRemoteUserId = userId;
    trtc.setRemoteAudioVolume(userId, volumeParams.remoteAudioVolume); // 设置某个远程用户的播放音量
  }

  // 远程用户退出房间事件处理
  function onRemoteUserLeaveRoom(userId, reason) {
    console.info(`${LOG_PREFIX} onRemoteUserLeaveRoom: userId: ${userId}, reason: ${reason}`);
  }

  // 远程用户开启/关闭摄像头事件处理
  function onUserVideoAvailable(userId, available) {
    console.info(`${LOG_PREFIX} onUserVideoAvailable: userId: ${userId}, available: ${available}`);
    if (available) {
      // 远程用户开启摄像头
      // 此处，可以为视频渲染区域的HTML元素增加 loading 效果
      const remoteVideoWrapper = document.getElementById('remoteVideoWrapper');
      // 调用 startRemoteView() 接口加载远程画面
      trtc.startRemoteView(userId, remoteVideoWrapper, TRTCVideoStreamType.TRTCVideoStreamTypeBig);
    } else {
      // 远程用户关闭摄像头
    }
  }

  // 开始渲染本地或远程用户的首帧画面
  function onFirstVideoFrame(userId, streamType, width, height) {
    console.info(`${LOG_PREFIX} onFirstVideoFrame: userId: ${userId} streamType: ${streamType} width: ${width} height: ${height}`);
    if (userId) {
      // 远程用户
      // 此处，可以关闭视频渲染区域HTML元素的 loading 效果
    } else {
      // 本地用户
    }
  }

  // 订阅事件
  const subscribeEvents = () => {
    trtc.on('onError', onError);
    trtc.on('onEnterRoom', onEnterRoom);
    trtc.on('onExitRoom', onExitRoom);
    trtc.on('onRemoteUserEnterRoom', onRemoteUserEnterRoom);
    trtc.on('onRemoteUserLeaveRoom', onRemoteUserLeaveRoom);
    trtc.on('onUserVideoAvailable', onUserVideoAvailable);
    trtc.on('onFirstVideoFrame', onFirstVideoFrame);
  };

  // 取消事件订阅
  const unsubscribeEvents = () => {
    trtc.off('onError', onError);
    trtc.off('onEnterRoom', onEnterRoom);
    trtc.off('onExitRoom', onExitRoom);
    trtc.off('onRemoteUserEnterRoom', onRemoteUserEnterRoom);
    trtc.off('onRemoteUserLeaveRoom', onRemoteUserLeaveRoom);
    trtc.off('onUserVideoAvailable', onUserVideoAvailable);
    trtc.off('onFirstVideoFrame', onFirstVideoFrame);
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

    trtc.setAudioCaptureVolume(volumeParams.audioCaptureVolume); // 设置 SDK 采集音量
    trtc.setAudioPlayoutVolume(volumeParams.audioPlayoutVolume); // 设置 SDK 播放音量
    trtc.setCurrentMicDeviceVolume(volumeParams.currentMicDeviceVolume); // 设置系统当前麦克风设备的音量
    trtc.setCurrentSpeakerVolume(volumeParams.currentSpeakerVolume); // 设置系统当前扬声器设备音量

    trtc.startSystemAudioLoopback(); // 打开系统声音采集
    trtc.setSystemAudioLoopbackVolume(volumeParams.systemAudioLoopbackVolume);

    trtc.startPlayMusic(audioMusicParam); // 启动播放背景音乐
    trtc.setMusicPlayoutVolume(audioMusicParam.id, volumeParams.musicPlayoutVolume); // 设置背景音乐本地播放音量的大小
    trtc.setMusicPublishVolume(audioMusicParam.id, volumeParams.musicPublishVolume); // 设置背景音乐远端播放音量的大小
  }

  // 退出房间
  function exitRoom() {
    // 取消参数表单上的事件监听
    if (volumeControlForm && volumeControlForm.querySelectorAll) {
      volumeControlForm.querySelectorAll('input').forEach((input) => {
        input.removeEventListener('change', updateVolume, false);
      });
      volumeControlForm = null;
    }

    trtc.stopSystemAudioLoopback(); // 关闭系统声音采集
    trtc.stopPlayMusic(audioMusicParam.id); // 停止播放背景音乐

    trtc.stopLocalPreview();
    trtc.stopLocalAudio();
    trtc.exitRoom();
  }

  // ====== 注册事件监听，进入房间：start =================================
  subscribeEvents();
  enterRoom();
  // ====== 注册事件监听，进入房间：end ===================================

  // ====== 停止运行后，退出房间，清理事件订阅：start =======================
  // 这里借助 ipcRenderer 获取停止示例代码运行事件，
  // 实际项目中直接在“停止”按钮的点击事件中处理即可
  ipcRenderer.on('stop-example', (event, arg) => {
    if (arg.type === 'volume-control') {
      exitRoom();
      setTimeout(() => {
        unsubscribeEvents(trtc);
        trtc.destroy();
      }, 1000);
    }
  });
  // ====== 停止运行后，退出房间，清理事件订阅：end =========================
}());
