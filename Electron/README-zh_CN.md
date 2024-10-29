## 实时音视频（TRTC）Electron 版 SDK

_[English](README.md) | 简体中文_

实时音视频（TRTC）Electron 版 SDK 包含实时音视频和直播能力。腾讯实时音视频（Tencent Real-Time Communication，TRTC）将腾讯20多年来在网络与音视频技术上的深度积累，以多人音视频通话和低延时互动直播两大场景化方案，通过腾讯云服务向开发者开放，致力于帮助开发者快速搭建低成本、低延时、高品质的音视频互动解决方案。
实时音视频（TRTC）产品请参见：[实时音视频（TRTC）](https://cloud.tencent.com/product/trtc)

## 目录结构
本目录包含 Electron 版 TRTC SDK 的 Demo App 源代码，主要包括以下2个 Demo App: TRTC-API-Examples 和 TRTCSimpleDemo。

-   TRTC-API-Examples: 演示 [TRTC Electron API](https://web.sdk.qcloud.com/trtc/electron/doc/zh-cn/trtc_electron_sdk/index.html) 的常见使用场景，方便客户了解 API 接口功能并快速接入到现有工程中，支持应用内编码、执行。
-   TRTCSimpleDemo：最简单的示例代码，主要演示 TRTC 的接口如何调用，以及最基本的音视频功能。

```
├─ TRTC-API-Examples
├── src
│   ├── app
│   │    ├── main                  // 主进程运行代码
│   │    ├── render                // 渲染进程主窗口运行代码
├── assets
│   ├── app-icon
│   ├── code                       // 示例代码
│   │    ├── basic                 // 基础功能示例代码
│   │    ├── advanced              // 高级功能示例代码
│   ├── debug                      // 包含 GenerateTestUserSig，用于本地生成测试用的 UserSig
├── main.js                        // electron 主进程入口文件
├── preload.js                     // electron 窗口预加载脚本
├── package.json                   // 工程配置
├── package-lock.json
|
├─ TRTCSimpleDemo                  // TRTC精简版Demo，包含通话模式和直播模式示例代码
│  ├── main.electron.js             // Electron 主文件
│  ├── package.json                 // 工程配置
│  ├── vue.config.js                // vue-cli 工程文件
│  ├── src                          // 源代码目录
│  │  ├── pages                     
│  │  │  ├── trtc                   // 演示 TRTC 以通话模式运行的示例代码，该模式下无角色的概念
│  │  │  ├── live                   // 演示 TRTC 以直播模式运行的示例代码，该模式下有角色的概念
│  │  ├── debug                     // 包含 GenerateTestUserSig，用于本地生成测试用的 UserSig
```

## Demo 下载

Electron 版 TRTC Demo 基于 TRTCSDK 设计和实现，Demo 包含实时音视频通话、低延迟直播、屏幕分享、美颜在内的多项功能，请前往[SDK 下载页面](https://cloud.tencent.com/document/product/647/32689#TRTC)，下载 Electron 版 TRTC Demo 文件。

## 相关文档链接

- [SDK 的 API 文档](https://web.sdk.qcloud.com/trtc/electron/doc/zh-cn/trtc_electron_sdk/index.html)
- [SDK 的官方体验 App](https://cloud.tencent.com/document/product/647/17021)

