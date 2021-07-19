const { ipcMain, BrowserWindow, Notification } = require('electron');

ipcMain.on('start-example', (event, arg) => {
  const win = BrowserWindow.getFocusedWindow();
  win.webContents.executeJavaScript(arg.code);
});

// To-do: 有没有更优雅、简洁的通信方式
ipcMain.on('stop-example', (event, arg) => {
  if (arg.type) {
    const win = BrowserWindow.getFocusedWindow();
    win.webContents.send('stop-example', arg);
  }
});

ipcMain.on('notification', (event, title, content) => {
  new Notification({ title, body: content }).show();
});
