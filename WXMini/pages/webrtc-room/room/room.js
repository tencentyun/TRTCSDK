const app = getApp();
const account = require('../account');

const ROLE_TYPE = {
  AUDIENCE: 'audience',
  PRESENTER: 'presenter'
}

Page({
  /**
   * 页面的初始数据
   */
  data: {
    template: 'float',
    webrtcroomComponent: null,
    roomID: '', // 房间id
    beauty: 0,
    muted: false,
    debug: false,
    frontCamera: true,
    role: ROLE_TYPE.PRESENTER, // presenter 代表主播，audience 代表观众
    userId: '',
    userSig: '',
    sdkAppID: account.sdkappid,
    isErrorModalShow: false,
    autoplay: true,
    enableCamera: true,
    smallViewLeft: 'calc(100vw - 30vw - 2vw)',
    smallViewTop: '20vw',
    smallViewWidth: '30vw',
    smallViewHeight: '40vw',
  },


  /**
   * 监听webrtc事件
   */
  onRoomEvent(e) {
    var self = this;
    switch (e.detail.tag) {
      case 'error':
        if (this.data.isErrorModalShow) { // 错误提示窗口是否已经显示
          return;
        }
        this.data.isErrorModalShow = true;
        wx.showModal({
          title: '提示',
          content: e.detail.detail,
          showCancel: false,
          complete: function () {
            self.data.isErrorModalShow = false;
            self.goBack();
          }
        });
        break;
    }
  },

  /**
   * 切换摄像头
   */
  changeCamera: function () {
    this.data.webrtcroomComponent.switchCamera();
    this.setData({
      frontCamera: !this.data.frontCamera
    })
  },

  /**
   * 开启/关闭摄像头
   */
  onEnableCameraClick: function () {
    this.data.enableCamera = !this.data.enableCamera;
    this.setData({
      enableCamera: this.data.enableCamera
    });
  },


  /**
   * 设置美颜
   */
  setBeauty: function () {
    this.data.beauty = (this.data.beauty == 0 ? 9 : 0);
    this.setData({
      beauty: this.data.beauty
    });
  },

  /**
   * 切换是否静音
   */
  changeMute: function () {
    this.data.muted = !this.data.muted;
    this.setData({
      muted: this.data.muted
    });
  },

  /**
   * 是否显示日志
   */
  showLog: function () {
    this.data.debug = !this.data.debug;
    this.setData({
      debug: this.data.debug
    });
  },

  /**
   * 进入房间
   */
  joinRoom: function () {
    // 设置webrtc-room标签中所需参数，并启动webrtc-room标签
    this.setData({
      userID: this.data.userId,
      userSig: this.data.userSig,
      sdkAppID: this.data.sdkAppID,
      roomID: this.data.roomID
    }, () => {
      this.data.webrtcroomComponent.start();
    })
  },

  /**
   * 返回上一页
   */
  goBack() {
    var pages = getCurrentPages();
    if (pages.length > 1 && (pages[pages.length - 1].__route__ == 'pages/webrtc-room/room/room')) {
      wx.navigateBack({
        delta: 1
      });
    }
  },


  /**
   * 生命周期函数--监听页面加载
   */
  onLoad: function (options) {
    this.data.roomID = options.roomID || '';
    this.data.userId = options.userId;
    this.data.userSig = options.userSig;
    this.data.template = options.template;

    this.data.webrtcroomComponent = this.selectComponent('#webrtcroom');

    this.setData({
      template: options.template
    });

    this.joinRoom();

    // 动态设置当前页面的标题 房间号+userid
    wx.setNavigationBarTitle({
      title: this.data.roomID + '-' + this.data.userId
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
    var self = this;
    console.log('room.js onShow');
    // 保持屏幕常亮
    wx.setKeepScreenOn({
      keepScreenOn: true
    })
  },

  /**
   * 生命周期函数--监听页面隐藏
   */
  onHide: function () {
    console.log('room.js onHide');
  },

  /**
   * 生命周期函数--监听页面卸载
   */
  onUnload: function () {
    console.log('room.js onUnload');
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
    return {
      // title: '',
      path: '/pages/webrtc-room/index/index',
      imageUrl: 'https://mc.qcloudimg.com/static/img/dacf9205fe088ec2fef6f0b781c92510/share.png'
    }
  },


  onBack: function () {
    wx.navigateBack({
      delta: 1
    });
  },
})