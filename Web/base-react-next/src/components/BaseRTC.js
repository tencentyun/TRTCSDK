import a18n from 'a18n';
import React from 'react';
import TRTC from 'trtc-js-sdk';
import { isUndefined, joinRoomUpload, publishUpload } from '@utils/utils';
import { getLatestUserSig } from '@app/index';
import { SDKAPPID } from '@app/config';
import toast from '@components/Toast';

export default class RTC extends React.Component {
  constructor(props) {
    super(props);
    this.userID = props.userID;
    this.roomID = props.roomID;
    this.useStringRoomID = props.useStringRoomID;
    this.cameraID = props.cameraID;
    this.microphoneID = props.microphoneID;
    this.setState = props.setState;
    this.addUser = props.addUser;
    this.removeUser = props.removeUser;
    this.addStream = props.addStream;
    this.updateStream = props.updateStream;
    this.updateStreamConfig = props.updateStreamConfig;
    this.removeStream = props.removeStream;
    this.mode = props.mode;
    this.audio = props.audio;
    this.video = props.video;
    this.localStream = null,
    this.remoteStreamList = [],
    this.client = null;
    this.shareClient = null;
    this.isJoining = false;
    this.isJoined = false;
    this.isPublishing = false;
    this.isPublished = false;
    this.isUnPublishing = false;
    this.isLeaving = false;
    this.userSig = '';
    this.privateMapKey = 255;
    this.mirror = true;
    this.dom = null;
    global.$TRTC = TRTC;
  }

  // eslint-disable-next-line camelcase
  async UNSAFE_componentWillReceiveProps(props) {
    if (this.userID !== props.userID) {
      this.userID = props.userID;
    }
    this.roomID = props.roomID;
    this.useStringRoomID = props.useStringRoomID;
    this.cameraID = props.cameraID;
    this.microphoneID = props.microphoneID;
    this.setState = props.setState;
    this.addStream = props.addStream;
    this.removeStream = props.removeStream;
    this.updateStream = props.updateStream;
    this.updateStreamConfig = props.updateStreamConfig;
    this.mode = props.mode;
    this.audio = props.audio;
    this.video = props.video;
  }

  async componentDidMount() {
    this.props.onRef(this);

    const checkResult = await TRTC.checkSystemRequirements();
    if (!checkResult.result) {
      alert(a18n('当前浏览器不支持 WebRTC SDK, 请更换其他浏览器'));
    }

    const that = this;
    window.addEventListener('beforeunload', (event) => {
      if (that.isJoined) {
        event.preventDefault();
        // eslint-disable-next-line no-param-reassign
        event.returnValue = 'Are you sure you want to close';
      }
    });
  }

  async componentWillUnmount() {
    this.handleLeave();
  }

  async getUserSig() {
    const { userSig, privateMapKey } = await getLatestUserSig(this.userID);
    this.userSig = userSig;
    this.privateMapKey = privateMapKey;
  }

  // 初始化客户端
  async initClient() {
    await this.getUserSig();

    this.client = TRTC.createClient({
      mode: this.mode,
      sdkAppId: SDKAPPID,
      userId: this.userID,
      userSig: this.userSig,
      useStringRoomId: this.useStringRoomID,
    });
    this.handleClientEvents();
    return this.client;
  }

  async initLocalStream() {
    this.localStream = TRTC.createStream({
      audio: this.audio,
      video: this.video,
      userId: this.userID,
      cameraId: this.cameraID,
      microphoneId: this.microphoneID,
      mirror: this.mirror,
    });
    try {
      await this.localStream.initialize();
      this.addStream && this.addStream(this.localStream);
      return this.localStream;
    } catch (error) {
      this.localStream = null;
      alert(`${JSON.stringify(error.message)}`);
    }
  }

  destroyLocalStream() {
    this.removeStream && this.removeStream(this.localStream);
    this.localStream && this.localStream.stop();
    this.localStream && this.localStream.close();
    this.localStream = null;
    this.dom = null;
  }

  playStream(stream, dom) {
    if (stream.getType() === 'main' && stream.getUserId().indexOf('share') >= 0) {
      stream.play(dom, { objectFit: 'contain' }).catch();
    } else {
      stream.play(dom).catch();
      if (stream === this.localStream) {
        this.dom = dom;
      }
    }
  }

  resumeStream(stream) {
    stream.resume();
  }

  async handleJoin() {
    if (this.isJoining || this.isJoined) {
      return;
    }
    this.isJoining = true;
    await this.initClient();
    try {
      await this.client.join({ roomId: this.roomID });
      toast.success('join room success!', 2000);
      joinRoomUpload(SDKAPPID);

      this.isJoining = false;
      this.isJoined = true;
      this.setState && this.setState('join', this.isJoined);
      this.addUser && this.addUser(this.userID, 'local');

      this.startGetAudioLevel();
    } catch (error) {
      this.isJoining = false;
      toast.error('join room failed!', 20000);
      console.error('join room failed', error);
    }
  }

