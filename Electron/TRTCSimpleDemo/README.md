本文主要介绍如何快速运行腾讯云 TRTC Demo（Electron）。
![演示](https://demovideo-1252463788.cos.ap-shanghai.myqcloud.com/electron/livemode.gif)

## 前提条件

您已 [注册腾讯云](https://cloud.tencent.com/document/product/378/17985) 账号，并完成 [实名认证](https://cloud.tencent.com/document/product/378/3629)。

## 操作步骤

<span id="step1" name="step1"> </span>

### 步骤1：创建新的应用

1.  登录实时音视频控制台，选择【开发辅助】>【[快速跑通Demo](https://console.cloud.tencent.com/trtc/quickstart)】。
2.  单击【立即开始】，输入应用名称，例如 `TestTRTC`，单击【创建应用】。

<span id="step2" name="step2"> </span>

### 步骤2：下载 SDK 和 Demo 源码

1.  鼠标移动至对应卡片，单击【[Github](https://github.com/tencentyun/TRTCSDK/tree/master/Electron)】跳转至 Github（或单击【[ZIP](https://web.sdk.qcloud.com/trtc/electron/download/TXLiteAVSDK_TRTC_Electron_latest.zip)】），下载相关 SDK 及配套的 Demo 源码。
    ![img](https://main.qcloudimg.com/raw/6273f79193eb7af25eff64020a0ea476.png)
2.  下载完成后，返回实时音视频控制台，单击【我已下载，下一步】，可以查看 SDKAppID 和密钥信息。<span id="idandkey" name="idandkey"> </span>

<span id="step3" name="step3"> </span>

### 步骤3：配置 Demo 工程文件
2.  打开 debug 目录下的 `gen-test-user-sig.js` 文件。

3.  设置 `gen-test-user-sig.js` 文件中的相关参数：

    -   SDKAPPID：替换该变量值为[步骤2](#idandkey)中在页面上看到的 SDKAppID。
    -   SECRETKEY：替换该变量值为[步骤2](#idandkey)中在页面上看到的密钥。
    
    
    
    >!
    >本文提到的生成 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通 Demo 和功能调试**。
    >正确的 UserSig 签发方式请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。
    
    

**文件目录说明：**

本目录包含的是最简单的示例代码，用于演示 TRTC 的接口如何调用，以及最基本的音视频功能。

```bash
.
|--main.electron.js                      Electron 主文件
|--package.json                          工程配置
|--vue.config.js                         vue-cli 工程文件
|--src                                   源代码目录
|  |--pages                               
|  |  |--trtc                            演示 TRTC 以通话模式运行的示例代码，该模式下无角色的概念
|  |  |--live                            演示 TRTC 以直播模式运行的示例代码，该模式下有角色的概念
|  |--debug                              包含 GenerateTestUserSig，用于本地生成测试用的 UserSig  
```

<span id="step4"> </span>

### 步骤4：编译运行

#### Windows 平台

1.  安装 Node 最新版本，请参数[Nodejs 官网](https://nodejs.org/en/download/)

2.  启动终端，切换到 项目目录，执行以下命令。
	
    ```shell
    $ npm install
    ```
	
    

	>   !
	>
	>   如果 Electron 安装较慢甚至超时，您可以参考文章：[Electron 常见问题收录](#https://cloud.tencent.com/developer/article/1616668) 中的 “安装时遇到的问题” 章节和 “附录：手动离线安装 Electron” 章节来完成 Electron 安装。
	
	
	
4.  待 npm 的依赖包都安装完成后，继续在命令行窗口执行以下命令，运行 Demo。

    ```shell
    $ npm run start  # 首次运行，稍等片刻后，窗口中才会出现 UI
    ```
    
### 项目主要命令

| 命令 | 说明 |
|--|--|
| npm run start | 以开发环境运行 Demo |
| npm run pack:mac | 打包 Mac 的 .dmg 安装文件 |
| npm run pack:win64 | 打包 Windows 64 位的 .exe 安装文件 |

## 常见问题

### 1. 查看密钥时只能获取公钥和私钥信息，要如何获取密钥？

TRTC SDK 6.6 版本（2019年08月）开始启用新的签名算法 HMAC-SHA256。在此之前已创建的应用，需要先升级签名算法才能获取新的加密密钥。如不升级，您也可以继续使用 [老版本算法 ECDSA-SHA256](https://cloud.tencent.com/document/product/647/17275#.E8.80.81.E7.89.88.E6.9C.AC.E7.AE.97.E6.B3.95)。

升级操作：

1.  登录 [实时音视频控制台](https://console.cloud.tencent.com/trtc)。
2.  在左侧导航栏选择【应用管理】，单击目标应用所在行的【应用信息】。
3.  选择【快速上手】页签，单击【第二步 获取签发UserSig的密钥】区域的【点此升级】。

### 2. 两台设备同时运行 Demo，为什么看不到彼此的画面？

请确保两台设备在运行 Demo 时使用的是不同的 UserID，TRTC 不支持同一个 UserID （除非 SDKAppID 不同）在两个设备同时使用。

![img](https://main.qcloudimg.com/raw/209a0d0d5833d68c1ad46ed7e74b97e8.png)

### 3. 防火墙有什么限制？

由于 SDK 使用 UDP 协议进行音视频传输，所以对 UDP 有拦截的办公网络下无法使用，如遇到类似问题，请参考文档：[应对公司防火墙限制](https://cloud.tencent.com/document/product/647/34399)。


