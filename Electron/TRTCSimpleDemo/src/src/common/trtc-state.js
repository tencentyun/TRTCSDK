import TRTCCloud from 'trtc-electron-sdk';
import Log from './log';
const trtcCloud = new TRTCCloud();
const logger = new Log('TRTCState');
class TRTCState {
  constructor() {
    this.camera = false;
    this.mic = false;
    this.micVolume = 0;
    this.speaker = false;
    this.speakerVolume = 0;
    this.network = false;
    this.checkTaskId = 0;
  }

  check(callBack) {
      this.isCameraReady();
      this.isMicReady();
      this.isSpeakerReady();
      this.getMicVolume();
      this.getSpeakerVolume();
      if (typeof callBack === 'function') {
        callBack({
          camera: this.camera,
          mic: this.mic,
          speaker: this.speaker,
          micVolume: this.micVolume,
          speakerVolume: this.speakerVolume,
        })
      }
  }

  startCheckTask(callBack) {
    this.check(callBack);
    this.checkTaskId = setInterval(()=>{
      this.check(callBack);
    }, 500);
    logger.log('startCheckTask, checkTaskId', this.checkTaskId);
  }

  stopCheckTask() {
    logger.log('stopCheckTask, checkTaskId', this.checkTaskId);
    clearInterval(this.checkTaskId);
  }

  isCameraReady() {
      let deviceInfo = trtcCloud.getCurrentCameraDevice();
      if (deviceInfo && deviceInfo.deviceId!='') {
        this.camera = true;
        return true;
      }
      let deviceList = trtcCloud.getCameraDevicesList();
      if (deviceList.length >= 1 ) {
        if (deviceList.length > 1) {
          trtcCloud.setCurrentCameraDevice(deviceList[0].deviceId);
        }
        this.camera = true;
        return true;
      }
      return false;
  }

  isMicReady() {
      let deviceInfo = trtcCloud.getCurrentMicDevice();
      if (deviceInfo && deviceInfo.deviceId!='') {
        this.mic = true;
        return true;
      }
      let deviceList = trtcCloud.getMicDevicesList();
      if (deviceList.length >= 1 ) {
        if (deviceList.length > 1) {
          trtcCloud.setCurrentMicDevice(deviceList[0].deviceId);
        }
        this.mic = true;
        return true;
      }
      return false;
  }

  isSpeakerReady() {
      let deviceInfo = trtcCloud.getCurrentSpeakerDevice();
      if (deviceInfo && deviceInfo.deviceId!='') {
        this.speaker = true;
        return true;
      }
      let deviceList = trtcCloud.getSpeakerDevicesList();
      if (deviceList.length >= 1 ) {
        if (deviceList.length > 1) {
          trtcCloud.setCurrentSpeakerDevice(deviceList[0].deviceId);
        }
        this.speaker = true;
        return true;
      }
      return false;
  }

  getSpeakerVolume () {
    this.speakerVolume = trtcCloud.getCurrentSpeakerVolume();
    return this.speakerVolume;
  }

  getMicVolume() {
    this.micVolume = trtcCloud.getCurrentMicDeviceVolume();
    return this.micVolume;
  }

}
const trtcState = new TRTCState();
export default trtcState;
