//
//  TRTCChatSalon.m
//  TRTCChatSalonOCDemo
//
//  Created by abyyxwang on 2020/6/30.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TRTCChatSalon.h"
#import "ChatSalonTRTCService.h"
#import "TXChatSalonService.h"
#import "TXChatSalonCommonDef.h"
#import "TRTCCloud.h"
#import "AppLocalized.h"

@interface TRTCChatSalon ()<ChatSalonTRTCServiceDelegate, ITXRoomServiceDelegate>

@property (nonatomic, assign) int mSDKAppID;

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *userSig;
@property (nonatomic, strong) NSString *roomID;
@property (nonatomic, strong) NSMutableSet<NSString *> *anchorSeatList;
@property (nonatomic, strong) NSMutableSet<NSString *> *audienceList;
@property (nonatomic, strong) NSMutableDictionary<NSString *, ChatSalonSeatInfo *> *seatInfoList;
@property (nonatomic, assign) BOOL isTakeSeat;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *cachedMuteInfo;
@property (nonatomic, strong) NSMutableDictionary<NSString *, TXChatSalonSendInviteInfo *> *cachedSendInviteInfoDict;

@property (nonatomic, strong) ChatSalonInfo *roomInfo;

@property (nonatomic, weak) id<TRTCChatSalonDelegate> delegate;

@property (nonatomic, copy, nullable) ActionCallback enterSeatCallback;
@property (nonatomic, copy, nullable) ActionCallback leaveSeatCallback;
@property (nonatomic, copy, nullable) ActionCallback pickSeatCallback;
@property (nonatomic, copy, nullable) ActionCallback kickSeatCallback;

@property (nonatomic, weak)dispatch_queue_t delegateQueue;

@property (nonatomic, readonly)TXChatSalonService *roomService;
@property (nonatomic, readonly)ChatSalonTRTCService *roomTRTCService;

@end

@implementation TRTCChatSalon

static TRTCChatSalon *_instance;
static dispatch_once_t onceToken;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegateQueue = dispatch_get_main_queue();
        self.seatInfoList = [[NSMutableDictionary alloc] initWithCapacity:2];
        self.anchorSeatList = [[NSMutableSet alloc] initWithCapacity:2];
        self.audienceList = [[NSMutableSet alloc] initWithCapacity:2];
        self.cachedMuteInfo = [[NSMutableDictionary alloc] init];
        self.cachedSendInviteInfoDict = [[NSMutableDictionary alloc] init];
        self.isTakeSeat = NO;
        self.roomService.delegate = self;
        self.roomTRTCService.delegate =self;
    }
    return self;
}

- (TXChatSalonService *)roomService {
    return [TXChatSalonService sharedInstance];
}

- (ChatSalonTRTCService *)roomTRTCService {
    return [ChatSalonTRTCService sharedInstance];
}

- (BOOL)canDelegateResponseMethod:(SEL)method {
    return self.delegate && [self.delegate respondsToSelector:method];
}

#pragma mark - private method
- (BOOL)isOnSeatWithUserId:(NSString *)userID {
    return [self.anchorSeatList containsObject:userID];
}

- (void)runMainQueue:(void(^)(void))action {
    dispatch_async(dispatch_get_main_queue(), ^{
        action();
    });
}

- (void)runOnDelegateQueue:(void(^)(void))action {
    if (self.delegateQueue) {
        dispatch_async(self.delegateQueue, ^{
            action();
        });
    }
}

- (void)destroy {
    [self.roomService destroy];
}

- (void)clearList {
    [self.seatInfoList removeAllObjects];
    [self.anchorSeatList removeAllObjects];
    [self.audienceList removeAllObjects];
    [self.cachedMuteInfo removeAllObjects];
    [self.cachedSendInviteInfoDict removeAllObjects];
}

- (void)exitRoomInternal:(ActionCallback _Nullable)callback {
    @weakify(self)
    [self.roomTRTCService exitRoom:^(int code, NSString * _Nonnull message) {
        @strongify(self)
        if (!self) {
            return;
        }
        if (code != 0) {
            [self runOnDelegateQueue:^{
                if ([self canDelegateResponseMethod:@selector(onError:message:)]) {
                    [self.delegate onError:code message:message];
                }
            }];
        }
    }];
    TRTCLog(@"start exit room service");
    [self.roomService exitRoom:^(int code, NSString * _Nonnull message) {
        @strongify(self)
        if (!self) {
            return;
        }
        if (callback) {
            [self runOnDelegateQueue:^{
                callback(code, message);
            }];
        }
    }];
    [self clearList];
    self.roomID = @"";
}

