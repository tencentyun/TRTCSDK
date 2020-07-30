//
//  TRTCLiveRoomDef.h
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/7.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class V2TIMGroupMemberFullInfo;
typedef NS_ENUM(NSUInteger, TRTCLiveRoomLiveStatus) {
    TRTCLiveRoomLiveStatusNone = 0,
    TRTCLiveRoomLiveStatusSingle = 1, //单人房间
    TRTCLiveRoomLiveStatusLinkMic = 2, //连麦
    TRTCLiveRoomLiveStatusRoomPK = 3, //PK
};

@interface TRTCCreateRoomParam : NSObject
/// 【字段含义】房间名称
@property(nonatomic, strong)NSString *roomName;
/// 【字段含义】房间封面图
@property(nonatomic, strong)NSString *coverUrl;

-(instancetype)initWithRoomName:(NSString *)roomName
                       coverUrl:(NSString *)coverUrl;

@end


@interface TRTCLiveRoomConfig : NSObject
/// 【字段含义】观众端使用CDN播放
/// 【特殊说明】true: 默认进房使用CDN播放 false: 使用低延时播放
@property (nonatomic, assign) BOOL useCDNFirst;
/// 【字段含义】CDN播放的域名地址
@property(nonatomic, strong, nullable) NSString *cdnPlayDomain;

-(instancetype)initWithUseCDNFirst:(BOOL)userCDNFirst
                     cdnPlayDomain:(NSString * _Nullable)cdnPlayDomain;

@end

@interface TRTCLiveRoomInfo : NSObject
/// 【字段含义】房间唯一标识
@property(nonatomic, strong)NSString *roomId;
/// 【字段含义】房间名称
@property(nonatomic, strong)NSString *roomName;
/// 【字段含义】房间封面图
@property(nonatomic, strong)NSString *coverUrl;
/// 【字段含义】房主id
@property(nonatomic, strong)NSString *ownerId;
/// 【字段含义】房主昵称
@property(nonatomic, strong)NSString *ownerName;
/// 【字段含义】cdn模式下的播放流地址
@property(nonatomic, strong, nullable)NSString *streamUrl;
/// 【字段含义】房间人数
@property (nonatomic, assign) NSInteger memberCount;
/// 【字段含义】房间状态 /单人/连麦/PK
@property (nonatomic, assign) TRTCLiveRoomLiveStatus roomStatus;

- (instancetype)initWithRoomId:(NSString *)roomId
                      roomName:(NSString *)roomName
                      coverUrl:(NSString *)coverUrl
                       ownerId:(NSString *)ownerId
                     ownerName:(NSString *)ownerName
                     streamUrl:(NSString * _Nullable)streamUrl
                   memberCount:(NSInteger)memberCount
                    roomStatus:(TRTCLiveRoomLiveStatus)roomStatus;

@end

@interface TRTCLiveUserInfo : NSObject
/// 【字段含义】用户唯一标识
@property (nonatomic, copy) NSString *userId;
/// 【字段含义】用户昵称
@property (nonatomic, copy) NSString *userName;
/// 【字段含义】用户头像
@property (nonatomic, copy) NSString *avatarURL;
/// 【字段含义】cdn模式下的播放流id
@property (nonatomic, copy, nullable) NSString *streamId;
/// 【字段含义】是否是主播
@property (nonatomic, assign) BOOL isOwner;

- (instancetype)initWithProfile:(V2TIMGroupMemberFullInfo *)profile;



@end

typedef void(^Callback)(int code, NSString * _Nullable message);
typedef void(^ResponseCallback)(BOOL agreed, NSString * _Nullable reason);
typedef void(^RoomInfoCallback)(int code, NSString * _Nullable message, NSArray<TRTCLiveRoomInfo *> * roomList);
typedef void(^UserListCallback)(int code, NSString * _Nullable message, NSArray<TRTCLiveUserInfo *> * userList);

NS_ASSUME_NONNULL_END
