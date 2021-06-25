import RTC from '@components/BaseRTC.js';
import TRTC from 'trtc-js-sdk';

export default class RTCClient extends RTC {
  constructor(options) {
    super(options);
    this.videoElement = options.videoElement;
    this.ownElementID = options.ownElementID;
    this.remoteElementID = options.remoteElementID;
  }

  async initLocalStream() {
    const stream = this.videoElement.current.captureStream();
    const [audioTrack] = stream.getAudioTracks();
    const [videoTrack] = stream.getVideoTracks();
    this.localStream = TRTC.createStream({
      userId: this.userID,
      audioSource: audioTrack,
      videoSource: videoTrack,
    });
    await this.localStream.initialize();
    this.localStream.play(this.ownElementID);
    return this.localStream;
  }

  handleClientEvents() {
    super.handleClientEvents();
    // fired when a remote stream has been subscribed
    this.client.on('stream-subscribed', (event) => {
      const { stream: remoteStream } = event;
      console.log('stream-subscribed userId: ', remoteStream.getUserId());
      remoteStream.play(this.remoteElementID);
    });
  }
}