  async handlePublish() {
    if (!this.isJoined || this.isPublishing || this.isPublished) {
      return;
    }
    this.isPublishing = true;
    !this.localStream && (await this.initLocalStream());
    try {
      await this.client.publish(this.localStream);
      toast.success('publish localStream success!', 2000);
      publishUpload(SDKAPPID);

      this.isPublishing = false;
      this.isPublished = true;
      this.setState && this.setState('publish', this.isPublished);
    } catch (error) {
      this.isPublishing = false;
      console.error('publish localStream failed', error);
      toast.error('publish localStream failed!', 2000);
    }
  }

  async handleUnPublish() {
    if (!this.isPublished || this.isUnPublishing) {
      return;
    }
    this.isUnPublishing = true;
    try {
      await this.client.unpublish(this.localStream);
      toast.success('unpublish localStream success!', 2000);

      this.isUnPublishing = false;
      this.isPublished = false;
      this.setState && this.setState('publish', this.isPublished);
    } catch (error) {
      this.isUnPublishing = false;
      console.error('unpublish localStream failed', error);
      switch (error.getCode()) {
        case 4096: // ErrorCode = 0x1001 INVALID_OPERATION
          toast.error('stream has not been published yet, please publish first', 2000);
          break;
        case 4097: // ErrorCode = 0x1001 INVALID_PARAMETER
          toast.error('publish is ongoing, please try unpublish later', 2000);
          break;
        default:
          toast.error('unpublish localStream failed! please try again later', 2000);
          break;
      }
    }
    this.localStream && (await this.destroyLocalStream());
  }

  async handleSubscribe(remoteStream, config = { audio: true, video: true }) {
    try {
      await this.client.subscribe(remoteStream, {
        audio: isUndefined(config.audio) ? true : config.audio,
        video: isUndefined(config.video) ? true : config.video,
      });
    } catch (error) {
      console.error(`subscribe ${remoteStream.getUserId()} with audio: ${config.audio} video: ${config.video} error`, error);
      toast.error(`subscribe ${remoteStream.getUserId()} failed!`, 2000);
    }
  }

  async handleUnSubscribe(remoteStream) {
    try {
      await this.client.unsubscribe(remoteStream);
    } catch (error) {
      console.error(`unsubscribe ${remoteStream.getUserId()} error`, error);
      toast.error(`unsubscribe ${remoteStream.getUserId()} failed!`, 2000);
    }
  }

  async handleLeave() {
    if (!this.isJoined || this.isLeaving) {
      return;
    }
    this.isLeaving = true;
    this.stopGetAudioLevel();
    if (this.isPublished) {
      await this.handleUnPublish();
    }
    try {
      await this.client.leave();
      toast.success('leave room success', 2000);

      this.removeUser && this.removeUser(this.userID, 'local');

      this.isLeaving = false;
      this.isJoined = false;
      this.setState && this.setState('join', this.isJoined);
    } catch (error) {
      this.isLeaving = false;
      console.error('leave room error', error);
      toast.error('leave room error', 2000);
    }
  }

  handleStartPublishCDNStream() {
    this.client.startPublishCDNStream();
  }

  handleSopPublishCDNStream() {
    this.client.handleSopPublishCDNStream();
  }

  handleStartMixTranscode(otherRoomID, otherRoomUserID) {
    const mixTranscodeConfig = {
      videoWidth: 1280,
      videoHeight: 480,
      videoBitrate: 1500,
      videoFramerate: 15,
      mixUsers: [
        {
          userId: this.userID,
          roomId: this.roomID, // roomId 字段自 v4.11.5 版本开始支持，支持跨房间混流
          pureAudio: false,
          width: 640,
          height: 480,
          locationX: 0,
          locationY: 0,
          streamType: 'main', // 指明该配置为远端主流
          zOrder: 1,
        },
        {
          userId: otherRoomUserID,
          roomId: otherRoomID, // roomId 字段自 v4.11.5 版本开始支持，支持跨房间混流
          pureAudio: false,
          width: 640,
          height: 480,
          locationX: 640,
          locationY: 0,
          streamType: 'main', // 指明该配置为远端辅流
          zOrder: 1,
        },
      ],
    };
    this.client.startMixTranscode(mixTranscodeConfig);
  }

  handleStopMixTranscode() {
    this.client.stopMixTranscode();
  }

  muteVideo() {
    this.localStream.muteVideo();
  }

  muteAudio() {
    this.localStream.muteAudio();
  }

  unmuteVideo() {
    this.localStream.unmuteVideo();
  }

  unmuteAudio() {
    this.localStream.unmuteAudio();
  }

