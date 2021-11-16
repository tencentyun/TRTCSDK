import {
  TRTCParams,
  TRTCAppScene,
  TRTCVideoStreamType,
} from 'trtc-electron-sdk/liteav/trtc_define';
import TRTCCloud from 'trtc-electron-sdk';
// @ts-ignore
import TIM from 'tim-js-sdk';
// @ts-ignore
import TIMUploadPlugin from 'tim-upload-plugin';

import Event from './event';
import { USER_EVENT_NAME } from '../../../constants';

interface ConfigParam {
  sdkAppId: number; // 应用id
  userID: string; // 用户id
  userSig: string; // 签名
}

interface EnterRoomParams {
  roomID(roomID: any): number;
  role: string; // 角色
  // classId: number; // 教室id
  // nickName?: string; // 昵称
  // avatar?: string; // 头像地址
  sdkAppId: number; // 应用id
  userID: string; // 用户id
  userSig: string; // 签名
}

// 自定义消息名
const CUSTOM_MESSAGE_NAMES = {
  MUTE_ALL_STUDENT: 'mute-all-student', // 禁言
  HANDS_UP: 'hands-up', // 举手
  CONFIRM_HAND_UP: 'confirm-hand-up', // 老师回应学生举手
  CLASS_START_TIME: 'class-start-time', // 时间同步
  CALL_ROLL: 'call-roll', // 老师点名
  CALL_ROLL_REPLY: 'call-roll-reply', // 学生签到
};

class TrtcElectronEducation {
  static logPrefix = '[TRTC-Electron-Edu-SDK]';

  private sdkAppId = -1;

  ownerID = '';

  userID = '';

  roomID = '';

  role = '';

  private userSig = '';

  emitter: Event;

  private isSdkReady: boolean;

  remoteVideoAvailableUserSet: Set<string> = new Set();

  rtcCloud: any;

  tim: any;

  // 初始化配置参数
  constructor(config?: ConfigParam) {
    if (config) {
      this.sdkAppId = config.sdkAppId;
      this.userID = config.userID;
      this.userSig = config.userSig;
    }
    this.emitter = new Event();
    this.isSdkReady = false;
    // 释放trtccloud单例对象并清理资源
    if (this.rtcCloud) {
      this.rtcCloud.destroyTRTCShareInstance();
    }
    // 创建trtccloud单例对象
    this.rtcCloud = TRTCCloud.getTRTCShareInstance();
    console.log(
      `${TrtcElectronEducation.logPrefix} TRTC version:`,
      this.rtcCloud.getSDKVersion()
    );

    // trtc相关各种监听事件
    this.bindTRTCEvent();

    this.onMessageReceived = this.onMessageReceived.bind(this);
  }

  // 事件回调
  bindTRTCEvent() {
    this.rtcCloud.on('onEnterRoom', (result: number) => {
      this.emitter.emit(USER_EVENT_NAME.ENTER_ROOM_SUCCESS, { result });
    });
    this.rtcCloud.on('onExitRoom', (result: number) => {
      this.emitter.emit(USER_EVENT_NAME.LEAVE_ROOM_SUCCESS, { result });
    });
    this.rtcCloud.on('onError', (errcode: number, errmsg: string) => {
      // this.emitter.emit(USER_EVENT_NAME.LEAVE_ROOM_SUCCESS, { result });
      console.log(errcode, errmsg);
    });
    this.rtcCloud.on(
      USER_EVENT_NAME.ON_REMOTE_USER_ENTER_ROOM,
      this.onRemoteUserEnterRoom.bind(this)
    );
    this.rtcCloud.on(
      USER_EVENT_NAME.ON_REMOTE_USER_LEAVE_ROOM,
      this.onRemoteUserLeaveRoom.bind(this)
    );
    // 监听用户是否开启摄像头
    this.rtcCloud.on(
      USER_EVENT_NAME.ON_USER_VIDEO_AVAILABLE,
      this.onUserVideoAvailable.bind(this)
    );
    // 监听用户是否开启辅路画面（屏幕分享）
    this.rtcCloud.on(
      USER_EVENT_NAME.ON_USER_SUB_STREAM_AVAILABLE,
      this.onUserSubStreamAvailable.bind(this)
    );
    this.rtcCloud.on(
      USER_EVENT_NAME.ON_USER_AUDIO_AVAILABLE,
      this.onUserAudioAvailable.bind(this)
    );
  }

