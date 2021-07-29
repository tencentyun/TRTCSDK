Page({

  /**
   * 页面的初始数据
   */
  data: {
    userId: wx.$globalData.userID,
    toggle: false
  },

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad: function (options) {
    this.setData({
      userId: wx.$globalData.userID,
    })
  },

  /**
   * 生命周期函数--监听页面初次渲染完成
   */
  onReady: function () {

  },

  /**
   * 生命周期函数--监听页面显示
   */
  onShow: function () {

  },

  /**
   * 生命周期函数--监听页面隐藏
   */
  onHide: function () {

  },

  /**
   * 生命周期函数--监听页面卸载
   */
  onUnload: function () {

  },

  /**
   * 页面相关事件处理函数--监听用户下拉动作
   */
  onPullDownRefresh: function () {

  },

  /**
   * 页面上拉触底事件的处理函数
   */
  onReachBottom: function () {

  },

  /**
   * 用户点击右上角分享
   */
  onShareAppMessage: function () {

  },
  onBack() {
    wx.navigateBack({
      delta: 1,
    })
  },
  handleCancellation() {
    this.setData({
      toggle: true
    })
  },
  close() {
    this.setData({
      toggle: false
    })
  },
  submit() {
    wx.clearStorage();
    app.resetLoginData();
    wx.redirectTo({ url: '../login/login' });
    this.close();
  }
})