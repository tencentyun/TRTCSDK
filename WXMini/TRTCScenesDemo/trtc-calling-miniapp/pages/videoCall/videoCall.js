import { genTestUserSig } from '../../debug/GenerateTestUserSig'

const app = getApp()

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
      sdkAppID: app.globalData.sdkAppID,
      userID: app.globalData.userID,
      userSig: app.globalData.userSig,
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
        title: '不可呼叫本机',
      })
      return
    }
    this.data.config.type = 2
    this.setData({
      callingFlag: true,
      inviteCallFlag: true,
      config: this.data.config,
    })
    this.TRTCCalling.call({ userID: this.data.invitee.userID, type: 2 })
  },

  bindTRTCCallingRoomEvent: function() {
    const TRTCCallingEvent = this.TRTCCalling.EVENT
    this.TRTCCalling.on(TRTCCallingEvent.INVITED, (event) => {
      this.setData({
        invitation: event.data,
        incomingCallFlag: true,
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
    this.data.config.type = this.data.invitation.type
    this.setData({
      callingFlag: true,
      incomingCallFlag: false,
      config: this.data.config,
    }, () => {
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
    const Signature = genTestUserSig(app.globalData.userID)
    this.data.config.sdkAppID = Signature.sdkAppID
    this.data.config.userID = app.globalData.userID
    this.data.config.userSig = Signature.userSig
    this.setData({
      config: this.data.config,
      loaclPhoneNumber: app.globalData.userID,
      pusherAvatar: this.data.pusherAvatar,
    }, () => {
      this.TRTCCalling = this.selectComponent('#TRTCCalling-component')
      this.bindTRTCCallingRoomEvent()
      this.TRTCCalling.login()
    })
  },

  onShow: function() {

  },
})