  bindTIMEvent() {
    // 登录成功后会触发 SDK_READY 事件，该事件触发后，可正常使用 SDK 接口
    this.tim.on(TIM.EVENT.SDK_READY, this.onTIMReadyStateUpdate.bind(this));
    // SDK NOT READT
    this.tim.on(TIM.EVENT.SDK_NOT_READY, this.onTIMReadyStateUpdate.bind(this));
    // 被踢出
    // this.tim.on(TIM.EVENT.KICKED_OUT, this.onKickOut);
    // // SDK内部出错
    this.tim.on(TIM.EVENT.ERROR, this.onError.bind(this));
    // 收到新消息
    this.tim.off(TIM.EVENT.MESSAGE_RECEIVED, this.onMessageReceived);
    this.tim.on(TIM.EVENT.MESSAGE_RECEIVED, this.onMessageReceived);
  }

  // eslint-disable-next-line class-methods-use-this
  onError(obj: any) {
    console.log(obj);
  }

  initIM() {
    // 初始化 sdk 实例
    const tim = TIM.create({
      SDKAppID: this.sdkAppId,
    });
    tim.setLogLevel(0); // 告警级别，SDK 只输出告警和错误级别的日志
    tim.registerPlugin({ 'tim-upload-plugin': TIMUploadPlugin });
    return tim;
  }

  loginIm(params: any) {
    if (!this.tim) {
      return;
    }
    const promise = this.tim.login({
      userID: params.userID,
      userSig: params.userSig,
    });
    promise
      .then(
        (imResponse: {
          data: {
            repeatLogin: boolean;
            errorInfo: any;
          };
        }) => {
          console.log('loginIm', imResponse.data); // 登录成功
          return imResponse.data;
        }
      )
      .catch((imError: any) => {
        console.warn('login error:', imError); // 登录失败的相关信息
      });
  }

  // 登出IM
  logoutIM() {
    const promise = this.tim.logout();
    promise
      .then((imResponse: { data: any }) => {
        console.log('logout success'); // 登出成功
        return imResponse.data;
      })
      .catch((imError: any) => {
        console.warn('logout error:', imError);
      });
  }

  onTIMReadyStateUpdate(obj: any) {
    console.log(`onTIMReadyStateUpdate ${obj.name}`);
    const isSDKReady = obj.name === TIM.EVENT.SDK_READY;
    if (isSDKReady) {
      this.isSdkReady = true;
      this.tim.getMyProfile(); // 获取个人资料
      if (this.role === 'teacher') {
        this.createOrJoinGroup(this.roomID); // 教师端是多窗口，首次进入时创建，后续再进入则直接加入
      } else {
        this.joinGroup(this.roomID);
      }
    }
  }

  // 创建或加入群
  createOrJoinGroup(groupID: any) {
    this.tim
      .searchGroupByID(groupID)
      .then((imResponse: any) => {
        console.warn(
          `${TrtcElectronEducation.logPrefix}.createOrJoinGroup searchGroupByID:`,
          imResponse.data.group
        );
        if (imResponse.data.group?.ownerID === this.userID) {
          this.joinGroup(groupID);
        } else {
          alert('课堂ID已存在，不能重复创建');
          (window as any).electron.ipcRenderer.send(
            USER_EVENT_NAME.EXIT_CLASS_ROOM,
            {}
          );
        }

        return null;
      })
      .catch((imError: any) => {
        // 未查到群信息（群不存在），新建群
        console.warn(
          `${TrtcElectronEducation.logPrefix}.createOrJoinGroup:`,
          imError
        );
        this.createGroup(groupID);
      });
  }

