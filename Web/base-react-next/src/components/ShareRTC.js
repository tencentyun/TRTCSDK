import a18n from 'a18n';
import React from 'react';
import TRTC from 'trtc-js-sdk';
import { getLatestUserSig } from '@app/index';
import { SDKAPPID } from '@app/config';

export default class ShareRTC extends React.Component {
  constructor(props) {
    super(props);
    this.userID = props.userID;
    this.roomID = props.roomID;
    this.useStringRoomID = props.useStringRoomID;
    this.relatedUserID = props.relatedUserID;
    this.updateStreamConfig = props.updateStreamConfig;
    this.shareClient = null;
    this.localStream = null;
    this.getUserSig();
  }

  // eslint-disable-next-line camelcase
  async UNSAFE_componentWillReceiveProps(props) {
    if (this.userID !== props.userID) {
      this.userID = props.userID;
      this.getUserSig();
    }
    this.roomID = props.roomID;
    this.useStringRoomID = props.useStringRoomID;
    this.relatedUserID = props.relatedUserID;
    this.updateStreamConfig = props.updateStreamConfig;
  }

  async componentDidMount() {
    this.props.onRef(this);
  }

  async getUserSig() {
    const { userSig, privateMapKey } = await getLatestUserSig(this.userID);
    this.userSig = userSig;
    this.privateMapKey = privateMapKey;
  }

  async initClient(mode = 'rtc') {
    this.shareClient = TRTC.createClient({
      mode,
      sdkAppId: SDKAPPID,
      userId: this.userID,
      userSig: this.userSig,
      autoSubscribe: false,
    });
    this.handleClientEvents();
    return this.shareClient;
  }

  async initLocalStream() {
    this.localStream = TRTC.createStream({
      // disable audio as RtcClient already enable audio
      audio: false,
      // enable screen share
      screen: true,
      userId: this.userID,
    });
    this.localStream.setScreenProfile('1080p');
    try {
      await this.localStream.initialize();
    } catch (error) {
      switch (error.name) {
        case 'NotReadableError':
          alert(a18n('屏幕分享失败，请确保系统允许当前浏览器获取屏幕内容'));
          throw error;
        case 'NotAllowedError':
          if (error.message === 'Permission denied by system') {
            alert(a18n('屏幕分享失败，请确保系统允许当前浏览器获取屏幕内容'));
          } else {
            console.log('User refused to share the screen');
          }
          throw error;
        default:
          return;
      }
    }
    this.handleStreamEvents();
  }

  destroyLocalStream() {
    this.localStream.stop();
    this.localStream.close();
  }

  async handleJoin() {
    if (this.isJoined) {
      return;
    }
    await this.initClient();
    try {
      await this.initLocalStream();
      await this.shareClient.join({ roomId: this.roomID });
      this.isJoined = true;
      this.props.setState && this.props.setState('screenShare', true);
      this.handlePublish();
    } catch (error) {
      console.log('shareRTC handleJoin error = ', error);
      throw error;
    }
  }

  async handlePublish() {
    await this.shareClient.publish(this.localStream);
    this.isPublished = true;
  }

  async handleUnPublish() {
    await this.shareClient.unpublish(this.localStream);
    this.isPublished = false;
  }

  async handleLeave() {
    if (!this.isJoined) {
      return;
    }
    this.destroyLocalStream();
    if (!this.isPublished) {
      this.handleUnPublish();
    }
    await this.shareClient.leave();
    this.isJoined = false;
    this.props.setState && this.props.setState('screenShare', false);
  }

  handleClientEvents() {
    this.shareClient.on('error', (error) => {
      console.error(error);
      alert(error);
    });
    this.shareClient.on('client-banned', (error) => {
      console.error(`client has been banned for ${error}`);
    });
  }

  handleStreamEvents() {
    this.localStream.on('player-state-changed', (event) => {
      console.log(`local stream ${event.type} player is ${event.state}`);
    });

    // 当用户通过浏览器自带的按钮停止屏幕分享时，会监听到 screen-sharing-stopped 事件
    this.localStream.on('screen-sharing-stopped', () => {
      console.log('share stream video track ended');
      this.updateStreamConfig && this.updateStreamConfig(this.relatedUserID, 'share-desk', false);
      this.handleLeave();
    });
  }

  render() {
    return (
     <div style={{ width: 0, height: 0 }}></div>
    );
  }
}
