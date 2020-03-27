/* eslint-disable require-jsdoc */

class RtcClient {
  constructor(options) {
    this.sdkAppId_ = options.sdkAppId;
    this.userId_ = options.userId;
    this.userSig_ = options.userSig;
    this.roomId_ = options.roomId;

    this.isJoined_ = false;
    this.isPublished_ = false;
    this.localStream_ = null;
    this.remoteStreams_ = [];

    // check if browser is compatible with TRTC
    TRTC.checkSystemRequirements().then(result => {
      if (!result) {
        alert('Your browser is not compatible with TRTC! Please download Chrome M72+');
      }
    });
  }

  async join() {
    if (this.isJoined_) {
      console.warn('duplicate RtcClient.join() observed');
      return;
    }

    // create a client for RtcClient
    this.client_ = TRTC.createClient({
      mode: 'videoCall', // 实时通话模式
      sdkAppId: this.sdkAppId_,
      userId: this.userId_,
      userSig: this.userSig_
    });

    // 处理 client 事件
    this.handleEvents();

    try {
      // join the room
      await this.client_.join({ roomId: this.roomId_ });
      console.log('join room success');
      Toast.notify('进房成功！');
      this.isJoined_ = true;
    } catch (error) {
      console.error('failed to join room because: ' + error);
      alert(
        '进房失败原因：' +
          error +
          '\r\n\r\n请确保您的网络连接是正常的，您可以先体验一下我们的Demo以确保网络连接是正常的：' +
          '\r\n https://trtc-1252463788.file.myqcloud.com/web/demo/official-demo/index.html ' +
          '\r\n\r\n另外，请确保您的账号信息是正确的。' +
          '\r\n请打开链接：https://cloud.tencent.com/document/product/647/34342 查询详细错误信息！'
      );
      Toast.error('进房错误！');
      return;
    }

    try {
      // 采集摄像头和麦克风视频流
      await this.createLocalStream({ audio: true /*采集麦克风*/, video: true /*采集摄像头*/ });
      Toast.info('摄像头及麦克风采集成功！');
      console.log('createLocalStream with audio/video success');
    } catch (error) {
      console.error('createLocalStream with audio/video failed: ' + error);
      // **注意：**
      // 请务必处理外设访问错误，根据您的业务逻辑来选择正确的错误处理逻辑。
      switch (error.name) {
        case 'NotReadableError':
          // 当系统或浏览器异常的时候，可能会出现此错误，您可能需要引导用户重启电脑/浏览器来尝试恢复。
          alert('暂时无法访问摄像头/麦克风，请确保当前没有其他应用请求访问摄像头/麦克风，并重试');
          return;
        case 'NotAllowedError':
          // 用户拒绝授权访问摄像头或麦克风 | 屏幕分享，您需要引导客户来授权访问
          alert('用户已拒绝授权访问摄像头或麦克风 | 屏幕分享');
          return;
        case 'NotFoundError':
          // 找不到摄像头或麦克风设备
          alert('找不到摄像头或麦克风设备');
          return;
        case 'OverConstrainedError':
          alert(
            '采集属性设置错误，如果您指定了 cameraId/microphoneId，请确保它们是一个有效的非空字符串'
          );
          return;
        default:
          alert('未知错误');
          return;
      }
    }

    this.localStream_.on('player-state-changed', event => {
      console.log(`local stream ${event.type} player is ${event.state}`);
      if (event.type === 'video' && event.state === 'PLAYING') {
        // dismiss the remote user UI placeholder
      } else if (event.type === 'video' && event.state === 'STOPPPED') {
        // show the remote user UI placeholder
      }
    });

    // 在名为 ‘local_stream’ 的 div 容器上播放本地音视频
    this.localStream_.play('local_stream');

    // publish local stream by default after join the room
    await this.publish();
    Toast.notify('发布本地流成功！');
  }

  async leave() {
    if (!this.isJoined_) {
      console.warn('leave() - leave without join()d observed');
      Toast.error('请先加入房间！');
      return;
    }

    if (this.isPublished_) {
      // ensure the local stream has been unpublished before leaving.
      await this.unpublish(true);
    }

    try {
      // leave the room
      await this.client_.leave();
      Toast.notify('退房成功！');
      this.isJoined_ = false;
    } catch (error) {
      console.error('failed to leave the room because ' + error);
      location.reload();
    } finally {
      // 停止本地流，关闭本地流内部的音视频播放器
      this.localStream_.stop();
      // 关闭本地流，释放摄像头和麦克风访问权限
      this.localStream_.close();
      this.localStream_ = null;
    }
  }

  async publish() {
    if (!this.isJoined_) {
      Toast.error('请先加入房间再点击开始推流！');
      console.warn('publish() - please join() firstly');
      return;
    }
    if (this.isPublished_) {
      console.warn('duplicate RtcClient.publish() observed');
      Toast.error('当前正在推流！');
      return;
    }
    try {
      // 发布本地流
      await this.client_.publish(this.localStream_);
      Toast.info('发布本地流成功！');
      this.isPublished_ = true;
    } catch (error) {
      console.error('failed to publish local stream ' + error);
      Toast.error('发布本地流失败！');
      this.isPublished_ = false;
    }
  }

