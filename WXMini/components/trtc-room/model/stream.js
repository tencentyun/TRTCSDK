// 一个stream 对应一个 player
import { DEFAULT_PLAYER_CONFIG } from '../common/constants.js'

class Stream {
  constructor(options) {
    Object.assign(this, DEFAULT_PLAYER_CONFIG, {
      userID: '', // 该stream 关联的userID
      streamType: '', // stream 类型 [main small] aux
      isVisible: true, // 手Q初始化时不能隐藏 puser和player 否则黑屏。iOS 微信初始化时不能隐藏，否则同层渲染失败，player会置顶
      hasVideo: false,
      hasAudio: false,
      playerContext: undefined, // playerContext 依赖component context来获取，目前只能在渲染后获取
    }, options)
  }
  /**
   * 大小流切换
   */
  switchMainSmallStream() {
    if (this.streamType === 'main' || this.streamType === 'small') {
      // 大小流切换逻辑
      // 修改 streamType 和 streamURL 并调用 componentContext setData()
    } else {
      console.log('aux 不支持大小流切换')
    }
  }
  reset() {
    if (!this.playerContext) {
      this.playerContext.stop()
      this.playerContext = null
    }
    Object.assign(this, DEFAULT_PLAYER_CONFIG, {
      userID: '', // 该stream 关联的userID
      streamType: '', // stream 类型 [main small] aux
      streamID: '',
      isVisible: true,
      hasVideo: false,
      hasAudio: false,
      playerContext: undefined,
    })
  }
}

export default Stream
