// miniprogram/pages/meeting.js
const app = getApp()
Page({

  /**
   * 页面的初始数据
   */
  data: {
    roomID: '',
    userID: '',
    template: 'grid',
    cloudenv: 'PRO',
    scene: 'rtc',
    localVideo: true,
    localAudio: true,
    enableEarMonitor: false,
    enableAutoFocus: true,
    localMirror: 'auto',
    enableAgc: true,
    enableAns: true,
    encsmall: false,
    frontCamera: 'front',
    resolution: 'SD',
    debugMode: false,

    // 用于自定义输入视频分辨率和默认值
    // videoHeight: 720,
    // videoWidth: 1280,
    // minBitrate: 1500,
    // maxBitrate: 2000,

    videoWidth: 360,
    videoHeight: 640,
    minBitrate: 600,
    maxBitrate: 900,

    localMirrorArray: [
      { value: 'auto', title: '自动' },
      { value: 'enable', title: '开启' },
      { value: 'disable', title: '关闭' },
    ],
    resolutionArray: [
      { value: 'FHD', title: 'FHD' },
      { value: 'HD', title: 'HD' },
      { value: 'SD', title: 'SD' },
      // { value: 'default', title: '自定义' }
    ],
    headerHeight: app.globalData.headerHeight,
    statusBarHeight: app.globalData.statusBarHeight,
  },

  enterRoomID: function(e) {
    this.setData({
      roomID: e.detail.value,
    })
  },

  enterUserID: function(e) {
    this.setData({
      userID: e.detail.value,
    })
  },

  selectScene: function(e) {
    this.setData({
      scene: e.detail.value,
    })
  },

  switchLocalVideo: function(e) {
    this.setData({
      localVideo: e.detail.value,
    })
  },

  switchLocalAudio: function(e) {
    this.setData({
      localAudio: e.detail.value,
    })
  },

  switchEarMonitor: function(e) {
    this.setData({
      enableEarMonitor: e.detail.value,
    })
  },

  switchAutoFocus: function(e) {
    this.setData({
      enableAutoFocus: e.detail.value,
    })
  },

  switchAgc: function(e) {
    this.setData({
      enableAgc: e.detail.value,
    })
  },

  switchAns: function(e) {
    this.setData({
      enableAns: e.detail.value,
    })
  },

  switchSmallScreen: function(e) {
    this.setData({
      encsmall: e.detail.value,
    })
  },

  selectDevicePosition: function(e) {
    this.setData({
      frontCamera: e.detail.value,
    })
  },

  selectLocalMirror: function(e) {
    this.setData({
      localMirror: e.detail.value,
    })
  },

  switchDebugMode: function(e) {
    this.setData({
      debugMode: e.detail.value,
    })
  },

  selectResolution: function(e) {
    this.setData({
      resolution: e.detail.value,
    }, () => {
      // 如果用户选择自定义的话, 手动输入分辨率，并且在传递的时候进行一下判断
      switch (this.data.resolution) {
        case 'FHD':
          this.setData({
            videoWidth: 720,
            videoHeight: 1280,
            minBitrate: 1500,
            maxBitrate: 2000,
          })
          break
        case 'SD':
          this.setData({
            videoWidth: 360,
            videoHeight: 640,
            minBitrate: 600,
            maxBitrate: 900,
          })
          break
        case 'HD':
          this.setData({
            videoWidth: 540,
            videoHeight: 960,
            minBitrate: 1000,
            maxBitrate: 1500,
          })
          break
        default:
          console.log('choose resolution error')
          break
      }
    })
  },

  enterRoom: function() {
    const nowTime = new Date()
    if (nowTime - this.tapTime < 1000) {
      return
    }

    const url = `../room/room?roomID=${this.data.roomID}` +
                `&template=${this.data.template}` +
                `&debugMode=${this.data.debugMode}` +
                `&cloudenv=${this.data.cloudenv}` +
                `&localVideo=${this.data.localVideo}` +
                `&localAudio=${this.data.localAudio}` +
                `&enableEarMonitor=${this.data.enableEarMonitor}` +
                `&enableAutoFocus=${this.data.enableAutoFocus}` +
                `&localMirror=${this.data.localMirror}` +
                `&enableAgc=${this.data.enableAgc}` +
                `&enableAns=${this.data.enableAns}` +
                `&encsmall=${this.data.encsmall}` +
                `&frontCamera=${this.data.frontCamera}` +
                `&videoWidth=${this.data.videoWidth}` +
                `&videoHeight=${this.data.videoHeight}` +
                `&scene=${this.data.scene}` +
                `&userID=${this.data.userID}` +
                `&minBitrate=${this.data.minBitrate}` +
                `&maxBitrate=${this.data.maxBitrate}`

    if (!this.data.roomID) {
      wx.showToast({
        title: '请输入房间号',
        icon: 'none',
        duration: 2000,
      })
      return
    }
    if (!this.data.userID) {
      wx.showToast({
        title: '请输入用户名',
        icon: 'none',
        duration: 2000,
      })
      return
    }
    const reg = /^[0-9a-zA-Z]*$/
    if (this.data.userID.match(reg) === null) {
      wx.showToast({
        icon: 'none',
        title: '用户名为英文加数字',
      })
    } else {
      wx.navigateTo({
        url: url,
      })
      this.setData({ 'tapTime': nowTime })
    }
  },
  onBack: function() {
    wx.navigateBack({
      delta: 1,
    })
  },
  randomUserID: function() {
    this.setData({
      // roomID: parseInt(10000 * Math.random()),
      userID: new Date().getTime().toString(16).split('').reverse().join(''),
    })
  },
  /**
   * 生命周期函数--监听页面加载
   * @param {Object} options 参数
   */
  onLoad: function(options) {
    wx.setKeepScreenOn({
      keepScreenOn: true,
    })
    // 随机 userID roomID
    // this.setData({
    //   roomID: parseInt(10000 * Math.random()),
    //   userID: new Date().getTime().toString(16),
    // })
  },

  /**
   * 生命周期函数--监听页面初次渲染完成
   */
  onReady: function() {

  },

  /**
   * 生命周期函数--监听页面显示
   */
  onShow: function() {

  },

  /**
   * 生命周期函数--监听页面隐藏
   */
  onHide: function() {

  },

  /**
   * 生命周期函数--监听页面卸载
   */
  onUnload: function() {

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
