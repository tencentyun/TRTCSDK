//
//  TXBaseDef.h
//  TRTCVoiceRoomOCDemo
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

@class TXVoiceRoomUserInfo;
@class TXRoomInfo;

typedef void(^TXCallback)(int code, NSString *message);
typedef void(^TXUserListCallback)(int code, NSString *message, NSArray<TXVoiceRoomUserInfo *> *userInfos);
typedef void(^TXRoomInfoListCallback)(int code, NSString *message, NSArray<TXRoomInfo *> *roomInfos);

typedef NS_ENUM(NSUInteger, TXSeatStatus) {
    kTXSeatStatusUnused = 0,
    kTXSeatStatusUsed = 1,
    kTXSeatStatusClose = 2,
};

@interface TXRoomInfo : NSObject

@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, assign) UInt32 memberCount;

@property (nonatomic, strong) NSString *ownerId;
@property (nonatomic, strong) NSString *ownerName;
@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, strong) NSString *cover;
@property (nonatomic, assign) NSInteger seatSize;
@property (nonatomic, assign) NSInteger needRequest;

@end

@interface TXVoiceRoomUserInfo : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *avatarURL;

@end

@interface TXSeatInfo : NSObject

@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) BOOL mute;
@property (nonatomic, strong) NSString *user;

@end

@interface TXInviteData : NSObject

@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *command;
@property (nonatomic, strong) NSString *message;

@end

NS_ASSUME_NONNULL_END
