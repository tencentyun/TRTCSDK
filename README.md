# 腾讯云实时音视频终端组件 TRTC SDK

## 最新动态

尊敬的开发者，您好，鉴于之前TRTC运营团队的调研结果：绝大部分开发者反馈希望我们能够将 [TRTCSDK](https://github.com/tencentyun/TRTCSDK) 按照平台&框架进行分类，减少仓库大小，同时为了信息更加聚焦不分散，**LiteAV SDK团队针对TRTC等产品创建了一个全新的Organization：**[**LiteAVSDK**](https://github.com/LiteAVSDK)，其中包含**实时音视频（TRTC）**、移动直播等多个腾讯云音视频产品，更多TRTC产品请点击[这里](https://github.com/LiteAVSDK?q=TRTC_&type=all&language=&sort=)...

![](https://qcloudimg.tencent-cloud.cn/raw/9e4643907ac68ded6be16c817f6ab360.png)

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

## Version 9.5 @ 2022.01.11

**问题修复：**

- 全平台：提升 API 易用性，修复部分 API 特定调用时序导致自定义渲染播放黑屏的问题。
- Windows：修复屏幕分享采集区域不完整的问题。
- iOS：修复 [muteLocalVideo](https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__ios.html#ac3a158f935a99abd4965d308c0f88977) 调用后退房下次进房还是不推流状态的问题。
- iOS：修复混流设置背景图无效的问题。

**功能优化：**

- 全平台：优化通话场景在弱网时的流畅度。
- Windows：优化摄像头兼容性，解决部分设备采集帧率与设定值不符或开启失败的问题。
- iOS：提升兼容性，降低和其他渲染组件如 cocos2D 共用时的冲突。
- Android：修复上行关闭再开启摄像头，播放端先显示关闭前最后一帧再正常显示的问题。

更早期的版本更新历史请点击  [More](https://cloud.tencent.com/document/product/647/46907)...