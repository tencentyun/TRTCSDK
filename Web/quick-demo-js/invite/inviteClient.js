/* eslint object-curly-spacing: ["error", "always"] */

/* global TRTC genTestUserSig joinBtn addStreamView removeStreamView*/

// eslint-disable-next-line no-unused-vars
class Client {
  constructor(options) {
    const { sdkAppId, userId, userSig, roomId } = options;
    this.sdkAppId = sdkAppId;
    this.userId = userId;
    this.roomId = roomId;
    this.userSig = userSig;

    this.client = null;
    this.localStream = null;
    this.remoteStreams = [];

    this.isJoined = false;
    this.isPublished = false;

    this.audio = true;
    this.video = true;
    this.initClient();
  }

  initClient() {
    const { userSig } = this;

    try {
      this.client = TRTC.createClient({ mode: 'rtc', sdkAppId: this.sdkAppId, userId: this.userId, userSig });
      console.log(`Client [${this.userId}] created.`);
      this.installEventHandlers();
    } catch (e) {
      console.error(`Failed to create Client [${this.userId}].`);
    }
  }

  createShareLink() {
    const userId = String(Math.floor(Math.random() * 1000000));
    const { userSig } = genTestUserSig({
      sdkAppId: this.sdkAppId,
      userId: this.userId,
      secretKey: this.secretKey,
    });
    return `https://web.sdk.qcloud.com/trtc/webrtc/demo/quick/share.html?sdkAppId=${this.sdkAppId}&&userId=${userId}&&userSig=${userSig}`;
  }

  async initLocalStream() {
    try {
      this.localStream = TRTC.createStream({
        userId: this.userId,
        audio: true,
        video: true,
      });
      this.localStream.setVideoProfile('640p');
      try {
        await this.localStream.initialize();
        console.log(`LocalStream [${this.userId}] initialized`);

        this.localStream.play('local')
          .then(() => {
            this.addLocalControlView();
            console.log(`LocalStream [${this.userId}] playing`);
          })
          .catch((e) => {
            console.error(`LocalStream [${this.userId}] failed to play. Error: ${e.message_}`);
          });
      } catch (e) {
        console.error(`LocalStream failed to initialize. Error: ${e.message_}`);
      }
    } catch (e) {
      console.error(`${this.userId} failed to create LocalStream. Error: ${e.message_}`);
    }
  }

  // join room
  async join() {
    console.log('join room clicked');

    try {
      await this.client.join({ roomId: this.roomId });
      this.isJoined = true;
      joinBtn.disabled = true;
      console.log(`Join room [${this.roomId}] success`);
      try {
        await this.initLocalStream();
      } catch (error) {
        console.error('init LocalStream failed', error);
        console.error(`Init LocalStream failed. Error: ${error.message_}`);
      }
    } catch (e) {
      console.error('join room failed', e);
      console.error(`Join room ${this.roomId} failed, please check your params. Error: ${e.message_}`);
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
    } catch (error) {
      console.log('publish failed', error);
      console.error(`LocalStream is failed to publish. Error: ${error.message_}`);
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
    } catch (error) {
      console.error('unpublish failed', error);
      console.error(`LocalStream is failed to unpublish. Error: ${error.message_}`);
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
      joinBtn.disabled = false;
      if (this.localStream) {
        this.localStream.stop();
        this.localStream.close();
        this.localStream = null;
      }
      this.tag && this.tag.remove();
    } catch (error) {
      console.error('leave failed', error);
      console.error(`Leave room failed. Error: ${error.message_}`);
    }
  }

  addLocalControlView() {
    const local = document.getElementById('local');

    const tag = document.createElement('div');
    this.tag = tag;
    tag.className = 'tag';
    const audioDiv = document.createElement('div');
    audioDiv.setAttribute('id', 'mute-audio');
    if (this.audio) {
      audioDiv.setAttribute('class', 'unmuteAudio');
    } else {
      audioDiv.setAttribute('class', 'muteAudio');
    }

    const videoDiv = document.createElement('div');
    videoDiv.setAttribute('id', 'mute-video');
    if (this.video) {
      videoDiv.setAttribute('class', 'unmuteVideo');
    } else {
      videoDiv.setAttribute('class', 'muteVideo');
    }

    tag.appendChild(audioDiv);
    tag.appendChild(videoDiv);
    local.appendChild(tag);

    audioDiv.addEventListener('click', () => {
      if (this.audio) {
        this.localStream.muteAudio();
        console.log('LocalStream audio muted');
        audioDiv.setAttribute('class', 'muteAudio');
        this.audio = false;
      } else {
        this.localStream.unmuteAudio();
        console.log('LocalStream audio unmuted');
        audioDiv.setAttribute('class', 'unmuteAudio');
        this.audio = true;
      }
    });

    videoDiv.addEventListener('click', () => {
      if (this.video) {
        this.localStream.muteVideo();
        console.log('LocalStream video muted');
        videoDiv.setAttribute('class', 'muteVideo');
        this.video = false;
      } else {
        this.localStream.unmuteVideo();
        console.log('LocalStream video unmuted');
        videoDiv.setAttribute('class', 'unmuteVideo');
        this.video = true;
      }
    });
  }

