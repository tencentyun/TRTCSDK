/**
 * 设备检测demo
 */
/* global $ TRTC presetting getOS getBroswer cameraId micId */

// 用于记录检测结果，生成检测报告
let hasCameraDevice = false,
  hasMicAndVoiceDevice = false,
  hasCameraConnect,
  hasVoiceConnect,
  hasMicConnect,
  hasNetworkConnect;
let cameraTestingResult = {};
let voiceTestingResult = {};
let micTestingResult = {};
let networkTestingResult = {};

// 记录检测步骤，用于关闭时清空弹窗
let completedTestingPageIdList = [];
let curTestingPageId = '';
let localStream = null;
let client = null;
let timeout = null;
// 监听到network-quality事件的次数
let networkQualityNum = 0;

const deviceFailAttention =
  '1. 若浏览器弹出提示，请选择“允许”<br>' +
  '2. 若杀毒软件弹出提示，请选择“允许”<br>' +
  '3. 检查浏览器设置，允许网页访问摄像头及麦克风<br>' +
  '4. 检查摄像头/麦克风是否正确连接并开启<br>' +
  '5. 尝试重新连接摄像头/麦克风<br>' +
  '6. 尝试重启电脑后重新检测';
const networkFailAttention =
  '1. 请检查设备是否联网<br>' + '2. 请刷新网页后再次检测<br>' + '3. 请尝试更换网络后再次检测';

// 网络参数对照表
const NETWORK_QUALITY = {
  '0': '未知',
  '1': '极佳',
  '2': '较好',
  '3': '一般',
  '4': '差',
  '5': '极差',
  '6': '断开'
};

// 设备检测tab页签对应的执行方法
const pageCallbackConfig = {
  'camera-testing-body': 'startCameraTesting',
  'voice-testing-body': 'startVoiceTesting',
  'mic-testing-body': 'startMicTesting',
  'network-testing-body': 'startNetworkTesting'
};

// 判断是否为safari浏览器
let isSafari = /Safari/.test(navigator.userAgent) && !/Chrome/.test(navigator.userAgent);
hideVoiceForSafari();
/**
 * safari浏览器中隐藏扬声器相关检测
 */
function hideVoiceForSafari() {
  if (!isSafari) return;
  $('#connect-voice').hide();
  $('#device-voice').hide();
  $('#voice-testing').hide();
  $('#voice-report').hide();
  $('#device-mic').addClass('safari');
  $('#device-network').addClass('safari');
  $('#mic-testing').addClass('safari');
  $('#network-testing').addClass('safari');
}

// 是否是本地路径打开
let isFilePath = location.href.indexOf('file://') > -1;

/**
 * 设备检测初始化
 */
