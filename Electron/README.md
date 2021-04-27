## 实时音视频（TRTC）版SDK
实时音视频（TRTC）版SDK包含实时音视频（TRTC）和直播播放的能力。腾讯实时音视频（Tencent Real-Time Communication，TRTC）将腾讯21年来在网络与音视频技术上的深度积累，以多人音视频通话和低延时互动直播两大场景化方案，通过腾讯云服务向开发者开放，致力于帮助开发者快速搭建低成本、低延时、高品质的音视频互动解决方案。
实时音视频（TRTC）产品请参见：[实时音视频（TRTC）](https://cloud.tencent.com/product/trtc)

## 目录结构
本目录包含 Electron 版 TRTC 的所有 Demo 源代码，被分成 TRTCSimpleDemo 和 TRTCScenesDemo 两个子目录：

-   TRTCSimpleDemo：最简单的示例代码，主要演示 TRTC 的接口如何调用，以及最基本的音视频功能。
-   TRTCScenesDemo：较复杂的场景案例，结合了 TRTC 和 IM 两个 SDK ，所实现的交互也更接近真实产品。
     - TRTCEducation Demo：实时互动课堂Demo，集成了语音、视频、屏幕分享等上课方式，还封装了老师开始问答、学生举手、老师邀请学生上台回答、结束回答等相关能力。

```
├─ TRTCScenceDemo                  // TRTC场景化Demo，包含实时互动课堂示例代码
|  ├─ TRTCEducation                // 实时互动课堂示例代码
|  |  |--app                       // 源代码文件
|  |  |  |--index.tsx              // 页面入口文件
|  |  |  |--Routes.tsx             // 路由配置文件
|  |  |  |--containers             // 进入教室、教室UI代码
|  |  |  |--components             // 教师端UI、学生端UI、聊天室、用户列表组件代码
|  |  |  |--debug                  // sdkAppId和密钥配置文件
|  |  |--package.json              // 工程配置
|  |  |--configs                   // webpack配置文件
|
├─ TRTCSimpleDemo                  // TRTC精简版Demo，包含通话模式和直播模式示例代码
|  |--main.electron.js             // Electron 主文件
|  |--package.json                 // 工程配置
|  |--vue.config.js                // vue-cli 工程文件
|  |--src                          // 源代码目录
|  |  |--pages                     
|  |  |  |--trtc                   // 演示 TRTC 以通话模式运行的示例代码，该模式下无角色的概念
|  |  |  |--live                   // 演示 TRTC 以直播模式运行的示例代码，该模式下有角色的概念
|  |  |--debug                     // 包含 GenerateTestUserSig，用于本地生成测试用的 UserSig 
```

## Demo 下载

Electron 版 TRTC Demo 基于 TRTCSDK 设计和实现，Demo 包含实时音视频通话、低延迟直播、屏幕分享、美颜在内的多项功能，请前往[SDK 下载页面](https://cloud.tencent.com/document/product/647/32689#TRTC)，下载 Electron 版 TRTC Demo 文件。

## 相关文档链接

- [SDK 的版本更新历史](https://github.com/tencentyun/TRTCSDK/releases)
- [SDK 的 API 文档](https://web.sdk.qcloud.com/trtc/electron/doc/zh-cn/trtc_electron_sdk/index.html)
- [SDK 的官方体验 App](https://cloud.tencent.com/document/product/647/17021)

