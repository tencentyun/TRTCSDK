# TRTCSDK for iOS

## 使用步骤

### 1. 下载SDK

由于iOS SDK较大，不方便放在github。请先下载SDK的Zip包，解压后将TXLiteAVSDK_TRTC.framework拷贝至SDK目录。
[下载链接](http://trtc-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_TRTC_iOS_2.0.1668.zip)

### 2. 获取配置文件
首次使用需要导入userid和usersig的配置文件，否者将无法进房。配置文件可以通过访问[腾讯云TRTC控制台](https://console.cloud.tencent.com/rav) 中的【快速上手】页面来获取。
```json
{
"sdkappid":1400037025,
"users":[
{"userId":"iOS_trtc_01","userToken":"eJxlj0tPg0...ftdgUQ__"},
{"userId":"iOS_trtc_02","userToken":"eJxlj1FPgz...AkOAX*o_"},
{"userId":"iOS_trtc_03","userToken":"eJxlj11Pgz...BvsWX4I_"},
{"userId":"iOS_trtc_04","userToken":"eJxlj0tPg0...4xt*T2Cp"}]}
```

### 3. 编译运行

修改/config.json，写入从控制台获得的配置信息并编译运行。
