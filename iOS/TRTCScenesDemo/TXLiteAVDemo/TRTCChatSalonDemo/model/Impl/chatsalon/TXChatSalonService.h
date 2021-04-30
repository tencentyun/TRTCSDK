//
//  TXChatSalonService.h
//  TRTCChatSalonOCDemo
//
//  Created by abyyxwang on 2020/7/1.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXChatSalonBaseDef.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ITXRoomServiceDelegate <NSObject>

- (void)onRoomDestroyWithRoomId:(NSString *)roomID;
- (void)onRoomRecvRoomTextMsg:(NSString *)roomID message:(NSString *)message userInfo:(TXChatSalonUserInfo *)userInfo;
- (void)onRoomRecvRoomCustomMsg:(NSString *)roomID cmd:(NSString *)cmd message:(NSString *)message userInfo:(TXChatSalonUserInfo *)userInfo;
- (void)onRoomInfoChange:(TXChatSalonRoomInfo *)roomInfo;
- (void)onSeatInfoListChange:(NSDictionary<NSString *, TXChatSalonSeatInfo *> *)seatInfoList;
- (void)onRoomAudienceEnter:(TXChatSalonUserInfo *)userInfo;
- (void)onRoomAudienceLeave:(TXChatSalonUserInfo *)userInfo;
- (void)onSeatTakeWithUserInfo:(TXChatSalonUserInfo *)userInfo;
- (void)onSeatLeaveWithUserInfo:(TXChatSalonUserInfo *)userInfo;
- (void)onSeatMuteWithUser:(NSString *)userID mute:(BOOL)isMute;
- (void)onReceiveNewInvitationWithIdentifier:(NSString *)identifier inviter:(NSString *)inviter cmd:(NSString *)cmd content:(NSString *)content;
- (void)onInviteeAcceptedWithIdentifier:(NSString *)identifier invitee:(NSString *)invitee;
- (void)onInviteeRejectedWithIdentifier:(NSString *)identifier invitee:(NSString *)invitee;
- (void)onInviteeCancelledWithIdentifier:(NSString *)identifier invitee:(NSString *)invitee;
- (void)onSeatKick;
- (void)onSeatPick;
- (void)onInvitationTimeout:(NSString *)inviteID;

@end

static int VOICE_ROOM_SERVICE_CODE_ERROR = -1;

@interface TXChatSalonService : NSObject

@property (nonatomic, weak) id<ITXRoomServiceDelegate> delegate;
@property (nonatomic, assign, readonly)BOOL isOwner;


+ (instancetype)sharedInstance;

- (void)loginWithSdkAppId:(int)sdkAppId userID:(NSString *)userID userSig:(NSString *)userSig callback:(TXCallback _Nullable)callback;
- (void)logout:(TXCallback _Nullable)callback;
- (void)getSelfInfo;
- (void)setSelfProfileWithUserName:(NSString *)userName
                         avatarUrl:(NSString *)avatarUrl
                          callback:(TXCallback _Nullable)callback;

- (void)createRoomWithRoomId:(NSString *)roomId
                    roomName:(NSString *)roomName
                    coverUrl:(NSString *)coverUrl
                 needRequest:(BOOL)needRequest
                    callback:(TXCallback _Nullable)callback;

- (void)destroyRoom:(TXCallback _Nullable)callback;

- (void)enterRoom:(NSString *)roomId callback:(TXCallback _Nullable)callback;

- (void)exitRoom:(TXCallback _Nullable)callback;

- (void)takeSeat:(TXCallback _Nullable)callback;

- (void)leaveSeat:(TXCallback _Nullable)callback;

- (void)pickSeat:(NSString *)userID callback:(TXCallback _Nullable)callback;

- (void)kickSeat:(NSString *)userID callback:(TXCallback)callback;

- (void)muteSeat:(NSString *)userID mute:(BOOL)mute callback:(TXCallback)callback;

- (void)getUserInfo:(NSArray<NSString *> *)userList callback:(TXUserListCallback _Nullable)callback;

- (void)sendRoomTextMsg:(NSString *)msg callback:(TXCallback _Nullable)callback;

- (void)sendRoomCustomMsg:(NSString *)cmd message:(NSString *)message callback:(TXCallback _Nullable)callback;

- (void)sendGroupMsg:(NSString *)message callback:(TXCallback _Nullable)callback;

- (void)getAudienceList:(TXUserListCallback _Nullable)callback;

- (void)getRoomInfoList:(NSArray<NSString *> *)roomIds calback:(TXChatSalonRoomInfoListCallback _Nullable)callback;

- (void)destroy;

- (NSString *)sendInvitation:(NSString *)cmd userID:(NSString *)userID content:(NSString *)content callback:(TXCallback _Nullable)callback;

- (void)acceptInvitation:(NSString *)identifier callback:(TXCallback _Nullable)callback;

- (void)rejectInvitaiton:(NSString *)identifier callback:(TXCallback _Nullable)callback;

- (void)cancelInvitation:(NSString *)identifier callback:(TXCallback _Nullable)callback;

- (void)onSeatTakeWithUser:(NSString *)userID;

- (void)onSeatLeaveWithUser:(NSString *)userID;

- (void)sendC2CCustomMessage:(NSString *)cmd to:(NSString *)userID callback:(TXCallback)callback;

@end

NS_ASSUME_NONNULL_END
