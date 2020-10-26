const app = getApp()

Page({
  data: {
    userID: '',
  },

  onLoad: function() {

  },

  onShow: function() {

  },

  onBack: function() {
    wx.navigateBack({
      delta: 1,
    })
  },


  bindInputUserID(e) {
    this.setData({
      userID: e.detail.value,
    })
  },

  login() {
    app.globalData.userID = this.data.userID
    wx.redirectTo({
      // 若把入口加到腾讯视频云小程序下，则带参数进行传递
      url: `../index/index`,
    })
  },
})
