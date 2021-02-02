import { genTestUserSig } from './debug/GenerateTestUserSig'
const Signature = genTestUserSig('')
App({
  onLaunch: function() {
    wx.$globalData = {
      userInfo: null,
      headerHeight: 0,
      statusBarHeight: 0,
      sdkAppID: Signature.sdkAppID,
      userID: '',
      userSig: '',
      token: '',
      expiresIn: '',
      phone: '',
      sessionID: '',
    }
  },
})
