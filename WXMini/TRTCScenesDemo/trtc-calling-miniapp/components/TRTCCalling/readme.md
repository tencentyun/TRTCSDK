### TUICalling接入说明

1. ##### 复制 TUICalling 到 components 文件

2. ##### 添加组件到对应page

```json
{
  "usingComponents": {
    "TRTCCalling": "../../components/TUICalling/TRTCCalling",
}
```

3. ##### 使用组件

js文件

```javascript
Page({
  /**
   * 页面的初始数据
   */
  data: {
    config: {
      sdkAppID: 0,
      userID: 0,
      userSig: '',
      type: 1
    },
    userId: 1
  },


  /**
   * 生命周期函数--监听页面加载
   */
  onLoad: function (options) {
    	// 将初始化后到TRTCCalling实例注册到this.TRTCCalling中，this.TRTCCalling 可使用TRTCCalling所以方法功能。
   		this.TRTCCalling = this.selectComponent('#TRTCCalling-component');
      // 绑定需要监听到事件
      this.bindTRTCCallingRoomEvent();
    	// 登录TRTCCalling
      this.TRTCCalling.login();
  },
  
  bindTRTCCallingRoomEvent: function() {
    const TRTCCallingEvent = this.TRTCCalling.EVENT
    this.TRTCCalling.on(TRTCCallingEvent.INVITED, (event) => {
     console.log('收到邀请')
    })
    // 处理挂断的事件回调
    this.TRTCCalling.on(TRTCCallingEvent.HANG_UP, () => {
      console.log('挂断')
    })
    this.TRTCCalling.on(TRTCCallingEvent.REJECT, () => {
      console.log('对方拒绝')
    })
    this.TRTCCalling.on(TRTCCallingEvent.USER_LEAVE, () => {
      console.log('用户离开房间')
    })
    this.TRTCCalling.on(TRTCCallingEvent.NO_RESP, () => {
      console.log('对方无应答')
    })
    this.TRTCCalling.on(TRTCCallingEvent.CALLING_TIMEOUT, () => {
      console.log('无应答超时')
    })
    this.TRTCCalling.on(TRTCCallingEvent.LINE_BUSY, () => {
      console.log('对方忙线')
    })
    this.TRTCCalling.on(TRTCCallingEvent.CALLING_CANCEL, () => {
      console.log('取消通话')
    })
    this.TRTCCalling.on(TRTCCallingEvent.USER_ENTER, () => {
      console.log('用户进入房间')
    })
    this.TRTCCalling.on(TRTCCallingEvent.CALL_END, () => {
     	console.log('通话结束')
    })
  },
  
  call: function() {
    this.TRTCCalling.call({ userID: this.data.userId, type:2})
  },
})
```

wxml文件

```xml
		<TRTCCalling 
      id="TRTCCalling-component"
      config="{{config}}"
    ></TRTCCalling>
```

