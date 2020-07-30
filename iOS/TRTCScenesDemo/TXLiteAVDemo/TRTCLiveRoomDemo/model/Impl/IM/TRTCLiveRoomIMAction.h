//
//  TRTCLiveRoomIMAction.h
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/8.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImSDK/ImSDK.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *trtcLiveRoomProtocolVersion = @"1.0.0";

typedef NS_ENUM(NSUInteger, TRTCLiveRoomIMActionType) {
    TRTCLiveRoomIMActionTypeUnknown = 0,
    TRTCLiveRoomIMActionTypeRequestJoinAnchor = 100,
    TRTCLiveRoomIMActionTypeRespondJoinAnchor,
    TRTCLiveRoomIMActionTypeKickoutJoinAnchor,
    TRTCLiveRoomIMActionTypeNotifyJoinAnchorStream,
    
    TRTCLiveRoomIMActionTypeRequestRoomPK = 200,
    TRTCLiveRoomIMActionTypeRespondRoomPK,
    TRTCLiveRoomIMActionTypeQuitRoomPK,
    
    TRTCLiveRoomIMActionTypeRoomTextMsg = 300,
    TRTCLiveRoomIMActionTypeRoomCustomMsg,
    
    TRTCLiveRoomIMActionTypeUpdateGroupInfo = 400,
};

@class TRTCLiveUserInfo;
@class TRTCLiveRoomInfo;
@class TRTCCreateRoomParam;
typedef void(^LRIMCallback)(int code, NSString* message);
typedef void(^LREnterRoomCallback)(NSArray<TRTCLiveUserInfo *> *members, NSDictionary<NSString *, id> * customInfo, TRTCLiveRoomInfo * _Nullable roomInfo);
typedef void(^LRMemberCallback)(NSArray<TRTCLiveUserInfo *> *members);
typedef void(^LRRoomInfosCallback)(NSArray<TRTCLiveRoomInfo *> *roomInfos);

@interface TRTCLiveRoomIMAction : NSObject

+ (BOOL)setupSDKWithSDKAppID:(int)sdkAppId userSig:(NSString *)userSig messageLister:(id<V2TIMAdvancedMsgListener, V2TIMGroupListener>)listener;

+ (void)releaseSdk;

+ (void)loginWithUserID:(NSString *)userID userSig:(NSString *)userSig callback:(LRIMCallback _Nullable)callback;

+ (void)logout:(LRIMCallback _Nullable)callback;

+ (void)setProfileWithName:(NSString *)name avatar:(NSString *)avatar callback:(LRIMCallback  _Nullable)callback;

+ (void)createRoomWithRoomID:(NSString *)roomID roomParam:(TRTCCreateRoomParam *)roomParam success:(LREnterRoomCallback _Nullable)success error:(LRIMCallback _Nullable)errorCallback;

+ (void)destroyRoomWithRoomID:(NSString *)roomID callback:(LRIMCallback _Nullable)callback;

+ (void)enterRoomWithRoomID:(NSString *)roomID success:(LREnterRoomCallback _Nullable)success error:(LRIMCallback _Nullable)errorCallback;

+ (void)exitRoomWithRoomID:(NSString *)roomID callback:(LRIMCallback _Nullable)callback;

+ (void)getRoomInfoWithRoomIds:(NSArray<NSString *> *)roomIds success:(LRRoomInfosCallback _Nullable)success error:(LRIMCallback _Nullable)error;

+ (void)getAllMembersWithRoomID:(NSString *)roomID success:(LRMemberCallback _Nullable)success error:(LRIMCallback _Nullable)error;

#pragma mark - Action Message
+ (void)requestJoinAnchorWithUserID:(NSString *)userID reason:(NSString *)reason callback:(LRIMCallback _Nullable)callback;

+ (void)respondJoinAnchorWithUserID:(NSString *)userID agreed:(BOOL)agreed reason:(NSString *)reason callback:(LRIMCallback _Nullable)callback;

+ (void)kickoutJoinAnchorWithUserID:(NSString *)userID callback:(LRIMCallback _Nullable)callback;

+ (void)notifyStreamToAnchorWithUserId:(NSString *)userID streamID:(NSString *)streamID callback:(LRIMCallback _Nullable)callback;

+ (void)requestRoomPKWithUserID:(NSString *)userID fromRoomID:(NSString *)fromRoomID fromStreamID:(NSString *)fromStreamID callback:(LRIMCallback _Nullable)callback;

+ (void)responseRoomPKWithUserID:(NSString *)userID agreed:(BOOL)agreed reason:(NSString * _Nullable)reason streamID:(NSString *)streamID callback:(LRIMCallback _Nullable)callback;

+ (void)quitRoomPKWithUserID:(NSString *)userID callback:(LRIMCallback _Nullable)callback;

+ (void)sendRoomTextMsgWithRoomID:(NSString *)roomID message:(NSString *)message callback:(LRIMCallback _Nullable)callback;

+ (void)sendRoomCustomMsgWithRoomID:(NSString *)roomID command:(NSString *)command message:(NSString *)message callback:(LRIMCallback _Nullable)callback;

+ (void)updateGroupInfoWithRoomID:(NSString *)roomID groupInfo:(NSDictionary<NSString *, id> *)groupInfo callback:(LRIMCallback _Nullable)callback;

@end

NS_ASSUME_NONNULL_END