async function deviceTestingInit() {
  // 点击【设备检测】文字, 点击 【重新连接】按钮
  $('#device-testing-btn, #connect-again-btn').on('click', () => {
    startDeviceConnect();
  });
  // 连接设备错误icon
  $('#connect-attention-icon').on('mouseover', () => {
    $('#connect-attention-info').show();
  });
  // 连接设备错误icon
  $('#connect-attention-icon').on('mouseout', () => {
    $('#connect-attention-info').hide();
  });
  // 【开始检测】开始设备检测按钮
  $('#start-test-btn').on('click', function() {
    if ($(this).hasClass('start-gray')) return;
    $('#device-testing-prepare').hide();
    $('#device-testing').show();
    startCameraTesting();
  });
  // 摄像头检测失败/成功
  $('#camera-fail, #camera-success').on('click', function() {
    cameraTestingResult.statusResult = $(this).attr('id') === 'camera-success';
    $('#camera-testing-body').hide();
    localStream.close();
    // safari浏览器跳过扬声器检测
    isSafari ? startMicTesting() : startVoiceTesting();
  });
  // 播放器检测失败/成功
  $('#voice-fail, #voice-success').on('click', function() {
    voiceTestingResult.statusResult = $(this).attr('id') === 'voice-success';
    $('#voice-testing-body').hide();
    let audioPlayer = document.querySelector('#audio-player');
    if (!audioPlayer.paused) {
      audioPlayer.pause();
    }
    startMicTesting();
  });
  // 麦克风测试失败/成功
  $('#mic-fail, #mic-success').on('click', function() {
    micTestingResult.statusResult = $(this).attr('id') === 'mic-success';
    $('#mic-testing-body').hide();
    localStream.close();
    startNetworkTesting();
  });
  // 点击【查看检测报告】按钮
  $('#testing-report-btn').on('click', () => {
    showTestingReport();
    localStream.close();
    client && client.leave();
    client && client.off('network-quality');
  });
  // 点击【重新测试】按钮
  $('#testing-again').on('click', () => {
    $('#device-testing-report').hide();
    startDeviceConnect();
    completedTestingPageIdList = [];
  });
  // 点击【测试完成】按钮 / 点击关闭图标
  $('#testing-finish, #device-testing-close-btn').on('click', () => {
    finishDeviceTesting();
  });
  // 测试tab页切换
  $('#camera-testing, #voice-testing, #mic-testing, #network-testing').on('click', function() {
    let targetPageId = $(this).attr('id') + '-body';
    if (
      targetPageId !== curTestingPageId &&
      completedTestingPageIdList.indexOf(targetPageId) > -1
    ) {
      $(`#${curTestingPageId}`).hide();
      localStream && localStream.close();
      client && client.leave();
      client && client.off('network-quality');
      // 停止播放器的音乐
      let audioPlayer = document.querySelector('#audio-player');
      if (!audioPlayer.paused) {
        audioPlayer.pause();
      }
      // 展示要切换的设备检测tab页面
      $(`#${targetPageId}`).show();
      window[pageCallbackConfig[targetPageId]] && window[pageCallbackConfig[targetPageId]]();
    }
  });
  // 摄像头设备切换
  $('#camera-select').change(async function() {
    let newCameraId = $(this)
      .children('option:selected')
      .val();
    localStorage.setItem('txy_webRTC_cameraId', newCameraId);
    cameraTestingResult.device = {
      label: $(this)
        .children('option:selected')
        .text(),
      deviceId: $(this)
        .children('option:selected')
        .val(),
      kind: 'videoinput'
    };
    await localStream.switchDevice('video', newCameraId);
  });
  // 扬声器设备切换
  $('#voice-select').change(async function() {
    let newVoiceId = $(this)
      .children('option:selected')
      .val();
    localStorage.setItem('txy_webRTC_voiceId', newVoiceId);
    voiceTestingResult.device = {
      label: $(this)
        .children('option:selected')
        .text(),
      deviceId: $(this)
        .children('option:selected')
        .val(),
      kind: 'audiooutput'
    };

    let audioPlayer = document.querySelector('#audio-player');
    await audioPlayer.setSinkId(newVoiceId);
  });
  // 麦克风设备切换
  $('#mic-select').change(async function() {
    let newMicID = $(this)
      .children('option:selected')
      .val();
    localStorage.setItem('txy_webRTC_micId', newMicID);
    micTestingResult.device = {
      label: $(this)
        .children('option:selected')
        .text(),
      deviceId: $(this)
        .children('option:selected')
        .val(),
      kind: 'audioinput'
    };
    await localStream.switchDevice('audio', newMicID);
  });

  $('body').on('click', function() {
    $('#device-connect-list').hide();
  });

  // 获取设备信息
  await getDevicesInfo();
  // 初始化设备弹窗信息
  deviceDialogInit();
}

/**
 * 获取设备信息及网络连接信息
 */
