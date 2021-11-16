import { ipcMain, BrowserWindow, screen } from 'electron';
import { USER_EVENT_NAME } from '../../constants';
import BaseWindow from './window-base';
import { createWindow } from '../create-window';
import { createShareScreenSelectWindow } from './window-share-screen-select';
import { createSharePreviewWindow } from './window-share-preview';
import store from '../store';

export class ClassRoomTopWindow extends BaseWindow {
  private static preLog = '[ClassRoomTopWindow]';

  private sharePreviewWindowId: number | null;

  constructor(options: Record<string, unknown>, url: string, initData: any) {
    super(options, url, initData);

    this.sharePreviewWindowId = null;

    this.changeShareScreenListener = this.changeShareScreenListener.bind(this);
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

    const sharePreviewWindow = await createSharePreviewWindow(this.initData);
    this.sharePreviewWindowId = sharePreviewWindow?.id || null;
  }

  /* eslint-disable */
  changeShareScreenListener(event: any, args: any) {
    console.log(`${ClassRoomTopWindow.preLog}.changeShareScreenListener args:`, args);
    createShareScreenSelectWindow({
      parentWindow: this
    })
  }
  /* eslint-disable */

  changeShareScreenOrWindow(screenSource: any) {
    store.currentUser.sharingScreenInfo = {
      type: screenSource.type,
      sourceId: screenSource.sourceId,
      sourceName: screenSource.sourceName,
    };
    //  通知预览小窗口
    if (this.sharePreviewWindowId) {
      const sharePreviewWindow = BrowserWindow.fromId(this.sharePreviewWindowId);
      if (sharePreviewWindow) {
        sharePreviewWindow.webContents.send(USER_EVENT_NAME.INIT_DATA, store);
      }
    }

    // 通知当前窗口
    this.browserWindow?.webContents.send(USER_EVENT_NAME.INIT_DATA, store);
  }

  registerEvent() {
    ipcMain.on(USER_EVENT_NAME.CHANGE_SHARE_SCREEN_WINDOW, this.changeShareScreenListener);
  }

  unregisterEvent() {
    ipcMain.removeListener(USER_EVENT_NAME.CHANGE_SHARE_SCREEN_WINDOW, this.changeShareScreenListener);
  }

  destroy() {
    if (this.sharePreviewWindowId) {
      const sharePreviewWindow = BrowserWindow.fromId(this.sharePreviewWindowId);
      if (sharePreviewWindow) {
        sharePreviewWindow.close();
        this.sharePreviewWindowId = null;
      }
    }

    this.unregisterEvent();
    super.destroy();
  }
}

export default ClassRoomTopWindow;

export async function createClassRoomTopWindow(initOptions: any) {
  const { width } = screen.getPrimaryDisplay().workAreaSize;
  const mainWindowConfig = {
    width: 1200,
    height: 146,
    x: (width - 1200) / 2,
    y: 0,
    resizable:false,
    frame: false,
    alwaysOnTop: true,
    transparent: true,
    hasShadow: false,
  };
  const mainWindowUrl = 'index.html?view=class-room-top';
  const newWindow = new ClassRoomTopWindow(mainWindowConfig, mainWindowUrl, initOptions);
  await newWindow.init();
  return newWindow;
}