- (void)getAudienceList:(ChatSalonUserListCallback _Nullable)callback {
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self.roomService getAudienceList:^(int code, NSString * _Nonnull message, NSArray<TXChatSalonUserInfo *> * _Nonnull userInfos) {
            TRTCLog(@"get audience list finish, code:%d, message:%@, userListCount:%d", code, message, userInfos.count);
            NSMutableArray *userInfoList = [[NSMutableArray alloc] initWithCapacity:2];
            for (TXChatSalonUserInfo* info in userInfos) {
                ChatSalonUserInfo* userInfo = [[ChatSalonUserInfo alloc] init];
                userInfo.userID = info.userID;
                userInfo.userName = info.userName;
                userInfo.userAvatar = info.avatarURL;
                [userInfoList addObject:userInfo];
            }
            if (callback) {
                [self runOnDelegateQueue:^{
                    callback(code, message, userInfoList);
                }];
            }
        }];
    }];
}

- (void)enterTRTCRoomInnerWithRoomId:(NSString *)roomId userID:(NSString *)userID userSign:(NSString *)userSig role:(NSInteger)role callback:(ActionCallback)callback {
    TRTCLog(@"start enter trtc room.");
    @weakify(self)
    [self.roomTRTCService enterRoomWithSdkAppId:self.mSDKAppID roomId:roomId userID:userID userSign:userSig role:role callback:^(int code, NSString * _Nonnull message) {
        @strongify(self)
        if (!self) {
            return;
        }
        if (callback) {
            [self runOnDelegateQueue:^{
                callback(code, message);
            }];
        }
    }];
}

#pragma mark - TRTCChatSalon 实现
+ (instancetype)sharedInstance {
    dispatch_once(&onceToken, ^{
        _instance = [[TRTCChatSalon alloc] init];
        [TXChatSalonService sharedInstance].delegate = _instance;
        [ChatSalonTRTCService sharedInstance].delegate = _instance;
    });
    return _instance;
}

+ (void)destroySharedInstance {
    onceToken = 0;
    _instance = nil;
}

- (void)setDelegate:(id<TRTCChatSalonDelegate>)delegate{
    self->_delegate = delegate;
}

- (void)setDelegateQueue:(dispatch_queue_t)queue {
    self->_delegateQueue = queue;
}

- (void)login:(int)sdkAppID userID:(NSString *)userID userSig:(NSString *)userSig callback:(ActionCallback)callback{
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        if (sdkAppID != 0 && userID && ![userID isEqualToString:@""] && userSig && ![userSig isEqualToString:@""]) {
            self.mSDKAppID = sdkAppID;
            self.userID = userID;
            self.userSig = userSig;
            TRTCLog(@"start login room service");
            [self.roomService loginWithSdkAppId:sdkAppID userID:userID userSig:userSig callback:^(int code, NSString * _Nonnull message) {
                @strongify(self)
                if (!self) {
                    return;
                }
                [self.roomService getSelfInfo];
                if (callback) {
                    [self runOnDelegateQueue:^{
                        callback(code, message);
                    }];
                }
            }];
        } else {
            TRTCLog(@"start login failed. params invalid.");
            callback(-1, @"start login failed. params invalid.");
        }
    }];
}

- (void)logout:(ActionCallback)callback {
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        TRTCLog(@"start logout");
        self.mSDKAppID = 0;
        self.userID = @"";
        self.userSig = @"";
        TRTCLog(@"start logout room service");
        [self.roomService logout:^(int code, NSString * _Nonnull message) {
            if (callback) {
                [self runOnDelegateQueue:^{
                    callback(code, message);
                }];
            }
        }];
    }];
}

- (void)setSelfProfile:(NSString *)userName avatarURL:(NSString *)avatarURL callback:(ActionCallback)callback{
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self.roomService setSelfProfileWithUserName:userName avatarUrl:avatarURL callback:^(int code, NSString * _Nonnull message) {
            if (callback) {
              [self runOnDelegateQueue:^{
                  callback(code, message);
              }];
            }
        }];
    }];
}

