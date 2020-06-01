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

## 最新版本 7.3 @ 2020.6.1
【功能新增】
1. 全平台：支持全链路128高音质立体声，通过 setAudioQuality(TRTCAudioQualityMusic) 接口即可设置。
1. 全平台：支持 SPEECH 语音模式，适合会议场景下的语音通话，拥有更强的降噪（ANS）能力，通过 setAudioQuality(TRTCAudioQualitySpeech) 可以设置。
1. 全平台：支持多路背景音乐并行播放，用于支持原声和伴唱分离的 K 歌场景。同时支持背景音乐循环播放。
1. 全平台：在兼容老接口的情况下，增加了全新的音效管理接口 TXAudioEffectManager，用于支持更加灵活和多样的音效能力。
1. 全平台：视频编码参数 setVideoEncoderParam 新增 minVideoBitrate 选项，推荐对画质要求高的直播客户进行设置。
1. 全平台：支持先调用 muteLocalVideo 再调用 startLocalPreview 实现“只预览，不推流”的效果，您也可以通过在 enterRoom 前调用 startLocalPreview 实现该能力。
1. iOS：新增 iOS 系统级录屏方案，可以实现类似腾讯会议的全系统屏幕分享效果。我们同时优化了接入的易用性，可以实现半天内完成该功能的接入。
1. iOS：耳返支持叠加混响等声音效果。
1. Android + Windows：音频新增瞬态降噪支持，您可以通过 setAudioQuality(TRTCAudioQualitySpeech) 开启。
1. Android：音效文件支持 asset 打包的音效文件。
1. Windows：新增变声等音效的能力支持。

【效果优化】
1. iOS：优化旧设备性能开销。
1. Mac：优化蓝牙耳机兼容性。
1. Android：提升本地视频清晰度。
1. Android：播放端自定义渲染支持纹理的方式，降低性能开销。
1. Android：优化摄像头采集分辨率选取逻辑，提升视角效果。
1. Android：优化了回声处理效果。

【BUGFIX】
1. 全平台：修复本地音频录制偶现的断断续续的bug。
1. 全平台：修复暂停推流（ muteLocalVideo，muteLocalAudio ）时，发生强杀或crash后重进房，播放端不会自动播放音视频的问题。
1. Mac：修复屏幕分享时，某些情况下花屏问题。
1. Android：修复自定义视频采集时，偶现 SDK 内部 OpenGL 上下文错误 crash。
1. Android：修复进房前 setLocalVideoRenderListener 自定义渲染回调不触发的问题。
1. Android：修复横屏模式下切换前后摄像头，播放端画面会倒置的问题。
1. Android：修复进房前调用 startLocalPreview，进房后播放端概率花屏问题。
1. Android：修复硬编码器偶现crash。
1. Windows：修复屏幕分享切换分享目标时播放端卡顿。
1. windows：修复了 MacBook 上使用 BootCamp 运行的 Windows 系统的兼容问题。
1. Windows：修复多声道硬件设备采集、播放的无声问题。

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


