## 适用场景
TRTC 支持四种不同的进房模式，其中视频通话（VideoCall）和语音通话（VoiceCall）统称为[通话模式](https://cloud.tencent.com/document/product/647/32221)，视频互动直播（Live）和语音互动直播（VoiceChatRoom）统称为[直播模式](https://cloud.tencent.com/document/product/647/35429)。

直播模式下的 TRTC，支持单个房间最多10万人同时在线，具备小于 300ms 的连麦延迟和小于 1000ms 的观看延迟，以及平滑上下麦切换技术，适用低延时互动直播、十万人互动课堂、视频相亲、在线教育、远程培训、超大型会议等应用场景。

## 原理解析
TRTC 云服务由两种不同类型的服务器节点组成，分别是“接口机”和“代理机”：

- **接口机**
这些节点都采用最优质的线路和高性能的机器，善于处理端到端的低延时连麦通话，单位时长计费较高。

- **代理机**
这些节点都采用普通的线路和性能一般的机器，善于处理高并发的拉流观看需求，单位时长计费较低。

在直播模式下，TRTC 引入了角色的概念，用户被分成“主播”和“观众”两种角色，“主播”会被分配到接口机上，"观众"则被分配在代理机，同一个房间的观众人数上限为10万人。

如果”观众“要上麦，需要先切换角色（switchRole）为”主播”，然后才能发言。切换角色的过程也伴随着用户从代理机到接口机的迁移过程，会有一个切换过程。不过 TRTC 特有的低延时观看技术和平滑上下麦切换技术，让整个切换时间变得非常短暂。

![](https://main.qcloudimg.com/raw/b88a624c0bd67d5d58db331b3d64c51c.gif)

## 示例代码
访问 [Github](https://github.com/tencentyun/TRTCSDK/tree/master/iOS/TRTCSimpleDemo) 即可获取本文档相关的实例代码。
![](https://main.qcloudimg.com/raw/3ebba7cc07044073b9b1d6f10877b5b3.png)

## 使用步骤
<span id="step1"> </span>
### 步骤1：集成 SDK 到项目中

#### 使用 CocoaPods 集成
1. 确保您当前的开发环境已经安装了 **CocoaPods** ，具体可能参考[CocoaPods官网安装说明](https://guides.cocoapods.org/using/getting-started.html)
2. 打开您当前项目根目录下的 **Podfile** 文件（如果没有，可以执行 `pod init` 命令新建一个），添加如下内容
```
target 'Your Project' do
    pod 'TXLiteAVSDK_TRTC'
end
```
3. 执行 `pod install` 命令安装 **TRTC SDK** ，安装成功后当前项目根目录下会生成一个 **xcworkspace** 文件
4. 打开新生成的 **xcworkspace** 文件即可。

#### 下载 ZIP 包手动集成
如果您暂时不想安装 CocoaPods 环境，或者已经安装但是访问 CocoaPods 仓库比较慢，可以考虑在下载页面直接下载 [ZIP 压缩包](https://cloud.tencent.com/document/product/647/32689)，并按照集成文档 [手动集成](https://cloud.tencent.com/document/product/647/32173#.E6.89.8B.E5.8A.A8.E9.9B.86.E6.88.90) 到您的工程中。

<span id="step2"> </span>
### 步骤2：在工程文件中添加媒体设备权限
在 **Info.plist** 文件中添加摄像头和麦克风的申请权限

| Key | Value |
|---------|---------|
| Privacy - Camera Usage Description | 描述使用麦克风权限的原因，如：需要访问你的相机权限，开启后视频聊天才会有画面 |
| Privacy - Microphone Usage Description | 描述使用摄像头权限的原因，如：需要访问你的麦克风权限，开启后聊天才会有声音 |

<span id="step3"> </span>
### 步骤3：初始化 SDK 实例并监听事件回调

1. 使用 [sharedInstance()](https://cloud.tencent.com/document/product/647/32258) 接口创建 `TRTCCloud` 实例。
2. 设置 `delegate` 属性注册事件回调，并监听相关事件和错误通知。

```swift
// 示例代码：创建 TRTC 实例对象，并监听关键的 onError 消息
let trtcCloud: TRTCCloud = TRTCCloud.sharedInstance()
trtcCloud.delegate = self

func onError(_ errCode: TXLiteAVError,
                errMsg: String?, extInfo: [AnyHashable : Any]?) {
    toastTip("TRTC 出现错误：[\(errMsg ?? "")]")
}
```

<span id="step4"> </span>
### 步骤4：组装进房参数 TRTCParams
在调用 [enterRoom()](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#a96152963bf6ac4bc10f1b67155e04f8d) 接口时需要填写一个关键参数 [TRTCParams](http://doc.qcloudtrtc.com/group__TRTCCloudDef__ios.html#interfaceTRTCParams)，它包含如下四个必填的字段：sdkAppId、userId、userSig 和 roomId。

| 参数名称 | 填写示例 | 字段类型 | 补充说明 |
|---------|---------|---------|---------|
| sdkAppId | 1400000123 | 数字 | 应用ID，您可以在 [控制台](https://console.cloud.tencent.com/trtc/app) >【应用管理】>【应用信息】中查找到。 |
| userId | test_user_001 | 字符串 | 只允许包含大小写英文字母（a-zA-Z）、数字（0-9）及下划线和连词符。 |
| userSig | eJyrVareCeYrSy1SslI... | 字符串 | 基于 userId 可以计算出 userSig，计算方法请参见 [UserSig 计算](https://cloud.tencent.com/document/product/647/17275) 。|
| roomId | 29834 | 数字 | 默认不支持字符串类型的房间号，字符串类型的房间号会拖慢进房速度，如果您确实需要支持字符串类型的房间号，请通过工单联系我们。 |

>! TRTC 同一时间不支持两个相同的 userId 进入房间，否则会相互干扰。

<span id="step5"> </span>
### 步骤5：主播端开启摄像头预览和麦克风采音
1. 主播端调用 [startLocalPreview()](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#a3fc1ae11b21944b2f354db258438100e) 可以开启本地的摄像头预览，SDK 也会在此时向系统请求摄像头使用权限。
2. 主播端调用 [setLocalViewFillMode()](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#a961596f832657bfca81fd675878a2d15) 可以设定本地视频画面的显示模式，其中 Fill 模式代表填充，此时画面可能会被等比放大和裁剪，但不会有黑边。Fit 模式代表适应，此时画面可能会等比缩小以完全显示其内容，可能会有黑边。
3. 主播端调用 [setVideoEncoderParam()](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#a57938e5b62303d705da2ceecf119d74e) 接口可以设定本地视频的编码参数，该参数决定了房间里其他用户观看您的画面时所感受到的[画面质量](https://cloud.tencent.com/document/product/647/32236)。
4. 主播端调用 [startLocalAudio()](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#a3177329bc84e94727a1be97563800beb) 开启麦克风，SDK 也会在此时向系统请求麦克风使用权限。

```swift
//示例代码：发布本地的音视频流
trtcCloud.setLocalViewFillMode(TRTCVideoFillMode.fit)
trtcCloud.startLocalPreview(frontCamera, view: localView)
//设置本地视频编码参数
let encParams = TRTCVideoEncParam.init()
encParams.videoResolution = TRTCVideoResolution._960_540
encParams.videoBitrate    = 1200
encParams.videoFps        = 15
trtcCloud.setVideoEncoderParam(encParams)
trtcCloud.startLocalAudio()
```

<span id="step6"> </span>
### 步骤6：主播端设置美颜效果

1. 主播端调用 [getBeautyManager()](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#a4fb05ae6b5face276ace62558731280a) 可以获取美颜设置接口 [TXBeautyManager](http://doc.qcloudtrtc.com/group__TXBeautyManager__ios.html#interfaceTXBeautyManager)。
2. 主播端调用 [setBeautyStyle()](http://doc.qcloudtrtc.com/group__TXBeautyManager__ios.html#a8f2378a87c2e79fa3b978078e534ef4a) 可以设置美颜风格：`Smooth` 为类抖音的网红风格，`Nature` 风格给人的感觉会更加自然，`Pitu`风格仅 [企业版](https://cloud.tencent.com/document/product/647/32689#Enterprise) 才有提供。
3. 主播端调用 [setBeautyLevel()](http://doc.qcloudtrtc.com/group__TXBeautyManager__ios.html#af864d9466d5161e1926e47bae0e3f027) 可以设置磨皮的级别，一般设置为 5 即可。
4. 主播端调用 [setWhitenessLevel()](http://doc.qcloudtrtc.com/group__TXBeautyManager__ios.html#a199b265f6013e0cca0ff99f731d60ff4) 可以设置美白级别，一般设置为 5 即可。
5. 由于 iPhone 的摄像头调色默认偏黄，所以建议默认调用 [setFilter()](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#a1b0c2a9e82a408881281c7468a74f2c0) 为主播增加美白特效，美白特效所对应的滤镜文件的下载地址为：[滤镜文件下载](https://trtc-1252463788.cos.ap-guangzhou.myqcloud.com/filter/filterPNG.zip)。

![](https://main.qcloudimg.com/raw/61ef817e3c12944665f1b7098c584ee3.jpg)

<span id="step7"> </span>
### 步骤7：主播端创建房间并开始推流
1. 主播端设置 [TRTCParams](http://doc.qcloudtrtc.com/group__TRTCCloudDef__ios.html#interfaceTRTCParams) 中的字段 role 为 **TRTCRoleType.anchor** ，表示当前用户的角色为主播。
2. 主播端调用 [enterRoom()](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#a96152963bf6ac4bc10f1b67155e04f8d) 即可创建 TRTCParams 参数中 `roomId` 所指定的音视频房间，并指定 **appScene** 参数为 `TRTCAppScene.LIVE` 表示当前为视频互动直播模式（如果是语音互动直播场景，请设置 appScene 参数为 `TRTCAppScene.voiceChatRoom`）。
3. 如果房间创建成功，主播端也就同步开始了音视频数据的编码和传输流程。与此同时，SDK 会回调 [onEnterRoom(result)](http://doc.qcloudtrtc.com/group__TRTCCloudDelegate__ios.html#a6960aca54e2eda0f424f4f915908a3c5)  事件，参数 `result` 大于0时代表进房成功，数值表示加入房间所消耗的时间，单位为毫秒（ms）；当 `result` 小于0时代表进房失败，数值表示进房失败的错误码。

```swift
func enterRoom() {
    let params = TRTCParams.init()
    params.sdkAppId = sdkappid
    params.userId   = userid
    params.userSig  = usersig
    params.roomId   = 908
    trtcCloud.enterRoom(params, appScene: TRTCAppScene.LIVE)
}

func onEnterRoom(_ result: Int) {
    if result > 0 {
        toastTip("进房成功，总计耗时[\(result)]ms")
    } else {
        toastTip("进房失败，错误码[\(result)]")
    }
}
```

<span id="step8"> </span>
### 步骤8：观众端进入房间观看直播
1. 观众端设置 [TRTCParams](http://doc.qcloudtrtc.com/group__TRTCCloudDef__ios.html#interfaceTRTCParams) 中的字段 role 为 **TRTCRoleType.audience** ，表示当前用户的角色为观众。
2. 观众端调用 [enterRoom()](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#a96152963bf6ac4bc10f1b67155e04f8d) 即可进入 TRTCParams 参数中 `roomId` 所指定的音视频房间，并指定 **appScene** 参数为 `TRTCAppScene.LIVE` 表示当前为视频互动直播模式（如果是语音互动直播场景，请设置 appScene 参数为 `TRTCAppScene.voiceChatRoom`）。
3. 观看主播的画面：
- 如果观众端事先知道主播的 userId，直接在进房成功后调用 [startRemoteView(userId, view: view)](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#af85283710ba6071e9fd77cc485baed49) 即可显示主播的画面。
- 如果观众端不知道主播的 userId 也没有关系，因为观众端在进房成功后会收到 [onUserVideoAvailable()](http://doc.qcloudtrtc.com/group__TRTCCloudDelegate__ios.html#a533d6ea3982a922dd6c0f3d05af4ce80) 事件通知，之后用回调中获得的 `userId` 调用 [startRemoteView(userId, view: view)](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#af85283710ba6071e9fd77cc485baed49) 方法即可显示主播的画面。

<span id="step9"> </span>
### 步骤9：观众跟主播连麦
1. 观众端调用 [switch(TRTCRoleType.anchor)](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#a5f4598c59a9c1e66938be9bfbb51589c) 把当前角色切换为主播（TRTCRoleType.anchor）。
2. 观众端调用 [startLocalPreview()](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#a3fc1ae11b21944b2f354db258438100e) 可以开启本地的画面。
3. 观众端调用 [startLocalAudio()](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#a3177329bc84e94727a1be97563800beb) 开启麦克风采音。

```swift
//示例代码：观众上麦
trtcCloud.switch(TRTCRoleType.anchor)
trtcCloud.startLocalAudio()
trtcCloud.startLocalPreview(frontCamera, view: localView)

//示例代码：观众下麦
trtcCloud.switch(TRTCRoleType.audience)
trtcCloud.stopLocalAudio()
trtcCloud.stopLocalPreview()
```
<span id="step10"> </span>
### 步骤10：主播间进行跨房连麦 PK

TRTC 中两个不同音视频房间中的主播，可以通过“跨房通话”功能拉通连麦通话功能。使用此功能时， 两个主播无需退出各自原来的直播间即可进行“跨房连麦 PK”。

1. 主播 A 调用 [connectOtherRoom()](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#a062bc48550b479a6b7c1662836b8c4a5) 接口，接口参数目前采用 json 格式，需要将主播 B 的 roomId 和 userId 拼装成形如 `{"roomId": "978","userId": "userB"}` 的参数传递给接口函数。
2. 如果跨房成功，主播 A 会收到 [onConnectOtherRoom()](http://doc.qcloudtrtc.com/group__TRTCCloudDelegate__ios.html#a69e5b1d59857956f736c204fe765ea9a)  事件回调。与此同时，两个直播房间里的所有用户均会收到 [onUserVideoAvailable()](http://doc.qcloudtrtc.com/group__TRTCCloudDelegate__ios.html#a533d6ea3982a922dd6c0f3d05af4ce80)  和 [onUserAudioAvailable()](http://doc.qcloudtrtc.com/group__TRTCCloudDelegate__ios.html#a8c885eeb269fc3d2e085a5711d4431d5) 事件通知。
例如：当房间“001”中的主播 A 通过 `connectOtherRoom()` 跟房间“002”中的主播 B 拉通跨房通话后， 房间“001”中的用户都会收到主播 B 的 `onUserVideoAvailable(B, available: true)` 回调和 `onUserAudioAvailable(B, available: true)` 回调。 房间“002”中的用户都会收到主播 A 的 `onUserVideoAvailable(A, available: true)`  回调和 `onUserAudioAvailable(A, available: true)` 回调。
3. 两个房间里的用户通过调用 [startRemoteView(userId, view: view)](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#af85283710ba6071e9fd77cc485baed49) 即可显示另一房间里主播的画面，其声音是自动播放的。

```swift
//示例代码：跨房连麦 PK
let jsonDict = [ "roomId" : "978", "userId" : "userB" ]
guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict,
                 options: JSONSerialization.WritingOptions.prettyPrinted) else {
    fatalError("JSONSerialization failed")
}
let jsonString = String.init(data: jsonData, encoding: String.Encoding.utf8)
trtcCloud.connectOtherRoom(jsonString)
```

<span id="step11"> </span>
### 步骤11：正确的退出当前房间

调用 [exitRoom()](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#a715f5b669ad1d7587ae19733d66954f3) 方法退出房间，由于 SDK 在退房时需要关闭和释放摄像头和麦克风等硬件设备，因此退房动作不是瞬间完成的，需要等待 [onExitRoom()](http://doc.qcloudtrtc.com/group__TRTCCloudDelegate__ios.html#a6a98fcaac43fa754cf9dd80454897bea) 回调才算是真正退房结束。

```Objective-C
// 调用退房后请等待 onExitRoom 事件回调
trtcCloud.exitRoom()

func onExitRoom(_ reason: Int) {
    print("离开房间[\(roomId)]: reason[\(reason)]")
}
```

>! 如果您在您的 App 中同时集成了多个音视频 SDK，请在收到 onExitRoom 回调后再启动其它音视频 SDK，否则可能会遭遇硬件占用问题。