- (void)createRoom:(int)roomID roomParam:(ChatSalonParam *)roomParam callback:(ActionCallback)callback {
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self.roomService getSelfInfo];
        if (roomID == 0) {
            TRTCLog(@"crate room fail. params invalid.");
            if (callback) {
                callback(-1, @"create room fail. parms invalid.");
            }
            return;
        }
        self.roomID = [NSString stringWithFormat:@"%d", roomID];
        [self clearList];
        NSString* roomName = roomParam.roomName;
        NSString* roomCover = roomParam.coverUrl;
        BOOL isNeedrequest = roomParam.needRequest;
        [self.roomService createRoomWithRoomId:self.roomID
                                      roomName:roomName
                                      coverUrl:roomCover
                                   needRequest:isNeedrequest
                                      callback:^(int code, NSString * _Nonnull message) {
            @strongify(self)
            if (!self) {
                return;
            }
            if (code == 0) {
                [self enterTRTCRoomInnerWithRoomId:self.roomID userID:self.userID userSign:self.userSig role:kTRTCRoleAnchorValue callback:^(int code, NSString * _Nonnull message) {
                    [self.roomTRTCService switchToAnchor:^(int code, NSString * _Nonnull message) {
                        if (code == 0) {
                            [self.roomService onSeatTakeWithUser:self.userID];
                        }
                    }];
                    
                    if (callback) {
                        callback(code, message);
                    }
                }];
                
                return;
            } else {
                [self runOnDelegateQueue:^{
                    if ([self canDelegateResponseMethod:@selector(onError:message:)]) {
                        [self.delegate onError:code message:message];
                    }
                }];
            }
            if (callback) {
                callback(code, message);
            }
        }];
    }];
}

- (void)destroyRoom:(ActionCallback)callback{
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        TRTCLog(@"start destroyu room.");
        [self.roomTRTCService exitRoom:^(int code, NSString * _Nonnull message) {
            @strongify(self)
            if (!self) {
                return;
            }
            if (code != 0) {
                if ([self canDelegateResponseMethod:@selector(onError:message:)]) {
                    [self.delegate onError:code message:message];
                }
            }
        }];
        [self.roomService exitRoom:^(int code, NSString * _Nonnull message) {
            @strongify(self)
            if (!self) {
                return;
            }
            if (code != 0) {
                if ([self canDelegateResponseMethod:@selector(onError:message:)]) {
                    [self.delegate onError:code message:message];
                }
            }
        }];
        [self.roomService destroyRoom:^(int code, NSString * _Nonnull message) {
            @strongify(self)
            if (!self) {
                return;
            }
            TRTCLog(@"destroy room finish, code:%d, message: %@", code, message);
            if (callback) {
                [self runOnDelegateQueue:^{
                    callback(code, message);
                }];
            }
        }];
        [self clearList];
    }];
}

- (void)enterRoom:(NSInteger)roomID callback:(ActionCallback)callback {
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self clearList];
        self.roomID = [NSString stringWithFormat:@"%ld", (long)roomID];
        TRTCLog(@"start enter room, room id is %ld", (long)roomID);
        
        [self.roomService enterRoom:self.roomID callback:^(int code, NSString * _Nonnull message) {
            @strongify(self)
            if (!self) {
                return;
            }
            if (code != 0) {
                [self runOnDelegateQueue:^{
                    if ([self canDelegateResponseMethod:@selector(onError:message:)]) {
                        [self.delegate onError:code message:message];
                    }
                }];
            } else {
                [self enterTRTCRoomInnerWithRoomId:self.roomID userID:self.userID userSign:self.userSig role:kTRTCRoleAudienceValue callback:^(int code, NSString * _Nonnull message) {
                    @strongify(self)
                    if (!self) {
                        return;
                    }
                    if (callback) {
                        [self runMainQueue:^{
                            callback(code, message);
                        }];
                    }
                }];
            }
        }];
    }];
}

- (void)exitRoom:(ActionCallback)callback {
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        TRTCLog(@"start exit room");
        if ([self isOnSeatWithUserId:self.userID]) {
            [self leaveSeat:^(int code, NSString * _Nonnull message) {
                @strongify(self)
                if (!self) {
                    return;
                }
                [self exitRoomInternal:callback];
            }];
        } else {
            [self exitRoomInternal:callback];
        }
    }];
}