  // 创建群组
  async createGroup(groupID: any) {
    // 判断sdk的状态
    if (!this.isSdkReady) {
      console.log('sdk not ready');
      return;
    }
    console.warn(`${TrtcElectronEducation.logPrefix}.createGroup`);
    try {
      await this.tim.createGroup({
        type: TIM.TYPES.GRP_AVCHATROOM,
        // todo: name不传
        name: 'avchatroom',
        groupID,
      });
      console.log('创建成功！');
      this.joinGroup(groupID);
      // 创建成功
    } catch (imError) {
      console.warn('createGroup error:', imError);
      alert('课堂ID已存在，不能重复创建');
      (window as any).electron.ipcRenderer.send(
        USER_EVENT_NAME.EXIT_CLASS_ROOM,
        {}
      );
    }
  }

  // 加入创建的直播群
  // To-do：暂时去掉 async-await，规避当前用户进群时，自身被计入2次问题。更优雅的解决办法是统一 IM 和 TRTC 用户数据
  async joinGroup(groupID: any) {
    console.warn(`${TrtcElectronEducation.logPrefix}.joinGroup`);
    try {
      await this.tim.joinGroup({
        groupID,
        type: TIM.TYPES.GRP_AVCHATROOM,
      });
      this.getGroupMemberList(groupID);
      this.getGroupProfile(groupID);
    } catch (e) {
      console.warn('joinGroup error:', e); // 申请加群失败的相关信息
      alert('请等待老师创建课堂');
      (window as any).electron.ipcRenderer.send(
        USER_EVENT_NAME.STUDENT_EXIT_CLASS_ROOM,
        {}
      );
    }
  }

  // 退群quitGroup
  quitGroup(groupID: any) {
    try {
      this.tim.quitGroup(groupID);
    } catch (e) {
      console.warn(`${TrtcElectronEducation.logPrefix} quitGroup error:`, e); // 申请加群失败的相关信息
      (window as any).electron.ipcRenderer.send(
        USER_EVENT_NAME.STUDENT_EXIT_CLASS_ROOM,
        {}
      );
    }
  }

  // 获取群组列表
  async getGroupProfile(groupID: any) {
    try {
      const imResponse = await this.tim.getGroupProfile({
        groupID: groupID.toString(),
        groupCustomFieldFilter: [],
      });
      this.ownerID = imResponse.data.group.ownerID;
      console.log(this.ownerID);
      this.emitter.emit(USER_EVENT_NAME.ON_OWNER_READY, this.ownerID);
    } catch (imError: any) {
      console.warn('getGroupList error:', imError); // 获取群组列表失败的相关信息
    }
  }

  // 拉取直播群对应的群成员
  async getGroupMemberList(groupID: any) {
    try {
      const {
        data: { memberList },
      } = await this.tim.getGroupMemberList({
        groupID,
        count: 30,
        offset: 0,
      });
      console.warn(
        `${TrtcElectronEducation.logPrefix} getGroupMemberList memberList`,
        memberList
      );
      const convertedMemberList: {
        userID: any;
        avatar: any;
        role: any;
        nick: any;
      }[] = [];
      memberList.forEach((member: any) => {
        if (member.role === 'Owner') {
          convertedMemberList.unshift({
            userID: member.userID,
            avatar: member.avatar,
            role: member.role,
            nick: member.nick,
          });
        } else {
          convertedMemberList.push({
            userID: member.userID,
            avatar: member.avatar,
            role: member.role,
            nick: member.nick,
          });
        }
      });
      this.emitter.emit(
        USER_EVENT_NAME.GET_GROUP_MEMBER_LIST,
        convertedMemberList
      );
    } catch (imError) {
      console.warn(
        `${TrtcElectronEducation.logPrefix} getGroupMemberProfile error:`,
        imError
      );
    }
  }

  // 发送消息
  sendMessage(msgText: any, roomId: any) {
    // 判断sdk的状态
    if (!this.isSdkReady) {
      console.log('sdk not ready');
      return;
    }
    // 创建消息并发送到对应群组
    const message = this.tim.createTextMessage({
      to: roomId,
      conversationType: TIM.TYPES.CONV_GROUP,
      payload: {
        text: msgText,
      },
    });
    try {
      const imResponse = this.tim.sendMessage(message);
      // 发送成功
      console.log(imResponse, '成功');
    } catch (imError) {
      // 发送失败
      console.warn(
        `${TrtcElectronEducation.logPrefix}sendMessage error:`,
        imError
      );
    }
    this.emitter.emit(USER_EVENT_NAME.ON_CHAT_MESSAGE, {
      nick: message.nick || '',
      content: message.payload.text,
      userID: message.from,
    });
  }