  async unpublish(isLeaving) {
    if (!this.isJoined_) {
      console.warn('unpublish() - please join() firstly');
      Toast.error('请先加入房间再停止推流！');
      return;
    }
    if (!this.isPublished_) {
      console.warn('RtcClient.unpublish() called but not published yet');
      Toast.error('当前尚未发布本地流！');
      return;
    }

    try {
      // 停止发布本地流
      await this.client_.unpublish(this.localStream_);
      this.isPublished_ = false;
      Toast.info('停止发布本地流成功！');
    } catch (error) {
      console.error('failed to unpublish local stream because ' + error);
      Toast.error('停止发布本地流失败！');
      if (!isLeaving) {
        console.warn('leaving the room because unpublish failure observed');
        Toast.error('停止发布本地流失败，退出房间！');
        this.leave();
      }
    }
  }

  async createLocalStream(options) {
    this.localStream_ = TRTC.createStream({
      audio: options.audio, // 采集麦克风
      video: options.video, // 采集摄像头
      userId: this.userId_
      // 由于浏览器的安全限制，某些特殊场景下获取的 cameraId/microphoneId 可能是无效的空字符串，此时会导致
      // localStream.initialize() 返回 OverConstrainedError 错误。所以，如果要指定 cameraId/microphoneId
      // 请先确保它们的值是有效的非空字符串。
      // cameraId: getCameraId(),
      // microphoneId: getMicrophoneId()
    });
    // 设置视频分辨率帧率和码率
    this.localStream_.setVideoProfile('480p');

    await this.localStream_.initialize();
  }

  handleEvents() {
    // 处理 client 错误事件，错误均为不可恢复错误
    // 建议提示用户后刷新页面或者调用 client.leave() 后再调用 client.join() 重新进房
    this.client_.on('error', err => {
      console.error(err);
      alert(err);
      Toast.error('客户端错误：' + err);
      // location.reload();
    });

    // 处理用户被踢事件，通常是因为房间内有同名用户引起，这种问题一般是应用层逻辑错误引起的
    // 应用层请尽量使用不同用户ID进房
    this.client_.on('client-banned', err => {
      console.error('client has been banned for ' + err);
      Toast.error('用户被踢出房间！');
      // location.reload();
    });

    // 远端用户进房通知 - 仅限主动推流用户
    this.client_.on('peer-join', evt => {
      const userId = evt.userId;
      console.log('peer-join ' + userId);
      Toast.notify('远端用户进房 - ' + userId);
    });
    // 远端用户退房通知 - 仅限主动推流用户
    this.client_.on('peer-leave', evt => {
      const userId = evt.userId;
      console.log('peer-leave ' + userId);
      Toast.notify('远端用户退房 - ' + userId);
    });

    // 处理远端流增加事件
    this.client_.on('stream-added', evt => {
      const remoteStream = evt.stream;
      const id = remoteStream.getId();
      const userId = remoteStream.getUserId();
      console.log(`remote stream added: [${userId}] ID: ${id} type: ${remoteStream.getType()}`);
      Toast.info('远端流增加 - ' + userId);
      console.log('subscribe to this remote stream');
      // 远端流默认已订阅所有音视频，此处可指定只订阅音频或者音视频，不能仅订阅视频。
      // 如果不想观看该路远端流，可调用 this.client_.unsubscribe(remoteStream) 取消订阅
      this.client_.subscribe(remoteStream);
    });

    // 远端流订阅成功事件
    this.client_.on('stream-subscribed', evt => {
      const remoteStream = evt.stream;
      const id = remoteStream.getId();
      this.remoteStreams_.push(remoteStream);
      addView(id);
      // 在指定的 div 容器上播放音视频
      remoteStream.play(id);
      console.log('stream-subscribed ID: ', id);
      Toast.info('远端流订阅成功 - ' + remoteStream.getUserId());
    });

    // 处理远端流被删除事件
    this.client_.on('stream-removed', evt => {
      const remoteStream = evt.stream;
      const id = remoteStream.getId();
      // 关闭远端流内部的音视频播放器
      remoteStream.stop();
      this.remoteStreams_ = this.remoteStreams_.filter(stream => {
        return stream.getId() !== id;
      });
      removeView(id);
      console.log(`stream-removed ID: ${id}  type: ${remoteStream.getType()}`);
      Toast.info('远端流删除 - ' + remoteStream.getUserId());
    });

    // 处理远端流更新事件，在音视频通话过程中，远端流音频或视频可能会有更新
    this.client_.on('stream-updated', evt => {
      const remoteStream = evt.stream;
      console.log(
        'type: ' +
          remoteStream.getType() +
          ' stream-updated hasAudio: ' +
          remoteStream.hasAudio() +
          ' hasVideo: ' +
          remoteStream.hasVideo()
      );
      Toast.info('远端流更新！');
    });

    // 远端流音频或视频mute状态通知
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

    // 信令通道连接状态通知
    this.client_.on('connection-state-changed', evt => {
      console.log(`RtcClient state changed to ${evt.state} from ${evt.prevState}`);
    });
  }
}
