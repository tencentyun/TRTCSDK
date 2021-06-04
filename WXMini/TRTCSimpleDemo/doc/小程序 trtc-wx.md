# trtc-wx 接口API文档

本文档包含 trtc-wx 模块 API 接口和所有事件说明，您通过查阅此文档能够获得更多 TRTC 的使用帮助，本文将在 API 概览部分中为您介绍 trtc-wx 提供的所有接口及其含义，在 API 使用指引的部分为您介绍，这些接口详细的使用方式，及注意事项，在更多高级特性中，会向您展示 trtc-wx 中是如何管理页面上的 live-pusher 和 live-player 实例的，最后，我们会为您介绍所有的事件通知，以及事件通知中的各种数据。

您可以根据业务场景，自主编写页面的元素布局，trtc-wx 则可以帮助您管理所有与实时音视频相关的状态，您也可以调用挂载在&lt;live-pusher&gt;和&lt;live-player&gt;上的方法，满足您业务场景所需。

![](https://web.sdk.qcloud.com/trtc/miniapp/doc/zh-cn/trtc-wx%E6%97%B6%E5%BA%8F%E5%9B%BE.png)

上图是一个简单的使用示例，您可以通过 trtc-wx 提供的 API 方法对您的推拉流状态进行设置，之后通过 setData 的方式，在微信页面上的原生标签上更新生效，您通过事件订阅的接口可以捕获服务端的一些状态通知，trtc-wx 也会在这些事件通知中，返回更新部分的状态，您可以及时的将这些属性更新到页面当中。
## API 概览

以下会为您介绍每个 API 的含义，基础方法是创建 TRTC 房间，使用 TRTC 服务的必用的 API，如果您需要主动改变推流的一些状态属性，您则需要调用 pusher 和 player 的属性变更的 API，如果您需要更多的功能，您也可以直接获取相关的实例，调用我们 SDK 开放的能力。

**基础方法**

您可以通过这些方法完成事件监听，并创建 TRTC 房间，获取远端的拉流信息等操作。

| API                   | 描述                 |
| :-------------------- | :------------------ |
| [on(EventCode, handler, context)](#on(eventcode.2C-handler.2C-context)) | 用于监听组件派发的事件，详细事件请参考 [事件表](#Event)。 |
| [off(EventCode, handler)](#off(eventcode.2C-handler)) | 取消事件监听。 |
| [createPusher(pusherAttributes)](#createPusher(pusherAttributes))   | 创建推流实例。     |
| [enterRoom(params)](#enterRoom(params)) | 进入房间，若房间不存在，系统将自动创建一个新房间。 |
| [exitRoom()](#exitroom()) | 停止推流和取消订阅所有远端音视频，并退出房间。   |
| [getPlayerList()](#getPlayerList())       | 获取当前远端 player 的列表。                                   |

**pusher && player 状态变更方法**

您可以通过这些 API 主动改变推拉流的状态。

| API                             | 描述             |
| :------------------------------ | :--------------- |
| [setPusherAttributes(config)](#setPusherAttributes(config))     | 设置推流参数变更 |
| [setPlayerAttributes(id, config)](#setPlayerAttributes(id.2C-config)) | 设置拉流参数变更 |

**获取实例**

获取相应的 pusher 和 player 的实例，可以调用更多的 SDK 开放能力。

| API                   | 描述                                                         |
| :-------------------- | :----------------------------------------------------------- |
| [getPusherInstance()](#getPusherInstance())   | 获取推流实例，可以调用 [pusherContext](https://developers.weixin.qq.com/miniprogram/dev/api/media/live/wx.createLivePusherContext.html)的相关方法 |
| [getPlayerInstance(id)](#getPlayerInstance(id)) | 获取某个 id 的 player 实例，可以调用 [playerContext](https://developers.weixin.qq.com/miniprogram/dev/api/media/live/wx.createLivePlayerContext.html)相关的方法 |

## API 使用指引

这部分会为您介绍如何进行使用上述 API 方法。

### 初始化TRTC实例

**注意：**初始化 TRTC 实例时传入的上下文应该是当前 page 的上下文，否则在调用实例方法的时候会出现无法获取的情况。

```javascript
import TRTC from 'trtc-wx.js'

page({
  onLoad(){
    this.TRTC = new TRTC(this)
    this.EVENT = this.TRTC.EVENT
  }
})
```

### on(EventCode, handler, context)

**说明：**

用于监听组件派发的事件，详细事件请参考 [事件表](https://cloud.tencent.com/document/product/647/17018#Event)。

> 注意：
>
> 请在调用 enterRoom 前监听事件，避免漏掉组件派发的事件。

**参数：**

| 参数名    | 类型     | 默认值 | 说明           |
| :-------- | :------- | :----- | :------------- |
| EventCode | String   | -      | 事件码         |
| handler   | Function | -      | 监听函数       |
| context   | Object   | -      | 当前执行上下文 |

**返回值：**

无

**示例代码：**

```javascript
this.TRTC.on(this.EVENT.LOCAL_JOIN, onLocalJoin, this)
```

### off(EventCode, handler)

**说明：**

取消事件监听。

**参数：**

| 参数名    | 类型     | 默认值 | 说明                   |
| :-------- | :------- | :----- | :--------------------- |
| EventCode | String   | -      | 事件码                 |
| handler   | Function | -      | 需要取消的具名监听函数 |

**返回值：**

无

**示例代码：**

```javascript
function onLocalJoin(event) {
 // 本地进房成功
}
trtcRoomContext.off(this.EVENT.LOCAL_JOIN, onLocalJoin)
```

### createPusher(pusherAttributes)

**说明：**

创建推流实例，可以传入初始化的参数，以下的参数都是可选参数。

**参数：**

| 参数名           | 类型   | 默认值  | 说明                                              |
| :--------------- | :----- | :------ | :------------------------------------------------ |
| pusherAttributes | Object | default | 可选，关于初始化参数您可以参照 pusherAttributes。 |

**返回值：**

pusherInstance

**示例代码：**

```javascript
this.TRTC.createPusher({'frontCamera': 'back'})
```

### enterRoom(params)

**说明：**

进入trtc房间

**参数：**

| 参数名   | 类型   | 默认值 | 说明                                                       |
| :------- | :----- | :----- | :--------------------------------------------------------- |
| sdkAppID | String | -      | 必填，您的腾讯云账号的 sdkAppID                             |
| userID   | String | -      | 必填，您进房的 userID                                       |
| userSig  | String | -      | 必填，您服务器签发的 userSig                                |
| roomID   | Number | -      | 必填，您要进入的房间号，如该房间不存在，系统会为您自动创建 |
| scene    | String | 'rtc'  | 选填，必填参数，使用场景：<li>rtc：实时通话，采用优质线路，同一房间中的人数不应超过300人。</li><li>live：直播模式，采用混合线路，支持单一房间十万人在线（同时上麦的人数应控制在50人以内）。</li> |

>! **视频通话&语音通话（scene = "rtc"）**
视频通话场景，支持 720P、1080P 高清画质。
视频通话场景，支持48kHz全频带，支持双声道。
单个房间最多支持300人同时在线，最高支持50人同时发言。
适用场景：1对1视频通话、300人视频会议、在线问诊、远程面试、视频客服、在线狼人杀等。
**互动直播&语音聊天室（scene = "live"）**
支持十万人级别观众同时播放，播放延时低至1000ms。
支持平滑上下麦，切换过程无需等待，主播延时小于300ms。
适用场景：视频低延时直播、十万人互动课堂、视频相亲、在线教育、远程培训、超大型会议等。

>? 其他pusherAttributes需要设置也可以在这里进行设置。

**返回值：**

pusherAttributes

**示例代码：**

```javascript
enterRoom(options) {
    this.setData({
        pusher: this.TRTC.enterRoom({
          sdkAppID: 1400xxxxx, // 您的腾讯云账号
          userID: 'trtc-user', //当前进房用户的userID
          userSig: 'xxxxxxx', // 您服务端生成的userSig
          roomID: 1234, // 您进房的房间号，
          enableMic: true, // 进房默认开启音频上行
          enableCamera: true, // 进房默认开启视频上行
        }),
    }, () => {
        this.TRTC.getPusherInstance.start() // 开始进行推流
    })
},
```

### exitRoom()

**说明：**

退房，重置状态机的状态，并同步到页面中，放置下次进房发生状态的混乱。

**参数：**

无

**返回值：**

Object

状态机重置，会返回更新后的 pusher 和 playerList

```
{
	pusher: {},
	playerList: {}
}
```

**示例代码：**

```javascript
exitRoom() {
    const result = this.TRTC.exitRoom()
    // 状态机重置，会返回更新后的pusher和playerList
    this.setData({
        pusher: result.pusher,
        playerList: result.playerList,
    })
},
```

### getPlayerList()

**说明：**

获取播放的 player 列表。

**参数：**

无

**返回值：**

Array 播放 player 的列表

**示例代码：**

```javascript
this.setData({
  playerList: this.TRTC.getPlayerList()
})
```

### setPusherAttributes(config)

**说明：**

设置推流的参数

**参数：**

| 参数名 | 类型   | 默认值 | 说明                               |
| :----- | :----- | :----- | :--------------------------------- |
| config | Object | -      | 您可以设置 pusherAttributes 中的属性 |

**返回值：**

pusherAttributes，返回更新后的推流状态

**示例代码：**

```javascript
this.setData({
  pusher: this.TRTC.setPusherAttributes({
    enableMic: false, // 关闭音频上行
    enableCamera: false, // 关闭视频上行
  }),
})
```

### setPlayerAttributes(id, config)

**说明：**

改变拉流 player 的参数

**参数：**

| 参数名 | 类型   | 默认值 | 说明                               |
| :----- | :----- | :----- | :--------------------------------- |
| id     | String | -      | 您需要改变状态的 player 的 id         |
| config | Object | -      | 您可以设置 playerAttributes 中的属性 |

**返回值：**

playerList，返回更新后的拉流状态列表

**示例代码：**

```javascript
this.setData({
  playerList: this.TRTC.setPlayerAttributes({
    muteAudio: false, // 关闭音频上行
    orientation: 'horizontal', // 改变拉流画面的方向
  }),
})
```

### getPusherInstance()

**说明：**

获取 pusher 的推流实例，调用挂载在实例上的相关方法，具体您可以参照 [pusherInstance](#pusherInstance)

**参数：**

无

**返回值：**

pusherInstance

**示例代码：**

```javascript
this.getPusherInstance().start() // 开始推流
```

### getPlayerInstance(id)

**说明：**

获取对应的 player 实例，调用挂载在实例上的相关方法，具体您可以参照 [playerInstance](#playerInstance)

**参数：**

| 参数名 | 类型   | 默认值 | 说明                       |
| :----- | :----- | :----- | :------------------------- |
| id     | String | -      | 您需要获取实例的 player 的 id |

**返回值：**

playerInstance

**示例代码：**

```javascript
this.getPlayerInstance().stop() // 停止这个player的播放
```

## 更多高级特性

&lt;live-pusher&gt;和&lt;live-player&gt;不仅仅具有原生标签所通用的标签属性，还具有相应 context 的能力，在每个标签 context 中都会有很多的 SDK 开放能力提供，trtc-wx 已经为您创建了相关的 context 对象，您只需要获取相应的 Instance 实例，就可以调用这些方法，参数的传递也是兼容微信原生方法的。
### pusherInstance

pusherInstance 是 trtc-wx 帮助您管理&lt;live-pusher&gt;的一个实例，这个对象是全局单例的，对于实例上的方法，大部分基于微信的原生  context 上的方法进行封装，所有参数均与官方文档一致，详细介绍如下表：

| 参数名                | 参数类型          | 参数说明                         | API说明           |
| :-------------------- | ----------------- | ------------- | :----------------------- |
| pusherAttributes      |                   | [pusherAttributes说明]()       | &lt;live-pusher&gt;标签上的属性，下文会有详细的介绍        |
| start(options)        | Object，可选      | [start参数](https://developers.weixin.qq.com/miniprogram/dev/api/media/live/LivePusherContext.start.html) | 开始推流，当您调用这个接口后，远端才能收到您的进房通知 |
| stop(options)         | Object，可选      | [stop参数](https://developers.weixin.qq.com/miniprogram/dev/api/media/live/LivePusherContext.stop.html) | 停止推流，您调用这个接口后，远端会收到您退房的通知     |
| pause(options)        | Object，可选      | [pause参数](https://developers.weixin.qq.com/miniprogram/dev/api/media/live/LivePusherContext.pause.html) | 暂停推流                                               |
| resume(options)       | Object，可选      | [resume参数](https://developers.weixin.qq.com/miniprogram/dev/api/media/live/LivePusherContext.resume.html) | 继续推流                                               |
| snapshot()            |                   | -    | 该接口已经进行了封装，对推流画面进行截图，并保存到本地相册    |
| playBGM(params)       | parma.url必填     | [playBGM参数](https://developers.weixin.qq.com/miniprogram/dev/api/media/live/LivePusherContext.playBGM.html) | 播放对应 URL 资源的音乐，作为背景音乐                    |
| pauseBGM(options)     | Object，可选      | [pauseBGM参数](https://developers.weixin.qq.com/miniprogram/dev/api/media/live/LivePusherContext.pauseBGM.html) | 暂停播放 BGM                                            |
| resumeBGM(options)    | Object，可选      | [resumeBGM参数](https://developers.weixin.qq.com/miniprogram/dev/api/media/live/LivePusherContext.resumeBGM.html) | 继续播放 BGM                                            |
| stopBGM(options)      | Object，可选      | [stopBGM参数](https://developers.weixin.qq.com/miniprogram/dev/api/media/live/LivePusherContext.stopBGM.html) | 停止播放 BGM                                            |
| setBGMVolume(params)  | params.volume必填 | [setBGMVolume](https://developers.weixin.qq.com/miniprogram/dev/api/media/live/LivePusherContext.pauseBGM.html) | 设置BGM的播放音量，默认是1.0                           |
| setMICVolume(params)  | params.volume必填 | [setMICVolume](https://developers.weixin.qq.com/miniprogram/dev/api/media/live/LivePusherContext.setMICVolume.html) | 设置麦克风的音量，默认是1.0                            |
| startPreview(options) | Object，可选      | [startPreview](https://developers.weixin.qq.com/miniprogram/dev/api/media/live/LivePusherContext.startPreview.html) | 开启预览                                               |
| stopPreview()         | Object，可选      | [stopPreview](https://developers.weixin.qq.com/miniprogram/dev/api/media/live/LivePusherContext.stopPreview.html) | 停止预览                                               |
| toggleTorch(options)  | Object，可选      | [toggleTorch](https://developers.weixin.qq.com/miniprogram/dev/api/media/live/LivePusherContext.toggleTorch.html) | 前置或后置摄像头，可选值：front，back                  |

#### pusherAttributes说明

| 参数名             | 类型    | 默认值      | 说明                                                         |
| :----------------- | :------ | :---------- | :----------------------------------------------------------- |
| mode               | String  | RTC         | RTC：实时通话 ; live：直播模式                               |
| enableCamera       | Boolean | false       | 是否开启摄像头                                               |
| enableMic          | Boolean | false       | 是否开启麦克风                                               |
| enableAgc          | Boolean | false       | 是否开启音频自动增益，该特性可以补偿部分手机麦克风音量太小的问题，但也会放大噪音，建议配合 ANS 同时开启。 |
| enableAns          | Boolean | false       | 是否开启音频噪声抑制，该特性会自动检测背景噪音并进行过滤，但也会误伤周围的音乐，只有会议、教学等场景才适合开启。 |
| minBitrate         | Number  | 600         | 最小码率，不建议设置太低。                                   |
| maxBitrate         | Number  | 900         | 最大码率，需要跟分辨率相匹配，建议参考 [分辨率码率参照表](https://cloud.tencent.com/document/product/647/32236#.E5.88.86.E8.BE.A8.E7.8E.87.E7.A0.81.E7.8E.87.E5.8F.82.E7.85.A7.E8.A1.A8)。 |
| frontCamera        | String  | front       | 前置或后置摄像头，可选值：front，back                        |
| enableZoom         | Boolean | false       | 是否支持双手滑动调整摄像头焦距。                             |
| videoWidth         | Number  | 360         | 视频宽（若设置了视频宽高就会忽略aspect）                     |
| videoHeight        | Number  | 640         | 视频高（若设置了视频宽高就会忽略aspect）                     |
| beautyLevel        | Number  | 0           | 美颜，取值范围 0-9 ，0 表示关闭                              |
| whitenessLevel     | Number  | 0           | 美白，取值范围 0-9 ，0 表示关闭                              |
| videoOrientation   | String  | vertical    | 推流方向，vertical：垂直方向， horizontal：水平方向          |
| enableRemoteMirror | Boolean | false       | 设置推流画面是否镜像，产生的效果会表现在 live-player         |
| localMirror        | String  | 'auto'      | 设置主播本地摄像头预览画面的镜像效果，支持如下取值：auto:前置摄像头镜像，后置摄像头不镜像（系统相机的表现 ）enable:前置摄像头和后置摄像头都镜像 disable: 前置摄像头和后置摄像头都不镜像 |
| audioQuality       | String  | 'high'      | 高音质(48KHz)或低音质(16KHz)，可选值：high，low              |
| audioVolumeType    | String  | 'voicecall' | 声音类型 可选值： media: 媒体音量，voicecall: 通话音量       |
| audioReverbType    | Number  | 0           | 音频混响类型 0: 关闭 1: KTV 2: 小房间 3:大会堂 4:低沉 5:洪亮 6:金属声 7:磁性 |
| beautyStyle        | String  | 'smooth'    | 美颜类型，取值有：smooth: 光滑、nature: 自然                |
| filter             | String  | ''          | 滤镜类型 standard: 标准 pink: 粉嫩 nostalgia: 怀旧 blues: 蓝调 romantic: 浪漫  cool: 清凉 fresher: 清新 solor: 日系 aestheticism: 唯美 whitening:美白 cerisered: 樱红 |

### playerInstance

playerInstance是trtc-wx为您管理的&lt;live-player&gt;的实例，

| 参数名                    | 参数类型            | 参数说明                                                     | API说明                                         |
| :------------------------ | ------------------- | -------------------------- | :----------------- |
| playerAttributes          |                     | [playerAttributes说明]()                                     | &lt;live-player&gt;标签上的属性，下文会有详细的介绍 |
| play(options)             | Object，可选        | [play参数](https://developers.weixin.qq.com/miniprogram/dev/api/media/live/LivePlayerContext.play.html) | 播放远端流，默认是自动模式，无需手动播放        |
| stop(options)             | Object，可选        | [stop参数](https://developers.weixin.qq.com/miniprogram/dev/api/media/live/LivePlayerContext.stop.html) | 停止播放                                        |
| pause(options)            | Object，可选        | [pause参数](https://developers.weixin.qq.com/miniprogram/dev/api/media/live/LivePlayerContext.pause.html) | 暂停播放                                        |
| resume(options)           | Object，可选        | [resume参数](https://developers.weixin.qq.com/miniprogram/dev/api/media/live/LivePlayerContext.resume.html) | 继续播放                                        |
| snapshot()                |                    | Promise    | 对 player 画面进行截图，保存到本地相册，返回值    |
| requestFullScreen(params) | parma.direction必填 | Promise    | 将这个 player 全屏播放       |
| requestExitFullScreen()   | 无                  | Promise      | 将这个 player 退出全屏播放  |
| mute(options)             | Object，可选        | [mute参数](https://developers.weixin.qq.com/miniprogram/dev/api/media/live/LivePlayerContext.mute.html) | 对当前player进行静音操作                        |

#### playerAttributes说明

| 参数名                | 类型    | 默认值   | 说明                                                         |
| :-------------------- | :------ | :------- | :----------------------------------------------------------- |
| mode                  | String  | RTC      | RTC：实时通话 ; live：直播模式                               |
| autoplay              | Boolean | true     | 有音频流下行后，是否自动播放                                 |
| muteAudio             | Boolean | true     | 默认不主动拉音频流，需要您手动进行订阅                       |
| muteVideo             | Boolean | true     | 默认不主动拉视频流，需要您手动进行订阅                       |
| orientation           | String  | vertical | player方向，vertical：垂直方向， horizontal：水平方向        |
| objectFit             | String  | fillCrop | 填充模式，可选值有 contain，fillCrop                         |
| minCache              | Number  | 1        | 最小缓冲区，单位s                                            |
| maxCache              | Number  | 2        | 最大缓冲区，单位s                                            |
| soundMode             | String  | speaker  | 是否支持双手滑动调整摄像头焦距。                             |
| enableRecvMessage     | Boolean | false    | 是否接收SEI消息                                              |
| autoPauseIfNavigate   | Boolean | true     | 当跳转到其它小程序页面时，是否自动暂停本页面的实时音视频播放 |
| autoPauseIfOpenNative | Boolean | true     | 当跳转到其它微信原生页面时，是否自动暂停本页面的实时音视频播放 |

[](id:Event)
## 事件表

通过组件实例的 EVENT 属性可以获取到事件常量字段，这些事件会通知您服务器推送的一些信息，以及 SDK 内部的一些参数提示。

```javascript
this.TRTC = new TRTC(this)
const EVENT = this.TRTC.EVENT
```

事件表

| CODE                       | 说明                                                         |
| :------------------------- | :----------------------------------------------------------- |
| LOCAL_JOIN                 | 成功进入房间。                                               |
| LOCAL_LEAVE                | 成功离开房间。                                               |
| REMOTE_USER_JOIN           | 远端用户进入房间时触发。                                     |
| REMOTE_USER_LEAVE          | 远端用户退出房间时触发。                                     |
| REMOTE_VIDEO_ADD           | 远端视频流添加事件，当远端用户发布视频流后会收到该通知。     |
| REMOTE_VIDEO_REMOVE        | 远端视频流移出事件，当远端用户取消发布视频流后会收到该通知。 |
| REMOTE_AUDIO_ADD           | 远端音频流添加事件，当远端用户发布音频流后会收到该通知。     |
| REMOTE_AUDIO_REMOVE        | 远端音频流移除事件，当远端用户取消发布音频流后会收到该通知。 |
| REMOTE_STATE_UPDATE        | 远端用户播放状态变更通知。                                   |
| LOCAL_NET_STATE_UPDATE     | 本地推流的网络状态变更通知。                                 |
| REMOTE_NET_STATE_UPDATE    | 远端用户网络状态变更通知。                                   |
| REMOTE_AUDIO_VOLUME_UPDATE | 远端用户音量变更通知。                                       |
| LOCAL_AUDIO_VOLUME_UPDATE  | 本地音量变更通知。                                       |
| VIDEO_FULLSCREEN_UPDATE    | 远端视图全屏状态变更通知。                                   |
| BGM_PLAY_PROGRESS          | BGM 播放时间戳变更通知。                                     |
| BGM_PLAY_COMPLETE          | BGM 播放结束通知。                                           |
| ERROR                      | 本地推流出现错误、渲染错误事件等。                           |

### LOCAL_JOIN

本地进房成功后的回调

```javascript
let onLocalJoin = function(event){
  console.log('本地进房成功')
}
this.TRTC.on(EVENT.LOCAL_JOIN, onLocalJoin)
```

### LOCAL_LEAVE

本地离开房间后的回调

```javascript
let onLocalLeave = function(event){
  console.log('本地退房成功')
}
this.TRTC.on(EVENT.LOCAL_LEAVE, onLocalLeave)
```

### REMOTE_USER_JOIN

远端用户加入此房间

```javascript
let onRemoteUserJoin = function(event){
  // userID 是加入的用户 ID
  const { userID, userList, playerList } = event.data
}
this.TRTC.on(EVENT.REMOTE_USER_JOIN, onRemoteUserJoin)
```

### REMOTE_USER_LEAVE

远端的用户离开

```javascript
let onRemoteUserLeave = function(event){
  // userID 是离开的用户 ID
  const { userID, userList, playerList } = event.data
}
this.TRTC.on(EVENT.REMOTE_USER_LEAVE, onRemoteUserLeave)
```

### REMOTE_VIDEO_ADD

远端的用户有新的视频上行

```javascript
let onRemoteVideoAdd = function(event){
  // id 是对应的player的id
  const { player, userList, playerList } = event.data
}
this.TRTC.on(EVENT.REMOTE_VIDEO_ADD, onRemoteVideoAdd)
```

### REMOTE_VIDEO_REMOVE

远端的用户有视频上行移除

```javascript
let onRemoteVideoRemove = function(event){
  // id 是对应的player的id
  const { player, userList, playerList } = event.data
}
this.TRTC.on(EVENT.REMOTE_VIDEO_REMOVE, onRemoteVideoRemove)
```

### REMOTE_AUDIO_ADD

远端的用户有新的音频上行

```javascript
let onRemoteAudioAdd = function(event){
  // id 是对应的player的id
  const { player, userList, playerList } = event.data
}
this.TRTC.on(EVENT.REMOTE_AUDIO_ADD, onRemoteAudioAdd)
```

### REMOTE_AUDIO_REMOVE

远端的用户有音频上行移除

```javascript
let onRemoteAudioRemove = function(event){
  // id 是对应的player的id
  const { id, userList, playerList } = event.data
}
this.TRTC.on(EVENT.REMOTE_AUDIO_REMOVE, onRemoteAudioRemove)
```

### REMOTE_STATE_UPDATE

远端的用户有音频上行移除

```javascript
let onRemoteStateUpdate = function(event){
  // id 是对应触发的 player 的 id，目前 streamid 和 id 是相同的
  const id = event.currentTarget.dataset.streamid
  const data = event.data // 这里是微信原生组件抛出的关于player的信息，若有需要您可以自主获取
}
this.TRTC.on(EVENT.REMOTE_AUDIO_REMOVE, onRemoteStateUpdate)
```

### LOCAL_NET_STATE_UPDATE

本地网络相关状态变更

```javascript
let onLocalNetStateUpdate = function(event){
  // 这里会返回更新后的 pusherAttributes，上面有个属性是 netStatus 对应网络状态的对象
  // 其中 netQualityLevel 对应网络状态的好坏，1 代表最好，数字越大代表网络越差
  const netStatus = event.data.pusher.netStatus
}
this.TRTC.on(EVENT.LOCAL_NET_STATE_UPDATE, onLocalNetStateUpdate)
```

### REMOTE_NET_STATE_UPDATE

远端用户网络相关状态变更

```javascript
let onRemoteNetStateUpdate = function(event){
  // 这里会返回更新后的 playerList，上面有个属性是 netStatus 对应网络状态的对象
  // 其中 netQualityLevel 对应网络状态的好坏，1 代表最好，数字越大代表网络越差
  const { playerList } = event.data

}
this.TRTC.on(EVENT.REMOTE_NET_STATE_UPDATE, onRemoteNetStateUpdate)
```

### REMOTE_AUDIO_VOLUME_UPDATE

远端用户音量状态变更

```javascript
let onRemoteAudioVolumeUpdate = function(event){
  // 这里会返回更新后的 playerList
  const { playerList } = event.data
}
this.TRTC.on(EVENT.REMOTE_AUDIO_VOLUME_UPDATE, onRemoteAudioVolumeUpdate)
```

### LOCAL_AUDIO_VOLUME_UPDATE

本地音量状态变更

```javascript
let onLocalAudioVolumeUpdate = function(event){
  // 这里会返回更新后的 pusher 状态
  const { pusher } = event.data
}
this.TRTC.on(EVENT.LOCAL_AUDIO_VOLUME_UPDATE, onLocalAudioVolumeUpdate)
```

### VIDEO_FULLSCREEN_UPDATE

远端视图全屏状态变更

```javascript
let onVideoFullscreenUpdate = function(event){
  // 您可以进行业务的操作，目前没有抛出data字段
}
this.TRTC.on(EVENT.VIDEO_FULLSCREEN_UPDATE, onVideoFullscreenUpdate)
```

### BGM_PLAY_PROGRESS

远端视图全屏状态变更

```javascript
let onBgmPlayProgress = function(event){
  // progress是已经播放的时长，duration是总时长，比值代表当前的进度
  const { progress, duration } = event.data
  
}
this.TRTC.on(EVENT.BGM_PLAY_PROGRESS, onBgmPlayProgress)
```

### BGM_PLAY_COMPLETE

BGM播放完成

```javascript
let onBgmPlayComplete = function(event){
  // 您可以进行业务的操作，目前没有抛出data字段
}
this.TRTC.on(EVENT.BGM_PLAY_COMPLETE, onBgmPlayComplete)
```

### ERROR

BGM播放完成

```javascript
let onError = function(event){
  // 您可以监听一些预期之外的错误信息
}
this.TRTC.on(EVENT.ERROR, onError)
```
