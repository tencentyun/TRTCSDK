// index.js
Page({
  data: {
    template: '1v1',
    headerHeight: wx.$globalData.headerHeight,
    statusBarHeight: wx.$globalData.statusBarHeight,
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
