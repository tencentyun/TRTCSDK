# 腾讯云实时音视频终端组件 TRTC SDK

## 分流下载
腾讯云分流下载地址，适用于访问 Github 较慢的客户 ：[DOWNLOAD](https://github-1252463788.cos.ap-shanghai.myqcloud.com/trtcsdk/TRTCSDK-6.5.7272.zip)

## 最新版本 6.5.7272 @ 2019.06.12

### 新增特性
1. 【全平台】直播模式（TRTCAppSceneLIVE）新增“低延时大房间”功能：
   - 采用专为音视频优化过的 UDP 协议，超强抗弱网能力。
   - 平均观看延迟一秒作为，提升观众和主播之间的互动积极性。
   - 最多支持 10万人进入同一个房间。
2. 【全平台】优化音量评估算法（enableAudioVolumeEvaluation），音量评估更灵敏。
3. 【全平台】优化高延迟和高丢包网络环境下的 QoE 算法，增强弱网抗性。
4. 【Android】修复自定义渲染回调(setRemoteVideoRenderDelegate)，远端画面在分辨率是540P以上（包括540P）时只回调10次的bug。
5. 【全平台】优化onStatistics状态回调，仅回调存在的流
6. 【全平台】优化视频通话（TRTCAppSceneVideoCall）模式下的 QoE 算法，进一步提升 1v1 通话模式下的弱网流畅性。
7. 【全平台】修复偶现的 enterRoom 没有回调的 bug。
8. 【Android】优化解码器性能，修复超低端 Android 手机上延迟越来越高的bug。
9. 【全平台】优化弱网下音画不同步的 Bug。
10. 【全平台】优化先 muteLocalVideo 之后再取消播放端画面的恢复速度。
11. 【全平台】优化直播 TXLivePlayer 播放缓冲逻辑，降低卡顿率。
12. 【iOS】修复耳返只有一边有声音的bug。
13. 【Android】修复关闭音频采集之后，播放也没有声音的 bug。
14. 【Android】修复移除后再添加本地渲染 view 之后绿屏的 bug。
15. 【MAC】优化屏幕分享的画面清晰度。
16. 【Mac】支持音频外部采集发送数据。
17. 【Windows】优化屏幕分享的画面清晰度。
18. 【Windows】优化 SDK 体积，SDK 体积缩减为原来的 50%。
19. 【Windows】修复屏幕分享过程中直接退房，高亮窗口还残留的bug。

### 接口变更
1. 用户角色：TRTCParams 新增 role 属性，用于在进房时指明角色（主播、观众）。
2. 切换角色：switchRole，在房期间，动态切换主播、观众角色，用于观众和主播进行连麦。
3. 新增回调：切换角色成功或失败的回调 onSwitchRole。
4. 回调变更：onFirstVideoFrame 接口新增 streamType 参数，指明视频流类型。
5. Windows: getCurrentCameraDevice、getCurrentMicDevice、getCurrentSpeakerDevice 接口返回类型调整为 ITRTCDeviceInfo \*，支持 getDeviceName 和 getDevicePID


## API 文档指引

| 所属平台 | Github 地址 | Demo运行说明 | SDK集成指引 | API 列表 |
|:---------:| :--------:|:--------:| :--------:|:--------:|
| iOS | [GitHub](https://github.com/tencentyun/TRTCSDK/tree/master/iOS)| [DOC](https://cloud.tencent.com/document/product/647/32396)| [DOC](https://cloud.tencent.com/document/product/647/32173) | [API](https://cloud.tencent.com/document/product/647/32258) |
| Android | [GitHub](https://github.com/tencentyun/TRTCSDK/tree/master/Android)| [DOC](https://cloud.tencent.com/document/product/647/32166)| [DOC](https://cloud.tencent.com/document/product/647/32175) | [API](https://cloud.tencent.com/document/product/647/32267) |
| Windows| [GitHub](https://github.com/tencentyun/TRTCSDK/tree/master/Windows)| [DOC](https://cloud.tencent.com/document/product/647/32397)| [DOC](https://cloud.tencent.com/document/product/647/32178) | [API](https://cloud.tencent.com/document/product/647/32268) |
| Mac| [GitHub](https://github.com/tencentyun/TRTCSDK/tree/master/Mac)| [DOC](https://cloud.tencent.com/document/product/647/32396)| [DOC](https://cloud.tencent.com/document/product/647/32176) |[API](https://cloud.tencent.com/document/product/647/32258) |
| Web | [GitHub](https://github.com/tencentyun/TRTCSDK/tree/master/H5)| [DOC](https://cloud.tencent.com/document/product/647/32398)| [DOC](https://cloud.tencent.com/document/product/647/16863) |[API](https://cloud.tencent.com/document/product/647/17249) |
| 微信小程序| [GitHub](https://github.com/tencentyun/TRTCSDK/tree/master/WXMini)| [DOC](https://cloud.tencent.com/document/product/647/32399)| [DOC](https://cloud.tencent.com/document/product/647/32183) |[API](https://cloud.tencent.com/document/product/647/17018) |

## SDK 下载地址

> [**SDK 各版本下载地址（精简版、专业版、企业版）**](https://github.com/tencentyun/TRTCSDK/blob/master/SDK%E4%B8%8B%E8%BD%BD.md)

## Demo 体验地址

### iOS
> [APPStore 体验地址](https://itunes.apple.com/cn/app/id1400663224?mt=8)
![](https://main.qcloudimg.com/raw/fa84e7c632b74483e9dc91dc04a8255e.jpg)

### Android
> [应用宝体验地址](https://android.myapp.com/myapp/detail.htm?apkName=com.tencent.trtc&ADTAG=mobile)
![](https://main.qcloudimg.com/raw/41cbcff8ec2a64b6e76c2573abbb8acf.jpg)

### Mac OS
> [下载后解压体验](http://trtc-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_Mac_Demo.tar.bz2)
![](https://main.qcloudimg.com/raw/8d146afb3b2dd07d5b5f1ca4432a9411.jpg)

### Windows
> [下载后安装体验](http://trtc-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_Win_Demo.exe)
![](https://main.qcloudimg.com/raw/00ec3ebc86902044c51a5487c18dcd0c.jpg)

### 微信小程序
>![](https://main.qcloudimg.com/raw/81662cce932b2500addac28baf6a83b3.jpg)

### Web 网页
> [Chrome 打开体验](https://sxb.qcloud.com/miniApp/?from=qcloud.com)
![](https://main.qcloudimg.com/raw/56e2bbc928a11bac85e5b78ac171b3bc.jpg)