  onMessageReceived(event: any) {
    console.info('message received: ', event);
    event.data.forEach((message: Record<string, any>) => {
      switch (message.type) {
        case TIM.TYPES.MSG_TEXT:
          this.handleMessageTip(message);
          break;
        case TIM.TYPES.MSG_CUSTOM:
          this.handleCustomMessage(message);
          break;
        case TIM.TYPES.MSG_GRP_TIP:
          this.handleGroupTip(message);
          break;
        case TIM.TYPES.MSG_GRP_SYS_NOTICE:
          this.handleGroupNotice(message);
          break;
        default:
          console.warn(
            `${TrtcElectronEducation.logPrefix}.onMessageReceived unknown message type:`,
            message
          );
      }
    });
  }

  handleGroupNotice(messageList: Record<string, any>) {
    // 解散群组通知
    this.handleDismissGroupNotice(messageList);
  }

  handleCustomMessage(message: Record<string, any>) {
    if (message.payload?.data === CUSTOM_MESSAGE_NAMES.MUTE_ALL_STUDENT) {
      console.warn(
        `${TrtcElectronEducation.logPrefix}.handleCustomMessage mute-all-student`,
        message
      );
      this.emitter.emit(
        USER_EVENT_NAME.ON_MUTE_ALL_STUDENT,
        message.payload?.extension === 'true'
      );
    } else if (message.payload?.data === CUSTOM_MESSAGE_NAMES.HANDS_UP) {
      console.warn(
        `${TrtcElectronEducation.logPrefix}.handleCustomMessage hands-up`,
        message
      );
      this.emitter.emit(
        USER_EVENT_NAME.ON_HANDS_UP,
        message.payload?.extension
      );
    } else if (message.payload?.data === CUSTOM_MESSAGE_NAMES.CONFIRM_HAND_UP) {
      console.warn(
        `${TrtcElectronEducation.logPrefix}.handleCustomMessage confirm-hand-up`,
        message
      );
      this.emitter.emit(USER_EVENT_NAME.ON_CONFIRM_HAND_UP, null);
    } else if (
      message.payload?.data === CUSTOM_MESSAGE_NAMES.CLASS_START_TIME
    ) {
      console.warn(
        `${TrtcElectronEducation.logPrefix}.handleCustomMessage class-start-time`,
        message
      );
      this.emitter.emit(
        USER_EVENT_NAME.ON_CLASS_TIME,
        message.payload?.extension
      );
    } else if (message.payload?.data === CUSTOM_MESSAGE_NAMES.CALL_ROLL) {
      console.warn(
        `${TrtcElectronEducation.logPrefix}.handleCustomMessage call-roll`,
        message
      );
      this.emitter.emit(
        USER_EVENT_NAME.ON_CALL_ROLL,
        message.payload?.extension
      );
    } else if (message.payload?.data === CUSTOM_MESSAGE_NAMES.CALL_ROLL_REPLY) {
      console.warn(
        `${TrtcElectronEducation.logPrefix}.handleCustomMessage  call-roll-reply`,
        message
      );
      this.emitter.emit(
        USER_EVENT_NAME.ON_CALL_ROLL_REPLY,
        message.payload?.extension
      );
    }
  }

  onUserVideoAvailable(userID: string, available: number) {
    console.info(
      `${TrtcElectronEducation.logPrefix}.onUserVideoAvailable: userId: ${userID}, available: ${available}`
    );
    (window as any).electron.ipcRenderer.send(
      USER_EVENT_NAME.ON_USER_VIDEO_AVAILABLE,
      {
        userID,
        available,
      }
    );
    this.emitter.emit(USER_EVENT_NAME.ON_USER_VIDEO_AVAILABLE, {
      userID,
      available,
    });
  }

