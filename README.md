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

## Version 7.8 @ 2020.09.29

- iOS：修复 iPhone SE 播放声音小的问题
- iOS：支持垫片推流，使用方法见 TRTCCloud.setVideoMuteImage
- iOS：修复子房间 (TRTCCloud.createSubCloud) 调用 muteRemoteAudio 触发 crash 的问题
- iOS：修复偶现渲染 crash
- iOS：修复前后台切换时在部分 iPad 视频渲染偶现卡死主线程的问题
- iOS：支持 VODPlayer 和 trtc 一起使用，并且支持回声消除
- iOS：修复已知内存泄露
- iOS：修复 iOS14 提示“查找并连接本地网络上的设备”的问题

- Mac：修复 getCurrentCameraDevice 始终返回 nil 的问题
- Mac：新增系统音量变化回调，详见：TRTCCloudDelegate.onAudioDevicePlayoutVolumeChanged
- Mac：解决部分USB摄像头无法打开的问题
- Mac：支持垫片推流，使用方法见 TRTCCloud.setVideoMuteImage
- Mac：修复屏幕分享指定区域面积为0时的 crash

- Android：优化声音路由策略：戴耳机时，声音只从耳机播放
- Android：支持垫片推流，使用方法见 TRTCCloud.setVideoMuteImage
- Android：支持部分系统下采用低延迟采集播放，降低 Android 系统通话延迟
- Android：修复未配置 READ_PHONE_STATE 权限时，Android5.0 设备 crash 的问题
- Android：修复蓝牙耳机断开再连上之后音频采集和播放异常的问题
- Android：支持 VODPlayer 和 trtc 一起使用，并且支持回声消除
- Android：修复已知crash

- Windows：兼容虚拟摄像头 e2eSoft Vacm
- Windows：新增支持跨屏指定区域进行屏幕分享
- Windows：支持同时调用 startLocalPreview 和 startCameraDeviceTest
- Windows：支持屏幕分享走主路的同时，调用 startLocalPreview 开启本地预览
- Windows：新增窗口分享支持过滤指定窗口进行抗遮挡，详见：TRTCCloud.addExcludedShareWindow & TRTCCloud.removeExcludedShareWindow
- Windows：新增系统音量变化回调，详见：ITRTCCloudCallback.onAudioDevicePlayoutVolumeChanged
- Windows：降低因SDK内部播放缓冲引发音频延迟较大的问题
- Windows：优化音频启动逻辑，在仅播放的情况下不占用麦克风
- Windows：修复64位 SDK 多次开关屏幕分享会 crash 的问题
- Windows：修复部分系统使用 OpenGL 会 crash 的问题


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


