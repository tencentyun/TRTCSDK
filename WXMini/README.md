# 快速跑通Demo

 本文主要介绍如何快速跑通微信小程序版本的 TRTC DEMO，您可以从 [Github](https://github.com/tencentyun/TRTCSDK) 上的 WXMini 目录下获取相关代码。DEMO 中前三个功能项演示了三个不同的应用场景：
 
 - 语音聊天室：纯语音交互，支持多人互动语音聊天，以及混音、混响等声音特效功能。适合在线狼人杀、在线语音直播等社交类场景。
 - 双人通话：1v1 视频通话，配合 [Web IM SDK](https://cloud.tencent.com/document/product/269/37411) 可以实现在线问诊，在线客服等需要面对面交流的沟通场景。
 - 多人会议：支持多路视频通话、大小画面和屏幕分享等围绕视频会议相关的高级功能，适用于远程培训、在线教育等场景。
 
 ![](https://main.qcloudimg.com/raw/6517a8a927130474927628457cdc27be.jpg)

## 环境要求

- 微信 App iOS 最低版本要求：7.0.9
- 微信 App Android 最低版本要求：7.0.8
- 小程序基础库最低版本要求：2.10.0
- 由于微信开发者工具不支持原生组件（即 &lt;live-pusher&gt; 和 &lt;live-player&gt; 标签），需要在真机上进行运行体验。

## 操作步骤

打开实时音视频控制台，点击进入[快速跑通 Demo](https://console.cloud.tencent.com/trtc/quickstart)，就会看到完整的 Demo 运行指引，接下来我们按照提示的步骤逐步实践一下：

### step1. 创建新的应用
点击“立即开始”，然后给自己的应用取个名字，比如就叫 “TestTRTC”，点击创建应用，即可进入下一步。


### step2. 下载 SDK 和 Demo 源码
选择小程序源码点击下载，我们提供了 [Github](https://github.com/tencentyun/TRTCSDK/tree/master) 和 [Zip压缩包](http://liteavsdk-1252463788.cosgz.myqcloud.com/TRTC_WXMini_latest.zip) 两种获取方式。

### step3. 将 SDKAppID 和密钥粘贴到指定位置
可以在下图中看到 SDKAppID 和 SecretKey 两个关键信息，这是要运行 Demo 所必须的，然后将他们按照页面上的指引粘贴到源代码中自带的 `GenerateTestUserSig.js` 文件中。
- 解压 step 2 中下载的源码包。
- 找到并打开 `./debug/GenerateTestUserSig.js` 文件。
- 设置`GenerateTestUserSig.js`文件中的相关参数：

![](https://main.qcloudimg.com/raw/74b82ded221f8e2e91e4f918da6b5932.png)

> !
> 本文提到的生成 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通 Demo 和功能调试**。
> 
> 正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。

### step4. 开通小程序类目与推拉流标签权限

出于政策和合规的考虑，微信暂未放开所有小程序对实时音视频功能（即  &lt;live-pusher&gt; 和  &lt;live-player&gt; 标签）的支持：

- 小程序推拉流标签不支持个人小程序，只支持企业类小程序。
- 小程序推拉流标签使用权限暂时只开放给有限 [类目](https://developers.weixin.qq.com/miniprogram/dev/component/live-pusher.html)。
- 符合类目要求的小程序，需要在【[微信公众平台](https://mp.weixin.qq.com/)】>【开发】>【接口设置】中自助开通该组件权限，如下图所示：

![](https://main.qcloudimg.com/raw/ad87091aaae2db6ad412136297886c15.png)

### step5. 编译运行

- 打开微信开发者工具，选择【小程序】，单击新建图标，选择【导入项目】。
- 填写您微信小程序的 AppID，单击【导入】。
![](https://main.qcloudimg.com/raw/b4eefa2896672e132f827fea79a2608b.jpg)     

- 单击【预览】，生成二维码，通过手机微信扫码二维码即可进入小程序。

> !
> 1. 此处应输入您微信小程序的 AppID，而非 SDKAppID。
> 2. 由于微信开发者工具不支持原生组件（即 &lt;live-pusher&gt; 和 &lt;live-player&gt; 标签），需要在真机上进行运行体验。您需要在手机微信上开启调试功能：手机微信扫码二维码后，单击右上角【...】>【开发调试】。 
> ![](https://main.qcloudimg.com/raw/9ae12892a437c25c2317fb62f7f851ba.png)


## 常见问题

### 1. 为什么“我”在查看密钥时只能获取公钥和私钥信息，要如何获取密钥？

TRTC SDK 6.6 版本（2019年08月）开始启用新的签名算法 HMAC-SHA256，这是一种对称加密方案。如果您看到了“公钥”和“私钥”这样的文案，说明您的 SDKAppID 应该是在 2019.08 之前创建的，需要先单击【step2. 获取签发UserSig的密钥】区域的【点此升级】升级签名算法才能获取新的加密密钥。如不升级，您也可以继续使用老版本 [ECDSA-SHA256](https://cloud.tencent.com/document/product/647/17275#.E8.80.81.E7.89.88.E6.9C.AC.E7.AE.97.E6.B3.95) 算法。

### 2. 防火墙有什么限制？

由于 SDK 使用 UDP 协议进行音视频传输，所以对 UDP 有拦截的办公网络下无法使用，如遇到类似问题，请参考文档：[应对公司防火墙限制](https://cloud.tencent.com/document/product/647/34399)。

### 3. 调试时为什么要开启调试模式？

开启调试后，可以略过把“request 合法域名”加入小程序白名单的操作，避免遇到登录失败，通话无法连接的问题。

### 4.为什么出现黑屏/画面卡住？

您可以检查我们小程序 demo 左下方的控制面板。打开 debug 选项，可以在界面上看到详细的推拉流信息，如果没有推拉流的信息则是未进房成功或是 live-pusher，live-player 创建失败。以下是我们控制面板的介绍

![](https://main.qcloudimg.com/raw/b370373d41217c2c0efca37ab87cc94a.jpg)


| 参数          | 含义                                                         |
| ------------- | ------------------------------------------------------------ |
| appVersion    | 微信版本号                                                   |
| libVersion    | 基础库版本号                                                 |
| template      | trtc-room 组件的 template                                      |
| debug         | 是否开启推拉流的 debug 信息                                    |
| userID        | 生成的用户 ID                                                 |
| roomID        | 房间号                                                       |
| camera        | 是否开启摄像头                                               |
| mic           | 是否开启麦克风                                               |
| switch camera | 摄像头位置( front / back )                                       |
| Room          | 进房，退房，退房并返回上一界面操作                           |
| user count    | 房间内人数，下方就是user的信息<br/>userID<br/>mainV：该用户是否有主路视频<br/>mainA：该用户是否有主路音频<br/>auxV：该用户是否有辅路视频 |
| stream count  | 房间内流的数量，下方就是流的信息<br/>userID<br/>SubV：是否订阅此路流的视频<br />SubA：是否订阅此路流的音频 |

