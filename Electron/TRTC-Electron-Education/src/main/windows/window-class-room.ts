import { ipcMain, BrowserWindow, screen } from 'electron';
import { USER_EVENT_NAME } from '../../constants';
import BaseWindow from './window-base';
import { createWindow } from '../create-window';
import { createClassRoomTopWindow } from './window-class-room-top';
import store from '../store';

class ClassRoomWindow extends BaseWindow {
  private static preLog = '[ClassRoomWindow]';

  private classRoomTopWindowId: number | null;

  constructor(options: Record<string, unknown>, url: string, initData: any) {
    super(options, url, initData);
    this.classRoomTopWindowId = null;

    this.enterShareRoomListener = this.enterShareRoomListener.bind(this);
    this.exitShareRoomListener = this.exitShareRoomListener.bind(this);
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
  async enterShareRoomListener(event: any, args: any) {
    console.warn(`${ClassRoomWindow.preLog}.enterShareRoomListener() args:`, args);
    this.browserWindow?.hide();
    try{
      const { screenSource } = args;
      store.currentUser.sharingScreenInfo = {
        type: screenSource.type,
        sourceId: screenSource.sourceId,
        sourceName: screenSource.sourceName,
      };
      const classRoomTopWindow = await createClassRoomTopWindow(store);
      this.classRoomTopWindowId = classRoomTopWindow?.id || null;
    } catch (error) {
      alert('打开屏幕分享窗口失败'); // To-do: 错误、异常如何告警？最佳实践？
    }
  }

  exitShareRoomListener(event: any, args: any) {
    console.warn(`${ClassRoomWindow.preLog}.exitShareRoomListener() args:`, args);

    this.browserWindow?.show();
    this.browserWindow?.webContents.send(USER_EVENT_NAME.ON_WINDOW_SHOW, {
      store,
    });
    if (this.classRoomTopWindowId) {
      const classRoomTopWindow = BrowserWindow.fromId(this.classRoomTopWindowId);
      if (classRoomTopWindow) {
        classRoomTopWindow.close();
        this.classRoomTopWindowId = null;
      }
    }
  }
  /* eslint-disable */

  registerEvent() {
    ipcMain.on(USER_EVENT_NAME.ENTER_SHARE_ROOM, this.enterShareRoomListener);
    ipcMain.on(USER_EVENT_NAME.EXIT_SHARE_ROOM, this.exitShareRoomListener);
  }

  unregisterEvent() {
    ipcMain.removeListener(USER_EVENT_NAME.ENTER_SHARE_ROOM, this.enterShareRoomListener);
    ipcMain.removeListener(USER_EVENT_NAME.EXIT_SHARE_ROOM, this.exitShareRoomListener);
  }

  destroy() {
    this.unregisterEvent();
    super.destroy();
  }
}

export default ClassRoomWindow;

export async function createClassRoomWindow(initData: any) {
  const { width, height } = screen.getPrimaryDisplay().workAreaSize;
  const mainWindowConfig = {
    width,
    height,
    minWidth: 1200,
    minHeight: 640,
  };
  const mainWindowUrl = 'index.html?view=class-room';
  const newWindow = new ClassRoomWindow(mainWindowConfig, mainWindowUrl, {
    ...initData
  });
  await newWindow.init();
  return newWindow;
}

export async function createStudentClassRoomWindow(initData = {}) {
  const { width, height } = screen.getPrimaryDisplay().workAreaSize;
  const studentWindowConfig = {
    width,
    height,
    minWidth: 1200,
    minHeight: 640,
  };
  const studentHomeUrl = 'index.html?view=student';
  const win = new ClassRoomWindow(studentWindowConfig, studentHomeUrl, {
    ...initData
  });
  await win.init();
  return win;
}
