
## SDK镜像下载

考虑到 Github 的文件下载速度可能较慢，您可以从如下地址获得较快的下载速度：

| TRTC SDK(iOS)  | TRTC SDK(Android) | TRTC(Windows) | TRTC(Mac OS) | 
|:-------:|:-------:|:-------:|:-------:|
|  [**iOS静态库**](http://liteavsdk-1252463788.cosgz.myqcloud.com/6.0/TXLiteAVSDK_TRTC_iOS_6.0.6400.zip) | [**Android(aar)**](http://liteavsdk-1252463788.cosgz.myqcloud.com/6.0/LiteAVSDK_TRTC_6.0.6400.aar) & [**Android(jar)**](http://liteavsdk-1252463788.cosgz.myqcloud.com/6.0/LiteAVSDK_TRTC_6.0.6400.zip) |[**Windows(dll)**](http://liteavsdk-1252463788.cosgz.myqcloud.com/6.0/TXLiteAVSDK_TRTC_Win_6.0.6320.zip)|[**Mac组件库**](http://liteavsdk-1252463788.cosgz.myqcloud.com/6.0/TXLiteAVSDK_TRTC_Mac_6.0.6320.tar.bz2)|


## LiteAVSDK

TRTC SDK 隶属于腾讯视频云 LiteAV 体系，TRTC 擅长于低延时视频通话解决方案，与此同时，LiteAV 体系还提供了其它应用场景的解决方案：

| SDK压缩包名称 | 主要用途 | 包含功能 |
|:-------:|:-------:|:-------:|
| LiteAV_TRTC | [实时音视频](https://cloud.tencent.com/product/trtc) | 视频通话 |
| LiteAV_Smart | [移动直播](https://cloud.tencent.com/product/mlvb) | 直播推流和直播播放 |
| LiteAV_Player | [超级播放器](https://cloud.tencent.com/product/player) | 直播播放器和点播播放器 |
| LiteAV_UGC | [短视频](https://cloud.tencent.com/product/ugsv) | 视频录制、视频特效、视频上传等 |

## SDK符号冲突

如果您的项目中已经使用过腾讯视频云 LiteAV 体系的相关产品，可能会出现符号冲突的问题（symbol duplicate）的问题：

这是由于以上 SDK 均是基于腾讯视频云 LiteAV 架构开发的，它们共同复用了相同的采集模块、编解码器、降噪模块、前处理等底层基础模块，所以才会出现符号重复。

![](https://main.qcloudimg.com/raw/9bcce79e250441f9aeb93756196e1a2e.png)

您可以下载腾讯视频 LiteAV_Professional 版本，该版本集成了以上 SDK 的全部功能，而且由于 60% 以上的底层模块是复用的，所以产生的安装包体积增量远远小于集成两个独立的 SDK（音视频 SDK 中的主要体积增量源于编解码等各种基础模块）。

### 专业版下载地址

| 专业版（iOS）| 专业版（Android） | 
|:-------:|:-------:|
| [**LiteAV_Professional_iOS_6.0.6400**](http://liteavsdk-1252463788.cosgz.myqcloud.com/6.0/TXLiteAVSDK_Professional_iOS_6.0.6400.zip) | [**LiteAV_Professional_Adroid_6.0.6400**](http://liteavsdk-1252463788.cosgz.myqcloud.com/6.0/LiteAVSDK_Professional_Android_6.0.6400.zip)|


