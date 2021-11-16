import { ipcMain } from 'electron';
import { USER_EVENT_NAME } from '../../constants';
import BaseWindow from './window-base';
import { createWindow } from '../create-window';
import store from '../store';

class ShareScreenSelectWindow extends BaseWindow {
  private static preLog = '[ShareScreenSelectWindow]';

  private parentWindow: any | null;

  constructor(options: Record<string, unknown>, url: string, initData: any) {
    super(options, url, initData);
    this.parentWindow = initData.parentWindow;
    this.initData = store;

    this.cancelShareScreenListener = this.cancelShareScreenListener.bind(this);
    this.confirmShareScreenListener =
      this.confirmShareScreenListener.bind(this);
    this.destroy = this.destroy.bind(this);

    // this.init();
  }

  async init() {
    this.browserWindow = await createWindow(
      this.windowOptions || {},
      this.contentUrl || '',
      this.initData
    );
    this.registerEvent();
    this.browserWindow?.on('closed', this.destroy);
  }

  /* eslint-disable */
  cancelShareScreenListener(event: any, args: any) {
    console.log(`${ShareScreenSelectWindow.preLog}.cancelShareScreenListener args:`, args);
    this.browserWindow?.close();
  }
  confirmShareScreenListener(event: any, args: any) {
    console.log(`${ShareScreenSelectWindow.preLog}.confirmShareScreenListener() args:`, args);
    const screenSource = args;
    this.parentWindow?.changeShareScreenOrWindow(screenSource);

    this.browserWindow?.close();
  }
  /* eslint-disable */

  registerEvent() {
    ipcMain.on(USER_EVENT_NAME.CANCEL_CHANGE_SHARE, this.cancelShareScreenListener);
    ipcMain.on(USER_EVENT_NAME.CONFIRM_CHANGE_SHARE, this.confirmShareScreenListener);
  }

  unregisterEvent() {
    ipcMain.removeListener(USER_EVENT_NAME.CANCEL_CHANGE_SHARE, this.cancelShareScreenListener);
    ipcMain.removeListener(USER_EVENT_NAME.CONFIRM_CHANGE_SHARE, this.confirmShareScreenListener);
  }

  destroy() {
    this.parentWindow = null;
    this.unregisterEvent();
    super.destroy();
  }
}

export default ShareScreenSelectWindow;

export async function createShareScreenSelectWindow(initOptions: any) {
  const mainWindowConfig = {
    width: 800,
    height: 600,
    frame: false,
    alwaysOnTop: true,
  };
  const mainWindowUrl = 'index.html?view=share-screen-select';
  const newWindow = new ShareScreenSelectWindow(mainWindowConfig, mainWindowUrl, initOptions);
  await newWindow.init();
  return newWindow;
}
