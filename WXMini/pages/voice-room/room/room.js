import { genTestUserSig } from '../../../debug/GenerateTestUserSig.js'
const app = getApp()
Page({

  /**
   * 页面的初始数据
   */
  data: {
    roomID: 0, // 房间号
    role: '',
    userList: [], // 主播list
    userID: '',
    debugMode: false,
    initialRole: '',
    showRolePanel: false,
    presenterConfig: {
      enableMic: true,
      muteAllAudio: false,
    },
    headerHeight: app.globalData.headerHeight,
    statusBarHeight: app.globalData.statusBarHeight,
    rtcConfig: {
      sdkAppID: '', // 必要参数 开通实时音视频服务创建应用后分配的 sdkAppID
      userID: '', // 必要参数 用户 ID 可以由您的帐号系统指定
      userSig: '', // 必要参数 身份签名，相当于登录密码的作用
      template: '', // 必要参数 组件模版，支持的值 1v1 grid custom ，注意：不支持动态修改, iOS 不支持 pusher 动态渲染
    },
  },
  enterRoom: function({ sdkAppID, userSig }) {
    const template = 'custom'
    const roomID = this.data.roomID
    console.log('* room enterRoom', roomID, template)
    this.data.rtcConfig = {
      sdkAppID: sdkAppID, // 您的实时音视频服务创建应用后分配的 sdkAppID
      userID: this.data.userID,
      userSig: userSig,
      template: template, // 1v1 grid custom
      debugMode: this.data.debugMode, // 非必要参数，打开组件的调试模式，开发调试时建议设置为 true
    }
    this.setData({
      rtcConfig: this.data.rtcConfig,
    }, () => {
      // 进房前决定是否推送视频或音频
      if (this.data.role === 'presenter') {
        this.trtcComponent.publishLocalAudio()
      }
      // roomID 取值范围 1 ~ 4294967295
      this.trtcComponent.enterRoom({ roomID: roomID })
    })
  },
  getSignature: function(userID) {
    console.log('* room getSignature', userID)
    const Signature = genTestUserSig(userID)
    this.enterRoom({
      sdkAppID: Signature.sdkAppID,
      userSig: Signature.userSig,
    })
  },
  bindTRTCRoomEvent: function() {
    const TRTC_EVENT = this.trtcComponent.EVENT
    // 初始化事件订阅
    this.trtcComponent.on(TRTC_EVENT.LOCAL_JOIN, (event)=>{
      console.log('* room LOCAL_JOIN', event)
      // 进房成功，触发该事件后可以对本地视频和音频进行设置
      // if (this.data.role === 'presenter') {
      //   this.trtcComponent.publishLocalAudio()
      // }
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
      const userList = this.trtcComponent.getRemoteUserList()
      this.handleOnUserList(userList).then(() => {
        console.log(this.data.userList)
      })
    })
    // 远端用户退出
    this.trtcComponent.on(TRTC_EVENT.REMOTE_USER_LEAVE, (event)=>{
      console.log('* room REMOTE_USER_LEAVE', event, this.trtcComponent.getRemoteUserList())
      const userList = this.trtcComponent.getRemoteUserList()
      this.handleOnUserList(userList).then(() => {
        console.log(this.data.userList)
      })
    })
    // 远端用户推送音频
    this.trtcComponent.on(TRTC_EVENT.REMOTE_AUDIO_ADD, (event)=>{
      if (this.data.userList.length < 6) {
        // 订阅音频
        const data = event.data
        // 如果不订阅就不会自动播放音频
        const userList = this.trtcComponent.getRemoteUserList()
        this.handleOnUserList(userList).then(() => {
          console.log(this.data.userList)
        })
        console.log('* room REMOTE_AUDIO_ADD', event, this.trtcComponent.getRemoteUserList())
        this.trtcComponent.subscribeRemoteAudio({ userID: data.userID })
      }
    })
    // 远端用户取消推送音频
    this.trtcComponent.on(TRTC_EVENT.REMOTE_AUDIO_REMOVE, (event)=>{
      console.log('* room REMOTE_AUDIO_REMOVE', event, this.trtcComponent.getRemoteUserList())
      const userList = this.trtcComponent.getRemoteUserList()
      this.handleOnUserList(userList).then(() => {
        console.log(this.data.userList)
      })
    })
    this.trtcComponent.on(TRTC_EVENT.REMOTE_AUDIO_VOLUME_UPDATE, (event)=>{
      const userID = event.data.target.dataset.userid
      const volume = event.data.detail.volume
      this.data.userList.forEach((item) =>{
        if (item.userID === userID) {
          item.volume = volume
        }
      })
      this.setData({
        userList: this.data.userList,
      })
    })
  },
  handleOnUserList: function(userList) {
    return new Promise((resolve, reject) => {
      const newUserList = []
      let index = 0
      const oldUserList = this.data.userList
      userList.forEach((item) => {
        if (item.hasMainAudio) {
          const user = this.judgeWhetherExist({ userID: item.userID, streamType: 'main' }, oldUserList)
          index += 1
          if (user) {
            // 已存在
            newUserList.push(Object.assign(user, { index: index }))
          } else {
            newUserList.push({
              userID: item.userID,
              streamType: 'main',
              index: index,
              hasMainAudio: item.hasMainAudio,
              volume: 0,
            })
          }
        }
      })
      this.setData({
        userList: newUserList,
      }, () => {
        console.log('handleOnUserList newUserList', newUserList)
        resolve()
      })
    })
  },
  judgeWhetherExist: function(target, userList) {
    userList.forEach( (item) => {
      if (target.userID === item.userID && target.streamType === item.streamType) {
        return item
      }
    })
    return false
  },
  handlePublishAudio() {
    if (this.data.presenterConfig.enableMic) {
      this.trtcComponent.unpublishLocalAudio()
      const config = this.data.presenterConfig
      config.enableMic = false
      this.setData({
        presenterConfig: config,
      }, () => {
        wx.showToast({
          title: '您已关闭麦克风',
          icon: 'none',
          duration: 500,
        })
      })
    } else {
      this.trtcComponent.publishLocalAudio()
      const config = this.data.presenterConfig
      config.enableMic = true
      this.setData({
        presenterConfig: config,
      }, () => {
        wx.showToast({
          title: '您已开启麦克风',
          icon: 'none',
          duration: 500,
        })
      })
    }
  },
  handleMuteAllAudio() {
    if (this.data.presenterConfig.muteAllAudio) {
      this.data.userList.forEach((item) => {
        this.trtcComponent.subscribeRemoteAudio({ userID: item.userID })
      })
      const config = this.data.presenterConfig
      config.muteAllAudio = false
      this.setData({
        presenterConfig: config,
      }, () => {
        wx.showToast({
          title: '取消禁音成功',
          icon: 'none',
          duration: 500,
        })
      })
    } else {
      this.data.userList.forEach((item) => {
        this.trtcComponent.unsubscribeRemoteAudio({ userID: item.userID })
      })
      const config = this.data.presenterConfig
      config.muteAllAudio = true
      this.setData({
        presenterConfig: config,
      }, () => {
        wx.showToast({
          title: '禁音成功',
          icon: 'none',
          duration: 500,
        })
      })
    }
  },
  /**
   * 返回上一页
   */
  onBack: function() {
    wx.navigateBack({
      delta: 1,
    })
  },
  handleRoleChange() {
    if (this.data.initialRole !== 'presenter' ) {
      this.setData({
        showRolePanel: !this.data.showRolePanel,
      })
    }
  },
  confirmRoleChange() {
    if (this.data.role === 'audience') {
      this.trtcComponent.publishLocalAudio().then(() => {
        this.setData({
          role: 'presenter',
          showRolePanel: false,
        })
      }).catch(() => {
        wx.showToast({
          icon: 'none',
          title: '上麦失败',
        })
      })
    } else {
      this.trtcComponent.unpublishLocalAudio().then(() => {
        this.setData({
          role: 'audience',
          showRolePanel: false,
        })
      }).catch(() => {
        wx.showToast({
          icon: 'none',
          title: '下麦失败',
        })
      })
    }
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
    Object.getOwnPropertyNames(options).forEach((key) => {
      if (options[key] === 'true') {
        options[key] = true
      }
      if (options[key] === 'false') {
        options[key] = false
      }
    })
    // 监听TRTC Room 关键事件
    this.bindTRTCRoomEvent()
    this.setData({
      roomID: parseInt(options.roomID),
      role: options.role,
      initialRole: options.role,
      userID: options.userID,
      debugMode: options.debugMode,
    }, () => {
      this.getSignature(options.userID)
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
})

