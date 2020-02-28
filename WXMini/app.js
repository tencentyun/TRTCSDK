// app.js
App({
  onLaunch: function() {
    const { model, system, statusBarHeight } = wx.getSystemInfoSync()
    let headHeight
    if (/iphone\s{0,}x/i.test(model)) {
      headHeight = 88
    } else if (system.indexOf('Android') !== -1) {
      headHeight = 68
    } else {
      headHeight = 64
    }
    this.globalData.headerHeight = headHeight
    this.globalData.statusBarHeight = statusBarHeight
  },
  globalData: {
    headerHeight: 0,
    statusBarHeight: 0,
  },
})
