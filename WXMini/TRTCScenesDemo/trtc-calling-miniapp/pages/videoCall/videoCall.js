import { genTestUserSig } from '../../debug/GenerateTestUserSig';

Page({
  data: {
    userIDToSearch: '',
    searchResultShow: false,
    invitee: null,
    config: {
      sdkAppID: wx.$globalData.sdkAppID,
      userID: wx.$globalData.userID,
      userSig: wx.$globalData.userSig,
      type: 2,
    }
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
        icon: "none",
        title: '不可呼叫本机',
      })
      return
    }
    this.TRTCCalling.call({ userID: this.data.invitee.userID, type: 2 })
  },

  bindTRTCCallingRoomEvent: function() {
    const TRTCCallingEvent = this.TRTCCalling.EVENT
    this.TRTCCalling.on(TRTCCallingEvent.INVITED, (event) => {

    })
    // 处理挂断的事件回调
    this.TRTCCalling.on(TRTCCallingEvent.HANG_UP, () => {
  
    })
    this.TRTCCalling.on(TRTCCallingEvent.REJECT, () => {
 
      wx.showToast({
        icon: "none",
        title: '对方已拒绝',
      })
      this.TRTCCalling.hangup()
    })
    this.TRTCCalling.on(TRTCCallingEvent.USER_LEAVE, () => {
      // this.TRTCCalling.hangup()
      // wx.showToast({
      //   icon: "none",
      //   title: '对方已挂断',
      // })
    })
    this.TRTCCalling.on(TRTCCallingEvent.NO_RESP, () => {
  
      wx.showToast({
        icon: "none",
        title: '对方不在线',
      })
      this.TRTCCalling.hangup()
    })
    this.TRTCCalling.on(TRTCCallingEvent.CALLING_TIMEOUT, () => {
  
      wx.showToast({
        icon: "none",
        title: '无应答超时',
      })
      this.TRTCCalling.hangup()
    })
    this.TRTCCalling.on(TRTCCallingEvent.LINE_BUSY, () => {

      wx.showToast({
        icon: "none",
        title: '对方忙线中',
      })
      this.TRTCCalling.hangup()
    })
    this.TRTCCalling.on(TRTCCallingEvent.CALLING_CANCEL, () => {
   
      wx.showToast({
        icon: "none",
        title: '通话已取消',
      })
    })
    this.TRTCCalling.on(TRTCCallingEvent.USER_ENTER, () => {
      
    })
    this.TRTCCalling.on(TRTCCallingEvent.CALL_END, () => {
      wx.showToast({
        icon: "none",
        title: '通话结束',
      })
      this.TRTCCalling.hangup()
    })
  },

  onBack: function() {
    wx.navigateBack({
      delta: 1,
    })
    this.TRTCCalling.logout()
  },


  onLoad: function() {
    const Signature = genTestUserSig(wx.$globalData.userID)
    console.log('audio----config', wx.$globalData);
    const config = {
      sdkAppID: wx.$globalData.sdkAppID,
      userID: wx.$globalData.userID,
      userSig: Signature.userSig
    }
    this.setData({
      config: { ...this.data.config, ...config }
    }, () => {
      this.TRTCCalling = this.selectComponent('#TRTCCalling-component')
      this.bindTRTCCallingRoomEvent()
      this.TRTCCalling.login()
    })
  },

  onShow: function() {

  },
})
