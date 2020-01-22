// index.js
// const app = getApp()
const app = getApp()
Page({
  data: {
    roomID: '',
    template: '1v1',
    debugMode: false,
    cloudenv: 'PRO',
    evnArray: [
      { value: 'PRO', title: 'PRO' },
      { value: 'CCC', title: 'CCC' },
      { value: 'DEV', title: 'DEV' },
      { value: 'UAT', title: 'UAT' },
    ],
    headerHeight: app.globalData.headerHeight,
    statusBarHeight: app.globalData.statusBarHeight,
  },

  onLoad: function() {

  },
  enterRoomID: function(event) {
    console.log('index enterRoomID', event)
    this.setData({
      roomID: event.detail.value,
    })
  },
  selectTemplate: function(event) {
    console.log('index selectTemplate', event)
    this.setData({
      template: event.detail.value,
    })
  },
  switchDebugMode: function(event) {
    console.log('index switchDebugMode', event)
    this.setData({
      debugMode: event.detail.value,
    })
  },
  selectEnv: function(event) {
    console.log('index switchDebugMode', event)
    this.setData({
      cloudenv: event.detail.value,
    })
  },
  enterRoom: function() {
    const roomID = this.data.roomID
    const nowTime = new Date()
    if (nowTime - this.tapTime < 1000) {
      return
    }
    if (!roomID) {
      wx.showToast({
        title: '请输入房间号',
        icon: 'none',
        duration: 2000,
      })
      return
    }
    if (/^\d*$/.test(roomID) === false) {
      wx.showToast({
        title: '房间号只能为数字',
        icon: 'none',
        duration: 2000,
      })
      return
    }
    if (roomID > 4294967295 || roomID < 0) {
      wx.showToast({
        title: '房间号取值范围为 1~4294967295',
        icon: 'none',
        duration: 2000,
      })
      return
    }
    const url = `../room/room?roomID=${roomID}&template=${this.data.template}&debugMode=${this.data.debugMode}&cloudenv=${this.data.cloudenv}`
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
})
