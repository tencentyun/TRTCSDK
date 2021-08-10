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

/**
 * Receive app path info from Main process. The app path will be used
 * by examples which need to load a static resource such as MP3 or MP4 media.
 */
ipcRenderer.on('app-path', (event, appPath) => {
  window.appPath = appPath;
});

window.ipcRenderer = ipcRenderer;
window.shell = shell;
window.genTestUserSig = genTestUserSig;
window.globalUserId = window.localStorage.getItem('localUserId') || '';
window.globalRoomId = window.parseInt(window.localStorage.getItem('roomId') || 0);

/**
 * Internationalization function
 * Here is a stub function. The real function is defined in initA18n.js,
 * which will be initialized when the UI page has loaded.
 * This function is used be online example code.
 */
window.a18n = keyString => keyString;
