本文档主要介绍如何快速集成实时音视频（TRTC）SDK，运行TRTC场景化Demo，实现多人视频会议、语音聊天室、视频连麦互动直播等。

## 目录结构

```
├─ Podfile                    //Pod描述文件
├─ TXLiteAVDemo
│    ├─ App                   // 主面板，各种场景入口
│    ├─ AudioSettingKit       // 音效面板，包含BGM播放，变声，混响，变调等效果
│    ├─ BeautySettingKit      // 美颜面板，包含美颜，滤镜，动效等效果
│    ├─ Debug                 // 调试相关
│    ├─ Login                 // 登录相关
│    ├─ TRTCMeetingDemo       // 多人视频会议，多人开会场景，包含屏幕分享、聊天等特性
│    ├─ TRTCVoiceRoomDemo     // 语聊房，多人音频聊天场景，注重高音质
│    ├─ TRTCLiveRoomDemo      // 视频互动直播，美女主播秀场场景，包含连麦、PK、聊天、点赞等特性
│    ├─ TRTCAudioCallDemo     // 音频通话，展示双人音频通话
│    ├─ TRTCVideoCallDemo     // 视频通话，展示双人视频通话
```

## 功能简介

在这个示例项目中包含了以下功能：

- 多人视频会议；
- 语音聊天室
- 视频互动直播；
- 语音通话；
- 视频通话；


## 环境准备
- 最低兼容 iOS 8.0 ，建议使用 iOS 10.0 及以上版本
- Xcode 10.0 及以上版本
- App 要求 iOS9.0 及以上设备

## 运行示例

### 前提条件
您已 [注册腾讯云](https://cloud.tencent.com/document/product/378/17985) 账号，并完成 [实名认证](https://cloud.tencent.com/document/product/378/3629)。

### 申请 SDKAPPID 和 SECRETKEY
1. 登录实时音视频控制台，选择【开发辅助】>【[快速跑通Demo](https://console.cloud.tencent.com/trtc/quickstart)】。
2. 单击【立即开始】，输入您的应用名称，例如`TestTRTC`，单击【创建应用】。

<img width=800 src="https://main.qcloudimg.com/raw/169391f6711857dca6ed8cfce7b391bd.png" />
3. 创建应用完成后，单击【我已下载，下一步】，可以查看 SDKAppID 和密钥信息。

### 配置 Demo 工程文件
1. 使用 Xcode（10.0及以上的版本）打开源码工程`iOS/TRTCScenesDemo/TXLiteAVDemo.xcworkspace`。
3. 找到并打开`iOS/TRTCScenesDemo/TRTCScenesDemo/debug/GenerateTestUserSig.h`文件。
4. 设置`GenerateTestUserSig.h`文件中的相关参数：
  <ul><li>SDKAPPID：默认为0，请设置为实际的 SDKAppID。</li>
  <li>SECRETKEY：默认为空字符串，请设置为实际的密钥信息。</li></ul>

 ![](https://main.qcloudimg.com/raw/15d986c5f4bc340e555630a070b90d63.png)

4. 返回实时音视频控制台，单击【粘贴完成，下一步】。
5. 单击【关闭指引，进入控制台管理应用】。

>!本文提到的生成 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通 Demo 和功能调试**。
>正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。

### 集成 SDK
你可以通过下载framework Zip包，集成SDK。也可以通过Cocoapods方式集成，Demo默认使用方法一进行集成。

#### 方法一：Cocoapods集成framework
在终端窗口中 cd 到 Podfile 所在目录执行以下命令安装需要的pod 库（如果从zip包解压的工程，可以跳过这一步）。

```
pod install
```
或使用以下命令更新本地库版本：

```
pod update
```
使用 XCode （10.0 以上的版本，建议使用最新版Xcode） 打开源码目录下的 `.xcworkspace` 工程，编译并运行 Demo 工程即可。

#### 方法二：手动下载（framework）
如果您的网络连接 Pods 有问题，您也可以手动下载 SDK 集成到工程里：

1. 下载最新版本 [实时音视频 SDK](http://liteavsdk-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_TRTC_iOS_latest.zip)。
2. 将下载到的 zip包解压，找到对应的framework文件，将文件拷贝到工程的 **iOS/SDK** 目录下。
3. 用xcode打开TXLiteAVDemo.xcworkspace文件，检查SDK目录下的framework是否正确引入。

### 编译运行
用 xcode 打开该项目，连上iOS设备，修改bundleID，配置你自己的测试证书和描述文件，编译并运行。
> 注意：如果是从github下载的工程，不含Pods目录，需要执行`pod install`。可以打开.xcworkspace工程，直接运行，工程会自动检测Pods目录是否存在，执行**运行前置脚本**，从远端下载zip包，自动配置Pod相关文件。如果`pod install`执行失败，也可以删除Pods文件夹，保留Podfile，Podfile.lock, xcworkspace，直接运行工程即可。


## 常见问题
#### 1. 查看密钥时只能获取公钥和私钥信息，该如何获取密钥？
TRTC SDK 6.6 版本（2019年08月）开始启用新的签名算法 HMAC-SHA256。在此之前已创建的应用，需要先升级签名算法才能获取新的加密密钥。如不升级，您也可以继续使用 [老版本算法 ECDSA-SHA256](https://cloud.tencent.com/document/product/647/17275#.E8.80.81.E7.89.88.E6.9C.AC.E7.AE.97.E6.B3.95)，如已升级，您按需切换为新旧算法。

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

#### 2. 两台手机同时运行 Demo，为什么看不到彼此的画面？
请确保两台手机在运行 Demo 时使用的是不同的 UserID，TRTC 不支持同一个 UserID （除非 SDKAppID 不同）在两个终端同时使用。

![](https://main.qcloudimg.com/raw/c7b1589e1a637cf502c6728f3c3c4f99.png)

#### 3. 防火墙有什么限制？
由于 SDK 使用 UDP 协议进行音视频传输，所以在对 UDP 有拦截的办公网络下无法使用。如遇到类似问题，请参考 [应对公司防火墙限制](https://cloud.tencent.com/document/product/647/34399) 排查并解决。