  startGetAudioLevel() {
    // 文档：https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/module-ClientEvent.html#.AUDIO_VOLUME
    this.client.on('audio-volume', (event) => {
      event.result.forEach(({ userId, audioVolume }) => {
        if (audioVolume > 2) {
          console.log(`user: ${userId} is speaking, audioVolume: ${audioVolume}`);
          this.updateStreamConfig && this.updateStreamConfig(userId, 'audio-volume', audioVolume);
        } else {
          this.updateStreamConfig && this.updateStreamConfig(userId, 'audio-volume', 0);
        }
      });
    });
    this.client.enableAudioVolumeEvaluation(200);
  }

  stopGetAudioLevel() {
    this.client && this.client.enableAudioVolumeEvaluation(-1);
  }

  handleStreamEvents(stream) {
    stream.on('error', (error) => {
      const errorCode = error.getCode();
      if (errorCode === 0x4043) {
        // PLAY_NOT_ALLOWED,引导用户手势操作并调用 stream.resume 恢复音视频播放
        this.updateStreamConfig && this.updateStreamConfig(stream.getUserId(), 'resume-stream');
      }
    });
  }

  handleClientEvents() {
    this.client.on('error', (error) => {
      console.error(error);
      alert(error);
    });
    this.client.on('client-banned', async (error) => {
      console.error(`client has been banned for ${error}`);

      this.isPublished = false;
      this.localStream = null;
      this.setState && this.setState('publish', this.isPublished);
      await this.handleLeave();

      alert(error);
    });
    // fired when a remote peer is joining the room
    this.client.on('peer-join', (event) => {
      const { userId } = event;
      console.log(`peer-join ${userId}`, event);
      this.addUser && this.addUser(userId);
    });
    // fired when a remote peer is leaving the room
    this.client.on('peer-leave', (event) => {
      const { userId } = event;
      console.log(`peer-leave ${userId}`, event);
      this.removeUser && this.removeUser(userId);
    });

    // fired when a remote stream is added
    this.client.on('stream-added', (event) => {
      const { stream: remoteStream } = event;
      const remoteUserID = remoteStream.getUserId();
      if (remoteUserID === `share_${this.userID}`) {
        // don't need screen shared by us
        this.handleUnSubscribe(remoteStream);
      } else {
        console.log(`remote stream added: [${remoteUserID}] type: ${remoteStream.getType()}`);
        // subscribe to this remote stream
        this.handleSubscribe(remoteStream);
      }
    });
    // fired when a remote stream has been subscribed
    this.client.on('stream-subscribed', (event) => {
      const { stream: remoteStream } = event;
      console.log('stream-subscribed userId: ', remoteStream.getUserId());
      this.addStream && this.addStream(remoteStream);
    });
    // fired when the remote stream is removed, e.g. the remote user called Client.unpublish()
    this.client.on('stream-removed', (event) => {
      const { stream: remoteStream } = event;
      remoteStream.stop();
      this.removeStream && this.removeStream(remoteStream);
      console.log(`stream-removed userId: ${remoteStream.getUserId()} type: ${remoteStream.getType()}`);
    });

    this.client.on('stream-updated', (event) => {
      const { stream: remoteStream } = event;
      this.updateStream && this.updateStream(remoteStream);
      console.log(`type: ${remoteStream.getType()} stream-updated hasAudio: ${remoteStream.hasAudio()} hasVideo: ${remoteStream.hasVideo()}`);
    });

    this.client.on('mute-audio', (event) => {
      const { userId } = event;
      console.log(`${userId} mute audio`);
      this.updateStreamConfig && this.updateStreamConfig(userId, 'mute-audio');
    });
    this.client.on('unmute-audio', (event) => {
      const { userId } = event;
      console.log(`${userId} unmute audio`);
      this.updateStreamConfig && this.updateStreamConfig(userId, 'unmute-audio');
    });
    this.client.on('mute-video', (event) => {
      const { userId } = event;
      console.log(`${userId} mute video`);
      this.updateStreamConfig && this.updateStreamConfig(userId, 'mute-video');
    });
    this.client.on('unmute-video', (event) => {
      const { userId } = event;
      console.log(`${userId} unmute video`);
      this.updateStreamConfig && this.updateStreamConfig(userId, 'unmute-video');
    });

    this.client.on('connection-state-changed', (event) => {
      console.log(`RtcClient state changed to ${event.state} from ${event.prevState}`);
    });

    this.client.on('network-quality', (event) => {
      const { uplinkNetworkQuality, downlinkNetworkQuality } = event;
      console.log(`network-quality uplinkNetworkQuality: ${uplinkNetworkQuality}, downlinkNetworkQuality: ${downlinkNetworkQuality}`);
      this.updateStreamConfig && this.updateStreamConfig(this.userID, 'uplink-network-quality', uplinkNetworkQuality);
      this.updateStreamConfig && this.updateStreamConfig(this.userID, 'downlink-network-quality', downlinkNetworkQuality);
    });
  }

  render() {
    return (
     <div style={{ width: 0, height: 0 }}></div>
    );
  }
}
