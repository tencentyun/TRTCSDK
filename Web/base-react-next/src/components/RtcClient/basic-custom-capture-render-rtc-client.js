import RTC from '@components/BaseRTC';
import TRTC from 'trtc-js-sdk';
class Client extends RTC {
  async initLocalStream() {
    // https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/TRTC.html#.createStream
    let stream = null;
    try {
      stream = await navigator.mediaDevices.getUserMedia({
        audio: true,
        video: { width: 640, height: 480, frameRate: 15 },
      });
    } catch (error) {
      console.error('failed to getUserMedia');
      return;
    }

    const [audioTrack] = stream.getAudioTracks();
    const [videoTrack] = stream.getVideoTracks();

    this.localStream = TRTC.createStream({
      userId: this.userID,
      audioSource: audioTrack,
      videoSource: videoTrack,
    });
    await this.localStream.initialize();
    this.addStream && this.addStream(this.localStream);

    return this.localStream;
  }
}

export default Client;
