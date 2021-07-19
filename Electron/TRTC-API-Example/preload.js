// All of the Node.js APIs are available in the preload process.
// It has the same sandbox as a Chrome extension.
console.log(`node version: ${process.versions.node}`);
console.log(`chrome version: ${process.versions.chrome}`);
console.log(`electron version: ${process.versions.electron}`);
console.log(`process.cwd(): ${process.cwd()}`);

const path = require('path');
window.ROOT_PATH = path.join(__dirname);

const genTestUserSig = require('./assets/debug/gen-test-user-sig');
const { ipcRenderer, shell } = require('electron');

// 接收主进程发送的应用路径
ipcRenderer.on('app-path', (event, appPath) => {
  window.appPath = appPath;
});

window.ipcRenderer = ipcRenderer;
window.shell = shell;
window.genTestUserSig = genTestUserSig;
window.globalUserId = window.localStorage.getItem('localUserId') || '';
window.globalRoomId = window.parseInt(window.localStorage.getItem('roomId') || 0);

// CDN旁路直播相关配置，参数获取，需要在 腾讯云控制台-》应用管理-》应用的 功能配置 区 启用旁路推流 设置
window.CDN_LIVE_APP_ID = 0;
window.CDN_LIVE_BIZ_ID = 0;
window.CDN_LIVE_URL_PREFIX = '';
