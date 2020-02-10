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
    if (nowTime - this.data.tapTime < 1000) {
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

    const url = '../room/room?&roomID=' + this.data.roomID + '&debugMode=' + this.data.debugMode + '&userID=' + this.data.userID + '&role=' + this.data.role
    wx.navigateTo({
      url: url,
    })
    this.setData({ 'tapTime': nowTime })
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