async function getDevicesInfo() {
  let micList = await TRTC.getMicrophones();
  let voiceList = await TRTC.getSpeakers();
  let cameraList = await TRTC.getCameras();
  let index = isFilePath ? 'label' : 'deviceId';
  if (cameraList.length > 0) {
    hasCameraDevice = true;
  }
  if (micList.length > 0) {
    hasMicAndVoiceDevice = true;
  }
  cameraList.forEach(camera => {
    if (camera[index].length > 0) {
      hasCameraConnect = true;
    }
  });
  micList.forEach(mic => {
    if (mic[index].length > 0) {
      hasMicConnect = true;
    }
  });
  if (isSafari) {
    hasVoiceConnect = true;
  } else {
    voiceList.forEach(voice => {
      if (voice[index].length > 0) {
        hasVoiceConnect = true;
      }
    });
  }
  hasNetworkConnect = !!navigator.onLine;
}

/**
 * 判断是否展示弹窗
 */
function deviceDialogInit() {
  if (!localStorage.getItem('txy_device_testing')) {
    localStorage.setItem('txy_device_testing', Date.now());
    startDeviceConnect();
  } else {
    // 在首页展示设备连接结果
    let showDeviceStatus = function() {
      $('#device-connect-list').show();
      timeout = setTimeout(() => {
        $('#device-connect-list').hide();
      }, 3000);
      $('#connect-camera').css('color', `${hasCameraConnect ? 'green' : 'red'}`);
      $('#connect-voice').css('color', `${hasVoiceConnect ? 'green' : 'red'}`);
      $('#connect-mic').css('color', `${hasMicConnect ? 'green' : 'red'}`);
      $('#connect-network').css('color', `${hasNetworkConnect ? 'green' : 'red'}`);
      if (!(hasCameraConnect && hasVoiceConnect && hasMicConnect && hasNetworkConnect)) {
        $('#device-testing-btn').css('color', 'red');
      } else {
        $('#device-testing-btn').css('color', 'green');
      }
    };
    showDeviceStatus();

    if (!(hasCameraConnect && hasVoiceConnect && hasMicConnect)) {
      navigator.mediaDevices
        .getUserMedia({ video: hasCameraDevice, audio: hasMicAndVoiceDevice })
        .then(async () => {
          // 重新获取设备信息
          await getDevicesInfo();
          // 更新首页popover的option list
          getDevicesList();
          // 展示连接结果
          showDeviceStatus();
        })
        .catch(err => {});
    }
  }
}

/**
 * 弹窗-设备连接检查
 */
