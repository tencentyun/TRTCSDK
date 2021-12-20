## 目录结构说明

本目录包含 Android 版 TRTC-API-Example 的源代码，最简单的示例代码，使用Objective-C语言。包括视频通话、语音通话等基础功能以及一些高级功能。- TRTC-API-Example-OC： 

```
├─ TRTC-API-Example // TRTC API Example，包括视频通话、语音通话的基础功能以及一些高级功能
|  ├─ AudioCall             // 演示 TRTC 音频通话的示例代码
|  ├─ VideoCall             // 演示 TRTC 视频通话的示例代码
|  ├─ Live                  // 演示 TRTC 视频互动直播的示例代码
|  ├─ VoiceChatRoom         // 演示 TRTC 语音互动直播的示例代码
|  ├─ ScreenShare           // 演示 TRTC 录屏直播的示例代码
|  ├─ Advanced              // 演示 TRTC 高级功能示例代码
|  |  ├─ StringRoomId              // 演示 TRTC 字符串房间号示例代码
|  |  ├─ SetVideoQuality           // 演示 TRTC 画质设定示例代码
|  |  ├─ SetAudioQuality           // 演示 TRTC 音质设定示例代码
|  |  ├─ SetRenderParams           // 演示 TRTC 渲染控制示例代码
|  |  ├─ SpeedTest                 // 演示 TRTC 网络测速示例代码
|  |  ├─ PushCDN                   // 演示 TRTC CDN发布示例代码
|  |  ├─ CustomCamera              // 演示 TRTC 自定义视频采集&amp;渲染发布示例代码
|  |  ├─ SetAudioEffect            // 演示 TRTC 设置音效示例代码
|  |  ├─ SetBackgroundMusic        // 演示 TRTC 设置背景音乐示例代码
|  |  ├─ LocalVideoShare           // 演示 TRTC 本地视频文件分享示例代码
|  |  ├─ LocalRecord               // 演示 TRTC 本地视频录制示例代码
|  |  ├─ JoinMultipleRoom          // 演示 TRTC 加入多个房间示例代码
|  |  ├─ SEIMessage                // 演示 TRTC 收发SEI消息示例代码
|  |  ├─ SwitchRoom                // 演示 TRTC 快速切换房间示例代码
|  |  ├─ RoomPk                    // 演示 TRTC 跨房PK示例代码
|  |  ├─ ThirdBeauty               // 演示 TRTC 第三方美颜示例代码
|  
├─ SDK 
|  ├─ TXLiteAVSDK_TRTC.framework          // 如果您下载的是精简版 zip 包，解压后将出现此文件夹
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
- [SDK 的 API 文档](https://liteav.sdk.qcloud.com/doc/api/zh-cn/md_introduction_trtc_iOS_mac_%E6%A6%82%E8%A7%88.html)
- [SDK 的官方体验 App](https://cloud.tencent.com/document/product/647/17021)
- [场景方案：互动直播](https://cloud.tencent.com/document/product/647/43181)
- [场景方案：视频通话](https://cloud.tencent.com/document/product/647/42044)
- [场景方案：语音通话](https://cloud.tencent.com/document/product/647/42046)

## 各场景化源码链接
- [实时视频/语音通话](https://github.com/tencentyun/TUICalling/)
- [视频互动直播](https://github.com/tencentyun/TUILiveRoom/)
- [多人视频会议](https://github.com/tencentyun/TUIMeeting/)
- [语音聊天室](https://github.com/tencentyun/TUIVoiceRoom/)
- [语音沙龙](https://github.com/tencentyun/TUIChatSalon/)