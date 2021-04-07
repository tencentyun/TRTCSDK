//
//  TXChatSalonBaseDef.h
//  TRTCChatSalonOCDemo
//
//  Created by abyyxwang on 2020/6/30.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef DEBUG
#define TRTCLog(fmt, ...) NSLog((@"TRTC LOG:%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define TRTCLog(...)
#endif

@class TXChatSalonUserInfo;
@class TXChatSalonRoomInfo;

typedef void(^TXCallback)(int code, NSString *message);
typedef void(^TXUserListCallback)(int code, NSString *message, NSArray<TXChatSalonUserInfo *> *userInfos);
typedef void(^TXChatSalonRoomInfoListCallback)(int code, NSString *message, NSArray<TXChatSalonRoomInfo *> *roomInfos);

typedef NS_ENUM(NSUInteger, TXSeatStatus) {
    kTXSeatStatusUnused = 0,
    kTXSeatStatusUsed = 1,
    kTXSeatStatusClose = 2,
};

@interface TXChatSalonRoomInfo : NSObject

@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, assign) UInt32 memberCount;

@property (nonatomic, strong) NSString *ownerId;
@property (nonatomic, strong) NSString *ownerName;
@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, strong) NSString *cover;
@property (nonatomic, assign) NSInteger seatSize;
@property (nonatomic, assign) NSInteger needRequest;

@end

@interface TXChatSalonUserInfo : NSObject

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *avatarURL;

@end

@interface TXChatSalonSeatInfo : NSObject

@property (nonatomic, assign) BOOL mute;
@property (nonatomic, strong) NSString *user;

@end

@interface TXChatSalonInviteData : NSObject

@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *command;
@property (nonatomic, strong) NSString *message;

@end

@interface TXChatSalonSendInviteInfo : NSObject
@property (nonatomic, copy) NSString *cmd;
@property (nonatomic, copy) NSString *userID;

@end

NS_ASSUME_NONNULL_END
