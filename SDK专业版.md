## SDK 符号冲突

如果您的项目中已经使用过腾讯视频云 LiteAV 体系的相关产品，可能会出现符号冲突的问题（symbol duplicate）的问题，这是由于它们共同复用了相同的采集模块、编解码器、降噪模块、前处理等底层基础模块，所以才会出现符号重复。

![](https://main.qcloudimg.com/raw/9bcce79e250441f9aeb93756196e1a2e.png)

您可以下载腾讯视频 LiteAV_Professional 版本，该版本集成了以上 SDK 的全部功能，而且由于 60% 以上的底层模块是复用的，所以产生的安装包体积增量远远小于集成两个独立的 SDK（音视频 SDK 中的主要体积增量源于编解码等各种基础模块）。

## 专业版下载地址

- [**LiteAV_Professional_iOS_6.0.6400(framework)**](http://liteavsdk-1252463788.cosgz.myqcloud.com/6.0/TXLiteAVSDK_Professional_iOS_6.0.6400.zip)


- [**LiteAV_Professional_Android_6.0.6400(aar)**](http://liteavsdk-1252463788.cosgz.myqcloud.com/6.0/LiteAVSDK_Professional_Android_6.0.6400.aar)

- [**LiteAV_Professional_Android_6.0.6400(zip)**](http://liteavsdk-1252463788.cosgz.myqcloud.com/6.0/LiteAVSDK_Professional_Android_6.0.6400.zip)

