本文主要介绍如何快速跑通微信小程序版本的 TRTCCalling Demo，Demo 中包括语音通话和视频通话场景：

 \- 语音通话：纯语音交互，支持多人互动语音聊天。

 \- 视频通话：视频通话，面向在线客服等需要面对面交流的沟通场景。

## 效果展示

<img src="https://web.sdk.qcloud.com/component/trtccalling/doc/miniapp/audiocall.gif" style="width: 45%;" >

<img src="https://web.sdk.qcloud.com/component/trtccalling/doc/miniapp/videocall.gif" style="width:45%;" >

## 前提条件

您已 [注册腾讯云](https://cloud.tencent.com/document/product/378/17985) 账号，并完成 [实名认证](https://cloud.tencent.com/document/product/378/3629)。

## 操作步骤

<span id="step1"></span>

### 步骤1：创建新的应用

1. 登录实时音视频控制台，选择【开发辅助】>【[快速跑通Demo](https://console.cloud.tencent.com/trtc/quickstart)】。

2. 单击【立即开始】，输入应用名称，例如`TestTRTC`，单击【创建应用】。

3. 登入[即时通信IM控制台](https://console.cloud.tencent.com/im)，添加新应用，启用IM服务。

<span id="step2"></span>

### 步骤2：下载 SDK 和 Demo 源码

1. 您可以单击【[Github](https://github.com/tencentyun/TRTCSDK/tree/master/WXMini/TRTCScenesDemo)】跳转至 Github（或单击【[ZIP](https://web.sdk.qcloud.com/trtc/miniapp/download/trtc-room.zip)】），下载相关 SDK 及配套的 Demo 源码。

<span id="step3"></span>

### 步骤3：配置 Demo 工程文件

1. 解压 [步骤2](#step2) 中下载的源码包。

2. 找到并打开`./debug/GenerateTestUserSig.js`文件。

3. 设置`GenerateTestUserSig.js`文件中的相关参数：

  <ul><li>SDKAPPID：默认为0，请设置为实际的 SDKAppID。</li>

  <li>SECRETKEY：默认为空字符串，请设置为实际的密钥信息。</li></ul> 

  <img src="https://main.qcloudimg.com/raw/0ae7a197ad22784384f1b6e111eabb22.png">

4. 返回实时音视频控制台，单击【粘贴完成，下一步】。

5. 单击【关闭指引，进入控制台管理应用】。

>!本文提到的生成 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通 Demo 和功能调试**。

>正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。

### 步骤4：开通小程序类目与推拉流标签权限

出于政策和合规的考虑，微信暂未放开所有小程序对实时音视频功能（即 &lt;live-pusher&gt; 和 &lt;live-player&gt; 标签）的支持：

- 小程序推拉流标签不支持个人小程序，只支持企业类小程序。

- 小程序推拉流标签使用权限暂时只开放给有限 [类目](https://developers.weixin.qq.com/miniprogram/dev/component/live-pusher.html)。

- 符合类目要求的小程序，需要在【[微信公众平台](https://mp.weixin.qq.com)】>【开发】>【接口设置】中自助开通该组件权限，如下图所示：

 ![](https://main.qcloudimg.com/raw/ad87091aaae2db6ad412136297886c15.png)


**### 步骤5：编译运行**

1. 打开微信开发者工具，选择【小程序】，单击新建图标，选择【导入项目】。

2. 填写您微信小程序的 AppID，单击【导入】。

 >!此处应输入您微信小程序的 AppID，而非 SDKAppID。

 ![](https://main.qcloudimg.com/raw/b4eefa2896672e132f827fea79a2608b.jpg)   

3. 单击【预览】，生成二维码，通过手机微信扫码二维码即可进入小程序。



> 小程序 &lt;live-player&gt; 和 &lt;live-pusher&gt; 标签需要在手机微信上才能使用，微信开发者工具上无法使用。为了小程序能够使用腾讯云房间管理服务，您需要在手机微信上开启调试功能：手机微信扫码二维码后，单击右上角【...】>【打开调试】。

<img src="https://web.sdk.qcloud.com/component/trtccalling/doc/miniapp/108fa6e3c2e8da33e547739c3ab93a31.png" style="zoom:30%;" />

## 常见问题

### 1. 查看密钥时只能获取公钥和私钥信息，该如何获取密钥？

TRTC SDK 6.6 版本（2019年08月）开始启用新的签名算法 HMAC-SHA256。在此之前已创建的应用，需要先升级签名算法才能获取新的加密密钥。如不升级，您也可以继续使用 [老版本算法 ECDSA-SHA256](https://cloud.tencent.com/document/product/647/17275#Old)，如已升级，您按需切换为新旧算法。

升级/切换操作：

1. 登录 [实时音视频控制台](https://console.cloud.tencent.com/trtc)。

2. 在左侧导航栏选择【应用管理】，单击目标应用所在行的【应用信息】。

3. 选择【快速上手】页签，单击【第二步 获取签发UserSig的密钥】区域的【点此升级】、【非对称式加密】或【HMAC-SHA256】。

- 升级：

   ![](https://main.qcloudimg.com/raw/69bd0957c99e6a6764368d7f13c6a257.png)

- 切换回老版本算法 ECDSA-SHA256：

   ![](https://main.qcloudimg.com/raw/f89c00f4a98f3493ecc1fe89bea02230.png)

- 切换为新版本算法 HMAC-SHA256：

   ![](https://main.qcloudimg.com/raw/b0412153935704abc9e286868ad8a916.png)


### 2. 防火墙有什么限制？

由于 SDK 使用 UDP 协议进行音视频传输，所以对 UDP 有拦截的办公网络下无法使用，如遇到类似问题，请参考文档：[应对公司防火墙限制](https://cloud.tencent.com/document/product/647/34399)。

### 3. 调试时为什么要开启调试模式？

开启调试后，可以略过把“request 合法域名”加入小程序白名单的操作，避免遇到登录失败，通话无法连接的问题。