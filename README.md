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

## 最新版本 7.5 @ 2020.07.31
TRTC 7.5 版本在如下方面做了改进和优化：
- 降低了端到端的连麦延时，7.5 版本的端到端通话和连麦延时在 7.4 版本的基础上缩短了 40%。
- 降低了移动端的耳返延时，并支持对耳返设置变声和混响等音效。

TRTC 7.5 版本的全部改动点包括：
- 全平台：优化播放端网络抖动评估算法，降低播放延迟
- 全平台：修复在一个函数中连续调用 playBGM 和 pauseBGM 后播放不生效的问题
- 全平台：修复偶现退房之后还能收到 onEnterRoom 回调的问题
- 全平台：支持对双栈 IPV6 和 IPV6 only 的支持
- 全平台：新增进多房间拉流能力，用于支持超级小班课
- 全平台：云端 MCU 混流支持设置背景图片（由于监管需要，图片必须先通过 TRTC 控制台进行上传）
- 全平台：云端 MCU 混流支持 A+B=>C 和 A+B=>A 两种模式
- 全平台：实时状态回调 onStatistics 增加播放缓冲时长字段 jitterBufferDelay
- Windows：修复屏幕分享高亮描边在高DPI情况下位置不对的问题
- Windows：修复窗口采集时，目标窗口最小化后高亮描边残留的问题
- Windows：优化采用竖屏分辨率推流时在部分摄像头上帧率极低的问题
- Windows：修复win7下屏幕分享鼠标闪烁的问题
- Windows：socks5代理支持用户名密码校验
- Android：降低 Android SDK 的端到端连麦通话延时
- Android：进一步优化耳返时延
- Android：优化播放view动态切换时画面黑屏的问题
- Android：修复部分机型对超低分辨率编码失败无法恢复的问题
- iOS：进一步优化耳返时延
- iOS：优化麦克风设备的打开成功率

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


