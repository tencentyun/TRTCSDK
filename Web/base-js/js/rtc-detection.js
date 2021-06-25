/* global $ TRTC getOS getBrowser */
const DEVICE_TYPE_ENUM = {
  DESKTOP_WIN: 'desktop_win',
  DESKTOP_MAC: 'desktop_mac',
  MOBILE_ANDROID: 'mobile_android',
  MOBILE_IOS: 'mobile_ios'
};

const deviceType = getDeviceType();

/**
 * 获取当前设备类型
 */
function getDeviceType() {
  let deviceType;
  const osType = getOS().type;
  const osName = getOS().osName;
  switch (osType) {
    case 'desktop':
      deviceType =
        osName.indexOf('Mac OS') > -1 ? DEVICE_TYPE_ENUM.DESKTOP_MAC : DEVICE_TYPE_ENUM.DESKTOP_WIN;
      break;
    case 'mobile':
      deviceType = osName === 'iOS' ? DEVICE_TYPE_ENUM.MOBILE_IOS : DEVICE_TYPE_ENUM.MOBILE_ANDROID;
      break;
    default:
      break;
  }
  return deviceType;
}

/**
 * 根据设备类型获取支持的浏览器列表
 */
function getRecommendBrowserInfo() {
  let recommendBrowserInfo = '';
  switch (deviceType) {
    case DEVICE_TYPE_ENUM.DESKTOP_MAC:
      recommendBrowserInfo =
        ' Mac OS 设备请使用 Chrome，Safari，Firefox 56+ 或 Edge 80+ 浏览器打开链接';
      break;
    case DEVICE_TYPE_ENUM.DESKTOP_WIN:
      recommendBrowserInfo = ' Windows 设备请使用 Chrome, Firefox 56+ 或 Edge 80+ 浏览器打开链接';
      break;
    case DEVICE_TYPE_ENUM.MOBILE_ANDROID:
      recommendBrowserInfo = ' Android 设备请使用 Chrome 浏览器打开链接';
      break;
    case DEVICE_TYPE_ENUM.MOBILE_IOS:
      recommendBrowserInfo = ' iOS 设备请使用 Safari 浏览器打开链接';
      break;
    default:
      recommendBrowserInfo = '建议下载最新版Chrome浏览器（http://www.google.cn/chrome/）打开链接';
      break;
  }
  return recommendBrowserInfo;
}

/**
 * 是否是 桌面端 firefox 56+ 浏览器
 */
function isFirefoxM56() {
  if (deviceType === DEVICE_TYPE_ENUM.DESKTOP_WIN || deviceType === DEVICE_TYPE_ENUM.DESKTOP_MAC) {
    let browserInfo = getBrowser();
    if (browserInfo.browser === 'Firefox' && browserInfo.version >= '56') {
      return true;
    }
  }
  return false;
}

/**
 * rtc支持度检测
 */
async function rtcDetection() {
  // 当前浏览器不支持webRtc
  let checkResult = await TRTC.checkSystemRequirements();
  let deviceDetectionRemindInfo = '';
  let checkDetail = checkResult.detail;
  console.log('checkResult', checkResult.result, 'checkDetail', checkDetail);
  if (!checkResult.result) {
    // 通过TRTC获取详细不支持的信息
    $('#remind-info-container').show();

    // 查看链接是否符合webRtc限制
    if (
      location.protocol !== 'https:' &&
      location.hostname !== 'localhost' &&
      location.origin !== 'file://'
    ) {
      deviceDetectionRemindInfo =
        '请检查链接, webRTC 支持以下三种环境:<br>' +
        '1) localhost 域<br>' +
        '2) 开启了 HTTPS 的域<br>' +
        '3) 使用 file:/// 协议打开的本地文件';
      $('#browser-remind').show();
      $('#remind-info').html(deviceDetectionRemindInfo);
      return false;
    }

    // 获取当前设备推荐的浏览器信息
    deviceDetectionRemindInfo = getRecommendBrowserInfo();

    console.log('isFirefoxM56', isFirefoxM56());
    if (isFirefoxM56() && !checkDetail.isH264Supported) {
      deviceDetectionRemindInfo =
        'Firefox 尚未完成H264编码支持，请稍等重试或使用其他推荐浏览器打开链接<br>' +
        deviceDetectionRemindInfo;
    }

    $('#browser-remind').show();
    $('#remind-info').html(deviceDetectionRemindInfo);

    return false;
  }
  return true;
}
