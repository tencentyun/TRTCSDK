import compareVersion from './compare-version.js'

const env = wx ? wx : qq
if (!env) {
  console.error('不支持当前小程序环境')
}
const systemInfo = env.getSystemInfoSync()
console.log('SystemInfo', systemInfo)
let isNewVersion
if (typeof qq !== 'undefined') {
  isNewVersion = true
} else if (typeof wx !== 'undefined') {
  if (compareVersion(systemInfo.version, '7.0.8') >= 0 && compareVersion(systemInfo.SDKVersion, '2.10.0') >= 0) {
    isNewVersion = true
  } else {
    isNewVersion = false
  }
}

export const IS_TRTC = isNewVersion
export const IS_QQ = typeof qq !== 'undefined'
export const IS_WX = typeof wx !== 'undefined'
export const IS_IOS = /iOS/i.test(systemInfo.system)
export const IS_ANDROID = /Android/i.test(systemInfo.system)
export const APP_VERSION = systemInfo.version
export const LIB_VERSION = (function() {
  if (systemInfo.SDKBuild) {
    return systemInfo.SDKVersion + '-' + systemInfo.SDKBuild
  }
  return systemInfo.SDKVersion
})()

console.log('APP_VERSION:', APP_VERSION, ' LIB_VERSION:', LIB_VERSION, ' is new version:', IS_TRTC)
