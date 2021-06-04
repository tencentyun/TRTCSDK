import TRTC from '../../../static/trtc-wx'

Page({
  data: {
    _rtcConfig: {
      sdkAppID: '', // 必要参数 开通实时音视频服务创建应用后分配的 sdkAppID
      userID: '', // 必要参数 用户 ID 可以由您的帐号系统指定
      userSig: '', // 必要参数 身份签名，相当于登录密码的作用
    },
    pusher: null,
    playerList: [],
    show_memberList: false,
    localAudio: false,
    localVideo: false
  },

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad(options) {
    console.log('room onload', options)
    wx.setKeepScreenOn({
      keepScreenOn: true,
    })
    this.TRTC = new TRTC(this)
    // 将String 类型的 true false 转换成 boolean
    Object.getOwnPropertyNames(options).forEach((key) => {
      if (options[key] === 'true') {
        options[key] = true
      }
      if (options[key] === 'false') {
        options[key] = false
      }
    })
    this.init(options)
    this.bindTRTCRoomEvent()
    this.enterRoom({ roomID: options.roomID })
  },

  onReady() {
    console.log('room ready')
  },
  onUnload() {
    console.log('room unload')
  },

  init(options) {
    // pusher 初始化参数
    const pusherConfig = {
      beautyLevel: 9,
    }
    const pusher = this.TRTC.createPusher(pusherConfig)
    this.setData({
      _rtcConfig: {
        userID: options.userID,
        sdkAppID: options.sdkAppID,
        userSig: options.userSig,
      },
      pusher: pusher.pusherAttributes,
      localAudio: options.localAudio,
      localVideo: options.localVideo
    })
  },

  enterRoom(options) {
    const roomID = options.roomID
    const config =  Object.assign(this.data._rtcConfig, { roomID })
    this.setData({
      pusher: this.TRTC.enterRoom(config),
    }, () => {
      this.TRTC.getPusherInstance().start() // 开始推流
    })
  },

  exitRoom() {
    const result = this.TRTC.exitRoom()
    this.setData({
      pusher: result.pusher,
      playerList: result.playerList,
    })
  },

  // 设置 pusher 属性
  setPusherAttributesHandler(options) {
    this.setData({
      pusher: this.TRTC.setPusherAttributes(options),
    })
  },

  // 设置某个 player 属性
  setPlayerAttributesHandler(player, options) {
    this.setData({
      playerList: this.TRTC.setPlayerAttributes(player.streamID, options),
    })
  },
  // 事件监听
  bindTRTCRoomEvent() {
    const TRTC_EVENT = this.TRTC.EVENT
    // 初始化事件订阅
    this.TRTC.on(TRTC_EVENT.LOCAL_JOIN, (event) => {
      console.log('* room LOCAL_JOIN', event)
      if (this.data.localVideo) {
        this.setPusherAttributesHandler({ enableCamera: true })
      }
      if (this.data.localAudio) {
        this.setPusherAttributesHandler({ enableMic: true })
      }
    })
    this.TRTC.on(TRTC_EVENT.LOCAL_LEAVE, (event) => {
      console.log('* room LOCAL_LEAVE', event)
    })
    this.TRTC.on(TRTC_EVENT.ERROR, (event) => {
      console.log('* room ERROR', event)
    })
    this.TRTC.on(TRTC_EVENT.REMOTE_USER_JOIN, (event) => {
      console.log('* room REMOTE_USER_JOIN', event)
      const { userID } = event.data
      wx.showToast({
        title: `${userID} 进入了房间`,
        icon: 'none',
        duration: 2000,
      })
    })
    // 远端用户退出
    this.TRTC.on(TRTC_EVENT.REMOTE_USER_LEAVE, (event) => {
      console.log('* room REMOTE_USER_LEAVE', event)
      const { userID, playerList } = event.data
      this.setData({
        playerList: playerList
      })
      wx.showToast({
        title: `${userID} 离开了房间`,
        icon: 'none',
        duration: 2000,
      })
    })
    // 远端用户推送视频
    this.TRTC.on(TRTC_EVENT.REMOTE_VIDEO_ADD, (event) => {
      console.log('* room REMOTE_VIDEO_ADD',  event)
      const { player } = event.data
      // 开始播放远端的视频流，默认是不播放的
      this.setPlayerAttributesHandler(player, { muteVideo: false })
    })
    // 远端用户取消推送视频
    this.TRTC.on(TRTC_EVENT.REMOTE_VIDEO_REMOVE, (event) => {
      console.log('* room REMOTE_VIDEO_REMOVE', event)
      const { player } = event.data
      this.setPlayerAttributesHandler(player, { muteVideo: true })
    })
    // 远端用户推送音频
    this.TRTC.on(TRTC_EVENT.REMOTE_AUDIO_ADD, (event) => {
      console.log('* room REMOTE_AUDIO_ADD', event)
      const { player } = event.data
      this.setPlayerAttributesHandler(player, { muteAudio: false })
    })
    // 远端用户取消推送音频
    this.TRTC.on(TRTC_EVENT.REMOTE_AUDIO_REMOVE, (event) => {
      console.log('* room REMOTE_AUDIO_REMOVE', event)
      const { player } = event.data
      this.setPlayerAttributesHandler(player, { muteAudio: true })
    })
    this.TRTC.on(TRTC_EVENT.REMOTE_AUDIO_VOLUME_UPDATE, (event) => {
      console.log('* room REMOTE_AUDIO_VOLUME_UPDATE', event)
      const { playerList } = event.data
      this.setData({
        playerList: playerList
      })
    })
    this.TRTC.on(TRTC_EVENT.LOCAL_AUDIO_VOLUME_UPDATE, (event) => {
      // console.log('* room LOCAL_AUDIO_VOLUME_UPDATE', event)
      const { pusher } = event.data
      this.setData({
        pusher: pusher
      })
    })
  },

  // 是否订阅某一个player Audio
  _mutePlayerAudio(event) {
    const player = event.currentTarget.dataset.value
    if (player.hasAudio && player.muteAudio) {
      this.setPlayerAttributesHandler(player, { muteAudio: false })
      return
    }
    if (player.hasAudio && !player.muteAudio) {
      this.setPlayerAttributesHandler(player, { muteAudio: true })
      return
    }
  },

  // 订阅 / 取消订阅某一个player Audio
  _mutePlayerVideo(event) {
    const player = event.currentTarget.dataset.value
    if (player.hasVideo && player.muteVideo) {
      this.setPlayerAttributesHandler(player, { muteVideo: false })
      return
    }
    if (player.hasVideo && !player.muteVideo) {
      this.setPlayerAttributesHandler(player, { muteVideo: true })
      return
    }
  },

  // 挂断退出房间
  _hangUp() {
    this.exitRoom()
    wx.navigateBack({
      delta: 1,
    })
  },

  // 设置美颜
  _setPusherBeautyHandle() {
    const  beautyLevel = this.data.pusher.beautyLevel === 0 ? 9 : 0
    this.setPusherAttributesHandler({ beautyLevel })
  },

  // 订阅 / 取消订阅 Audio
  _pusherAudioHandler() {
    if (this.data.pusher.enableMic) {
      this.setPusherAttributesHandler({ enableMic: false })
    } else {
      this.setPusherAttributesHandler({ enableMic: true })
    }
  },

  // 订阅 / 取消订阅 Video
  _pusherVideoHandler() {
    if (this.data.pusher.enableCamera) {
      this.setPusherAttributesHandler({ enableCamera: false })
    } else {
      this.setPusherAttributesHandler({ enableCamera: true })
    }
  },

  _switchMemberListPanel() {
    this.setData({
      show_memberList: true
    })
  },
  _handleClose() {
    this.setData({
      show_memberList: false
    })
  },
  // 请保持跟 wxml 中绑定的事件名称一致
  _pusherStateChangeHandler(event) {
    this.TRTC.pusherEventHandler(event)
  },
  _pusherNetStatusHandler(event) {
    this.TRTC.pusherNetStatusHandler(event)
  },
  _pusherErrorHandler(event) {
    this.TRTC.pusherErrorHandler(event)
  },
  _pusherBGMStartHandler(event) {
    this.TRTC.pusherBGMStartHandler(event)
  },
  _pusherBGMProgressHandler(event) {
    this.TRTC.pusherBGMProgressHandler(event)
  },
  _pusherBGMCompleteHandler(event) {
    this.TRTC.pusherBGMCompleteHandler(event)
  },
  _pusherAudioVolumeNotify(event) {
    this.TRTC.pusherAudioVolumeNotify(event)
  },
  _playerStateChange(event) {
    this.TRTC.playerEventHandler(event)
  },
  _playerFullscreenChange(event) {
    this.TRTC.playerFullscreenChange(event)
  },
  _playerNetStatus(event) {
    this.TRTC.playerNetStatus(event)
  },
  _playerAudioVolumeNotify(event) {
    this.TRTC.playerAudioVolumeNotify(event)
  },
})

