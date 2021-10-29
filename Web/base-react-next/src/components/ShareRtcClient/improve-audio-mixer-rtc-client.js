import ShareRTC from '@components/ShareRTC.js';
import AudioMixerPlugin from 'rtc-audio-mixer';

export default class ShareRTCClient extends ShareRTC {
  constructor(options) {
    super(options);
    this.shareLowMix = null;
  }

  addShareLowMix() {
    this.shareLowMix = this.shareLowMix || AudioMixerPlugin.createAudioSource({
      url: './count.mp3',
      volume: 0.2,
    });

    const shareAudioTrack = AudioMixerPlugin.mix({ sourceList: [this.shareLowMix] });
    this.localStream.addTrack(shareAudioTrack);
  }

  shareLowMixStart() {
    this.shareLowMix && this.shareLowMix.play();
  }
  shareLowMixPause() {
    this.shareLowMix && this.shareLowMix.pause();
  }
  shareLowMixStop() {
    this.shareLowMix && this.shareLowMix.stop();
  }
  shareLowMixResume() {
    this.shareLowMix && this.shareLowMix.resume();
  }
}
