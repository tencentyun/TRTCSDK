中文 | [English](README.en.md)

本文主要介绍如何快速运行腾讯云 TRTC QTDemo。

## 前言
这个开源示例 Demo 主要演示了 [TRTC 实时音视频 SDK](https://cloud.tencent.com/document/product/647/32689) 部分API的使用示例，帮助开发者可以更好的理解 TRTC 实时音视频 SDK 的 API ，从而快速实现一些音视频场景的基本功能。 

## 结构说明
在这个示例项目中包含了以下场景:（带上对应的跳转目录，方便用户快速浏览感兴趣的功能）

  - [基础功能(视频通话、音频通话、视频互动直播、语音聊天室)](./src/TestBaseScene)
  - [跨房PK](./src/ConnectOtherRoom)
  - [子房间](./src/TestSubCloudSetting)
  - [屏幕分享](./src/TestScreenShare)
  - [CDN 发布](./src/TestCDNPublish)
  - [CDN 混流](./src/TestMixStreamPublish)
  - [CDN 流播放器](./src/TestCDNPlayer)
  - [音频检测](./src/TestAudioDetect)
  - [视频检测](./src/TestVideoDetect)
  - [音频设置](./src/TestAudioSetting)
  - [视频设置](./src/TestVideoSetting)
  - [音频录制](./src/TestAudioRecord)
  - [美颜&水印](./src/TestBeautyAndWatermark)
  - [背景音乐&音效](./src/TestBgmSetting)
  - [自定义音/视频采集](./src/TestCustomCapture)
  - [自定义渲染](./src/TestCustomRender)
  - [自定义消息发送](./src/TestCustomMessage)
  - [日志设置](./src/TestLogSetting)
  - [网络检测](./src/TestNetworkCheck)


## 环境要求
- QT 建议使用 Qt 5.14.1 及以上版本。
- MAC 端建议使用 QT creator 4.11.1及以上版本。
- Windows 端建议使用 Visual Studio 2015 及以上版本。

## 前提条件
您已 [注册腾讯云](https://cloud.tencent.com/document/product/378/17985) 账号，并完成 [实名认证](https://cloud.tencent.com/document/product/378/3629)。

## 操作步骤
[](id:step1)

### 步骤1：创建新的应用

1. 登录实时音视频控制台，选择【开发辅助】>【[快速跑通 Demo ](https://console.cloud.tencent.com/trtc/quickstart)】。
2. 输入应用名称，例如 TestTRTC ，单击【创建】。
![](https://main.qcloudimg.com/raw/9b2db43594f4744b42ef74c94494ea8e.png)

[](id:step2)
### 步骤2：下载 SDK 和 Demo 源码

1. 根据实际业务需求下载 SDK 及配套的 Demo 源码。
2. 下载完成后，单击【已下载，下一步】。
![](https://main.qcloudimg.com/raw/3b115019ddfd0866108ed1add30810d8.png)

[](id:step3)

### 步骤3：配置 Demo 工程文件
1. 进入修改配置页，根据您下载的源码包，选择相应的开发环境。
2. 找到并打开 `QTDemo/src/Util/defs.h` 文件。
3. 设置 `defs.h` 文件中的相关参数：
	<ul>
	<li/>SDKAPPID：默认为 PLACEHOLDER ，请设置为实际的 SDKAppID。
	<li/>SECRETKEY：默认为 PLACEHOLDER ，请设置为实际的密钥信息。</ul>
    <img src="https://main.qcloudimg.com/raw/8f64723d3e202a5345517a18f9e8c5d8.png"> 
4. 粘贴完成后，单击【已复制粘贴，下一步】即创建成功。
5. 编译完成后，单击【回到控制台概览】即可。

>**注意：**此处获取 SECRETKEY 的方案仅适用于调试 Demo ，正式上线前请将 UserSig 的计算代码和密钥迁移到您的后台服务器上，以避免加密密钥泄露导致的流量盗用, [详细文档](https://cloud.tencent.com/document/product/647/17275#Server)。

[](id:step4)
### 步骤4：如何跑通Demo
> 
>**Mac:** 下载并安装 [Qt Creator](https://www.qt.io/download-qt-installer?hsCtaTracking=99d9dd4f-5681-48d2-b096-470725510d34%7C074ddad0-fdef-4e53-8aa8-5e8a876d6ab4)，然后用 Qt Creator 打开 `QTDemo.pro` ，到 `QTDemo/base/Defs.h` 头文件中配置好对应的 `SECRETKEY` 和 `SDKAppID` 即可开始编译运行调试；
>
> `注意：`请您确保已将`TXLiteAVSDK_TRTC_Mac.framework`[下载](https://liteav.sdk.qcloud.com/download/latest/TXLiteAVSDK_TRTC_Mac_latest.tar.bz2)并保存到 `Mac/SDK` 文件夹下。最终的工程路径如下——
>```
>├─ QTDemo // QTDemo工程路径
>├─ SDK    // TRTC MAC SDK
>```
>  至此，所有环境配置完毕，您可以通过 **Qt Creator** 编译并调试 Demo 。

>---------
>  **Windows:** 您需要安装 Visual Studio（2015或以上版本）来运行调试，同时配置 VS 下的 Qt 编译环境，步骤如下：
>>首先：**下载并安装**`.vsix`插件文件，[官网](https://download.qt.io/official_releases/vsaddin/)上找对应插件版本安装，
>>
>>然后：打开VS并在工具栏找到 **QT VS Tools** -> **Qt Options** -> **Qt Versions**，**add** 添加我们自己的Qt编译器 msvc ；
>>
>>最后：在运行前，您需要将 **SDK/CPlusPlus/Win32/lib** 下的所有的`.dll`文件，根据您的运行配置`（debug or release）`，拷贝到工程目录下的`debug`或`release`文件夹下。
>
> `注意：`请您确保已将`SDK`文件夹下的`CPlusPlus`[下载](https://liteav.sdk.qcloud.com/download/latest/TXLiteAVSDK_TRTC_Win_latest.zip)并保存到`Windows/SDK`文件夹下，工程路径如下——
>```
>├─ QTDemo // QTDemo工程路径
>├─ SDK    // TRTC Windows SDK
>|  ├─ CPlusPlus //SDK 目录内放置此文件夹
>```
>
>
> 至此，所有环境配置完毕，您可以通过VS编译并调试 Demo 。
> 
> 另外您会在目录结构中看到 `QTDemo.pro`，`.pro` 为工程配置文件，包括但不限于资源文件引用、编译配置等。


## 目录结构说明
```
├─ QTDemo // QTDemo API Example，包括视频通话、语音通话的基础功能以及一些高级功能
|  ├─ src                 // QTDemo 的源码路径
|  |  ├─ TestBaseScene             // 演示 TRTC 基础功能，覆盖视频通话、音频通话、视频互动直播、语音聊天室场景示例代码
|  |  ├─ TestScreenShare           // 演示 TRTC 屏幕分享示例代码
|  |  ├─ TestCDNPublish            // 演示 TRTC CDN 发布实例代码
|  |  ├─ TestMixStreamPublish      // 演示 TRTC CDN 混流示例代码
|  |  ├─ TestAudioDetect           // 演示 TRTC 音频检测示例代码
|  |  ├─ TestVideoDetect           // 演示 TRTC 视频检测示例代码
|  |  ├─ TestAudioSetting          // 演示 TRTC 音频设置示例代码
|  |  ├─ TestVideoSetting          // 演示 TRTC 视频设置示例代码
|  |  ├─ TestAudioRecord           // 演示 TRTC 音频录制示例代码
|  |  ├─ TestBeautyAndWatermark    // 演示 TRTC 美颜&水印示例代码
|  |  ├─ TestBgmSetting            // 演示 TRTC 背景音乐&音效示例代码
|  |  ├─ TestCDNPlayer             // 演示 TRTC CDN 在线流地址播放示例代码
|  |  ├─ TestConnectOtherOther     // 演示 TRTC 跨房 PK 示例代码
|  |  ├─ TestCustomCapture         // 演示 TRTC 自定义音频/视频采集示例代码
|  |  ├─ TestCustomRender          // 演示 TRTC 自定义渲染示例代码
|  |  ├─ TestCustomMessage         // 演示 TRTC 自定义消息发送示例代码
|  |  ├─ TestLogSetting            // 演示 TRTC 日志设置示例代码
|  |  ├─ TestNetworkCheck          // 演示 TRTC 网络检测示例代码
|  |  ├─ TestSubCloudSetting       // 演示 TRTC 子房间示例代码
|  ├─ assets              // 存储 demo 必要的本地资源文件，包含背景音乐、自定义渲染的演示文件，需要拷贝到执行文件所在目录
|  ├─ resources           // demo 运行所需图片等资源
```
## 相关文档链接

- [SDK 的版本更新历史](https://github.com/tencentyun/TRTCSDK/releases)
- [SDK 的 API 文档](http://doc.qcloudtrtc.com/md_introduction_trtc_Windows_cpp_%E6%A6%82%E8%A7%88.html)
- [SDK 的官方体验 App](https://cloud.tencent.com/document/product/647/17021)
- [场景方案：互动直播](https://cloud.tencent.com/document/product/647/43181)
- [场景方案：视频通话](https://cloud.tencent.com/document/product/647/42044)
- [场景方案：语音通话](https://cloud.tencent.com/document/product/647/42046)
- [UserSig 相关问题](https://cloud.tencent.com/document/product/647/17275)
- [应对防火墙限制相关问题](https://cloud.tencent.com/document/product/647/34399)