- (void)getRoomInfoList:(NSArray<NSNumber *> *)roomIdList callback:(ChatSalonInfoCallback)callback {
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        TRTCLog(@"start get room info:%@", roomIdList);
        NSMutableArray* roomIds = [[NSMutableArray alloc] initWithCapacity:2];
        for (NSNumber *roomId in roomIdList) {
            [roomIds addObject:[roomId stringValue]];
        }
        [self.roomService getRoomInfoList:roomIds calback:^(int code, NSString * _Nonnull message, NSArray<TXChatSalonRoomInfo *> * _Nonnull roomInfos) {
            if (code == 0) {
                TRTCLog(@"roomInfos: %@", roomInfos);
                NSMutableArray* trtcRoomInfos = [[NSMutableArray alloc] initWithCapacity:2];
                for (TXChatSalonRoomInfo *info in roomInfos) {
                    if ([info.roomId integerValue] != 0) {
                        ChatSalonInfo *roomInfo = [[ChatSalonInfo alloc] init];
                        roomInfo.roomID = [info.roomId integerValue];
                        roomInfo.ownerId = info.ownerId;
                        roomInfo.memberCount = info.memberCount;
                        roomInfo.roomName = info.roomName;
                        roomInfo.coverUrl = info.cover;
                        roomInfo.ownerName = info.ownerName;
                        roomInfo.needRequest = info.needRequest == 1;
                        [trtcRoomInfos addObject:roomInfo];
                    }
                }
                if (callback) {
                    callback(code, message, trtcRoomInfos);
                }
            } else {
                if (callback) {
                    callback(code, message, @[]);
                }
            }
        }];
    }];
}

- (void)getUserInfoList:(NSArray<NSString *> *)userIDList callback:(ChatSalonUserListCallback)callback {
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        if (!userIDList) {
            [self getAudienceList:callback];
            return;
        }
        [self.roomService getUserInfo:userIDList callback:^(int code, NSString * _Nonnull message, NSArray<TXChatSalonUserInfo *> * _Nonnull userInfos) {
            @strongify(self)
            if (!self) {
                return;
            }
            [self runOnDelegateQueue:^{
                @strongify(self)
                if (!self) {
                    return;
                }
                NSMutableArray* userList = [[NSMutableArray alloc] initWithCapacity:2];
                [userInfos enumerateObjectsUsingBlock:^(TXChatSalonUserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    ChatSalonUserInfo* userInfo = [[ChatSalonUserInfo alloc] init];
                    userInfo.userID = obj.userID;
                    userInfo.userName = obj.userName;
                    userInfo.userAvatar = obj.avatarURL;
                    [userList addObject:userInfo];
                }];
                if (callback) {
                    callback(code, message, userList);
                }
            }];
        }];
    }];
}

- (void)enterSeat:(ActionCallback _Nullable)callback {
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        if ([self isOnSeatWithUserId:self.userID]) {
            [self runOnDelegateQueue:^{
                if (callback) {
                    callback(-1, @"you are alread in the seat.");
                }
            }];
            return;
        }
        self.enterSeatCallback = callback;
        
        [self.roomTRTCService switchToAnchor:^(int code, NSString * _Nonnull message) {
            if (code == 0) {
                [self.roomService onSeatTakeWithUser:self.userID];
            } else {
                self.enterSeatCallback = nil;
                self.isTakeSeat = NO;
                if (callback) {
                    callback(code, message);
                }
            }
        }];
    }];
}

- (void)leaveSeat:(ActionCallback)callback {
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        if (!self.isTakeSeat) {
            [self runOnDelegateQueue:^{
                if (callback) {
                    callback(-1, @"you are not in the seat.");
                }
            }];
            return;
        }
        self.leaveSeatCallback = callback;
        
        [self.roomTRTCService switchToAudience:^(int code, NSString * _Nonnull message) {
            @strongify(self)
            if (!self) {
                return;
            }
            if (code == 0) {
                [self.roomService onSeatLeaveWithUser:self.userID];
            } else {
                self.leaveSeatCallback = nil;
                if (callback) {
                    callback(code, message);
                }
            }
        }];
    }];
}

- (void)pickSeat:(NSString *)userID callback:(ActionCallback)callback{
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        if ([self isOnSeatWithUserId:userID]) {
            [self runOnDelegateQueue:^{
                if (callback) {
                    callback(-1, TRTCLocalize(@"Demo.TRTC.Salon.userisspeaker"));
                }
            }];
            return;
        }
        self.pickSeatCallback = callback;
        [self.roomService pickSeat:userID callback:^(int code, NSString * _Nonnull message) {
            @strongify(self)
            if (!self) {
                return;
            }
            if (code == 0) {
                TRTCLog(@"pick seat calback success. and wait attrs changed.");
            } else {
                self.pickSeatCallback = nil;
                if (callback) {
                    callback(code, message);
                }
            }
        }];
    }];
}

