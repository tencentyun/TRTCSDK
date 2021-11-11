import { genTestUserSig } from '../../debug/GenerateTestUserSig'

Page({
  data: {
    userIDToSearch: '',
    searchResultShow: false,
    invitee: null,
    config: {
      sdkAppID: wx.$globalData.sdkAppID,
      userID: wx.$globalData.userID,
      userSig: wx.$globalData.userSig,
      type: 1,
      tim: null,
    },
  },

  userIDToSearchInput: function(e) {
    this.setData({
      userIDToSearch: e.detail.value,
    })
  },

  searchUser: function() {
    this.data.invitee = {
      userID: this.data.userIDToSearch,
    }
    this.setData({
      searchResultShow: true,
      invitee: this.data.invitee,
    }, () => {
      console.log('searchUser: invitee:', this.data.invitee)
    })
  },

  call: function() {
    if (this.data.config.userID === this.data.invitee.userID) {
      wx.showToast({
        icon: 'none',
        title: '不可呼叫本机',
      })
      return
    }
    this.TUICalling.call({ userID: this.data.invitee.userID, type: 1 })
  },

  onBack: function() {
    wx.navigateBack({
      delta: 1,
    })
    this.TUICalling.destroyed()
  },


  onLoad: function() {
    const Signature = genTestUserSig(wx.$globalData.userID)
    const config = {
      sdkAppID: wx.$globalData.sdkAppID,
      userID: wx.$globalData.userID,
      userSig: Signature.userSig,
    }
    this.setData({
      config: { ...this.data.config, ...config },
    }, () => {
      this.TUICalling = this.selectComponent('#TUICalling-component')
      this.TUICalling.init()
    })
  },
  /**
   * 生命周期函数--监听页面卸载
   */
  onUnload: function() {
    this.TUICalling.destroyed()
  },

  onShow: function() {

  },
})