  onUserAudioAvailable(userID: string, available: number) {
    console.info(
      `${TrtcElectronEducation.logPrefix}.onUserAudioAvailable: userId: ${userID}, available: ${available}`
    );
    (window as any).electron.ipcRenderer.send(
      USER_EVENT_NAME.ON_USER_AUDIO_AVAILABLE,
      {
        userID,
        available,
      }
    );
    this.emitter.emit(USER_EVENT_NAME.ON_USER_AUDIO_AVAILABLE, {
      userID,
      available,
    });
  }

  onUserSubStreamAvailable(userId: string, available: number) {
    console.info(
      `${TrtcElectronEducation.logPrefix}.onUserSubStreamAvailable`,
      userId,
      available
    );
    this.emitter.emit(USER_EVENT_NAME.ON_USER_SUB_STREAM_AVAILABLE, {
      userId,
      available,
    });
  }

  onRemoteUserEnterRoom(userID: string) {
    console.info(
      `${TrtcElectronEducation.logPrefix}.onRemoteUserEnterRoom: userId: ${userID}`
    );
    // 屏幕分享端
    (window as any).electron.ipcRenderer.send(
      USER_EVENT_NAME.ON_REMOTE_USER_ENTER_ROOM,
      userID
    );
    this.emitter.emit(USER_EVENT_NAME.ON_REMOTE_USER_ENTER_ROOM, userID);
  }

  onRemoteUserLeaveRoom(userID: string, reason: number) {
    console.log(
      `${TrtcElectronEducation.logPrefix}.onRemoteUserLeaveRoom userID: ${userID} reason: ${reason}`
    );
    (window as any).electron.ipcRenderer.send(
      USER_EVENT_NAME.ON_REMOTE_USER_LEAVE_ROOM,
      userID
    );
    this.emitter.emit(USER_EVENT_NAME.ON_REMOTE_USER_LEAVE_ROOM, userID);
  }

  // 监听到文本消息
  async handleMessageTip(message: Record<string, any>) {
    // 收到的是文本消息
    if (message.type === TIM.TYPES.MSG_TEXT) {
      const newMessage = {
        nick: message.nick || message.from,
        content: message.payload.text,
        userID: message.from,
      };
      this.emitter.emit(USER_EVENT_NAME.ON_CHAT_MESSAGE, newMessage);
      (window as any).electron.ipcRenderer.send(
        USER_EVENT_NAME.ON_MESSAGE_RECEIVED,
        [newMessage]
      );
    }
  }

  handleGroupTip(messageList: Record<string, any>) {
    switch (messageList.payload.operationType) {
      case TIM.TYPES.GRP_TIP_MBR_JOIN:
        this.handleJoinGroupTip(messageList);
        break;
      case TIM.TYPES.GRP_TIP_MBR_QUIT:
        this.handleQuitGroupTip(messageList);
        break;
      default:
        console.warn(
          `${TrtcElectronEducation.logPrefix}.onMessageReceived unknown message group type:`,
          messageList
        );
    }
  }

  // 监听到加群消息
  async handleJoinGroupTip(messageList: Record<string, any>) {
    console.warn(
      `${TrtcElectronEducation.logPrefix}.handleJoinGroupTip args:`,
      messageList
    );
    this.emitter.emit(USER_EVENT_NAME.ON_CLASS_MEMBER_ENTER, {
      userID: messageList.payload.operatorID,
      avatar: messageList.avatar,
      role:
        this.role === 'teacher' &&
        this.userID === messageList.payload.operatorID
          ? 'Owner'
          : 'Member',
      nick: '',
    });
  }

  // 监听到退群消息
  async handleQuitGroupTip(messageList: Record<string, any>) {
    // 筛选出当前会话的退群/被踢群的 groupTip
    console.warn(
      `${TrtcElectronEducation.logPrefix}.handleQuitGroupTip args:`,
      messageList
    );
    if (messageList.payload.operatorID !== this.ownerID) {
      console.log('quit-group-messagelist', messageList);
      this.emitter.emit(USER_EVENT_NAME.ON_CLASS_MEMBER_QUIT, {
        userID: messageList.payload.operatorID,
        avatar: messageList.avatar,
        role: 'Member',
        nick: '',
      });
    }
  }

