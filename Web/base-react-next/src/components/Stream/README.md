Stream 组件使用说明

参数说明：

```javascript
stream {Stream} 从 TRTC 中获取到的本地流或者远端流

config {Object}

@param {String} className classname 选填

@param {Boolean} video 视频初始状态 选填

@param {Boolean} audio 音频初始状态 选填

@param {Boolean} mic 话筒初始状态 选填

@param {Boolean} view 视图初始状态 选填

@param {Boolean} shareDesk 共享桌面初始状态 选填
```

```js
function init(dom) {
 // 流播放需要的 dom        
  navigator.mediaDevices.getUserMedia(mediaStreamConstraints)
    .then((mediaStream) => {
            const video = document.createElement('video');
            console.log(mediaStream);
            video.srcObject = mediaStream;
            video.autoplay = true;
            dom.append(video);
     })
}
```

```js
function onChange (data) {
    const { name, config } = data;
  // @param {String} name 要修改的功能名称 video:视频，audio，音频，mic：麦克风，view：视图，shareDesk：分享桌面
  // @param {Object} config 当前组件的传入对象
    config[name] = !config[name];
    setLocal(config);
}
```

使用说明：

```js
import Stream from "../components/stream";
<Stream config={config} init={init} onChange={handleLocalChange}></Stream>
```

