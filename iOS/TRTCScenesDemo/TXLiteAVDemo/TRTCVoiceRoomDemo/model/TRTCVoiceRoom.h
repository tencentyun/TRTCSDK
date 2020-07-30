//
//  TRTCVoiceRoom.h
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/6/30.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TRTCVoiceRoomDelegate.h"
#import "TRTCVoiceRoomDef.h"

NS_ASSUME_NONNULL_BEGIN

@class TXAudioEffectManager;
@interface TRTCVoiceRoom : NSObject

/**
* 获取 TRTCVoiceRoom 单例对象
*
* - returns: TRTCVoiceRoom 实例
* - note: 可以调用 {@link TRTCVoiceRoom#destroySharedInstance()} 销毁单例对象
*/
+ (instancetype)sharedInstance NS_SWIFT_NAME(shared());

/**
* 销毁 TRTCVoiceRoom 单例对象
*
* - note: 销毁实例后，外部缓存的 TRTCVoiceRoom 实例不能再使用，需要重新调用 {@link TRTCVoiceRoom#sharedInstance()} 获取新实例
*/
+ (void)destroySharedInstance NS_SWIFT_NAME(destroyShared());

#pragma mark: - 基础接口
/**
* 设置组件回调接口
* <p>
* 您可以通过 TRTCVoiceRoomDelegate 获得 TRTCVoiceRoom 的各种状态通知
*
* - parameter delegate 回调接口
* - note: TRTCVoiceRoom 中的回调事件，默认是在 Main Queue 中回调给您；如果您需要指定事件回调所在的队列，可使用 {@link TRTCVoiceRoom#setDelegateQueue(queue)}
*/
- (void)setDelegate:(id<TRTCVoiceRoomDelegate>)delegate NS_SWIFT_NAME(setDelegate(delegate:));

/**
* 设置事件回调所在的队列
*
* - parameter queue 队列，TRTCVoiceRoom 中的各种状态通知回调，会派发到您指定的queue。
*/
- (void)setDelegateQueue:(dispatch_queue_t)queue NS_SWIFT_NAME(setDelegateQueue(queue:));

/**
* 登录
*
* - parameter sdkAppID 您可以在实时音视频控制台 >【[应用管理](https://console.cloud.tencent.com/trtc/app)】> 应用信息中查看 SDKAppID
* - parameter userId   当前用户的 ID，字符串类型，只允许包含英文字母（a-z 和 A-Z）、数字（0-9）、连词符（-）和下划线（\_）
* - parameter userSig  腾讯云设计的一种安全保护签名，获取方式请参考 [如何计算 UserSig](https://cloud.tencent.com/document/product/647/17275)。
* - parameter callback 登录回调，成功时 code 为 0
*/
- (void)login:(int)sdkAppID
       userId:(NSString *)userId
      userSig:(NSString *)userSig
     callback:(ActionCallback _Nullable)callback NS_SWIFT_NAME(login(sdkAppID:userId:userSig:callback:));

/**
* 退出登录
*/
- (void)logout:(ActionCallback _Nullable)callback NS_SWIFT_NAME(logout(callback:));


/**
* 设置用户信息，您设置的用户信息会被存储于腾讯云 IM 云服务中。
*
* - parameter userName     用户昵称, 不能为nil
* - parameter avatarURL    用户头像
* - parameter callback     是否设置成功的结果回调
*/
- (void)setSelfProfile:(NSString *)userName avatarURL:(NSString *)avatarURL callback:(ActionCallback _Nullable)callback NS_SWIFT_NAME(setSelfProfile(userName:avatarURL:callback:));

#pragma mark - 房间管理接口
/**
* 创建房间（主播调用）
*
* 主播正常的调用流程是：
* 1. 主播调用`createRoom`创建新的语音聊天室，此时传入房间 ID、上麦是否需要房主确认、麦位数等房间属性信息。
* 2. 主播创建房间成功后，调用`enterSeat`进入座位。
* 3. 主播收到组件的`onSeatListChange`麦位表变化事件通知，此时可以将麦位表变化刷新到 UI 界面上。
* 4. 主播还会收到麦位表有成员进入的`onAnchorEnterSeat`的事件通知，此时会自动打开麦克风采集。
*
* - parameter roomID       房间标识，需要由您分配并进行统一管理。
* - parameter roomParam    房间信息，用于房间描述的信息，例如房间名称，封面信息等。如果房间列表和房间信息都由您的服务器自行管理，可忽略该参数。
* - parameter callback     创建房间的结果回调，成功时 code 为0.
*/
- (void)createRoom:(int)roomID roomParam:(VoiceRoomParam *)roomParam callback:(ActionCallback _Nullable)callback NS_SWIFT_NAME(createRoom(roomID:roomParam:callback:));

