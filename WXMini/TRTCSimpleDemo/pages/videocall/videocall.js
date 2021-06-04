// index.js
// const app = getApp()
import { randomUserID } from '../../utils/common'
import { genTestUserSig } from '../../debug/GenerateTestUserSig'

const app = getApp()
Page({
  data: {
    roomID: '',
    headerHeight: app.globalData.headerHeight,
    statusBarHeight: app.globalData.statusBarHeight,
  },

  onLoad() {

  },
  enterRoomID(event) {
    this.setData({
      roomID: event.detail.value,
    })
  },
  enterRoom() {
    const { roomID } = this.data
    const nowTime = new Date()
    if (nowTime - this.tapTime < 1000) {
      return
    }
    if (!roomID) {
      wx.showToast({
        title: '请输入房间号',
        icon: 'none',
        duration: 2000,
      })
      return
    }
    if (/^\d*$/.test(roomID) === false) {
      wx.showToast({
        title: '房间号只能为数字',
        icon: 'none',
        duration: 2000,
      })
      return
    }
    if (roomID > 4294967295 || roomID < 1) {
      wx.showToast({
        title: '房间号取值范围为 1~4294967295',
        icon: 'none',
        duration: 2000,
      })
      return
    }
    const userID = randomUserID()
    const Signature = genTestUserSig(userID)
    const url = `./room/room?roomID=${roomID}&userID=${userID}&sdkAppID=${Signature.sdkAppID}&userSig=${Signature.userSig}`
    this.tapTime = nowTime
    this.checkDeviceAuthorize().then((result) => {
      console.log('授权成功', result)
      wx.navigateTo({ url })
    })
      .catch((error) => {
        console.log('没有授权', error)
      })
  },
  checkDeviceAuthorize() {
    this.hasOpenDeviceAuthorizeModal = false
    return new Promise((resolve, reject) => {
      if (!wx.getSetting || !wx.getSetting()) {
        // 微信测试版 获取授权API异常，目前只能即使没授权也可以通过
        resolve()
      }
      wx.getSetting().then((result) => {
        console.log('getSetting', result)
        this.authorizeMic = result.authSetting['scope.record']
        this.authorizeCamera = result.authSetting['scope.camera']
        if (result.authSetting['scope.camera'] && result.authSetting['scope.record']) {
          // 授权成功
          resolve()
        } else {
          // 没有授权，弹出授权窗口
          // 注意： wx.authorize 只有首次调用会弹框，之后调用只返回结果，如果没有授权需要自行弹框提示处理
          console.log('getSetting 没有授权，弹出授权窗口', result)
          wx.authorize({
            scope: 'scope.record',
          }).then((res) => {
            console.log('authorize mic', res)
            this.authorizeMic = true
            if (this.authorizeCamera) {
              resolve()
            }
          })
            .catch((error) => {
              console.log('authorize mic error', error)
              this.authorizeMic = false
            })
          wx.authorize({
            scope: 'scope.camera',
          }).then((res) => {
            console.log('authorize camera', res)
            this.authorizeCamera = true
            if (this.authorizeMic) {
              resolve()
            } else {
              this.openConfirm()
              reject(new Error('authorize fail'))
            }
          })
            .catch((error) => {
              console.log('authorize camera error', error)
              this.authorizeCamera = false
              this.openConfirm()
              reject(new Error('authorize fail'))
            })
        }
      })
    })
  },
  openConfirm() {
    if (this.hasOpenDeviceAuthorizeModal) {
      return
    }
    this.hasOpenDeviceAuthorizeModal = true
    return wx.showModal({
      content: '您没有打开麦克风和摄像头的权限，是否去设置打开？',
      confirmText: '确认',
      cancelText: '取消',
      success: (res) => {
        this.hasOpenDeviceAuthorizeModal = false
        console.log(res)
        // 点击“确认”时打开设置页面
        if (res.confirm) {
          console.log('用户点击确认')
          wx.openSetting({
            success: (res) => { },
          })
        } else {
          console.log('用户点击取消')
        }
      },
    })
  },
  onBack() {
    wx.navigateBack({
      delta: 1,
    })
  },
})
