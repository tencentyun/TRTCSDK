<template>
  <div class="live-main">

    <nav-bar href="/index" title="LIVE"></nav-bar>

    <div class="live-param-form">
        <b-tabs content-class="mt-3" justified v-model="tabIndex"> 

          <b-tab title="主播">
            <div>
              <b-input-group prepend="房间号">
                <b-form-input placeholder="请输入房间号" v-model="roomId"></b-form-input>

                  <b-input-group-append>
                    <b-button @click="randomRoomId" variant="info">
                      <b-icon-arrow-clockwise></b-icon-arrow-clockwise>
                    </b-button>
                  </b-input-group-append>

              </b-input-group>
              <br/>

              <b-input-group prepend="主播名" class="mb-2 mr-sm-2 mb-sm-0">
                <b-form-input placeholder="请输入用户名" v-model="userId" ></b-form-input>
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
                <b-button @click="createRoom" variant="primary" block > 开始 </b-button>
              </p>

            </div>

          </b-tab>

          <b-tab title="观众">

              <div class="room-list">
                <b-list-group>
                  <b-list-group-item v-for="item in roomList" :key="item.id"> 
                      {{item.roomId}} 
                      <b-button-group size="sm" class="f-right">
                        <b-button @click="enterRoom" v-bind:data-room-id="item.roomId" variant="primary">进入</b-button>
                      </b-button-group>
                  </b-list-group-item>
                </b-list-group>
              </div>

          </b-tab>

        </b-tabs>

    </div>

  </div>
</template>

<script>
import rand from '../../common/rand';
import Log from '../../common/log';
import TRTCCloud from 'trtc-electron-sdk';
// 注意：live-room-service 中用到的服务是为了方便向您展示 demo 的功能。真实业务场景中，您需要自行实现这些服务。
import {createLiveRoom, getLiveRoomList} from '../../common/live-room-service';
import trtcState from '../../common/trtc-state';
let logger = new Log('liveIndex');
const trtcCloud = new TRTCCloud();
export default {
  data() {
    return {
      roomId: rand(10000), // 随机生成一个房间号
      userId: rand(1000000000, true), // 随机生成一个用户名，注意：是字符串类型,
      roomList: [], // 房间列表
      roomIdList: [],
      tabIndex: 0,
      getRoomListIntervalID: 0,
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
     * 当点击左侧的“进入”按钮时，带着 userId 和 roomId 参数转到观众席页面（liveRoomAudience）。
     */
    enterRoom(event) {
      let selectedRoomId = event.target.dataset.roomId;
      if (selectedRoomId) {
        this.roomId = parseInt(selectedRoomId);
      }
      if (!this.roomIdList.includes(this.roomId)) {
        this.warn(`房间号${selectedRoomId}不存在`);
        return;
      } else {
        let path = `/live-room-audience/${this.userId}/${this.roomId}/`;
        logger.log('enterRoom, path', path);
        this.$router.push(path);
      }
      logger.log("enterRoom: roomId", this.roomId);
    },

    /**
     * 创建直播间，当点击“开始”按钮时，会带 userId 和 roomId 参数转到主播间页面（liveRoomAnchor）。
     * 主播间页面会根据实际情况决定是创建新的房间，还是以主播的身份进入一个房间：
     * - roomId 不存在的情况下，会创建一个新的房间，并以主播的身份进入；
     * - roomId 存在的情况，会以主播的身份进入这个房间；
     */
    createRoom() {
      // 没有摄像头，没有麦克风，安装好设备再试，或者以观众身份进入。
      if (trtcState.isCameraReady() === false && trtcState.isMicReady() === false) {
        this.warn('找不到可用的摄像头和麦克风。无法以主播身份创建直播间。请安装好摄像头和麦克风后再试，或者您可以以观众的身份观看其她主播。');
        return;
      }

      let path =`/live-room-anchor/${this.userId}/${this.roomId}/${encodeURIComponent(this.selectedCameraID)}`;
      logger.log(`createRoom path: ${path}`);

        // 在 liveRoomService 中创建一个房间号，方便其其他用户查看
      createLiveRoom(this.roomId)
      .then(({data})=>{
        if (data.errorCode!=0) {
          this.warn(`liveRoomService createRoom error: ${data.errorCode}, ${data.errorMessage}`);
        }
      })
      .catch((error)=>{
        logger.error('liveRoomService createRoom error: ', error);
      }).finally(()=>{
        this.$router.push(path);
      });
    },

    /**
     * 获取直播房间列表，注意：涉及到的 API 仅限 demo 使用，如您需要实现相同的功能，需要自建 web 服务。
     */
    getRoomList () {
      getLiveRoomList()
      .then(({data})=>{
        if (data.errorCode!=0) {
          // this.warn(`getRoomList 错误 #${data.errorCode}, ${data.errorMessage}`);
          return;
        }
        let list = [];
        let oldList = data.data;
        for (let i = 0 ; i < oldList.length; i++) {
          list.push({
            appId: oldList[i].appId,
            type: oldList[i].type,
            roomId: parseInt(oldList[i].roomId),
            id: parseInt(oldList[i].id),
            createTime: parseInt(oldList[i].createTime)
          });
        }
        this.roomList = list;
        this.roomIdList = [];
        logger.log('getRoomList', this.roomList);
        for (let i = 0; i < this.roomList.length; i++ ) {
          this.roomIdList[i] = this.roomList[i]['roomId'];
        }
      })
      .catch((error)=>{
          // this.warn('getRoomList error');
          logger.error('getRoomList error: ', error);
      });
    }, 

    randomUserId() {
				this.userId = rand(1000000000, true);
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
    logger.log('mounted s',this.$route.params);
    this.tabIndex = ['anchor', 'audience'].indexOf(this.$route.params.active);
    if (this.tabIndex < 0) {
      this.tabIndex = 0;
    }
    this.getRoomList();
    this.getRoomListIntervalID = setInterval(()=>{
      this.getRoomList();
    }, 5000);
    this.getDefaultCamera();
    this.getCameraList();
  },

  beforeDestroy(){
    // 当退出页面时，停止计时器
    clearInterval(this.getRoomListIntervalID);
  }
};
</script>
<style scoped>
.f-right{
  float: right;
}
.live-param-form {
    max-width: 500px;
    min-width: 300px;
    height: auto;
    margin: 10vh auto 0 auto;
}
.room-list {
  min-height: 2vh;
  max-height: 80vh;
  overflow-y: auto;
}
</style>