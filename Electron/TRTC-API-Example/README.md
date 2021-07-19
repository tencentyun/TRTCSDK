# TRTC API-Example

## 前言
TRTC Electron API Examples 展示了 [TRTC Electron API](https://web.sdk.qcloud.com/trtc/electron/doc/zh-cn/trtc_electron_sdk/index.html) 的使用场景，方便客户了解 API 接口功能并快速接入到现有工程中。

## 目录结构
```
├── README.md
├── .husky    -- commit 钩子
├── .eslintignore
├── .eslintrc.js
├── .editorconfig
├── main.js   -- electron 主进程入口文件
├── preload.js  -- electron 主窗口预加载脚本
├── package.json
├── package-lock.json
├── assets
│   ├── app-icon
│   ├── code  -- 对应 example 示例代码
│   │    ├── advanced -- 高级示例
│   │    ├── basic -- 基础示例
└── src
│   ├── app
│   │    ├── main   -- 主进程运行代码
│   │    ├── render -- 渲染进程主窗口运行代码
```

## 结构说明
在这个示例项目中包含了以下场景:（带上对应的跳转目录，方便用户快速浏览感兴趣的功能）

- 基础功能
  - [视频通话](./assets/code/basic/video-call/index.js)
  - [语音通话](./assets/code/basic/audio-call/index.js)
  - [屏幕分享](./assets/code/basic/screen-share/index.js)
  - [视频互动直播](./assets/code/basic/video-live/index.js)
  - [语音互动直播](./assets/code/basic/audio-call/index.js)
  - [设备检测](./assets/code/basic/device-test/index.js)
- 进阶功能
  - [画质设定](./assets/code/advanced/video-quality/index.js)
  - [混流功能](./assets/code/advanced/video-stream-mix/index.js)
  - [大小画面](./assets/code/advanced/big-small-stream/index.js)
  - [渲染控制](./assets/code/advanced/video-render-params/index.js)
  - [内置美颜](./assets/code/advanced/beauty-sdk-inner/index.js)
  - [跨房连麦](./assets/code/advanced/connect-other-room/index.js)
  - [切换角色](./assets/code/advanced/switch-role/index.js)
  - [通话统计](./assets/code/advanced/call-statistics/index.js)
  - [音量控制](./assets/code/advanced/volume-control/index.js)

## 前提条件
您已 [注册腾讯云](https://cloud.tencent.com/document/product/378/17985) 账号，并完成 [实名认证](https://cloud.tencent.com/document/product/378/3629)。

## 操作步骤
### 步骤1：创建新的应用
1. 登录实时音视频控制台，选择【开发辅助】>【[快速跑通Demo](https://console.cloud.tencent.com/trtc/quickstart)】。
2. 单击【立即开始】，输入应用名称，例如`TestTRTC`，单击【创建应用】。

### 步骤2：配置 API Examples 工程文件
1. 找到并打开`assets/debug/gen-test-user-sig.js`文件。
2. 设置`gen-test-user-sig.js`文件中的相关参数：
  <ul><li>SDKAPPID：默认为0，请设置为实际的 SDKAppID。</li>
  <li>SECRETKEY：默认为空字符串，请设置为实际的密钥信息。</li></ul>
3. 返回实时音视频控制台，单击【粘贴完成，下一步】。
4. 单击【关闭指引，进入控制台管理应用】。
5. 设置 `preload.js` 文件中 window.globalUserId 和 window.globalRoomId, 可在所有 API Examples 生效 。

> ⚠️注意：
> 本文提到的生成 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通 Demo 和功能调试**。
>
> 正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。

### 步骤3：运行 API Examples
> ⚠️注意：
> 1. 建议 node 环境为 v14.16.0

#### 1. 安装依赖
```bash
npm install
cd src/app/render/main-page
npm install
```

#### 2. 开发环境运行
```bash
npm run start
```

#### 3. 生产环境打包
win
```bash
npm run package:win
```

mac
```bash
npm run package:mac
```

## 常见问题

### 1. 查看密钥时只能获取公钥和私钥信息，要如何获取密钥？
TRTC SDK 6.6 版本（2019年08月）开始启用新的签名算法 HMAC-SHA256。在此之前已创建的应用，需要先升级签名算法才能获取新的加密密钥。如不升级，您也可以继续使用 [老版本算法 ECDSA-SHA256](https://cloud.tencent.com/document/product/647/17275#.E8.80.81.E7.89.88.E6.9C.AC.E7.AE.97.E6.B3.95)。

升级操作：
1. 登录 [实时音视频控制台](https://console.cloud.tencent.com/trtc)。
2. 在左侧导航栏选择【应用管理】，单击目标应用所在行的【应用信息】。
3. 选择【快速上手】页签，单击【第二步 获取签发UserSig的密钥】区域的【点此升级】。

### 2. 终端出现提示“Electron failed to install correctly”
可参考 [Electron 常见问题收录](https://cloud.tencent.com/developer/article/1616668) 对 Electron 进行手动安装
