import RTC from '@components/BaseRTC';
import toast from '@components/Toast';
import TRTC from 'trtc-js-sdk';

class Client extends RTC {
  // ref: https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/LocalStream.html#addTrack
  async addVideoTrack() {
    if (this.localStream) {
      const stream = TRTC.createStream({
        userId: this.userID,
        audio: false,
        video: true,
        cameraId: this.cameraID,
      });
      await stream.initialize();
      console.log('adding video track to local stream');
      try {
        await this.localStream.addTrack(stream.getVideoTrack());
        this.updateStream && this.updateStream(this.localStream);
        this.updateStreamConfig && this.updateStreamConfig(this.userID, 'unmute-video');
        this.setState('addedTrack', true);
        toast.success('add video track success', 2000);
      } catch (error) {
        console.error('add video track error', error);
        toast.error('add video track error', 2000);
      }
    }
  }

  // ref: https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/LocalStream.html#removeTrack
  async removeVideoTrack() {
    if (this.localStream) {
      console.log('removing video track from local stream');
      const videoTrack = this.localStream.getVideoTrack();
      if (videoTrack) {
        try {
          await this.localStream.removeTrack(videoTrack);
          videoTrack.stop();
          this.updateStream && this.updateStream(this.localStream);
          this.updateStreamConfig && this.updateStreamConfig(this.userID, 'mute-video');
          this.setState('addedTrack', false);
          toast.success('remove video track success', 2000);
        } catch (error) {
          console.error('remove video track error', error);
          toast.error('remove video track error', 2000);
        }
      }
    }
  }
}

export default Client;
