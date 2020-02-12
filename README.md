# 腾讯云实时音视频终端组件 TRTC SDK

## SDK 下载
访问 Github 较慢的客户可以考虑使用国内下载地址： [DOWNLOAD](https://cloud.tencent.com/document/product/647/32689) 。

| 所属平台 | Zip下载 | Demo运行说明 | SDK集成指引 | API 列表 |
|:---------:| :--------:|:--------:| :--------:|:--------:|
| iOS | [下载](http://liteavsdk-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_TRTC_iOS_latest.zip)| [DOC](https://cloud.tencent.com/document/product/647/32396)| [DOC](https://cloud.tencent.com/document/product/647/32173) | [API](https://cloud.tencent.com/document/product/647/32258) |
| Android | [下载](http://liteavsdk-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_TRTC_Android_latest.zip)| [DOC](https://cloud.tencent.com/document/product/647/32166)| [DOC](https://cloud.tencent.com/document/product/647/32175) | [API](https://cloud.tencent.com/document/product/647/32267) |
| Win(C++)| [下载](http://liteavsdk-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_TRTC_Win_latest.zip)| [DOC](https://cloud.tencent.com/document/product/647/32397)| [DOC](https://cloud.tencent.com/document/product/647/32178) | [API](https://cloud.tencent.com/document/product/647/32268) |
| Win(C#)| [下载](http://liteavsdk-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_TRTC_Win_latest.zip)| [DOC](https://cloud.tencent.com/document/product/647/32397)| [DOC](https://cloud.tencent.com/document/product/647/32178) | [API](https://cloud.tencent.com/document/product/647/36776) |
| Mac| [下载](http://liteavsdk-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_TRTC_Mac_latest.tar.bz2)| [DOC](https://cloud.tencent.com/document/product/647/32396)| [DOC](https://cloud.tencent.com/document/product/647/32176) |[API](https://cloud.tencent.com/document/product/647/32258) |
| Web | [下载](https://liteavsdk-1252463788.cosgz.myqcloud.com/H5_latest.zip)| [DOC](https://cloud.tencent.com/document/product/647/32398)| [DOC](https://cloud.tencent.com/document/product/647/16863) |[API](https://cloud.tencent.com/document/product/647/17249) |
| Electron | [下载](http://liteavsdk-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_TRTC_Electron_latest.zip) | [DOC](https://cloud.tencent.com/document/product/647/38548) | [DOC](https://cloud.tencent.com/document/product/647/38549) |[API](https://cloud.tencent.com/document/product/647/38551) |
| 微信小程序 | [下载](http://liteavsdk-1252463788.cosgz.myqcloud.com/TRTC_WXMini_latest.zip) | [DOC](https://cloud.tencent.com/document/product/647/32399) | [DOC](https://cloud.tencent.com/document/product/647/32183) |[API](https://cloud.tencent.com/document/product/647/17018) |

## 最新版本 6.9 @ 2020.01.14
新特性：
1. 全平台 enterRoom 参数 TRTCParams 中新增加 streamId 属性，用于设定当前用户在 CDN 上的直播流 ID，更方便您绑定直播 CDN。
2. 全平台 enterRoom 参数 TRTCParams 中新增加 cloudRecordFileName 属性，您可以设置本次直播在云端录制的文件名。同时我们优化了录制服务对视频流中断的抵抗能力，使得远程录制的文件更加完整。
3. 全平台 新增场景 TRTCAppSceneAudioCall，在 enterRoom 时可以设置。该场景下，TRTC SDK 针对语音通话进行了全方位的优化。
4. 全平台 新增场景 TRTCAppSceneVoiceChatRoom，在 enterRoom 时可以设置，可以开启 TRTC SDK 专门针对语音互动聊天室场景所作的各项优化。
5. 全平台 视频画面支持 1080P 高分辨率采集，让手机直播 PC 观看的场景获得更佳的画面清晰度。
6. iOS&Android 新增API：snapshotVideo()  支持本地及远端视频画面截图。
7. 全平台 新增API：pauseAudioEffect、resumeAudioEffect 音效支持暂停/恢复控制。
8. 全平台 新增API：setBGMPlayoutVolume、setBGMPublishVolume，BGM 支持分别设置本地播放和推流混音音量。
9. 全平台 新增API：setRemoteSubStreamViewRotation 辅路视频播放支持调整渲染旋转角度。
10. 全平台 错误码优化，简化进房错误码。
11. Android 平台新增加一种全局音量类型模式：setSystemVolumeType(TRTCSystemVolumeTypeVOIP)，即一直采用通话音量，主要用于解决蓝牙耳机自带麦克风的采集切换问题。
12. 增加对 Android 10.0 系统的支持。
13. C# 版 SDK 支持真窗口渲染和自定义渲染。
14. C# 版 SDK 对齐本地音频录制能力。

关键bug修复：
1. 全平台 优化偶现秒开慢的问题
2. 全平台 修复偶现进房失败后无法恢复的问题
3. iOS 修复偶现视频硬解码crash
4. Android 优化某些机型硬解时音画不同步的问题
5. Android 修复偶现http组件crash
6. Android 修复音效播放偶现没有完成回调的问题
7. Windows 修复屏幕采集切换采集窗口后遮挡红框不移除的问题
8. Windows 优化部分USB设备兼容问题


## Demo 体验地址

### iOS
> [APPStore 体验地址](https://itunes.apple.com/cn/app/id1400663224?mt=8)
![](https://main.qcloudimg.com/raw/fa84e7c632b74483e9dc91dc04a8255e.jpg)

### Android
> [应用宝体验地址](https://android.myapp.com/myapp/detail.htm?apkName=com.tencent.trtc&ADTAG=mobile)
![](https://main.qcloudimg.com/raw/913eecbf69577de4e27d9bfe45acf80e.jpg)

### Mac OS
> [下载后解压体验](http://trtc-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_Mac_Demo.tar.bz2)
![](https://main.qcloudimg.com/raw/8d146afb3b2dd07d5b5f1ca4432a9411.jpg)

### Windows
> [下载后安装体验](http://trtc-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_Win_Demo.exe)
![](https://main.qcloudimg.com/raw/00ec3ebc86902044c51a5487c18dcd0c.jpg)

### 微信小程序
>![](https://main.qcloudimg.com/raw/81662cce932b2500addac28baf6a83b3.jpg)

### Web 网页
> [Chrome 打开体验](https://trtc-1252463788.file.myqcloud.com/web/demo/official-demo/index.html)
![](https://main.qcloudimg.com/raw/56e2bbc928a11bac85e5b78ac171b3bc.jpg)


