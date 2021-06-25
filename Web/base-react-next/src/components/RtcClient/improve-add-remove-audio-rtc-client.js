import RTC from '@components/BaseRTC';
import toast from '@components/Toast';
import TRTC from 'trtc-js-sdk';

class Client extends RTC {
  // ref: https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/LocalStream.html#addTrack
  async addAudioTrack() {
    if (this.localStream) {
      const stream = TRTC.createStream({
        userId: this.userID,
        audio: true,
        video: false,
        microphoneId: this.microphoneID,
      });
      await stream.initialize();
      console.log('adding audio track to local stream');
      try {
        await this.localStream.addTrack(stream.getAudioTrack());
        this.updateStream && this.updateStream(this.localStream);
        this.updateStreamConfig && this.updateStreamConfig(this.userID, 'unmute-audio');
        this.setState('addedTrack', true);
        toast.success('add audio track success', 2000);
      } catch (error) {
        console.error('add audio track error', error);
        toast.error('add audio track error', 2000);
      }
    }
  }

  // ref: https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/LocalStream.html#removeTrack
  async removeAudioTrack() {
    if (this.localStream) {
      console.log('removing audio track from local stream');
      const audioTrack = this.localStream.getAudioTrack();
      if (audioTrack) {
        try {
          await this.localStream.removeTrack(audioTrack);
          audioTrack.stop();
          this.updateStream && this.updateStream(this.localStream);
          this.updateStreamConfig && this.updateStreamConfig(this.userID, 'mute-audio');
          this.setState('addedTrack', false);
          toast.success('remove audio track success', 2000);
        } catch (error) {
          console.error('remove audio track error', error);
          toast.error('remove audio track is not supported, please use muteAudio', 2000);
        }
      }
    }
  }
}

export default Client;
