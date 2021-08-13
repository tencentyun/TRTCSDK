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
      type: 2,
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
    this.TRTCCalling.call({ userID: this.data.invitee.userID, type: 2 })
  },

  invitedEvent() {},

  hangupEvent() {},

  rejectEvent() {
    wx.showToast({
      title: '对方已拒绝',
    })
  },

  userLeaveEvent() {},

  onRespEvent() {
    wx.showToast({
      title: '对方不在线',
    })
    this.TRTCCalling.hangup()
  },

  callingTimeoutEvent() {
    wx.showToast({
      title: '无应答超时',
    })
  },

  lineBusyEvent() {
    wx.showToast({
      title: '对方忙线中',
    })
    this.TRTCCalling.hangup()
  },

  callingCancelEvent() {
    wx.showToast({
      title: '通话已取消',
    })
  },

  userEnterEvent() {},

  callEndEvent() {
    wx.showToast({
      title: '通话结束',
    })
    this.TRTCCalling.hangup()
  },

  bindTRTCCallingRoomEvent: function() {
    const TRTCCallingEvent = this.TRTCCalling.EVENT
    this.TRTCCalling.on(TRTCCallingEvent.INVITED, this.invitedEvent)
    // 处理挂断的事件回调
    this.TRTCCalling.on(TRTCCallingEvent.HANG_UP, this.hangupEvent)
    this.TRTCCalling.on(TRTCCallingEvent.REJECT, this.rejectEvent)
    this.TRTCCalling.on(TRTCCallingEvent.USER_LEAVE, this.userLeaveEvent)
    this.TRTCCalling.on(TRTCCallingEvent.NO_RESP, this.onRespEvent)
    this.TRTCCalling.on(TRTCCallingEvent.CALLING_TIMEOUT, this.callingTimeoutEvent)
    this.TRTCCalling.on(TRTCCallingEvent.LINE_BUSY, this.lineBusyEvent)
    this.TRTCCalling.on(TRTCCallingEvent.CALLING_CANCEL, this.callingCancelEvent)
    this.TRTCCalling.on(TRTCCallingEvent.USER_ENTER, this.userEnterEvent)
    this.TRTCCalling.on(TRTCCallingEvent.CALL_END, this.callEndEvent)
  },
  unbindTRTCCallingRoomEvent() {
    const TRTCCallingEvent = this.TRTCCalling.EVENT
    this.TRTCCalling.off(TRTCCallingEvent.INVITED, this.invitedEvent)
    this.TRTCCalling.off(TRTCCallingEvent.HANG_UP, this.hangupEvent)
    this.TRTCCalling.off(TRTCCallingEvent.REJECT, this.rejectEvent)
    this.TRTCCalling.off(TRTCCallingEvent.USER_LEAVE, this.userLeaveEvent)
    this.TRTCCalling.off(TRTCCallingEvent.NO_RESP, this.onRespEvent)
    this.TRTCCalling.off(TRTCCallingEvent.CALLING_TIMEOUT, this.callingTimeoutEvent)
    this.TRTCCalling.off(TRTCCallingEvent.LINE_BUSY, this.lineBusyEvent)
    this.TRTCCalling.off(TRTCCallingEvent.CALLING_CANCEL, this.callingCancelEvent)
    this.TRTCCalling.off(TRTCCallingEvent.USER_ENTER, this.userEnterEvent)
    this.TRTCCalling.off(TRTCCallingEvent.CALL_END, this.callEndEvent)
  },

  onBack: function() {
    wx.navigateBack({
      delta: 1,
    })
    this.TRTCCalling.logout()
  },


  onLoad: function() {
    const Signature = genTestUserSig(wx.$globalData.userID)
    console.log('audio----config', wx.$globalData)
    const config = {
      sdkAppID: wx.$globalData.sdkAppID,
      userID: wx.$globalData.userID,
      userSig: Signature.userSig,
    }
    this.setData({
      config: { ...this.data.config, ...config },
    }, () => {
      this.TRTCCalling = this.selectComponent('#TRTCCalling-component')
      this.bindTRTCCallingRoomEvent()
      this.TRTCCalling.login()
    })
  },
  /**
   * 生命周期函数--监听页面卸载
   */
  onUnload: function() {
    // 取消监听事件
    this.unbindTRTCCallingRoomEvent()
    // 退出登录
    this.TRTCCalling.logout()
  },

  onShow: function() {

  },
})
