/**
 * 使用系统浏览器打开URL地址
 * @param {String} url
 */
export function openUrlInBrowser(url) {
  url && window.shell.openExternal(url); // shell在 preload.js 中定义
}