function startDeviceConnect() {
  // 显示设备检测弹窗
  $('#device-testing-root').show();
  // 设备检测弹窗-设备连接页
  $('#device-testing-prepare').show();

  curTestingPageId = 'device-testing-prepare';
  initTestingTabTitle();

  // 在设备检测弹窗显示设备连接信息
  let showDeviceConnectInfo = function() {
    if (!(hasCameraConnect && hasVoiceConnect && hasMicConnect && hasNetworkConnect)) {
      $('#device-testing-btn').css('color', 'red');
    } else {
      $('#device-testing-btn').css('color', 'green');
    }
    // 隐藏设备连接失败提示
    $('#connect-attention-container').hide();

    // 设备连接中
    $('#device-loading').show();
    $('#connect-info')
      .text('设备正在连接中，请稍等')
      .css('color', '#cccccc');
    $('#device-camera, #device-voice, #device-mic, #device-network').removeClass(
      'connect-success connect-fail'
    );
    $('#connect-again-btn').hide();
    $('#start-test-btn')
      .addClass('start-gray')
      .show();

    // 设备连接结束，展示连接结果
    setTimeout(() => {
      $('#device-loading').hide();
      $('#device-camera')
        .removeClass('connect-success connect-fail')
        .addClass(`${hasCameraConnect ? 'connect-success' : 'connect-fail'}`);
      $('#device-voice')
        .removeClass('connect-success connect-fail')
        .addClass(`${hasVoiceConnect ? 'connect-success' : 'connect-fail'}`);
      $('#device-mic')
        .removeClass('connect-success connect-fail')
        .addClass(`${hasMicConnect ? 'connect-success' : 'connect-fail'}`);
      $('#device-network')
        .removeClass('connect-success connect-fail')
        .addClass(`${hasNetworkConnect ? 'connect-success' : 'connect-fail'}`);

      if (!(hasCameraConnect && hasVoiceConnect && hasMicConnect)) {
        let connectInfo = hasNetworkConnect
          ? '设备连接失败，请允许网页访问摄像头及麦克风'
          : '设备及网络连接失败，请允许网页访问摄像头及麦克风并检查网络连接';
        $('#connect-info')
          .text(connectInfo)
          .css('color', 'red');
        // 显示设备连接失败引导
        $('#connect-attention-container').show();
        $('#connect-attention-info').html(deviceFailAttention);
        // 切换按钮状态
        $('#start-test-btn').hide();
        $('#connect-again-btn').show();
      }
      if (hasCameraConnect && hasVoiceConnect && hasMicConnect && !hasNetworkConnect) {
        $('#connect-info')
          .text('网络连接失败，请检查网络连接')
          .css('color', 'red');
        // 显示网络连接失败引导
        $('#connect-attention-container').show();
        $('#connect-attention-info').html(networkFailAttention);
        // 切换按钮状态
        $('#start-test-btn').hide();
        $('#connect-again-btn').show();
      }
      if (hasCameraConnect && hasVoiceConnect && hasMicConnect && hasNetworkConnect) {
        $('#connect-info')
          .text('设备及网络连接成功，请开始设备检测')
          .css('color', '#32CD32');
        $('#connect-again-btn').hide();
        $('#start-test-btn')
          .removeClass('start-gray')
          .show();
      }
    }, 2000);
  };
  showDeviceConnectInfo();

  // 如果有设备未连接，唤起请求弹窗
  if (!(hasCameraConnect && hasVoiceConnect && hasMicConnect)) {
    navigator.mediaDevices
      .getUserMedia({ video: hasCameraDevice, audio: hasMicAndVoiceDevice })
      .then(async () => {
        // 重新获取设备信息
        await getDevicesInfo();
        // 更新首页popover的option list
        getDevicesList();
        // 显示设备连接信息
        showDeviceConnectInfo();
      })
      .catch(err => {
        console.log('err', err.name);
      });
  }
}

/**
 * 更新首页popover的option list
 */
function getDevicesList() {
  // populate camera options
  TRTC.getCameras().then(devices => {
    $('#camera-option').empty();
    devices.forEach(device => {
      if (!cameraId) {
        // eslint-disable-next-line no-global-assign
        cameraId = device.deviceId;
      }
      let div = $('<div></div>');
      div.attr('id', device.deviceId);
      div.html(device.label);
      div.appendTo('#camera-option');
    });
  });

  // populate microphone options
  TRTC.getMicrophones().then(devices => {
    $('#mic-option').empty();
    devices.forEach(device => {
      if (!micId) {
        // eslint-disable-next-line no-global-assign
        micId = device.deviceId;
      }
      let div = $('<div></div>');
      div.attr('id', device.deviceId);
      div.html(device.label);
      div.appendTo('#mic-option');
    });
  });
}

/**
 * 摄像头检测页-检测展示摄像头设备选择列表
 */
async function updateCameraDeviceList() {
  let cameraDevices = await TRTC.getCameras();
  cameraDevices.filter(camera => camera.deviceId !== 'default');
  $('#camera-select').empty();
  cameraDevices.forEach(camera => {
    let option = $('<option></option>');
    option.attr('value', camera.deviceId);
    option.html(camera.label);
    option.appendTo('#camera-select');
  });

  // 如果有用户设备选择缓存，优先使用缓存的deviceId
  let cacheCameraDevice = cameraDevices.filter(
    camera => camera.deviceId === localStorage.getItem('txy_webRTC_cameraId')
  );
  if (cacheCameraDevice.length > 0) {
    $('#camera-select').val(localStorage.getItem('txy_webRTC_cameraId'));
    cameraTestingResult.device = cacheCameraDevice[0];
  } else {
    $('#camera-select').val(cameraDevices[0].deviceId);
    cameraTestingResult.device = cameraDevices[0];
  }
}

