//
//  TRTCLiveRoom.swift
//  TRTCLiveRoom
//
//  Created by Xiaoya Liu on 2020/2/7.
//  Copyright © 2020 Xiaoya Liu. All rights reserved.
//

import UIKit

@objc public protocol TRTCLiveRoom: class {
    typealias Callback = (_ code: Int, _ message: String?) -> Void
    typealias ResponseCallback = (_ agreed: Bool, _ reason: String?) -> Void
    typealias RoomInfoCallback = (_ code: Int, _ message: String?, _ roomList: [TRTCLiveRoomInfo]) -> Void
    typealias UserListCallback = (_ code: Int, _ message: String, _ userList: [TRTCLiveUserInfo]) -> Void
    
    /// 登录到组件系统
    /// - Parameters:
    ///   - sdkAppID: TRTC SDKAppID
    ///   - userID: 用户ID
    ///   - userSig: 用户签名
    ///   - config: liveRoom的配置，登录时初始化，之后不可变更
    ///   - callback: 登录回调
    /// - Note:
    ///   - userSig 建议设定 7 天，能够有效规避 usersign 过期导致的 IM 收发消息失败、TRTC 连麦失败等情况
    @objc func login(sdkAppID: Int, userID: String, userSig: String, config: TRTCLiveRoomConfig, callback: Callback?)
    
    /// 用户登出
    /// - Parameter callback: 登出回调
    @objc func logout(_ callback: Callback?)
    
    /// 设置用户信息
    /// - Parameters:
    ///   - name: 用户昵称
    ///   - avatarURL: 用户头像地址
    ///   - callback: 设置回调
    @objc func setSelfProfile(name: String, avatarURL: String?, callback: Callback?)
    
    /// 主播创建房间
    /// 主播开播的正常调用流程是：
    /// 1.【主播】调用 startCameraPreview() 打开摄像头预览，此时可以调整美颜参数。
    /// 2.【主播】调用 createRoom() 创建直播间，房间创建成功与否会通过 TRTCLiveRoomDelegate 通知给主播。
    /// 3.【主播】调用 startPublish() 开始推流
    /// - Parameters:
    ///   - roomID: 房间ID
    ///   - roomInfo: 房间参数
    ///   - callback: 创建房间结果回调
    /// - Note:
    ///   - 主播开始直播的时候调用，可重复创建自己已创建过的房间。
    @objc func createRoom(roomID: UInt32, roomParam: TRTCCreateRoomParam, callback: Callback?)
    
    /// 主播销毁房间
    /// - Parameter callback: 销毁房间回调
    /// - Note:
    ///   - 主播结束直播的时候调用
    @objc func destroyRoom(callback: Callback?)
    
    /// 观众进入房间
    ///观众观看直播的正常调用流程是：
    ///1.【观众】通过业务后台拿到最新的直播房间列表。
    ///2.【观众】选择一个直播间以后，调用 enterRoom() 进入该房间。
    ///3.【观众】调用 startPlay() 播放主播的画面。
    /// - Parameters:
    ///   - roomID: 房间ID
    ///   - callback: 进入房间回调
    /// - Note:
    ///   - 观众进入直播房间的时候调用
    ///   - 主播不可调用这个接口进入自己已创建的房间，而要用createRoom
    @objc func enterRoom(roomID: UInt32, callback: Callback?)
    
    /// 观众离开房间
    /// - Parameter callback: 离开房间回调
    /// - Note:
    ///   - 观众离开直播房间的时候调用
    ///   - 主播不可调用这个接口离开房间
    @objc func exitRoom(callback: Callback?)
    
    /// 获取房间信息
    /// - Parameter roomIDs: 房间ID列表
    /// - Parameter callback: 房间信息回调
    @objc func getRoomInfos(roomIDs: [UInt32], callback: RoomInfoCallback?)
    
    /// 获取主播列表
    /// - Parameter callback: 主播列表回调
    @objc func getAnchorList(callback: UserListCallback?)
    
    /// 获取主播列表
    /// - Parameter callback: 观众列表回调
    @objc func getAudienceList(callback: UserListCallback?)
    
    /// 开启视频预览
    /// - Parameters:
    ///   - frontCamera: 使用前置摄像头
    ///   - view: 用来渲染主播画面的 View
    ///   - callback: 开启预览回调
    @objc func startCameraPreview(frontCamera: Bool, view: UIView, callback: Callback?)
    
