/* eslint-disable no-underscore-dangle */
import TRTC, {
  Client, LocalStream, RemoteStream,
} from 'trtc-js-sdk';
import { ElMessage } from 'element-plus/es';
import { genTestUserSig } from '@/utils/generateTestUserSig';
import { ClientOptions } from '@/types/type';

class LocalClient {
  private sdkAppId: number;

  private userId: string;

  private secretKey: string;

  private roomId: number;

  private userSig: string;

  private client: Client;

  private localStream: LocalStream;

  private isJoined: boolean;

  private isPublished: boolean;

  private remoteStreams: RemoteStream[];

  private video: boolean;

  private audio: boolean;

  private cameraId: any;

  private microphoneId: any;

  constructor(options: ClientOptions) {
    const {
      sdkAppId, userId, roomId, secretKey, userSig,
    } = options;
    this.sdkAppId = sdkAppId;
    this.userId = userId;
    this.secretKey = secretKey;
    this.userSig = userSig;
    this.roomId = roomId;

    this.client = null;
    this.localStream = null;
    this.remoteStreams = [];

    this.isJoined = false;
    this.isPublished = false;

    this.cameraId = '';
    this.microphoneId = '';

    this.video = true;
    this.audio = true;

    this.initClient();
  }

  initClient() {
    const userSig = this.userSig || genTestUserSig({
      sdkAppId: this.sdkAppId,
      userId: this.userId,
      secretKey: this.secretKey,
    }).userSig;

    try {
      this.client = TRTC.createClient({
        mode: 'rtc', sdkAppId: this.sdkAppId, userId: this.userId, userSig,
      });
      console.log(`Client [${this.userId}] created.`);
      this.installEventHandlers();
    } catch (e) {
      console.log(`Failed to create Client [${this.userId}].`);
    }
  }

  createShareLink() {
    const userId = String(Math.floor(Math.random() * 1000000));
    const { userSig } = genTestUserSig({
      sdkAppId: this.sdkAppId,
      userId,
      secretKey: this.secretKey,
    });
    const { origin } = window.location;
    const pathname = window.location.pathname.replace('index.html', 'invite/invite.html');
    return `${origin}${pathname}?userSig=${userSig}&&SDKAppId=${this.sdkAppId}&&userId=${userId}&&roomId=${this.roomId}`;
  }

  async initLocalStream() {
    try {
      this.localStream = TRTC.createStream({
        userId: this.userId,
        audio: true,
        video: true,
        cameraId: this.cameraId,
        microphoneId: this.microphoneId,
      });
      this.localStream.setVideoProfile('480p');
      try {
        await this.localStream.initialize();
        console.log(`LocalStream [${this.userId}] initialized`);
      } catch (e: any) {
        console.log(`LocalStream failed to initialize. Error: ${e.message_}`);
      }
    } catch (e: any) {
      console.log(`${this.userId} failed to create LocalStream. Error: ${e.message_}`);
    }
  }

  // join room
  async join() {
    console.log('join room clicked');

    try {
      await this.client.join({ roomId: this.roomId });
      this.isJoined = true;
      console.log(`Join room [${this.roomId}] success`);
      try {
        await this.initLocalStream();
      } catch (error: any) {
        console.log(`Init LocalStream failed. Error: ${error.message_}`);
      }
    } catch (e: any) {
      console.log(`Join room ${this.roomId} failed, please check your params. Error: ${e.message_}`);
    }
  }

  async publish() {
    if (!this.isJoined) {
      console.warn('call publish()- please join() firstly');
      return;
    }
    if (this.isPublished) {
      console.warn('duplicate publish() observed');
      return;
    }
    if (!this.localStream) {
      return;
    }
    try {
      await this.client.publish(this.localStream);
      this.isPublished = true;
      console.log('LocalStream is published successfully');
    } catch (error: any) {
      console.log(`LocalStream is failed to publish. Error: ${error.message_}`);
    }
  }

  async unpublish() {
    if (!this.isJoined) {
      console.warn('unpublish() - please join() firstly');
      return;
    }
    if (!this.isPublished) {
      console.warn('call unpublish() - you have not published yet');
      return;
    }
    try {
      await this.client.unpublish(this.localStream);
      this.isPublished = false;
      console.log('Unpublish localStream success');
    } catch (error: any) {
      console.log(`LocalStream is failed to unpublish. Error: ${error.message_}`);
    }
  }

