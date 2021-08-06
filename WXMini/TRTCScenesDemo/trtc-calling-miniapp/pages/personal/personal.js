// pages/personal/personal.js
Page({

  /**
   * 页面的初始数据
   */
  data: {
    list: [
      {
        icon: '../Resources/icon/text.png',
        name: '关于',
        path: '../about/index',
        extra: 1,
      },
      {
        icon: '../Resources/icon/logout.png',
        name: '退出登录',
        path: '../login/login',
        extra: 3,
      },
    ],
    userId: '',
  },

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad: function() {

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
    this.setData({
      userId: wx.$globalData.userID,
    })

    if (typeof this.getTabBar === 'function' && this.getTabBar()) {
      this.getTabBar().setData({ selected: 1 })
    }
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

  /**
   * 页面相关事件处理函数--监听用户下拉动作
   */
  onPullDownRefresh: function() {

  },

  /**
   * 页面上拉触底事件的处理函数
   */
  onReachBottom: function() {

  },

  /**
   * 用户点击右上角分享
   */
  onShareAppMessage: function() {

  },

  // 路由跳转
  handleRouter(e) {
    const data = e.currentTarget.dataset.item
    switch (data.extra) {
      case 1:
        wx.navigateTo({ url: `${data.path}` })
        break
      default:
        wx.clearStorage()
        wx.$globalData = {}
        wx.redirectTo({ url: `${data.path}` })
        break
    }
  },
})
