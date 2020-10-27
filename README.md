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

## Version 7.9 @ 2020.10.27
**欢迎加入**

团队技术氛围浓厚，培训体系完善，产品线多样，有经验丰富的“老司机”手把手帮你入门音视频技术。<br>
北京、上海、深圳、广州均有岗位，如果您对音视频技术感兴趣，欢迎加入我们 [腾讯云 TRTC 研发团队](https://careers.tencent.com/jobdesc.html?postId=1297858141983088640) 。

**功能新增**
- Mac：屏幕分享支持过滤选定的窗口，用户可以将自己不希望分享出去的窗口排除掉，从而更好地保护用户的隐私。
- Windows：屏幕分享支持设置“正在分享”提示边框的描边颜色以及边框宽度。
- Windows：屏幕分享在分享整个桌面时支持开启高性能模式。
- 全平台：支持自定义加密：您可以对编码后的音视频数据通过暴露的 C 接口进行二次处理。
- 全平台：在 `TRTCRemoteStatistics` 中新增音频卡顿信息回调 `audioTotalBlockTime` 和 `audioBlockRate`。

**质量优化**
- iOS：优化了音频模块的启动速度，让首个音频帧可以更快地采集并发送出去。
- Windows：优化系统回采的回声消除算法，让开启系统回采（SystemLoopback）时有更好的回声消除能力。
- Windows：优化屏幕分享功能中的窗口采集抗遮挡能力，支持设置过滤窗口。
- Android：针对大部分 Android 机型进行了耳返效果的优化，使耳返延迟降低到一个更舒适的水平。
- Android：针对 Music 模式（在 startLocalAudio 时指定）下的点对点延迟进行了进一步的优化。
- 全平台：在手动订阅模式下，优化了观众和主播角色互切时的声音流畅度。
- 全平台：优化了音视频通话中的弱网抗性，在较差的网络下也能有更优质的音频流畅度。
- 全平台：修复部分偶现的崩溃问题，提升 SDK 的稳定性。

**问题修复**
- iOS：修复部分场景下偶现的视频画面不渲染问题。
- iOS：修复用户在戴耳机并且是 Default 音质下偶现的杂音问题。
- iOS：修复部分已知的内存泄露问题。
- iOS：修复偶现的 replaykit 扩展录屏结束后的 crash 问题。
- iOS：解决模拟器环境下的编译问题。
- Android：修复部分手机在 App 长时间切到后台，之后又再次切回前台时偶现的音画不同步问题。
- Android：修复切后台后没有释放麦克风的问题。
- Android：修复 SDK 内部部分 OpenGL 资源未及时释放的问题。
- Windows：修复个别场景下偶现的杂音问题。

更早期的版本更新历史请点击 [More](https://cloud.tencent.com/document/product/647/46907)...

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


