import { genTestUserSig } from '../../debug/GenerateTestUserSig.js'

Page({

  /**
   * 页面的初始数据
   */
  data: {
    rtcConfig: {
      sdkAppID: '', // 必要参数 开通实时音视频服务创建应用后分配的 sdkAppID
      userID: '', // 必要参数 用户 ID 可以由您的帐号系统指定
      userSig: '', // 必要参数 身份签名，相当于登录密码的作用
      template: '', // 必要参数 组件模版，支持的值 1v1 grid custom ，注意：不支持动态修改, iOS 不支持 pusher 动态渲染
    },
    showTipToast: false,
  },
  enterRoom: function(params) {
    params.template = params.template || '1v1'
    params.roomID = params.roomID || this.randomRoomID()
    params.userID = params.userID || this.randomUserID()
    console.log('* room enterRoom', params)

    const Signature = genTestUserSig(params.userID)
    params.sdkAppID = Signature.sdkAppID
    params.userSig = Signature.userSig

    this.template = params.template
    if (params.template === 'grid') {
      this.data.rtcConfig = {
        sdkAppID: params.sdkAppID, // 您的实时音视频服务创建应用后分配的 sdkAppID
        userID: params.userID,
        userSig: params.userSig,
        template: params.template, // 1v1 grid custom
        debugMode: params.debugMode, // 非必要参数，打开组件的调试模式，开发调试时建议设置为 true
        frontCamera: params.frontCamera,
        enableEarMonitor: params.enableEarMonitor,
        enableAutoFocus: params.enableAutoFocus,
        localMirror: params.localMirror,
        enableAgc: params.enableAgc,
        enableAns: params.enableAns,
        encsmall: params.encsmall ? 1 : 0,
        videoWidth: params.videoWidth,
        videoHeight: params.videoHeight,
        scene: params.scene, // rtc live
        maxBitrate: params.maxBitrate,
        minBitrate: params.minBitrate,
        beautyLevel: 9, // 开启美颜等级 0～9级美颜
        enableIM: false, // 可选，仅支持初始化设置（进房前设置），不支持动态修改，需要开通云通信功能
      }
    } else {
      this.data.rtcConfig = {
        sdkAppID: params.sdkAppID, // 您的实时音视频服务创建应用后分配的 sdkAppID
        userID: params.userID,
        userSig: params.userSig,
        template: params.template, // 1v1 grid custom
        debugMode: params.debugMode, // 非必要参数，打开组件的调试模式，开发调试时建议设置为 true
        beautyLevel: 9, // 默认开启美颜
        enableIM: false, // 可选，仅支持初始化设置（进房前设置），不支持动态修改，需要开通云通信功能
      }
    }

    this.setData({
      rtcConfig: this.data.rtcConfig,
    }, () => {
      // 进房前决定是否推送视频或音频 部分机型会出现画面卡死，原因不明，必须放到进房成功事件后设置
      // console.log('rtcConfig', this.data.rtcConfig)
      // if (params.localVideo === true || params.template === '1v1') {
      //   this.trtcComponent.publishLocalVideo()
      // }
      // if (params.localAudio === true || params.template === '1v1') {
      //   this.trtcComponent.publishLocalAudio()
      // }

      // roomID 取值范围 1 ~ 4294967295
      this.trtcComponent.enterRoom({ roomID: params.roomID }).then(()=>{
        if (this.template === 'custom') {
          // 设置推流端视窗的坐标和尺寸
          this.trtcComponent.setViewRect({
            userID: params.userID,
            xAxis: '480rpx',
            yAxis: '160rpx',
            width: '240rpx',
            height: '320rpx',
          })
        }
      }).catch((res)=>{
        console.error('* room joinRoom 进房失败:', res)
      })
    })
  },
  bindTRTCRoomEvent: function() {
    const TRTC_EVENT = this.trtcComponent.EVENT
    this.timestamp = []
    // 初始化事件订阅
    this.trtcComponent.on(TRTC_EVENT.LOCAL_JOIN, (event)=>{
      console.log('* room LOCAL_JOIN', event)
      // 进房成功，触发该事件后可以对本地视频和音频进行设置
      if (this.options.localVideo === true || this.options.template === '1v1') {
        this.trtcComponent.publishLocalVideo()
      }
      if (this.options.localAudio === true || this.options.template === '1v1') {
        this.trtcComponent.publishLocalAudio()
      }
    })
    this.trtcComponent.on(TRTC_EVENT.LOCAL_LEAVE, (event)=>{
      console.log('* room LOCAL_LEAVE', event)
    })
    this.trtcComponent.on(TRTC_EVENT.ERROR, (event)=>{
      console.log('* room ERROR', event)
    })
    // 远端用户进房
    this.trtcComponent.on(TRTC_EVENT.REMOTE_USER_JOIN, (event)=>{
      console.log('* room REMOTE_USER_JOIN', event, this.trtcComponent.getRemoteUserList())
      this.timestamp.push(new Date())
      // 1v1视频通话时限制人数为两人的简易逻辑，建议通过后端实现房间人数管理
      // 2人以上同时进行通话请选择网格布局
      if (this.template === '1v1' && this.timestamp.length > 1) {
        const interval = this.timestamp[1] - this.timestamp[0]
        if (interval < 1000) {
          // 房间里已经有两个人
          this.setData({
            showTipToast: true,
          }, () => {
            setTimeout(()=>{
              this.setData({
                showTipToast: false,
              })
              wx.navigateBack({
                delta: 1,
              })
            }, 4000)
          })
        }
      }
    })
    // 远端用户退出
    this.trtcComponent.on(TRTC_EVENT.REMOTE_USER_LEAVE, (event)=>{
      console.log('* room REMOTE_USER_LEAVE', event, this.trtcComponent.getRemoteUserList())
      if (this.template === '1v1') {
        this.timestamp = []
      }
      if (this.template === '1v1' && this.remoteUser === event.data.userID) {
        this.remoteUser = null
      }
    })
    // 远端用户推送视频
    this.trtcComponent.on(TRTC_EVENT.REMOTE_VIDEO_ADD, (event)=>{
      console.log('* room REMOTE_VIDEO_ADD', event, this.trtcComponent.getRemoteUserList())
      // 订阅视频
      const userList = this.trtcComponent.getRemoteUserList()
      const data = event.data
      if (this.template === '1v1' && (!this.remoteUser || this.remoteUser === data.userID)) {
        // 1v1 只订阅第一个远端流
        this.remoteUser = data.userID
        this.trtcComponent.subscribeRemoteVideo({
          userID: data.userID,
          streamType: data.streamType,
        })
      } else if (this.template === 'grid') {
        this.trtcComponent.subscribeRemoteVideo({
          userID: data.userID,
          streamType: data.streamType,
        })
      }
      if (this.template === 'custom' && data.userID && data.streamType) {
        let index = userList.findIndex((item)=>{
          return item.userID === data.userID
        })
        index++
        const y = 320 * index + 160
        // 设置远端视图坐标和尺寸
        this.trtcComponent.setViewRect({
          userID: data.userID,
          streamType: data.streamType,
          xAxis: '480rpx',
          yAxis: y + 'rpx',
          width: '240rpx',
          height: '320rpx',
        })
      }
    })
    // 远端用户取消推送视频
    this.trtcComponent.on(TRTC_EVENT.REMOTE_VIDEO_REMOVE, (event)=>{
      console.log('* room REMOTE_VIDEO_REMOVE', event, this.trtcComponent.getRemoteUserList())
    })
    // 远端用户推送音频
    this.trtcComponent.on(TRTC_EVENT.REMOTE_AUDIO_ADD, (event)=>{
      console.log('* room REMOTE_AUDIO_ADD', event, this.trtcComponent.getRemoteUserList())
      // 订阅音频
      const data = event.data
      if (this.template === '1v1' && (!this.remoteUser || this.remoteUser === data.userID)) {
        this.remoteUser = data.userID
        this.trtcComponent.subscribeRemoteAudio({ userID: data.userID })
      } else if (this.template === 'grid' || this.template === 'custom') {
        this.trtcComponent.subscribeRemoteAudio({ userID: data.userID })
      }
      // 如果不订阅就不会自动播放音频
      // this.trtcComponent.subscribeRemoteAudio({ userID: data.userID })
    })
    // 远端用户取消推送音频
    this.trtcComponent.on(TRTC_EVENT.REMOTE_AUDIO_REMOVE, (event)=>{
      console.log('* room REMOTE_AUDIO_REMOVE', event, this.trtcComponent.getRemoteUserList())
    })
    this.trtcComponent.on(TRTC_EVENT.IM_SDK_READY, (event)=>{
      console.log('* room IM_SDK_READY', event)
    })
    this.trtcComponent.on(TRTC_EVENT.IM_MESSAGE_RECEIVED, (event)=>{
      console.log('* room IM_MESSAGE_RECEIVED', event)
    })
  },
  randomUserID: function() {
    return new Date().getTime().toString(16).split('').reverse().join('')
  },
  randomRoomID: function() {
    return parseInt(Math.random() * 9999)
  },
  /**
   * 生命周期函数--监听页面加载
   * @param {*} options 配置项
   */
  onLoad: function(options) {
    console.log('room onload', options)
    wx.setKeepScreenOn({
      keepScreenOn: true,
    })
    // 获取 rtcroom 实例
    this.trtcComponent = this.selectComponent('#trtc-component')
    // 监听TRTC Room 关键事件
    this.bindTRTCRoomEvent()
    // 将String 类型的 true false 转换成 boolean
    Object.getOwnPropertyNames(options).forEach((key) => {
      if (options[key] === 'true') {
        options[key] = true
      }
      if (options[key] === 'false') {
        options[key] = false
      }
    })
    this.options = options
    // querystring 只支持传递 String 类型, 注意类型转换
    this.enterRoom({
      roomID: Number(options.roomID),
      userID: options.userID,
      template: options.template,
      debugMode: options.debugMode,
      cloudenv: options.cloudenv,
      frontCamera: options.frontCamera,
      localVideo: options.localVideo,
      localAudio: options.localAudio,
      enableEarMonitor: options.enableEarMonitor,
      enableAutoFocus: options.enableAutoFocus,
      localMirror: options.localMirror,
      enableAgc: options.enableAgc,
      enableAns: options.enableAns,
      encsmall: options.encsmall,
      videoHeight: options.videoHeight,
      videoWidth: options.videoWidth,
      scene: options.scene,
      maxBitrate: Number(options.maxBitrate),
      minBitrate: Number(options.minBitrate),
    })
  },

  /**
   * 生命周期函数--监听页面初次渲染完成
   */
  onReady: function() {
    console.log('room ready')
    wx.setKeepScreenOn({
      keepScreenOn: true,
    })
  },

  /**
   * 生命周期函数--监听页面显示
   */
  onShow: function() {
    console.log('room show')
    wx.setKeepScreenOn({
      keepScreenOn: true,
    })
  },

  /**
   * 生命周期函数--监听页面隐藏
   */
  onHide: function() {
    console.log('room hide')
  },

  /**
   * 生命周期函数--监听页面卸载
   */
  onUnload: function() {
    console.log('room unload')
    wx.setKeepScreenOn({
      keepScreenOn: false,
    })
  },

  /**
   * 页面相关事件处理函数--监听用户下拉动作
   */
  onPullDownRefresh: function() {

  },

  /**
   * 页面上拉触底事件的处理函数
   */
  onReachBottom: function() {

  },

  /**
   * 用户点击右上角分享
   */
  onShareAppMessage: function() {

  },
})

