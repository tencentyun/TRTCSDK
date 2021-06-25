import RTC from '@components/BaseRTC';
import TRTC from 'trtc-js-sdk';

class Client extends RTC {
  constructor(options) {
    super(options);
    this.videoElement = options.videoElement;
  }

  async initLocalStream() {
    const stream = this.videoElement.captureStream();
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
