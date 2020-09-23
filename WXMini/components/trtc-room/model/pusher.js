import { DEFAULT_PUSHER_CONFIG } from '../common/constants.js'

class Pusher {
  constructor(options) {
    Object.assign(this, DEFAULT_PUSHER_CONFIG, {
      isVisible: true, // 手Q初始化时不能隐藏 puser和player 否则黑屏
    }, options)
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
      // 2020/09/23 安卓端华为小米机型发现，安卓原生返回键，退房失败。
      // 会触发detached生命周期，调用到该方法，puhserContext.stop()调用不成功，但是清空url后，客户端调用的退房方法就会不生效
      // 这里做出改动，只有stop调用成功后，才会清空url，保持组件卸载流程的完整性，调用不成功的情况将由微信客户端兜底清除
      this.pusherContext.stop({
        success: () => {
          console.log('Pusher pusherContext.stop()')
          Object.assign(this, DEFAULT_PUSHER_CONFIG, {
            isVisible: true,
          })
        },
      })
      this.pusherContext = null
    }
  }
}

export default Pusher
