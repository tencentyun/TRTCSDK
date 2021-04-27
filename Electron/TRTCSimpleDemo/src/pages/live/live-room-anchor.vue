<template name="liveRoomAnchor">
  <div id="live-room">

    <nav-bar :title="'房间号：' + roomId+'；主播：'+userId"></nav-bar>

    <!-- 视频容器 -->
    <div id="video-container"></div>
    <!-- 控制条 -->
    <div id="controll-bar">

      <!-- 开始/停止推流，会弹出模态框 -->
      <b-button variant="link" @click="showConfirmPushModal">
        <b-iconstack font-scale="1">
          <b-icon icon="stop-fill" color="red" v-if="isPushing"></b-icon> 
          <b-icon icon="caret-right-fill" color="white" v-else></b-icon>
        </b-iconstack>
      </b-button>

      <!-- 开启/关闭麦克风 -->
      <b-button variant="link" @click="toggleMic">
        <b-iconstack font-scale="1">
          <b-icon icon="mic-fill" color="white"></b-icon> 
          <b-icon icon="slash" variant="danger"  v-if="isMuteMic" ></b-icon>
        </b-iconstack>
      </b-button>

      <!-- 开房/关闭摄像头 -->
      <b-button variant="link" @click="toggleCamera">
        <b-iconstack font-scale="1">
          <b-icon icon="camera-video-fill" color="white"></b-icon>
          <b-icon icon="slash" variant="danger"  v-if="isDisableCamara"></b-icon>
        </b-iconstack>
      </b-button>


      <!-- 屏幕分享控制 -->
      <b-button variant="link">
        
        <b-iconstack font-scale="1" id="screen-sharing-controll" @click="toggleScreenSharing" v-if="isPushing">
          <b-icon icon="tv-fill" color="yellow" v-if="isScreenSharing"></b-icon>
          <b-icon icon="tv-fill" color="white" v-else></b-icon>
        </b-iconstack>
        <b-iconstack font-scale="1" id=""  v-else>
          <b-icon icon="tv-fill" color="gray" ></b-icon>
        </b-iconstack>

      </b-button>

      <!-- 退出房间 -->
      <b-button variant="link" @click="exitRoom">
        <b-iconstack font-scale="1">
          <b-icon icon="power" variant="warning"></b-icon>
        </b-iconstack>
      </b-button>

    </div>

    <!-- 模态框、浮层 -->
    <div>
      <b-modal id="screens-list-modal" size="lg" title="选择一个窗口" v-model="screensListVisiable" >
        <show-screen-capture v-bind:list="screensList" v-bind:onClick="chooseWindowCapture"></show-screen-capture>
      </b-modal>
      <b-modal id="start-push-confirm" size="lg" title="即将直播推流，是否确认?" centered @ok="startLive">
        <p class="my-4"> 如果您对预览的效果感到满意，请点击“OK”开始直播推流。 </p>
      </b-modal>

      <b-modal id="stop-push-confirm" size="lg" title="正在关闭直播，是否确认?" centered @ok="stopLive">
        <p class="my-4"> 请确认是否关闭直播？ </p>
      </b-modal>

      <div id="count-down-layer" v-if="countDown > 0">
          {{countDown}} 秒后开始直播
      </div>
      
    </div>

  </div>
</template>

<script>
import TRTCCloud from 'trtc-electron-sdk';
import showScreenCpature from '../../components/show-screen-capture.vue';
import trtcState from '../../common/trtc-state';
import {
  TRTCAppScene, 
  TRTCVideoStreamType, 
  TRTCVideoFillMode, 
  TRTCRoleType, 
  TRTCParams, 
  TRTCVideoEncParam,
  TRTCVideoResolution,
  TRTCVideoResolutionMode,
  TRTCBeautyStyle,
  Rect,
} from "trtc-electron-sdk/liteav/trtc_define";
import genTestUserSig from '../../debug/gen-test-user-sig';
import mtaH5 from '../../common/mtah5';
import Log from '../../common/log';
import {BDVideoEncode, BDBeauty} from '../../common/bd-tools';
const logger = new Log(`trtcRoom`);
let trtcCloud = null; // 用于TRTCQcloud 实例， mounted 时实体化





