# TRTC API-Example 
_中文 | [English](README.en.md)_

## 前言
这个开源示例Demo主要演示了 [TRTC 实时音视频 SDK](https://cloud.tencent.com/document/product/647/32689) 部分API的使用示例，帮助开发者可以更好的理解 TRTC 实时音视频 SDK 的API，从而快速实现一些音视频场景的基本功能。 

## 结构说明
在这个示例项目中包含了以下场景:（带上对应的跳转目录，方便用户快速浏览感兴趣的功能）

- 基础功能
  - [语音通话](./Basic/AudioCall)
  - [视频通话](./Basic/VideoCall)
  - [视频互动直播](./Basic/Live)
  - [语音互动直播](./Basic/VoiceChatRoom)
  - [录屏直播](./Basic/ScreenShare)
- 进阶功能
  - [字符串房间号](./Advanced/StringRoomId)
  - [画质设定](./Advanced/SetVideoQuality)
  - [音质设定](./Advanced/SetAudioQuality)
  - [渲染控制](./Advanced/SetRenderParams)
  - [网络测速](./Advanced/SpeedTest)
  - [CDN发布](./Advanced/PushCDN)
  - [自定义视频采集&渲染](./Advanced/CustomCamera)
  - [设置音效](./Advanced/SetAudioEffect)
  - [设置背景音乐](./Advanced/SetBackgroundMusic)
  - [本地视频文件分享](./Advanced/LocalVideoShare)
  - [本地视频录制](./Advanced/LocalRecord)
  - [加入多个房间](./Advanced/JoinMultipleRoom)
  - [收发SEI消息](./Advanced/SEIMessage)
  - [快速切换房间](./Advanced/SwitchRoom)
  - [跨房PK](./Advanced/RoomPk)
  - [第三方美颜](./Advanced/ThirdBeauty)
  

## 环境准备
- Xcode 11.0及以上版本
- 请确保您的项目已设置有效的开发者签名
 

## 运行示例

### 前提条件
您已 [注册腾讯云](https://cloud.tencent.com/document/product/378/17985) 账号，并完成 [实名认证](https://cloud.tencent.com/document/product/378/3629)。


### 申请 SDKAPPID 和 SECRETKEY
1. 登录实时音视频控制台，选择【开发辅助】>【[快速跑通Demo](https://console.cloud.tencent.com/trtc/quickstart)】。
2. 单击【立即开始】，输入您的应用名称，例如`TestTRTC`，单击【创建应用】。

![](https://main.qcloudimg.com/raw/169391f6711857dca6ed8cfce7b391bd.png)
3. 创建应用完成后，单击【我已下载，下一步】，可以查看 SDKAppID 和密钥信息。


### 配置 Demo 工程文件
1. 打开 Debug 目录下的 [GenerateTestUserSig.h](debug/GenerateTestUserSig.h) 文件。
2. 配置`GenerateTestUserSig.h`文件中的两个参数：
  - SDKAPPID：替换该变量值为上一步骤中在页面上看到的 SDKAppID。
  - SECRETKEY：替换该变量值为上一步骤中在页面上看到的密钥。
 ![ #900px](https://main.qcloudimg.com/raw/8fb309ce8c378dd3ad2c0099c57795a5.png)

4. 返回实时音视频控制台，单击【粘贴完成，下一步】。
5. 单击【关闭指引，进入控制台管理应用】。

>!本文提到的生成 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通 Demo 和功能调试**。
>正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。

### 配置CDN 相关（可选）
如果您需要使用CDN相关业务，比如主播使用TRTC SDK互动连麦，观众端播放CDN流这样的方式，您还需要配置如下三个**直播**相关参数：
- `BIZID`；
- `APPID`；
- `CDN_DOMAIN_NAME`;

![ #900px](https://liteav.sdk.qcloud.com/doc/res/trtc/picture/bizid_appid_scree.png)

详细操作可以参考 [实现 CDN 直播观看](https://cloud.tencent.com/document/product/647/16826#.E9.80.82.E7.94.A8.E5.9C.BA.E6.99.AF)

>注意：
>本文提到的生成 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通 Demo 和功能调试**。
>正确的 UserSig 签发方式请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。

### 编译运行
使用 XCode（11.0及以上的版本）打开源码目录下的 TRTC-API-Example-OC.xcodeproj
> 上述流程并没有解答您的疑问，你可以[点击此处](https://wj.qq.com/s2/8393513/f442/)反馈，我们的**工程师妹子**会尽快处理！

