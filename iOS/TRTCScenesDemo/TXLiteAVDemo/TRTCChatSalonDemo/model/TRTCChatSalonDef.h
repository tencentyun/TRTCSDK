//
//  TRTCChatSalonDef.h
//  TRTCChatSalonOCDemo
//
//  Created by abyyxwang on 2020/6/30.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatSalonSeatInfo : NSObject
/// 【字段含义】座位是否被静音
@property (nonatomic, assign) BOOL mute;
/// 【字段含义】存储userID
@property (nonatomic, strong) NSString *userID;

@end

@interface ChatSalonParam : NSObject
/// 【字段含义】房间名称
@property (nonatomic, strong) NSString *roomName;
/// 【字段含义】房间封面图
@property (nonatomic, strong) NSString *coverUrl;
/// 【字段含义】是否需要房主确认上麦
@property (nonatomic, assign) BOOL needRequest;
/// 【字段含义】初始化的座位表，可以为nil
@property (nonatomic, strong) NSArray<ChatSalonSeatInfo *> *seatInfoList;


@end

@interface ChatSalonUserInfo : NSObject
/// 【字段含义】用户唯一标识
@property (nonatomic, strong) NSString *userID;
/// 【字段含义】用户昵称
@property (nonatomic, strong) NSString *userName;
/// 【字段含义】用户头像
@property (nonatomic, strong) NSString *userAvatar;

@end

@interface ChatSalonInfo : NSObject
/// 【字段含义】房间唯一标识
@property (nonatomic, assign) NSInteger roomID;
/// 【字段含义】房间名称
@property (nonatomic, strong) NSString *roomName;
/// 【字段含义】房间封面图
@property (nonatomic, strong) NSString *coverUrl;
/// 【字段含义】房主id
@property (nonatomic, strong) NSString *ownerId;
/// 【字段含义】房主昵称
@property (nonatomic, strong) NSString *ownerName;
/// 【字段含义】房间人数
@property (nonatomic, assign) NSInteger memberCount;
/// 【字段含义】是否需要房主确认上麦
@property (nonatomic, assign) BOOL needRequest;

-(instancetype)initWithRoomID:(NSInteger)roomID ownerId:(NSString *)ownerId memberCount:(NSInteger)memberCount;

@end

typedef void(^ActionCallback)(int code, NSString * _Nonnull message);
typedef void(^ChatSalonInfoCallback)(int code, NSString * _Nonnull message, NSArray<ChatSalonInfo * > * _Nonnull roomInfos);
typedef void(^ChatSalonUserListCallback)(int code, NSString * _Nonnull message, NSArray<ChatSalonUserInfo * > * _Nonnull userInfos);

typedef NS_ENUM(NSInteger, ChatSalonErrorCode) {
    ChatSalonErrorCodeInviteLimited   = -2,
};


NS_ASSUME_NONNULL_END
