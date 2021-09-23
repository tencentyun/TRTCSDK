[WebRTC API Examples](https://web.sdk.qcloud.com/trtc/webrtc/demo/api-sample/index.html) 展示了 [WebRTC API 接口](https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/Client.html) 的使用场景，方便客户了解 API 接口功能并快速接入到现有工程中。

[WebRTC API Examples](https://web.sdk.qcloud.com/trtc/webrtc/demo/api-sample/index.html) 使用 [Next.js](https://www.nextjs.cn/) 进行开发，如有需要，您可以阅读官网相关文档。

本文主要介绍如何快速运行腾讯云 WebRTC API Examples。

## 目录结构
```
├── README.md
├── jsconfig.json
├── next.config.js
├── package.json
├── public
│   ├── favicon.ico
└── src
    ├── api   -- 获取数据
    ├── app   -- 配置实时音视频应用信息
    ├── components -- WebRTC API Examples 公共组件
    ├── config -- 配置数据
    ├── i18n   -- 国际化
    ├── pages  -- WebRTC API 使用示例
    ├── styles -- 样式
    └── utils  -- 通用函数
```

## 前提条件
您已 [注册腾讯云](https://cloud.tencent.com/document/product/378/17985) 账号，并完成 [实名认证](https://cloud.tencent.com/document/product/378/3629)。

## 操作步骤
### 步骤1：创建新的应用
1. 登录实时音视频控制台，选择【开发辅助】>【[快速跑通Demo](https://console.cloud.tencent.com/trtc/quickstart)】。
2. 单击【立即开始】，输入应用名称，例如`TestTRTC`，单击【创建应用】。

### 步骤2：配置 API Examples 工程文件
1. 找到并打开`src/app/config.js`文件。
2. 设置`config.js`文件中的相关参数：
  <ul><li>SDKAPPID：默认为0，请设置为实际的 SDKAppID。</li>
  <li>SECRETKEY：默认为空字符串，请设置为实际的密钥信息。</li></ul> 
	<img src="https://main.qcloudimg.com/raw/1732ea2401af6111b41259a78b5330a4.png">
3. 返回实时音视频控制台，单击【粘贴完成，下一步】。
4. 单击【关闭指引，进入控制台管理应用】。

> ⚠️注意：  
> 本文提到的生成 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通 Demo 和功能调试**。  
>   
> 正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。

### 步骤3：运行 API Examples

> ⚠️注意：  
> 1. 建议 node 环境为 v14.16.0  
> 2. 请使用 yarn 安装依赖，运行项目  

#### 1. 安装依赖
```bash
yarn 
```

#### 2. 开发环境运行
```bash
yarn run dev
```
使用 Chrome 浏览器打开 `http://localhost:3000/basic-rtc` 查看开发页面

#### 3. 生产环境打包
```bash
yarn run build
```
您可以在 `/.next` 文件夹下看到打包结果并根据需要将打包结果部署在服务器上

#### 4. 生产环境运行
```bash
yarn run build
yarn run start
```
您可以使用 Chrome 浏览器打开 `http://localhost:3000/basic-rtc` 查看部署在本地服务器上的页面

#### 5. 生产环境打包并导出静态文件
```bash
yarn run export
```
您可以在 `/out` 文件夹下看到导出的静态文件，静态文件可以直接上传到 CDN

Demo 运行界面如图所示：
![](https://web.sdk.qcloud.com/trtc/webrtc/assets/API-examples-page.png)

WebRTC 需要使用摄像头和麦克风采集音视频，在体验过程中您可能会收到来自 Chrome 浏览器的相关提示，单击【允许】。
![](https://web.sdk.qcloud.com/trtc/webrtc/assets/API-examples-device-request.png)

## 支持的平台

WebRTC 技术由 Google 最先提出，目前主要在桌面版 Chrome 浏览器、桌面版 Safari 浏览器以及移动版的 Safari 浏览器上有较为完整的支持，其他平台（例如 Android 平台的浏览器）支持情况均比较差。
- 在移动端推荐使用 [小程序](https://cloud.tencent.com/document/product/647/32399) 解决方案，微信和手机 QQ 小程序均已支持，都是由各平台的 Native 技术实现，音视频性能更好，且针对主流手机品牌进行了定向适配。
- 如果您的应用场景主要为教育场景，那么教师端推荐使用稳定性更好的 [Electron](https://cloud.tencent.com/document/product/647/38549) 解决方案，支持大小双路画面，更灵活的屏幕分享方案以及更强大而弱网络恢复能力。

<table>
<tr>
<th>操作系统</th>
<th width="22%">浏览器类型</th><th>浏览器最低<br>版本要求</th><th width="16%">接收（播放）</th><th width="16%">发送（上麦）</th><th>屏幕分享</th><th>SDK 版本要求</th>
</tr><tr>
<td>Mac OS</td>
<td>桌面版 Safari 浏览器</td>
<td>11+</td>
<td>支持</td>
<td>支持</td>
<td>支持（需要 Safari13+ 版本）</td>
<td>-</td>
</tr>
<tr>
<td>Mac OS</td>
<td>桌面版 Chrome 浏览器</td>
<td>56+</td>
<td>支持</td>
<td>支持</td>
<td>支持（需要 Chrome72+ 版本）</td>
<td>-</td>
</tr>
<tr>
<td>Mac OS</td>
<td>桌面版 Firefox 浏览器</td>
<td>56+</td>
<td>支持</td>
<td>支持</td>
<td>支持（需要 Firefox66+ 版本）</td>
<td>v4.7.0+</td>
</tr>
<tr>
<td>Mac OS</td>
<td>桌面版 Edge 浏览器</td>
<td>80+</td>
<td>支持</td>
<td>支持</td>
<td>支持</td>
<td>v4.7.0+</td>
</tr>
<tr>
<td>Windows</td>
<td>桌面版 Chrome 浏览器</td>
<td>56+</td>
<td>支持</td>
<td>支持</td>
<td>支持（需要 Chrome72+ 版本）</td>
<td>-</td>
</tr>
<tr>
<td>Windows</td>
<td>桌面版 QQ 浏览器（极速内核）</td>
<td>10.4+</td>
<td>支持</td>
<td>支持</td>
<td>不支持</td>
<td>-</td>
</tr>
<tr>
<td>Windows</td>
<td>桌面版 Firefox 浏览器</td>
<td>56+</td>
<td>支持</td>
<td>支持</td>
<td>支持（需要 Firefox66+ 版本）</td>
<td>v4.7.0+</td>
</tr>
<tr>
<td>Windows</td>
<td>桌面版 Edge 浏览器</td>
<td>80+</td>
<td>支持</td>
<td>支持</td>
<td>支持</td>
<td>v4.7.0+</td>
</tr>
<tr>
<td>iOS 11.1.2+</td>
<td>移动版 Safari 浏览器</td>
<td>11+</td>
<td>支持</td>
<td>支持</td>
<td>不支持</td>
<td>-</td>
</tr>
<tr>
<td>iOS 12.1.4+</td>
<td>微信内嵌网页</td>
<td>-</td>
<td>支持</td>
<td>不支持</td>
<td>不支持</td>
<td>-</td>
</tr>
<tr>
<td>Android</td>
<td>移动版 QQ 浏览器</td>
<td>-</td>
<td>不支持</td>
<td>不支持</td>
<td>不支持</td>
<td>-</td>
</tr>
<tr>
<td>Android</td>
<td>移动版 UC 浏览器</td>
<td>-</td>
<td>不支持</td>
<td>不支持</td>
<td>不支持</td>
<td>-</td>
</tr>
<tr>
<td>Android</td>
<td>微信内嵌网页（TBS 内核）</td>
<td>-</td>
<td>支持</td>
<td>支持</td>
<td>不支持</td>
<td>-</td>
</tr>
<tr>
<td>Android</td>
<td>微信内嵌网页（XWEB 内核）</td>
<td>-</td>
<td>支持</td>
<td>支持</td>
<td>不支持</td>
<td>-</td>
</tr>
</table>

>! 
>- 您可以在浏览器中打开 [WebRTC 能力测试](https://www.qcloudtrtc.com/webrtc-samples/abilitytest/index.html) 页面进行检测是否完整支持 WebRTC。例如公众号等浏览器环境。
>- 由于 H.264 版权限制，华为系统的 Chrome 浏览器和以 Chrome WebView 为内核的浏览器均不支持 TRTC 的 Web 版 SDK 的正常运行。

<span id="requirements"></span>
## 环境要求
- 请使用最新版本的 Chrome 浏览器。
- TRTC Web SDK 依赖以下端口进行数据传输，请将其加入防火墙白名单，配置完成后，您可以通过访问并体验 [官网 Demo](https://trtc-1252463788.file.myqcloud.com/web/demo/official-demo/index.html) 检查配置是否生效。
 - TCP 端口：8687
 - UDP 端口：8000；8080；8800；843；443；16285
 - 域名：qcloud.rtc.qq.com

## 常见问题

### 1. 查看密钥时只能获取公钥和私钥信息，要如何获取密钥？
TRTC SDK 6.6 版本（2019年08月）开始启用新的签名算法 HMAC-SHA256。在此之前已创建的应用，需要先升级签名算法才能获取新的加密密钥。如不升级，您也可以继续使用 [老版本算法 ECDSA-SHA256](https://cloud.tencent.com/document/product/647/17275#.E8.80.81.E7.89.88.E6.9C.AC.E7.AE.97.E6.B3.95)。

升级操作：
1. 登录 [实时音视频控制台](https://console.cloud.tencent.com/trtc)。
2. 在左侧导航栏选择【应用管理】，单击目标应用所在行的【应用信息】。
3. 选择【快速上手】页签，单击【第二步 获取签发UserSig的密钥】区域的【点此升级】。

### 2. 出现客户端错误：“RtcError: no valid ice candidate found”该如何处理？
出现该错误说明 TRTC Web SDK 在 STUN 打洞失败，请根据 [环境要求](#requirements) 检查防火墙配置。

### 3. 出现客户端错误："RtcError: ICE/DTLS Transport connection failed" 或 “RtcError: DTLS Transport connection timeout”该如何处理？
出现该错误说明 TRTC Web SDK 在建立媒体传输通道时失败，请根据 [环境要求](#requirements) 检查防火墙配置。

### 4. 出现10006 error 该如何处理？
如果出现"Join room failed result: 10006 error: service is suspended,if charge is overdue,renew it"，请确认您的实时音视频应用的服务状态是否为可用状态。
登录 [实时音视频控制台](https://console.cloud.tencent.com/rav)，单击您创建的应用，单击【帐号信息】，在帐号信息面板即可确认服务状态。
![](https://main.qcloudimg.com/raw/13c9b520ea333804cffb4e2c4273fced.png)
