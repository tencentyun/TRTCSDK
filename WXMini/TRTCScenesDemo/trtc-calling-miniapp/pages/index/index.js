// index.js
Page({
  data: {
    template: '1v1',
    headerHeight: wx.$globalData.headerHeight,
    statusBarHeight: wx.$globalData.statusBarHeight,
    entryInfos: [
      { icon: 'https://web.sdk.qcloud.com/component/miniApp/resources/audio-card.png', title: '语音通话', desc: '丢包率70%仍可正常语音通话', navigateTo: '../audioCall/audioCall' },
      { icon: 'https://web.sdk.qcloud.com/component/miniApp/resources/video-card.png', title: '视频通话', desc: '包率50%仍可正常视频通话', navigateTo: '../videoCall/videoCall' },
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

  onShow() {
    if (typeof this.getTabBar === 'function' && this.getTabBar()) {
      this.getTabBar().setData({ selected: 0 })
    }
  },
})
