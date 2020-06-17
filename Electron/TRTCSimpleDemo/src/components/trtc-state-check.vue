<template>
      <div id="state-check-ersult">
        <!-- <h3 v-if="checkResult">检测完成</h3>
        <h3 v-if="!checkResult">检测中...</h3> -->
        <ul>
          <li>摄像头 
            <b-icon icon="check-circle" v-if="!cameraWarning" color="blue" ></b-icon>
            <b-icon icon="x-circle" color="red" v-if="cameraWarning"></b-icon>
          </li>
          <li>麦克风 
            <b-icon icon="check-circle" v-if="!micWarning" color="blue" ></b-icon>
            <b-icon icon="x-circle"  color="red"  v-if="micWarning"></b-icon>
          </li>
          <li>扬声器 
            <b-icon icon="check-circle" v-if="!speakerWarning" color="blue"></b-icon>
            <b-icon icon="x-circle"  color="red"  v-if="speakerWarning"></b-icon>
          </li>
        </ul>
        <div>
          <b-alert variant="warning" v-model="cameraWarning"> 找不到可用的摄像头 </b-alert>
          <b-alert variant="warning" v-model="micWarning"> 找不到可用的麦克风 </b-alert>
          <b-alert variant="warning" v-model="speakerWarning"> 找不到可用的扬声器 </b-alert>
        </div>
      </div>
</template>
<script>
import trtcState from '../common/trtc-state';
      
import Log from '../common/log';

let logger = new Log('TRTCStateCheck');
export default {
  data() {
    return {
      micVolume: 0,
      speakerVolume: 0,
      cameraWarning: false,
      micWarning: false,
      speakerWarning: false,
    };
  },

  methods: {
    setCameraWarning(bool) {
      this.cameraWarning = bool;
    },
    setMicWarning(bool) {
      this.micWarning = bool;
    },
    setSpeakerWarning(bool) {
      this.speakerWarning = bool;
    },
    onDeviceCheck(opt) {
      this.cameraWarning = !opt.camera;
      this.micWarning = !opt.mic;
      this.speakerWarning = !opt.speaker;
      this.micVolume = opt.micVolume;
      this.speakerVolume = opt.speakerVolume;
    }
  },

  computed: {
    camera() {
      let result = trtcState.isCameraReady();
      logger.log('camera', result);
      this.setCameraWarning(!result);
      return result;
    },
    mic() {
      let result = trtcState.isMicReady();
      logger.log('mic', result);
      this.setMicWarning(!result);
      return result;
    },
    speaker() {
      let result = trtcState.isSpeakerReady();
      logger.log('speaker', result);
      this.setSpeakerWarning(!result);
      return result;
    },

    checkResult() {
      return this.camera && this.mic && this.speaker;
    },
  },

  mounted() {
  },

  beforeDestroy() {
    trtcState.stopCheckTask();
  },

  created() {
    trtcState.startCheckTask(this.onDeviceCheck.bind(this));
  },

}
</script>
<style scoped>
#state-check-ersult {
  display:block;
  width: 100vw;
  text-align: center;
}
#state-check-ersult>h3{
  font-size: 1em;
}
#state-check-ersult>ul {
  margin:0;
  padding: 0;
}
#state-check-ersult>ul>li {
  margin: 5px 10px;
  display: inline-block;
}
</style>