  // eslint-disable-next-line class-methods-use-this
  async handleDismissGroupNotice(messageList: Record<string, any>) {
    console.warn(
      `${TrtcElectronEducation.logPrefix}.handleDisMissGroupTipOut args:`,
      messageList.payload.operationType
    );
    // 此通知未定义tim常量
    if (messageList.payload.operationType === 5) {
      console.warn(
        `${TrtcElectronEducation.logPrefix}.handleDisMissGroupTip args:`,
        messageList
      );
      this.exitTRTCroom();
      alert('老师已解散群组！!!');
      (window as any).electron.ipcRenderer.send(
        USER_EVENT_NAME.STUDENT_EXIT_CLASS_ROOM,
        {}
      );
    }
  }

  /**
   * 进入教室
   *
   * 进入 TRTC 房间并创建 IM 群组
   * @params EnterRoomParams
   */
  enterClassRoom(params: EnterRoomParams) {
    this.sdkAppId = params.sdkAppId;
    this.userID = params.userID;
    this.userSig = params.userSig;
    this.role = params.role;
    this.roomID = params.roomID.toString();
    if (params.role === 'teacher') {
      this.enterTRTCRoom(Number(params.roomID));
      this.rtcCloud.startLocalAudio(); // To-do: 待用户进房时，根据进房参数再调用该方法
      (window as any).electron.ipcRenderer.send(
        USER_EVENT_NAME.ON_CHANGE_LOCAL_USER_STATE,
        {
          userID: this.userID,
          isCameraStarted: true,
          isMicStarted: true,
        }
      );
    } else if (params.role === 'student') {
      this.enterTRTCRoom(Number(params.roomID));
      this.rtcCloud.startLocalAudio(); // To-do: 待用户进房时，根据进房参数 + 教师端控制参数，再调用该方法
    } else {
      console.log('用户角色错误！'); // To-do: 日志打印待优化
    }
    this.tim = this.initIM();
    this.bindTIMEvent();
    this.loginIm({
      userID: this.userID,
      userSig: this.userSig,
    });
  }

  reenterTRTCRoom() {
    if (this.role === 'teacher') {
      this.enterTRTCRoom(Number(this.roomID));
      this.rtcCloud.startLocalAudio(); // To-do: 待用户进房时，根据进房参数再调用该方法
    }
  }

  enterTRTCRoom(roomID: number) {
    const param = new TRTCParams();
    param.sdkAppId = this.sdkAppId;
    param.roomId = roomID;
    param.userId = this.userID;
    param.userSig = this.userSig;
    param.userDefineRecordId = ''; // 云端录制
    // 调用enterRoom接口
    this.rtcCloud.enterRoom(param, TRTCAppScene.TRTCAppSceneVideoCall); // 视频互动直播，支持平滑上下麦，切换过程无需等待，主播延时小于300ms；

    this.rtcCloud.setRenderMode(2); // 1-webgl 2-yuvcanvs
  }

  /*
   * 开始显示远端视频画面或屏幕分享画面
   * @params RemoteParams
   */
  startRemoteView(userID: any, dom: any) {
    this.rtcCloud.startRemoteView(
      userID,
      dom,
      TRTCVideoStreamType.TRTCVideoStreamTypeBig
    );
  }

  /*
   * 停止显示远端视频画面或屏幕分享画面，同时不再拉取该远端用户的数据流
   * @params StopRemoteParams
   */
  stopRemoteView(userID: any, dom: any) {
    this.rtcCloud.stopRemoteView(
      userID,
      dom,
      TRTCVideoStreamType.TRTCVideoStreamTypeBig
    );
  }

  async sendClassTimeMessage(roomId: any, time: number) {
    // 判断sdk的状态
    if (!this.isSdkReady) {
      console.log('sdk not ready');
      return;
    }
    // 创建消息并发送到对应群组
    const message = this.tim.createCustomMessage({
      to: roomId.toString(),
      conversationType: TIM.TYPES.CONV_GROUP,
      payload: {
        data: CUSTOM_MESSAGE_NAMES.CLASS_START_TIME, // 类型消息
        description: '', // 根据需求判断
        extension: time.toString(), // 自定义扩展字段
      },
    });
    try {
      const imResponse = await this.tim.sendMessage(message);
      // 发送成功
      console.log(
        `${TrtcElectronEducation.logPrefix}时间戳发送成功`,
        imResponse
      );
    } catch (imError) {
      // 发送失败
      console.warn(`${TrtcElectronEducation.logPrefix}时间戳发送失败`, imError);
      throw imError;
    }
  }