/**
* 销毁房间（主播调用）
*
* 主播在创建房间后，可以调用这个函数来销毁房间。
*/
- (void)destroyRoom:(ActionCallback _Nullable)callback NS_SWIFT_NAME(destroyRoom(callback:));

/**
* 进入房间（观众调用）
*
* 观众观看直播的正常调用流程如下：
* 1.【观众】向您的服务端获取最新的语音聊天室列表，可能包含多个直播间的 roomId 和房间信息。
* 2. 观众选择一个语音聊天室，调用`enterRoom`并传入房间号即可进入该房间。
* 3. 进房后会收到组件的`onRoomInfoChange`房间属性变化事件通知，此时可以记录房间属性并做相应改变，例如 UI 展示房间名、记录上麦是否需要请求主播同意等。
* 4. 进房后会收到组件的`onSeatListChange`麦位表变化事件通知，此时可以将麦位表变化刷新到 UI 界面上。
* 5. 进房后还会收到麦位表有主播进入的`onAnchorEnterSeat`的事件通知。
*
* - parameter roomID   房间标识
* - parameter callback 进入房间是否成功的结果回调
*/
- (void)enterRoom:(NSInteger)roomID callback:(ActionCallback _Nullable)callback NS_SWIFT_NAME(enterRoom(roomID:callback:));

/**
* 退出房间
*
* - parameter callback 退出房间是否成功的结果回调
*/
- (void)exitRoom:(ActionCallback _Nullable)callback NS_SWIFT_NAME(exitRoom(callback:));

/**
* 获取房间列表的详细信息
*
* 其中的信息是主播在创建 `createRoom()` 时通过 roomParam 设置进来的，如果房间列表和房间信息都由您的服务器自行管理，此函数您可以不用关心。
*
* - parameter roomIdList   房间号列表
* - parameter callback     房间详细信息回调
*/
- (void)getRoomInfoList:(NSArray<NSNumber *> *)roomIdList callback:(VoiceRoomInfoCallback _Nullable)callback NS_SWIFT_NAME(getRoomInfoList(roomIdList:callback:));

/**
* 获取指定userId的用户信息，如果为null，则获取房间内所有人的信息
*
* - parameter userIDList   用户id列表
* - parameter callback     用户详细信息回调
*/
- (void)getUserInfoList:(NSArray<NSString *> * _Nullable)userIDList callback:(VoiceRoomUserListCallback _Nullable)callback NS_SWIFT_NAME(getUserInfoList(userIDList:callback:));

#pragma mark - 麦位管理接口
/**
* 主动上麦（观众端和主播均可调用）
*
* 上麦成功后，房间内所有成员会收到`onSeatListChange`和`onAnchorEnterSeat`的事件通知。
*
* - parameter seatIndex    需要上麦的麦位序号
* - parameter callback     操作回调
*/
- (void)enterSeat:(NSInteger)seatIndex callback:(ActionCallback _Nullable)callback NS_SWIFT_NAME(enterSeat(seatIndex:callback:));

/**
* 主动下麦（观众端和主播均可调用）
*
* 下麦成功后，房间内所有成员会收到`onSeatListChange`和`onAnchorLeaveSeat`的事件通知。
*
* - parameter callback 操作回调
*/
- (void)leaveSeat:(ActionCallback _Nullable)callback NS_SWIFT_NAME(leaveSeat(callback:));

/**
* 抱人上麦(主播调用)
*
* 主播抱人上麦，房间内所有成员会收到`onSeatListChange`和`onAnchorEnterSeat`的事件通知。
*
* - parameter seatIndex    需要抱麦的麦位序号
* - parameter userId       用户id
* - parameter callback     操作回调
*/
- (void)pickSeat:(NSInteger)seatIndex userId:(NSString *)userId callback:(ActionCallback _Nullable)callback NS_SWIFT_NAME(pickSeat(seatIndex:userId:callback:));

/**
 * 踢人下麦(主播调用)
 *
 * 主播踢人下麦，房间内所有成员会收到`onSeatListChange`和`onAnchorLeaveSeat`的事件通知。
 *
 * - parameter seatIndex    需要踢下麦的麦位序号
 * - parameter callback     操作回调
 */
- (void)kickSeat:(NSInteger)seatIndex callback:(ActionCallback _Nullable)callback NS_SWIFT_NAME(kickSeat(seatIndex:callback:));

/**
* 静音/解禁对应麦位的麦克风(主播调用)
*
* - parameter seatIndex    麦位序号
* - parameter isMute       true : 静音，false : 解除静音
* - parameter callback     操作回调
*/
- (void)muteSeat:(NSInteger)seatIndex isMute:(BOOL)isMute callback:(ActionCallback _Nullable)callback NS_SWIFT_NAME(muteSeat(seatIndex:isMute:callback:));

