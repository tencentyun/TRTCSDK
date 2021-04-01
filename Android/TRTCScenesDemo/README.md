本文档主要介绍如何快速集成实时音视频（TRTC）SDK，运行TRTC场景化Demo，实现多人视频会议、语音聊天室、视频连麦互动直播等。

## 目录结构

```
├─ app                   // 主面板，各种场景入口
├─ audioeffectsettingkit // 音效面板，包含BGM播放，变声，混响，变调等效果
├─ beautysettingkit      // 美颜面板，包含美颜，滤镜，动效等效果
├─ debug                 // 调试相关
├─ login                 // 登录相关
├─ trtcmeetingdemo       // 多人视频会议，多人开会场景，包含屏幕分享、聊天等特性
├─ trtcvoiceroomdemo     // 语聊房，多人音频聊天场景，注重高音质
├─ trtcliveroomdemo      // 视频互动直播，美女主播秀场场景，包含连麦、PK、聊天、点赞等特性
├─ trtcaudiocalldemo     // 音频通话，展示双人音频通话
├─ trtcvideocalldemo     // 视频通话，展示双人视频通话
```

## 功能简介

在这个示例项目中包含了以下功能：

- 多人视频会议；
- 语音聊天室
- 视频互动直播；
- 语音通话；
- 视频通话；


## 环境准备
- 最低兼容 Android 4.1（SDK API Level 16），建议使用 Android 5.0 （SDK API Level 21）及以上版本
- Android Studio 3.5及以上版本
- App 要求 Android 4.1及以上设备

## 运行示例

### 前提条件
您已 [注册腾讯云](https://cloud.tencent.com/document/product/378/17985) 账号，并完成 [实名认证](https://cloud.tencent.com/document/product/378/3629)。

### 申请 SDKAPPID 和 SECRETKEY
1. 登录实时音视频控制台，选择【开发辅助】>【[快速跑通Demo](https://console.cloud.tencent.com/trtc/quickstart)】。
2. 单击【立即开始】，输入您的应用名称，例如`TestTRTC`，单击【创建应用】。
<img src="https://main.qcloudimg.com/raw/169391f6711857dca6ed8cfce7b391bd.png" width="650" height="295"/>
3. 创建应用完成后，单击【我已下载，下一步】，可以查看 SDKAppID 和密钥信息。

### 配置 Demo 工程文件
1. 使用 Android Studio（3.5及以上的版本）打开源码工程`TRTCScenesDemo`。
2. 找到并打开`TRTCScenesDemo/debug/src/main/java/com/tencent/liteav/debug/GenerateTestUserSig.java`文件。
3. 设置`GenerateTestUserSig.java`文件中的相关参数：
  <ul><li>SDKAPPID：默认为 PLACEHOLDER ，请设置为实际的 SDKAppID。</li>
  <li>SECRETKEY：默认为空字符串，请设置为实际的密钥信息。</li></ul>
  <img src="https://main.qcloudimg.com/raw/8fb309ce8c378dd3ad2c0099c57795a5.png" width="650" height="295"/>
4. 返回实时音视频控制台，单击【粘贴完成，下一步】。
5. 单击【关闭指引，进入控制台管理应用】。

>!本文提到的生成 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通 Demo 和功能调试**。
>正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。

### 集成 SDK

您可以选择使用 JCenter 自动加载的方式，或者手动下载 aar 再将其导入到您当前的工程项目中，Demo默认采用方法一配置。

#### 方法一：自动加载（aar）
实时音视频（TRTC） SDK 已经发布到 JCenter 库，您可以通过配置 gradle 自动下载更新。
只需要用 Android Studio 打开需要集成 SDK 的工程，然后通过简单的三个步骤修改 app/build.gradle 文件，就可以完成 SDK 集成：

1. 在 dependencies 中添加 SDK 的依赖。
  - 若使用3.x版本的 com.android.tools.build:gradle 工具，请执行以下命令：

	```
	dependencies {
    	implementation 'com.tencent.liteav:LiteAVSDK_TRTC:latest.release'
	}
	```

  - 若使用2.x版本的 com.android.tools.build:gradle 工具，请执行以下命令：

	```
	dependencies {
	    compile 'com.tencent.liteav:LiteAVSDK_TRTC:latest.release'
	}
	```

2. 在 defaultConfig 中，指定 App 使用的 CPU 架构。

	```
	defaultConfig {
    	ndk {
        	abiFilters "armeabi", "armeabi-v7a", "arm64-v8a"
    	}
	}
	```
3. 单击【Sync Now】，自动下载 SDK 并集成到工程里。


#### 方法二：手动下载（aar）
如果您的网络连接 JCenter 有问题，您也可以手动下载 SDK 集成到工程里：

1. 下载最新版本 [实时音视频 SDK](https://liteav.sdk.qcloud.com/download/latest/TXLiteAVSDK_TRTC_Android_latest.zip)。
2. 将下载到的 aar 文件拷贝到工程的 **app/libs** 目录下。
3. 在工程根目录下的 build.gradle 中，添加 **flatDir**，指定本地仓库路径。

	```
	allprojects {
    	repositories {
        	flatDir {
            	dirs 'libs'
           	 dirs project(':app').file('libs')
       	 }
    	}
	}
	```

4. 在 app/build.gradle 中，添加引用 aar 包的代码。

	```
	dependencies {
    	compile(name: 'LiteAVSDK_TRTC_xxx', ext: 'aar') // xxx表示解压出来的SDK版本号    
	}
	```

5. 在 app/build.gradle的defaultConfig 中，指定 App 使用的 CPU 架构。

	```
	defaultConfig {
    	ndk {
       	 abiFilters "armeabi", "armeabi-v7a", "arm64-v8a"
    	}
	}
	```
6. 单击【Sync Now】，完成 SDK 的集成工作。 

### 编译运行
用 Android Studio 打开该项目，连上Android设备，编译并运行。



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
<img src="https://main.qcloudimg.com/raw/c7b1589e1a637cf502c6728f3c3c4f99.png" width="600" height="434"/>

#### 3. 防火墙有什么限制？
由于 SDK 使用 UDP 协议进行音视频传输，所以在对 UDP 有拦截的办公网络下无法使用。如遇到类似问题，请参考 [应对公司防火墙限制](https://cloud.tencent.com/document/product/647/34399) 排查并解决。
