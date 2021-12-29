<p align="center">
  <a href="https://cloud.tencent.com/document/product/647">
    <img width="200" src="https://web.sdk.qcloud.com/trtc/webrtc/assets/trtc-logo.png">
  </a>
</p>

<h1 align="center">TRTC Web SDK</h1>

<div align="center">

一款面向对象的 WebRTC SDK。

[![NPM version](https://img.shields.io/npm/v/trtc-js-sdk)](https://www.npmjs.com/package/trtc-js-sdk) [![NPM downloads](https://img.shields.io/npm/dw/trtc-js-sdk)](https://www.npmjs.com/package/trtc-js-sdk) [![trtc.js](https://img.shields.io/bundlephobia/min/trtc-js-sdk)](https://www.npmjs.com/package/trtc-js-sdk) [![Documents](https://img.shields.io/badge/-Documents-blue)](https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/index.html) [![Stars](https://img.shields.io/github/stars/tencentyun/TRTCSDK?style=social)](https://github.com/tencentyun/TRTCSDK) 

</div>

简体中文 | [English](./README.md)
## 简介

[TRTC Web SDK](https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/index.html) 是腾讯云实时音视频通讯解决方案的 Web 端 SDK，它是通过 HTML 网页加载的 JavaScript 库。开发者可以使用 TRTC Web SDK 提供的 API 建立连接，控制实时音视频通话或者直播服务。

- [在线 Demo](https://web.sdk.qcloud.com/trtc/webrtc/demo/api-sample/basic-rtc.html)

## 环境支持

TRTC Web SDK 支持市面上主流浏览器，详情参考：[浏览器支持情况](https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/tutorial-05-info-browser.html)。

| [<img src="https://web.sdk.qcloud.com/trtc/webrtc/assets/logo/chrome_48x48.png" alt="Chrome" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Chrome | [<img src="https://web.sdk.qcloud.com/trtc/webrtc/assets/logo/edge_48x48.png" alt="IE / Edge" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/> Edge | [<img src="https://web.sdk.qcloud.com/trtc/webrtc/assets/logo/firefox_48x48.png" alt="Firefox" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Firefox | [<img src="https://web.sdk.qcloud.com/trtc/webrtc/assets/logo/safari_48x48.png" alt="Safari" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Safari | [<img src="https://web.sdk.qcloud.com/trtc/webrtc/assets/logo/safari-ios_48x48.png" alt="iOS Safari" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>iOS Safari | [<img src="https://web.sdk.qcloud.com/trtc/webrtc/assets/logo/opera_48x48.png" alt="Opera" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Opera |
| --------- | --------- | --------- | --------- | --------- | --------- |
| 56+ | 80+ | 56+ | 11+ | 11+ | 46+ |

## 安装

使用 npm:
```
$ npm install trtc-js-sdk --save
```

使用 yarn:
```
$ yarn add trtc-js-sdk
```

手动下载 sdk 包：

1. 下载 [webrtc_latest.zip](https://web.sdk.qcloud.com/trtc/webrtc/download/webrtc_latest.zip)。
2. 将 `base-js/js/trtc.js` 复制到您的项目中。

## 使用

参考下述两个教程，可快速跑通 Demo 及了解如何使用 SDK 实现基础音视频通话功能。

- [快速跑通 Demo](https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/tutorial-10-basic-get-started-with-demo.html)
- [基础音视频通话](https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/tutorial-11-basic-video-call.html)

## API 概要

详细 API 文档可参考：[TRTC Web SDK API 文档](https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/index.html)

- [TRTC]((https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/TRTC.html)) 是整个 SDK 的主入口，提供创建客户端对象 Client 和创建本地流对象 LocalStream 的方法，以及浏览器兼容性检测，日志等级及日志上传控制。
- [Client]((https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/Client.html)) 客户端对象，提供实时音视频通话的核心能力，包括进房 [join()](https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/Client.html#join) 及退房 [leave()](https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/Client.html#leave)，发布本地流 [publish()](https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/Client.html#publish) 及停止发布本地流 [unpublish()](https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/Client.html#unpublish)，订阅远端流 [subscribe()](https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/Client.html#subscribe) 及取消订阅远端流 [unsubscribe()](https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/Client.html#unsubscribe)。
- [Stream](https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/Stream.html) 音视频流对象，包括本地流 [LocalStream](https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/LocalStream.html) 和远端流 [RemoteStream](https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/RemoteStream.html) 对象。Stream 对象中的方法为本地流及远端流通用方法。
  - 本地流 LocalStream 通过 [TRTC.createStream](https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/TRTC.html#.createStream) 创建，
  - 远端流 RemoteStream 通过监听 [Client.on('stream-added')](https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/module-ClientEvent.html#.STREAM_ADDED) 事件获得。

## 目录结构

```
├── README.md
├── package.json
├── trtc.js // npm 包入口文件
├── trtc.esm.js // 基于 es 模块的 sdk 包（自 4.11.7+ 版本支持）
└── trtc.umd.js // 基于 umd 模块的 sdk 包（自 4.11.7+ 版本支持）
```

## 模块说明

**trtc.js**

npm 包入口文件，umd 模块类型，包含 ES6 语法，以及所有依赖包。使用方法：
- 在项目工程安装包后，通过 `import TRTC from 'trtc-js-sdk'`;  引入该文件。
- 也可以通过 `<script src="[完整路径]/trtc.js"></scirpt>` 加载使用。

**trtc.esm.js**

ES Modules 类型，包含 ES6 语法，以及所有依赖包。体积小，不支持 ES6 的浏览器无法使用。可参考 [ES6 兼容性](https://caniuse.com/?search=ES6)。

> 自 4.11.7+ 版本提供该 sdk 文件。

使用方法：
- 在项目工程安装包后，通过 `import TRTC from 'trtc-js-sdk/trtc.esm.js'`;  引入该文件。

**trtc.umd.js**

umd 模块类型，ES5 语法，体积大，但兼容性更好。

> 自 4.11.7+ 版本提供该 sdk 文件。

使用方法：

- 在项目工程安装包后，通过 `import TRTC from 'trtc-js-sdk/trtc.umd.js'`;  引入该文件。
- 也可以通过 `<script src="[完整路径]/trtc.umd.js"></scirpt>` 加载使用。


## Changelog

- [变更日志](https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/tutorial-01-info-changelog.html)
