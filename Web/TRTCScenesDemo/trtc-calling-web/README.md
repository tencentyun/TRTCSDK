本文主要介绍如何快速跑通 Web 版本的 TRTCCalling Demo，Demo 中包括语音通话和视频通话场景：

\- 语音通话：纯语音交互，支持多人互动语音聊天。

\- 视频通话：视频通话，面向在线客服等需要面对面交流的沟通场景。

### 环境要求
* 请使用最新版本的 Chrome 浏览器。
* TRTCCalling 依赖以下端口进行数据传输，请将其加入防火墙白名单，配置完成后，您可以通过访问并体验 [官网 Demo](https://web.sdk.qcloud.com/component/trtccalling/demo/web/latest/index.html) 检查配置是否生效。
  - TCP 端口：8687
  - UDP 端口：8000，8080，8800，843，443，16285
  - 域名：qcloud.rtc.qq.com

> 
>- 一般情况下体验 Demo 需要部署至服务器，通过 https://域名/xxx 访问，或者直接在本地搭建服务器，通过 localhost:端口访问。
>- 目前桌面端 Chrome 浏览器支持 TRTC 桌面浏览器 SDK 的相关特性比较完整，因此建议使用 Chrome 浏览器进行体验。

### 前提条件

您已 [注册腾讯云](https://cloud.tencent.com/document/product/378/17985) 账号，并完成 [实名认证](https://cloud.tencent.com/document/product/378/3629)。

### 复用 Demo 的 UI 界面

<span id="step1"></span>

#### 步骤1：创建新的应用

1. 登录实时音视频控制台，选择【开发辅助】>【[快速跑通Demo](https://console.cloud.tencent.com/trtc/quickstart)】。

2. 单击【立即开始】，输入应用名称，例如`TestTRTC`，单击【创建应用】。

<span id="step2"></span>

#### 步骤2：下载 SDK 和 Demo 源码
2. 鼠标移动至对应卡片，单击【[Github](https://github.com/tencentyun/TRTCSDK/tree/master/Web/TRTCScenesDemo/trtc-calling-web)】跳转至 Github（或单击【[ZIP](https://web.sdk.qcloud.com/trtc/webrtc/download/webrtc_latest.zip)】），下载相关 SDK 及配套的 Demo 源码。
 ![](https://main.qcloudimg.com/raw/0f35fe3bafe9fcdbd7cc73f991984d1a.png)
2. 下载完成后，返回实时音视频控制台，单击【我已下载，下一步】，可以查看 SDKAppID 和密钥信息。

<span id="step3"></span>

#### 步骤3：配置 Demo 工程文件

1. 解压 [步骤2](#step2) 中下载的源码包。

2. 找到并打开`Web/TRTCScenesDemo/TRTCCalling/public/debug/GenerateTestUserSig.js`文件。

3. 设置`GenerateTestUserSig.js`文件中的相关参数：

  <ul><li>SDKAPPID：默认为0，请设置为实际的 SDKAppID。</li>

  <li>SECRETKEY：默认为空字符串，请设置为实际的密钥信息。</li></ul> 

  <img src="https://main.qcloudimg.com/raw/0ae7a197ad22784384f1b6e111eabb22.png">

4. 返回实时音视频控制台，单击【粘贴完成，下一步】。

5. 单击【关闭指引，进入控制台管理应用】。

>本文提到的生成 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此****该方法仅适合本地跑通 Demo 和功能调试****。

>正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。

#### 步骤4：运行 Demo
>- 同步依赖： npm install
>- 启动项目： npm run serve
>- 浏览器中打开链接：http://localhost:8080/

- Demo 运行界面如图所示：
![](https://main.qcloudimg.com/raw/90118deded971621db7bb14b55073bcc.png)
- 输入用户 userid，点击【登录】
![](https://main.qcloudimg.com/raw/f430fb067cddbb52ba32e4d0660cd331.png)
- 输入呼叫用户 userid，即可视频通话
![](https://main.qcloudimg.com/raw/66562b4c14690de4eb6f2da58ee6f4df.png)
- 视频通话
![](https://main.qcloudimg.com/raw/592189d0f18c91c51cdf7184853c6437.png)


### 实现自定义 UI 界面
#### 步骤1：集成 SDK
NPM 集成
> 从v0.6.0起，需要手动安装依赖 [trtc-js-sdk](https://www.npmjs.com/package/trtc-js-sdk) 和 [tim-js-sdk](https://www.npmjs.com/package/tim-js-sdk) 以及 [tsignaling](https://www.npmjs.com/package/tsignaling)
>- 为了减小 trtc-calling-js.js 的体积，避免和接入侧已使用的 trtc-js-sdk 和 tim-js-sdk 以及 tsignaling 发生版本冲突，trtc-js-sdk 和 tim-js-sdk 以及 tsignaling 不再被打包到 trtc-calling-js.js，在使用前您需要手动安装依赖。
```javascript
  npm i trtc-js-sdk --save
  npm i tim-js-sdk --save
  npm i tsignaling --save
  npm i trtc-calling-js --save
 
  // 如果您通过 script 方式使用 trtc-calling-js，需要按顺序先手动引入 trtc.js
  <script src="./trtc.js"></script>
  
  // 接着手动引入 tim-js.js
  <script src="./tim-js.js"></script>
  
  // 然后再手动引入 tsignaling.js
  <script src="./tsignaling.js"></script>

  // 最后再手动引入 trtc-calling-js.js
  <script src="./trtc-calling-js.js"></script>
```
在项目脚本里引入模块
```javascript
import TrtcCalling from 'trtc-calling-js';
```
#### 步骤2：创建 trtcCalling 对象
>- sdkAppID: 您从腾讯云申请的 sdkAppID
```javascript
let options = {
  SDKAppID: 0 // 接入时需要将0替换为您的云通信应用的 SDKAppID
};
const trtcCalling = new TRTCCalling(options);
```

#### 步骤3：登录
>- userID: 用户 ID
>- userSig: 用户签名，计算方式参见[如何计算 userSig](https://cloud.tencent.com/document/product/647/17275)
```javascript
trtcCalling.login({
  userID,
  userSig
});
```

#### 步骤4：实现 1v1 通话
>#### 拨打：
>- userID: 用户 ID
>- type: 通话类型，0-未知， 1-语音通话，2-视频通话
>- timeout: 邀请超时, 单位 s(秒)
```javascript
trtcCalling.call({
  userID,
  type: 2,
  timeout
});
```
>#### 接听
>- inviteID: 邀请 ID, 标识一次邀请
>- roomID: 通话房间号 ID
>- callType: 0-未知， 1-语音通话，2-视频通话
```javascript
trtcCalling.accept({
  inviteID,
  roomID,
  callType
});
```
>#### 打开本地摄像头
```javascript
trtcCalling.openCamera()
```
>#### 展示远端画面
>- userID: 远端用户 ID
>- videoViewDomID: 该用户数据将渲染到该 DOM ID 节点里
```javascript
trtcCalling.startRemoteView({
  userID,
  videoViewDomID
})
```

>#### 展示本地画面
>- userID: 本地用户 ID
>- videoViewDomID: 该用户数据将渲染到该 DOM ID 节点里
```javascript
trtcCalling.startLocalView({
  userID,
  videoViewDomID
})
```

>#### 挂断/拒接
```javascript
trtcCalling.hangup()
```
>- inviteID: 邀请 id，标识一次邀请
>- isBusy: 是否是忙线中， 0-未知， 1-语音通话，2-视频通话
```javascript
trtcCalling.reject({ 
  inviteID,
  isBusy
  })
```

### 支持的平台

| 操作系统 |      浏览器类型      | 浏览器最低版本要求 |
| :------: | :------------------: | :----------------: |
|  Mac OS  | 桌面版 Safari 浏览器 |        11+         |
|  Mac OS  | 桌面版 Chrome 浏览器 |        56+         |
| Windows  | 桌面版 Chrome 浏览器 |        56+         |
| Windows  |   桌面版 QQ 浏览器   |        10.4        |

### 常见问题

#### 1. 查看密钥时只能获取公钥和私钥信息，该如何获取密钥？
TRTC SDK 6.6 版本（2019年08月）开始启用新的签名算法 HMAC-SHA256。在此之前已创建的应用，需要先升级签名算法才能获取新的加密密钥。如不升级，您也可以继续使用 老版本算法 ECDSA-SHA256，如已升级，您按需切换为新旧算法。

升级/切换操作：

1. 登录 实时音视频控制台。

2. 在左侧导航栏选择【应用管理】，单击目标应用所在行的【应用信息】。

3. 选择【快速上手】页签，单击【第二步 获取签发 UserSig 的密钥】区域的【点此升级】、【非对称式加密】或【HMAC-SHA256】。

- 升级：

   ![](https://main.qcloudimg.com/raw/69bd0957c99e6a6764368d7f13c6a257.png)

- 切换回老版本算法 ECDSA-SHA256：

   ![](https://main.qcloudimg.com/raw/f89c00f4a98f3493ecc1fe89bea02230.png)

- 切换为新版本算法 HMAC-SHA256：

   ![](https://main.qcloudimg.com/raw/b0412153935704abc9e286868ad8a916.png)

#### 2. 防火墙有什么限制？

由于 SDK 使用 UDP 协议进行音视频传输，所以对 UDP 有拦截的办公网络下无法使用，如遇到类似问题，请参考文档：[应对公司防火墙限制](https://cloud.tencent.com/document/product/647/34399)。
