const TRTCCloud = require('trtc-electron-sdk');
const {
  TRTCVideoStreamType,
  TRTCVideoResolution,
  TRTCVideoFillMode,
  TRTCVideoQosPreference,
  TRTCQosControlMode,
  TRTCAppScene,
  TRTCRoleType,
  TRTCVideoResolutionMode,
  TRTCBeautyStyle,
  TRTCDeviceType,
  TRTCDeviceState,
  TRTCTranscodingConfigMode,
  TRTCVideoPixelFormat,
  TRTCVideoBufferType
} = require('trtc-electron-sdk/liteav/trtc_define');
const {
  TRTCParams,
  TRTCVideoEncParam,
  TRTCNetworkQosParam,
  TRTCTranscodingConfig, 
  TRTCMixUser,
  Rect,
  TRTCVideoFrame
} = require('trtc-electron-sdk/liteav/trtc_define');
const ipc = require('electron').ipcRenderer;
const Store = require('electron-store');
const store = new Store();

// 移除数组中的某个元素
Array.prototype.remove = function (val) {
  var index = this.indexOf(val);
  if (index > -1) {
    this.splice(index, 1);
  }
};

function getRandom(num) {
  return Math.floor((Math.random() + Math.floor(Math.random() * 9 + 1)) * Math.pow(10, num - 1));
};

