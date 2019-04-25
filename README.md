# 腾讯云实时音视频终端组件 TRTC SDK
覆盖iOS、Android、Windows、Mac、浏览器和微信小程序六大应用平台，致力于提供全球最好的视频通话和直播连麦解决方案。

## 最新版本 6.4.7110 @ 2019.04.25

全平台优化
1. 提升弱网环境下的流畅度。
3. 修复直播(TXLivePlayer)延时可能会升高且不恢复的bug。
4. 优化音量大小的回调算法，音量回调数值更加合理。
5. 发送自定义音频、视频数据支持外部指定数据帧时间戳。
6. 增加混流  setMixTranscodingConfig API 的设置回调函数。
7. 强化 setMixTranscodingConfig 接口，支持 roomID 参数，用于跨房连麦流混流。
8. 强化 setMixTranscodingConfig 接口，支持 pureAudio 参数，用于纯语音通话场景下的语音混流和录制。

Android
1. 增加商用企业版支持（增加大眼、瘦脸、V脸 和 动效挂架功能）。
1. 修复声音免提切换无效bug。
2. 优化低端 Android 设备上解码 720p 视频的性能问题。
3. 修复 Android 禁用麦克风权限后，没有错误回调bug。
5. 增加本地显示镜像和编码器输出镜像接口。
6. 修复直播场景setVideoEncoderRotation无效的bug。
7. 修复音量调节按钮无法调整观众端声音大小的问题。
8. 修复 Android 9.0 系统上 Demo 打开后弹窗的问题。

iOS、Mac
1. 修复符号重复bug。
2. iOS 优化低端机器性能。
3. iOS 增加商用企业版支持（增加大眼、瘦脸、V脸 和 动效挂架功能）。
4. 增加本地显示镜像和编码器输出镜像接口。
5. sendCustomVideoData 支持 NSData 数据格式。
6. 修复开启 Xcode 中 Dead Code Stripping 选项后编译失败的问题。

Windows
1. 新增基于 Duilib 库的全功能版本 Demo。
2. 优化摄像头配置选择策略，设备选择支持传 deviceId。
3. 修复设置日志路径为中文路径后日志文件位置异常bug。
4. 修复直播(TXLivePlayer) 播放混流和旁路直播流时音画不同步的bug。
5. 修复直播屏幕分享参数设置bug。
6. 优化美颜和渲染模块在部分 Windows 版本下的兼容和性能问题。


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

> [**SDK 下载地址**](https://github.com/tencentyun/TRTCSDK/blob/master/SDK%E4%B8%8B%E8%BD%BD.md)

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


