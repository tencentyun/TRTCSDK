# 腾讯云实时音视频终端组件 TRTC SDK
覆盖iOS、Android、Windows、Mac、浏览器和微信小程序六大应用平台，致力于提供全球最好的视频通话和直播连麦解决方案。

## 最新版本 6.3.7031 @ 2019.03.22

Android、iOS、Windows
1. 增加自定义视频采集接口: TRTCCloud >> sendCustomVideoData
2. 增加自定义音频采集接口: TRTCCloud >> sendCustomAudioData
3. 增加自定义视频渲染接口：TRTCCloud >> setLocalVideoRenderDelegate + setRemoteVideoRenderDelegate
4. 增加自定义音频数据回调接口：TRTCCloud >> setAudioFrameDelegate 支持：
  + 返回麦克风采集数据 TRTCAudioFrameDelegate >> onCapturedAudioFrame
  + 返回每一路远程用户的音频数据 TRTCAudioFrameDelegate >> onPlayAudioFrame
  + 返回混合后送入喇叭播放的音频数据 TRTCAudioFrameDelegate >>onMixedPlayAudioFrame


## API 文档及使用指引

| 所属平台 | Github 地址 | Demo运行说明 | SDK集成指引 | API 列表 |
|:---------:| :--------:|:--------:| :--------:|:--------:|
| iOS | [GitHub](https://github.com/tencentyun/TRTCSDK/tree/master/iOS)| [DOC](https://cloud.tencent.com/document/product/647/32396)| [DOC](https://cloud.tencent.com/document/product/647/32173) | [API](https://cloud.tencent.com/document/product/647/32258) |
| Android | [GitHub](https://github.com/tencentyun/TRTCSDK/tree/master/Android)| [DOC](https://cloud.tencent.com/document/product/647/32166)| [DOC](https://cloud.tencent.com/document/product/647/32175) | [API](https://cloud.tencent.com/document/product/647/32267) |
| Windows| [GitHub](https://github.com/tencentyun/TRTCSDK/tree/master/Windows)| [DOC](https://cloud.tencent.com/document/product/647/32397)| [DOC](https://cloud.tencent.com/document/product/647/32178) | [API](https://cloud.tencent.com/document/product/647/32268) |
| Mac| [GitHub](https://github.com/tencentyun/TRTCSDK/tree/master/Mac)| [DOC](https://cloud.tencent.com/document/product/647/32396)| [DOC](https://cloud.tencent.com/document/product/647/32176) |[API](https://cloud.tencent.com/document/product/647/32258) |
| Web | [GitHub](https://github.com/tencentyun/TRTCSDK/tree/master/H5)| [DOC](https://cloud.tencent.com/document/product/647/32398)| [DOC](https://cloud.tencent.com/document/product/647/16863) |[API](https://cloud.tencent.com/document/product/647/17249) |
| 微信小程序| [GitHub](https://github.com/tencentyun/TRTCSDK/tree/master/WXMini)| [DOC](https://cloud.tencent.com/document/product/647/32399)| [DOC](https://cloud.tencent.com/document/product/647/32183) |[API](https://cloud.tencent.com/document/product/647/17018) |

## iOS TRTC Demo
> [APPStore 体验地址](https://itunes.apple.com/cn/app/id1400663224?mt=8)

![](https://main.qcloudimg.com/raw/fa84e7c632b74483e9dc91dc04a8255e.jpg)

## Android TRTC Demo
> [应用宝体验地址](https://android.myapp.com/myapp/detail.htm?apkName=com.tencent.trtc&ADTAG=mobile)

![](https://main.qcloudimg.com/raw/41cbcff8ec2a64b6e76c2573abbb8acf.jpg)

## Mac TRTC Demo
> [下载后解压体验](http://trtc-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_Mac_Demo.tar.bz2)

![](https://main.qcloudimg.com/raw/8d146afb3b2dd07d5b5f1ca4432a9411.jpg)

## Windows TRTC Demo
> [下载后安装体验](http://trtc-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_Win_Demo.exe)

![](https://main.qcloudimg.com/raw/00ec3ebc86902044c51a5487c18dcd0c.jpg)

## 微信小程序

![](https://main.qcloudimg.com/raw/81662cce932b2500addac28baf6a83b3.jpg)

## Chrome浏览器

> [谷歌浏览器打开体验](https://sxb.qcloud.com/miniApp/?from=qcloud.com)

![](https://main.qcloudimg.com/raw/56e2bbc928a11bac85e5b78ac171b3bc.jpg)

## LiteAVSDK

![](https://main.qcloudimg.com/raw/1332cdccd195ef61848e0b588fd12c5c.jpg)

如果您的项目中已经使用过腾讯视频云 LiteAV 体系的相关产品，可能会出现符号冲突的问题（symbol duplicate）的问题。这是由于它们共同复用了相同的采集模块、编解码器、降噪模块、前处理等底层基础模块，所以才会出现符号重复。

您可以下载腾讯视频 LiteAV_Professional 版本，该版本集成了以上 SDK 的全部功能，而且由于 60% 以上的底层模块是复用的，所以产生的安装包体积增量远远小于集成两个独立的 SDK（音视频 SDK 中的主要体积增量源于编解码等各种基础模块）。

> [**专业版下载地址**](https://github.com/tencentyun/TRTCSDK/blob/master/SDK%E4%B8%93%E4%B8%9A%E7%89%88.md)
