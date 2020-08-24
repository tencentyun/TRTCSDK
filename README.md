# 腾讯云实时音视频终端组件 TRTC SDK

## SDK 下载
访问 Github 较慢的客户可以考虑使用国内下载地址： [DOWNLOAD](https://cloud.tencent.com/document/product/647/32689) 。

| 所属平台 | Zip下载 | Demo运行说明 | SDK集成指引 | API 列表 |
|:---------:| :--------:|:--------:| :--------:|:--------:|
| iOS | [下载](http://liteavsdk-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_TRTC_iOS_latest.zip)| [DOC](https://cloud.tencent.com/document/product/647/32396)| [DOC](https://cloud.tencent.com/document/product/647/32173) | [API](https://cloud.tencent.com/document/product/647/32258) |
| Android | [下载](http://liteavsdk-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_TRTC_Android_latest.zip)| [DOC](https://cloud.tencent.com/document/product/647/32166)| [DOC](https://cloud.tencent.com/document/product/647/32175) | [API](https://cloud.tencent.com/document/product/647/32267) |
| Win(C++)| [下载](http://liteavsdk-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_TRTC_Win_latest.zip)| [DOC](https://cloud.tencent.com/document/product/647/32397)| [DOC](https://cloud.tencent.com/document/product/647/32178) | [API](https://cloud.tencent.com/document/product/647/32268) |
| Win(C#)| [下载](http://liteavsdk-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_TRTC_Win_latest.zip)| [DOC](https://cloud.tencent.com/document/product/647/32397)| [DOC](https://cloud.tencent.com/document/product/647/32178) | [API](https://cloud.tencent.com/document/product/647/36776) |
| Mac| [下载](http://liteavsdk-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_TRTC_Mac_latest.tar.bz2)| [DOC](https://cloud.tencent.com/document/product/647/32396)| [DOC](https://cloud.tencent.com/document/product/647/32176) |[API](https://cloud.tencent.com/document/product/647/32258) |
| Web | [下载](https://liteavsdk-1252463788.cosgz.myqcloud.com/H5_latest.zip)| [DOC](https://cloud.tencent.com/document/product/647/32398)| [DOC](https://cloud.tencent.com/document/product/647/16863) |[API](https://cloud.tencent.com/document/product/647/17249) |
| Electron | [下载](http://liteavsdk-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_TRTC_Electron_latest.zip) | [DOC](https://cloud.tencent.com/document/product/647/38548) | [DOC](https://cloud.tencent.com/document/product/647/38549) |[API](https://cloud.tencent.com/document/product/647/38551) |
| 微信小程序 | [下载](http://liteavsdk-1252463788.cosgz.myqcloud.com/TRTC_WXMini_latest.zip) | [DOC](https://cloud.tencent.com/document/product/647/32399) | [DOC](https://cloud.tencent.com/document/product/647/32183) |[API](https://cloud.tencent.com/document/product/647/17018) |

## 最新版本 7.6 @ 2020.08.21
TRTC 7.6 版本主要改进了 Windows 和 Mac 端的 SDK 稳定性，并优化了很多已知的无声和黑屏 BUG，全部升级点包括如下：
- 全平台：优化 enterRoom 的协议策略，提升加入房间的速度，并提高成功率。
- 全平台：优化同时订阅超多路音频时的总体性能消耗和卡顿问题。
- 全平台：修复在不退房的情况下进入同一个房间时，SDK 不触发 onEnterRoom 回的 BUG。
- 全平台：修复几种可能导致黑屏的偶现内部 BUG 的问题。
- 全平台：修复提前调用 startRemoteSubStreamView 无法正常显示屏幕分享画面的问题。
- Windows：新增 [updateLocalView](http://doc.qcloudtrtc.com/group__ITRTCCloud__cplusplus.html#ae5211a2739df8d8ec6017559b3aa0299) 和 [updateRemoteView](http://doc.qcloudtrtc.com/group__ITRTCCloud__cplusplus.html#a8c8247cbc679ea144ffb393b6b940c9e) 接口，用于优化实时调整 HWND 类型的渲染窗口时的体验。
- Windows：新增 [getCurrentMicDeviceMute](http://doc.qcloudtrtc.com/group__ITRTCCloud__cplusplus.html#a8a8badf62eee1021f9315f11df0f597f) 接口用于获取当前 Windows PC 是否被设置为静音。
- Windows：新增[setCurrentMicDeviceMute](http://doc.qcloudtrtc.com/group__ITRTCCloud__cplusplus.html#a8a8badf62eee1021f9315f11df0f597f) 接口用于将当前 Windows PC 设置为全局静音。
- Windows：修复已知的几处句柄及GDI泄露。
- Windows：修复多个已知的 Crash 问题。
- Windows 修复摄像头和麦克风拔掉后重新插入不会自动开启设备的问题。
- Mac：新增 [updateLocalView](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#abf20f249b4b43fff64f944b4aefe54cb) 和 [updateRemoteView](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#aa27f954e6301fb57a143b27429b63d87) 接口，用于优化实时调整 View 渲染区域时的体验。
- Mac：新增 [getCurrentMicDeviceMute](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#a6ba78519e9c98c1eecd365154882d53f) 接口用于获取当前 Mac 电脑是否被设置为静音。
- Mac：新增[setCurrentMicDeviceMute](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#a88569e62fe75b7ea98cc012169f22bfe) 接口用于将当前 Mac 电脑设置为全局静音。
- Mac：屏幕分享开始支持分享指定窗口的指定区域。
- iOS: 新增 [updateLocalView](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#abf20f249b4b43fff64f944b4aefe54cb) 和 [updateRemoteView](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#aa27f954e6301fb57a143b27429b63d87) 接口，用于优化实时调整 View 渲染区域时的体验。
- iOS：修复在 iOS10 上背景音乐接口在传入特定规则的文件路径时会崩溃的 BUG。
- iOS: 为 TRTCCloudDelegate 增加了 [onCapturedRawAudioFrame](http://doc.qcloudtrtc.com/group__TRTCCloudDelegate__ios.html#aeaeaf9e7091c75e1a072d576a57d7f5c) 回调，并修改了其他几个回调函数的名称，依次修改为 [onLocalProcessedAudioFrame](http://doc.qcloudtrtc.com/group__TRTCCloudDelegate__ios.html#a73a3e7de3c5c340957f119bb0f8744b0)、[onRemoteUserAudioFrame](http://doc.qcloudtrtc.com/group__TRTCCloudDelegate__ios.html#aa392c17c27bae1505f148bf541b7746a)和 [onMixedPlayAudioFrame](http://doc.qcloudtrtc.com/group__TRTCCloudDelegate__ios.html#a5a8a0bf6f8d02c33b2fe01c6175dfd4e)。
- Android：修复频繁快速的 enterRoom 和 exitRoom 后偶先的无声问题。
- Android：修复偶现的录屏推流黑屏的问题。
- Android：为 TRTCCloudListener 增加了 [onCapturedRawAudioFrame](http://doc.qcloudtrtc.com/group__TRTCCloudListener__android.html#abffd560f5b2b2322ea3980bc5a91d22e) 回调，并修改了其他几个回调函数的名称，依次修改为 [onLocalProcessedAudioFrame](http://doc.qcloudtrtc.com/group__TRTCCloudListener__android.html#a62c526c6c30a66671260bdf0c5c64e46)、[onRemoteUserAudioFrame](http://doc.qcloudtrtc.com/group__TRTCCloudListener__android.html#a4af98a7d668c150ea8e99e3085505902)和 [onMixedPlayAudioFrame](http://doc.qcloudtrtc.com/group__TRTCCloudListener__android.html#a580e94224357c38adf6ed883ab3321f7)。


## Demo 体验地址

### iOS
> [APPStore 体验地址](https://itunes.apple.com/cn/app/id1400663224?mt=8)
![](https://main.qcloudimg.com/raw/fa84e7c632b74483e9dc91dc04a8255e.jpg)

### Android
> [应用宝体验地址](https://android.myapp.com/myapp/detail.htm?apkName=com.tencent.trtc&ADTAG=mobile)
![](https://main.qcloudimg.com/raw/913eecbf69577de4e27d9bfe45acf80e.jpg)

### Mac OS
> [下载后解压体验](http://trtc-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_Mac_Demo.tar.bz2)
![](https://main.qcloudimg.com/raw/8d146afb3b2dd07d5b5f1ca4432a9411.jpg)

### Windows
> [下载后安装体验](http://trtc-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_Win_Demo.exe)
![](https://main.qcloudimg.com/raw/00ec3ebc86902044c51a5487c18dcd0c.jpg)

### 微信小程序
>![](https://main.qcloudimg.com/raw/81662cce932b2500addac28baf6a83b3.jpg)

### Web 网页
> [Chrome 打开体验](https://trtc-1252463788.file.myqcloud.com/web/demo/official-demo/index.html)
![](https://main.qcloudimg.com/raw/56e2bbc928a11bac85e5b78ac171b3bc.jpg)


