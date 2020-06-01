# TRTC精简版Demo

这个开源示例Demo主要演示如何基于 [TRTC 实时音视频 SDK](https://cloud.tencent.com/document/product/647/32689)，快速实现一些音视频场景的基本功能。

在这个示例项目中包含了以下场景：

- 视频通话
- 视频互动直播

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

![](https://main.qcloudimg.com/raw/169391f6711857dca6ed8cfce7b391bd.png)
3. 创建应用完成后，单击【我已下载，下一步】，可以查看 SDKAppID 和密钥信息。

### 配置 Demo 工程文件
1. 使用 Android Studio（3.5及以上的版本）打开源码工程`TRTCSimpleDemo`
2. 找到并打开`TRTCSimpleDemo/debug/src/main/java/com/tencent/liteav/debug/GenerateTestUserSig.java`文件。
3. 设置`GenerateTestUserSig.java`文件中的相关参数：
  <ul><li>SDKAPPID：默认为 PLACEHOLDER ，请设置为实际的 SDKAppID。</li>
  <li>SECRETKEY：默认为空字符串，请设置为实际的密钥信息。</li></ul>

 ![](https://main.qcloudimg.com/raw/8fb309ce8c378dd3ad2c0099c57795a5.png)

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
3.单击【Sync Now】，自动下载 SDK 并集成到工程里。


#### 方法二：手动下载（aar）
如果您的网络连接 JCenter 有问题，您也可以手动下载 SDK 集成到工程里：

1. 下载最新版本 [实时音视频 SDK](http://liteavsdk-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_TRTC_Android_latest.zip)。
2. 将下载到的 aar 文件拷贝到工程的 **app/libs** 目录下。
3. 在工程根目录下的 build.gradle 中，添加 **flatDir**，指定本地仓库路径。
```
...
allprojects {
    repositories {
        flatDir {
            dirs 'libs'
            dirs project(':app').file('libs')
        }
    ...
    }
}
...
```

4. 在 app/build.gradle 中，添加引用 aar 包的代码。
```
dependencies {
    ...
    compile(name: 'LiteAVSDK_TRTC_xxx', ext: 'aar') // xxx表示解压出来的SDK版本号
    ...
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
