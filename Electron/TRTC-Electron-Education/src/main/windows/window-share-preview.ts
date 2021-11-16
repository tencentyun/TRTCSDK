import { ipcMain, screen } from 'electron';
import { USER_EVENT_NAME } from '../../constants';
import BaseWindow from './window-base';
import { createWindow } from '../create-window';

class SharePreviewWindow extends BaseWindow {
  private static preLog = '[SharePreviewWindow]';

  constructor(options: Record<string, unknown>, url: string, initData: any) {
    super(options, url, initData);
    this.onChangeSharePreviewMode = this.onChangeSharePreviewMode.bind(this);
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

  onChangeSharePreviewMode(event: any, args: any) {
    console.log(
      `${SharePreviewWindow.preLog}.onChangeSharePreviewMode args:`,
      args
    );
    const mode = args.mode as string;

    if (mode === 'MIN') {
      this.browserWindow?.setSize(320 + 16, 32);
    } else {
      // MAX
      this.browserWindow?.setSize(320 + 16, 180 + 32 + 16);
    }
  }

  registerEvent() {
    ipcMain.on(
      USER_EVENT_NAME.ON_CHANGE_SHARE_PREVIEW_MODE,
      this.onChangeSharePreviewMode
    );
  }

  unregisterEvent() {
    ipcMain.removeListener(
      USER_EVENT_NAME.ON_CHANGE_SHARE_PREVIEW_MODE,
      this.onChangeSharePreviewMode
    );
  }

  destroy() {
    this.unregisterEvent();
    super.destroy();
  }
}

export default SharePreviewWindow;

export async function createSharePreviewWindow(initOptions: any) {
  const { width } = screen.getPrimaryDisplay().workAreaSize;
  const windowConfig = {
    width: 320 + 16,
    height: 180 + 32 + 16,
    x: width - 320 - 16,
    y: 180,
    resizable: false,
    frame: false,
    alwaysOnTop: true,
    transparent: true,
    hasShadow: false,
  };
  const pageUrl = 'index.html?view=share-preview';
  const newWindow = new SharePreviewWindow(windowConfig, pageUrl, initOptions);
  await newWindow.init();
  return newWindow;
}
