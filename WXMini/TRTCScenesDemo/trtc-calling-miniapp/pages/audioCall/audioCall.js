import { genTestUserSig } from '../../debug/GenerateTestUserSig'

Page({
  data: {
    userIDToSearch: '',
    searchResultShow: false,
    callingFlag: false,
    invitee: null,
    inviter: null,
    invitation: null,
    incomingCallFlag: false,
    inviteCallFlag: false,
    pusherAvatar: '',
    config: {
      sdkAppID: wx.$globalData.sdkAppID,
      userID: wx.$globalData.userID,
      userSig: wx.$globalData.userSig,
      type: 1,
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
        title: '不可呼叫本机',
      })
      return
    }
    this.data.config.type = 1
    this.setData({
      callingFlag: true,
      inviteCallFlag: true,
      config: this.data.config,
    })
    this.TRTCCalling.call({ userID: this.data.invitee.userID, type: 1 })
  },

  bindTRTCCallingRoomEvent: function() {
    const TRTCCallingEvent = this.TRTCCalling.EVENT
    this.TRTCCalling.on(TRTCCallingEvent.INVITED, (event) => {
      this.setData({
        invitation: event.data,
        incomingCallFlag: true,
      }, () => {
        console.log('inviteData', this.data.invitation)
      })
    })
    // 处理挂断的事件回调
    this.TRTCCalling.on(TRTCCallingEvent.HANG_UP, () => {
      this.setData({
        callingFlag: false,
      })
    })
    this.TRTCCalling.on(TRTCCallingEvent.REJECT, () => {
      this.setData({
        callingFlag: false,
        inviteCallFlag: false,
      })
      wx.showToast({
        title: '对方已拒绝',
      })
      this.TRTCCalling.hangup()
    })
    this.TRTCCalling.on(TRTCCallingEvent.USER_LEAVE, () => {
      this.TRTCCalling.hangup()
      wx.showToast({
        title: '对方已挂断',
      })
    })
    this.TRTCCalling.on(TRTCCallingEvent.NO_RESP, () => {
      this.setData({
        incomingCallFlag: false,
        inviteCallFlag: false,
      })
      wx.showToast({
        title: '对方不在线',
      })
      this.TRTCCalling.hangup()
    })
    this.TRTCCalling.on(TRTCCallingEvent.CALLING_TIMEOUT, () => {
      this.setData({
        incomingCallFlag: false,
        inviteCallFlag: false,
      })
      wx.showToast({
        title: '无应答超时',
      })
      this.TRTCCalling.hangup()
    })
    this.TRTCCalling.on(TRTCCallingEvent.LINE_BUSY, () => {
      this.setData({
        incomingCallFlag: false,
        inviteCallFlag: false,
      })
      wx.showToast({
        title: '对方忙线中',
      })
      this.TRTCCalling.hangup()
    })
    this.TRTCCalling.on(TRTCCallingEvent.CALLING_CANCEL, () => {
      this.setData({
        incomingCallFlag: false,
      })
      wx.showToast({
        title: '通话已取消',
      })
    })
    this.TRTCCalling.on(TRTCCallingEvent.USER_ENTER, () => {
      this.setData({
        inviteCallFlag: false,
      })
    })
  },

  handleOnAccept: function() {
    this.data.config.type = this.data.invitation.inviteData.callType
    this.setData({
      callingFlag: true,
      incomingCallFlag: false,
      config: this.data.config,
    }, () => {
      console.log(this.data.config)
      this.TRTCCalling.accept()
    })
  },

  handleOnReject: function() {
    this.setData({
      incomingCallFlag: false,
    }, () => {
      this.TRTCCalling.reject()
    })
  },

  handleOnCancel: function() {
    this.TRTCCalling.hangup()
    this.setData({
      inviteCallFlag: false,
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
    this.data.config.userID = wx.$globalData.userID
    this.data.config.userSig = Signature.userSig
    this.setData({
      config: this.data.config,
      loaclPhoneNumber: wx.$globalData.userID,
      pusherAvatar: '../Resources/avatar1_100',
    }, () => {
      this.TRTCCalling = this.selectComponent('#TRTCCalling-component')
      this.bindTRTCCallingRoomEvent()
      this.TRTCCalling.login()
    })
  },

  onShow: function() {

  },
})