- (void)kickSeat:(NSString *)userID callback:(ActionCallback)callback {
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        self.kickSeatCallback = callback;
        [self.roomService kickSeat:userID callback:^(int code, NSString * _Nonnull message) {
            @strongify(self)
            if (!self) {
                return;
            }
            if (code == 0) {
                 TRTCLog(@"kick seat calback success. and wait attrs changed.");
            } else {
                self.kickSeatCallback = nil;
                if (callback) {
                    callback(code, message);
                }
            }
        }];
    }];
}

- (void)muteSeat:(NSString *)userID isMute:(BOOL)isMute callback:(ActionCallback)callback {
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self.roomService muteSeat:userID mute:isMute callback:^(int code, NSString * _Nonnull message) {
            @strongify(self)
            if (!self) {
                return;
            }
            [self runOnDelegateQueue:^{
                if (callback) {
                    callback(code, message);
                }
            }];
        }];
    }];
}

- (void)startMicrophone {
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self.roomTRTCService startMicrophone];
    }];
}

- (void)stopMicrophone{
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self.roomTRTCService stopMicrophone];
    }];
}

- (void)setAuidoQuality:(NSInteger)quality {
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self.roomTRTCService setAudioQuality:quality];
    }];
}

- (void)muteLocalAudio:(BOOL)mute{
    @weakify(self)
//    [self muteSeat:self.userID isMute:mute callback:nil];
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self.roomTRTCService muteLocalAudio:mute];
        
        @weakify(self)
        [self runOnDelegateQueue:^{
            @strongify(self)
            if (!self) {
                return;
            }
            if ([self canDelegateResponseMethod:@selector(onSeatMute:isMute:)]) {
                [self.delegate onSeatMute:self.userID isMute:mute];
            }
        }];
    }];
}

- (void)setSpeaker:(BOOL)userSpeaker {
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self.roomTRTCService setSpeaker:userSpeaker];
    }];
}

- (void)setAudioCaptureVolume:(NSInteger)voluem {
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self.roomTRTCService setAudioCaptureVolume:voluem];
    }];
}

- (void)setAudioPlayoutVolume:(NSInteger)volume {
    @weakify(self)
       [self runMainQueue:^{
           @strongify(self)
           if (!self) {
               return;
           }
           [self.roomTRTCService setAudioPlayoutVolume:volume];
       }];
}

- (void)muteRemoteAudio:(NSString *)userID mute:(BOOL)mute{
    @weakify(self)
       [self runMainQueue:^{
           @strongify(self)
           if (!self) {
               return;
           }
           [self.roomTRTCService muteRemoteAudioWithUserId:userID isMute:mute];
       }];
}

- (void)muteAllRemoteAudio:(BOOL)isMute{
    @weakify(self)
       [self runMainQueue:^{
           @strongify(self)
           if (!self) {
               return;
           }
           [self.roomTRTCService muteAllRemoteAudio:isMute];
       }];
}

- (TXAudioEffectManager *)getAudioEffectManager{
    return [[TRTCCloud sharedInstance] getAudioEffectManager];
}

- (void)sendRoomTextMsg:(NSString *)message callback:(ActionCallback)callback {
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self.roomService sendRoomTextMsg:message callback:^(int code, NSString * _Nonnull message) {
            @strongify(self)
            if (!self) {
                return;
            }
            [self runOnDelegateQueue:^{
                if (callback) {
                    callback(code, message);
                }
            }];
        }];
    }];
}

- (void)sendRoomCustomMsg:(NSString *)cmd message:(NSString *)message callback:(ActionCallback)callback {
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self.roomService sendRoomCustomMsg:cmd message:message callback:^(int code, NSString * _Nonnull message) {
            @strongify(self)
            if (!self) {
                return;
            }
            [self runOnDelegateQueue:^{
                if (callback) {
                    callback(code, message);
                }
            }];
        }];
    }];
}

