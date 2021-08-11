const { ipcMain, BrowserWindow, Notification } = require('electron');

const WINDOW_NOT_READY_WARNING = ' 应用程序的窗口实例不存在或者尚未创建完成。  \n Application window does not exist or has not been created yet.';

ipcMain.on('start-example', (event, arg) => {
  const win = BrowserWindow.getFocusedWindow();
  if (win) {
    win.webContents.executeJavaScript(arg.code);
  } else {
    console.warn(WINDOW_NOT_READY_WARNING);
  }
});

ipcMain.on('stop-example', (event, arg) => {
  if (arg.type) {
    const win = BrowserWindow.getFocusedWindow();
    if (win) {
      win.webContents.send('stop-example', arg);
    } else {
      console.warn(WINDOW_NOT_READY_WARNING);
    }
  }
});

ipcMain.on('notification', (event, title, content) => {
  new Notification({ title, body: content }).show();
});

ipcMain.on('reload', () => {
  const win = BrowserWindow.getFocusedWindow();
  if (win) {
    win.reload(); // same as: win.webContents.reload();
  } else {
    console.warn(WINDOW_NOT_READY_WARNING);
  }
});
