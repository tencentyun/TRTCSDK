## 目录结构说明

本目录包含 Android 版 TRTC 的所有 Demo 源代码，被分成 TRTCSimpleDemo 和 TRTCScenesDemo 两个子目录：
- TRTCSimpleDemo： 最简单的示例代码，主要演示接口如何调用以及最基本的功能。
- TRTCScenesDemo： 较复杂的场景案例，结合了 TRTC 和 IM 两个 SDK ，所实现的交互也更接近真实产品。

```
├─ TRTCScenesDemo // TRTC场景化Demo，包括视频通话、语音通话、视频互动直播、语音聊天室
|  ├─ app                   // 程序入口界面
|  ├─ audioeffectsettingkit // 音效面板，包含BGM播放，变声，混响，变调等效果
|  ├─ beautysettingkit      // 美颜面板，包含美颜，滤镜，动效等效果
|  ├─ debug                 // 包含 GenerateTestUserSig，用于本地生成测试用的 UserSig
|  ├─ login                 // 一个演示性质的简单登录界面
|  ├─ trtcmeetingdemo       // 场景一：多人会议，类似腾讯会议，包含屏幕分享
|  ├─ trtcvoiceroomdemo     // 场景二：语音聊天室，也叫语聊房，多人音频聊天场景
|  ├─ trtcliveroomdemo      // 场景三：互动直播，包含连麦、PK、聊天、点赞等特性
|  ├─ trtcaudiocalldemo     // 场景四：音频通话，展示双人音频通话，有离线通知能力
|  ├─ trtcvideocalldemo     // 场景五：视频通话，展示双人视频通话，有离线通知能力
|  
├─ TRTCSimpleDemo // TRTC精简化Demo，包含通话模式和直播模式。
|  ├─ live                  // 演示 TRTC 以直播模式运行的示例代码，该模式下有角色的概念
|  ├─ rtc                   // 演示 TRTC 以通话模式运行的示例代码，该模式下无角色的概念
|  ├─ screen                // 演示 TRTC 如何进行屏幕分享的示例代码
|  ├─ debug                 // 包含 GenerateTestUserSig，用于本地生成测试用的 UserSig  
|
├─ SDK 
│  ├─ LiteAVSDK_TRTC_x.y.zzzz.aar         // 如果您下载的是精简版 zip 包，解压后将出现此文件夹，其中 x.y.zzzz 表示 SDK 版本号 
|  ├─ LiteAVSDK_Professional_x.y.zzzz.aar // 如果您下载的是专业版 zip 包，解压后将出现此文件夹，其中 x.y.zzzz 表示 SDK 版本号 
|  ├─ LiteAVSDK_Enterprise_x.y.zzzz.aar   // 如果您下载的是企业版 zip 包，解压后将出现此文件夹，其中 x.y.zzzz 表示 SDK 版本号 
```

## SDK 分类和下载

腾讯云 TRTC SDK 基于 LiteAVSDK 统一框架设计和实现，该框架包含直播、点播、短视频、RTC、AI美颜在内的多项功能：
- 如果您追求最小化体积增量，可以下载 TRTC 精简版：[TXLiteAVSDK_TRTC.zip](https://cloud.tencent.com/document/product/647/32689#TRTC)
- 如果您需要使用多个功能而不希望打包多个 SDK，可以下载专业版：[TXLiteAVSDK_Professional.zip](https://cloud.tencent.com/document/product/647/32689#Professional)
- 如果您已经通过腾讯云商务购买了 AI 美颜 License，可以下载企业版：[TXLiteAVSDK_Enterprise.zip](https://cloud.tencent.com/document/product/647/32689#Enterprise)

## 相关文档链接

- [SDK 的版本更新历史](https://github.com/tencentyun/TRTCSDK/releases)
- [SDK 的 API 文档](http://doc.qcloudtrtc.com/md_introduction_trtc_Android_%E6%A6%82%E8%A7%88.html)
- [SDK 的官方体验 App](https://cloud.tencent.com/document/product/647/17021)
- [场景方案：互动直播](https://cloud.tencent.com/document/product/647/43181)
- [场景方案：视频通话](https://cloud.tencent.com/document/product/647/42044)
- [场景方案：语音通话](https://cloud.tencent.com/document/product/647/42046)
