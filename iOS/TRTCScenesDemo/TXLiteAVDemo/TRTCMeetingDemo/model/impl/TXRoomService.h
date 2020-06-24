//
//  TXRoomService.h
//  TRTCScenesDemo
//
//  Created by J J on 2020/5/29.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TRTCMeetingDef.h"

@protocol TXRoomServiceDelegate <NSObject>

- (void)onRoomDestroy:(NSString *_Nullable)roomId;
- (void)onRoomRecvRoomTextMsg:(NSString *_Nullable)roomId message:(NSString *_Nullable)message
                     userInfo:(TXUserInfo *_Nullable)userInfo;
- (void)onRoomRecvRoomCustomMsg:(NSString *_Nullable)roomId cmd:(NSString *_Nullable)cmd
                        message:(NSString *_Nullable)message userInfo:(TXUserInfo *_Nonnull)userInfo;
@end

typedef void(^TXCallback)(NSInteger code, NSString *_Nullable message);
typedef void(^TXUserListCallback)(NSInteger code, NSString *_Nullable message, NSArray <TXUserInfo*> *_Nullable userList);

NS_ASSUME_NONNULL_BEGIN

@interface TXRoomService : NSObject

@property (nonatomic, weak) id<TXRoomServiceDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)login:(NSInteger) sdkAppId userId:(NSString *)userId userSign:(NSString *)userSign callback:(TXCallback) callback;

- (void)logout:(TXCallback) callback;

- (void)setSelfProfile:(NSString *)userName avatarURL:(NSString *)avatarURL callback:(TXCallback) callback;

- (void)createRoom:(NSString *)roomId roomInfo:(NSString *)roomInfo coverUrl:(NSString *)coverUrl callback:(TXCallback) callback;

- (void)destroyRoom:(TXCallback) callback;

- (void)enterRoom:(NSString *)roomId callback:(TXCallback) callback;

- (void)exitRoom:(TXCallback) callback;

- (void)getUserInfo:(NSArray *)userList callback:(TXUserListCallback) callback;

- (void)sendRoomTextMsg:(NSString *)msg callback:(TXCallback) callback;

- (void)sendRoomCustomMsg:(NSString *)cmd message:(NSString *)message callback:(TXCallback) callback;

- (BOOL)isLogin;

- (BOOL)isEnterRoom;

- (NSString *)getOwnerUserId;

- (BOOL)isOwner;

@end

NS_ASSUME_NONNULL_END
