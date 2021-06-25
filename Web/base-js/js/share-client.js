/* global $ TRTC */
class ShareClient {
  constructor(options) {
    this.sdkAppId_ = options.sdkAppId;
    this.userId_ = options.userId;
    this.userSig_ = options.userSig;
    this.roomId_ = options.roomId;
    this.privateMapKey_ = options.privateMapKey;

    this.isJoined_ = false;
    this.isPublished_ = false;
    this.localStream_ = null;

    this.client_ = TRTC.createClient({
      mode: 'rtc',
      sdkAppId: this.sdkAppId_,
      userId: this.userId_,
      userSig: this.userSig_
    });

    this.handleEvents();
  }

  async join() {
    if (this.isJoined_) {
      console.warn('duplicate RtcClient.join() observed');
      return;
    }
    // create a local stream for screen share
    this.localStream_ = TRTC.createStream({
      // disable audio as RtcClient already enable audio
      audio: false,
      // enable screen share
      screen: true,
      userId: this.userId_
    });

    try {
      // initialize the local stream to populate the screen stream
      await this.localStream_.initialize();
      console.log('ShareClient initialize local stream for screen share success');

      this.localStream_.on('player-state-changed', event => {
        console.log(`local stream ${event.type} player is ${event.state}`);
      });

      // 当用户通过浏览器自带的按钮停止屏幕分享时，会监听到 screen-sharing-stopped 事件
      this.localStream_.on('screen-sharing-stopped', event => {
        console.log('share stream video track ended');
        this.leave();
        $('#screen-btn').attr('src', './img/screen-off.png');
      });
    } catch (error) {
      console.error('fail to initialize share stream -', error);
      $('#screen-btn').attr('src', 'img/screen-off.png');
      switch (error.name) {
        case 'NotReadableError':
          alert('屏幕分享失败，请确保系统允许当前浏览器获取屏幕内容');
          return;
        case 'NotAllowedError':
          if (error.message === 'Permission denied by system') {
            alert('屏幕分享失败，请确保系统允许当前浏览器获取屏幕内容');
          } else {
            console.log('User refused to share the screen');
          }
          return;
        default:
          return;
      }
    }

    try {
      await this.client_.join({
        roomId: parseInt(this.roomId_)
      });
      console.log('ShareClient join room success');
      this.isJoined_ = true;
    } catch (error) {
      console.error('ShareClient join room failed! ' + error);
    }

    try {
      // publish the screen share stream
      await this.client_.publish(this.localStream_);
      this.isPublished_ = true;
    } catch (error) {
      console.error('ShareClient failed to publish local stream ' + error);
    }
  }

  async leave() {
    if (!this.isJoined_) {
      console.warn('leave() - please join() firstly');
      return;
    }
    if (this.isPublished_) {
      await this.client_.unpublish(this.localStream_);
      this.isPublished_ = false;
    }
    if (this.isJoined_) {
      await this.client_.leave();
      this.isJoined_ = false;
    }
    if (this.localStream_) {
      this.localStream_.close();
      this.localStream_ = null;
    }
  }

  handleEvents() {
    this.client_.on('error', err => {
      console.error(err);
      alert(err);
    });
    this.client_.on('client-banned', err => {
      console.error('client has been banned for ' + err);
    });
    // fired when a remote peer is joining the room
    this.client_.on('peer-join', evt => {
      const userId = evt.userId;
      console.log('peer-join ' + userId);
    });
    // fired when a remote peer is leaving the room
    this.client_.on('peer-leave', evt => {
      const userId = evt.userId;
      console.log('peer-leave ' + userId);
    });
    // fired when a remote stream is added
    this.client_.on('stream-added', evt => {
      const remoteStream = evt.stream;
      const id = remoteStream.getId();
      const userId = remoteStream.getUserId();
      console.log(`remote stream added: [${userId}] ID: ${id} type: ${remoteStream.getType()}`);
      console.log('subscribe to this remote stream');
      this.client_.unsubscribe(remoteStream);
    });
    // fired when a remote stream has been subscribed
    this.client_.on('stream-subscribed', evt => {
      const uid = evt.userId;
      const remoteStream = evt.stream;
      const id = remoteStream.getId();
      remoteStream.on('player-state-changed', event => {
        console.log(`${event.type} player is ${event.state}`);
      });
      console.log('stream-subscribed ID: ', id);
    });
    // fired when the remote stream is removed, e.g. the remote user called Client.unpublish()
    this.client_.on('stream-removed', evt => {
      const remoteStream = evt.stream;
      const id = remoteStream.getId();
      console.log(`stream-removed ID: ${id}  type: ${remoteStream.getType()}`);
    });

    this.client_.on('stream-updated', evt => {
      const remoteStream = evt.stream;
      console.log(
        'type: ' +
          remoteStream.getType() +
          ' stream-updated hasAudio: ' +
          remoteStream.hasAudio() +
          ' hasVideo: ' +
          remoteStream.hasVideo() +
          ' uid: ' +
          remoteStream.getUserId()
      );
    });

    this.client_.on('mute-audio', evt => {
      console.log(evt.userId + ' mute audio');
    });
    this.client_.on('unmute-audio', evt => {
      console.log(evt.userId + ' unmute audio');
    });
    this.client_.on('mute-video', evt => {
      console.log(evt.userId + ' mute video');
    });
    this.client_.on('unmute-video', evt => {
      console.log(evt.userId + ' unmute video');
    });
  }
}
