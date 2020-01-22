// index.js
// const app = getApp()
const app = getApp()
Page({
  data: {
    template: '1v1',
    headerHeight: app.globalData.headerHeight,
    statusBarHeight: app.globalData.statusBarHeight,
  },

  onLoad: function() {

  },
  selectTemplate: function(event) {
    console.log('index selectTemplate', event)
    this.setData({
      template: event.detail.value,
    })
  },
  enterRoom: function() {
    let url = '../videocall/videocall'
    if (this.data.template === 'grid') {
      url = '../meeting/meeting'
    }
    wx.navigateTo({
      url: url,
    })
  },
})