- (NSString *)sendInvitation:(NSString *)cmd userID:(NSString *)userID content:(NSString *)content callback:(ActionCallback)callback{
    NSArray *cachedInfoArray = [self.cachedSendInviteInfoDict allValues];
    for (TXChatSalonSendInviteInfo *info in cachedInfoArray) {
        if ([info.cmd isEqualToString:cmd] && [info.userID isEqualToString:userID]) {
            if (callback) {
                callback(ChatSalonErrorCodeInviteLimited, @"frequency limited");
            }
            break;
        }
    }
    
    @weakify(self)
    NSString *inviteID = [self.roomService sendInvitation:cmd userID:userID content:content callback:^(int code, NSString * _Nonnull message) {
        @strongify(self)
        if (!self) {
            return;
        }
        
        if (code != 0) {
            NSString *curInviteID = nil;
            for (NSString *key in self.cachedSendInviteInfoDict.allKeys) {
                TXChatSalonSendInviteInfo *info = [self.cachedSendInviteInfoDict objectForKey:key];
                if ([info.cmd isEqualToString:cmd] && [info.userID isEqualToString:userID]) {
                    curInviteID = key;
                    break;
                }
            }
            [self.cachedSendInviteInfoDict removeObjectForKey:curInviteID];
        }
        
        [self runOnDelegateQueue:^{
            if (callback) {
                callback(code, message);
            }
        }];
    }];
    
    if (inviteID != nil) {
        TXChatSalonSendInviteInfo *info = [[TXChatSalonSendInviteInfo alloc] init];
        info.cmd = cmd;
        info.userID = userID;
        [self.cachedSendInviteInfoDict setObject:info forKey:inviteID];
    }
    
    return inviteID;
}

- (void)acceptInvitation:(NSString *)identifier callback:(ActionCallback)callback{
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self.roomService acceptInvitation:identifier callback:^(int code, NSString * _Nonnull message) {
            @strongify(self)
            if (!self) {
                return;
            }
            [self runOnDelegateQueue:^{
                if (callback) {
                    callback(code, message);
                }
            }];
        }];
    }];
}

- (void)rejectInvitation:(NSString *)identifier callback:(ActionCallback)callback{
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self.roomService rejectInvitaiton:identifier callback:^(int code, NSString * _Nonnull message) {
            @strongify(self)
            if (!self) {
                return;
            }
            [self runOnDelegateQueue:^{
                if (callback) {
                    callback(code, message);
                }
            }];
        }];
    }];
}

- (void)cancelInvitation:(NSString *)identifier callback:(ActionCallback)callback{
    @weakify(self)
       [self runMainQueue:^{
           @strongify(self)
           if (!self) {
               return;
           }
           [self.roomService cancelInvitation:identifier callback:^(int code, NSString * _Nonnull message) {
               @strongify(self)
               if (!self) {
                   return;
               }
               [self runOnDelegateQueue:^{
                   if (callback) {
                       callback(code, message);
                   }
               }];
           }];
       }];
}

#pragma mark - ChatSalonTRTCServiceDelegate

- (void)onTRTCAnchorEnter:(NSString *)userID {
    [self.roomService onSeatTakeWithUser:userID];
}

- (void)onTRTCAnchorExit:(NSString *)userID {
    [self.roomService onSeatLeaveWithUser:userID];
}

- (void)onTRTCAudioAvailable:(NSString *)userID available:(BOOL)available {
    @weakify(self)
    [self runOnDelegateQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        
        if ([self.anchorSeatList containsObject:userID]) {
            if ([self canDelegateResponseMethod:@selector(onSeatMute:isMute:)]) {
                [self.delegate onSeatMute:userID isMute:!available];
            }
        } else {
            [self.cachedMuteInfo setObject:@(!available) forKey:userID];
        }
    }];
}

- (void)onError:(NSInteger)code message:(NSString *)message {
    @weakify(self)
    [self runOnDelegateQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        if ([self canDelegateResponseMethod:@selector(onError:message:)]) {
            [self.delegate onError:(int)code message:message];
        }
    }];
}

- (void)onNetWorkQuality:(TRTCQualityInfo *)trtcQuality arrayList:(NSArray<TRTCQualityInfo *> *)arrayList {
    
}

- (void)onUserVoiceVolume:(NSArray<TRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume {
    @weakify(self)
    [self runOnDelegateQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        if ([self canDelegateResponseMethod:@selector(onUserVolumeUpdate:totalVolume:)]) {
            [self.delegate onUserVolumeUpdate:userVolumes totalVolume:totalVolume];
        }
    }];
}

#pragma mark - ITXRoomServiceDelegate
- (void)onRoomDestroyWithRoomId:(NSString *)roomID{
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self exitRoom:nil];
        [self runOnDelegateQueue:^{
            @strongify(self)
            if (!self) {
                return;
            }
            if ([self canDelegateResponseMethod:@selector(onRoomDestroy:)]) {
                [self.delegate onRoomDestroy:roomID];
            }
        }];
    }];
}

