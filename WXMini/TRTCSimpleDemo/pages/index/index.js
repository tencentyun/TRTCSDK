// index.js
// const app = getApp()
const app = getApp()
Page({
  data: {
    template: '1v1',
    headerHeight: app.globalData.headerHeight,
    statusBarHeight: app.globalData.statusBarHeight,
    entryInfos: [
      { icon: "../../images/call.png", title: "语音聊天室", desc: "<trtc-room>", navigateTo: "../voice-room/join-room/joinRoom" },
      { icon: "../../images/doubleroom.png", title: "双人通话", desc: "<trtc-room>", navigateTo: "../videocall/videocall" },
      { icon: "../../images/multiroom.png", title: "多人会议", desc: "<trtc-room>", navigateTo: "../meeting/meeting" }
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
    let url = this.data.entryInfos[e.currentTarget.id].navigateTo
    wx.navigateTo({
      url: url,
    })
  },
})
