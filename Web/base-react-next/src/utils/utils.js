
/**
 * 从 window.location.href 中获取指定key的value
 * @param {*} key 要获取的 key
 * @returns window.location.href 中指定key对应的value
 * @example
 * const value = getUrlParam(key);
 */
export function getUrlParam(key) {
  const url = window.location.href.replace(/^[^?]*\?/, '');
  const regexp = new RegExp(`(^|&)${key}=([^&#]*)(&|$|)`, 'i');
  const paramMatch = url.match(regexp);

  return paramMatch ? paramMatch[2] : null;
}

/**
 * 从 window.location.href 获取search参数
 * @param {*} key 要获取的 key
 * @returns window.location.href 中指定key对应的value
 * @example
 * const value = getUrlParam(key);
 */
export function getUrlParamObj() {
  const urlParamObj = {};
  if (location.search) {
    const paramUrl = location.search.slice(1);
    paramUrl.split('&').forEach((item) => {
      const [key, value] = item.split('=');
      urlParamObj[key] = value;
    });
  }
  return urlParamObj;
}

/**
 * 单词首字母大写
 * @param {String}} str
 */
export function upperFirstLetter(str) {
  return str.split(' ')
    .map(item => item.slice(0, 1).toUpperCase() + item.slice(1))
    .join(' ');
}

export function isUndefined(data) {
  return typeof data === 'undefined';
}

/**
 * 功能: 获取浏览器语言, 默认返回 'zh_CN'（中文）
 */
export function getLanguage() {
  let language = localStorage.getItem('language');
  const lang = navigator.language || navigator.userLanguage; // 常规浏览器语言和IE浏览器
  language = language || lang;
  language = language.replace(/-/, '_').toLowerCase();

  if (language === 'zh_cn' || language === 'zh') {
    language = 'zh_CN';
  } else if (language === 'zh_tw' || language === 'zh_hk') {
    language = 'zh_TW';
  } else {
    language = 'en_US';
  }

  return language || 'zh_CN';
};

/**
 * 功能: 获取 cookie 中特定 key 的值
 * @param {string} cname 就是 cookie 中对应的键
 *
 * ```javascript
 *     getCookie('language');  // 返回 cookie 中的设置的语言
 * ```
 */
export function getCookie(cname) {
  if (!cname) {
    return '';
  }
  const value = `; ${document.cookie}`;
  const parts = value.split('; ').find(str => str.includes(`${cname}=`)) || '';
  return parts.replace(`${cname}=`, '');
}

/**
 * 获取环境信息: 环境默认语言, 是否为移动端设备
 */
export function collectionCurrentInfo(req) {
  let currentEnvInfo = {};
  currentEnvInfo = {
    ...currentEnvInfo,
    isMobile: isMobile(req),
    // lang: getUrlParam('lang') || getCookie('lang') || getLanguage() || 'zh',
    lang: req && req.headers['accept-language'].split(';')[0].split(',')[0], // 'accept-language': 'en,zh-CN;q=0.9,zh;q=0.8',
  };
  return currentEnvInfo;
}
/**
 * 判断当前环境是否为移动端设备
 */
export function isMobile(req) {
  let userAgent;
  if (req) { // if you are on the server and you get a 'req' property from your context
    userAgent = req.headers['user-agent']; // get the user-agent from the headers
  } else {
    // if you are on the client you can access the navigator from the window object
    userAgent = typeof navigator !== 'undefined' && navigator && navigator.userAgent;
  }
  const isMobile = Boolean(userAgent.match(/Android|BlackBerry|iPhone|iPad|iPod|Opera Mini|IEMobile|WPDesktop/i));

  return isMobile;
}

/**
 * 将 dom 元素全屏
 * @param {dom} element dom元素
 * @example
 * setFullscreen(document.documentElement) // 整个页面进入全屏
 * setFullscreen(document.getElementById("id")) // 某个元素进入全屏
 */
