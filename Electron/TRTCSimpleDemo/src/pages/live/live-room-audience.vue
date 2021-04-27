<template name="trtcRoomAudience">

  <div id="live-room">

    <nav-bar :title="'房间号：' + roomId+'；观众：'+userId"></nav-bar>

    <!-- 视频容器 -->
    <div id="video-container"></div>

    <div id="controll-bar">
      <b-button variant="link" @click="exitRoom">
        <b-iconstack font-scale="1">
          <b-icon icon="power" variant="warning"></b-icon>
        </b-iconstack>
      </b-button>
    </div>

    <div>
      <b-modal id="no-anchor-modal" size="lg" title="提示" 
        @ok = "exitAndDeleteRoom"
      >
        此房间没有主播，请换一个房间.
      </b-modal>
      <b-modal id="live-stop-modal" size="lg" title="提示"
        @ok = "exitRoom"
      >
        所有主播已经离开，点“OK” 离开房间，点“chancel”继续等待。
      </b-modal>
    </div>
  </div>
</template>

<script>
import TRTCCloud from 'trtc-electron-sdk';
import {destroyLiveRoom} from '../../common/live-room-service';
import mtaH5 from '../../common/mtah5';
import {
  TRTCAppScene, 
  TRTCVideoStreamType, 
  TRTCVideoFillMode, 
  TRTCRoleType, 
  TRTCParams, 
} from "trtc-electron-sdk/liteav/trtc_define";
import genTestUserSig from '../../debug/gen-test-user-sig';
import Log from '../../common/log';
const logger = new Log(`trtcRoom`);
let trtcCloud = null; // 用于TRTCIns 实例， mounted 时实体化
export default {
  data() {
    return {
      roomId: 0, 
      userId: '',
      videosList: [],
      streamType: TRTCVideoStreamType.TRTCVideoStreamTypeBig,
      isMuteMic: false,
      isDisableCamara : false,
      isScreenSharing: false,
      getScreensTaskID: 0,
      screensList: [],
      screensListVisiable: false,
      videoContainer: null,
      enablePush: false,
      anchorIdList: [], // 主播ID列表
      noAnchorTimoutID: '',
      noAnchorCountDown: 3, // 空房间倒计时检测的最大时长，如果达到了这个时间，仍没有触发 onUserVideoAvailable ，就会提示用户是否要退出此直播间。

      // 存放远程用户视频列表
      remoteVideos: {},
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
     * 启动一个计时器，当进入了空的房间 n 秒后给出提示
     */
    startNoAnchorCountDown() {
      this.noAnchorTimoutID = setTimeout(()=>{
        if (this.anchorIdList.length===0) {
          this.$bvModal.show('no-anchor-modal');
        }
      },this.noAnchorCountDown * 1000);
    },


    /**
    * 当进入房间时触发的回调
    * @param {number} result - 进房结果， 大于 0 时，为进房间消耗的时间，这表示进进房成功。如果为 -1 ，则表示进房失败。
    **/
    onEnterRoom(result) {
      if ( result > 0 ) {
        logger.log(`onEnterRoom，进房成功，使用了 ${result} 毫秒`);
        this.startNoAnchorCountDown();
      } else {
        this.$bvToast.toast(`进房失败 ${result}`);
        logger.warn(`onEnterRoom: 进房失败 ${result}`);
      }
    },

    /**
     * 当退出房间时触发的回调
     */
    onExitRoom(reason) {
      logger.warn(`onExitRoom, reason: ${reason}`);
    },

    /**
     * 当主播进房时，把主播ID push 到列表里，并返回列表的长度
     */
    anchorIn(uid) {
      if (!this.anchorIdList.includes(uid)) {
        this.anchorIdList.push(uid);
      }
      return this.anchorIdList.length;
    },

    /**
     * 当主播退房时，把主播ID 从列表中 去除，并返回列表的长度
     */
    anchorOut(uid) {
      let idx = this.anchorIdList.indexOf(uid);
      this.anchorIdList = this.anchorIdList.slice(idx);
      return this.anchorIdList.length;
    },

   /**
    * 远程用户视频流的状态发生变更时触发。
    * @param {number} uid - 用户标识
    * @param {boolean} available - 画面是否开启
    **/
    onUserVideoAvailable(uid, available) {
      logger.log(`onUserVideoAvailable: uid: ${uid}, available ${available}`);
      if (available === 1) {
        clearTimeout(this.noAnchorTimoutID);
        this.anchorIn(uid);
        this.showAnchorVideo(uid);
        this.$bvToast.toast(`主播 ${uid} 进入房间`, {variant: 'primary'});
      } else {
        this.$bvToast.toast(`主播 ${uid} 退出房间`, {variant: 'warning'});
        this.closeAnchorVideo(uid);
        if (this.anchorOut() === 0) {
          this.$bvModal.show('live-stop-modal');
        }
      }
    },

    /**
     * 显示主播的视频，直播模式下，显示主播的画面
     */
    showAnchorVideo(uid) {
      let id = `${uid}-${this.roomId}-${TRTCVideoStreamType.TRTCVideoStreamTypeBig}`;
      logger.log(`showAnchorVideo: remoteVideoIndex: ${this.remoteVideoIndex}; uid: ${uid}; `);
      let view = document.getElementById(id);
      if (!view) {
        view = document.createElement('div');
        view.id = id;
        this.videoContainer.appendChild(view);
      }
      if (view.className.indexOf('anchor-view') < 0) {
        view.classList.add('anchor-view');
      }
      this.remoteVideos[id] = view;
      trtcCloud.startRemoteView(uid, view);
      trtcCloud.setRemoteViewFillMode(uid, TRTCVideoFillMode.TRTCVideoFillMode_Fill);
      this.videoTypeSettingAutoWrap();
    },

    /**
     * 关闭主播的视频
     * @param {number} uid 
     */
    closeAnchorVideo(uid) {
      let id = `${uid}-${this.roomId}-${TRTCVideoStreamType.TRTCVideoStreamTypeBig}`;
      let view = document.getElementById(id);
      if (view) {
        this.videoContainer.removeChild(view);
      }
      delete this.remoteVideos[id];
      this.remoteVideoIndex--;
      this.videoTypeSettingAutoWrap();
    },

    /**
     * 视频元素自动换行排版
     */
    videoTypeSettingAutoWrap () {
      let maxPerline = 2; // 每行最多放三个
      let remoteVideos = this.remoteVideos;
      let winWidth = 100; // 窗口宽度，百分比值
      let winHeight = 100; // 窗口高度，百分比值
      let len = Object.keys(remoteVideos).length;
      let nw = 1;
      let nh = 1;
      for (let id in remoteVideos) {
        nw = len <= maxPerline ? len : maxPerline;
        nh = Math.ceil(len / maxPerline);
        remoteVideos[id].className = `user-video-container-auto-wrap`;
        remoteVideos[id].style.width = `${winWidth / nw}vw`
        remoteVideos[id].style.height = `${winHeight / nh}vh`
      }
    },

    /**
     * 当主播进入本房间
     */
    onRemoteUserEnterRoom(uid) {
      logger.warn('onRemoteUserEnterRoom', uid);
        if (!this.anchorIdList.includes(uid)) {
          this.anchorIdList.push(uid);
          this.$bvToast.toast(`主播 ${uid}，进入房间。`, {
            variant: 'primary'
          });
        }
    },

    onRemoteUserLeaveRoom(uid) {
      logger.warn('onRemoteUserLeaveRoom', uid);
      this.closeAnchorVideo(uid);
      if (this.anchorOut(uid) === 0) {
        this.$bvModal.show('live-stop-modal');
      }
    },

    /**
     * 当远程用户屏幕分享的状态发生变化
     **/
    onUserSubStreamAvailable(uid, available) {
      logger.log(`onUserSubStreamAvailable ${uid}, ${available}`);
      if (available) {
        this.showRemoteScreenSharing(uid);
      } else {
        this.closeRemoteScreenSharing(uid);
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
      let view = document.getElementById(id);
      if (!view) {
        view = document.createElement('div');
        view.id = id;
        view.style.width = `${W}px`;
        view.style.height = `${H}px`;
        this.videoContainer.appendChild(view);
      }
      this.remoteVideos[id] = view;
      trtcCloud.startRemoteSubStreamView(uid, view);
      trtcCloud.setRemoteSubStreamViewFillMode(uid, TRTCVideoFillMode.TRTCVideoFillMode_Fill);
      this.videoTypeSettingAutoWrap();
    },

    /**
     * 关闭远程用户的屏幕分享
     *
     * @param {*} uid
     */
    closeRemoteScreenSharing (uid) {
      let id = `${uid}-${this.roomId}-${TRTCVideoStreamType.TRTCVideoStreamTypeSub}`;
      let view = document.getElementById(id);
      if (view) {
        this.videoContainer.removeChild(view);
      }
      delete this.remoteVideos[id];
    },

    /** 
     * 离开房间
    */
    exitRoom(event) {
      logger.log('exitRoom', event);
      trtcCloud.exitRoom();
      let my = this;
      
      setTimeout(()=>{
        my.$router.push('/live-index/audience');
      }, 0 );
    },

    /** 
     * 退出并清除房间
     */
    exitAndDeleteRoom() {
      destroyLiveRoom(this.roomId);
      this.exitRoom();
    }

  },

  mounted() {
    // 1. 获取用于承载视频的 HTMLElement；
    this.videoContainer = document.querySelector('#video-container');
    logger.log(`mounted: `, this.$route.params);

    // 获取 vue-router 传参：userId 和 roomId
    this.roomId = parseInt(this.$route.params.roomId); // roomId 为整数类型
    this.userId = this.$route.params.userId; // userId 为字符串类型

    if (!this.roomId || !this.userId) {
      this.$bvToast.toast('roomId 或 userId 为空，请填写后再试。');
      this.$router.push('live-index/audience');
      return;
    }

    // 2. 计算签名
    this.sdkInfo = genTestUserSig(this.userId);

    mtaH5.reportSDKAppID(this.sdkInfo.sdkAppId);

    // 3. 实例化一个 TRTCCloud （包装了 TRTCCloud的类）
    trtcCloud = new TRTCCloud();
    logger.warn(`sdk version: ${trtcCloud.getSDKVersion()}`);

    // 4. 配置基本的事件订阅
    trtcCloud.on('onEnterRoom', this.onEnterRoom.bind(this));
    trtcCloud.on('onExitRoom', this.onExitRoom.bind(this));
    trtcCloud.on('onUserVideoAvailable', this.onUserVideoAvailable.bind(this));
    trtcCloud.on('onRemoteUserEnterRoom', this.onRemoteUserEnterRoom.bind(this));
    trtcCloud.on('onRemoteUserLeaveRoom', this.onRemoteUserLeaveRoom.bind(this));
    trtcCloud.on('onUserSubStreamAvailable', this.onUserSubStreamAvailable.bind(this));

    // 5. 进入房间
    // TRTCParams 详细说明，请查看文档：https://web.sdk.qcloud.com/trtc/electron/doc/zh-cn/trtc_electron_sdk/TRTCParams.html
    let param = new TRTCParams();
    param.sdkAppId = this.sdkInfo.sdkappid;
    param.userSig = this.sdkInfo.userSig;
    param.roomId = this.roomId;
    param.userId = this.userId;
    param.privateMapKey = ''; // 房间签名（非必填）7.1.157 版本以上（含），可以忽略此参数，7.1.157 之前的版本建议赋值为空字符串
    param.businessInfo = ''; // 业务数据（非必填）7.1.157 版本以上（含），可以忽略此参数，7.1.157 之前的版本建议赋值为空字符串
    param.role = TRTCRoleType.TRTCRoleAudience; // 直播场景下的角色，仅适用于直播场景（TRTCAppSceneLIVE 和 TRTCAppSceneVoiceChatRoom），视频通话场景下指定无效。默认值：主播（TRTCRoleAnchor）
    trtcCloud.enterRoom(param, TRTCAppScene.TRTCAppSceneLIVE);

    // 挂到 windows BOM 下，方便调试。
    window.trtc = trtcCloud;
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
</style>
<style>
.user-video-container-auto-wrap {
  float: left;
  overflow: hidden;
}
</style>
<style>
.anchor-view {
  width: 100vw;
  height: 101vh;
}
</style>
