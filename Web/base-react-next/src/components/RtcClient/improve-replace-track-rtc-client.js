import RTC from '@components/BaseRTC';
import toast from '@components/Toast';
import TRTC from 'trtc-js-sdk';

class Client extends RTC {
  // ref: https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/LocalStream.html#replaceTrack
  async replaceAudioTrack() {
    if (this.localStream) {
      const stream = TRTC.createStream({
        userId: this.userID,
        audio: true,
        video: false,
        microphoneId: this.microphoneID,
      });
      await stream.initialize();
      console.log('replacing audio track to local stream');
      try {
        await this.localStream.replaceTrack(stream.getAudioTrack());
        toast.success('replace audio track success', 2000);
      } catch (error) {
        console.error('replace audio track error', error);
        toast.error('replace audio track error', 2000);
      }
    }
  }

  // ref: https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/LocalStream.html#replaceTrack
  async replaceVideoTrack() {
    if (this.localStream) {
      const stream = TRTC.createStream({
        userId: this.userID,
        audio: false,
        video: true,
        cameraId: this.cameraID,
      });
      await stream.initialize();
      console.log('replacing video track to local stream');
      try {
        await this.localStream.replaceTrack(stream.getVideoTrack());
        toast.success('replace video track success', 2000);
      } catch (error) {
        console.error('replace video track error', error);
        toast.error('replace video track error', 2000);
      }
    }
  }
}

export default Client;