/**
* 封禁/解禁某个麦位(主播调用)
*
* - parameter seatIndex    麦位序号
* - parameter isClose      true : 封禁，false : 解除封禁
* - parameter callback     操作回调
*/
- (void)closeSeat:(NSInteger)seatIndex isClose:(BOOL)isClose callback:(ActionCallback _Nullable)callback NS_SWIFT_NAME(closeSeat(seatIndex:isClose:callback:));

#pragma mark - 本地音频操作接口

/**
* 开启麦克风采集
*/
- (void)startMicrophone;

/**
* 停止麦克风采集
*/
- (void)stopMicrophone;

/**
* 设置音质
*
* - parameter quality TRTC_AUDIO_QUALITY_MUSIC/TRTC_AUDIO_QUALITY_DEFAULT/TRTC_AUDIO_QUALITY_SPEECH
*/
- (void)setAuidoQuality:(NSInteger)quality NS_SWIFT_NAME(setAuidoQuality(quality:));

/**
* 开启本地静音
*
* - parameter mute 是否静音
*/
- (void)muteLocalAudio:(BOOL)mute NS_SWIFT_NAME(muteLocalAudio(mute:));

/**
* 设置开启扬声器
*
* - parameter useSpeaker  true : 扬声器，false : 听筒
*/
- (void)setSpeaker:(BOOL)userSpeaker NS_SWIFT_NAME(setSpeaker(userSpeaker:));

/**
* 设置麦克风采集音量
*
* - parameter volume 采集音量 0-100
*/
- (void)setAudioCaptureVolume:(NSInteger)voluem NS_SWIFT_NAME(setAudioCaptureVolume(volume:));

- (void)setAudioPlayoutVolume:(NSInteger)volume NS_SWIFT_NAME(setAudioPlayoutVolume(volume:));

#pragma mark - 远端用户接口
/**
* 静音某一个用户的声音
*
* - parameter userId   用户id
* - parameter mute     true : 静音，false : 解除静音
*/
- (void)muteRemoteAudio:(NSString *)userId mute:(BOOL)mute NS_SWIFT_NAME(muteRemoteAudio(userId:mute:));

/**
* 静音所有用户的声音
*
* - parameter isMute true : 静音，false : 解除静音
*/
- (void)muteAllRemoteAudio:(BOOL)isMute NS_SWIFT_NAME(muteAllRemoteAudio(isMute:));

/**
* 音效控制相关
*/
- (TXAudioEffectManager * _Nullable)getAudioEffectManager;

#pragma mark - 消发送接口
/**
* 在房间中广播文本消息，一般用于弹幕聊天
*
* - parameter message  文本消息
* - parameter callback 发送结果回调
*/
- (void)sendRoomTextMsg:(NSString *)message callback:(ActionCallback _Nullable)callback NS_SWIFT_NAME(sendRoomTextMsg(message:callback:));

/**
* 在房间中广播自定义（信令）消息，一般用于广播点赞和礼物消息
*
* - parameter cmd      命令字，由开发者自定义，主要用于区分不同消息类型
* - parameter message  文本消息
* - parameter callback 发送结果回调
*/
- (void)sendRoomCustomMsg:(NSString *)cmd message:(NSString *)message callback:(ActionCallback _Nullable)callback NS_SWIFT_NAME(sendRoomCustomMsg(cmd:message:callback:));

#pragma mark - 邀请信令消息

/**
* 向用户发送邀请
*
* - parameter cmd      业务自定义指令
* - parameter userId   邀请的用户ID
* - parameter content  邀请的内容
* - parameter callback 发送结果回调
* - returns: inviteId 用于标识此次邀请ID
*/
- (NSString *)sendInvitation:(NSString *)cmd
                      userId:(NSString *)userId
                     content:(NSString *)content
                    callback:(ActionCallback _Nullable)callback NS_SWIFT_NAME(sendInvitation(cmd:userId:content:callback:));

/**
* 接受邀请
*
* - parameter identifier   邀请ID
* - parameter callback     接受操作的回调
*/
- (void)acceptInvitation:(NSString *)identifier callback:(ActionCallback _Nullable)callback NS_SWIFT_NAME(acceptInvitation(identifier:callback:));


/**
* 拒绝邀请
* - parameter identifier   邀请ID
* - parameter callback     接受操作的回调
*/
- (void)rejectInvitation:(NSString *)identifier callback:(ActionCallback _Nullable)callback NS_SWIFT_NAME(rejectInvitation(identifier:callback:));

/**
* 取消邀请
* - parameter identifier   邀请ID
* - parameter callback     接受操作的回调
*/
- (void)cancelInvitation:(NSString *)identifier callback:(ActionCallback _Nullable)callback NS_SWIFT_NAME(cancelInvitation(identifier:callback:));

@end

NS_ASSUME_NONNULL_END
