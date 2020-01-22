import { DEFAULT_PUSHER_CONFIG } from '../common/constants.js'

class Pusher {
  constructor(options) {
    Object.assign(this, DEFAULT_PUSHER_CONFIG, {
      isVisible: true, // 手Q初始化时不能隐藏 puser和player 否则黑屏
    },options)
  }
  /**
   * 通过wx.createLivePusherContext 获取<live-pusher> context
   * @param {Object} context 组件上下文
   * @returns {Object} livepusher context
   */
  getPusherContext(context) {
    if (!this.pusherContext) {
      this.pusherContext = wx.createLivePusherContext(context)
    }
    return this.pusherContext
  }
  reset() {
    console.log('Pusher reset', this.pusherContext)
    if (this.pusherContext) {
      console.log('Pusher pusherContext.stop()')
      this.pusherContext.stop()
      this.pusherContext = null
    }
    Object.assign(this, DEFAULT_PUSHER_CONFIG, {
      isVisible: true,
    })
  }
}

export default Pusher
