console.log(`[preload.js] node version: ${process.versions.node}`);
console.log(`[preload.js] chrome version: ${process.versions.chrome}`);
console.log(`[preload.js] electron version: ${process.versions.electron}`);
console.log(`[preload.js] process.cwd(): ${process.cwd()}`);
console.log(`[preload.js] __dirname: ${__dirname}`);

const { ipcRenderer } = require('electron');
const TRTCCloud = require('trtc-electron-sdk').default;
const genTestUserSig = require('./config/generateUserSig');
// const { USER_EVENT_NAME } = require('../constants');

window.electron = {
  // preloadUtil: {
  //   enterClassRoom(options) {
  //     window.console.warn('preload.js enterClassRoom:', options);
  //     ipcRenderer.send(USER_EVENT_NAME.ENTER_CLASS_ROOM, options);
  //   },
  //   exitClassRoom(options) {
  //     ipcRenderer.send(USER_EVENT_NAME.EXIT_CLASS_ROOM, options);
  //   },
  //   enterShareRoom(options) {
  //     window.console.warn('preload.js enterClassRoom:', options);
  //     ipcRenderer.send(USER_EVENT_NAME.ENTER_SHARE_ROOM, options);
  //   },
  //   exitShareRoom(options) {
  //     ipcRenderer.send(USER_EVENT_NAME.EXIT_SHARE_ROOM, options);
  //   },
  //   studentEnterClassRoom(options) {
  //     window.console.warn('preload.js studentEnterClassRoom:', options);
  //     ipcRenderer.send(USER_EVENT_NAME.STUDENT_ENTER_CLASS_ROOM, options);
  //   },
  //   studentExitClassRoom(options) {
  //     window.console.warn('preload.js studentExitClassRoom:', options);
  //     ipcRenderer.send(USER_EVENT_NAME.STUDENT_EXIT_CLASS_ROOM, options);
  //   },
  // },
  TRTCCloud,
  ipcRenderer,
  genTestUserSig,
};
