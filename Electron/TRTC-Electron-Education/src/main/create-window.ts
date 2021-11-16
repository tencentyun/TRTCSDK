import 'core-js/stable';
import 'regenerator-runtime/runtime';
import path from 'path';
import { app, BrowserWindow } from 'electron';
import { resolveHtmlPath } from './util';
import { USER_EVENT_NAME } from '../constants';

if (process.env.NODE_ENV === 'production') {
  const sourceMapSupport = require('source-map-support');
  sourceMapSupport.install();
}

const isDevelopment =
  process.env.NODE_ENV === 'development' || process.env.DEBUG_PROD === 'true';

if (isDevelopment) {
  require('electron-debug')({ showDevTools: false });
}

const installExtensions = async () => {
  const installer = require('electron-devtools-installer');
  const forceDownload = !!process.env.UPGRADE_EXTENSIONS;
  const extensions = ['REACT_DEVELOPER_TOOLS'];

  return installer
    .default(
      extensions.map((name) => installer[name]),
      forceDownload
    )
    .catch(console.log);
};

const RESOURCES_PATH = app.isPackaged
  ? path.join(process.resourcesPath, 'assets')
  : path.join(__dirname, '../../assets');

export function getAssetPath(...paths: string[]): string {
  return path.join(RESOURCES_PATH, ...paths);
}

const defaultOptions = {
  show: false,
  icon: getAssetPath('icon.png'),
  webPreferences: {
    preload: path.join(__dirname, 'preload.js'),
    nodeIntegration: true,
    contextIsolation: false,
    webSecurity: false,
  },
};

export async function createWindow(
  options: Record<string, unknown>,
  url: string,
  initData?: any
) {
  if (
    process.env.NODE_ENV === 'development' ||
    process.env.DEBUG_PROD === 'true'
  ) {
    await installExtensions();
  }

  const newWindowOptions = { ...defaultOptions, ...options };
  let newWindow: BrowserWindow | null = new BrowserWindow(newWindowOptions);

  if (url) {
    newWindow.loadURL(resolveHtmlPath(url));
  }

  newWindow.webContents.on('did-finish-load', () => {
    if (!newWindow) {
      throw new Error(
        `createWindow failed with options: ${JSON.stringify(newWindowOptions)}`
      );
    }

    if (process.env.START_MINIMIZED) {
      newWindow.minimize();
    } else {
      newWindow.show();
      newWindow.focus();
    }

    if (initData) {
      newWindow?.webContents.send(USER_EVENT_NAME.INIT_DATA, initData);
    }
  });

  newWindow.on('closed', () => {
    newWindow = null;
  });

  return newWindow;
}
