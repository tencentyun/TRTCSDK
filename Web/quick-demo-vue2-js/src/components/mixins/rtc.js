/*
 * @Description: 音视频通话集成
 * @Date: 2022-03-14 17:15:23
 * @LastEditTime: 2022-03-23 17:47:14
 */
import TRTC from 'trtc-js-sdk';
import { isUndefined } from '@/utils/utils.js';

export default {
  data() {
    return {
      client: null,
      localStream: null,
      remoteStreamList: [],
      isJoining: false,
      isJoined: false,
      isPublishing: false,
      isPublished: false,
      isMutedVideo: false,
      isMutedAudio: false,
      isPlayingLocalStream: false,
    };
  },

  methods: {
    // 初始化客户端
    async initClient() {
      this.client = TRTC.createClient({
        mode: 'rtc',
        sdkAppId: this.sdkAppId,
        userId: this.userId,
        userSig: this.userSig,
      });
      this.addSuccessLog(`Client [${this.userId}] created.`);
      this.handleClientEvents();
    },

    async initLocalStream() {
      this.localStream = TRTC.createStream({
        audio: true,
        video: true,
        userId: this.userId,
        cameraId: this.cameraId,
        microphoneId: this.microphoneId,
      });
      try {
        await this.localStream.initialize();
        this.addSuccessLog(`LocalStream [${this.userId}] initialized.`);
      } catch (error) {
        this.localStream = null;
        this.addFailedLog(`LocalStream failed to initialize. Error: ${error.message}.`);
        throw error;
      }
    },

    playLocalStream() {
      this.localStream.play('localStream')
        .then(() => {
          this.isPlayingLocalStream = true;
          this.addSuccessLog(`LocalStream [${this.userId}] playing.`);
        })
        .catch((error) => {
          this.addFailedLog(`LocalStream [${this.userId}] failed to play. Error: ${error.message}`);
        });
    },

    destroyLocalStream() {
      this.localStream && this.localStream.stop();
      this.localStream && this.localStream.close();
      this.localStream = null;
      this.isPlayingLocalStream = false;
    },

    playRemoteStream(remoteStream, element) {
      if (remoteStream.getType() === 'main' && remoteStream.getUserId().indexOf('share') >= 0) {
        remoteStream.play(element, { objectFit: 'contain' }).catch();
      } else {
        remoteStream.play(element).catch();
      }
    },

    resumeStream(stream) {
      stream.resume();
    },

    async join() {
      if (this.isJoining || this.isJoined) {
        return;
      }
      this.isJoining = true;
      !this.client && await this.initClient();
      try {
        await this.client.join({ roomId: this.roomId });
        this.isJoining = false;
        this.isJoined = true;

        this.addSuccessLog(`Join room [${this.roomId}] success.`);
        this.reportSuccessEvent('joinRoom');

        this.startGetAudioLevel();
      } catch (error) {
        this.isJoining = false;
        console.error('join room failed', error);
        this.addFailedLog(`Join room ${this.roomId} failed, please check your params. Error: ${error.message}`);
        this.reportFailedEvent('joinRoom', error);
        throw error;
      }
    },

    async publish() {
      if (!this.isJoined || this.isPublishing || this.isPublished) {
        return;
      }
      this.isPublishing = true;
      try {
        await this.client.publish(this.localStream);
        this.isPublishing = false;
        this.isPublished = true;

        this.addSuccessLog('LocalStream is published successfully.');
        this.reportSuccessEvent('publish');
      } catch (error) {
        this.isPublishing = false;
        console.error('publish localStream failed', error);
        this.addFailedLog(`LocalStream is failed to publish. Error: ${error.message}`);
        this.reportFailedEvent('publish');
        throw error;
      }
    },

    async unPublish() {
      if (!this.isPublished || this.isUnPublishing) {
        return;
      }
      this.isUnPublishing = true;
      try {
        await this.client.unpublish(this.localStream);
        this.isUnPublishing = false;
        this.isPublished = false;

        this.addSuccessLog('localStream unpublish successfully.');
        this.reportSuccessEvent('unpublish');
      } catch (error) {
        this.isUnPublishing = false;
        console.error('unpublish localStream failed', error);
        this.addFailedLog(`LocalStream is failed to unpublish. Error: ${error.message}`);
        this.reportFailedEvent('unpublish', error);
        throw error;
      }
    },

    async subscribe(remoteStream, config = { audio: true, video: true }) {
      try {
        await this.client.subscribe(remoteStream, {
          audio: isUndefined(config.audio) ? true : config.audio,
          video: isUndefined(config.video) ? true : config.video,
        });
        this.addSuccessLog(`Subscribe [${remoteStream.getUserId()}] success.`);
        this.reportSuccessEvent('subscribe');
      } catch (error) {
        console.error(`subscribe ${remoteStream.getUserId()} with audio: ${config.audio} video: ${config.video} error`, error);
        this.addFailedLog(`Subscribe ${remoteStream.getUserId()} failed!`);
        this.reportFailedEvent('subscribe', error);
      }
    },

    async unSubscribe(remoteStream) {
      try {
        await this.client.unsubscribe(remoteStream);
        this.addSuccessLog(`unsubscribe [${remoteStream.getUserId()}] success.`);
        this.reportSuccessEvent('unsubscribe');
      } catch (error) {
        console.error(`unsubscribe ${remoteStream.getUserId()} error`, error);
        this.addFailedLog(`unsubscribe ${remoteStream.getUserId()} failed!`);
        this.reportFailedEvent('unsubscribe', error);
      }
    },

    async leave() {
      if (!this.isJoined || this.isLeaving) {
        return;
      }
      this.isLeaving = true;
      this.stopGetAudioLevel();
      this.isPublished && await this.unPublish();
      this.localStream && this.destroyLocalStream();

      try {
        await this.client.leave();
        this.isLeaving = false;
        this.isJoined = false;

        this.addSuccessLog('Leave room success.');
        this.reportSuccessEvent('leaveRoom');
      } catch (error) {
        this.isLeaving = false;
        console.error('leave room error', error);
        this.addFailedLog(`Leave room failed. Error: ${error.message}`);
        this.reportFailedEvent('leaveRoom', error);
        throw error;
      }
    },

    muteVideo() {
      if (this.localStream) {
        this.localStream.muteVideo();
        this.isMutedVideo = true;
        this.addSuccessLog('LocalStream muted video.');
      }
    },

    muteAudio() {
      if (this.localStream) {
        this.localStream.muteAudio();
        this.isMutedAudio = true;
        this.addSuccessLog('LocalStream muted audio.');
      }
    },

    unmuteVideo() {
      if (this.localStream) {
        this.localStream.unmuteVideo();
        this.isMutedVideo = false;
        this.addSuccessLog('LocalStream unmuted video.');
      }
    },

    unmuteAudio() {
      if (this.localStream) {
        this.localStream.unmuteAudio();
        this.isMutedAudio = false;
        this.addSuccessLog('LocalStream unmuted audio.');
      }
    },

    switchDevice(type, deviceId) {
      try {
        if (this.localStream) {
          this.localStream.switchDevice(type, deviceId);
          this.addSuccessLog(`Switch ${type} device success.`);
        }
      } catch (error) {
        console.error('switchDevice failed', error);
        this.addFailedLog(`Switch ${type} device failed.`);
      }
    },

    startGetAudioLevel() {
      // 文档：https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/module-ClientEvent.html#.AUDIO_VOLUME
      this.client.on('audio-volume', (event) => {
        event.result.forEach(({ userId, audioVolume }) => {
          if (audioVolume > 2) {
            console.log(`user: ${userId} is speaking, audioVolume: ${audioVolume}`);
          }
        });
      });
      this.client.enableAudioVolumeEvaluation(200);
    },

    stopGetAudioLevel() {
      this.client && this.client.enableAudioVolumeEvaluation(-1);
    },

    handleClientEvents() {
      this.client.on('error', (error) => {
        console.error(error);
        alert(error);
      });
      this.client.on('client-banned', async (event) => {
        console.warn(`client has been banned for ${event.reason}`);

        this.isPublished = false;
        this.localStream = null;
        await this.leave();
      });
      // fired when a remote peer is joining the room
      this.client.on('peer-join', (event) => {
        const { userId } = event;
        console.log(`peer-join ${userId}`, event);
      });
      // fired when a remote peer is leaving the room
      this.client.on('peer-leave', (event) => {
        const { userId } = event;
        console.log(`peer-leave ${userId}`, event);
      });

      // fired when a remote stream is added
      this.client.on('stream-added', (event) => {
        const { stream: remoteStream } = event;
        const remoteUserId = remoteStream.getUserId();
        if (remoteUserId === `share_${this.userId}`) {
          // don't need screen shared by us
          this.unSubscribe(remoteStream);
        } else {
          console.log(`remote stream added: [${remoteUserId}] type: ${remoteStream.getType()}`);
          // subscribe to this remote stream
          this.subscribe(remoteStream);
          this.addSuccessLog(`RemoteStream added: [${remoteUserId}].`);
        }
      });
      // fired when a remote stream has been subscribed
      this.client.on('stream-subscribed', (event) => {
        const { stream: remoteStream } = event;
        const remoteUserId = remoteStream.getUserId();
        console.log('stream-subscribed userId: ', remoteUserId);
        this.addSuccessLog(`RemoteStream subscribed: [${remoteUserId}].`);
        this.remoteStreamList.push(remoteStream);
        this.$nextTick(() => {
          this.playRemoteStream(remoteStream, remoteUserId);
        });
      });
      // fired when the remote stream is removed, e.g. the remote user called Client.unpublish()
      this.client.on('stream-removed', (event) => {
        const { stream: remoteStream } = event;
        remoteStream.stop();
        const index = this.remoteStreamList.indexOf(remoteStream);
        if (index >= 0) {
          this.remoteStreamList.splice(index, 1);
        }
        console.log(`stream-removed userId: ${remoteStream.getUserId()} type: ${remoteStream.getType()}`);
      });

      this.client.on('stream-updated', (event) => {
        const { stream: remoteStream } = event;
        console.log(`type: ${remoteStream.getType()} stream-updated hasAudio: ${remoteStream.hasAudio()} hasVideo: ${remoteStream.hasVideo()}`);
        this.addSuccessLog(`RemoteStream updated: [${remoteStream.getUserId()}] audio:${remoteStream.hasAudio()}, video:${remoteStream.hasVideo()}.`);
      });

      this.client.on('mute-audio', (event) => {
        const { userId } = event;
        console.log(`${userId} mute audio`);
        this.addSuccessLog(`[${event.userId}] mute audio.`);
      });
      this.client.on('unmute-audio', (event) => {
        const { userId } = event;
        console.log(`${userId} unmute audio`);
        this.addSuccessLog(`[${event.userId}] unmute audio.`);
      });
      this.client.on('mute-video', (event) => {
        const { userId } = event;
        console.log(`${userId} mute video`);
        this.addSuccessLog(`[${event.userId}] mute video.`);
      });
      this.client.on('unmute-video', (event) => {
        const { userId } = event;
        console.log(`${userId} unmute video`);
        this.addSuccessLog(`[${event.userId}] unmute video.`);
      });

      this.client.on('connection-state-changed', (event) => {
        console.log(`RtcClient state changed to ${event.state} from ${event.prevState}`);
      });

      this.client.on('network-quality', (event) => {
        const { uplinkNetworkQuality, downlinkNetworkQuality } = event;
        console.log(`network-quality uplinkNetworkQuality: ${uplinkNetworkQuality}, downlinkNetworkQuality: ${downlinkNetworkQuality}`);
      });
    },
  },
};
