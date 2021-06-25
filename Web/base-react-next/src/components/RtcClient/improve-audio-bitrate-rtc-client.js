import RTC from '@components/BaseRTC';

class Client extends RTC {
  async changeAudioBitRate(audioBitRate) {
    try {
      await this.localStream.setAudioProfile(audioBitRate);
      await this.localStream.setVideoProfile('480p');
    } catch (error) {
      if (error.name === 'OverconstrainedError') {
        console.error('current camera not support profile');
      } else {
        console.error('current browser not support dynamic change');
      }
    }
  }
}

export default Client;
