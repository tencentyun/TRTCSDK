import RTC from '@components/BaseRTC.js';
import AudioMixerPlugin from 'rtc-audio-mixer';

export default class RTCClient extends RTC {
  constructor(options) {
    super(options);
    this.lowMix = null;
    this.already = [];
  }

  createMusic() {
    this.lowMix = AudioMixerPlugin.createAudioSource({
      url: './count.mp3',
      volume: 0.2,
      loop: true,
    });
    this.lowMix.on('play', (event) => {
      console.log('event: play', event);
    });
    this.lowMix.on('end', (event) => {
      console.log('event: end', event);
    });
    this.lowMix.on('error', (event) => {
      console.log('event: error', event);
    });
  };

  addLowMix() {
    if (this.lowMix) {
      this.already.push(this.lowMix);
      console.log('already mix', this.already);
      const origin = this.localStream.getAudioTrack();
      const lowAudioTrack = AudioMixerPlugin.mix({
        targetTrack: origin,
        sourceList: this.already,
      });
      this.localStream.replaceTrack(lowAudioTrack);
      this.updateAlready();
    }
  }

  leaveRoom() {
    this.lowMixStop();
    this.lowMix = null;
  }

  lowMixStart() {
    this.lowMix && this.lowMix.play();
  }
  lowMixPause() {
    this.lowMix && this.lowMix.pause();
  }
  lowMixStop() {
    this.lowMix && this.lowMix.stop();
  }
  lowMixResume() {
    this.lowMix && this.lowMix.resume();
  }

  updateAlready() {
    console.log('already mixed audio: ', (this.already || []).length);
  }
}