  async switchDevice({ videoId, audioId }) {
    if (!this.isJoined) {
      console.warn('switchDevice() - please join() firstly');
      return;
    }
    if (videoId) {
      try {
        await this.localStream.switchDevice('video', videoId);
        console.log('Switch video device success');
      } catch (error) {
        console.error('switchDevice failed', error);
        console.error('Switch video device failed');
      }
    }
    if (audioId) {
      try {
        await this.localStream.switchDevice('audio', audioId);
        console.log('Switch audio device success');
      } catch (error) {
        console.error('switchDevice failed', error);
        console.error('Switch audio device failed');
      }
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
    this.client.on('mute-video', this.handleMuteVideo.bind(this));
    this.client.on('mute-audio', this.handleMuteAudio.bind(this));
    this.client.on('unmute-video', this.handleUnmuteVideo.bind(this));
    this.client.on('unmute-audio', this.handleUnmuteAudio.bind(this));
  }

  handleMuteVideo(event) {
    console.log(`[${event.userId}] mute video`);
  }

  handleMuteAudio(event) {
    console.log(`[${event.userId}] mute audio`);
  }

  handleUnmuteVideo(event) {
    console.log(`[${event.userId}] unmute video`);
  }

  handleUnmuteAudio(event) {
    console.log(`[${event.userId}] unmute audio`);
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
    if (userId !== 'local-screen') {
      console.log(`Peer Client [${userId}] joined`);
    }
  }

  handlePeerLeave(event) {
    const { userId } = event;
    console.log(`peer-leave ${userId}`);
    if (userId !== 'local-screen') {
      console.log(`[${userId}] leave`);
    }
  }

  handleStreamAdded(event) {
    const remoteStream = event.stream;
    const id = remoteStream.getId();
    const userId = remoteStream.getUserId();

    if (remoteStream.getUserId() === `share_${this.userId}`) {
      // don't need screen shared by us
      this.client.unsubscribe(remoteStream).catch((error) => {
        console.error('unsubscribe failed', error);
        console.error(`Unsubscribe [${userId}] failed`);
      });
    } else {
      console.log(`remote stream added: [${userId}] ID: ${id} type: ${remoteStream.getType()}`);
      this.client.subscribe(remoteStream).catch((error) => {
        console.error('subscribe failed', error);
        console.error(`Subscribe [${userId}] failed`);
      });
      console.log(`RemoteStream added: [${userId}]`);
    }
  }

  handleStreamSubscribed(event) {
    const remoteStream = event.stream;
    const id = remoteStream.getId();
    const userId = remoteStream.getUserId();
    const remoteId = `remote-${id}`;
    console.log(`remote stream subscribed: [${userId}] ID: ${id} type: ${remoteStream.getType()}`);
    console.log(`RemoteStream subscribed: [${userId}]`);
    addStreamView(remoteId);

    remoteStream.play(remoteId).then(() => {
      console.log(`play remote stream success: [${userId}] ID: ${id} type: ${remoteStream.getType()}`);
      console.log(`RemoteStream play success: [${userId}]`);
    })
      .catch((error) => {
        console.error('play remote stream failed', error);
        console.error(`RemoteStream play failed: [${userId}]`);
      });

    this.remoteStreams.push(remoteStream);
    remoteStream.on('player-state-changed', (event) => {
      // TODO: handle remote stream player state changed
    });
    console.log('stream-subscribed ID: ', id);
  }

  handleStreamRemoved(event) {
    const remoteStream = event.stream;
    const id = remoteStream.getId();
    const userId = remoteStream.getUserId();
    const remoteId = `remote-${id}`;
    remoteStream.stop();
    console.log(`remote stream removed:${userId}`);
    if (remoteStream.getUserId() !== `share_${this.userId}`) {
      console.log(`RemoteStream removed: [${userId}]`);
    }
    this.remoteStreams = this.remoteStreams.filter(stream => stream.getId() !== id);

    removeStreamView(remoteId);
    console.log(`stream-removed ID: ${id}  type: ${remoteStream.getType()}`);
  }

  handleStreamUpdated(event) {
    const remoteStream = event.stream;
    const userId = remoteStream.getUserId();

    console.log(`RemoteStream updated: [${userId}] audio:${remoteStream.hasAudio()} video:${remoteStream.hasVideo()}`);
    console.log(`type: ${remoteStream.getType()} stream-updated hasAudio:${remoteStream.hasAudio()} hasVideo:${remoteStream.hasVideo()}`);
  }

  handleConnection(event) {
    console.log(`connection state changed: ${event.state}`);
  }
}
