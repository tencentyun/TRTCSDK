const app = getApp()
const GenerateTestUserSig = require("../debug/GenerateTestUserSig.js");

Page({
  data: {
    // 微信官方提供获取微信和头像的方法
    userInfo: {},
    hasUserInfo: false,
    canIUse: wx.canIUse('button.open-type.getUserInfo'),
    // 用于快速进入会议
    userID: '',
    tapTime: '',
    template: 'grid'
  },

  onLoad: function () {
    if (app.globalData.userInfo) {
      this.setData({
        userInfo: app.globalData.userInfo,
        hasUserInfo: true
      })
    } else if (this.data.canIUse){
      // 由于 getUserInfo 是网络请求，可能会在 Page.onLoad 之后才返回
      // 所以此处加入 callback 以防止这种情况
      app.userInfoReadyCallback = res => {
        this.setData({
          userInfo: res.userInfo,
          hasUserInfo: true
        })
      }
    } else {
      // 在没有 open-type=getUserInfo 版本的兼容处理
      wx.getUserInfo({
        success: res => {
          app.globalData.userInfo = res.userInfo
          this.setData({
            userInfo: res.userInfo,
            hasUserInfo: true
          })
        }
      })
    }
  },
  getUserInfo: function(e) {
    console.log(e)
    app.globalData.userInfo = e.detail.userInfo
    this.setData({
      userInfo: e.detail.userInfo,
      hasUserInfo: true
    })
  },

  enterMeetingPage: function() {
    wx.navigateTo({
      url: '../index/index'
    })
  },

  quicMeeting: function() {
    var self = this;
    // 随机生成房间编号，并进入房间

    let num = new Date().getTime();
    let roomNo = num.toString().substring(9);

    self.setData({
      userID: new Date().getTime().toString(16)
    })

    var userSig = GenerateTestUserSig.genTestUserSig(self.data.userID);

    var url = `../room/room?roomID=${roomNo}&template=${self.data.template}&sdkAppID=${userSig.sdkAppID}&userId=${self.data.userID}&userSig=${userSig.userSig}`;

		wx.navigateTo({
			url: url
		});

		wx.showToast({
			title: '创建房间'+ roomNo,
			icon: 'success',
			duration: 1000
    });

    wx.setNavigationBarTitle({
      title: roomNo
    });

		self.setData({
			'tapTime': nowTime
		});
	}

})
