/*
 * @Description: 屏幕分享
 * @Date: 2022-03-16 10:34:54
 * @LastEditTime: 2022-04-01 11:57:06
 */
import TRTC from 'trtc-js-sdk';
import LibGenerateTestUserSig from '@/utils/lib-generate-test-usersig.min.js';

export default {
  data() {
    return {
      shareClient: null,
      shareLocalStream: null,
      isShareJoined: false,
      isSharePublished: false,
    };
  },

  computed: {
    shareUserId() {
      return `share_${this.userId}`;
    },
    shareUserSig() {
      if (this.sdkAppId && this.secretKey && this.shareUserId) {
        const generator = new LibGenerateTestUserSig(this.sdkAppId, this.secretKey, 604800);
        return generator.genTestUserSig(this.shareUserId);
      }
      return '';
    },
  },

  methods: {
    // 初始化屏幕分享 client
    initShareClient() {
      this.shareClient = TRTC.createClient({
        mode: 'rtc',
        sdkAppId: this.sdkAppId,
        userId: this.shareUserId,
        userSig: this.shareUserSig,
        autoSubscribe: false,
      });
      this.addSuccessLog(`Client [${this.shareUserId}] created.`);
      this.handleShareClientEvents();
    },

    // 初始化屏幕分享 stream
    async initShareLocalStream() {
      this.shareLocalStream = TRTC.createStream({
        screenAudio: false,
        screen: true,
        userId: this.shareUserId,
      });
      this.shareLocalStream.setScreenProfile('1080p');
      try {
        await this.shareLocalStream.initialize();
        this.addSuccessLog(`ShareStream [${this.shareUserId}] initialized.`);
      } catch (error) {
        this.addFailedLog(`ShareStream failed to initialize. Error: ${error.message}}.`);
        switch (error.name) {
          case 'NotReadableError':
            alert('屏幕分享失败，请确保系统允许当前浏览器获取屏幕内容');
            throw error;
          case 'NotAllowedError':
            if (error.message.includes('Permission denied by system')) {
              alert('屏幕分享失败，请确保系统允许当前浏览器获取屏幕内容');
            } else {
              console.log('User refused to share the screen');
            }
            throw error;
          default:
            return;
        }
      }
      this.handleShareStreamEvents();
    },

    // 销毁本地屏幕分享流
    destroyShareLocalStream() {
      this.shareLocalStream.stop();
      this.shareLocalStream.close();
      this.shareLocalStream = null;
    },

    // 处理屏幕分享 client 进房
    async handleShareJoin() {
      if (this.isShareJoined) {
        console.error('ShareClient has joined');
        return;
      }
      try {
        await this.shareClient.join({ roomId: this.roomId });
        this.isShareJoined = true;

        this.addSuccessLog(`ShareClient [${this.shareUserId}] join success.`);
      } catch (error) {
        console.log('shareRTC handleJoin error', error);
        this.addFailedLog(`ShareClient [${this.shareUserId}] join failed. ${error.message}.`);
        this.reportFailedEvent('startScreenShare', error, 'share');
      }
    },

    // 屏幕分享 client 发布屏幕分享流
    async handleSharePublish() {
      if (this.isSharePublished) {
        console.error('ShareClient has published');
        return;
      }
      try {
        await this.shareClient.publish(this.shareLocalStream);
        this.isSharePublished = true;

        this.addSuccessLog('ShareStream is published successfully.');
        this.reportSuccessEvent('startScreenShare', 'share');
      } catch (error) {
        this.addFailedLog(`ShareStream is published failed. ${error.message}.`);
        this.reportFailedEvent('startScreenShare', error, 'share');
      }
    },

    async handleShareUnpublish() {
      if (!this.isSharePublished) {
        console.error('ShareStream has not published');
        return;
      }
      try {
        await this.shareClient.unpublish(this.shareLocalStream);
        this.isSharePublished = false;

        this.addSuccessLog('ShareStream is unpublished successfully.');
      } catch (error) {
        console.log(`ShareStream unpublish failed, ${error.message}`);
        this.addFailedLog(`ShareStream unpublish failed, ${error.message}.`);
        this.reportFailedEvent('stopScreenShare', error, 'share');
      }
    },

    async handleShareLeave() {
      if (!this.isShareJoined) {
        console.error('ShareStream has not joined');
        return;
      }
      this.destroyShareLocalStream();
      try {
        await this.shareClient.leave();
        this.isShareJoined = false;

        this.addSuccessLog('ShareClient leave successfully.');
        this.reportSuccessEvent('stopScreenShare', 'share');
      } catch (error) {
        console.log(`ShareClient leave failed, ${error.message}`);
        this.addFailedLog(`ShareClient leave failed, ${error.message}.`);
        this.reportFailedEvent('stopScreenShare', error, 'share');
      }
    },

    handleShareClientEvents() {
      this.shareClient.on('error', (error) => {
        console.error(error);
        alert(error);
      });
      this.shareClient.on('client-banned', (event) => {
        console.warn(`client has been banned for ${event.reason}`);
      });
    },

    handleShareStreamEvents() {
      this.shareLocalStream.on('player-state-changed', (event) => {
        console.log(`local stream ${event.type} player is ${event.state}`);
      });
      // 当用户通过浏览器自带的按钮停止屏幕分享时，会监听到 screen-sharing-stopped 事件
      this.shareLocalStream.on('screen-sharing-stopped', async () => {
        console.log('share stream video track ended.');
        this.addSuccessLog('ScreenShare is stopped.');
        await this.handleShareUnpublish();
        await this.handleShareLeave();
      });
    },
  },
};
