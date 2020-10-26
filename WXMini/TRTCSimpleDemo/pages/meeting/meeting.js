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
    localVideo: true,
    localAudio: true,
    enableEarMonitor: false,
    enableAutoFocus: true,
    localMirror: 'auto',
    enableAgc: true,
    enableAns: true,
    frontCamera: 'front',
    audioVolumeType: 'auto',
    resolution: 'SD',
    debugMode: false,
    audioQuality: 'high',
    // 用于自定义输入视频分辨率和默认值
    videoWidth: 360,
    videoHeight: 640,
    minBitrate: 600,
    maxBitrate: 900,
    // pusher URL 参数
    scene: 'rtc',
    encsmall: false,
    cloudenv: 'PRO',
    enableBlackStream: 0,
    streamID: '',
    userDefineRecordID: '',
    privateMapKey: '',
    pureAudioMode: '', // 默认不填，值为1或者2
    recvMode: '',
    // player 参数
    enableRecvMessage: false,

    audioQualityArray: [
      { value: 'high', title: '48K' },
      { value: 'low', title: '16K' },
    ],
    cloudenvArray: [
      { value: 'PRO', title: 'PRO' },
      { value: 'CCC', title: 'CCC' },
      { value: 'DEV', title: 'DEV' },
      { value: 'UAT', title: 'UAT' },
    ],
    sceneArray: [
      { value: 'rtc', title: '通话' },
      { value: 'live', title: '直播' },
    ],
    audioVolumeTypeArray: [
      { value: 'auto', title: '自动' },
      { value: 'media', title: '媒体' },
      { value: 'voicecall', title: '通话' },
    ],
    localMirrorArray: [
      { value: 'auto', title: '自动' },
      { value: 'enable', title: '开启' },
      { value: 'disable', title: '关闭' },
    ],
    resolutionArray: [
      { value: 'FHD', title: 'FHD' },
      { value: 'HD', title: 'HD' },
      { value: 'SD', title: 'SD' },
    ],
    headerHeight: app.globalData.headerHeight,
    statusBarHeight: app.globalData.statusBarHeight,
  },

  enterHandler: function(event) {
    const key = event.currentTarget.dataset.key
    const data = {}
    data[key] = event.detail.value
    if ('roomID' === key) {
      data[key] = data[key].replace(/[^A-Za-z0-9]/g, '')
    }
    this.setData(data, () => {
      console.log(`set ${key}:`, data[key])
    })
  },

  switchHandler: function(event) {
    const key = event.currentTarget.dataset.key
    const data = {}
    data[key] = event.detail.value
    if (key === 'enableBlackStream') {
      data[key] = data[key] === false ? 0 : 1
    }
    this.setData(data, () => {
      console.log(`set ${key}:`, data[key])
    })
  },

  selectHandler: function(event) {
    const key = event.currentTarget.dataset.key
    const data = {}
    data[key] = event.detail.value
    this.setData(data, () => {
      console.log(`set ${key}:`, data[key])
      if ('resolution' === key) {
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
            break
        }
      }
    })
  },

  enterRoom: function() {
    const nowTime = new Date()
    if (nowTime - this.tapTime < 1200) {
      return
    }

    const url = `../room/room?roomID=${this.data.roomID}` +
                `&template=${this.data.template}` +
                `&debugMode=${this.data.debugMode}` +
                `&localVideo=${this.data.localVideo}` +
                `&localAudio=${this.data.localAudio}` +
                `&enableEarMonitor=${this.data.enableEarMonitor}` +
                `&enableAutoFocus=${this.data.enableAutoFocus}` +
                `&localMirror=${this.data.localMirror}` +
                `&enableAgc=${this.data.enableAgc}` +
                `&enableAns=${this.data.enableAns}` +
                `&frontCamera=${this.data.frontCamera}` +
                `&audioVolumeType=${this.data.audioVolumeType}` +
                `&audioQuality=${this.data.audioQuality}` +
                `&videoWidth=${this.data.videoWidth}` +
                `&videoHeight=${this.data.videoHeight}` +
                `&userID=${this.data.userID}` +
                `&minBitrate=${this.data.minBitrate}` +
                `&maxBitrate=${this.data.maxBitrate}` +
                // pusher URL 参数
                `&encsmall=${this.data.encsmall}` +
                `&scene=${this.data.scene}` +
                `&cloudenv=${this.data.cloudenv}` +
                `&enableBlackStream=${this.data.enableBlackStream}` +
                `&streamID=${this.data.streamID}` +
                `&userDefineRecordID=${this.data.userDefineRecordID}` +
                `&privateMapKey=${this.data.privateMapKey}` +
                `&pureAudioMode=${this.data.pureAudioMode}` +
                `&recvMode=${this.data.recvMode}` +
                // player参数
                `&enableRecvMessage=${this.data.enableRecvMessage}`
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
      this.tapTime = nowTime
      this.checkDeviceAuthorize().then((result)=>{
        console.log('授权成功', result)
        console.log('navigateTo', url)
        wx.navigateTo({ url: url })
      }).catch((error)=>{
        console.log('没有授权', error)
      })
    }
  },

  checkDeviceAuthorize: function() {
    this.hasOpenDeviceAuthorizeModal = false
    return new Promise((resolve, reject) => {
      if (!wx.getSetting || !wx.getSetting()) {
        // 微信测试版 获取授权API异常，目前只能即使没授权也可以通过
        resolve()
      }
      wx.getSetting().then((result)=> {
        console.log('getSetting', result)
        this.authorizeMic = result.authSetting['scope.record']
        this.authorizeCamera = result.authSetting['scope.camera']
        if (result.authSetting['scope.camera'] && result.authSetting['scope.record']) {
          // 授权成功
          resolve()
        } else {
          // 没有授权，弹出授权窗口
          // 注意： wx.authorize 只有首次调用会弹框，之后调用只返回结果，如果没有授权需要自行弹框提示处理
          console.log('getSetting 没有授权，弹出授权窗口', result)
          wx.authorize({
            scope: 'scope.record',
          }).then((res)=>{
            console.log('authorize mic', res)
            this.authorizeMic = true
            if (this.authorizeCamera) {
              resolve()
            }
          }).catch((error)=>{
            console.log('authorize mic error', error)
            this.authorizeMic = false
          })
          wx.authorize({
            scope: 'scope.camera',
          }).then((res)=>{
            console.log('authorize camera', res)
            this.authorizeCamera = true
            if (this.authorizeMic) {
              resolve()
            } else {
              this.openConfirm()
              reject(new Error('authorize fail'))
            }
          }).catch((error)=>{
            console.log('authorize camera error', error)
            this.authorizeCamera = false
            this.openConfirm()
            reject(new Error('authorize fail'))
          })
        }
      })
    })
  },
  openConfirm: function() {
    if (this.hasOpenDeviceAuthorizeModal) {
      return
    }
    this.hasOpenDeviceAuthorizeModal = true
    return wx.showModal({
      content: '您没有打开麦克风和摄像头的权限，是否去设置打开？',
      confirmText: '确认',
      cancelText: '取消',
      success: (res)=>{
        this.hasOpenDeviceAuthorizeModal = false
        console.log(res)
        // 点击“确认”时打开设置页面
        if (res.confirm) {
          console.log('用户点击确认')
          wx.openSetting({
            success: (res) => { },
          })
        } else {
          console.log('用户点击取消')
        }
      },
    })
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
    // this.randomUserID()
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
