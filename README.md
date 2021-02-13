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

## Version 8.4 @ 2021.02.08

**欢迎加入**
团队技术氛围浓厚，培训体系完善，产品线多样，有经验丰富的“老司机”手把手帮你入门音视频技术。<br>
北京、西安、上海、深圳、广州均有岗位，如果您对音视频技术感兴趣，欢迎加入我们 [腾讯云 TRTC 研发团队](https://careers.tencent.com/jobdesc.html?postId=1297858141983088640) 。

**功能新增**
1. Mac 版本开始支持采集 Mac 操作系统的输出声音，也就是跟 Windows 端一样的 SystemLoopback 能力，该功能可以让 SDK 采集当前系统的声音，开启这个功能后，主播就可以很方便地向其他用户直播音乐或者电影文件了。
2. Mac 版本屏幕分享开始支持本地预览功能，您可以通过一个小窗口向用户展示屏幕分享的预览内容。
3. Windows 版本增加进程音量调整能力，使用 [setApplicationPlayVolume](http://doc.qcloudtrtc.com/group__ITXDeviceManager__cplusplus.html#af6722fa5e6e45738e007004c374948b1) 可以设置系统的音量合成器的音量大小。
4. 全平台版本均新增本地音视频录制功能，主播可以在推流过程中把本地的音频和视频录制成一个 mp4 文件，参见 [startLocalRecording](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#a5075d55a6fc31895eedd5b23a1b8826b)
5. 全平台版本均优化了 [Music](http://doc.qcloudtrtc.com/group__TRTCCloudDef__ios.html#ga865e618ff3a81236f9978723c00e86fb) 模式下的声音质量，更加适合类似 cloubhouse 的语音直播场景。

**问题修复**
1. 全平台：优化音视频链路的网络抗性，在 70% 的极端查网络环境下，音视频依然较为流畅。
2. Windows：优化部分场景下的直播音质，大幅减少了声音损伤问题。
3. Windows：性能优化，在部分使用场景下的性能较旧版本有 20%-30% 的提升。
4. Windows：修复 Windows Server 2019 Datacenter x64 系统上启动桌面分享 crash 的问题。
5. Windows：修复分享窗口的同时改变目标窗口大小会偶发分享意外终止的 BUG。
6. Windows：修复部分型号的摄像头采集不出画面的问题。
7. iOS：修复 snapvideoshot 会造成 CAAnimation 动画卡顿的问题。
8. iOS&Mac：修复使用同一个 View 轮流显示摄像头和屏幕分享画面时，屏幕分享画面黑屏的问题。
9. iOS：修复使用第三方美颜组件时在 iPhone 6s 上可能会出现花屏的问题。
10. iOS：修复点播与 TRTC 同时使用时，在停止点播播放时偶现 crash 的问题。
11. Android：修复使用蓝牙耳机时被电话打断，拒绝接听电话后声音通过扬声器播放的问题。

更早期的版本更新历史请点击  [More](https://cloud.tencent.com/document/product/647/46907)...

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
