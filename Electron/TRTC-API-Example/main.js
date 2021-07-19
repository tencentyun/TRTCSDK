const path = require('path');
const glob = require('glob');
const { app, BrowserWindow } = require('electron');
const isDev = require('electron-is-dev');

const debug = /--debug/.test(process.argv[2]);

if (process.mas) app.setName('TRTC Electron API Examples');

let mainWindow = null;

function initialize() {
  makeSingleInstance();

  loadMainModules();

  function createWindow() {
    const windowOptions = {
      width: 1080,
      minWidth: 680,
      height: 840,
      title: app.getName(),
      webPreferences: {
        nodeIntegration: true,
        preload: path.join(__dirname, 'preload.js')
      }
    };

    mainWindow = new BrowserWindow(windowOptions);

    if (isDev) {
      mainWindow.loadURL('http://localhost:3000');
    } else {
      mainWindow.loadURL(path.join('file://', __dirname, '/src/app/render/main-page/build/index.html'));
    }

    // Launch fullscreen with DevTools open, usage: npm run debug
    if (debug) {
      mainWindow.webContents.openDevTools();
      mainWindow.maximize();
      require('devtron').install();
    }

    mainWindow.on('closed', () => {
      mainWindow = null;
    });
  }

  app.on('ready', () => {
    createWindow();
  });

  app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
      app.quit();
    }
  });

  app.on('activate', () => {
    if (mainWindow === null) {
      createWindow();
    }
  });
}

// Make this app a single instance app.
//
// The main window will be restored and focused instead of a second window
// opened when a person attempts to launch a second instance.
//
// Returns true if the current version of the app should quit instead of
// launching.
function makeSingleInstance() {
  if (process.mas) return;

  app.requestSingleInstanceLock();

  app.on('second-instance', () => {
    if (mainWindow) {
      if (mainWindow.isMinimized()) mainWindow.restore();
      mainWindow.focus();
    }
  });
}

// Require each JS file in the main-process dir
function loadMainModules() {
  const files = glob.sync(path.join(__dirname, 'src/app/main/**/*.js'));
  files.forEach(file => require(file));
}

initialize();
