import UserController from 'controller/user-controller.js'
import Pusher from 'model/pusher.js'
import { EVENT } from 'common/constants.js'
import Event from 'utils/event.js'
import * as ENV from 'utils/environment.js'

const TAG_NAME = 'TRTC-ROOM'

Component({
  /**
   * 组件的属性列表
   */
  properties: {
    // 必要的初始化参数
    config: {
      type: Object,
      value: {
        sdkAppID: '',
        userID: '',
        userSig: '',
        template: '',
        debugMode: '',
      },
      observer: function(newVal, oldVal) {
        this._propertyObserver({
          'name': 'config', newVal, oldVal,
        })
      },
    },
  },

  /**
   * 组件的初始数据
   */
  data: {
    pusher: null,
    // debugMode: false, // 是否开启调试模式
    debugPanel: true, // 是否打开组件调试面板
    debug: false, // 是否打开player pusher 的调试信息
    streamList: [], // 用于渲染player列表,存储stram
    userList: [], // 扁平化的数据用来返回给用户
    template: '', // 不能设置默认值，当默认值和传入组件的值不一致时，iOS渲染失败
    cameraPosition: '',
    panelName: '', // 控制面板名称，包括 setting-panel  memberlist-panel
    localVolume: 0,
    remoteVolumeList: [],
    appVersion: ENV.APP_VERSION,
    libVersion: ENV.LIB_VERSION,
  },
  /**
   * 生命周期方法
   */
  lifetimes: {
    created: function() {
      // 在组件实例刚刚被创建时执行
      console.log(TAG_NAME, 'created', ENV)
    },
    attached: function() {
      // 在组件实例进入页面节点树时执行
      console.log(TAG_NAME, 'attached')
      this._init()
    },
    ready: function() {
      // 在组件在视图层布局完成后执行
      console.log(TAG_NAME, 'ready')
    },
    detached: function() {
      // 在组件实例被从页面节点树移除时执行
      console.log(TAG_NAME, 'detached')
      // 停止所有拉流，并重置数据
      this.exitRoom()
    },
    error: function(error) {
      // 每当组件方法抛出错误时执行
      console.log(TAG_NAME, 'error', error)
    },
  },
  pageLifetimes: {
    show: function() {
      // 组件所在的页面被展示时执行
      console.log(TAG_NAME, 'show status:', this.status)
      if (this.status.isPending) {
        // 经历了 5000 挂起事件
        this.status.isPending = false
      }
      if (this.status.isPush) {
        // 小程序hide - show 有一定概率本地黑屏或静止，远端正常，或者远端和本地同时黑屏或静止，需要手动启动预览，非必现
        // this.data.pusher.getPusherContext().startPreview()
        // this.data.pusher.getPusherContext().resume()
      }
    },
    hide: function() {
      // 组件所在的页面被隐藏时执行
      console.log(TAG_NAME, 'hide')
    },
    resize: function(size) {
      // 组件所在的页面尺寸变化时执行
      console.log(TAG_NAME, 'resize', size)
    },
  },
  /**
   * 组件的方法列表
   */
  methods: {
    /**
     * 初始化各项参数和用户控制模块，在组件实例触发 attached 时调用，此时不建议对View进行变更渲染（调用setData方法）
     */
    _init: function() {
      console.log(TAG_NAME, '_init')
      this.userController = new UserController(this)
      this._emitter = new Event()
      this.EVENT = EVENT
      this._initStatus()
      this._bindEvent()
      this._bindEventGrid()
      console.log(TAG_NAME, '_init success component:', this)
    },
    /**
     * 进房
     * @param {Object} params 必传 roomID 取值范围 1 ~ 4294967295
     * @returns {Promise}
     */
    enterRoom: function(params) {
      return new Promise((resolve, reject) => {
        console.log(TAG_NAME, 'enterRoom')
        console.log(TAG_NAME, 'params', params)
        console.log(TAG_NAME, 'config', this.data.config)
        console.log(TAG_NAME, 'pusher', this.data.pusher)
        // 1. 补齐进房参数，校验必要参数是否齐全
        if (params) {
          Object.assign(this.data.pusher, params)
          Object.assign(this.data.config, params)
        }
        if (!this._checkParam(this.data.config)) {
          reject(new Error('缺少必要参数'))
          return
        }
        // 2. 根据参数拼接 push url，赋值给 live-pusher，
        this._getPushUrl(this.data.config).then((pushUrl)=> {
          this.data.pusher.url = pushUrl
          this.setData({
            pusher: this.data.pusher,
          }, () => {
            console.log(TAG_NAME, 'enterRoom success', this.data.pusher)
            // view 渲染成功回调后，开始推流
            this.data.pusher.getPusherContext().start()
            this.status.isPush = true
            resolve()
          })
        }).catch((res)=> {
          // 获取 room sig 失败, 进房失败需要通过 pusher state 事件通知
          console.error(TAG_NAME, 'enterRoom fail', res)
          reject(res)
        })
      })
    },
    /**
     * 退房，停止推流和拉流，并重置数据
     * @returns {Promise}
     */
    exitRoom: function() {
      return new Promise((resolve, reject) => {
        console.log(TAG_NAME, 'exitRoom')
        this.data.pusher.reset()
        this.status.isPush = false
        const result = this.userController.reset()
        this.setData({
          pusher: this.data.pusher,
          userList: result.userList,
          streamList: result.streamList,
        }, () => {
          // 在销毁页面时调用，不会走到这里
          resolve({ userList: this.data.userList, streamList: this.data.streamList })
          console.log(TAG_NAME, 'exitRoom success', this.data.pusher, this.data.streamList, this.data.userList)
        })
      })
    },
    /**
     * 开启摄像头
     * @returns {Promise}
     */
    publishLocalVideo: function() {
      // 设置 pusher enableCamera
      console.log(TAG_NAME, 'publishLocalVideo 开启摄像头')
      return this._setPusherConfig({ enableCamera: true })
    },
    /**
     * 关闭摄像头
     * @returns {Promise}
     */
    unpublishLocalVideo: function() {
      // 设置 pusher enableCamera
      console.log(TAG_NAME, 'unpublshLocalVideo 关闭摄像头')
      return this._setPusherConfig({ enableCamera: false })
    },
    /**
     * 开启麦克风
     * @returns {Promise}
     */
    publishLocalAudio: function() {
      // 设置 pusher enableCamera
      console.log(TAG_NAME, 'publishLocalAudio 开启麦克风')
      return this._setPusherConfig({ enableMic: true })
    },
    /**
     * 关闭麦克风
     * @returns {Promise}
     */
    unpublishLocalAudio: function() {
      // 设置 pusher enableCamera
      console.log(TAG_NAME, 'unpublshLocalAudio 关闭麦克风')
      return this._setPusherConfig({ enableMic: false })
    },
    /**
     * 订阅远端视频 主流 小画面 辅流
     * @param {Object} params {userID,streamType} streamType 传入 small 时修改对应的主流url的 streamtype 参数为small
     * @returns {Promise}
     */
    subscribeRemoteVideo(params) {
      console.log(TAG_NAME, 'subscribeRemoteVideo', params)
      // 设置指定 user streamType 的 muteVideo 为 false
      const config = {
        muteVideo: false,
      }
      // 本地数据结构里的 streamType 只支持 main 和 aux ，订阅small 也是对main进行处理
      const streamType = params.streamType === 'small' ? 'main' : params.streamType
      if (params.streamType === 'small' || params.streamType === 'main') {
        const stream = this.userController.getStream({
          userID: params.userID,
          streamType: streamType,
        })
        if (stream && stream.streamType === 'main') {
          console.log(TAG_NAME, 'subscribeRemoteVideo switch small', stream.src)
          if (params.streamType === 'small') {
            config.src = stream.src.replace('main', 'small')
            config._definitionType = 'small' // 用于设置面板的渲染
          } else if (params.streamType === 'main') {
            stream.src = stream.src.replace('small', 'main')
            config._definitionType = 'main'
          }
          console.log(TAG_NAME, 'subscribeRemoteVideo', stream.src)
        }
      }
      return this._setPlayerConfig({
        userID: params.userID,
        streamType: streamType,
        config: config,
      })
    },
    /**
     * 取消订阅远端视频
     * @param {Object} params {userID,streamType}
     * @returns {Promise}
     */
    unsubscribeRemoteVideo(params) {
      console.log(TAG_NAME, 'unsubscribeRemoteVideo', params)
      // 设置指定 user streamType 的 muteVideo 为 true
      return this._setPlayerConfig({
        userID: params.userID,
        streamType: params.streamType,
        config: {
          muteVideo: true,
        },
      })
    },
    /**
     * 订阅远端音频
     * @param {Object} params userID 用户ID
     * @returns {Promise}
     */
    subscribeRemoteAudio(params) {
      console.log(TAG_NAME, 'subscribeRemoteAudio', params)
      return this._setPlayerConfig({
        userID: params.userID,
        streamType: 'main',
        config: {
          muteAudio: false,
        },
      })
    },
    /**
     * 取消订阅远端音频
     * @param {Object} params userID 用户ID
     * @returns {Promise}
     */
    unsubscribeRemoteAudio(params) {
      console.log(TAG_NAME, 'unsubscribeRemoteAudio', params)
      return this._setPlayerConfig({
        userID: params.userID,
        streamType: 'main',
        config: {
          muteAudio: true,
        },
      })
    },
    on: function(eventCode, handler, context) {
      this._emitter.on(eventCode, handler, context)
    },
    off: function(eventCode, handler) {
      this._emitter.off(eventCode, handler)
    },
    getRemoteUserList: function() {
      return this.data.userList
    },
    /**
     * 切换前后摄像头
     */
    switchCamera: function() {
      if (!this.data.cameraPosition) {
        // this.data.pusher.cameraPosition 是初始值，不支持动态设置
        this.data.cameraPosition = this.data.pusher.frontCamera
      }
      console.log(TAG_NAME, 'switchCamera', this.data.cameraPosition)
      this.data.cameraPosition = this.data.cameraPosition === 'front' ? 'back' : 'front'
      this.setData({
        cameraPosition: this.data.cameraPosition,
      }, () => {
        console.log(TAG_NAME, 'switchCamera success', this.data.cameraPosition)
      })
      // wx 7.0.9 不支持动态设置 pusher.devicePosition ，需要调用api设置，这里修改cameraPosition是为了记录状态
      this.data.pusher.getPusherContext().switchCamera()
    },
    /**
     * 设置指定player view的渲染坐标和尺寸
     * @param {object} params
     * userID: string
     * streamType: string
     * xAxis: number
     * yAxis: number
     * width: number
     * height: number
     * @returns {Promise}
     */
    setViewRect: function(params) {
      console.log(TAG_NAME, 'setViewRect', params)
      if (this.data.pusher.template !== 'custom') {
        console.warn(`如需使用setViewRect方法，请设置template:"custom", 当前 template:"${this.data.pusher.template}"`)
      }
      if (this.data.pusher.userID === params.userID) {
        return this._setPusherConfig({
          xAxis: params.xAxis,
          yAxis: params.yAxis,
          width: params.width,
          height: params.height,
        })
      }
      return this._setPlayerConfig({
        userID: params.userID,
        streamType: params.streamType,
        config: {
          xAxis: params.xAxis,
          yAxis: params.yAxis,
          width: params.width,
          height: params.height,
        },
      })
    },
    /**
     * 设置指定 player 或者 pusher view 是否可见
     * @param {object} params
     * userID: string
     * streamType: string
     * isVisible：boolean
     * @returns {Promise}
     */
    setViewVisible: function(params) {
      console.log(TAG_NAME, 'setViewVisible', params)
      // if (this.data.pusher.template !== 'custom') {
      //   console.warn(`如需使用setViewVisible方法，请设置template:"custom", 当前 template:"${this.data.pusher.template}"`)
      // }
      if (this.data.pusher.userID === params.userID) {
        return this._setPusherConfig({
          isVisible: params.isVisible,
        })
      }
      return this._setPlayerConfig({
        userID: params.userID,
        streamType: params.streamType,
        config: {
          isVisible: params.isVisible,
        },
      })
    },
    /**
     * 设置指定player view的层级
     * @param {Object} params
     * userID: string
     * streamType: string
     * zindex: number
     * @returns {Promise}
     */
    setViewZIndex: function(params) {
      console.log(TAG_NAME, 'setViewZIndex', params)
      if (this.data.pusher.template !== 'custom') {
        console.warn(`如需使用setViewZIndex方法，请设置template:"custom", 当前 template:"${this.data.pusher.template}"`)
      }
      if (this.data.pusher.userID === params.userID) {
        return this._setPusherConfig({
          zindex: params.zindex,
        })
      }
      return this._setPlayerConfig({
        userID: params.userID,
        streamType: params.streamType,
        config: {
          zindex: params.zindex,
        },
      })
    },
    /**
     * 播放背景音
     * @param {Object} params url
     * @returns {Promise}
     */
    playBGM: function(params) {
      return new Promise((resolve, reject) => {
        this.data.pusher.getPusherContext().playBGM({
          url: params.url,
          // 已经有相关事件不需要在这里监听,目前用于测试
          success: () => {
            console.log(TAG_NAME, '播放背景音成功')
            // this._emitter.emit(EVENT.BGM_PLAY_START)
            resolve()
          },
          fail: () => {
            console.log(TAG_NAME, '播放背景音失败')
            this._emitter.emit(EVENT.BGM_PLAY_FAIL)
            reject(new Error('播放背景音失败'))
          },
          // complete: () => {
          //   console.log(TAG_NAME, '背景完成')
          //   this._emitter.emit(EVENT.BGM_PLAY_COMPLETE)
          // },
        })
      })
    },
    stopBGM: function() {
      this.data.pusher.getPusherContext().stopBGM()
    },
    pauseBGM: function() {
      this.data.pusher.getPusherContext().pauseBGM()
    },
    resumeBGM: function() {
      this.data.pusher.getPusherContext().resumeBGM()
    },
    /**
     * 设置背景音音量
     * @param {Object} params volume
     */
    setBGMVolume: function(params) {
      this.data.pusher.getPusherContext().setBGMVolume({ volume: params.volume })
    },
    /**
     * 设置麦克风音量
     * @param {Object} params volume
     */
    setMICVolume: function(params) {
      this.data.pusher.getPusherContext().setMICVolume({ volume: params.volume })
    },
    /**
     * 发送SEI消息
     * @param {Object} params message
     * @returns {Promise}
     */
    sendSEI: function(params) {
      return new Promise((resolve, reject) => {
        this.data.pusher.getPusherContext().sendMessage({
          msg: params.message,
          success: function(result) {
            resolve(result)
          },
        })
      })
    },
    /**
     * pusher 和 player 的截图并保存
     * @param {Object} params userID streamType
     * @returns {Promise}
     */
    snapshot: function(params) {
      console.log(TAG_NAME, 'snapshot', params)
      return new Promise((resolve, reject) => {
        this.captureSnapshot(params).then((result)=>{
          wx.saveImageToPhotosAlbum({
            filePath: result.tempImagePath,
            success(res) {
              wx.showToast({
                title: '已保存到相册',
              })
              console.log('save photo is success', res)
              resolve(result)
            },
            fail: function(error) {
              wx.showToast({
                icon: 'none',
                title: '保存失败',
              })
              console.log('save photo is fail', error)
              reject(error)
            },
          })
        }).catch((error)=>{
          reject(error)
        })
      })
    },
    /**
     * 获取pusher 和 player 的截图
     * @param {Object} params userID streamType
     * @returns {Promise}
     */
    captureSnapshot: function(params) {
      return new Promise((resolve, reject) => {
        if (params.userID === this.data.pusher.userID) {
        // pusher
          this.data.pusher.getPusherContext().snapshot({
            quality: 'raw',
            complete: (result) => {
              console.log(TAG_NAME, 'snapshot pusher', result)
              if (result.tempImagePath) {
                resolve(result)
              } else {
                console.log('snapShot 回调失败', result)
                reject(new Error('截图失败'))
              }
            },
          })
        } else {
        // player
          this.userController.getStream(params).playerContext.snapshot({
            quality: 'raw',
            complete: (result) => {
              console.log(TAG_NAME, 'snapshot player', result)
              if (result.tempImagePath) {
                resolve(result)
              } else {
                console.log('snapShot 回调失败', result)
                reject(new Error('截图失败'))
              }
            },
          })
        }
      })
    },
    /**
     * 将远端视频全屏
     * @param {Object} params userID streamType direction
     * @returns {Promise}
     */
    enterFullscreen: function(params) {
      console.log(TAG_NAME, 'enterFullscreen', params)
      return new Promise((resolve, reject) => {
        this.userController.getStream(params).playerContext.requestFullScreen({
          direction: params.direction || 0,
          success: (event) => {
            console.log(TAG_NAME, 'enterFullscreen success', event)
            resolve(event)
          },
          fail: (event) => {
            console.log(TAG_NAME, 'enterFullscreen fail', event)
            reject(event)
          },
        })
      })
    },
    /**
     * 将远端视频取消全屏
     * @param {Object} params userID streamType
     * @returns {Promise}
     */
    exitFullscreen: function(params) {
      console.log(TAG_NAME, 'exitFullscreen', params)
      return new Promise((resolve, reject) => {
        this.userController.getStream(params).playerContext.exitFullScreen({
          success: (event) => {
            console.log(TAG_NAME, 'exitFullScreen success', event)
            resolve(event)
          },
          fail: (event) => {
            console.log(TAG_NAME, 'exitFullScreen fail', event)
            reject(event)
          },
        })
      })
    },
    /**
     * 设置 player 视图的横竖屏显示
     * @param {Object} params userID streamType orientation: vertical, horizontal
     * @returns {Promise}
     */
    setRemoteOrientation: function(params) {
      return this._setPlayerConfig({
        userID: params.userID,
        streamType: params.streamType,
        config: {
          orientation: params.orientation,
        },
      })
    },
    // 改为：
    setViewOrientation: function(params) {
      return this._setPlayerConfig({
        userID: params.userID,
        streamType: params.streamType,
        config: {
          orientation: params.orientation,
        },
      })
    },
    /**
     * 设置 player 视图的填充模式
     * @param {Object} params userID streamType fillMode: contain，fillCrop
     * @returns {Promise}
     */
    setRemoteFillMode: function(params) {
      return this._setPlayerConfig({
        userID: params.userID,
        streamType: params.streamType,
        config: {
          objectFit: params.fillMode,
        },
      })
    },
    // 改为：
    setViewFillMode: function(params) {
      return this._setPlayerConfig({
        userID: params.userID,
        streamType: params.streamType,
        config: {
          objectFit: params.fillMode,
        },
      })
    },
    /**
     * 切换 player 大小画面
     * @param {Object} params userID streamType definition: HD SD
     * @returns {Promise}
     */
    _setRemoteDefinition: function(params) {
      params.streamType = 'main'
      return new Promise((resolve, reject) => {
        const stream = this.userController.getStream({
          userID: params.userID,
          streamType: params.streamType,
        })
        if (stream && stream.streamType === 'main') {
          console.log(TAG_NAME, '_switchStreamType', stream.src)
          // stream.volume = volume
          if (stream.src.indexOf('main') > -1) {
            stream.src = stream.src.replace('main', 'small')
            stream._streamType = 'small' // 用于设置面板的渲染
          } else if (stream.src.indexOf('small') > -1) {
            stream.src = stream.src.replace('small', 'main')
            stream._streamType = 'main'
          }
          console.log(TAG_NAME, '_switchStreamType', stream.src)
          this.setData({
            streamList: this.data.streamList,
          }, () => {
          })
        }
      })
    },
    _initStatus() {
      this.status = {
        isPush: false, // 推流状态
        isPending: false, // 挂起状态，触发5000事件标记为true，onShow后标记为false
      }
      this._lastTapTime = 0
      this._beforeLastTapTime = 0
      this._isFullscreen = false
    },
    /**
     * 设置推流参数并触发页面渲染更新
     * @param {Object} config live-pusher 的配置
     * @returns {Promise}
     */
    _setPusherConfig(config) {
      console.log(TAG_NAME, '_setPusherConfig', config, this.data.pusher)
      return new Promise((resolve, reject) => {
        if (!this.data.pusher) {
          this.data.pusher = new Pusher(config)
        } else {
          Object.assign(this.data.pusher, config)
        }
        this.setData({
          pusher: this.data.pusher,
        }, () => {
          // console.log(TAG_NAME, '_setPusherConfig setData compelete', 'config:', config, 'pusher:', this.data.pusher)
          resolve(config)
        })
      })
    },
    /**
     *
     * @param {Object} params include userID,streamType,config
     * @returns {Promise}
     */
    _setPlayerConfig(params) {
      const userID = params.userID
      const streamType = params.streamType
      const config = params.config
      console.log(TAG_NAME, '_setPlayerConfig', params)
      return new Promise((resolve, reject) => {
        // 获取指定的userID streamType 的 stream
        const user = this.userController.getUser(userID)
        if (user && user.streams[streamType]) {
          user.streams[streamType] = Object.assign(user.streams[streamType], config)
          // user.streams引用的对象和 streamList 里的是同一个
          this.setData({
            streamList: this.data.streamList,
          }, () => {
            // console.log(TAG_NAME, '_setPlayerConfig complete', params, 'streamList:', this.data.streamList)
            resolve(params)
          })
        } else {
          // 不需要reject，静默处理
          console.warn(TAG_NAME, '指定 userID 或者 streamType 不存在')
          // reject(new Error('指定 userID 或者 streamType 不存在'))
        }
      })
    },
    /**
     * 必选参数检测
     * @param {Object} rtcConfig rtc参数
     * @returns {Boolean}
     */
    _checkParam: function(rtcConfig) {
      console.log(TAG_NAME, 'checkParam config:', rtcConfig)
      if (!rtcConfig.sdkAppID) {
        console.error('未设置 sdkAppID')
        return false
      }
      if (rtcConfig.roomID === undefined) {
        console.error('未设置 roomID')
        return false
      }
      if (rtcConfig.roomID < 1 || rtcConfig.roomID > 4294967296) {
        console.error('roomID 超出取值范围 1 ~ 4294967295')
        return false
      }
      if (!rtcConfig.userID) {
        console.error('未设置 userID')
        return false
      }
      if (!rtcConfig.userSig) {
        console.error('未设置 userSig')
        return false
      }
      if (!rtcConfig.template) {
        console.error('未设置 template')
        return false
      }
      return true
    },
    _getPushUrl: function(rtcConfig) {
      // 拼接 puhser url rtmp 方案
      console.log(TAG_NAME, 'getPushUrl', rtcConfig)
      if (ENV.IS_TRTC) {
        // 版本高于7.0.8，基础库版本高于2.10.0 使用新的 url
        return new Promise((resolve, reject) => {
          // appscene videocall live
          // cloudenv PRO CCC DEV UAT
          // encsmall 0
          // 对外的默认值是rtc ，对内的默认值是videocall
          rtcConfig.scene = !rtcConfig.scene || rtcConfig.scene === 'rtc' ? 'videocall' : 'live'
          rtcConfig.enableBlackStream = rtcConfig.enableBlackStream || 1
          rtcConfig.encsmall = rtcConfig.encsmall || 0
          rtcConfig.cloudenv = rtcConfig.cloudenv || 'PRO'
          setTimeout(()=> {
            const pushUrl = 'room://cloud.tencent.com/rtc?sdkappid=' + rtcConfig.sdkAppID +
                            '&roomid=' + rtcConfig.roomID +
                            '&userid=' + rtcConfig.userID +
                            '&usersig=' + rtcConfig.userSig +
                            '&appscene=' + rtcConfig.scene +
                            '&encsmall=' + rtcConfig.encsmall +
                            '&cloudenv=' + rtcConfig.cloudenv
            console.log(TAG_NAME, 'getPushUrl result:', pushUrl)
            resolve(pushUrl)
          }, 0)
        })
      }
      return this._requestSigServer(rtcConfig)
    },
    /**
     * 获取签名和推流地址
     * @param {Object} rtcConfig 进房参数配置
     * @returns {Promise}
     */
    _requestSigServer: function(rtcConfig) {
      console.log('requestSigServer:', rtcConfig)
      const sdkAppID = rtcConfig.sdkAppID
      const userID = rtcConfig.userID
      const userSig = rtcConfig.userSig
      const roomID = rtcConfig.roomID
      const privateMapKey = rtcConfig.privateMapKey

      rtcConfig.useCloud = rtcConfig.useCloud === undefined ? true : rtcConfig.useCloud
      let url = rtcConfig.useCloud ? 'https://official.opensso.tencent-cloud.com/v4/openim/jsonvideoapp' : 'https://yun.tim.qq.com/v4/openim/jsonvideoapp'
      url += '?sdkappid=' + sdkAppID + '&identifier=' + userID + '&usersig=' + userSig + '&random=' + Date.now() + '&contenttype=json'

      const reqHead = {
        'Cmd': 1,
        'SeqNo': 1,
        'BusType': 7,
        'GroupId': roomID,
      }
      const reqBody = {
        'PrivMapEncrypt': privateMapKey,
        'TerminalType': 1,
        'FromType': 3,
        'SdkVersion': 26280566,
      }
      console.log('requestSigServer:', url, reqHead, reqBody)
      return new Promise((resolve, reject) => {
        wx.request({
          url: url,
          data: {
            'ReqHead': reqHead,
            'ReqBody': reqBody,
          },
          method: 'POST',
          success: (res) => {
            console.log('requestSigServer success:', res)
            if (res.data['ErrorCode'] || res.data['RspHead']['ErrorCode'] !== 0) {
              // console.error(res.data['ErrorInfo'] || res.data['RspHead']['ErrorInfo'])
              console.error('获取roomsig失败')
              reject(res)
            }

            const roomSig = JSON.stringify(res.data['RspBody'])
            let pushUrl = 'room://cloud.tencent.com?sdkappid=' + sdkAppID + '&roomid=' + roomID + '&userid=' + userID + '&roomsig=' + encodeURIComponent(roomSig)
            // TODO 需要重新整理的逻辑
            // 如果有配置纯音频推流或者recordId参数
            if (rtcConfig.pureAudioPushMod || rtcConfig.recordId) {
              const bizbuf = {
                Str_uc_params: {
                  pure_audio_push_mod: 0,
                  record_id: 0,
                },
              }
              // 纯音频推流
              if (rtcConfig.pureAudioPushMod) {
                bizbuf.Str_uc_params.pure_audio_push_mod = rtcConfig.pureAudioPushMod
              } else {
                delete bizbuf.Str_uc_params.pure_audio_push_mod
              }
              // 自动录制时业务自定义id
              if (rtcConfig.recordId) {
                bizbuf.Str_uc_params.record_id = rtcConfig.recordId
              } else {
                delete bizbuf.Str_uc_params.record_id
              }
              pushUrl += '&bizbuf=' + encodeURIComponent(JSON.stringify(bizbuf))
            }
            console.log('roomSigInfo', pushUrl)
            resolve(pushUrl)
          },
          fail: (res) => {
            console.log('requestSigServer fail:', res)
            reject(res)
          },
        })
      })
    },
    _doubleTabToggleFullscreen: function(event) {
      const curTime = event.timeStamp
      const lastTime = this._lastTapTime
      // 已知问题：上次全屏操作后，必须等待1.5s后才能再次进行全屏操作，否则引发SDK全屏异常，因此增加节流逻辑
      const beforeLastTime = this._beforeLastTapTime
      console.log(TAG_NAME, '_doubleTabToggleFullscreen', event, lastTime, beforeLastTime)
      if (curTime - lastTime > 0 && curTime - lastTime < 300 && lastTime - beforeLastTime > 1500 ) {
        const userID = event.currentTarget.dataset.userid
        const streamType = event.currentTarget.dataset.streamtype
        if (this._isFullscreen) {
          this.exitFullscreen({ userID, streamType }).then(() => {
            this._isFullscreen = false
          }).catch(() => {
          })
        } else {
          // const stream = this.userController.getStream({ userID, streamType })
          let direction
          // // 已知问题：视频的尺寸需要等待player触发NetStatus事件才能获取到，如果进房就双击全屏，全屏后的方向有可能不对。
          // if (stream && stream.videoWidth && stream.videoHeight) {
          //   // 如果是横视频，全屏时进行横屏处理。如果是竖视频，则为0
          //   direction = stream.videoWidth > stream.videoHeight ? 90 : 0
          // }
          this.enterFullscreen({ userID, streamType, direction }).then(() => {
            this._isFullscreen = true
          }).catch(() => {
          })
        }
        this._beforeLastTapTime = lastTime
      }
      this._lastTapTime = curTime
    },
    /**
     * TRTC-room 远端用户和音视频状态处理
     */
    _bindEvent: function() {
      // 远端用户进房
      this.userController.on(EVENT.REMOTE_USER_JOIN, (event)=>{
        console.log(TAG_NAME, '远端用户进房', event, event.data.userID)
        this.setData({
          userList: event.data.userList,
        }, () => {
          this._emitter.emit(EVENT.REMOTE_USER_JOIN, { userID: event.data.userID })
        })
        console.log(TAG_NAME, 'REMOTE_USER_JOIN', 'streamList:', this.data.streamList, 'userList:', this.data.userList)
      })
      // 远端用户离开
      this.userController.on(EVENT.REMOTE_USER_LEAVE, (event)=>{
        console.log(TAG_NAME, '远端用户离开', event, event.data.userID)
        if (event.data.userID) {
          this.setData({
            userList: event.data.userList,
            streamList: event.data.streamList,
          }, () => {
            this._emitter.emit(EVENT.REMOTE_USER_LEAVE, { userID: event.data.userID })
          })
        }
        console.log(TAG_NAME, 'REMOTE_USER_LEAVE', 'streamList:', this.data.streamList, 'userList:', this.data.userList)
      })
      // 视频状态 true
      this.userController.on(EVENT.REMOTE_VIDEO_ADD, (event)=>{
        console.log(TAG_NAME, '远端视频可用', event, event.data.stream.userID)
        const stream = event.data.stream
        this.setData({
          userList: event.data.userList,
          streamList: event.data.streamList,
        }, () => {
          // 完善 的stream 的 playerContext
          stream.playerContext = wx.createLivePlayerContext(stream.streamID, this)
          // 新增的需要触发一次play 默认属性才能生效
          // stream.playerContext.play()
          // console.log(TAG_NAME, 'REMOTE_VIDEO_ADD playerContext.play()', stream)
          // TODO 视频通话模版默认订阅且显示
          this._emitter.emit(EVENT.REMOTE_VIDEO_ADD, { userID: stream.userID, streamType: stream.streamType })
        })
        console.log(TAG_NAME, 'REMOTE_VIDEO_ADD', 'streamList:', this.data.streamList, 'userList:', this.data.userList)
      })
      // 视频状态 false
      this.userController.on(EVENT.REMOTE_VIDEO_REMOVE, (event)=>{
        console.log(TAG_NAME, '远端视频移除', event, event.data.stream.userID)
        const stream = event.data.stream
        this.setData({
          userList: event.data.userList,
          streamList: event.data.streamList,
        }, () => {
          // 有可能先触发了退房事件，用户名下的所有stream都已清除
          if (stream.userID && stream.streamType) {
            this._emitter.emit(EVENT.REMOTE_VIDEO_REMOVE, { userID: stream.userID, streamType: stream.streamType })
          }
        })
        console.log(TAG_NAME, 'REMOTE_VIDEO_REMOVE', 'streamList:', this.data.streamList, 'userList:', this.data.userList)
      })
      // 音频可用
      this.userController.on(EVENT.REMOTE_AUDIO_ADD, (event)=>{
        console.log(TAG_NAME, '远端音频可用', event)
        const stream = event.data.stream
        this.setData({
          userList: event.data.userList,
          streamList: event.data.streamList,
        }, () => {
          stream.playerContext = wx.createLivePlayerContext(stream.streamID, this)
          // 新增的需要触发一次play 默认属性才能生效
          // stream.playerContext.play()
          // console.log(TAG_NAME, 'REMOTE_AUDIO_ADD playerContext.play()', stream)
          this._emitter.emit(EVENT.REMOTE_AUDIO_ADD, { userID: stream.userID, streamType: stream.streamType })
        })
        console.log(TAG_NAME, 'REMOTE_AUDIO_ADD', 'streamList:', this.data.streamList, 'userList:', this.data.userList)
      })
      // 音频不可用
      this.userController.on(EVENT.REMOTE_AUDIO_REMOVE, (event)=>{
        console.log(TAG_NAME, '远端音频移除', event, event.data.stream.userID)
        const stream = event.data.stream
        this.setData({
          userList: event.data.userList,
          streamList: event.data.streamList,
        }, () => {
          // 有可能先触发了退房事件，用户名下的所有stream都已清除
          if (stream.userID && stream.streamType) {
            this._emitter.emit(EVENT.REMOTE_AUDIO_REMOVE, { userID: stream.userID, streamType: stream.streamType })
          }
        })
        console.log(TAG_NAME, 'REMOTE_AUDIO_REMOVE', 'streamList:', this.data.streamList, 'userList:', this.data.userList)
      })
    },
    /**
     * pusher event handler
     * @param {*} event 事件实例
     */
    _pusherStateChangeHandler: function(event) {
      const code = event.detail.code
      const message = event.detail.message
      console.log(TAG_NAME, 'pusherStateChange：', code, event)
      switch (code) {
        case 0:
          console.log(message, code)
          break
        case 1001:
          console.log('已经连接推流服务器', code)
          break
        case 1002:
          console.log('已经与服务器握手完毕,开始推流', code)
          break
        case 1003:
          console.log('打开摄像头成功', code)
          break
        case 1004:
          console.log('录屏启动成功', code)
          break
        case 1005:
          console.log('推流动态调整分辨率', code)
          break
        case 1006:
          console.log('推流动态调整码率', code)
          break
        case 1007:
          console.log('首帧画面采集完成', code)
          break
        case 1008:
          console.log('编码器启动', code)
          break
        case 1018:
          console.log('进房成功', code)
          this._emitter.emit(EVENT.LOCAL_JOIN, { userID: this.data.pusher.userID })
          break
        case 1019:
          console.log('退出房间', code)
          this._emitter.emit(EVENT.LOCAL_LEAVE, { userID: this.data.pusher.userID })
          break
        case 2003:
          console.log('渲染首帧视频', code)
          break
        case 1020:
        case 1031:
        case 1032:
        case 1033:
        case 1034:
          // 通过 userController 处理 1020 1031 1032 1033 1034
          this.userController.userEventHandler(event)
          break
        case -1301:
          console.error('打开摄像头失败: ', code)
          this._emitter.emit(EVENT.ERROR, { code, message })
          break
        case -1302:
          console.error('打开麦克风失败: ', code)
          this._emitter.emit(EVENT.ERROR, { code, message })
          break
        case -1303:
          console.error('视频编码失败: ', code)
          this._emitter.emit(EVENT.ERROR, { code, message })
          break
        case -1304:
          console.error('音频编码失败: ', code)
          this._emitter.emit(EVENT.ERROR, { code, message })
          break
        case -1307:
          console.error('推流连接断开: ', code)
          this._emitter.emit(EVENT.ERROR, { code, message })
          break
        case -100018:
          console.error('进房失败: ', code, message)
          this._emitter.emit(EVENT.ERROR, { code, message })
          break
        case 5000:
          console.log('小程序被挂起: ', code)
          // 终端 sdk 建议执行退房操作，唤起时重新进房，临时解决方案，待小程序SDK完全实现自动重新推流后可以去掉
          this.status.isPending = true
          if (this.status.isPush) {
            // this.exitRoom()
            const tempUrl = this.data.pusher.url
            this.data.pusher.url = ''
            // console.log('5000 小程序被挂起后更换pusher', this.data.pusher.getPusherContext().webviewId)
            this.setData({
              pusher: this.data.pusher,
            }, () => {
              this.data.pusher.url = tempUrl
              this.setData({
                pusher: this.data.pusher,
              }, () => {
                this.data.pusher.getPusherContext().start()
                console.log('5000 小程序被挂起后更换pusher', this.data.pusher)
              })
            })
          }
          break
        case 1021:
          console.log('网络类型发生变化，需要重新进房', code)
          break
        case 2007:
          console.log('本地视频播放loading: ', code)
          break
        case 2004:
          console.log('本地视频播放开始: ', code)
          break
        default:
          console.log(message, code)
      }

      this._emitter.emit(EVENT.LOCAL_STATE_UPDATE, { data: event })
    },
    _pusherNetStatusHandler: function(event) {
      // 触发 LOCAL_NET_STATE_UPDATE
      this._emitter.emit(EVENT.LOCAL_NET_STATE_UPDATE, event)
    },
    _pusherErrorHandler: function(event) {
      // 触发 ERROR
      console.warn(TAG_NAME, 'pusher error', event)
      try {
        const code = event.detail.errCode
        const message = event.detail.errMsg
        this._emitter.emit(EVENT.ERROR, { code, message })
      } catch (exception) {
        console.error(TAG_NAME, 'pusher error data parser exception', event, exception)
      }
    },
    _pusherBGMStartHandler: function(event) {
      // 触发 BGM_START 已经在playBGM方法中进行处理
      // this._emitter.emit(EVENT.BGM_PLAY_START, { data: event })
    },
    _pusherBGMProgressHandler: function(event) {
      // BGM_PROGRESS
      this._emitter.emit(EVENT.BGM_PLAY_PROGRESS, event)
    },
    _pusherBGMCompleteHandler: function(event) {
      // BGM_COMPLETE
      this._emitter.emit(EVENT.BGM_PLAY_COMPLETE, event)
    },
    // player event handler
    // 获取 player ID 再进行触发
    _playerStateChange: function(event) {
      // console.log(TAG_NAME, '_playerStateChange', event)
      this._emitter.emit(EVENT.REMOTE_STATE_UPDATE, event)
    },
    _playerFullscreenChange: function(event) {
      // console.log(TAG_NAME, '_playerFullscreenChange', event)
      this._emitter.emit(EVENT.REMOTE_NET_STATE_UPDATE, event)
    },
    _playerNetStatus: function(event) {
      // console.log(TAG_NAME, '_playerNetStatus', event)
      // 获取player 视频的宽高
      const stream = this.userController.getStream({
        userID: event.currentTarget.dataset.userid,
        streamType: event.currentTarget.dataset.streamtype,
      })
      if (stream && (stream.videoWidth !== event.detail.info.videoWidth || stream.videoHeight !== event.detail.info.videoHeight)) {
        console.log(TAG_NAME, '_playerNetStatus update video size', event)
        stream.videoWidth = event.detail.info.videoWidth
        stream.videoHeight = event.detail.info.videoHeight
      }
      this._emitter.emit(EVENT.REMOTE_FULLSCREEN_UPDATE, event)
    },
    _playerAudioVolumeNotify: function(event) {
      // console.log(TAG_NAME, '_playerAudioVolumeNotify', event)
      this._emitter.emit(EVENT.REMOTE_AUDIO_VOLUME_UPDATE, event)
    },
    /**
     * 监听组件属性变更，外部变更组件属性时触发该监听，用于检查属性设置是否正常
     * @param {Object} data 变更数据
     */
    _propertyObserver: function(data) {
      console.log(TAG_NAME, '_propertyObserver', data, this.data.config)
      if (data.name === 'config') {
        // const config = Object.assign(DEFAULT_PUSHER_CONFIG, data.newVal)
        const config = data.newVal
        // querystring 只支持String类型，做一个类型防御
        if (typeof config.debugMode === 'string') {
          config.debugMode === 'true' ? true : false
        }
        // 独立设置与pusher无关的配置
        this.setData({
          template: config.template,
          debugMode: config.debugMode || false,
          debug: config.debugMode || false,
        })
        this._setPusherConfig(config)
      }
    },
    _toggleVideo() {
      if (this.data.pusher.enableCamera) {
        this.unpublishLocalVideo()
      } else {
        this.publishLocalVideo()
      }
    },
    _toggleAudio() {
      if (this.data.pusher.enableMic) {
        this.unpublishLocalAudio()
      } else {
        this.publishLocalAudio()
      }
    },
    _debugToggleRemoteVideo(event) {
      console.log(TAG_NAME, '_debugToggleRemoteVideo', event.currentTarget.dataset)
      const userID = event.currentTarget.dataset.userID
      const streamType = event.currentTarget.dataset.streamType
      const stream = this.data.streamList.find((item)=>{
        return item.userID === userID && item.streamType === streamType
      })
      if (stream.muteVideo) {
        this.subscribeRemoteVideo({ userID, streamType })
        this.setViewVisible({ userID, streamType, isVisible: true })
      } else {
        this.unsubscribeRemoteVideo({ userID, streamType })
        this.setViewVisible({ userID, streamType, isVisible: false })
      }
    },
    _debugToggleRemoteAudio(event) {
      console.log(TAG_NAME, '_debugToggleRemoteAudio', event.currentTarget.dataset)
      const userID = event.currentTarget.dataset.userID
      const streamType = event.currentTarget.dataset.streamType
      const stream = this.data.streamList.find((item)=>{
        return item.userID === userID && item.streamType === streamType
      })
      if (stream.muteAudio) {
        this.subscribeRemoteAudio({ userID })
      } else {
        this.unsubscribeRemoteAudio({ userID })
      }
    },
    _debugToggleVideoDebug() {
      this.setData({
        debug: !this.data.debug,
      })
    },
    _debugExitRoom() {
      this.exitRoom()
    },
    _debugEnterRoom() {
      this.publishLocalVideo()
      this.publishLocalAudio()
      this.enterRoom({ roomID: this.data.config.roomID }).then(()=>{
        // 进房后开始推送视频或音频
      })
    },
    _debugGoBack() {
      wx.navigateBack({
        delta: 1,
      })
    },
    _debugTogglePanel() {
      this.setData({
        debugPanel: !this.data.debugPanel,
      })
    },
    _toggleAudioVolumeType() {
      if (this.data.pusher.audioVolumeType === 'voicecall') {
        this._setPusherConfig({
          audioVolumeType: 'media',
        })
      } else {
        this._setPusherConfig({
          audioVolumeType: 'voicecall',
        })
      }
    },
    _toggleSoundMode() {
      if (this.data.userList.length === 0 ) {
        return
      }
      const stream = this.userController.getStream({
        userID: this.data.userList[0].userID,
        streamType: 'main',
      })
      if (stream) {
        if (stream.soundMode === 'speaker') {
          stream['soundMode'] = 'ear'
        } else {
          stream['soundMode'] = 'speaker'
        }
        this._setPlayerConfig({
          userID: stream.userID,
          streamType: 'main',
          config: {
            soundMode: stream['soundMode'],
          },
        })
      }
    },
    /**
     * 退出通话
     */
    _hangUp: function() {
      this.exitRoom()
      wx.navigateBack({
        delta: 1,
      })
    },
    /**
     * 切换订阅音频状态
     */
    handleSubscribeAudio: function() {
      if (this.data.pusher.enableMic) {
        this.unpublishLocalAudio()
      } else {
        this.publishLocalAudio()
      }
    },
    /**
     * 切换订阅远端视频状态
     * @param event
     */
    _handleSubscribeRemoteVideo: function(event) {
      const userID = event.currentTarget.dataset.userID
      const streamType = event.currentTarget.dataset.streamType
      const stream = this.data.streamList.find((item)=>{
        return item.userID === userID && item.streamType === streamType
      })
      if (stream.muteVideo) {
        this.subscribeRemoteVideo({ userID, streamType })
      } else {
        this.unsubscribeRemoteVideo({ userID, streamType })
      }
    },
    /**
     * 将远端视频取消全屏
     * @param event
     */
    _handleSubscribeRemoteAudio: function(event) {
      const userID = event.currentTarget.dataset.userID
      const streamType = event.currentTarget.dataset.streamType
      const stream = this.data.streamList.find((item)=>{
        return item.userID === userID && item.streamType === streamType
      })
      if (stream.muteAudio) {
        this.subscribeRemoteAudio({ userID })
      } else {
        this.unsubscribeRemoteAudio({ userID })
      }
    },
    /**
     * grid布局, 唤起 memberlist-panel
     */
    _switchMemberListPanel() {
      this.setData({
        panelName: this.data.panelName !== 'memberlist-panel' ? 'memberlist-panel' : '',
      })
    },
    /**
     * grid布局, 唤起setting-panel
     */
    _switchSettingPanel() {
      this.setData({
        panelName: this.data.panelName !== 'setting-panel' ? 'setting-panel' : '',
      })
    },
    _handleMaskerClick() {
      this.setData({
        panelName: '',
      })
    },

    _setPuserProperty(event) {
      // console.log(TAG_NAME, '_setPuserProperty', event)
      const key = event.currentTarget.dataset.key
      let value = event.currentTarget.dataset.value
      const config = {}
      if (value === 'true') {
        value = true
      } else if (value === 'false') {
        value = false
      }
      if (typeof value === 'boolean') {
        config[key] = !this.data.pusher[key]
      } else if (typeof value === 'string' && value.indexOf('|') > 0) {
        value = value.split('|')
        if ( this.data.pusher[key] === value[0]) {
          config[key] = value[1]
        } else {
          config[key] = value[0]
        }
      }
      // console.log(TAG_NAME, '_setPuserProperty', config)
      this._setPusherConfig(config)
    },
    _setPlayerProperty(event) {
      console.log(TAG_NAME, '_setPlayerProperty', event)
      const userID = event.currentTarget.dataset.userid
      const streamType = event.currentTarget.dataset.streamtype
      const key = event.currentTarget.dataset.key
      let value = event.currentTarget.dataset.value
      const stream = this.userController.getStream({
        userID: userID,
        streamType: streamType,
      })
      if (!stream) {
        return
      }
      const config = {}
      if (value === 'true') {
        value = true
      } else if (value === 'false') {
        value = false
      }
      if (typeof value === 'boolean') {
        config[key] = !stream[key]
      } else if (typeof value === 'string' && value.indexOf('|') > 0) {
        value = value.split('|')
        if (stream[key] === value[0]) {
          config[key] = value[1]
        } else {
          config[key] = value[0]
        }
      }
      console.log(TAG_NAME, '_setPlayerProperty', config)
      this._setPlayerConfig({ userID, streamType, config })
    },
    _switchStreamType(event) {
      const userID = event.currentTarget.dataset.userid
      const streamType = event.currentTarget.dataset.streamtype
      const stream = this.userController.getStream({
        userID: userID,
        streamType: streamType,
      })
      if (stream && stream.streamType === 'main') {
        if (stream._definitionType === 'small') {
          this.subscribeRemoteVideo({ userID, streamType: 'main' })
        } else {
          this.subscribeRemoteVideo({ userID, streamType: 'small' })
        }
      }
    },
    _handleSnapshotClick(event) {
      wx.showToast({
        title: '开始截屏',
        icon: 'none',
        duration: 1000,
      })
      const userID = event.currentTarget.dataset.userid
      const streamType = event.currentTarget.dataset.streamtype
      this.snapshot({ userID, streamType })
    },
    /**
     * grid布局, 绑定事件
     */
    _bindEventGrid() {
      // 远端音量变更
      this.on(EVENT.REMOTE_AUDIO_VOLUME_UPDATE, (event) => {
        const data = event.data
        const userID = data.currentTarget.dataset.userid
        const streamType = data.currentTarget.dataset.streamtype
        const volume = data.detail.volume
        // console.log(TAG_NAME, '远端音量变更', userID, streamType, volume)
        const stream = this.userController.getStream({
          userID: userID,
          streamType: streamType,
        })
        if (stream) {
          stream.volume = volume
        }
        this.setData({
          streamList: this.data.streamList,
        }, () => {
        })
      })
    },
    _toggleFullscreen(event) {
      console.log(TAG_NAME, '_toggleFullscreen', event)
      const userID = event.currentTarget.dataset.userID
      const streamType = event.currentTarget.dataset.streamType
      if (this._isFullscreen) {
        this.exitFullscreen({ userID, streamType }).then(() => {
          this._isFullscreen = false
        }).catch(() => {
        })
      } else {
        // const stream = this.userController.getStream({ userID, streamType })
        const direction = 0
        // 已知问题：视频的尺寸需要等待player触发NetStatus事件才能获取到，如果进房就双击全屏，全屏后的方向有可能不对。
        // if (stream && stream.videoWidth && stream.videoHeight) {
        //   // 如果是横视频，全屏时进行横屏处理。如果是竖视频，则为0
        //   direction = stream.videoWidth > stream.videoHeight ? 90 : 0
        // }
        this.enterFullscreen({ userID, streamType, direction }).then(() => {
          this._isFullscreen = true
        }).catch(() => {
        })
      }
    },
  },
})
