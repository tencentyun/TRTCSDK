// index.js
// const app = getApp()
const app = getApp()
Page({
  data: {
    template: '1v1',
    headerHeight: app.globalData.headerHeight,
    statusBarHeight: app.globalData.statusBarHeight,
    entryInfos: [
      { icon: '../Resources/call.png', title: '语音通话', desc: '<TRTCCaliing>', navigateTo: '../audioCall/audioCall' },
      { icon: '../Resources/doubleroom.png', title: '视频通话', desc: '<TRTCCaliing>', navigateTo: '../videoCall/videoCall' },
    ],
  },

  onLoad: function() {

  },
  selectTemplate: function(event) {
    console.log('index selectTemplate', event)
    this.setData({
      template: event.detail.value,
    })
  },
  handleEntry: function(e) {
    const url = this.data.entryInfos[e.currentTarget.id].navigateTo
    wx.navigateTo({
      url: url,
    })
  },
})
