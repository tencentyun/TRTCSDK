import 'core-js/stable';
import 'regenerator-runtime/runtime';
import { app, BrowserWindow } from 'electron';
// import { autoUpdater } from 'electron-updater';
// import log from 'electron-log';
import { createMainWindow } from './windows/window-main';

// export default class AppUpdater {
//   constructor() {
//     log.transports.file.level = 'info';
//     autoUpdater.logger = log;
//     autoUpdater.checkForUpdatesAndNotify();
//   }
// }

let mainWindow: BrowserWindow | null = null;

async function initApp() {
  const newWindow = await createMainWindow();
  mainWindow = newWindow.getBrowserWindow();

  mainWindow?.on('closed', () => {
    mainWindow = null;
  });

  // Remove this if your app does not use auto updates
  // eslint-disable-next-line
  // new AppUpdater();
}

app.on('window-all-closed', () => {
  // Respect the OSX convention of having the application in memory even
  // after all windows have been closed
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.whenReady().then(initApp).catch(console.log);

app.on('activate', () => {
  // On macOS it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (mainWindow === null) initApp();
});

const trtcEduApp = {
  mainWindow,
};

export default trtcEduApp;
