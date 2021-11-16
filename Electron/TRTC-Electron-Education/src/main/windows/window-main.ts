import { ipcMain, BrowserWindow } from 'electron';
import { USER_EVENT_NAME } from '../../constants';
import { createWindow } from '../create-window';
import BaseWindow from './window-base';
import {
  createClassRoomWindow,
  createStudentClassRoomWindow,
} from './window-class-room';
import store, { clearStore } from '../store';

class MainWindow extends BaseWindow {
  private static preLog = '[MainWindow]';

  private classRoomWindowId!: number | null;

  private studentClassRoomWindowId!: number | null;

  constructor(options: Record<string, unknown>, url: string) {
    super(options, url);
    // App event handler
    this.enterClassRoomListener = this.enterClassRoomListener.bind(this);
    this.exitClassRoomListener = this.exitClassRoomListener.bind(this);
    this.studentEnterClassRoomListener =
      this.studentEnterClassRoomListener.bind(this);
    this.exitStudentEnterClassRoomListener =
      this.exitStudentEnterClassRoomListener.bind(this);
    this.onChangeLocalUserState = this.onChangeLocalUserState.bind(this);
    this.onMuteAllStudent = this.onMuteAllStudent.bind(this);
    this.onCallRoll = this.onCallRoll.bind(this);

    // TIM event handler
    this.onMessageReceived = this.onMessageReceived.bind(this);

    // TRTC event handler
    this.onUserVideoAvailable = this.onUserVideoAvailable.bind(this);

    this.destroy = this.destroy.bind(this);

    // this.init();
  }

  async init() {
    this.browserWindow = await createWindow(
      this.windowOptions || {},
      this.contentUrl || ''
    );
    this.registerEvent();
    this.browserWindow?.on('closed', this.destroy);
  }

  /* eslint-disable */
  async enterClassRoomListener(event: any, args: any) {
    console.log(`${MainWindow.preLog}.enterClassRoomListener() args:`, args);
    try {
      const userInfo = JSON.parse(JSON.stringify(args));
      store.currentUser = Object.assign(store.currentUser, userInfo);
      const classRoomWindow = await createClassRoomWindow(store);
      this.classRoomWindowId = classRoomWindow.id || null;

      this.browserWindow?.hide();
    } catch (error) {
      alert("窗口打开失败！");
    }
  }

  async studentEnterClassRoomListener(event: any, args: any) {
    console.log(`${MainWindow.preLog}.studentEnterClassRoomListener() args:`, args);
    try {
      const userInfo = JSON.parse(JSON.stringify(args));
      store.currentUser = Object.assign(store.currentUser, userInfo);
      const studentClassWindow = await createStudentClassRoomWindow(store);
      this.studentClassRoomWindowId = studentClassWindow.id || null;
      this.browserWindow?.hide();
    } catch (error) {
      alert("窗口打开失败！");
    }
  }

  exitClassRoomListener(event: any, args: any) {
    console.warn(`${MainWindow.preLog}.exitClassRoomListener() args:`, args);
    this.browserWindow?.show();
    if (this.classRoomWindowId) {
      const classRoomWindow = BrowserWindow.fromId(this.classRoomWindowId);
      if (classRoomWindow) {
        classRoomWindow.close();
        this.classRoomWindowId = null;
      }
      // 清楚定时器！
    }
    // clear store
    clearStore();
  }

  exitStudentEnterClassRoomListener(event: any, args: any) {
    console.warn(`${MainWindow.preLog}.exitStudentEnterClassRoomListener() args:`, args);
    this.browserWindow?.show();
    if (this.studentClassRoomWindowId) {
      const studentClassWindow = BrowserWindow.fromId(this.studentClassRoomWindowId);
      if (studentClassWindow) {
        studentClassWindow.close();
        this.studentClassRoomWindowId = null;
      }
    }
    // clear store
    clearStore();
  }
  /* eslint-disable */

  onMessageReceived(event: any, args: any) {
    console.warn(`${MainWindow.preLog}.onMessageReceived() args:`, args);

    const receivedMessage = args as Array<never>;
    receivedMessage.forEach(item => store.messages.push(item));
  }

