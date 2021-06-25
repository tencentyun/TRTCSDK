import RTC from '@components/BaseRTC';
import toast from '@components/Toast';

class Client extends RTC {
  constructor(options) {
    super(options);
    this.mixedMCU = false;
  }
  async startMixTranscode(mixMode, mixInputParamList, mixOutputParam, shareID) {
    if (!this.isJoined) {
      toast.error('please join room', 2000);
      return;
    }
    try {
      const [videoTrack] = this.localStream.getMediaStream().getVideoTracks();
      const localInfo = {
        id: 'local_stream',
        userId: this.localStream.getUserId(),
        width: videoTrack && videoTrack.getSettings().width,
        height: videoTrack && videoTrack.getSettings().height,
        locationX: 0,
        locationY: 0,
        pureAudio: false,
        zOrder: 1,
      };
      const mixInputParamList = [...mixInputParamList, localInfo];

      let mixUsers = mixInputParamList;
      if (mixMode === 'preset-layout') {
        mixUsers = [
          {
            width: 960,
            height: 720,
            locationX: 0,
            locationY: 0,
            pureAudio: false,
            userId: shareID,
            zOrder: 1,
          },
          {
            width: 320,
            height: 240,
            locationX: 960,
            locationY: 0,
            pureAudio: false,
            userId: this.userID,
            zOrder: 1,
          },
          {
            width: 320,
            height: 240,
            locationX: 960,
            locationY: 240,
            pureAudio: false,
            userId: '$PLACE_HOLDER_REMOTE$',
            zOrder: 1,
          },
          {
            width: 320,
            height: 240,
            locationX: 960,
            locationY: 480,
            pureAudio: false,
            userId: '$PLACE_HOLDER_REMOTE$',
            zOrder: 1,
          },
        ];
      }
      const config = {
        ...mixOutputParam,
        mixUsers,
        mode: mixMode,
      };

      await this.client.startMixTranscode(config);
      this.mixedMCU = true;
    } catch (error) {
      console.log('startMixTranscode fail', error);
      this.mixedMCU = false;
    }
  }
}

export default Client;
