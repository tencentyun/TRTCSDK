## 目录结构说明


本目录包含 iOS 版 TRTC 的所有 Demo 源代码，被分成 TRTCSimpleDemo 和 TRTCScenesDemo 两个子目录：
- TRTCSimpleDemo： 最简单的示例代码，主要演示接口如何调用以及最基本的功能。
- TRTCScenesDemo：较复杂的场景案例，结合了 TRTC 和 IM 两个 SDK ，所实现的交互也更接近真实产品。

```
├─ TRTCScenesDemo // TRTC场景化Demo，包括视频通话、语音通话、视频互动直播、语音聊天室
|  │─ Podfile                    //Pod描述文件
|  │─ TXLiteAVDemo
|  │    ├─ App                   // 程序入口界面
|  │    ├─ AudioSettingKit       // 音效面板，包含BGM播放，变声，混响，变调等效果
|  │    ├─ BeautySettingKit      // 美颜面板，包含美颜，滤镜，动效等效果
|  │    ├─ Debug                 // 包含 GenerateTestUserSig，用于本地生成测试用的 UserSig
|  │    ├─ Login                 // 一个演示性质的简单登录界面
|  │    ├─ TRTCMeetingDemo       // 场景一：多人会议，类似腾讯会议，包含屏幕分享
|  │    ├─ TRTCVoiceRoomDemo     // 场景二：语音聊天室，也叫语聊房，多人音频聊天场景
|  │    ├─ TRTCLiveRoomDemo      // 场景三：互动直播，包含连麦、PK、聊天、点赞等特性
|  │    ├─ TRTCAudioCallDemo     // 场景四：音频通话，展示双人音频通话，有离线通知能力
|  │    ├─ TRTCVideoCallDemo     // 场景五：视频通话，展示双人视频通话，有离线通知能力
|  
├─ TRTCSimpleDemo // TRTC精简化Demo，包含通话模式和直播模式。
|  ├─ Live                       // 演示 TRTC 以直播模式运行的示例代码，该模式下有角色的概念
|  ├─ RTC                        // 演示 TRTC 以通话模式运行的示例代码，该模式下无角色的概念
|  ├─ Screen                     // 演示 TRTC 如何进行屏幕分享的示例代码
|  ├─ Debug                      // 包含 GenerateTestUserSig，用于本地生成测试用的 UserSig  
|
├─ SDK 
│  ├─ TXLiteAVSDK_TRTC.framework          // 如果您下载的是精简版 zip 包，解压后将出现此文件夹
|  ├─ TXLiteAVSDK_Professional.framework  // 如果您下载的是专业版 zip 包，解压后将出现此文件夹
|  ├─ TXLiteAVSDK_Enterprise.framework    // 如果您下载的是企业版 zip 包，解压后将出现此文件夹
```

## SDK 分类和下载

腾讯云 TRTC SDK 基于 LiteAVSDK 统一框架设计和实现，该框架包含直播、点播、短视频、RTC、AI美颜在内的多项功能：
- 如果您追求最小化体积增量，可以下载 TRTC 精简版：[TXLiteAVSDK_TRTC.framework](https://cloud.tencent.com/document/product/647/32689#TRTC)
- 如果您需要使用多个功能而不希望打包多个 SDK，可以下载专业版：[TXLiteAVSDK_Professional.framework](https://cloud.tencent.com/document/product/647/32689#Professional)
- 如果您已经通过腾讯云商务购买了 AI 美颜 License，可以下载企业版：[TXLiteAVSDK_Enterprise.framework](https://cloud.tencent.com/document/product/647/32689#Enterprise)

## 相关文档链接

- [SDK 的版本更新历史](https://github.com/tencentyun/TRTCSDK/releases)
- [SDK 的 API 文档](http://doc.qcloudtrtc.com/md_introduction_trtc_iOS_mac_%E6%A6%82%E8%A7%88.html)
- [SDK 的官方体验 App](https://cloud.tencent.com/document/product/647/17021)
- [场景方案：互动直播](https://cloud.tencent.com/document/product/647/43181)
- [场景方案：视频通话](https://cloud.tencent.com/document/product/647/42044)
- [场景方案：语音通话](https://cloud.tencent.com/document/product/647/42046)