  onChangeLocalUserState(event: any, args: any) {
    console.warn(`${MainWindow.preLog}.onChangeLocalUserState() args:`, args);

    store.currentUser = Object.assign(store.currentUser, args);
  }

  onMuteAllStudent(event: any, args: any) {
    console.warn(`${MainWindow.preLog}.onMuteAllStudent() args:`, args);
    store.currentUser.isAllStudentMuted = args;
  }

  onCallRoll(event: any, args: any) {
    console.warn(`${MainWindow.preLog}.onCallRoll() args:`, args);
    store.currentUser = Object.assign(store.currentUser, args);
  }

  onUserVideoAvailable(event: any, args: any) {
    console.warn(`${MainWindow.preLog}.onUserVideoAvailable() args:`, args);

    const available = args.available as number;
    if (available) {
      store.videoAvailableUserSet.add(args.userId);
    } else {
      store.videoAvailableUserSet.delete(args.userId);
    }
  }

  registerEvent() {
    // App event
    ipcMain.on(USER_EVENT_NAME.ENTER_CLASS_ROOM, this.enterClassRoomListener);
    ipcMain.on(USER_EVENT_NAME.EXIT_CLASS_ROOM, this.exitClassRoomListener);
    ipcMain.on(USER_EVENT_NAME.STUDENT_ENTER_CLASS_ROOM, this.studentEnterClassRoomListener);
    ipcMain.on(USER_EVENT_NAME.STUDENT_EXIT_CLASS_ROOM, this.exitStudentEnterClassRoomListener);
    ipcMain.on(USER_EVENT_NAME.ON_CHANGE_LOCAL_USER_STATE, this.onChangeLocalUserState);
    ipcMain.on(USER_EVENT_NAME.ON_MUTE_ALL_STUDENT, this.onMuteAllStudent);
    ipcMain.on(USER_EVENT_NAME.ON_CALL_ROLL, this.onCallRoll);



    // TIM event
    ipcMain.on(USER_EVENT_NAME.ON_MESSAGE_RECEIVED, this.onMessageReceived);

    // TRTC event
    ipcMain.on(USER_EVENT_NAME.ON_USER_VIDEO_AVAILABLE, this.onUserVideoAvailable);
  }

  unregisterEvent() {
    // App event
    ipcMain.removeListener(USER_EVENT_NAME.ENTER_CLASS_ROOM, this.enterClassRoomListener);
    ipcMain.removeListener(USER_EVENT_NAME.EXIT_CLASS_ROOM, this.exitClassRoomListener);
    ipcMain.removeListener(USER_EVENT_NAME.STUDENT_ENTER_CLASS_ROOM, this.studentEnterClassRoomListener);
    ipcMain.removeListener(USER_EVENT_NAME.STUDENT_EXIT_CLASS_ROOM, this.exitStudentEnterClassRoomListener);
    ipcMain.removeListener(USER_EVENT_NAME.ON_CHANGE_LOCAL_USER_STATE, this.onChangeLocalUserState);
    ipcMain.removeListener(USER_EVENT_NAME.ON_MUTE_ALL_STUDENT, this.onMuteAllStudent);
    ipcMain.removeListener(USER_EVENT_NAME.ON_CALL_ROLL, this.onCallRoll);

    // TIM event
    ipcMain.removeListener(USER_EVENT_NAME.ON_MESSAGE_RECEIVED, this.onMessageReceived);

    // TRTC event
    ipcMain.removeListener(USER_EVENT_NAME.ON_USER_VIDEO_AVAILABLE, this.onUserVideoAvailable);
  }

  getBrowserWindow() {
    return this.browserWindow;
  }

  destroy() {
    this.unregisterEvent();
    super.destroy();
  }
}

export default MainWindow;

export async function createMainWindow() {
  const LOGIN_WIDTH = 800;
  const LOGIN_HEIGHT = 600;
  // const CLASS_ROOM_WIDTH = 1024;
  // const CLASS_ROOM_HEIGHT = 728;

  const mainWindowConfig = {
    width: LOGIN_WIDTH,
    height: LOGIN_HEIGHT,
  };
  const mainWindowUrl = 'index.html?view=login';
  const newWindow = new MainWindow(mainWindowConfig, mainWindowUrl);
  await newWindow.init();
  return newWindow;
}
