## 目录结构说明

本目录包含 Android 版 TRTC 的所有 Demo 源代码，被分成 TRTC-API-Example 和 TRTCScenesDemo 两个子目录：
- TRTC-API-Example： 最简单的示例代码，包括视频通话、语音通话的基础功能以及一些高级功能。
- TRTCScenesDemo： 较复杂的场景案例，结合了 TRTC 和 IM 两个 SDK ，所实现的交互也更接近真实产品。

```
├─ TRTC-API-Example // TRTC API Example，包括视频通话、语音通话的基础功能以及一些高级功能
|  ├─ Basic                 // 演示 TRTC 基础功能示例代码
|  |  ├─ AudioCall                 // 演示 TRTC 音频通话的示例代码
|  |  ├─ VideoCall                 // 演示 TRTC 视频通话的示例代码
|  |  ├─ Live                      // 演示 TRTC 视频互动直播的示例代码
|  |  ├─ VoiceChatRoom             // 演示 TRTC 语音互动直播的示例代码
|  |  ├─ ScreenShare               // 演示 TRTC 录屏直播的示例代码
|  ├─ Advanced              // 演示 TRTC 高级功能示例代码
|  |  ├─ StringRoomId              // 演示 TRTC 字符串房间号示例代码
|  |  ├─ SetVideoQuality           // 演示 TRTC 画质设定示例代码
|  |  ├─ SetAudioQuality           // 演示 TRTC 音质设定示例代码
|  |  ├─ SetRenderParams           // 演示 TRTC 渲染控制示例代码
|  |  ├─ SpeedTest                 // 演示 TRTC 网络测速示例代码
|  |  ├─ PushCDN                   // 演示 TRTC CDN发布示例代码
|  |  ├─ CustomCamera              // 演示 TRTC 自定义视频采集&渲染发布示例代码
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
├─ TRTCScenesDemo   // TRTC场景化Demo，包括视频通话、语音通话、视频互动直播、语音聊天室
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