/**
 * 摄像头设备测试
 */
async function startCameraTesting() {
  $('#camera-testing-body').show();
  curTestingPageId = 'camera-testing-body';
  $('#camera-testing')
    .removeClass('icon-normal')
    .addClass('icon-blue complete');
  completedTestingPageIdList.push('camera-testing-body');
  completedTestingPageIdList = [...new Set(completedTestingPageIdList)];

  await updateCameraDeviceList();

  // 创建本地视频流
  await createLocalStream(
    {
      audio: false,
      video: true,
      cameraId: cameraTestingResult.device.deviceId
    },
    'camera-video'
  );
}

/**
 * 初始化/更新扬声器设备数组
 */
async function updateVoiceDeviceList() {
  // 获取扬声器设备并展示在界面中
  let voiceDevices = await TRTC.getSpeakers();
  voiceDevices = voiceDevices.filter(voice => voice.deviceId !== 'default');
  $('#voice-select').empty();
  voiceDevices.forEach(voice => {
    let option = $('<option></option>');
    option.attr('value', voice.deviceId);
    option.html(voice.label);
    option.appendTo('#voice-select');
  });

  // 如果有用户设备选择缓存，优先使用缓存的deviceId
  let cacheVoiceDevice = voiceDevices.filter(
    mic => mic.deviceId === localStorage.getItem('txy_webRTC_voiceId')
  );
  if (cacheVoiceDevice.length > 0) {
    $('#voice-select').val(localStorage.getItem('txy_webRTC_voiceId'));
    voiceTestingResult.device = cacheVoiceDevice[0];
  } else {
    $('#voice-select').val(voiceDevices[0].deviceId);
    voiceTestingResult.device = voiceDevices[0];
  }
}

/**
 * 播放器设备测试
 */
async function startVoiceTesting() {
  $('#voice-testing-body').show();
  curTestingPageId = 'voice-testing-body';
  $('#voice-testing')
    .removeClass('icon-gray')
    .addClass('icon-blue complete');
  completedTestingPageIdList.push('voice-testing-body');
  completedTestingPageIdList = [...new Set(completedTestingPageIdList)];

  await updateVoiceDeviceList();
}

/**
 * 更新/初始化麦克风设备
 */
async function updateMicDeviceList() {
  // 展示麦克风设备选择
  let micDevices = await TRTC.getMicrophones();
  micDevices = micDevices.filter(mic => mic.deviceId !== 'default');
  $('#mic-select').empty();
  micDevices.forEach(mic => {
    let option = $('<option></option>');
    option.attr('value', mic.deviceId);
    option.html(mic.label);
    option.appendTo('#mic-select');
  });

  // 如果有用户设备选择缓存，优先使用缓存的deviceId
  let cacheMicDevice = micDevices.filter(
    mic => mic.deviceId === localStorage.getItem('txy_webRTC_micId')
  );
  if (cacheMicDevice.length > 0) {
    $('#mic-select').val(localStorage.getItem('txy_webRTC_micId'));
    micTestingResult.device = cacheMicDevice[0];
  } else {
    $('#mic-select').val(micDevices[0].deviceId);
    micTestingResult.device = micDevices[0];
  }
}

/**
 * 麦克风设备测试
 */
