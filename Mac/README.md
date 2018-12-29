# TRTCSDK for Mac

## 使用步骤

### 1. 获取配置文件
首次使用需要导入userid和usersig的配置文件，否者将无法进房。配置文件可以通过访问[腾讯云TRTC控制台](https://console.cloud.tencent.com/rav) 中的【快速上手】页面来获取。
```json
{
"sdkappid":1400037025,
"users":[
{"userId":"Mac_trtc_01","userToken":"eJxlj0tPg0...ftdgUQ__"},
{"userId":"Mac_trtc_02","userToken":"eJxlj1FPgz...AkOAX*o_"},
{"userId":"Mac_trtc_03","userToken":"eJxlj11Pgz...BvsWX4I_"},
{"userId":"Mac_trtc_04","userToken":"eJxlj0tPg0...4xt*T2Cp"}]}
```

### 2. 编译运行

修改/config.json，写入从控制台获得的配置信息并编译运行。
