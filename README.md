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

## Version 8.0 @ 2020.11.13

**欢迎加入**

团队技术氛围浓厚，培训体系完善，产品线多样，有经验丰富的“老司机”手把手帮你入门音视频技术。<br>
北京、上海、深圳、广州均有岗位，如果您对音视频技术感兴趣，欢迎加入我们 [腾讯云 TRTC 研发团队](https://careers.tencent.com/jobdesc.html?postId=1297858141983088640) 。


**功能新增**
- 全平台 新增C++统一API，请参见 cpp_interface/ITRTCCloud.h
- 全平台 支持字符串房间号，请参见 TRTCParams.strRoomId
- 全平台 新增 TXDeviceManager 设备管理类
- 全平台 新增 API TRTCCloud.switchRoom，支持不停止采集，直接切换房间
- 全平台 新增 API TRTCCloud.startRemoteView 开始渲染远端视频画面
- 全平台 新增 API TRTCCloud.stopRemoteView 停止渲染远端视频画面
- 全平台 新增 API TRTCCloud.getDeviceManager 获取设备管理类 
- 全平台 新增 API TRTCCloud.startLocalAudio 开启本地音频的采集和上行
- 全平台 新增 API TRTCCloud.setRemoteRenderParams 设置远端图像的渲染配置
- 全平台 新增 API TRTCCloud.setLocalRenderParams 设置本地图像的渲染配置


**质量优化**
- Android 优化软硬解切换逻辑
- Windows 优化 System loopback 音频采集音质及回声消除效果
- Windows 优化音频设备选择逻辑，降低无声率
- Windows 优化双讲剪切效果
- 全平台 优化手动接收模式切换角色时的秒开效果
- 全平台 优化音频接收逻辑，提升音频效果
- 全平台 优化 sendCustomCmdMsg 可靠性

**问题修复**
- iOS 修复 muteLocalVideo 调用导致本地视频渲染暂停的问题
- iOS 修复在前后台切换时偶现调用系统组件可能导致卡死的问题
- iOS 修复开启音效时，耳返音频断断续续的问题
- Android 修复切通话音量播音效的时候电话打断，音效不会停止播放的问题
- Android 修复偶现音频采集启动失败的问题
- Windows 修复偶现本地视频渲染黑屏的问题
- Windows 修复进程退出时可能crash的问题
- Windows 优化蓝牙耳机支持，修复蓝牙耳机无声问题
- Windows 修复屏幕分享结束时抢焦点的问题
- 全平台 修复状态回调丢包率统计异常问题


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


