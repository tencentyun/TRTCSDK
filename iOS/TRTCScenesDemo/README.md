## 目录结构说明
本目录包含的是多个场景案例的 Demo 源代码，每一个案例都有 model 和 ui 两个文件夹：
- model 文件夹
- ui 文件夹

```
├─ TRTCScenesDemo // TRTC场景化Demo，包括视频通话、语音通话、视频互动直播、语音聊天室
|  │─ Podfile                    //Pod描述文件
|  │─ TXLiteAVDemo
|  │    ├─ App                   // 程序入口界面
|  │    ├─ AudioSettingKit       // 音效面板，包含BGM播放，变声，混响，变调等效果
|  │    ├─ BeautySettingKit      // 美颜面板，包含美颜，滤镜，动效等效果
|  │    ├─ Debug                 // 包含 GenerateTestUserSig，用于本地生成测试用的 UserSig
|  │    ├─ Login                 // 一个演示性质的简单登录界面
|  │    ├─ TRTCMeetingDemo       // 场景一：多人会议，类似腾讯会议，包含屏幕分享
|  │    ├─ TRTCVoiceRoomDemo     // 场景二：语音聊天室，也叫语聊房，多人音频聊天场景
|  │    ├─ TRTCLiveRoomDemo      // 场景三：互动直播，包含连麦、PK、聊天、点赞等特性
|  │    ├─ TRTCAudioCallDemo     // 场景四：音频通话，展示双人音频通话，有离线通知能力
|  │    ├─ TRTCVideoCallDemo     // 场景五：视频通话，展示双人视频通话，有离线通知能力
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

#### 步骤4：检查 SDK 是否存在
- **如果您使用 ZIP 压缩包**
如果您是直接下载的 zip 压缩包，解压后会发现 SDK 目录下已经包含了对应的 framework，此时您只需要用 XCode 打开 TXLiteAVDemo.xcworkspace 文件，并检查是否有正确引入 SDK 目录下的 framework 即可。

- **如果您克隆 Github 仓库**
如果您是从 Github 仓库上直接 clone 的源代码，会发现 SDK 目录下是空的，并不包含 framework。此时您可以直接在控制台中切换到 `Podfile` 所在目录，并执行如下命令以安装需要的 SDK：
  ```
  pod install
  ```
  或者使用以下命令更新本地的 SDK 版本：
  ```
  pod update
  ```

#### 步骤5：编译运行
使用 XCode （10.0 以上的版本，建议使用最新版Xcode） 打开源码目录下的 TXLiteAVDemo.xcworkspace 工程，设置有效的开发者签名，连接 iPhone／iPad 测试设备后，编译并运行 Demo 工程即可。