async function startMicTesting() {
  $('#mic-testing-body').show();
  curTestingPageId = 'mic-testing-body';
  $('#mic-testing')
    .removeClass('icon-gray')
    .addClass('icon-blue complete');
  completedTestingPageIdList.push('mic-testing-body');
  completedTestingPageIdList = [...new Set(completedTestingPageIdList)];

  await updateMicDeviceList();

  // 展示麦克风的声音大小显示
  if ($('#mic-bar-container').children().length === 0) {
    for (let index = 0; index < 28; index++) {
      $('<div></div>')
        .addClass('mic-bar')
        .appendTo('#mic-bar-container');
    }
  }

  // 创建本地音频流
  await createLocalStream(
    {
      audio: true,
      microphoneId: micTestingResult.device.deviceId,
      video: false
    },
    'audio-container'
  );

  // 监听音量，并量化显示出来
  setInterval(() => {
    let volume = localStream.getAudioLevel();
    let num = Math.ceil(28 * volume);
    $('#mic-bar-container')
      .children('.active')
      .removeClass('active');
    for (let i = 0; i < num; i++) {
      $('#mic-bar-container')
        .children()
        .slice(0, i)
        .addClass('active');
    }
  }, 100);
}

/**
 * 系统信息展示
 */
async function startNetworkTesting() {
  $('#network-testing-body').show();
  $('#testing-report-btn').hide();
  curTestingPageId = 'network-testing-body';
  $('#network-testing')
    .removeClass('icon-gray')
    .addClass('icon-blue complete');
  completedTestingPageIdList.push('network-testing-body');
  completedTestingPageIdList = [...new Set(completedTestingPageIdList)];

  networkQualityNum = 0;
  $('#uplink-network')
    .addClass('network-loading')
    .text('');

  // 获取系统信息
  $('#system').empty();
  let OSInfo = getOS();
  $('<div></div>')
    .text(OSInfo.osName)
    .appendTo('#system');

  // 获取浏览器及版本信息
  $('#browser').empty();
  let browser = getBroswer();
  $('<div></div>')
    .text(`${browser.broswer} ${browser.version}`)
    .appendTo('#browser');

  // 获取ip地址信息
  // $('#ip').empty();
  // let IPAddress = await getIPAddress();
  // $('<div></div>').text(IPAddress).appendTo('#ip');
  // networkTestingResult.IPAddress = IPAddress;

  // 是否支持屏幕分享能力
  $('#screen-share').empty();
  let isScreenShareSupported = TRTC.isScreenShareSupported();
  $('<div></div>')
    .text(isScreenShareSupported ? '支持' : '不支持')
    .appendTo('#screen-share');

  // 上下行网络质量
  presetting.login(false, async options => {
    client = TRTC.createClient({ mode: 'rtc', ...options });
    client.on('network-quality', event => {
      networkQualityNum++;
      // 收到3次'network-quality'事件的时候认为拿到了网络实际质量
      if (networkQualityNum === 3) {
        networkTestingResult.upLinkNetwork = event.uplinkNetworkQuality;
        networkTestingResult.downLinkNetwork = event.downlinkNetworkQuality;
        $('#uplink-network')
          .removeClass('network-loading')
          .text(NETWORK_QUALITY[String(networkTestingResult.upLinkNetwork)]);
        $('#testing-report-btn').show();
        client && client.leave();
        client && client.off('network-quality');
      }
    });
    await client.join({
      roomId: options.roomId
    });
    await createLocalStream(
      {
        audio: true,
        video: false
      },
      'audio-container'
    );
    await client.publish(localStream);
    // 音频轨道静音
    localStream.muteAudio();
  });
}

/**
 * 展示检测报告
 */
