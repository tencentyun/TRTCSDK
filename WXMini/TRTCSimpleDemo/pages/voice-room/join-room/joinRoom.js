const app = getApp()
Page({

  /**
   * 页面的初始数据
   */
  data: {
    roomID: '',
    userID: '',
    role: 'presenter', // 用户角色 presenter audience
    tapTime: '',
    headerHeight: app.globalData.headerHeight,
    statusBarHeight: app.globalData.statusBarHeight,
    lc: '◀︎',
    audioVolumeType: 'media',
    debugMode: false,
    streamList: [],
  },
  // 绑定输房间号入框
  bindRoomID: function(e) {
    this.setData({
      roomID: e.detail.value,
    })
  },
  bindUserID: function(e) {
    this.setData({
      userID: e.detail.value,
    })
  },
  roleChange: function(e) {
    this.setData({
      role: e.detail.value,
    })
  },
  selectVolumeType: function(e) {
    this.setData({
      audioVolumeType: e.detail.value,
    })
  },
  switchDebugMode: function(event) {
    this.setData({
      debugMode: event.detail.value,
    })
  },
  radioDebugChange: function(e) {
    this.setData({
      debug: e.detail.value,
    })
  },
  // 进入rtcroom页面
  joinRoom: function() {
    // 防止两次点击操作间隔太快
    const nowTime = new Date()
    if (nowTime - this.tapTime < 1000) {
      return
    }

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
      return
    }
    if (/^\d*$/.test(this.data.roomID) === false) {
      wx.showToast({
        title: '只能为数字',
        icon: 'none',
        duration: 2000,
      })
      return
    }

    const url = '../room/room?&roomID=' + this.data.roomID + '&debugMode=' + this.data.debugMode + '&userID=' + this.data.userID + '&role=' + this.data.role + '&audioVolumeType=' + this.data.audioVolumeType
    this.tapTime = nowTime
    this.checkDeviceAuthorize().then((result)=>{
      console.log('授权成功', result)
      wx.navigateTo({ url: url })
    }).catch((error)=>{
      console.log('没有授权', error)
    })
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
        // this.authorizeCamera = result.authSetting['scope.camera']
        if (result.authSetting['scope.record']) {
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
            resolve()
          }).catch((error)=>{
            console.log('authorize mic error', error)
            this.authorizeMic = false
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
      content: '您没有打开麦克风的权限，是否去设置打开？',
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
  /**
   * 生命周期函数--监听页面加载
   * @param {*} options 配置项
   */
  onLoad: function(options) {

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
    wx.setKeepScreenOn({
      keepScreenOn: true,
    })
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
})
