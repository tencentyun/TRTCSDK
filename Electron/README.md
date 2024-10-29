## TRTC Electron SDK
_English | [简体中文](README-zh_CN.md)_

The TRTC Electron SDK provides real-time communication and live streaming capabilities. Leveraging Tencent's over 20 years of experience in network and audio/video technologies, Tencent Real-Time Communication (TRTC) offers solutions for group audio/video calls and low-latency interactive live streaming. With TRTC, you can quickly develop cost-effective, low-latency, and high-quality interactive audio/video services.
For more information about TRTC, see [TRTC](https://intl.cloud.tencent.com/products/trtc).

## Directory Structure
This directory contains the source code of two demo applications of the TRTC Electron SDK: `TRTC-API-Examples` and `TRTCSimpleDemo`.

-   TRTC-API-Examples: Demonstrates the common use cases of [TRTC APIs for Electron](https://web.sdk.qcloud.com/trtc/electron/doc/en-us/trtc_electron_sdk/index.html) to help you understand API features and quickly connect them to your existing project. It supports in-app encoding and execution.
-   TRTCSimpleDemo: The simplest sample code to demonstrate how to call TRTC APIs and use the most basic audio/video features.

```
├─ TRTC-API-Examples
├── src
│   ├── app
│   │    ├── main                  // Main process running code
│   │    ├── render                // Main window running code of the renderer process
├── assets
│   ├── app-icon
│   ├── code                       // Sample code
│   │    ├── basic                 // Sample code for basic features
│   │    ├── advanced              // Sample code for advanced features
│   ├── debug                      // Contains `GenerateTestUserSig` to generate a testing `UserSig` locally
├── main.js                        // Electron main process entry file
├── preload.js                     // Electron window preload script
├── package.json                   // Project configuration
├── package-lock.json
|
├─ TRTCSimpleDemo                  // TRTC Lite Edition demo containing the sample code of call and live streaming modes.
│  ├── main.electron.js             // Main Electron file
│  ├── package.json                 // Project configuration
│  ├── vue.config.js                // Vue CLI project file
│  ├── src                          // Source code directory
│  │  ├── pages                     
│  │  │  ├── trtc                   // The Demo for call mode in TRTC. In this mode, there is no concept of role
│  │  │  ├── live                   // The Demo for live streaming mode in TRTC. In this mode, there is a concept of role
│  │  ├── debug                     // Contains `GenerateTestUserSig` to generate a testing `UserSig` locally
```

## Demo Download

TRTC demo for Electron is designed and implemented based on the TRTC SDK and contains various features, including real-time communication, low-latency live streaming, screen sharing, and beauty filters. You can download the demo files in [Free Demo](https://intl.cloud.tencent.com/document/product/647/35076).

## Documentation

- [TRTC SDK API documentation](https://web.sdk.qcloud.com/trtc/electron/doc/en-us/trtc_electron_sdk/index.html)
- [TRTC SDK demo app](https://intl.cloud.tencent.com/document/product/647/35076)

