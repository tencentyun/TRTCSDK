//
//  TRTCCall.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/2.
//

#import <Foundation/Foundation.h>
#import "TRTCCallingModel.h"
#import "TRTCCloud.h"

@import ImSDK;

NS_ASSUME_NONNULL_BEGIN

typedef void(^CallingActionCallback)(void);
typedef void(^ErrorCallback)(int code, NSString *des);

@protocol TRTCCallingDelegate;

@interface TRTCCalling : NSObject<TRTCCloudDelegate,V2TIMSignalingListener>

/// IM APNS推送ID
@property (nonatomic, assign) int imBusinessID;
/// 推送DeviceToken，需要在调用登录之前设置，否则APNS推送会设置失败
@property (nonatomic, strong) NSData *deviceToken;

/// 单例对象
+ (TRTCCalling *)shareInstance;

/// 设置TRTCCallingDelegate回调
/// @param delegate 回调实例
- (void)addDelegate:(id<TRTCCallingDelegate>)delegate;

/// 登录接口
/// @param sdkAppID SDK ID，可在腾讯云控制台获取
/// @param userID 用户ID
/// @param userSig 用户签名
/// @param success 成功回调
/// @param failed 失败回调
- (void)login:(UInt32)sdkAppID
         user:(NSString *)userID
      userSig:(NSString *)userSig
      success:(CallingActionCallback)success
       failed:(ErrorCallback)failed
NS_SWIFT_NAME(login(sdkAppID:user:userSig:success:failed:));


/// 登出接口
/// @param success 成功回调
/// @param failed 失败回调
- (void)logout:(CallingActionCallback)success
        failed:(ErrorCallback)failed
NS_SWIFT_NAME(logout(success:failed:));

/// 发起1v1通话接口
/// @param userID 被邀请方ID
/// @param type 通话类型：视频/语音
- (void)call:(NSString *)userID
        type:(CallType)type
NS_SWIFT_NAME(call(userID:type:));

/// 发起多人通话
/// @param userIDs 被邀请方ID列表
/// @param type 通话类型:视频/语音
/// @param groupID 群组ID，可选参数
- (void)groupCall:(NSArray *)userIDs
             type:(CallType)type
          groupID:(NSString * _Nullable)groupID
NS_SWIFT_NAME(groupCall(userIDs:type:groupID:));

/// 接受当前通话
- (void)accept;

/// 拒绝当前通话
- (void)reject;

/// 主动挂断通话
- (void)hangup;

///开启远程用户视频渲染
- (void)startRemoteView:(NSString *)userId view:(UIView *)view
NS_SWIFT_NAME(startRemoteView(userId:view:));

///关闭远程用户视频渲染
- (void)stopRemoteView:(NSString *)userId
NS_SWIFT_NAME(stopRemoteView(userId:));

///打开摄像头
- (void)openCamera:(BOOL)frontCamera view:(UIView *)view
NS_SWIFT_NAME(openCamera(frontCamera:view:));

///关闭摄像头
- (void)closeCamara;

///切换摄像头
- (void)switchCamera:(BOOL)frontCamera;

///静音操作
- (void)setMicMute:(BOOL)isMute;

///免提操作
- (void)setHandsFree:(BOOL)isHandsFree;

@end

@protocol TRTCCallingDelegate <NSObject>
@optional
/// sdk内部发生了错误 | sdk error
/// - Parameters:
///   - code: 错误码
///   - msg: 错误消息
-(void)onError:(int)code msg:(NSString * _Nullable)msg
NS_SWIFT_NAME(onError(code:msg:));
   
/// 被邀请通话回调 | invitee callback
/// - Parameter userIds: 邀请列表 (invited list)
-(void)onInvited:(NSString *)sponsor
         userIds:(NSArray<NSString *> *)userIds
     isFromGroup:(BOOL)isFromGroup
        callType:(CallType)callType
NS_SWIFT_NAME(onInvited(sponsor:userIds:isFromGroup:callType:));
   
/// 群聊更新邀请列表回调 | update current inviteeList in group calling
/// - Parameter userIds: 邀请列表 | inviteeList
-(void)onGroupCallInviteeListUpdate:(NSArray *)userIds
NS_SWIFT_NAME(onGroupCallInviteeListUpdate(userIds:));
   
/// 进入通话回调 | user enter room callback
/// - Parameter uid: userid
-(void)onUserEnter:(NSString *)uid
NS_SWIFT_NAME(onUserEnter(uid:));
   
/// 离开通话回调 | user leave room callback
/// - Parameter uid: userid
-(void)onUserLeave:(NSString *)uid
NS_SWIFT_NAME(onUserLeave(uid:));
   
/// 用户是否开启音频上行回调 | is user audio available callback
/// - Parameters:
///   - uid: 用户ID | userID
///   - available: 是否有效 | available
-(void)onUserAudioAvailable:(NSString *)uid available:(BOOL)available
NS_SWIFT_NAME(onUserAudioAvailable(uid:available:));
   
/// 用户是否开启视频上行回调 | is user video available callback
/// - Parameters:
///   - uid: 用户ID | userID
///   - available: 是否有效 | available
-(void)onUserVideoAvailable:(NSString *)uid available:(BOOL)available
NS_SWIFT_NAME(onUserVideoAvailable(uid:available:));
   
/// 用户音量回调
/// - Parameter uid: 用户ID | userID
/// - Parameter volume: 说话者的音量, 取值范围0 - 100
-(void)onUserVoiceVolume:(NSString *)uid volume:(UInt32)volume
NS_SWIFT_NAME(onUserVoiceVolume(uid:volume:));
   
/// 拒绝通话回调-仅邀请者受到通知，其他用户应使用 onUserEnter |
/// reject callback only worked for Sponsor, others should use onUserEnter)
/// - Parameter uid: userid
-(void)onReject:(NSString *)uid
NS_SWIFT_NAME(onReject(uid:));
   
/// 无回应回调-仅邀请者受到通知，其他用户应使用 onUserEnter |
/// no response callback only worked for Sponsor, others should use onUserEnter)
/// - Parameter uid: userid
-(void)onNoResp:(NSString *)uid
NS_SWIFT_NAME(onNoResp(uid:));
   
/// 通话占线回调-仅邀请者受到通知，其他用户应使用 onUserEnter |
/// linebusy callback only worked for Sponsor, others should use onUserEnter
/// - Parameter uid: userid
-(void)onLineBusy:(NSString *)uid
NS_SWIFT_NAME(onLineBusy(uid:));
   
// invitee callback

/// 当前通话被取消回调 | current call had been canceled callback
-(void)onCallingCancel:(NSString *)uid
NS_SWIFT_NAME(onCallingCancel(uid:));
   
/// 通话超时的回调 | timeout callback
-(void)onCallingTimeOut;
   
/// 通话结束 | end callback
-(void)onCallEnd;

@end

NS_ASSUME_NONNULL_END
