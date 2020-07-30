//
//  TXVoiceRoomService.h
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/1.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXBaseDef.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ITXRoomServiceDelegate <NSObject>

- (void)onRoomDestroyWithRoomId:(NSString *)roomID;
- (void)onRoomRecvRoomTextMsg:(NSString *)roomID message:(NSString *)message userInfo:(TXVoiceRoomUserInfo *)userInfo;
- (void)onRoomRecvRoomCustomMsg:(NSString *)roomID cmd:(NSString *)cmd message:(NSString *)message userInfo:(TXVoiceRoomUserInfo *)userInfo;
- (void)onRoomInfoChange:(TXRoomInfo *)roomInfo;
- (void)onSeatInfoListChange:(NSArray<TXSeatInfo *> *)seatInfoList;
- (void)onRoomAudienceEnter:(TXVoiceRoomUserInfo *)userInfo;
- (void)onRoomAudienceLeave:(TXVoiceRoomUserInfo *)userInfo;
- (void)onSeatTakeWithIndex:(NSInteger)index userInfo:(TXVoiceRoomUserInfo *)userInfo;
- (void)onSeatCloseWithIndex:(NSInteger)index isClose:(BOOL)isClose;
- (void)onSeatLeaveWithIndex:(NSInteger)index userInfo:(TXVoiceRoomUserInfo *)userInfo;
- (void)onSeatMuteWithIndex:(NSInteger)index mute:(BOOL)isMute;
- (void)onReceiveNewInvitationWithIdentifier:(NSString *)identifier inviter:(NSString *)inviter cmd:(NSString *)cmd content:(NSString *)content;
- (void)onInviteeAcceptedWithIdentifier:(NSString *)identifier invitee:(NSString *)invitee;
- (void)onInviteeRejectedWithIdentifier:(NSString *)identifier invitee:(NSString *)invitee;
- (void)onInviteeCancelledWithIdentifier:(NSString *)identifier invitee:(NSString *)invitee;

@end

static int VOICE_ROOM_SERVICE_CODE_ERROR = -1;

@interface TXVoiceRoomService : NSObject

@property (nonatomic, weak) id<ITXRoomServiceDelegate> delegate;
@property (nonatomic, assign, readonly)BOOL isOwner;


+ (instancetype)sharedInstance;

- (void)loginWithSdkAppId:(int)sdkAppId userId:(NSString *)userId userSig:(NSString *)userSig callback:(TXCallback _Nullable)callback;
- (void)logout:(TXCallback _Nullable)callback;
- (void)getSelfInfo;
- (void)setSelfProfileWithUserName:(NSString *)userName
                         avatarUrl:(NSString *)avatarUrl
                          callback:(TXCallback _Nullable)callback;

- (void)createRoomWithRoomId:(NSString *)roomId
                    roomName:(NSString *)roomName
                    coverUrl:(NSString *)coverUrl
                 needRequest:(BOOL)needRequest
                seatInfoList:(NSArray<TXSeatInfo *> *)seatInfoList
                    callback:(TXCallback _Nullable)callback;

- (void)destroyRoom:(TXCallback _Nullable)callback;

- (void)enterRoom:(NSString *)roomId callback:(TXCallback _Nullable)callback;
- (void)exitRoom:(TXCallback _Nullable)callback;
- (void)takeSeat:(NSInteger)seatIndex callback:(TXCallback _Nullable)callback;
- (void)leaveSeat:(NSInteger)seatIndex callback:(TXCallback _Nullable)callback;
- (void)pickSeat:(NSInteger)seatIndex userId:(NSString *)userId callback:(TXCallback _Nullable)callback;
- (void)kickSeat:(NSInteger)seatIndex callback:(TXCallback _Nullable)callback;
- (void)muteSeat:(NSInteger)seatIndex mute:(BOOL)mute callback:(TXCallback _Nullable)callback;
- (void)closeSeat:(NSInteger)seatIndex isClose:(BOOL)isClose callback:(TXCallback _Nullable)callback;
- (void)getUserInfo:(NSArray<NSString *> *)userList callback:(TXUserListCallback _Nullable)callback;
- (void)sendRoomTextMsg:(NSString *)msg callback:(TXCallback _Nullable)callback;
- (void)sendRoomCustomMsg:(NSString *)cmd message:(NSString *)message callback:(TXCallback _Nullable)callback;
- (void)sendGroupMsg:(NSString *)message callback:(TXCallback _Nullable)callback;
- (void)getAudienceList:(TXUserListCallback _Nullable)callback;
- (void)getRoomInfoList:(NSArray<NSString *> *)roomIds calback:(TXRoomInfoListCallback _Nullable)callback;
- (void)destroy;
- (NSString *)sendInvitation:(NSString *)cmd userId:(NSString *)userId content:(NSString *)content callback:(TXCallback _Nullable)callback;
- (void)acceptInvitation:(NSString *)identifier callback:(TXCallback _Nullable)callback;
- (void)rejectInvitaiton:(NSString *)identifier callback:(TXCallback _Nullable)callback;
- (void)cancelInvitation:(NSString *)identifier callback:(TXCallback _Nullable)callback;

@end

NS_ASSUME_NONNULL_END
