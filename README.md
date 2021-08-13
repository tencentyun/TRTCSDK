# 腾讯云实时音视频终端组件 TRTC SDK

## 工程动态

TUI场景化解决方案是腾讯云TRTC针对直播、语聊、视频通话等推出的低代码解决方案，依托腾讯在音视频&通信领域的技术积累，帮助开发者快速实现相关业务场景，聚焦核心业务，助力业务起飞，欢迎使用～

- [视频互动直播-TUILiveRoom](https://github.com/tencentyun/TUILiveRoom/)
- [实时语音/视频通话-TUICalling](https://github.com/tencentyun/TUICalling/)
- [多人视频会议-TUIMeeting](https://github.com/tencentyun/TUIMeeting/)
- [语音聊天室-TUIVoiceRoom](https://github.com/tencentyun/TUIVoiceRoom/)
- [语音沙龙-TUIChatSalon](https://github.com/tencentyun/TUIChatSalon)

## SDK 下载

访问 Github 较慢的客户可以考虑使用国内下载地址： [DOWNLOAD](https://cloud.tencent.com/document/product/647/32689) 。

| 所属平台 | Zip下载 | Demo运行说明 | SDK集成指引 | API 列表 |
|:---------:| :--------:|:--------:| :--------:|:--------:|
| iOS | [下载](https://liteav.sdk.qcloud.com/download/latest/TXLiteAVSDK_TRTC_iOS_latest.zip)| [DOC](https://cloud.tencent.com/document/product/647/32396)| [DOC](https://cloud.tencent.com/document/product/647/32173) | [API](https://cloud.tencent.com/document/product/647/32258) |
| Android | [下载](https://liteav.sdk.qcloud.com/download/latest/TXLiteAVSDK_TRTC_Android_latest.zip)| [DOC](https://cloud.tencent.com/document/product/647/32166)| [DOC](https://cloud.tencent.com/document/product/647/32175) | [API](https://cloud.tencent.com/document/product/647/32267) |
| Win(C++)| [下载](https://liteav.sdk.qcloud.com/download/latest/TXLiteAVSDK_TRTC_Win_latest.zip)| [DOC](https://cloud.tencent.com/document/product/647/32397)| [DOC](https://cloud.tencent.com/document/product/647/32178) | [API](https://cloud.tencent.com/document/product/647/32268) |
| Win(C#)| [下载](https://liteav.sdk.qcloud.com/download/latest/TXLiteAVSDK_TRTC_Win_latest.zip)| [DOC](https://cloud.tencent.com/document/product/647/32397)| [DOC](https://cloud.tencent.com/document/product/647/32178) | [API](https://cloud.tencent.com/document/product/647/36776) |
| Mac| [下载](https://liteav.sdk.qcloud.com/download/latest/TXLiteAVSDK_TRTC_Mac_latest.tar.bz2)| [DOC](https://cloud.tencent.com/document/product/647/32396)| [DOC](https://cloud.tencent.com/document/product/647/32176) |[API](https://cloud.tencent.com/document/product/647/32258) |
| Web | [下载](https://web.sdk.qcloud.com/trtc/webrtc/download/webrtc_latest.zip)| [DOC](https://cloud.tencent.com/document/product/647/32398)| [DOC](https://cloud.tencent.com/document/product/647/16863) |[API](https://cloud.tencent.com/document/product/647/17249) |
| Electron | [下载](https://web.sdk.qcloud.com/trtc/electron/download/TXLiteAVSDK_TRTC_Electron_latest.zip) | [DOC](https://cloud.tencent.com/document/product/647/38548) | [DOC](https://cloud.tencent.com/document/product/647/38549) |[API](https://cloud.tencent.com/document/product/647/38551) |
| 微信小程序 | [下载](https://web.sdk.qcloud.com/component/trtccalling/download/trtc-calling-miniapp.zip) | [DOC](https://cloud.tencent.com/document/product/647/32399) | [DOC](https://cloud.tencent.com/document/product/647/32183) |[API](https://cloud.tencent.com/document/product/647/17018) |

## Version 9.0 @ 2021.08.06

**欢迎加入**
团队技术氛围浓厚，培训体系完善，产品线多样，有经验丰富的“老司机”手把手帮你入门音视频技术。<br>
北京、西安、上海、深圳、广州均有岗位，如果您对音视频技术感兴趣，欢迎加入我们 [腾讯云 TRTC 研发团队](https://careers.tencent.com/jobdesc.html?postId=1297858141983088640) 。

**功能新增**
- iOS：支持设置系统采集音量，详见 [setSystemAudioLoopbackVolume](https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__ios.html#afc45226807d84673bab78b21d1be54ae)；
- 全平台：支持设置自定义音轨的音量，详见 [setMixExternalAudioVolume](https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__cplusplus.html#ae0031e4af8bb120ef6de164d99886418)；
- 全平台：状态回调可区分音频和视频的丢包率，详见 [TRTCRemoteStatistics](https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCStatistic__cplusplus.html#structliteav_1_1TRTCRemoteStatistics)；

**质量优化**
- 全平台：优化订阅流程，提升手动订阅的秒开速度；
- 全平台：修复特定场景 onExitRoom 回调重复的问题；

**问题修复**
- Android：修复自定义采集动态设置码率和帧率无效的问题；
- iOS：修复先开启录屏辅路，再开启摄像头推流导致的推流失败问题；
- iOS：修复本地视频录制模糊的问题；
- iOS：修复若干稳定性问题；
- Winodws：修复屏幕分享时采集帧率异常的问题；
- Windows：修复屏幕分享切换目标时，播放端会先显示一帧旧画面的问题；

更早期的版本更新历史请点击  [More](https://cloud.tencent.com/document/product/647/46907)...

## Demo 体验地址

### iOS
> [APPStore 体验地址](https://itunes.apple.com/cn/app/id1400663224?mt=8)
![](https://main.qcloudimg.com/raw/fa84e7c632b74483e9dc91dc04a8255e.jpg)

### Android
> [应用宝体验地址](https://android.myapp.com/myapp/detail.htm?apkName=com.tencent.trtc&ADTAG=mobile)
![](https://main.qcloudimg.com/raw/913eecbf69577de4e27d9bfe45acf80e.jpg)

### Mac OS
> [下载后解压体验](https://liteav.sdk.qcloud.com/app/install/TXLiteAVSDK_Mac_Demo.tar.bz2)
![](https://main.qcloudimg.com/raw/8d146afb3b2dd07d5b5f1ca4432a9411.jpg)

### Windows
> [下载后安装体验](https://liteav.sdk.qcloud.com/app/install/TXLiteAVSDK_Win_Demo.exe)
![](https://main.qcloudimg.com/raw/00ec3ebc86902044c51a5487c18dcd0c.jpg)

### 微信小程序
>![](https://main.qcloudimg.com/raw/81662cce932b2500addac28baf6a83b3.jpg)

### Web 网页
> [Chrome 打开体验](https://web.sdk.qcloud.com/trtc/webrtc/demo/latest/official-demo/index.html)
![](https://main.qcloudimg.com/raw/56e2bbc928a11bac85e5b78ac171b3bc.jpg)