export function setFullscreen(element) {
  if (element.requestFullscreen) {
    element.requestFullscreen();
  } else if (element.mozRequestFullScreen) {
    element.mozRequestFullScreen();
  } else if (element.msRequestFullscreen) {
    element.msRequestFullscreen();
  } else if (element.webkitRequestFullscreen) {
    element.webkitRequestFullScreen();
  }
};

/**
 * 退出全屏
 * @example
 * exitFullscreen();
 */
export function exitFullscreen() {
  if (document.exitFullscreen) {
    document.exitFullscreen();
  } else if (document.msExitFullscreen) {
    document.msExitFullscreen();
  } else if (document.mozCancelFullScreen) {
    document.mozCancelFullScreen();
  } else if (document.webkitExitFullscreen) {
    document.webkitExitFullscreen();
  }
};

/**
 * mimetype 支持检查
 */
export function getSupportedMimeTypes() {
  const possibleTypes = [
    'video/webm;codecs=vp9,opus',
    'video/webm;codecs=vp8,opus',
    'video/webm;codecs=h264,opus',
    'video/mp4;codecs=h264,aac',
  ];
  return possibleTypes.filter(mimeType => MediaRecorder.isTypeSupported(mimeType));
}

/**
 * 上报 TAM 数据
 */
export function uploadToTAM(eventString, sdkAppId) {
  window && window.aegis && window.aegis.reportEvent({
    name: eventString.split('#')[0] || '',
    ext1: eventString,
    ext2: 'webrtcSamplesSite', // webrtc samples-site 为 100
    ext3: sdkAppId,
  });
}
// https://doc.weixin.qq.com/sheet/e3_AJQAlgbNACk3JTdvUgfSKGQ6PYbJ5?scode=AJEAIQdfAAoO04FJEHAMEAfQZdACo
// 进房成功、失败上报到 TAM
export const joinRoomSuccessUpload = sdkAppId => uploadToTAM('joinRoom-success', sdkAppId);
export const joinRoomFailedUpload = (sdkAppId, errorMsg) => {
  console.warn(errorMsg);
  uploadToTAM(`joinRoom-failed#error: ${errorMsg}`, sdkAppId);
};
// 推流成功、失败上报到 TAM
export const publishSuccessUpload = sdkAppId => uploadToTAM('publish-success', sdkAppId);
export const publishFailedUpload = (sdkAppId, errorMsg) => {
  uploadToTAM(`publish-failed#error: ${errorMsg}`, sdkAppId);
};
// 初始化流成功、失败上报到 TAM
export const initLocalStreamSuccessUpload = sdkAppId => uploadToTAM('initLocalStream-success', sdkAppId);
export const initLocalStreamFailedUpload = (sdkAppId, errorMsg) => {
  uploadToTAM(`initLocalStream-failed#error: ${errorMsg}`, sdkAppId);
};
// 使用美颜操作上报到 TAM
export const beautyOperationUpload = (sdkAppId, type) => {
  uploadToTAM(`beautyOperation-success#type: ${type}`, sdkAppId);
};
// 流录制成功、失败上报到 TAM
export const recordStreamSuccessUpload = sdkAppId => uploadToTAM('recordStream-success', sdkAppId);
export const recordStreamFailedUpload = (sdkAppId, errorMsg) => {
  uploadToTAM(`recordStream-failed#error: ${errorMsg}`, sdkAppId);
};
// 开启水印上报到 TAM
export const openWaterMarkUpload = sdkAppId => uploadToTAM('openWaterMark-success', sdkAppId);
// 使用语音识别上报到 TAM
export const startAsrUpload = sdkAppId => uploadToTAM('startAsr-success', sdkAppId);
// 推流 CDN 成功、失败上报到 TAM
export const publishCdnSuccessUpload = sdkAppId => uploadToTAM('publishCdn-success', sdkAppId);
export const publishCdnFailedUpload = sdkAppId => uploadToTAM('publishCdn-failed', sdkAppId);
