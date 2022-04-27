import TRTC, { Client, LocalStream } from 'trtc-js-sdk';
import { genTestUserSig } from '@/utils/generateTestUserSig';
import { ClientOptions } from '@/types/type';

class ShareClient {
  private sdkAppId: number;

  private userId: string;

  private secretKey: string;

  private roomId: number;

  private client: Client;

  private localStream: LocalStream;

  private isJoined: boolean;

  private isPublished: boolean;

  private isLeaving: boolean;

  constructor(options: ClientOptions) {
    const {
      sdkAppId, userId, roomId, secretKey,
    } = options;

    this.sdkAppId = sdkAppId;
    this.userId = userId;
    this.secretKey = secretKey;
    this.roomId = roomId;

    this.isJoined = false;
    this.isPublished = false;
    this.isLeaving = false;

    this.initClient();
  }

  initClient() {
    const { userSig } = genTestUserSig({
      sdkAppId: this.sdkAppId,
      userId: this.userId,
      secretKey: this.secretKey,
    });

    try {
      this.client = TRTC.createClient({
        mode: 'rtc',
        sdkAppId: this.sdkAppId,
        userId: this.userId,
        userSig,
      });
      console.log(`Client [${this.userId}] created.`);
      this.installEventHandlers();
    } catch (e) {
      console.error(`Failed to create Client [${this.userId}].`);
    }
  }

  async initLocalStream() {
    try {
      this.localStream = TRTC.createStream({
        audio: false,
        screen: true,
        userId: this.userId,
      });
      this.localStream.setScreenProfile({
        width: 960,
        height: 540,
        frameRate: 15,
        bitrate: 2000,
      });
      await this.localStream.initialize();
      this.localStream.on('screen-sharing-stopped', () => {
        console.log('ShareStream video track ended');
        this.leave();
      });
      return this.localStream;
    } catch (error: any) {
      console.error(`ShareStream failed to initialize. Error: ${error}`);
      return null;
    }
  }

  // join room
  async join() {
    console.log('join room clicked');

    try {
      await this.client.join({ roomId: this.roomId });
      await this.initLocalStream();
      this.isJoined = true;
    } catch (e) {
      console.error('join room failed', e);
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
    try {
      await this.client.publish(this.localStream);
      console.log('ShareStream is published successfully');
      this.isPublished = true;
    } catch (error: any) {
      console.error(`ShareStream is failed to publish. Error: ${error}`);
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
      if (this.localStream) {
        await this.client.unpublish(this.localStream);
      }
      this.isPublished = false;
      console.log('Unpublish ShareStream success');
    } catch (error) {
      console.error('unpublish failed', error);
    }
  }

  async leave() {
    if (!this.isJoined) {
      console.warn('leave() - please join() firstly');
      return;
    }
    if (this.isLeaving) {
      console.warn('duplicate leave() observed');
      return;
    }
    if (this.isPublished) {
      await this.unpublish();
    }
    try {
      this.isLeaving = true;

      await this.client.leave();
      this.isJoined = false;
      console.log('Local share client leave room success');

      if (this.localStream) {
        this.localStream.stop();
        this.localStream.close();
        this.localStream = null;
      }
      this.isLeaving = false;
    } catch (error) {
      console.error('leave failed', error);
    }
  }

  installEventHandlers() {
    this.client.on('error', this.handleError.bind(this));
    this.client.on('client-banned', this.handleBanned.bind(this));
    this.client.on('stream-subscribed', this.handleStreamSubscribed.bind(this));
  }

  handleError(error: any) {
    console.error('client error', error);
  }

  handleBanned(error: any) {
    console.error(`client has been banned for ${error}`);
  }

  handleStreamSubscribed(event: any) {
    const remoteStream = event.stream;
    const id = remoteStream.getId();
    const userId = remoteStream.getUserId();
    console.log(`remote stream subscribed: [${userId}] ID: ${id} type: ${remoteStream.getType()}`);

    this.client.unsubscribe(remoteStream);
  }
}

export default ShareClient;
