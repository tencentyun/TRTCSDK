<template>
  <div class="trtc-main">

    <nav-bar href="/index" title="RTC"></nav-bar>

    <div class="param-form">

        <b-input-group prepend="房间号">
          <b-form-input placeholder="请输入房间号" v-model="roomId"></b-form-input>

          <b-input-group-append>
            <b-button @click="randomRoomId" variant="info">
              <b-icon-arrow-clockwise></b-icon-arrow-clockwise>
            </b-button>
          </b-input-group-append>

        </b-input-group>
        <br/>

        <b-input-group prepend="用户名">
          <b-form-input placeholder="请输入用户名" v-model="userId"></b-form-input>

          <b-input-group-append>
            <b-button @click="randomUserId" variant="info">
              <b-icon-arrow-clockwise></b-icon-arrow-clockwise>
            </b-button>
          </b-input-group-append>

        </b-input-group>
        <br/>

        <b-input-group>
          <template v-slot:prepend>
            <b-input-group-text >摄像头</b-input-group-text>
          </template>
            <b-form-select
              v-model="selectedCameraID"
              :options="cameraList"
            ></b-form-select>
        </b-input-group>
        <br/>

        <p style="text-align: center;">
          <b-button @click="enterRoom" variant="primary" block >开始</b-button>
        </p>

    </div>
  </div>
</template>

<script>
import rand from '../../common/rand';
import trtcState from '../../common/trtc-state';
import Log from '../../common/log';
import TRTCCloud from 'trtc-electron-sdk';
let logger = new Log('trtcIndex');
const trtcCloud = new TRTCCloud();
export default {
  data() {
    return {
      roomId: rand(10000), // 随机生成一个房间号
      userId: rand(100000).toString(), // 随机生成一个用户名，注意：是字符串类型
      selectedCameraID: '',
      cameraList: [],
    };
  },

  methods: {

    getDefaultCamera() {
      let deviceInfo = trtcCloud.getCurrentCameraDevice();
      if (deviceInfo) {
        this.selectedCameraID = deviceInfo.deviceId;
      }
    },

    getCameraList() {
      let tmp = trtcCloud.getCameraDevicesList();
      if (tmp.length === 1 && this.selectedCameraID==='') {
        this.selectedCameraID = tmp[0].deviceId;
      }
      for (var i = 0; i<tmp.length; i++) {
        this.cameraList.push({
          text: tmp[i].deviceName,
          value: tmp[i].deviceId,
        });
      }
      logger.log.apply(logger, ['getCameraList', ...tmp]);
    },
    /** 
     * 当点击“开始”按钮时，带着 userId 和 roomId 参数转到 trtcRoom 页面
    */
    enterRoom() {
       // 没有摄像头，也没有麦克风，安装好设备再试。
      if (trtcState.isCameraReady() === false && trtcState.isMicReady() === false) {
        this.warn('找不到可用的摄像头和麦克风。请安装摄像头和麦克风后再试。');
        return;
      }

      let path = `/trtc-room/${this.userId}/${this.roomId}/${encodeURIComponent(this.selectedCameraID)}`;
      logger.log('enterRoom: path', path);
      this.$router.push(path);
    },
    randomUserId() {
				this.userId = rand(1000000000, true).toString();
		},
    randomRoomId() {
				this.roomId = rand(100000);
    },
    warn(message) {
      logger.warn(message);
      this.$bvToast.toast(message, {
          title: '警告',
          variant: 'warning',
          solid: true
      });
    }

  },
  mounted() {
      this.getDefaultCamera();
      this.getCameraList();
  }
};
</script>
<style scoped>
.param-form {
    max-width: 300px;
    min-width: 250px;
    height: auto;
    margin: 30vh auto 0 auto;
}
</style>