- (void)onRoomRecvRoomTextMsg:(NSString *)roomID message:(NSString *)message userInfo:(TXChatSalonUserInfo *)userInfo {
    @weakify(self)
    [self runOnDelegateQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        ChatSalonUserInfo* user = [[ChatSalonUserInfo alloc] init];
        user.userID = userInfo.userID;
        user.userName = userInfo.userName;
        user.userAvatar = userInfo.avatarURL;
        if ([self canDelegateResponseMethod:@selector(onRecvRoomTextMsg:userInfo:)]) {
            [self.delegate onRecvRoomTextMsg:message userInfo:user];
        }
    }];
}

- (void)onRoomRecvRoomCustomMsg:(NSString *)roomID cmd:(NSString *)cmd message:(NSString *)message userInfo:(TXChatSalonUserInfo *)userInfo {
    @weakify(self)
    [self runOnDelegateQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        ChatSalonUserInfo* user = [[ChatSalonUserInfo alloc] init];
        user.userID = userInfo.userID;
        user.userName = userInfo.userName;
        user.userAvatar = userInfo.avatarURL;
        if ([self canDelegateResponseMethod:@selector(onRecvRoomCustomMsg:message:userInfo:)]) {
            [self.delegate onRecvRoomCustomMsg:cmd message:message userInfo:user];
        }
    }];
}

- (void)onRoomInfoChange:(TXChatSalonRoomInfo *)roomInfo{
    @weakify(self)
    [self runOnDelegateQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        if ([roomInfo.roomId intValue] == 0) {
            return;
        }
        ChatSalonInfo *room = [[ChatSalonInfo alloc] init];
        room.roomID = [roomInfo.roomId intValue];
        room.ownerId = roomInfo.ownerId;
        room.memberCount = roomInfo.memberCount;
        room.ownerName = roomInfo.ownerName;
        room.coverUrl = roomInfo.cover;
        room.needRequest = roomInfo.needRequest == 1;
        room.roomName = roomInfo.roomName;
        if ([self canDelegateResponseMethod:@selector(onRoomInfoChange:)]) {
            [self.delegate onRoomInfoChange:room];
        }
    }];
}

- (void)onSeatInfoListChange:(NSDictionary<NSString *, TXChatSalonSeatInfo *> *)seatInfoList{
    // IM 属性修改回调，暂不使用
}

- (void)onRoomAudienceEnter:(TXChatSalonUserInfo *)userInfo {
    @weakify(self)
    [self runOnDelegateQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        ChatSalonUserInfo* user = [[ChatSalonUserInfo alloc] init];
        user.userID = userInfo.userID;
        user.userName = userInfo.userName;
        user.userAvatar = userInfo.avatarURL;
        if ([self canDelegateResponseMethod:@selector(onAudienceEnter:)]) {
            [self.delegate onAudienceEnter:user];
        }
    }];
}

- (void)onRoomAudienceLeave:(TXChatSalonUserInfo *)userInfo {
    @weakify(self)
    [self runOnDelegateQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        ChatSalonUserInfo* user = [[ChatSalonUserInfo alloc] init];
        user.userID = userInfo.userID;
        user.userName = userInfo.userName;
        user.userAvatar = userInfo.avatarURL;
        if ([self canDelegateResponseMethod:@selector(onAudienceExit:)]) {
            [self.delegate onAudienceExit:user];
        }
    }];
}

- (void)onSeatTakeWithUserInfo:(TXChatSalonUserInfo *)userInfo{
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        
        [self.anchorSeatList addObject:userInfo.userID];
        
        BOOL isSelfEnterSeat = [userInfo.userID isEqualToString:self.userID];
        if (isSelfEnterSeat) {
            // 是自己上线了
            self.isTakeSeat = YES;
        }
        [self runOnDelegateQueue:^{
            @strongify(self)
            if (!self) {
                return;
            }
            ChatSalonUserInfo* user = [[ChatSalonUserInfo alloc] init];
            user.userID = userInfo.userID;
            user.userName = userInfo.userName;
            user.userAvatar = userInfo.avatarURL;
            if ([self canDelegateResponseMethod:@selector(onAnchorEnterSeat:)]) {
                [self.delegate onAnchorEnterSeat:user];
            }
            
            NSNumber *cachedMute = self.cachedMuteInfo[userInfo.userID];
            if (cachedMute) {
                if ([self canDelegateResponseMethod:@selector(onSeatMute:isMute:)]) {
                    [self.delegate onSeatMute:userInfo.userID isMute:[cachedMute boolValue]];
                }
                [self.cachedMuteInfo removeObjectForKey:userInfo.userID];
            } else if (isSelfEnterSeat) {
                if ([self canDelegateResponseMethod:@selector(onSeatMute:isMute:)]) {
                    [self.delegate onSeatMute:userInfo.userID isMute:NO];
                }
            }
            if (self.pickSeatCallback) {
                self.pickSeatCallback(0, @"pick seat success");
                self.pickSeatCallback = nil;
            }
        }];
        if (isSelfEnterSeat) {
            [self runOnDelegateQueue:^{
                @strongify(self)
                if (!self) {
                    return;
                }
                if (self.enterSeatCallback) {
                    self.enterSeatCallback(0, @"enter seat success.");
                    self.enterSeatCallback = nil;
                }
            }];
        }
    }];
}

