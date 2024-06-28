/* eslint object-curly-spacing: ["error", "always"] */

/* eslint-disable max-len */
/* eslint-disable no-unused-vars */

/* global sdkAppId TRTC genTestUserSig joinBtn addStreamView removeStreamView addSuccessLog addFailedLog reportSuccessEvent reportFailedEvent publishBtn startShareBtn */

class ShareClient {
  constructor(options) {
    const { sdkAppId, userId, roomId, secretKey } = options;
    this.sdkAppId = sdkAppId;
    this.userId = userId;
    this.secretKey = secretKey;
    this.roomId = roomId;

    this.client = null;
    this.localStream = null;

    this.isJoined = false;
    this.isPublished = false;

    this.initClient();
  }

  initClient() {
    const { userSig } = genTestUserSig({
      sdkAppId: this.sdkAppId,
      userId: this.userId,
      secretKey: this.secretKey,
    });

    try {
      this.client = TRTC.createClient({ mode: 'rtc', sdkAppId: this.sdkAppId, userId: this.userId, userSig });
      addSuccessLog(`Client [${this.userId}] created.`);
      this.installEventHandlers();
    } catch (e) {
      addFailedLog(`Failed to create Client [${this.userId}].`);
    }
  }

  async initLocalStream() {
    try {
      this.localStream = TRTC.createStream({
        audio: false,
        screen: true,
        userId: this.userId,
      });
      this.localStream.setScreenProfile({ width: 1920, height: 1080, frameRate: 15, bitrate: 2000 });
      await this.localStream.initialize();
      this.localStream.on('screen-sharing-stopped', (event) => {
        console.log('ShareStream video track ended');
        addSuccessLog('ShareStream video track ended');
        this.leave();
      });
    } catch (e) {
      addFailedLog(`ShareStream failed to initialize. Error: ${e.message_}`);
    }
  }

  // join room
  async join() {
    console.log('join room clicked');

    try {
      await this.client.join({ roomId: this.roomId });
      this.isJoined = true;

      try {
        await this.initLocalStream();
      } catch (error) {
        console.log('init local stream failed', error);
      }
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
      addSuccessLog('ShareStream is published successfully');
      this.isPublished = true;
      startShareBtn.disabled = true;
    } catch (error) {
      addFailedLog(`ShareStream is failed to publish. Error: ${error.message_}`);
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
      addSuccessLog('Unpublish ShareStream success');
    } catch (error) {
      console.error('unpublish failed', error);
      addFailedLog(`ShareStream is failed to unpublish. Error: ${error.message_}`);
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
      this.isJoined = false;
      addSuccessLog('Local share client leave room success');

      startShareBtn.disabled = false;
      if (this.localStream) {
        this.localStream.stop();
        this.localStream.close();
        this.localStream = null;
      }
    } catch (error) {
      console.error('leave failed', error);
      addFailedLog(`Leave room failed. Error: ${error.message_}`);
    }
  }

  installEventHandlers() {
    this.client.on('error', this.handleError.bind(this));
    this.client.on('client-banned', this.handleBanned.bind(this));
    this.client.on('peer-join', this.handlePeerJoin.bind(this));
    this.client.on('peer-leave', this.handlePeerLeave.bind(this));
    this.client.on('stream-added', this.handleStreamAdded.bind(this));
    this.client.on('stream-subscribed', this.handleStreamSubscribed.bind(this));
    this.client.on('stream-removed', this.handleStreamRemoved.bind(this));
    this.client.on('stream-updated', this.handleStreamUpdated.bind(this));
    this.client.on('connection-state-changed', this.handleConnection.bind(this));
  }


  handleError(error) {
    console.error('client error', error);
    alert(error);
  }

  handleBanned(event) {
    console.warn(`client has been banned for ${event.reason}`);
    alert('您已被踢出房间');
  }

  handlePeerJoin(event) {
    const { userId } = event;
    console.log(`peer-join ${userId}`);
  }

  handlePeerLeave(event) {
    const { userId } = event;
    console.log(`peer-leave ${userId}`);
  }

  handleStreamAdded(event) {
    const remoteStream = event.stream;
    const id = remoteStream.getId();
    const userId = remoteStream.getUserId();

    console.log(`remote stream added: [${userId}] ID: ${id} type: ${remoteStream.getType()}`);
  }

  handleStreamSubscribed(event) {
    const remoteStream = event.stream;
    const id = remoteStream.getId();
    const userId = remoteStream.getUserId();
    console.log(`remote stream subscribed: [${userId}] ID: ${id} type: ${remoteStream.getType()}`);

    this.client.unsubscribe(remoteStream);
  }

  handleStreamRemoved(event) {
    const remoteStream = event.stream;
    const id = remoteStream.getId();
    console.log(`remote stream removed: ID: ${id}`);
    console.log(`stream-removed ID: ${id}  type: ${remoteStream.getType()}`);
  }

  handleStreamUpdated(event) {
    const remoteStream = event.stream;
    console.log(`type: ${remoteStream.getType()} stream-updated hasAudio:${remoteStream.hasAudio()} hasVideo:${remoteStream.hasVideo()}`);
  }

  handleConnection(event) {
    console.log(`connection state changed: ${event.state}`);
  }
}
