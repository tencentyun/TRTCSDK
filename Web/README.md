<p align="center">
  <a href="https://intl.cloud.tencent.com/products/trtc">
    <img width="200" src="https://web.sdk.qcloud.com/trtc/webrtc/assets/trtc-logo.png">
  </a>
</p>

<h1 align="center">TRTC Web SDK</h1>

<div align="center">

An object-oriented WebRTC SDK library  

[![NPM version](https://img.shields.io/npm/v/trtc-js-sdk)](https://www.npmjs.com/package/trtc-js-sdk) [![NPM downloads](https://img.shields.io/npm/dw/trtc-js-sdk)](https://www.npmjs.com/package/trtc-js-sdk) [![trtc.js](https://img.shields.io/bundlephobia/min/trtc-js-sdk)](https://www.npmjs.com/package/trtc-js-sdk) [![Documents](https://img.shields.io/badge/-Documents-blue)](https://web.sdk.qcloud.com/trtc/webrtc/doc/en/index.html) [![Stars](https://img.shields.io/github/stars/tencentyun/TRTCSDK?style=social)](https://github.com/tencentyun/TRTCSDK) 

</div>

English | [简体中文](./README-zh_CN.md)

## Introduction

TRTC Web SDK is an object-oriented WebRTC SDK of Tencent Cloud's real-time communication solution. Web developers can use TRTC Web SDK to establish an audio/video calls or live streaming services on your website.

- [Online Demo](https://web.sdk.qcloud.com/trtc/webrtc/demo/api-sample/basic-rtc.html?lang=en)

## Environment Supports

TRTC Web SDK supports major modern browsers. For details, please refer to [Browsers Supported](https://web.sdk.qcloud.com/trtc/webrtc/doc/en/tutorial-05-info-browser.html).

| [<img src="https://web.sdk.qcloud.com/trtc/webrtc/assets/logo/chrome_48x48.png" alt="Chrome" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Chrome | [<img src="https://web.sdk.qcloud.com/trtc/webrtc/assets/logo/edge_48x48.png" alt="IE / Edge" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/> Edge | [<img src="https://web.sdk.qcloud.com/trtc/webrtc/assets/logo/firefox_48x48.png" alt="Firefox" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Firefox | [<img src="https://web.sdk.qcloud.com/trtc/webrtc/assets/logo/safari_48x48.png" alt="Safari" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Safari | [<img src="https://web.sdk.qcloud.com/trtc/webrtc/assets/logo/safari-ios_48x48.png" alt="iOS Safari" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>iOS Safari | [<img src="https://web.sdk.qcloud.com/trtc/webrtc/assets/logo/opera_48x48.png" alt="Opera" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Opera |
| --------- | --------- | --------- | --------- | --------- | --------- |
| 56+ | 80+ | 56+ | 11+ | 11+ | 46+ |

## Install

npm:
```
$ npm install trtc-js-sdk --save
```

yarn:
```
$ yarn add trtc-js-sdk
```

Download manually：

1. download [webrtc_latest.zip](https://web.sdk.qcloud.com/trtc/webrtc/download/webrtc_latest.zip).
2. copy `base-js/js/trtc.js` to your project.

## Usage

Refer to the following two tutorials for a quick run-through of the demo and how to use the SDK to implement basic audio and video calling functionality.

- [Demo Quick Run](https://web.sdk.qcloud.com/trtc/webrtc/doc/en/tutorial-10-basic-get-started-with-demo.html)
- [Basic Audio/Video Call](https://web.sdk.qcloud.com/trtc/webrtc/doc/en/tutorial-11-basic-video-call.html)

Explore SDK documents：[TRTC Web SDK](https://web.sdk.qcloud.com/trtc/webrtc/doc/en/index.html)

## API Overview

- [TRTC](https://web.sdk.qcloud.com/trtc/webrtc/doc/en/TRTC.html) is the main entry to the entire TRTC SDK. You can use TRTC APIs to create a client object ([Client](https://web.sdk.qcloud.com/trtc/webrtc/doc/en/Client.html)) and local stream object (LocalStream), check a browser's compatibility, set log levels, and upload logs.
- A client object [Client](https://web.sdk.qcloud.com/trtc/webrtc/doc/en/Client.html) provides the core TRTC call capabilities, including entering a room [join()](https://web.sdk.qcloud.com/trtc/webrtc/doc/en/Client.html#join), leaving a room [leave()](https://web.sdk.qcloud.com/trtc/webrtc/doc/en/Client.html#leave), publishing a local stream [publish()](https://web.sdk.qcloud.com/trtc/webrtc/doc/en/Client.html#publish), unpublishing a local stream [unpublish()](https://web.sdk.qcloud.com/trtc/webrtc/doc/en/Client.html#unpublish), subscribing to a remote stream [subscribe()](https://web.sdk.qcloud.com/trtc/webrtc/doc/en/Client.html#subscribe), and unsubscribing from a remote stream [unsubscribe()](https://web.sdk.qcloud.com/trtc/webrtc/doc/en/Client.html#unsubscribe).
- Audio/video objects [Stream](https://web.sdk.qcloud.com/trtc/webrtc/doc/en/Stream.html) include local stream LocalStream and remote stream RemoteStream objects. The APIs in Stream are general APIs for the local and remote streams.
  - Local streams [LocalStream](https://web.sdk.qcloud.com/trtc/webrtc/doc/en/LocalStream.html) are created via [TRTC.createStream()](https://web.sdk.qcloud.com/trtc/webrtc/doc/en/TRTC.html#.createStream).
  - Remove streams [RemoteStream](https://web.sdk.qcloud.com/trtc/webrtc/doc/en/RemoteStream.html) are obtained through listening for 'stream-added' events from [Client.on()](https://web.sdk.qcloud.com/trtc/webrtc/doc/en/Client.html#on).

## Directory

```
├── README.md
├── package.json
├── trtc.js // sdk file
├── trtc.esm.js // sdk file base on ES modules(support v4.11.7+)
└── trtc.umd.js // sdk file base on UMD modules(support v4.11.7+)
```

## Difference between sdk files

**trtc.js**

Default entry file, base on UMD modules, ES6 included. 

Usage:
- `import TRTC from 'trtc-js-sdk'`
- or `<script src="[path]/trtc.js"></scirpt>`

**trtc.esm.js**

ES6 included, base on ES Modules. Smaller file size, not usable by browsers that do not support ES6. Refer to: [Compatibility of ES6](https://caniuse.com/?search=ES6).

> support v4.11.7+

Usage: 
- `import TRTC from 'trtc-js-sdk/trtc.esm.js'`

**trtc.umd.js**

ES5 included(without ES6 syntax). Larger file size, but better compatibility.

> support v4.11.7+

Usage：

- `import TRTC from 'trtc-js-sdk/trtc.umd.js'`
- or `<script src="[path]/trtc.umd.js"></scirpt>`


## Changelog

- [Changelog](https://web.sdk.qcloud.com/trtc/webrtc/doc/en/tutorial-01-info-changelog.html)
