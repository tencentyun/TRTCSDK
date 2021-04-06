# TRTC精简版Demo

这个开源示例Demo主要演示如何基于 [TRTC 实时音视频 SDK](https://cloud.tencent.com/document/product/647/32689)，快速实现一些音视频场景的基本功能。

在这个示例项目中包含了以下场景：

- 视频通话
- 视频互动直播

## 环境要求
- Xcode 10.2及以上版本

## 前提条件
您已 [注册腾讯云](https://cloud.tencent.com/document/product/378/17985) 账号，并完成 [实名认证](https://cloud.tencent.com/document/product/378/3629)。

## 操作步骤
<span id="step1"></span>
### 步骤1：创建新的应用
1. 登录实时音视频控制台，选择【开发辅助】>【[快速跑通Demo](https://console.cloud.tencent.com/trtc/quickstart)】。
2. 单击【立即开始】，输入应用名称，例如`TestTRTC`，单击【创建应用】。

<span id="step2"></span>
### 步骤2：下载 SDK 和 Demo 源码
1. 鼠标移动至对应卡片，下载相关 SDK 及配套的 Demo 源码。
 单击【[Github](https://github.com/tencentyun/TRTCSDK/tree/master/Mac)】跳转至 Github（或单击【[ZIP](https://liteav.sdk.qcloud.com/download/latest/TXLiteAVSDK_TRTC_Mac_latest.tar.bz2?_ga=1.195966252.185644906.1567570704)】）
  ![](https://main.qcloudimg.com/raw/3b6d17adff2348fa2363cd608e2e3802.png)
    
2. 下载完成后，返回实时音视频控制台，单击【我已下载，下一步】，可以查看 SDKAppID 和密钥信息。

<span id="step3"></span>
### 步骤3：配置 Demo 工程中的AppID和密钥
1. 打开[GenerateTestUserSig.h](debug/GenerateTestUserSig.h)文件
2. 配置`GenerateTestUserSig.h`文件中的相关参数：
  <ul><li>SDKAPPID：默认为0，请设置为实际的 SDKAppID。</li>
  <li>SECRETKEY：默认为空字符串，请设置为实际的密钥信息。</li></ul> 
    <img src="https://main.qcloudimg.com/raw/15d986c5f4bc340e555630a070b90d63.png">
3. 返回实时音视频控制台，单击【粘贴完成，下一步】。
4. 单击【关闭指引，进入控制台管理应用】。

>!本文提到的生成 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通 Demo 和功能调试**。
>正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。

### 步骤4：编译运行
使用 XCode（10.2及以上的版本）打开源码目录下的 TRTCSimpleDemo.xcworkspace 工程，编译并运行 Demo 工程即可。