  async sendHandsMessage(roomId: any, userId: any) {
    // 判断sdk的状态
    if (!this.isSdkReady) {
      console.log('sdk not ready');
      return;
    }
    // 创建消息并发送到对应群组
    const message = this.tim.createCustomMessage({
      to: roomId.toString(),
      conversationType: TIM.TYPES.CONV_GROUP,
      payload: {
        data: CUSTOM_MESSAGE_NAMES.HANDS_UP, // 类型消息
        description: '', // 根据需求判断
        extension: userId.toString(), // 自定义扩展字段
      },
    });
    try {
      const imResponse = await this.tim.sendMessage(message);
      // 发送成功
      console.log(`${TrtcElectronEducation.logPrefix}举手成功`, imResponse);
    } catch (imError) {
      // 发送失败
      console.warn(`${TrtcElectronEducation.logPrefix}举手失败`, imError);
      throw imError;
    }
  }

  async sendHandUpAck(userID: string) {
    // 判断sdk的状态
    if (!this.isSdkReady) {
      console.log('sdk not ready');
      return;
    }

    const message = this.tim.createCustomMessage({
      to: userID.toString(),
      conversationType: TIM.TYPES.CONV_C2C,
      payload: {
        data: CUSTOM_MESSAGE_NAMES.CONFIRM_HAND_UP, // 类型消息
        description: '', // 根据需求判断
        extension: userID.toString(), // 自定义扩展字段
      },
    });
    try {
      const imResponse = await this.tim.sendMessage(message);
      console.log(
        `${TrtcElectronEducation.logPrefix}.sendHandUpAck success`,
        imResponse
      );
    } catch (imError) {
      console.log(
        `${TrtcElectronEducation.logPrefix}.sendHandUpAck error`,
        imError
      );
      throw imError;
    }
  }

  // 只有教师端可以调用
  async muteAllStudent(mute: boolean, roomID: any) {
    // 判断sdk的状态
    if (!this.isSdkReady) {
      console.log('sdk not ready');
      return;
    }
    // 创建消息并发送到对应群组
    const message = this.tim.createCustomMessage({
      to: roomID.toString(),
      conversationType: TIM.TYPES.CONV_GROUP,
      payload: {
        data: CUSTOM_MESSAGE_NAMES.MUTE_ALL_STUDENT, // 类型消息
        description: '', // 根据需求判断
        extension: mute.toString(), // 自定义扩展字段
      },
    });
    try {
      const imResponse = await this.tim.sendMessage(message);
      console.log(
        `${TrtcElectronEducation.logPrefix}.muteAllStudent success`,
        imResponse
      );
      (window as any).electron.ipcRenderer.send(
        USER_EVENT_NAME.ON_MUTE_ALL_STUDENT,
        mute
      );
    } catch (imError) {
      console.log(
        `${TrtcElectronEducation.logPrefix}.muteAllStudent error`,
        imError
      );
      throw imError;
    }
  }

  // 新用户进房后，教师端根据是否开启全员禁麦调用
  async muteStudentByID(mute: boolean, userID: string) {
    // 判断sdk的状态
    if (!this.isSdkReady) {
      console.log('sdk not ready');
      return;
    }

    const message = this.tim.createCustomMessage({
      to: userID.toString(),
      conversationType: TIM.TYPES.CONV_C2C,
      payload: {
        data: CUSTOM_MESSAGE_NAMES.MUTE_ALL_STUDENT,
        description: '',
        extension: mute.toString(),
      },
    });
    try {
      const imResponse = await this.tim.sendMessage(message);
      // 发送成功
      console.log('muteStudentByID 成功', imResponse);
    } catch (imError) {
      // 发送失败
      console.warn('muteStudentByID error:', imError);
      throw imError;
    }
  }