    /// 关闭视频预览
    @objc func stopCameraPreview()
    
    /// 开启推流
    /// - Parameters:
    ///   - streamID: 自定义流ID，传空时系统会生成默认的流ID。这里也可以传入完整的 CDN 地址，用于转推流
    ///   - callback: 开启推流回调
    @objc func startPublish(streamID: String?, callback: Callback?)
    
    /// 关闭推流
    /// - Parameter callback: 关闭推流回调
    @objc func stopPublish(callback: Callback?)
    
    /// 播放主播画面
    /// - Parameters:
    ///   - userID: 主播用户ID
    ///   - view: 渲染画面用的view
    ///   - callback: 播放回调
    @objc func startPlay(userID: String, view: UIView, callback: Callback?)
    
    /// 停止播放主播画面
    /// - Parameters:
    ///   - userID: 主播用户ID
    ///   - callback: 停止播放回调
    @objc func stopPlay(userID: String, callback: Callback?)
    
    /**
     * 观众请求连麦
     *
     * 主播和观众的连麦流程可以简单描述为如下几个步骤：
     * 1. 【观众】调用 requestJoinAnchor() 向主播发起连麦请求。
     * 2. 【主播】会收到 TRTCLiveRoomDelegate onRequestJoinAnchor 的回调通知。
     * 3. 【主播】调用 responseJoinAnchor() 确定是否接受观众的连麦请求。
     * 4. 【观众】会收到 responseCallback  回调通知，可以得知请求是否被同意。
     * 5. 【观众】如果请求被同意，则调用 startCameraPreview() 开启本地摄像头。
     * 6. 【观众】然后调用 startPublish() 正式进入推流状态。
     * 7. 【主播】一旦观众进入连麦状态，主播就会收到 TRTCLiveRoomDelegate onAnchorEnter 通知。
     * 8. 【主播】主播调用 startPlay() 就可以看到连麦观众的视频画面。
     * 9. 【观众】如果直播间里已经有其他观众正在跟主播进行连麦，那么新加入的这位连麦观众也会收到 onAnchorEnter() 通知，用于展示（startPlay）其他连麦者的视频画面。
 * */
    
    /// 观众端请求连麦
    /// - Parameters:
    ///   - reason: 连麦请求原因
    ///   - responseCallback: 主播是否同意连麦的回调
    ///   - callback: 请求错误回调
    /// - Note: 观众发起请求后，主播端会收到`onRequestJoinAnchor`回调
    @objc func requestJoinAnchor(reason: String?, responseCallback: ResponseCallback?, callback: Callback?)
    
    /// 主播回复观众连麦请求
    /// - Parameters:
    ///   - user: 观众
    ///   - agree: 是否同意
    ///   - reason: 回复原因
    /// - Note: 主播回复后，观众端会收到`requestJoinAnchor`传入的`responseCallback`回调
    @objc func responseJoinAnchor(userID: String, agree: Bool, reason: String?)
    
    /// 主播将连麦观众下麦
    /// - Parameters:
    ///   - userID: 观众ID
    ///   - callback: 下麦回调
    /// - Note: 下麦后，被下麦的观众会收到`trtcLiveRoomOnKickoutJoinAnchor`回调
    @objc func kickoutJoinAnchor(userID: String, callback: Callback?)
    
    /**
        * 请求跨房 PK
        *
        * 主播和主播之间可以跨房间 PK，两个正在直播中的主播 A 和 B，他们之间的跨房 PK 流程如下：
        * 1. 【主播 A】调用 requestRoomPK() 向主播 B 发起连麦请求。
        * 2. 【主播 B】会收到 TRTCLiveRoomDelegate onRequestRoomPK 回调通知。
        * 3. 【主播 B】调用 responseRoomPK() 确定是否接受主播 A 的 PK 请求。
        * 4. 【主播 B】如果接受了主播 A 的要求，等待 TRTCLiveRoomDelegate onAnchorEnter 通知，然后调用 startPlay() 来显示主播 A 的视频画面。
        * 5. 【主播 A】会收到 responseCallback 回调通知，可以得知请求是否被同意。
        * 6. 【主播 A】如果请求被同意，等待 TRTCLiveRoomDelegate onAnchorEnter 通知，然后调用 startPlay() 来显示主播 B 的视频画面
        */
    