  async leave() {
    if (!this.isJoined) {
      console.warn('leave() - please join() firstly');
      return;
    }
    await this.unpublish();
    try {
      await this.client.leave();
      console.log('Leave room success');
      this.isJoined = false;
      if (this.localStream) {
        this.localStream.stop();
        this.localStream.close();
        this.localStream = null;
      }
    } catch (error: any) {
      console.error('leave failed', error);
      console.log(`Leave room failed. Error: ${error.message_}`);
    }
  }

  async switchDevice({ videoId, audioId }: { videoId: string, audioId: string }) {
    if (!this.isJoined) {
      return;
    }
    if (videoId) {
      try {
        await this.localStream.switchDevice('video', videoId);
        console.log('Switch video device success');
      } catch (error: any) {
        console.error('switchDevice failed', error);
        console.log('Switch video device failed');
      }
    }
    if (audioId) {
      try {
        await this.localStream.switchDevice('audio', audioId);
        console.log('Switch audio device success');
      } catch (error: any) {
        console.error('switchDevice failed', error);
        console.log('Switch audio device failed');
      }
    }
  }

  installEventHandlers() {
    this.client.on('error', this.handleError.bind(this));
    this.client.on('client-banned', this.handleBanned.bind(this));
    this.client.on('peer-join', this.handlePeerJoin.bind(this));
    this.client.on('peer-leave', this.handlePeerLeave.bind(this));
    this.client.on('stream-added', this.handleStreamAdded.bind(this));
    this.client.on('stream-updated', this.handleStreamUpdated.bind(this));
    this.client.on('connection-state-changed', this.handleConnection.bind(this));
    this.client.on('mute-video', this.handleMuteVideo.bind(this));
    this.client.on('mute-audio', this.handleMuteAudio.bind(this));
    this.client.on('unmute-video', this.handleUnmuteVideo.bind(this));
    this.client.on('unmute-audio', this.handleUnmuteAudio.bind(this));
  }

  handleMuteVideo(event: any) {
    console.log(`[${event.userId}] mute video`);
  }

  handleMuteAudio(event: any) {
    console.log(`[${event.userId}] mute audio`);
  }

  handleUnmuteVideo(event: any) {
    console.log(`[${event.userId}] unmute video`);
  }

  handleUnmuteAudio(event: any) {
    console.log(`[${event.userId}] unmute audio`);
  }

  handleError(error: any) {
    ElMessage({ message: error.message_, type: 'error' });
    console.log(`RTCError: ${error.message_}`);
  }

  handleBanned(error: any) {
    console.error(`client has been banned for ${error}`);
  }

  handlePeerJoin(event: any) {
    const { userId } = event;
    if (userId !== 'local-screen') {
      console.log(`Peer Client [${userId}] joined`);
    }
  }

  handlePeerLeave(event: any) {
    const { userId } = event;
    if (userId !== 'local-screen') {
      console.log(`[${userId}] leave`);
    }
  }

  handleStreamAdded(event: any) {
    const remoteStream = event.stream;
    const id = remoteStream.getId();
    const userId = remoteStream.getUserId();

    if (remoteStream.getUserId() === `share_${this.userId}`) {
      // don't need screen shared by us
      this.client.unsubscribe(remoteStream).catch(() => {
        console.log(`Unsubscribe [${userId}] failed`);
      });
    } else {
      console.log(`remote stream added: [${userId}] ID: ${id} type: ${remoteStream.getType()}`);
      this.client.subscribe(remoteStream).catch(() => {
        console.log(`Subscribe [${userId}] failed`);
      });
      console.log(`RemoteStream added: [${userId}]`);
    }
  }

  handleStreamSubscribed(event: any) {
    const remoteStream = event.stream;
    const id = remoteStream.getId();
    const userId = remoteStream.getUserId();
    console.log(`RemoteStream subscribed: [${userId}]`);

    this.remoteStreams.push(remoteStream);
    console.log('stream-subscribed ID: ', id);
  }

  handleStreamRemoved(event: any) {
    const remoteStream = event.stream;
    const id = remoteStream.getId();
    const userId = remoteStream.getUserId();
    remoteStream.stop();
    if (remoteStream.getUserId() !== `share_${this.userId}`) {
      console.log(`RemoteStream removed: [${userId}]`);
    }
    this.remoteStreams = this.remoteStreams.filter((stream) => stream.getId() !== id);
  }

  handleStreamUpdated(event: any) {
    const remoteStream = event.stream;
    const userId = remoteStream.getUserId();

    console.log(`RemoteStream updated: [${userId}] audio:${remoteStream.hasAudio()} video:${remoteStream.hasVideo()}`);
  }

  handleConnection(event: any) {
    console.log(`connection state changed: ${event.state}`);
  }

  getClient() {
    return this.client;
  }

  getLocalStream() {
    return this.localStream;
  }
}

export default LocalClient;