  // 老师点名
  async callRoll(time: number, roomID: any) {
    // 判断sdk的状态
    if (!this.isSdkReady) {
      console.log('sdk not ready');
      return;
    }
    // 创建消息并发送到对应群组
    const message = this.tim.createCustomMessage({
      to: roomID.toString(),
      conversationType: TIM.TYPES.CONV_GROUP,
      payload: {
        data: CUSTOM_MESSAGE_NAMES.CALL_ROLL, // 类型消息
        description: '', // 根据需求判断
        extension: time.toString(), // 自定义扩展字段
      },
    });
    try {
      const imResponse = await this.tim.sendMessage(message);
      console.log(
        `${TrtcElectronEducation.logPrefix}.callRoll success`,
        imResponse
      );
    } catch (imError) {
      console.log(`${TrtcElectronEducation.logPrefix}.callRoll error`, imError);
      throw imError;
    }
  }

  // 老师向后进来的学生发送签到请求
  async callRollByID(time: number, userID: string) {
    // 判断sdk的状态
    if (!this.isSdkReady) {
      console.log('sdk not ready');
      return;
    }
    // 创建消息并发送到对应群组
    const message = this.tim.createCustomMessage({
      to: userID.toString(),
      conversationType: TIM.TYPES.CONV_C2C,
      payload: {
        data: CUSTOM_MESSAGE_NAMES.CALL_ROLL, // 类型消息
        description: '', // 根据需求判断
        extension: time.toString(), // 自定义扩展字段
      },
    });
    try {
      const imResponse = await this.tim.sendMessage(message);
      console.log(
        `${TrtcElectronEducation.logPrefix}.callRollByID success`,
        imResponse
      );
    } catch (imError) {
      console.log(
        `${TrtcElectronEducation.logPrefix}.callRollByID error`,
        imError
      );
      throw imError;
    }
  }

  // 学生签到
  async callRollReply(
    studentUserID: string,
    time: number,
    teacherUserID: string
  ) {
    // 判断sdk的状态
    if (!this.isSdkReady) {
      console.log('sdk not ready');
      return;
    }

    const message = this.tim.createCustomMessage({
      to: teacherUserID.toString(),
      conversationType: TIM.TYPES.CONV_C2C,
      payload: {
        data: CUSTOM_MESSAGE_NAMES.CALL_ROLL_REPLY,
        description: '',
        extension: JSON.stringify({ studentUserID, time }),
      },
    });
    try {
      const imResponse = await this.tim.sendMessage(message);
      // 发送成功
      console.log(
        `${TrtcElectronEducation.logPrefix}.call-roll-reply 成功`,
        imResponse
      );
      // 抛事件，学生数据（time，id）
    } catch (imError) {
      // 发送失败
      console.warn(
        `${TrtcElectronEducation.logPrefix}.call-roll-reply error:`,
        imError
      );
      throw imError;
    }
  }

  /**
   * 清空启动的TRTC功能和数据
   */
  clearTRTCData() {
    // 关闭采集音视频
    this.rtcCloud.stopLocalPreview();
    this.rtcCloud.stopLocalAudio();
    this.rtcCloud.stopScreenCapture();
    this.rtcCloud.stopAllAudioEffects();
    this.rtcCloud.stopBGM();
  }

  /**
   * 逻辑：
   * 老师-退出trtc房间，解散群组
   * 学生-退出群组、退出 trtc 房间
   */
  exitClassRoom() {
    this.exitTRTCroom();
    if (this.role === 'teacher') {
      this.dismissGroup(this.roomID);
    } else {
      this.quitGroup(this.roomID);
    }
  }

  exitTRTCroom() {
    this.clearTRTCData();
    this.rtcCloud.exitRoom();
  }

  // 解散群组
  async dismissGroup(groupID: any) {
    try {
      await this.tim.dismissGroup(groupID.toString());
      this.emitter.emit(USER_EVENT_NAME.TEACHER_GROUP_DISMISSED, groupID);
      console.log('群组解散成功');
    } catch (imError) {
      console.log('群组解散失败');
      console.warn('dismissGroup error:', imError); // 解散群组失败的相关信息
    }
  }
}

export default TrtcElectronEducation;