    /// 主播向另一个主播请求连麦PK
    /// - Parameters:
    ///   - roomID: 对方主播房间ID
    ///   - userID: 对方主播用户ID
    ///   - responseCallback: 对方主播是否同意跨房PK的回调
    ///   - callback: 跨房PK错误回调
    /// - Note: 发起请求后，对方主播会收到`onRequestRoomPK`回调
    @objc func requestRoomPK(roomID: UInt32, userID: String, responseCallback: ResponseCallback?, callback: Callback?)
    
    /// 主播回复跨房PK的请求
    /// - Parameters:
    ///   - user: 对方主播
    ///   - agree: 是否同意
    ///   - reason: 回复原因    /// - Note: 主播回复后，对方主播会收到`requestRoomPK`传入的`responseCallback`回调
    @objc func responseRoomPK(userID: String, agree: Bool, reason: String?)
    
    /// 主播退出连麦
    /// - Parameter callback: 退出连麦的回调
    /// - Note: 退出后，对方主播会收到`trtcLiveRoomOnQuitRoomPK`回调
    @objc func quitRoomPK(callback: Callback?)
    
    /// 切换前后摄像头
    @objc func switchCamera()
    
    /// 切换视频画面镜像
    /// - Parameter isMirror: 开启镜像
    @objc func setMirror(_ isMirror: Bool)
    
    /// 将麦克风静音
    /// - Parameter isMuted: 开启静音
    @objc func muteLocalAudio(_ isMuted: Bool)
    
    /// 将某个主播的声音静音
    /// - Parameters:
    ///   - userID: 主播ID
    ///   - isMuted: 开启静音
    @objc func muteRemoteAudio(userID: String, isMuted: Bool)
    
    /// 将所有主播的声音静音
    /// - Parameter isMuted: 开启静音
    @objc func muteAllRemoteAudio(_ isMuted: Bool)
    
    /// 发送文本消息，房间内所有成员都可见
    /// - Parameters:
    ///   - message: 文本消息
    ///   - callback: 发送回调
    @objc func sendRoomTextMsg(message: String, callback: Callback?)
    
    /// 发送自定义消息
    /// - Parameters:
    ///   - command: 命令字，由开发者自定义，主要用于区分不同消息类型
    ///   - message: 本文消息
    ///   - callback: 发送回调
    @objc func sendRoomCustomMsg(command: String, message: String, callback: Callback?)
    
    /// 开启渲染页面上的 Debug 信息
    /// - Parameter isShow: 开启 Debug 信息显示
    @objc func showVideoDebugLog(_ isShow: Bool)
    
    /* 美颜及动效参数管理
    *
    * 通过美颜管理，您可以使用以下功能：
    * - 设置"美颜风格"、“美白”、“红润”、“大眼”、“瘦脸”、“V脸”、“下巴”、“短脸”、“小鼻”、“亮眼”、“白牙”、“祛眼袋”、“祛皱纹”、“祛法令纹”等美容效果。
    * - 调整“发际线”、“眼间距”、“眼角”、“嘴形”、“鼻翼”、“鼻子位置”、“嘴唇厚度”、“脸型”
    * - 设置人脸挂件（素材）等动态效果
    * - 添加美妆
    * - 进行手势识别
    */
    @objc func getBeautyManager() -> TXBeautyManager
    
    /**
     * 设置指定素材滤镜特效
     *
     * @param image 指定素材，即颜色查找表图片。**必须使用 png 格式**
     */
    @objc func setFilter(image: UIImage)

    /**
     * 设置滤镜浓度
     *
     * 在美女秀场等应用场景里，滤镜浓度的要求会比较高，以便更加突显主播的差异。
     * 我们默认的滤镜浓度是0.5，如果您觉得滤镜效果不明显，可以使用下面的接口进行调节。
     *
     * @param concentration 从0到1，越大滤镜效果越明显，默认值为0.5。
     */
    @objc func setFilterConcentration(concentration: Float)

    /**
     * 设置绿幕背景视频（企业版有效，其它版本设置此参数无效）
     *
     * 此处的绿幕功能并非智能抠背，需要被拍摄者的背后有一块绿色的幕布来辅助产生特效
     *
     * @param file 视频文件路径。支持 MP4; nil 表示关闭特效。
     */
    @objc func setGreenScreenFile(file: URL?)
    
    /// 背景音乐管理实例
    @objc func getAudioEffectManager() -> TRTCAudioEffectManagerImpl
}
