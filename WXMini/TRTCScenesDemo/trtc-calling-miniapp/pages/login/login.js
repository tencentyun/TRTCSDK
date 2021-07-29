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
    if (!this.data.userID) {
      wx.showToast({
        title: '名称不能为空',
        icon: 'error',
      })
    } else {
      wx.$globalData.userID = this.data.userID
      wx.switchTab({
        url: '../index/index',
      });
    }
  },
})
