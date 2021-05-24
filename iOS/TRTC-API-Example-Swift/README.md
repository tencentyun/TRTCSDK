## 目录结构说明
本目录包含的是最简单的示例代码，用于演示 TRTC 的接口如何调用，以及最基本的音视频功能。

```
├─ TRTCSimpleDemo // TRTC精简化Demo，包含通话模式和直播模式。
|  ├─ Live                       // 演示 TRTC 以直播模式运行的示例代码，该模式下有角色的概念
|  ├─ RTC                        // 演示 TRTC 以通话模式运行的示例代码，该模式下无角色的概念
|  ├─ Screen                     // 演示 TRTC 如何进行屏幕分享的示例代码
|  ├─ Debug                      // 包含 GenerateTestUserSig，用于本地生成测试用的 UserSig  
```

## 如何跑通Demo

#### 步骤1：检查环境要求
- Xcode 11.0及以上版本
- 请确保您的项目已设置有效的开发者签名

#### 步骤2：创建新的应用
1. 登录实时音视频控制台，选择【开发辅助】>【[快速跑通Demo](https://console.cloud.tencent.com/trtc/quickstart)】。
2. 单击【立即开始】，输入应用名称，例如`TestTRTC`，单击【创建应用】。
3. 单击【我已下载】，会看到页面上展示了您的 SDKAppID 和密钥。

#### 步骤3：修改工程中的 SDKAppID 和密钥
1. 打开 Debug 目录下的 [GenerateTestUserSig.h](debug/GenerateTestUserSig.h) 文件。
2. 配置`GenerateTestUserSig.h`文件中的两个参数：
  - SDKAPPID：替换该变量值为上一步骤中在页面上看到的 SDKAppID。
  - SECRETKEY：替换该变量值为上一步骤中在页面上看到的密钥。

>注意：
>本文提到的生成 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通 Demo 和功能调试**。
>正确的 UserSig 签发方式请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。

#### 步骤4：编译运行
使用 XCode（11.0及以上的版本）打开源码目录下的 TRTCSimpleDemo.xcworkspace 工程，设置有效的开发者签名，连接 iPhone／iPad 测试设备后，编译并运行 Demo 工程即可。