function showTestingReport() {
  $('#device-testing').hide();
  $('#network-testing-body').hide();
  $('#device-testing-report').show();
  curTestingPageId = 'device-testing-report';

  // 摄像头检测结果
  $('#camera-name').text(cameraTestingResult.device.label);
  if (cameraTestingResult.statusResult) {
    $('#camera-testing-result')
      .text('正常')
      .css('color', 'green');
  } else {
    $('#camera-testing-result')
      .text('异常')
      .css('color', 'red');
  }

  // 扬声器检测结果(safari浏览器不显示扬声器检测结果)
  if (!isSafari) {
    $('#voice-name').text(voiceTestingResult.device.label);
    if (voiceTestingResult.statusResult) {
      $('#voice-testing-result')
        .text('正常')
        .css('color', 'green');
    } else {
      $('#voice-testing-result')
        .text('异常')
        .css('color', 'red');
    }
  }

  // 麦克风检测结果
  $('#mic-name').text(micTestingResult.device.label);
  if (micTestingResult.statusResult) {
    $('#mic-testing-result')
      .text('正常')
      .css('color', 'green');
  } else {
    $('#mic-testing-result')
      .text('异常')
      .css('color', 'red');
  }

  // 网络检测结果
  // $('#network-name').text(networkTestingResult.IPAddress);
  $('#network-name').text('网络质量');
  $('#network-testing-result')
    .html(`${NETWORK_QUALITY[String(networkTestingResult.upLinkNetwork)]}`)
    .css('color', `${Number(networkTestingResult.upLinkNetwork) > 3 ? 'red' : 'green'}`);
}

/**
 * 结束设备检测，隐藏设备检测弹窗
 */
function finishDeviceTesting() {
  $('#device-testing-root').hide();
  $('#device-testing').hide();
  $(`#${curTestingPageId}`).hide();
  curTestingPageId = '';
  completedTestingPageIdList = [];

  // 停止摄像头/麦克风的流采集并释放摄像头/麦克风设备
  localStream && localStream.close();
  client && client.leave();
  client && client.off('network-quality');
  // 停止播放器的音乐
  let audioPlayer = document.querySelector('#audio-player');
  if (!audioPlayer.paused) {
    audioPlayer.pause();
  }
  audioPlayer.currentTime = 0;
}

/**
 * 恢复检测页面头部图标的状态
 */
function initTestingTabTitle() {
  ['camera', 'voice', 'mic', 'network'].forEach(item => {
    $(`#${item}-testing`)
      .removeClass('icon-blue complete')
      .addClass('icon-gray');
  });
}

/**
 * 监听设备变化
 */
navigator.mediaDevices.ondevicechange = async function(event) {
  // 当前在摄像头检测页
  if (curTestingPageId === 'camera-testing-body') {
    await updateCameraDeviceList();
    return;
  }
  // 当前在扬声器检测页
  if (curTestingPageId === 'voice-testing-body') {
    await updateVoiceDeviceList();
    return;
  }
  // 当前在麦克风检测页
  if (curTestingPageId === 'mic-testing-body') {
    await updateMicDeviceList();
    return;
  }
};

/**
 * 抽离createStream的公共处理函数
 */
async function createLocalStream(constraints, container) {
  localStream = TRTC.createStream(constraints);
  try {
    await localStream.initialize();
  } catch (error) {
    switch (error.name) {
      case 'NotReadableError':
        // 当系统或浏览器异常的时候，可能会出现此错误，您可能需要引导用户重启电脑/浏览器来尝试恢复。
        alert('暂时无法访问摄像头/麦克风，请确保当前没有其他应用请求访问摄像头/麦克风，并重试');
        return;
      case 'NotAllowedError':
        // 用户拒绝授权访问摄像头或麦克风 | 屏幕分享，您需要引导客户来授权访问
        alert('用户已拒绝授权访问摄像头或麦克风');
        return;
      case 'NotFoundError':
        // 找不到摄像头或麦克风设备
        alert('找不到摄像头或麦克风设备');
        return;
      case 'OverConstrainedError':
        alert(
          '采集属性设置错误，如果您指定了 cameraId/microphoneId，请确保它们是一个有效的非空字符串'
        );
        return;
      default:
        alert('未知错误');
        return;
    }
  }
  container && localStream.play(container);
}