let demoApp = new Vue({
  el: '#demo_app',
  data() {
    return {
      rtcCloud: null,
      version: '',

      //用户信息
      userId: "",
      roomId: "",

      //变量
      muteLocalVideo: false,
      muteLocalAudio: false,
      localMirror: false,
      encoderMirror: false,
      screenCapture: false,
      showVoice: false,

      inroom: false,

      // 屏幕信息
      screenList: null,
      screenName: '',

      // SDK 配置信息
      openSettingDialog: false,
      videoResolution: TRTCVideoResolution.TRTCVideoResolution_640_480,
      videoFillMode: TRTCVideoFillMode.TRTCVideoFillMode_Fill,
      videoResolutionList: [],
      videoFps: 15,
      videoFpsList: [],
      videoBitrate: 600,
      qosPreference: TRTCVideoQosPreference.TRTCVideoQosPreferenceSmooth,
      qosPreferenceList: [],
      qosControlMode: TRTCQosControlMode.TRTCQosControlModeServer,
      qosControlModeList: [],
      appScene: TRTCAppScene.TRTCAppSceneVideoCall,
      appSceneList: [],
      videoResolutionMode: TRTCVideoResolutionMode.TRTCVideoResolutionModeLandscape,
      videoResolutionModeList: [],
      playSmallVideo: false, // 观看低清
      pushSmallVideo: false, // 双路编码
      // 是否为纯音频进房
      pureAudioStyle: false,

      // 设备信息
      openDeviceDialog: false,
      cameraDeviceName: '',
      cameraList: [],
      micDeviceName: '',
      micVolume: 0,
      micList: [],
      speakerDeviceName: '',
      speakerVolume: 0,
      speakerList: [],
      testCamera: false,
      testMic: false,
      testMicVolume: 0,
      testSpeaker: false,
      testSpeakerVolume: 0,
      testBGM: false,

      // mac 打包后资源存放在“Contents/Resources”中， win 打包存放在“resources”中， demo 引用路径在“resources”中
      //testPath: process.resourcesPath + '/testspeak.mp3',
      testPath: __dirname + '/resources/testspeak.mp3',

      // 美颜信息
      openBeautyDialog: false,
      openBeauty: false,
      beautyStyle: TRTCBeautyStyle.TRTCBeautyStyleNature,
      beauty: 5,     // 磨皮级别
      white: 5,      // 美白级别
      ruddiness: 0,  // 红润级别，(Windows 平台暂未生效)

      // 跨房通话
      openConnectDialog: false,
      connectLoading: false,
      connected: false,
      connectLoadingText: '',
      pkUsers: [],
      pkUserId: '',
      pkRoomId: '',

      // 混流设置
      mixTranscoding: false,
      mixStreamInfos: [],    // 每一路需要混流的信息（不包括当前用户主流）

      // 在房间中的用户（包括本地用户）
      users: [],
    }
  },
  mounted: function () {
    // 重要点, 创建 TRTC 对象
    this.rtcCloud = new TRTCCloud();

    let self = this;
    ipc.on('app-close', () => {
      if (self.inroom) {
        self.exitRoom();
      }
      self.rtcCloud.destroy();
      this.setLocalStore();
      if (process.platform !== 'darwin') {
        ipc.send('closed');
      }
    });

    console.log("TRTCCloud ...");
    this.version = this.rtcCloud.getSDKVersion();

    this.userId = getRandom(6).toString();
    this.roomId = getRandom(3);

    this.initSDKLocalData();
    this.getLocalStore();

    subscribeEvents = (rtcCloud) => {
      rtcCloud.on('onError', (errcode, errmsg) => {
        console.error('trtc_demo: onError:' + errcode + " msg:" + errmsg);
        this.notify('Error: ' + errcode + '<br/>Message: ' + errmsg, 'error', '错误');
      });
      rtcCloud.on('onWarning', (warncode, warnmsg) => {
        console.warn('trtc_demo: onWarning:' + warncode + " msg:" + warnmsg);
        this.notify('Warn: ' + warncode + '<br/>Message: ' + warnmsg, 'warning', '警告');
      });

      rtcCloud.on('onEnterRoom', (result) => {
        console.info('trtc_demo: onEnterRoom elapsed:' + result);
        if (result > 0) {
          // 进房成功，添加本地用户
          this.users.push("local_video");
          this.notify('加入房间成功，耗时' + result + '毫秒');
          this.inroom = true;
        } else {
          // 进房失败
          console.error('trtc_demo: onEnterRoom failed.');
          this.notify('加入房间失败，errCode:' + result, 'error', '错误');
          this.inroom = false;
        }
      });
      rtcCloud.on('onExitRoom', (reason) => {
        console.info('trtc_demo: onExitRoom reason:' + reason);
        this.destroyAllVideoView();
        this.notify('退出房间成功');
        this.inroom = false;
      });

      rtcCloud.on('onRemoteUserEnterRoom', (uid) => {
        console.info('trtc_demo: onRemoteUserEnterRoom uid:' + uid);
        this.users.push(uid);
        let result = this.pkUsers.find((element) => { return element.userId === uid; });
        if (result !== undefined) {
          this.notify('连麦用户[' + uid + ']进入房间');
        } else {
          this.notify('用户[' + uid + ']进入房间');
        }
      });
      rtcCloud.on('onRemoteUserLeaveRoom', (uid, reason) => {
        console.info('trtc_demo: onRemoteUserLeaveRoom uid:' + uid + " reason:" + reason);
        this.users.remove(uid);
        let result = this.pkUsers.find((element) => { return element.userId === uid; });
        if (result !== undefined) {
          this.pkUsers.remove(result);
          this.notify('连麦用户[' + uid + ']离开房间');
        } else {
          this.notify('用户[' + uid + ']退出房间');
        }
        if (this.pkUsers.length == 0) {
          this.connected = false;
        }
      });

      // 远程视频用户状态监听，在此创建一个Dom结点，然后给trtc，由trtc负责绘制
      rtcCloud.on('onUserVideoAvailable', (uid, available) => {
        console.info('trtc_demo: onUserVideoAvailable uid:' + uid + "|available:" + available);
        // bugfix：注意 mac 平台下中文用户进房 userId 返回空，待解决
        if (available) {
          // 画面不区分大小流，只区分主流和辅流，这里统一使用主流当做 key
          let view = this.findVideoView(uid, TRTCVideoStreamType.TRTCVideoStreamTypeBig);
          this.setVisibleVoice(this.showVoice, uid, TRTCVideoStreamType.TRTCVideoStreamTypeBig);
          this.rtcCloud.startRemoteView(uid, view);
          // 填充模式需要在设置 view 后才生效
          this.rtcCloud.setRemoteViewFillMode(uid, this.videoFillMode);


          this.rtcCloud.setRemoteVideoRenderCallback(
            uid,
            TRTCVideoPixelFormat.TRTCVideoPixelFormat_BGRA32, 
            TRTCVideoBufferType.TRTCVideoBufferType_Buffer, 
            /**
             * 
             * @param userId     用户标识
             * @param streamType	流类型：即摄像头还是屏幕分享
             * @param videoframe      视频帧数据
             */
            (userId, streamType, videoframe) => {
              //console.info("onRenderVideoFrame, remote " + userId + "|" + streamType + "|" + videoframe.length);
          });

        }
        else {
          this.rtcCloud.stopRemoteView(uid);
          this.destroyVideoView(uid, TRTCVideoStreamType.TRTCVideoStreamTypeBig);
          // 移除混流画面信息
          let index = this.mixStreamInfos.findIndex(function (item) {
            return item.userId === uid && item.streamType !== TRTCVideoStreamType.TRTCVideoStreamTypeSub;
          });
          if (index != -1) {
            this.mixStreamInfos.splice(index, 1);
          }
          this.updateMixTranscodeInfo();
        }
      });

      // 远程视频用户辅流状态监听
      rtcCloud.on('onUserSubStreamAvailable', (uid, available) => {
        console.info('trtc_demo: onUserSubStreamAvailable uid:' + uid + "|available:" + available);
        if (available) {
          let view = this.findVideoView(uid, TRTCVideoStreamType.TRTCVideoStreamTypeSub);
          this.rtcCloud.startRemoteSubStreamView(uid, view);
          // 填充模式需要在设置 view 后才生效
          this.rtcCloud.setRemoteSubStreamViewFillMode(uid, this.videoFillMode);
        }
        else {
          this.rtcCloud.stopRemoteSubStreamView(uid);
          this.destroyVideoView(uid, TRTCVideoStreamType.TRTCVideoStreamTypeSub);
          // 移除混流画面信息
          let index = this.mixStreamInfos.findIndex(function (item) {
            return item.userId === uid && item.streamType === TRTCVideoStreamType.TRTCVideoStreamTypeSub;
          });
          if (index != -1) {
            this.mixStreamInfos.splice(index, 1);
          }
          this.updateMixTranscodeInfo();
        }
      });

      // 音视频首帧接收回调监听
      rtcCloud.on('onFirstVideoFrame', (userId, streamType, width, height) => {
        console.info('trtc_demo: onFirstVideoFrame userId:' + userId + "|streamType:" + streamType + "|width:" + width + "|height:" + height);
        // 添加用户的混流信息（包括本地和远端用户），并实时更新混流信息
        if (userId === null || userId === "") {
          userId = this.userId;
        }
        let find = false;
        this.mixStreamInfos.forEach(function (item) {
          if (find || item.userId !== userId) return;
          // 这里有两种情况（ userId 相同说明当前首帧用户的一路画面已在混流中）
          // 1. 流类型与当前混流的一路相同，无需添加
          // 2. 流类型与当前混流类型不同，主流中的大小流切换了，需要重新设置这路画面的 streamType
          if (item.streamType === streamType) {
            item.width = width;
            item.height = height;
            find = true;
          } else if (streamType !== TRTCVideoStreamType.TRTCVideoStreamTypeSub) {
            item.streamType = streamType;
            find = true;
          }
        });
        if (!find && !(streamType === TRTCVideoStreamType.TRTCVideoStreamTypeBig && userId === this.userId)) {
          let mixUser = {
            userId: userId,
            roomId: '',
            streamType: streamType,
            width: width,
            height: height,
            fps: 15,
            pureAudio: this.pureAudioStyle,
          };
          this.mixStreamInfos.push(mixUser);
          this.updateMixTranscodeInfo();
        } else {
          if (userId !== this.userId) {
            this.updateMixTranscodeInfo();
          }
        }
      });
      rtcCloud.on('onFirstAudioFrame', (userId) => {
        console.info('trtc_demo: onFirstAudioFrame userId:' + userId);
      });

      // 音视频首帧发送回调监听
      rtcCloud.on('onSendFirstLocalVideoFrame', (streamType) => {
        console.info('trtc_demo: onSendFirstLocalVideoFrame streamType:' + streamType);
      });
      rtcCloud.on('onSendFirstLocalAudioFrame', () => {
        console.info('trtc_demo: onSendFirstLocalAudioFrame');
      });

      // 音量提示回调监听
      rtcCloud.on('onUserVoiceVolume', (userVolumes, userVolumesCount, totalVolume) => {
        if (userVolumesCount <= 0) return;
        if (!this.showVoice) return;
        for (var i = 0; i < userVolumesCount; i++) {
          let userVolume = userVolumes[i];
          if (userVolume) {
            let key;
            if (userVolume.userId === undefined || userVolume.userId === null || userVolume.userId === "") {
              key = "local_video_" + TRTCVideoStreamType.TRTCVideoStreamTypeBig;
            } else {
              key = userVolume.userId + '_' + TRTCVideoStreamType.TRTCVideoStreamTypeBig;
            }
            let voiceEl = document.getElementById(key + "_voice_inner");
            if (voiceEl) {
              voiceEl.style.width = userVolume.volume + "%";
            }
          }
        }
      });

      // 跨房连麦回调监听
      rtcCloud.on('onConnectOtherRoom', (userId, errCode, errMsg) => {
        console.info('trtc_demo: onConnectOtherRoom userId:' + userId + "|errCode:" + errCode + "|errMsg:" + errMsg);
        if (userId !== this.pkUserId) return;
        // 错误码为 ERR_NULL 时，连麦成功
        if (errCode === 0) {
          this.connected = true;
          this.notify('连麦成功:[room: ' + this.pkRoomId + ', user: ' + this.pkUserId + ']', 'success');
          this.pkUsers.push({ userId: this.pkUserId, roomId: parseInt(this.pkRoomId) });
        } else {
          // 连麦失败
          this.notify('连麦失败[userId:' + this.pkUserId + ', roomId:' + this.pkRoomId + ', errCode:' + errCode + ', msg:' + errMsg + ']')
        }
        this.connectLoading = false;
      });
      rtcCloud.on('onDisconnectOtherRoom', (errCode, errMsg) => {
        console.info('trtc_demo: onDisconnectOtherRoom errCode:' + errCode + "|errMsg:" + errMsg);
        // 错误码为 ERR_NULL 时，取消连麦成功
        if (errCode === 0) {
          this.connected = false;
          this.notify('取消连麦成功', 'success');
          this.pkUsers.splice(0, this.pkUsers.length);
        } else {
          // 取消连麦失败
          this.notify('取消连麦失败[userId:' + this.pkUserId + ', roomId:' + this.pkRoomId + ', errCode:' + errCode + ', msg:' + errMsg + ']');
        }
        this.connectLoading = false;
      });

      // 网络质量指标回调，每2秒回调1次，具体参数属性查看 TRTCQualityInfo
      rtcCloud.on('onNetworkQuality', (localQuality, remoteQuality) => {
        // console.debug('trtc_demo: onNetworkQuality userId:' + localQuality.userId + "|quality:" + localQuality.quality);
        // for (var i = 0; i < remoteQuality.length; i++) {
        //   console.debug('trtc_demo: onNetworkQuality remote userId:' + remoteQuality[i].userId + "|quality:" + remoteQuality[i].quality);
        // }
      });
      // 技术指标统计回调，每2秒回调1次，具体参数属性查看 TRTCStatistics
      rtcCloud.on('onStatistics', (statis) => {
        // console.debug('trtc_demo: onStatistics upLoss:' + statis.upLoss + "|downLoss:" + statis.downLoss + "|appCpu:" + statis.appCpu +
        //   "|systemCpu:" + statis.systemCpu + "|rtt:" + statis.rtt + "|localStatisticsArraySize:" + statis.localStatisticsArraySize +
        //   "|remoteStatisticsArraySize:" + statis.remoteStatisticsArraySize);
        // for (var i = 0; i < statis.localStatisticsArraySize; i++) {
        //   var localStatis = statis.localStatisticsArray[i];
        //   console.debug('trtc_demo: localStatis width:' + localStatis.width + "|height: " + localStatis.height + "|frameRate:" + localStatis.frameRate +
        //     "|videoBitrate:" + localStatis.videoBitrate + "|audioSampleRate:" + localStatis.audioSampleRate + "|audioBitrate:" + localStatis.audioBitrate +
        //     "|streamType:" + localStatis.streamType);
        // }
        // for (var i = 0; i < statis.remoteStatisticsArraySize; i++) {
        //   var remoteStatis = statis.remoteStatisticsArray[i];
        //   console.debug('trtc_demo: remoteStatis userId:' + remoteStatis.userId + "|finalLoss:" + remoteStatis.finalLoss + "|width:" + remoteStatis.width +
        //     "|height: " + remoteStatis.height + "|frameRate:" + remoteStatis.frameRate + "|videoBitrate:" + remoteStatis.videoBitrate +
        //     "|audioSampleRate:" + remoteStatis.audioSampleRate + "|audioBitrate:" + remoteStatis.audioBitrate + "|streamType:" + remoteStatis.streamType);
        // }
      });

      // 屏幕共享回调监听
      rtcCloud.on('onScreenCaptureCovered', () => {
        console.info('trtc_demo: onScreenCaptureCovered');
      });
      rtcCloud.on('onScreenCaptureStarted', () => {
        console.info('trtc_demo: onScreenCaptureStarted');
      });
      rtcCloud.on('onScreenCaptureStoped', (reason) => {
        console.info('trtc_demo: onScreenCaptureStoped reason:' + reason);
      });

      // 麦克风音量回调监听
      rtcCloud.on('onTestMicVolume', (volume) => {
        this.testMicVolume = volume;
      });
      // 扬声器音量回调监听
      rtcCloud.on('onTestSpeakerVolume', (volume) => {
        this.testSpeakerVolume = volume;
      });

      // BGM 状态回调监听
      rtcCloud.on('onPlayBGMBegin', (errCode) => {
        console.info('trtc_demo: onPlayBGMBegin errCode:' + errCode);
      });
      rtcCloud.on('onPlayBGMProgress', (progressMS, durationMS) => {
        // console.info('trtc_demo: onPlayBGMProgress progress:' + progressMS + '|duration:' + durationMS);
      });
      rtcCloud.on('onPlayBGMComplete', (errCode) => {
        console.info('trtc_demo: onPlayBGMComplete errCode:' + errCode);
      });

      rtcCloud.on('onSetMixTranscodingConfig', (errcode, errmsg) => {
        console.info('trtc_demo: onSetMixTranscodingConfig errCode:' + errcode + '|errmsg:' + errmsg);
      });

      // 设备状态监控回调
      rtcCloud.on('onDeviceChange', (deviceId, type, state) => {
        // 实时监控本地设备的拔插
        console.info('trtc_demo: onDeviceChange deviceId:' + deviceId + '|type:' + type + '|state:' + state);
        if (type === TRTCDeviceType.TRTCDeviceTypeCamera) {
          this.cameraList = this.rtcCloud.getCameraDevicesList();
          let select = false;
          if (state === TRTCDeviceState.TRTCDeviceStateRemove) {
            // 选择设备被移除了，尝试选择其他设备
            if (this.cameraDeviceName === deviceId) {
              select = true;
              this.destroyVideoView("local_video", TRTCVideoStreamType.TRTCVideoStreamTypeBig)
            }
          } else if (state === TRTCDeviceState.TRTCDeviceStateAdd) {
            // 如果之前没有设备，此时添加了设备，则重新选择
            if (this.cameraDeviceName === '') {
              select = true;
            }
          }
          if (select) {
            if (this.cameraList.length > 0) {
              this.rtcCloud.setCurrentCameraDevice(this.cameraList[0].deviceName);
              this.cameraDeviceName = this.cameraList[0].deviceName;
              // 重新选择设备后需要重新打开采集摄像头
              let view = this.findVideoView("local_video", TRTCVideoStreamType.TRTCVideoStreamTypeBig);
              this.rtcCloud.startLocalPreview(view);
            } else {
              this.cameraDeviceName = '';
            }
          }
        } else if (type === TRTCDeviceType.TRTCDeviceTypeMic) {
          this.micList = this.rtcCloud.getMicDevicesList();
          let select = false;
          if (state === TRTCDeviceState.TRTCDeviceStateRemove) {
            // 选择设备被移除了，尝试选择其他设备
            if (this.micDeviceName === deviceId) {
              select = true;
            }
          } else if (state === TRTCDeviceState.TRTCDeviceStateAdd) {
            // 如果之前没有设备，此时添加了设备，则重新选择
            if (this.micDeviceName === '') {
              select = true;
            }
          }
          if (select) {
            if (this.micList.length > 0) {
              this.rtcCloud.setCurrentMicDevice(this.micList[0].deviceName);
              this.micDeviceName = this.micList[0].deviceName;
            } else {
              this.micDeviceName = '';
            }
          }
        }
      });
    };
    subscribeEvents(this.rtcCloud);
  },
  methods: {
    // 填充模式
    onVideoFillMode() {
      for (var i = 0; i < this.users.length; i++) {
        if (this.users[i] === this.userId) {
          this.rtcCloud.setLocalViewFillMode(this.videoFillMode);
        } else {
          this.rtcCloud.setRemoteViewFillMode(this.users[i], this.videoFillMode);
        }
      }
    },
    // 屏蔽视频
    onMuteLocalVideo() {
      this.setVisibleView(!this.muteLocalVideo, "local_video", TRTCVideoStreamType.TRTCVideoStreamTypeBig)
      this.rtcCloud.muteLocalVideo(this.muteLocalVideo);
    },
    // 屏蔽音频
    onMuteLocalAudio() {
      this.rtcCloud.muteLocalAudio(this.muteLocalAudio);
    },
    // 本地镜像
    onOpenLocalMirror() {
      this.rtcCloud.setLocalViewMirror(this.localMirror);
    },
    // 远程镜像
    onOpenEncoderMirror() {
      this.rtcCloud.setVideoEncoderMirror(this.encoderMirror);
    },
    // 音量提示
    onShowVoiceVolume() {
      if (this.showVoice) {
        this.rtcCloud.enableAudioVolumeEvaluation(200);
      } else {
        this.rtcCloud.enableAudioVolumeEvaluation(0);
      }
      for (var i = 0; i < this.users.length; i++) {
        this.setVisibleVoice(this.showVoice, this.users[i], TRTCVideoStreamType.TRTCVideoStreamTypeBig);
      }
    },
    // 更新视频编码配置
    onVideoEncoderChanged() {
      let param = new TRTCVideoEncParam();
      param.videoResolution = this.videoResolution;
      param.resMode = this.videoResolutionMode;
      param.videoFps = this.videoFps;
      param.videoBitrate = this.videoBitrate;
      this.rtcCloud.setVideoEncoderParam(param);
    },
    // 更新视频网络配置
    onVideoQosChanged() {
      let param = new TRTCNetworkQosParam();
      param.preference = this.qosPreference;
      param.controlMode = this.qosControlMode;
      this.rtcCloud.setNetworkQosParam(param);
    },
    // 双路编码
    onPushSmallVideo() {
      let param = new TRTCVideoEncParam();
      param.videoFps = 15;
      param.videoBitrate = 100;
      param.videoResolution = TRTCVideoResolution.TRTCVideoResolution_320_240;
      param.resMode = this.videoResolutionMode;
      this.rtcCloud.enableSmallVideoStream(this.pushSmallVideo, param);
    },
    // 观看低清
    onPlaySmallVideo() {
      if (this.playSmallVideo) {
        this.rtcCloud.setPriorRemoteVideoStreamType(TRTCVideoStreamType.TRTCVideoStreamTypeSmall);
      } else {
        this.rtcCloud.setPriorRemoteVideoStreamType(TRTCVideoStreamType.TRTCVideoStreamTypeBig);
      }
    },
    // 美颜
    onOpenBeauty() {
      if (this.openBeauty) {
        this.rtcCloud.setBeautyStyle(this.beautyStyle, this.beauty, this.white, this.ruddiness);
      } else {
        this.rtcCloud.setBeautyStyle(this.beautyStyle, 0, 0, 0);
      }
    },
    // 摄像头选择
    onCameraDeviceSelect() {
      this.rtcCloud.setCurrentCameraDevice(this.cameraDeviceName);
    },
    // 摄像头测试
    onTestCameraChanged() {
      let key = "camera_device_video_view";
      if (this.testCamera) {
        let cameraTestVideoEl = document.getElementById(key);
        if (!cameraTestVideoEl) {
          cameraTestVideoEl = document.createElement('div');
          cameraTestVideoEl.id = key;
          cameraTestVideoEl.classList.add('camera_test_video_view');
          document.querySelector("#camera_device_video_wrap").appendChild(cameraTestVideoEl);
        }
        this.rtcCloud.startCameraDeviceTest(cameraTestVideoEl);
      } else {
        // 暂时不需要主动调用 stopCameraDeviceTest 这样会导致 Renderer 失效
        let cameraTestVideoEl = document.getElementById(key);
        if (cameraTestVideoEl) {
          document.querySelector("#camera_device_video_wrap").removeChild(cameraTestVideoEl);
        }
      }
    },
    // 麦克风选择
    onMicDeviceSelect() {
      this.rtcCloud.setCurrentMicDevice(this.micDeviceName);
    },
    // 麦克风测试
    onTestMicChanged() {
      if (this.testMic) {
        this.rtcCloud.startMicDeviceTest(300);
      } else {
        this.rtcCloud.stopMicDeviceTest();
        this.testMicVolume = 0;
      }
    },
    // 麦克风音量
    onMicVolumeChanged() {
      this.rtcCloud.setCurrentMicDeviceVolume(this.micVolume);
    },
    // 扬声器选择
    onSpeakerDeviceSelect() {
      this.rtcCloud.setCurrentSpeakerDevice(this.speakerDeviceName);
    },
    // 扬声器测试
    onTestSpeakerChanged() {
      if (this.testSpeaker) {
        this.rtcCloud.startSpeakerDeviceTest(this.testPath);
      } else {
        this.rtcCloud.stopSpeakerDeviceTest();
        this.testSpeakerVolume = 0;
      }
    },
    // 扬声器音量变化
    onSpeakerVolumeChanged() {
      this.rtcCloud.setCurrentSpeakerVolume(this.speakerVolume);
    },
    // BGM 测试
    onTestBGMChanged() {
      if (this.testBGM) {
        this.rtcCloud.playBGM(this.testPath);
      } else {
        this.rtcCloud.stopBGM();
      }
    },

    // 云端画面混合
    onMixTransCoding() {
      if (this.mixTranscoding) {
        this.updateMixTranscodeInfo();
      } else {
        this.rtcCloud.setMixTranscodingConfig(null);
      }
    },
    // 更新云端混流界面信息（本地用户进房或远程用户进房或开启本地屏幕共享画面则更新，可根据需求设置混哪一路画面）
    updateMixTranscodeInfo() {
      // 没有打开云端混流功能则退出
      if (!this.mixTranscoding) return;
      // 云端混流的没有辅流界面，则退出（无需混流）
      if (this.mixStreamInfos.length == 0) {
        this.rtcCloud.setMixTranscodingConfig(null);
        return;
      }
      // 如果使用的是纯音频进房，则需要混流设置每一路为纯音频，云端会只混流音频数据
      if (this.pureAudioStyle) {
        this.mixStreamInfos.forEach(function (item) {
          item.pureAudio = true;
        });
      }
      // 没有主流，直接停止混流
      if (this.muteLocalVideo && this.muteLocalAudio) {
        this.rtcCloud.setMixTranscodingConfig(null);
        return;
      }
      // 连麦后的 User 可进行设置对应的 roomId
      let self = this;
      this.pkUsers.forEach(function (users) {
        let index = self.mixStreamInfos.findIndex(function (item) {
          return users.userId === item.userId;
        });
        if (index !== -1) {
          self.mixStreamInfos[index].roomId = users.roomId.toString();
        }
      });
      // 配置本地主流的混流信息（可根据自己的需求设置参数，下面仅供参考）
      let localMainStream = {
        userId: this.userId,
        roomId: '',
        streamType: TRTCVideoStreamType.TRTCVideoStreamTypeBig,
        width: 960,
        height: 720,
        fps: 15,
        pureAudio: this.pureAudioStyle,
      };
      // 这里的显示混流的方式只提供参考，如需其他需求请参考以下方式实现
      let sdkInfo = genTestUserSig(this.userId);
      if (sdkInfo.appId == 0 || sdkInfo.bizId == 0) {
        this.notify('混流功能不可使用，请在 GenerateTestUserSig.js 填写混流的账号信息');
        return;
      }
      let config = new TRTCTranscodingConfig();
      config.mode = TRTCTranscodingConfigMode.TRTCTranscodingConfigMode_Manual;
      config.appId = sdkInfo.appId;
      config.bizId = sdkInfo.bizId;
      config.videoWidth = localMainStream.width;
      config.videoHeight = localMainStream.height;
      config.videoBitrate = 800;
      config.videoFramerate = 15;
      config.videoGOP = 1;
      config.audioSampleRate = 48000;
      config.audioBitrate = 64;
      config.audioChannels = 1;
      config.mixUsersArraySize = 1 + this.mixStreamInfos.length;
      config.mixUsersArray = [];
      // 设置每一路子画面的位置信息（仅供参考）
      let zOrder = 1, i = 0;
      let localMainView = new TRTCMixUser();
      localMainView.userId = localMainStream.userId;
      localMainView.roomId = localMainStream.roomId;
      localMainView.rect = new Rect();
      localMainView.rect.left = 0;
      localMainView.rect.top = 0;
      localMainView.rect.right = localMainStream.width;
      localMainView.rect.bottom = localMainStream.height;
      localMainView.zOrder = zOrder++;
      localMainView.pureAudio = this.pureAudioStyle;
      localMainView.streamType = localMainStream.streamType;
      let mixWidth = 160, mixHeight = 120;
      config.mixUsersArray.push(localMainView);
      this.mixStreamInfos.forEach(function (item) {
        ++i;
        let left = parseInt(config.videoWidth - (i % 5) * (mixWidth + 10));
        let top = parseInt(config.videoHeight - (mixHeight + 20));
        let mixUser = new TRTCMixUser();
        mixUser.userId = item.userId;
        mixUser.roomId = item.roomId <= 0 ? '' : item.roomId.toString();
        mixUser.rect = new Rect();
        mixUser.rect.left = left;
        mixUser.rect.top = top;
        mixUser.rect.right = mixWidth + left;
        mixUser.rect.bottom = mixHeight + top;
        mixUser.zOrder = zOrder++;
        mixUser.pureAudio = item.pureAudio;
        mixUser.streamType = item.streamType;
        config.mixUsersArray.push(mixUser);
      });
      this.rtcCloud.setMixTranscodingConfig(config);
    },

    // 屏幕分享
    onStartScreenCapture() {
      // 打开屏幕分享
      if (this.screenCapture) {
        this.screenList = this.rtcCloud.getScreenCaptureSources(120, 70, 20, 20);
        let encparam = new TRTCVideoEncParam();
        encparam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_640_480;
        encparam.resMode = TRTCVideoResolutionMode.TRTCVideoResolutionModeLandscape;
        encparam.videoFps = 15;
        encparam.videoBitrate = 600;
        this.rtcCloud.setSubStreamEncoderParam(encparam);
      }
      else {
        this.screenName = "";
        this.rtcCloud.stopScreenCapture();
        this.destroyVideoView("local_video", TRTCVideoStreamType.TRTCVideoStreamTypeSub);

        // 移除混流画面信息
        let self = this;
        let index = this.mixStreamInfos.findIndex(function (item) {
          return item.userId === self.userId && item.streamType === TRTCVideoStreamType.TRTCVideoStreamTypeSub;
        });
        if (index !== -1) {
          this.mixStreamInfos.splice(index, 1);
        }
        this.updateMixTranscodeInfo();
      }
    },

    onSelectScreenCapture(sourceId) {
      // 选择屏幕分享
      if (this.screenCapture) {
        let source;
        for (var i = 0; i < this.screenList.length; i++) {
          if (this.screenList[i].sourceId == sourceId) {
            source = this.screenList[i];
            break;
          }
        }
        if (source === null || source === undefined) return;
        this.screenName = source.sourceName;
        let rect = new Rect(0, 0, 0, 0);
        let mouse = true, highlight = true;

        this.rtcCloud.selectScreenCaptureTarget(source.type, source.sourceId, source.sourceName, rect, mouse, highlight);
        // windows 平台支持本地屏幕共享预览画面， mac 平台暂时不支持。
        // let view = this.findVideoView("local_video", TRTCVideoStreamType.TRTCVideoStreamTypeSub);
        this.rtcCloud.startScreenCapture();
      }
    },

    // 进房
    enterRoom() {
      if (this.userId === null || this.userId === "" || this.roomId === null || this.roomId === "") {
        this.notify('房间号或用户号不能为空！', 'warning', '警告');
        return;
      }

      let sdkInfo = genTestUserSig(this.userId);
      let userSig = sdkInfo.userSig;
      if (sdkInfo.sdkappid === 0 || userSig === undefined || userSig === null || userSig === "") {
        this.notify('请填写SDKAPPID信息！', 'warning', '警告');
        return;
      }

      // 1.进房参数
      let param = new TRTCParams();
      param.sdkAppId = sdkInfo.sdkappid;
      param.roomId = parseInt(this.roomId);
      param.userId = this.userId;
      param.userSig = userSig;
      param.privateMapKey = '';
      param.businessInfo = '';
      //param.role = TRTCRoleType.TRTCRoleAudience;
      //this.appScene = TRTCAppScene.TRTCAppSceneLIVE;
      this.rtcCloud.enterRoom(param, this.appScene);
      
      this.rtcCloud.setLocalVideoRenderCallback(
        TRTCVideoPixelFormat.TRTCVideoPixelFormat_BGRA32, 
        TRTCVideoBufferType.TRTCVideoBufferType_Buffer, 
        /**
         * 
         * @param userId     用户标识
         * @param streamType	流类型：即摄像头还是屏幕分享
         * @param videoframe      视频帧数据
         */
        (userId, streamType, videoframe) => {
          //console.info("onRenderVideoFrame, Local " + userId + "|" + streamType + "|" + videoframe.length);
      });

      // 2.编码参数
      let encParam = new TRTCVideoEncParam();
      encParam.videoResolution = this.videoResolution;
      encParam.resMode = this.videoResolutionMode;
      encParam.videoFps = this.videoFps;
      encParam.videoBitrate = this.videoBitrate;
      this.rtcCloud.setVideoEncoderParam(encParam);

      this.rtcCloud.setLocalViewMirror(this.localMirror);
      this.rtcCloud.setVideoEncoderMirror(this.encoderMirror);
      if (this.openBeauty) {
        this.rtcCloud.setBeautyStyle(this.beautyStyle, this.beauty, this.white, this.ruddiness);
      }

      if (this.pushSmallVideo) {
        let param = new TRTCVideoEncParam();
        param.videoFps = 15;
        param.videoBitrate = 100;
        param.videoResolution = TRTCVideoResolution.TRTCVideoResolution_320_240;
        param.resMode = this.videoResolutionMode;
        this.rtcCloud.enableSmallVideoStream(this.pushSmallVideo, param);
      }
      if (this.playSmallVideo) {
        this.rtcCloud.setPriorRemoteVideoStreamType(TRTCVideoStreamType.TRTCVideoStreamTypeSmall);
      }

      //3. 打开采集和预览本地视频、采集音频
      let view = this.findVideoView("local_video", TRTCVideoStreamType.TRTCVideoStreamTypeBig);
      this.rtcCloud.startLocalPreview(view);
      // 填充模式需要在设置 view 后才生效
      this.rtcCloud.setLocalViewFillMode(this.videoFillMode);
      this.rtcCloud.startLocalAudio();
      this.rtcCloud.muteLocalAudio(false);
    },

    // 退房
    exitRoom() {
      if (!this.inroom) return;
      // 退房重新进房前需要清理所有资源，所以这里先还在房间内，等 onExitRoom 回调到来才退房成功
      this.inroom = true;
      // 关闭采集音视频
      this.rtcCloud.stopLocalPreview();
      this.rtcCloud.stopLocalAudio();

      // 清除状态
      this.muteLocalVideo = false;
      this.muteLocalAudio = false;
      this.screenCapture = false;
      this.screenName = "";
      this.connectLoading = false;
      this.connected = false;
      this.users.splice(0, this.users.length);
      this.pkUsers.splice(0, this.pkUsers.length);
      this.mixTranscoding = false;
      this.mixStreamInfos.splice(0, this.mixStreamInfos.length);

      // 释放资源
      if (this.screenCapture) {
        this.rtcCloud.stopScreenCapture();
      }
      if (this.mixTranscoding) {
        this.rtcCloud.setMixTranscodingConfig(null);
      }
      this.destroyAllVideoView();
      this.rtcCloud.exitRoom();
    },

    // 跨房连麦
    connectRoom() {
      if (this.pkUserId === null || this.pkUserId === "" || this.pkRoomId === null || this.pkRoomId === "") {
        this.notify('房间号或用户号不能为空！', 'warning', '警告');
        return;
      }
      let json = JSON.stringify({
        userId: this.pkUserId,
        roomId: parseInt(this.pkRoomId)
      });
      this.rtcCloud.connectOtherRoom(json);
      this.connectLoadingText = '连接房间[' + this.pkRoomId + ']中';
      this.connectLoading = true;
    },

    // 退出连麦
    disconnectRoom() {
      if (this.connected) {
        // 如果此时是多人连麦，则是取消所有连麦的用户
        this.rtcCloud.disconnectOtherRoom();
        this.connectLoadingText = '取消连麦中';
        this.connectLoading = true;
      }
    },

    // 分享播放地址（获取旁路直播的 url ）
    sharePlayUrl() {
      // 计算 CDN 地址(格式： http://[bizid].liveplay.myqcloud.com/live/[bizid]_[streamid].flv )
      let sdkInfo = genTestUserSig(this.userId);
      // streamid = MD5 (房间号_用户名_流类型)
      let crypto = require('crypto');
      let strHash = crypto.createHash('md5');
      strHash.update(this.roomId + '_' + this.userId + '_main');
      let streamId = strHash.digest('hex');
      let shareUrl = 'http://' + sdkInfo.bizId + '.liveplay.myqcloud.com/live/' + sdkInfo.bizId + '_' + streamId + '.flv';
      let clipboard = require('electron').clipboard;
      clipboard.writeText(shareUrl);
      this.$message('播放地址：（已复制到剪切板）' + shareUrl);
    },

    // 在创建一个 Dom 节点，用来显示视频。key 值是用于给 view 的标记，以免重复创建
    findVideoView(uid, streamtype) {
      let key = uid + '_' + streamtype;
      var userVideoEl = document.getElementById(key);
      if (!userVideoEl) {
        userVideoEl = document.createElement('div');
        userVideoEl.id = key;
        userVideoEl.classList.add('video_view');
        document.querySelector("#video_wrap").appendChild(userVideoEl);
        var voiceEl = document.getElementById(key + "_voice");
        if (!voiceEl && (streamtype === TRTCVideoStreamType.TRTCVideoStreamTypeBig || streamtype === TRTCVideoStreamType.TRTCVideoStreamTypeSmall)) {
          this.createProgressElement(key, userVideoEl);
        }
      }
      this.setVisibleVoice(this.showVoice, uid, streamtype);
      return userVideoEl;
    },

    // 动态添加音量提示条
    createProgressElement(key, userVideoEl) {
      voiceEl = document.createElement('div');
      voiceEl.id = key + "_voice";
      var progressBarOuter = document.createElement('div');
      progressBarOuter.style.height = "4px";
      progressBarOuter.classList.add('el-progress-bar__outer');
      var progressBarInner = document.createElement('div');
      progressBarInner.id = key + "_voice_inner";
      progressBarInner.style.width = "0%";
      progressBarInner.classList.add('el-progress-bar__inner');
      progressBarOuter.appendChild(progressBarInner);
      voiceEl.appendChild(progressBarOuter);
      voiceEl.classList.add('el-progress-bar');
      voiceEl.classList.add('video_voice_progress');
      userVideoEl.appendChild(voiceEl);
    },

    // 设置 video_voice_progress 是否可见，打开音量提示时显示提示条
    setVisibleVoice(visible, uid, streamtype) {
      let key = uid + '_' + streamtype + "_voice";
      var voiceEl = document.getElementById(key);
      if (voiceEl) {
        if (visible) {
          voiceEl.style.visibility = "visible";
        } else {
          voiceEl.style.visibility = "hidden";
        }
      }
    },

    // 设置 video_view 是否可见，屏蔽视频后，直接隐藏 view，相反打开视频时显示 view
    setVisibleView(visible, uid, streamtype) {
      let key = uid + '_' + streamtype;
      var userVideoEl = document.getElementById(key);
      if (userVideoEl) {
        if (visible) {
          userVideoEl.hidden = false;
        } else {
          userVideoEl.hidden = true;
        }
      }
    },

    // 在视频用户退出视频时，将些 Dom 结点移除掉
    destroyVideoView(uid, streamtype) {
      let key = uid + '_' + streamtype;
      var userVideoEl = document.getElementById(key);
      if (userVideoEl) {
        document.querySelector("#video_wrap").removeChild(userVideoEl);
      }
    },

    // 清掉所有的视频 Dom 结点，适用于退出房间时。
    destroyAllVideoView() {
      var n = document.querySelector("#video_wrap").childNodes.length;
      for (var i = 0; i < n; i++) {
        var dom = document.querySelector("#video_wrap");
        dom.removeChild(dom.firstChild);
      }
    },

    // 初始化 SDK 本地配置信息
    initSDKLocalData() {
      this.videoResolutionList = [
        { type: TRTCVideoResolution.TRTCVideoResolution_320_180, name: "320 x 180" },
        { type: TRTCVideoResolution.TRTCVideoResolution_320_240, name: "320 x 240" },
        { type: TRTCVideoResolution.TRTCVideoResolution_640_360, name: "640 x 360" },
        { type: TRTCVideoResolution.TRTCVideoResolution_640_480, name: "640 x 480" },
        { type: TRTCVideoResolution.TRTCVideoResolution_960_540, name: "960 x 540" },
        { type: TRTCVideoResolution.TRTCVideoResolution_1280_720, name: "1280 x 720" }
      ];
      this.videoFpsList = [
        { type: 15, name: "15 FPS" },
        { type: 20, name: "20 FPS" },
        { type: 24, name: "24 FPS" }
      ];
      this.qosPreferenceList = [
        { type: TRTCVideoQosPreference.TRTCVideoQosPreferenceSmooth, name: "优先流畅" },
        { type: TRTCVideoQosPreference.TRTCVideoQosPreferenceClear, name: "优先清晰" }
      ];
      this.qosControlModeList = [
        { type: TRTCQosControlMode.TRTCQosControlModeServer, name: "云端流控" },
        { type: TRTCQosControlMode.TRTCQosControlModeClient, name: "客户端控" }
      ];
      this.appSceneList = [
        { type: TRTCAppScene.TRTCAppSceneVideoCall, name: "视频通话" },
        { type: TRTCAppScene.TRTCAppSceneLIVE, name: "在线直播" }
      ];
      this.videoResolutionModeList = [
        { type: TRTCVideoResolutionMode.TRTCVideoResolutionModeLandscape, name: "横屏模式" },
        { type: TRTCVideoResolutionMode.TRTCVideoResolutionModePortrait, name: "竖屏模式" }
      ];
      // 初始化设备信息
      this.cameraList = this.rtcCloud.getCameraDevicesList();
      if (this.cameraList.length > 0) {
        this.cameraDeviceName = this.cameraList[0].deviceName;
      }
      this.micList = this.rtcCloud.getMicDevicesList();
      if (this.micList.length > 0) {
        this.micDeviceName = this.micList[0].deviceName;
      }
      this.speakerList = this.rtcCloud.getSpeakerDevicesList();
      if (this.speakerList.length > 0) {
        this.speakerDeviceName = this.speakerList[0].deviceName;
      }
      this.micVolume = this.rtcCloud.getCurrentMicDeviceVolume();
      this.speakerVolume = this.rtcCloud.getCurrentSpeakerVolume();

      this.testBGMText = '启动 BGM 测试';
    },

    getLocalStore() {
      // 第一次打开该应用，初始化本地 SDK 配置
      if (store.get('userId') === undefined) {
        this.setLocalStore();
      } else {
        this.userId = store.get('userId');
        this.roomId = store.get('roomId');
        this.localMirror = store.get('localMirror');
        this.encoderMirror = store.get('encoderMirror');
        this.showVoice = store.get('showVoice');
        this.videoResolution = store.get('videoResolution');
        this.videoFillMode = store.get('videoFillMode');
        this.videoFps = store.get('videoFps');
        this.videoBitrate = store.get('videoBitrate');
        this.qosPreference = store.get('qosPreference');
        this.qosControlMode = store.get('qosControlMode');
        this.appScene = store.get('appScene');
        this.videoResolutionMode = store.get('videoResolutionMode');
        this.playSmallVideo = store.get('playSmallVideo');
        this.pushSmallVideo = store.get('pushSmallVideo');
        this.pureAudioStyle = store.get('pureAudioStyle');
        this.openBeauty = store.get('openBeauty');
        this.beautyStyle = store.get('beautyStyle');
        this.beauty = store.get('beauty');
        this.white = store.get('white');
        this.ruddiness = store.get('ruddiness');
      }
    },

    // 初始化本地 SDK 配置信息
    setLocalStore() {
      store.set('userId', this.userId);
      store.set('roomId', parseInt(this.roomId));
      store.set('localMirror', this.localMirror);
      store.set('encoderMirror', this.encoderMirror);
      store.set('showVoice', this.showVoice);
      store.set('videoResolution', this.videoResolution);
      store.set('videoFillMode', this.videoFillMode);
      store.set('videoFps', this.videoFps);
      store.set('videoBitrate', this.videoBitrate);
      store.set('qosPreference', this.qosPreference);
      store.set('qosControlMode', this.qosControlMode);
      store.set('appScene', this.appScene);
      store.set('videoResolutionMode', this.videoResolutionMode);
      store.set('playSmallVideo', this.playSmallVideo);
      store.set('pushSmallVideo', this.pushSmallVideo);
      store.set('pureAudioStyle', this.pureAudioStyle);
      store.set('openBeauty', this.openBeauty);
      store.set('beautyStyle', this.beautyStyle);
      store.set('beauty', this.beauty);
      store.set('white', this.white);
      store.set('ruddiness', this.ruddiness);
    },

    notify(msg, type = '', title = '提示') {
      this.$notify({
        title: title,
        message: msg,
        type: type,
        dangerouslyUseHTMLString: true,
        duration: 2000
      });
    }
  }
});