- (void)onSeatLeaveWithUserInfo:(TXChatSalonUserInfo *)userInfo {
    @weakify(self)
    [self runOnDelegateQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        
        [self.anchorSeatList removeObject:userInfo.userID];
        
        if ([self.userID isEqualToString:userInfo.userID]) {
            self.isTakeSeat = NO;
        }
        ChatSalonUserInfo* user = [[ChatSalonUserInfo alloc] init];
        user.userID = userInfo.userID;
        user.userName = userInfo.userName;
        user.userAvatar = userInfo.avatarURL;
        if ([self canDelegateResponseMethod:@selector(onAnchorLeaveSeat:)]) {
            [self.delegate onAnchorLeaveSeat:user];
        }
        if (self.kickSeatCallback) {
            self.kickSeatCallback(0, @"kick seat success.");
            self.kickSeatCallback = nil;
        }
        if ([self.userID isEqualToString:userInfo.userID]) {
            if (self.leaveSeatCallback) {
                self.leaveSeatCallback(0, @"leave seat success.");
                self.leaveSeatCallback = nil;
            }
        }
    }];
}

- (void)onReceiveNewInvitationWithIdentifier:(NSString *)identifier inviter:(NSString *)inviter cmd:(NSString *)cmd content:(NSString *)content{
    @weakify(self)
    [self runOnDelegateQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        if ([self canDelegateResponseMethod:@selector(onReceiveNewInvitation:inviter:cmd:content:)]) {
            [self.delegate onReceiveNewInvitation:identifier inviter:inviter cmd:cmd content:content];
        }
    }];
}

- (void)onInviteeAcceptedWithIdentifier:(NSString *)identifier invitee:(NSString *)invitee {
    if ([self.cachedSendInviteInfoDict objectForKey:identifier]) {
        [self.cachedSendInviteInfoDict removeObjectForKey:identifier];
    }
    @weakify(self)
    [self runOnDelegateQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        if ([self canDelegateResponseMethod:@selector(onInviteeAccepted:invitee:)]) {
            [self.delegate onInviteeAccepted:identifier invitee:invitee];
        }
    }];
}

- (void)onInviteeRejectedWithIdentifier:(NSString *)identifier invitee:(NSString *)invitee {
    if ([self.cachedSendInviteInfoDict objectForKey:identifier]) {
        [self.cachedSendInviteInfoDict removeObjectForKey:identifier];
    }
    @weakify(self)
    [self runOnDelegateQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        if ([self canDelegateResponseMethod:@selector(onInviteeRejected:invitee:)]) {
            [self.delegate onInviteeRejected:identifier invitee:invitee];
        }
    }];
}

- (void)onInviteeCancelledWithIdentifier:(NSString *)identifier invitee:(NSString *)invitee {
    @weakify(self)
    [self runOnDelegateQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        if ([self canDelegateResponseMethod:@selector(onInvitationCancelled:invitee:)]) {
            [self.delegate onInvitationCancelled:identifier invitee:invitee];
        }
    }];
}

- (void)onInvitationTimeout:(NSString *)inviteID {
    if ([self.cachedSendInviteInfoDict objectForKey:inviteID]) {
        [self.cachedSendInviteInfoDict removeObjectForKey:inviteID];
    }
    
    @weakify(self)
    [self runOnDelegateQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        if ([self canDelegateResponseMethod:@selector(onInvitationTimeout:)]) {
            [self.delegate onInvitationTimeout:inviteID];
        }
    }];
}

- (void)onSeatKick {
    [self leaveSeat:nil];
}

- (void)onSeatPick {
    [self enterSeat:nil];
}

@end