export default {
  components: {
    'show-screen-capture': showScreenCpature
  },
  data() {
    return {
      roomId: 0, 
      userId: '',
      cameraId: '',
      videosList: [],
      streamType: TRTCVideoStreamType.TRTCVideoStreamTypeBig,
      isMuteMic: false,
      isDisableCamara : false,
      getScreensTaskID: 0,
      screensList: [],
      screensListVisiable: false,
      videoContainer: null,
      isPushing: false,
      isScreenSharing: false,
      isScreenSharingPlaying: false,
      countDown: 0, // 倒计时开播，单位：秒
      countDownMax: 3, // 倒计时最大值
      countDownVisiable: false,
      loadingProgess: 100,
      sdkInfo: null,
      // 存放远程用户视频列表
      remoteVideos: {},
      isRemoteScreenSharing: false, // 远程用户是否正在分享屏幕

    };
  },

  computed: {
    subStreamWidth() {
      return Math.floor(this.videoContainer.clientWidth * 0.2);
    },

    subStreamHeight () {
      return Math.floor(this.videoContainer.clientHeight * 0.2);
    }
  },

  methods: {

    /**
     * 推流状态切换确认
     */
    showConfirmPushModal() {
      let modalId = this.isPushing === false ? 'start-push-confirm' : 'stop-push-confirm';
      this.$bvModal.show(modalId);
    },

    /** 
     * 倒计时3秒开始直播
     */
    startLiveCountDown() {
      let gap = 1000;
      this.countDown = this.countDownMax;
      let intervalID = setInterval(()=>{
        this.countDown -= gap / 1000;
        logger.log('startLiveCountDown: ', this.countDown);
        if (this.countDown <= 0 ) {
          this.startLive();
          clearInterval(intervalID);
        }
      }, gap);
    },

    /**
     * 开始直播，注意：进入房间会开始推流
     */
    startLive() {
      this.isPushing = true;
      // 进入房间便会开始推流
      // TRTCParams 详细说明，请查看文档：https://web.sdk.qcloud.com/trtc/electron/doc/zh-cn/trtc_electron_sdk/TRTCParams.html
      let param = new TRTCParams();
      param.sdkAppId = this.sdkInfo.sdkappid;
      param.userSig = this.sdkInfo.userSig;
      param.roomId = this.roomId;
      param.userId = this.userId;
      param.privateMapKey = ''; // 房间签名（非必填）7.1.157 版本以上（含），可以忽略此参数，7.1.157 之前的版本建议赋值为空字符串
      param.businessInfo = ''; // 业务数据（非必填）7.1.157 版本以上（含），可以忽略此参数，7.1.157 之前的版本建议赋值为空字符串
      param.role = TRTCRoleType.TRTCRoleAnchor; // 直播场景下的角色，仅适用于直播场景（TRTCAppSceneLIVE 和 TRTCAppSceneVoiceChatRoom），视频通话场景下指定无效。默认值：主播（TRTCRoleAnchor）
      trtcCloud.enterRoom(param, TRTCAppScene.TRTCAppSceneLIVE);
    },

    /** 
     * 停止直播
     */
    stopLive() {
      this.isPushing = false;
      trtcCloud.stopScreenCapture(); // 停止屏幕分享
      trtcCloud.exitRoom(); // 退出房间
      setTimeout(()=>{
        // 推流结束后，继续观看本地画面
        this.startCameraAndMic();
      }, 0);
    },

    /**
    * 当进入房间时触发，显示摄像头画面，设置填充模式
    * @param {number} result - 进房结果， 大于 0 时，为进房间消耗的时间，这表示进进房成功。如果为 -1 ，则表示进房失败。
    **/
    onEnterRoom(result) {
      if ( result > 0 ) {
        logger.log(`onEnterRoom，进房成功，使用了 ${result} 毫秒`);
      } else {
        logger.warn(`onEnterRoom: 进房失败 ${result}`);
      }
    },

    /**
     * 当退出房间时触发
     */
    onExitRoom(reason) {
      logger.warn(`onExitRoom, reason: ${reason}`);
    },

    /**
    * 远程用户视频流的状态发生变更时触发。
    * @param {number} uid - 用户标识
    * @param {boolean} available - 画面是否开启
    **/
    onUserVideoAvailable(uid, available) {
      logger.log(`onUserVideoAvailable: uid: ${uid}, available ${available}`);
      if (available === 1) {
        this.$bvToast.toast(`主播 ${uid} 进入房间`, {
          variant: 'success'
        });
        this.showVideo(uid);
      } else {
        this.$bvToast.toast(`主播 ${uid} 退出房间`, {
          variant: 'warning'
        });
        this.closeVideo(uid);
      }
    },

    /***
     * 显示其他用户的视频
     * @param {number} uid - 用户ID
     */
    showVideo(uid){
      let id = `${uid}-${this.roomId}-${TRTCVideoStreamType.TRTCVideoStreamTypeBig}`;
      logger.log(`showVideo: uid: ${uid}; style:${this.remoteVideoStyle}`);
      let view = document.getElementById(id);
      if (!view) {
        view = document.createElement('div');
        view.id = id;
        this.videoContainer.appendChild(view);
      }
      view.style.width = `${this.subStreamWidth}px`;
      view.style.height = `${this.subStreamHeight}px`;
      this.remoteVideos[id] = view;
      trtcCloud.startRemoteView(uid, view);
      trtcCloud.setRemoteViewFillMode(uid, TRTCVideoFillMode.TRTCVideoFillMode_Fill);
      this.videoTypeSetting();
    },

    /**
     * 关闭其他用户的视频
     * @param {number} uid 
     */
    closeVideo(uid) {
      let id = `${uid}-${this.roomId}-${TRTCVideoStreamType.TRTCVideoStreamTypeBig}`;
      let view = document.getElementById(id);
      if (view) {
        this.videoContainer.removeChild(view);
      }
      delete this.remoteVideos[id];
    },


    /**
     * 对视频元素进行排版
     */
    videoTypeSetting() {
      let marginTop =  80 ;
      let margin = 5;
      let H = this.subStreamHeight;
      let m = 0;
      let topIndex = 0;
      let remoteVideos = this.remoteVideos;
      let typeClassName = '';
      let top = 0;
      let i = 0;
      for (let id in remoteVideos) {
        topIndex = Math.floor( i / 2 );
        typeClassName = i % 2 ===0 ? 'right' : 'left';
        top = (topIndex * H + (topIndex+1) * margin )+ marginTop;
        remoteVideos[id].className = `user-video-container ${typeClassName}`;
        remoteVideos[id].style.top = `${top}px`;
        logger.log(`videoTypeSetting: i:${i}, ti: ${topIndex}, top ${top}, H: ${H}, m: ${m}, id:${id},` );
        i++;
      }
    },

    /**
     * 当远端用户进入本房间，显示出此用户的画面
     */
    onRemoteUserEnterRoom(uid) {
      logger.warn('onRemoteUserEnterRoom', uid);
      this.$bvToast.toast(`主播 ${uid} 进入房间`, {
        variant: 'primary'
      });
    },

    /**
     * 当远程用户离开房间，关闭此用户的画面
     */
    onRemoteUserLeaveRoom(uid) {
      this.$bvToast.toast(`主播 ${uid} 离开房间`);
      logger.warn('onRemoteUserLeaveRoom', uid );
    },

    /**
     * 当远程用户屏幕分享的状态发生变化，会根据 available 参数打开或关闭画面
     **/
    onUserSubStreamAvailable(uid, available) {
      logger.log(`onUserSubStreamAvailable ${uid}, ${available}`);
      if (available) {
        this.showRemoteScreenSharing(uid);
        this.isRemoteScreenSharing = true;
      } else {
        this.closeRemoteScreenSharing(uid);
        this.isRemoteScreenSharing = false;
      }
    },

    /**
     * 显示远程用户的屏幕分享
     */
    showRemoteScreenSharing(uid) {
      let id = `${uid}-${this.roomId}-${TRTCVideoStreamType.TRTCVideoStreamTypeSub}`;
      logger.log(`showRemoteScreenSharing:  uid: ${id}`);
      let W = this.subStreamWidth;
      let H = this.subStreamHeight;
      let el = document.getElementById(id);
      if (!el) {
        el = document.createElement('div');
        el.id = id;
        el.style.width = `${W}px`;
        el.style.height = `${H}px`;
        this.videoContainer.appendChild(el);
      }
      this.remoteVideos[id] = el;
      trtcCloud.startRemoteSubStreamView(uid, el);
      trtcCloud.setRemoteSubStreamViewFillMode(uid, TRTCVideoFillMode.TRTCVideoFillMode_Fill);
      this.videoTypeSetting();
    },

    /**
     * 关闭远程用户的屏幕分享
     *
     * @param {*} uid
     */
    closeRemoteScreenSharing (uid) {
      let id = `${uid}-${this.roomId}-${TRTCVideoStreamType.TRTCVideoStreamTypeSub}`;
      let el = document.getElementById(id);
      if (el) {
        this.videoContainer.removeChild(el);
      }
      delete this.remoteVideos[id];
      this.videoTypeSetting();
    },

    /**
     * 开启/关闭麦克风
     */
    toggleMic(event) {
      this.isMuteMic = !this.isMuteMic;
      trtcCloud.muteLocalAudio(this.isMuteMic);
      logger.log('toggleMic', this.isMuteMic, event);
    }, 
    
    /**
     * 开启/关闭摄像头
     */
    toggleCamera(event) {
      this.isDisableCamara = !this.isDisableCamara;
      if (this.isDisableCamara === true) {
        this.hideLocalCameraVideoDom();
      } else {
        this.showLocalCameraVideoDom();
      }
      trtcCloud.muteLocalVideo(this.isDisableCamara);
      logger.log('toggleCamera', this.isDisableCamara, event);
    },

    /**
     * 显示/隐藏屏幕分享控制条
     */
    toggleCreenShareControlBar(){
      if (this.isPushing===false) {
        this.$bvToast.show('开启推流后，才能分享屏幕');
        return;
      }
      this.screenSharingControllerBarVisiable = !this.screenSharingControllerBarVisiable;

    },

    /**
     * 开启 / 关闭屏幕分享，开启时会弹出窗口选择列表
     */
    toggleScreenSharing() {
      logger.log('toggleScreenSharing');
      if (this.isRemoteScreenSharing === true) {
        logger.log('toggleScreenSharing, ignore');
        this.$bvToast.toast(`其他主播正在分享屏幕，您现在无法分享。`, {
          variant: 'warning',
        });
        return;
      }
      if (this.isScreenSharing === false) {
        this.getScreensList();
        logger.log('toggleScreenSharing, getScreenList');
        return;
      }
      this.isScreenSharing = false;
      this.stopScreenShare();
    },

    /** 
     * 获取窗口列表，用于屏幕分享
     */
    getScreensList() {
      // 获取窗口快照，这是资源消耗很高的函数，做个防抖，防频繁点击。
      clearTimeout(this.getScreensTaskID);
      let my = this;
      this.getScreensTaskID = setTimeout(()=>{
        logger.log('getScreensList');
        my.screensList = trtcCloud.getScreenCaptureSources(200, 160, 0, 0);
        my.screensListVisiable = true;
      }, 200);
    },

    /**
     * 当在show-screen-capture 组件中选择了一个窗口快照后，会开始屏幕分享
     */
    chooseWindowCapture(event) {
      let source = {
        sourceId: event.currentTarget.dataset.id,
        sourceName: event.currentTarget.dataset.name,
        type: parseInt(event.currentTarget.dataset.type),
      };
      logger.log('chooseWindowCapture:', source);
      this.startScreenShare(source);
      this.screensListVisiable = false;
      this.isScreenSharing = true;
    },

    /**
     * 开始屏幕分享
     */
    startScreenShare(source) {
      logger.log('startScreenShare');
      let rect = new Rect();
      rect.top = 0; // 左坐标
      rect.left = 0; // 上坐标
      rect.width = 0; // 宽度
      rect.height = 0; // 高度
      trtcCloud.selectScreenCaptureTarget(source.type, source.sourceId, source.sourceName, rect, true, true);
      trtcCloud.startScreenCapture();
    },

   /** 
    * 暂停屏幕分享
    */
    pauseScreenShare(){
      logger.log('pauseScreenShare');
      trtcCloud.pauseScreenCapture();
    },

    /**
     * 恢复屏幕分享
     */
    resumeScreenShare() {
      logger.log('resumeScreenShare');
      trtcCloud.resumeScreenCapture();
      this.isScreenSharingPlaying = true;
    },


    /**
     * 停止屏幕分享
     */
    stopScreenShare() {
      logger.log('stopScreenShare');
      trtcCloud.stopScreenCapture();
      this.isScreenSharing = false;
      this.videoTypeSetting();
    },

    /** 
     * 离开房间
    */
    exitRoom(event) {
      logger.log('exitRoom', event);
      trtcCloud.exitRoom();
      let my = this;
      setTimeout(()=>{
        my.$router.push('/live-index/anchor');
      }, 0 );
    },

    /**
     * 隐藏本地视频的DOM元素
     */
    hideLocalCameraVideoDom() {
      document.querySelector('div.local-video-container').style.display = 'none';
    },

    /**
     * 显示本地视频的DOM元素
     */
    showLocalCameraVideoDom() {
      document.querySelector('div.local-video-container').style.display = 'inline-block';
    },

    /**
     * 启动摄像头、麦克风，显示本地画面
     */
    startCameraAndMic() {
      let id = `local_video-${this.roomId}-${TRTCVideoStreamType.TRTCVideoStreamTypeBig}`;
      logger.log(`startCameraAndMic: ${id}`);
      let view = document.getElementById(id);
      if (!view) {
        view = document.createElement('div');
        view.id = id;
        view.className = 'local-video-container';
        this.videoContainer.appendChild(view);
      }
      trtcCloud.startLocalPreview(view);
      trtcCloud.startLocalAudio();
      trtcCloud.setLocalViewFillMode(TRTCVideoFillMode.TRTCVideoFillMode_Fill);
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
    // 没有摄像头，有麦克风，可以音频
    if (trtcState.isCameraReady() === false) {
      this.warn('找不到可用的摄像头，观众将无法看到您的画面。');
    }
    // 有摄像头，没有麦克风，可以视频
    if (trtcState.isMicReady() === false) {
      this.warn('找不到可用的麦克风，观众将无法听到您的声音。');
    }
    // 1. 获取用于承载视频的 HTMLElement；
    this.videoContainer = document.querySelector('#video-container');
    logger.log(`mounted: `, this.$route.params);

    // 获取 vue-router 传参：userId 和 roomId
    this.roomId = parseInt(this.$route.params.roomId); // roomId 为整数类型
    this.userId = this.$route.params.userId.toString(); // userId 为字符串类型
    this.cameraId = decodeURIComponent(this.$route.params.cameraId.toString()); // 摄像头ID

    if (!this.roomId || !this.userId) {
      this.$bvToast.toast('roomId 或 userId 为空，请填写后再试。');
      this.$router.push('live-index/anchor');
      return;
    }

    // 2. 计算签名
    this.sdkInfo = genTestUserSig(this.userId);

    mtaH5.reportSDKAppID(this.sdkInfo.sdkAppId);

    // 3. 实例化一个 TRTCCloud （包装了 TRTCCloud的类）
    trtcCloud = new TRTCCloud();
    logger.warn(`sdk version: ${trtcCloud.getSDKVersion()}`);

    // 4. 配置基本的事件订阅
    trtcCloud.on('onError',(err)=>{logger.error(err)});
    trtcCloud.on('onEnterRoom', this.onEnterRoom.bind(this));
    trtcCloud.on('onExitRoom', this.onExitRoom.bind(this));
    trtcCloud.on('onUserVideoAvailable', this.onUserVideoAvailable.bind(this));
    trtcCloud.on('onRemoteUserEnterRoom', this.onRemoteUserEnterRoom.bind(this));
    trtcCloud.on('onRemoteUserLeaveRoom', this.onRemoteUserLeaveRoom.bind(this));
    trtcCloud.on('onUserSubStreamAvailable', this.onUserSubStreamAvailable.bind(this));
    logger.log(`mounted, setCurrentCameraDevice('${this.cameraId}')`);
    trtcCloud.setCurrentCameraDevice(this.cameraId);
    // 5. 设置编码参数
    // TRTCVideoEncParam 的详细说明，请参考： https://web.sdk.qcloud.com/trtc/electron/doc/zh-cn/trtc_electron_sdk/TRTCVideoEncParam.html
    let encParam = new TRTCVideoEncParam();

    /**
     *  videoResolution
     * 【字段含义】 视频分辨率
     * 【推荐取值】 : Window 和 iMac 建议选择 640 × 360 及以上分辨率，resMode 选择 TRTCVideoResolutionModeLandscape
     * 【特别说明】 TRTCVideoResolution 默认只能横屏模式的分辨率，例如640 × 360。
     */
    encParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_640_360;

    /**
     * TRTCVideoResolutionMode
     *【字段含义】分辨率模式（横屏分辨率 - 竖屏分辨率）
     *【推荐取值】Window 和 Mac 建议选择 TRTCVideoResolutionModeLandscape
     *【特别说明】如果 videoResolution 指定分辨率 640 × 360，resMode 指定模式为 Portrait，则最终编码出的分辨率为360 × 640。
     */
    encParam.resMode = TRTCVideoResolutionMode.TRTCVideoResolutionModeLandscape;
    encParam.videoFps = 25;
    encParam.videoBitrate = 800;
    encParam.enableAdjustRes = true;
    trtcCloud.setVideoEncoderParam(encParam);

    // 6. 开启美颜 
    // setBeautyStyle 详细信息，请参考：https://web.sdk.qcloud.com/trtc/electron/doc/zh-cn/trtc_electron_sdk/TRTCCloud.html#setBeautyStyle
    trtcCloud.setBeautyStyle(TRTCBeautyStyle.TRTCBeautyStyleNature, 9, 9, 9);

    // 7. 显示摄像头画面和开房麦克风
    this.startCameraAndMic();

    // 执行倒计时
    this.startLiveCountDown();

    // 挂到 windows BOM 下，方便调试。
    window.trtc = trtcCloud;
    window.videoEncode = new BDVideoEncode(trtcCloud);
    window.beauty = new BDBeauty(trtcCloud);
  },

  beforeDestroy() {
    this.isScreenSharing = false;
  }
};

</script>

<style scoped>
#controll-bar {
  position: fixed;
  width: 100%;
  height: 10vh;
  bottom: 0;
  left: 0;
  text-align: center;
  background-color: rgba(0,0,0, 0.3);
  padding-top: 0.9em;
}

#controll-bar>button {
  margin: 0 2em;
  border: none;
}

#controll-bar>button>.b-icon {
  width: 2.5;
}
.close-bt {
  position: relative;
  top: -0.5vh;
  right: -1vw;
}
#count-down-layer{
    position: absolute;
    top: 50%;
    left: 50%;
    width: 66vw;
    height: 14vh;
    font-size: 7vh;
    border: 0.5vw #3f3 solid;
    color: #3f3;
    margin-top: -7vh;
    margin-left: -33vw;
    text-align: center;
    line-height: 14vh;
    overflow: hidden;
}
#audience-list {
  position:absolute;
  top: 10vh;
  left: 1vw;
  color: #fff;
  text-shadow: #000 0 0 2px;
}
#loading {
    position: absolute;
    width: 30vw;
    top: 60%;
    left: 50%;
    margin-left: -15vw;
}
</style>
