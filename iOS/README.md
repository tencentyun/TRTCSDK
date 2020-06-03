#### 实时音视频（TRTC）版SDK
实时音视频（TRTC）版SDK包含实时音视频（TRTC）和直播播放的能力。腾讯实时音视频（Tencent Real-Time Communication，TRTC）将腾讯21年来在网络与音视频技术上的深度积累，以多人音视频通话和低延时互动直播两大场景化方案，通过腾讯云服务向开发者开放，致力于帮助开发者快速搭建低成本、低延时、高品质的音视频互动解决方案。
实时音视频（TRTC）产品请参见：[实时音视频（TRTC）](https://cloud.tencent.com/product/trtc)

#### 目录结构

```
├─ TRTCScenceDemo // TRTC场景化Demo，包括视频通话、语音通话、视频互动直播、语音聊天室
├─ TRTCSimpleDemo // TRTC精简化Demo，包含通话模式和直播模式。
├─ SDK 
│  ├─ TXLiteAVSDK_TRTC.framework // TRTC依赖的动态库
```

#### SDK更新地址

[SDK更新地址](https://cloud.tencent.com/document/product/647/32689)


#### 版本更新记录

[版本更新记录](https://github.com/tencentyun/TRTCSDK/releases)

#### API文档

[实时音视频（TRTC）API文档](http://doc.qcloudtrtc.com/md_introduction_trtc_iOS_mac_%E6%A6%82%E8%A7%88.html)


#### TRTC场景化方案

| 场景 |Andorid平台| iOS平台 |
| ------ | ------ | ------ |
| 视频互动直播 | [Andorid](https://cloud.tencent.com/document/product/647/43182) | [iOS](https://cloud.tencent.com/document/product/647/43181) |
| 实时视频通话 |[Andorid](https://cloud.tencent.com/document/product/647/42045) | [iOS](https://cloud.tencent.com/document/product/647/42044) |
| 实时语音通话 | [Andorid](https://cloud.tencent.com/document/product/647/42047) | [iOS](https://cloud.tencent.com/document/product/647/42046) |


#### 体验地址

<table style="text-align:center;vertical-align:middle;">
  <tr>
    <th width="150px">iOS</th>
    <th width="150px">Android</th>
    <th width="150px">Mac OS</th>
    <th width="150px">Windows</th>
    <th width="150px">桌面浏览器</th>
    <th width="150px">微信小程序</th>
  </tr>
  <tr>
    <td><img src="https://main.qcloudimg.com/raw/b637949cbfc255ecefb060fafbfc70be.png" /></td>
    <td><img onclick="window.open('http://dldir1.qq.com/hudongzhibo/TRTC/Demo/TRTCDemo.apk')" style="display: block;cursor: pointer;" src="https://main.qcloudimg.com/raw/cb4c811e2f4dc4a7c9cc4f759e9ca86b.png" /></td>
    <td><a href="http://trtc-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_Mac_Demo.tar.bz2"><img src="https://main.qcloudimg.com/raw/e2acfcec98990f8e3b10e379b62b6ab6.jpg"></a></td>
    <td><a href="http://trtc-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_Win_Demo.exe"><img src="https://main.qcloudimg.com/raw/e2acfcec98990f8e3b10e379b62b6ab6.jpg"></a></td>
    <td><a href="https://trtc-1252463788.file.myqcloud.com/web/demo/official-demo/index.html"><img src="https://main.qcloudimg.com/raw/e2acfcec98990f8e3b10e379b62b6ab6.jpg"></a></td>
    <td><img src="https://main.qcloudimg.com/raw/7298c4c6297b3dc6d9fac973c52caf66.png" /></td>
  </tr>
</table>


#### 其他产品

- 短视频（UGSV）：[链接地址](https://cloud.tencent.com/product/ugsv)

- 播放器（Player）：[链接地址](https://cloud.tencent.com/product/player)


#### 各版本差异对照表

<table>
  <tr>
    <th width="100px" style="text-align:center">功能模块</th>
    <th width="100px" style="text-align:center">功能项</th>
    <th width="100px" style="text-align:center"><a href="https://cloud.tencent.com/document/product/454/7873">直播精简版</a><br>LiteAV_Smart</th>
    <th width="100px" style="text-align:center"><a href="https://cloud.tencent.com/document/product/584/9366">短视频版</a><br>LiteAV_UGC</th>
    <th width="100px" style="text-align:center"><a href="https://cloud.tencent.com/document/product/647/32689">TRTC版</a><br>LiteAV_TRTC</th>
    <th width="100px" style="text-align:center"><a href="https://cloud.tencent.com/document/product/881/20205">播放器版</a><br>LiteAV_Player</th>
    <th width="100px" style="text-align:center"><a href="#Professional">专业版</a><br>Professional</th>
    <th width="100px" style="text-align:center"><a href="#Enterprise">企业版</a><br>Enterprise</th>
  </tr>
  <tr>
    <td rowspan='2' style="text-align:center">直播推流</td>
    <td style="text-align:center">摄像头推流</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
  </tr>
   <tr>
    <td style="text-align:center">录屏推流</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
  </tr>
  <tr>
    <td rowspan='3' style="text-align:center">直播播放</td>
    <td style="text-align:center">RTMP 协议</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
  </tr>
  <tr>
    <td style="text-align:center">HTTP - FLV</td>
    <td style="text-align:center">&#10003;</td>
     <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
  </tr>
  <tr>
    <td style="text-align:center">HLS(m3u8)</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
  </tr>
  <tr>
    <td rowspan='3' style="text-align:center">点播播放</td>
    <td style="text-align:center">MP4 格式</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
  </tr>
   <tr>
    <td style="text-align:center">HLS(m3u8)</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
  </tr>
   <tr>
    <td style="text-align:center">DRM 加密</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
  </tr>
  <tr>
    <td rowspan='2' style="text-align:center">美颜滤镜</td>
    <td style="text-align:center">基础美颜</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
  </tr>
  <tr>
    <td style="text-align:center">基础滤镜</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
  </tr>
  <tr>
    <td rowspan='2' style="text-align:center">直播连麦</td>
    <td style="text-align:center">连麦互动</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
  </tr>
  <tr>
    <td style="text-align:center">跨房 PK</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
  </tr>
  <tr>
    <td rowspan='2' style="text-align:center">视频通话</td>
    <td style="text-align:center">双人通话</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
  </tr>
  <tr>
    <td style="text-align:center">视频会议</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
  </tr>
  <tr>
    <td rowspan='4' style="text-align:center">短视频</td>
    <td style="text-align:center">录制和拍摄</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
  </tr>
  <tr>
    <td style="text-align:center">裁剪拼接</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
  </tr>
  <tr>
    <td style="text-align:center">“抖音”特效</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
  </tr>
  <tr>
    <td style="text-align:center">视频上传</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
    <td style="text-align:center">&#10003;</td>
  </tr>
  <tr>
    <td rowspan='4' style="text-align:center">AI 美颜特效</td>
    <td style="text-align:center">大眼瘦脸</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
  </tr>
  <tr>
    <td style="text-align:center">V 脸隆鼻</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
  </tr>
  <tr>
    <td style="text-align:center">动效贴纸</td>
   <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
  </tr>
  <tr>
    <td style="text-align:center">绿幕抠图</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">-</td>
    <td style="text-align:center">&#10003;</td>
  </tr>
</table>
