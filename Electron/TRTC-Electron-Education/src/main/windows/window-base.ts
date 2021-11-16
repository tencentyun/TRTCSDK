import { BrowserWindow } from 'electron';

class BaseWindow {
  protected windowOptions: Record<string, unknown> | null;

  protected contentUrl: string | null;

  protected initData: any | null;

  protected browserWindow: BrowserWindow | null;

  protected parentWindowId: number | null;

  constructor(
    windowOptions: Record<string, unknown>,
    url: string,
    initData?: any
  ) {
    this.windowOptions = { ...windowOptions };
    this.contentUrl = url;
    this.initData = initData;
    this.browserWindow = null;
    this.parentWindowId = null;

    this.destroy = this.destroy.bind(this);

    // this.init();
  }

  get id() {
    return this.browserWindow?.id;
  }

  // virtual init() {}

  // virtual registerEvent() {}

  // virtual unregisterEvent() {}

  destroy() {
    this.windowOptions = null;
    this.contentUrl = null;
    this.initData = null;
    this.browserWindow = null;
    this.parentWindowId = null;
  }
}

export default BaseWindow;
