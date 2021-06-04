// index.js
// const app = getApp()
const app = getApp()
Page({
  data: {
    headerHeight: app.globalData.headerHeight,
    statusBarHeight: app.globalData.statusBarHeight,
    entryInfos: [
      { icon: '../../static/images/call.png', title: '语音聊天室', navigateTo: '../voice-room/join-room/joinRoom' },
      { icon: '../../static/images/doubleroom.png', title: '双人通话', navigateTo: '../videocall/videocall' },
      { icon: '../../static/images/multiroom.png', title: '多人会议', navigateTo: '../meeting/meeting' },
    ],
  },

  onLoad() {

  },
  selectTemplate(event) {
    console.log('index selectTemplate', event)
    this.setData({
      template: event.detail.value,
    })
  },
  handleEntry(e) {
    const url = this.data.entryInfos[e.currentTarget.id].navigateTo
    wx.navigateTo({
      url,
    })
  },
})
