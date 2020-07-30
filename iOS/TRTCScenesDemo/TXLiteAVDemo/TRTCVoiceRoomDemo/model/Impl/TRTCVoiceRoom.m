//
//  TRTCVoiceRoom.m
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/6/30.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TRTCVoiceRoom.h"
#import "VoiceRoomTRTCService.h"
#import "TXVoiceRoomService.h"
#import "TXVoiceRoomCommonDef.h"
#import "TRTCCloud.h"

@interface TRTCVoiceRoom ()<VoiceRoomTRTCServiceDelegate, ITXRoomServiceDelegate>

@property (nonatomic, assign) int mSDKAppID;

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userSig;
@property (nonatomic, strong) NSString *roomID;
@property (nonatomic, strong) NSMutableSet<NSString *> *anchorSeatList;
@property (nonatomic, strong) NSMutableSet<NSString *> *audienceList;
@property (nonatomic, strong) NSMutableArray<VoiceRoomSeatInfo *> *seatInfoList;
@property (nonatomic, assign) NSInteger takeSeatIndex;

@property (nonatomic, strong) VoiceRoomInfo *roomInfo;

@property (nonatomic, weak) id<TRTCVoiceRoomDelegate> delegate;

@property (nonatomic, copy, nullable) ActionCallback enterSeatCallback;
@property (nonatomic, copy, nullable) ActionCallback leaveSeatCallback;
@property (nonatomic, copy, nullable) ActionCallback pickSeatCallback;
@property (nonatomic, copy, nullable) ActionCallback kickSeatCallback;

@property (nonatomic, weak)dispatch_queue_t delegateQueue;

@property (nonatomic, readonly)TXVoiceRoomService *roomService;
@property (nonatomic, readonly)VoiceRoomTRTCService *roomTRTCService;

@end

@implementation TRTCVoiceRoom

static TRTCVoiceRoom *_instance;
static dispatch_once_t onceToken;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegateQueue = dispatch_get_main_queue();
        self.seatInfoList = [[NSMutableArray alloc] initWithCapacity:2];
        self.anchorSeatList = [[NSMutableSet alloc] initWithCapacity:2];
        self.audienceList = [[NSMutableSet alloc] initWithCapacity:2];
        self.takeSeatIndex = -1;
        self.roomService.delegate = self;
        self.roomTRTCService.delegate =self;
    }
    return self;
}

- (TXVoiceRoomService *)roomService {
    return [TXVoiceRoomService sharedInstance];
}

- (VoiceRoomTRTCService *)roomTRTCService {
    return [VoiceRoomTRTCService sharedInstance];
}

- (BOOL)canDelegateResponseMethod:(SEL)method {
    return self.delegate && [self.delegate respondsToSelector:method];
}

#pragma mark - private method
- (BOOL)isOnSeatWithUserId:(NSString *)userId {
    if (self.seatInfoList.count == 0) {
        return NO;
    }
    for (VoiceRoomSeatInfo *seatInfo in self.seatInfoList) {
        if ([seatInfo.userId isEqualToString:userId]) {
            return YES;
        }
    }
    return NO;
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

- (void)getAudienceList:(VoiceRoomUserListCallback _Nullable)callback {
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self.roomService getAudienceList:^(int code, NSString * _Nonnull message, NSArray<TXVoiceRoomUserInfo *> * _Nonnull userInfos) {
            TRTCLog(@"get audience list finish, code:%d, message:%@, userListCount:%d", code, message, userInfos.count);
            NSMutableArray *userInfoList = [[NSMutableArray alloc] initWithCapacity:2];
            for (TXVoiceRoomUserInfo* info in userInfos) {
                VoiceRoomUserInfo* userInfo = [[VoiceRoomUserInfo alloc] init];
                userInfo.userId = info.userId;
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

- (void)enterTRTCRoomInnerWithRoomId:(NSString *)roomId userId:(NSString *)userId userSign:(NSString *)userSig role:(NSInteger)role callback:(ActionCallback)callback {
    TRTCLog(@"start enter trtc room.");
    @weakify(self)
    [self.roomTRTCService enterRoomWithSdkAppId:self.mSDKAppID roomId:roomId userId:userId userSign:userSig role:role callback:^(int code, NSString * _Nonnull message) {
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

#pragma mark - TRTCVoiceRoom 实现
+ (instancetype)sharedInstance {
    dispatch_once(&onceToken, ^{
        _instance = [[TRTCVoiceRoom alloc] init];
        [TXVoiceRoomService sharedInstance].delegate = _instance;
        [VoiceRoomTRTCService sharedInstance].delegate = _instance;
    });
    return _instance;
}

+ (void)destroySharedInstance {
    onceToken = 0;
    _instance = nil;
}

- (void)setDelegate:(id<TRTCVoiceRoomDelegate>)delegate{
    self->_delegate = delegate;
}

- (void)setDelegateQueue:(dispatch_queue_t)queue {
    self->_delegateQueue = queue;
}

- (void)login:(int)sdkAppID userId:(NSString *)userId userSig:(NSString *)userSig callback:(ActionCallback)callback{
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        if (sdkAppID != 0 && userId && ![userId isEqualToString:@""] && userSig && ![userSig isEqualToString:@""]) {
            self.mSDKAppID = sdkAppID;
            self.userId = userId;
            self.userSig = userSig;
            TRTCLog(@"start login room service");
            [self.roomService loginWithSdkAppId:sdkAppID userId:userId userSig:userSig callback:^(int code, NSString * _Nonnull message) {
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
        self.userId = @"";
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

- (void)createRoom:(int)roomID roomParam:(VoiceRoomParam *)roomParam callback:(ActionCallback)callback {
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
        NSInteger seatCount = roomParam.seatCount;
        NSMutableArray* seatInfoList = [[NSMutableArray alloc] initWithCapacity:2];
        if (roomParam.seatInfoList.count > 0) {
            for (VoiceRoomSeatInfo* info in roomParam.seatInfoList) {
                TXSeatInfo* seatInfo = [[TXSeatInfo alloc] init];
                seatInfo.status = info.status;
                seatInfo.mute = info.mute;
                seatInfo.user = info.userId;
                [seatInfoList addObject:seatInfo];
                [self.seatInfoList addObject:info];
            }
        } else {
            for (int index = 0; index < seatCount; index += 1) {
                TXSeatInfo* info = [[TXSeatInfo alloc] init];
                [seatInfoList addObject:info];
                [self.seatInfoList addObject:[[VoiceRoomSeatInfo alloc] init]];
            }
        }
        [self.roomService createRoomWithRoomId:self.roomID
                                      roomName:roomName
                                      coverUrl:roomCover
                                   needRequest:isNeedrequest
                                  seatInfoList:seatInfoList
                                      callback:^(int code, NSString * _Nonnull message) {
            @strongify(self)
            if (!self) {
                return;
            }
            if (code == 0) {
                [self enterTRTCRoomInnerWithRoomId:self.roomID userId:self.userId userSign:self.userSig role:kTRTCRoleAnchorValue callback:callback];
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
        [self enterTRTCRoomInnerWithRoomId:self.roomID userId:self.userId userSign:self.userSig role:kTRTCRoleAudienceValue callback:^(int code, NSString * _Nonnull message) {
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
        if ([self isOnSeatWithUserId:self.userId]) {
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

- (void)getRoomInfoList:(NSArray<NSNumber *> *)roomIdList callback:(VoiceRoomInfoCallback)callback {
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
        [self.roomService getRoomInfoList:roomIds calback:^(int code, NSString * _Nonnull message, NSArray<TXRoomInfo *> * _Nonnull roomInfos) {
            if (code == 0) {
                TRTCLog(@"roomInfos: %@", roomInfos);
                NSMutableArray* trtcRoomInfos = [[NSMutableArray alloc] initWithCapacity:2];
                for (TXRoomInfo *info in roomInfos) {
                    if ([info.roomId integerValue] != 0) {
                        VoiceRoomInfo *roomInfo = [[VoiceRoomInfo alloc] init];
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

- (void)getUserInfoList:(NSArray<NSString *> *)userIDList callback:(VoiceRoomUserListCallback)callback {
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
        [self.roomService getUserInfo:userIDList callback:^(int code, NSString * _Nonnull message, NSArray<TXVoiceRoomUserInfo *> * _Nonnull userInfos) {
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
                [userInfos enumerateObjectsUsingBlock:^(TXVoiceRoomUserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    VoiceRoomUserInfo* userInfo = [[VoiceRoomUserInfo alloc] init];
                    userInfo.userId = obj.userId;
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

- (void)enterSeat:(NSInteger)seatIndex callback:(ActionCallback)callback {
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        if ([self isOnSeatWithUserId:self.userId]) {
            [self runOnDelegateQueue:^{
                if (callback) {
                    callback(-1, @"you are alread in the seat.");
                }
            }];
            return;
        }
        self.enterSeatCallback = callback;
        [self.roomService takeSeat:seatIndex callback:^(int code, NSString * _Nonnull message) {
            if (code == 0) {
                TRTCLog(@"take seat callback success, and wait attrs changed");
            } else {
                self.enterSeatCallback = nil;
                self.takeSeatIndex = -1;
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
        if (self.takeSeatIndex == -1) {
            [self runOnDelegateQueue:^{
                callback(-1, @"you are not in the seat.");
            }];
            return;
        }
        self.leaveSeatCallback = callback;
        [self.roomService leaveSeat:self.takeSeatIndex callback:^(int code, NSString * _Nonnull message) {
            @strongify(self)
            if (!self) {
                return;
            }
            if (code == 0) {
                TRTCLog(@"levae seat success. and wait attrs changed");
            } else {
                self.leaveSeatCallback = nil;
                if (callback) {
                    callback(code, message);
                }
            }
        }];
    }];
}

- (void)pickSeat:(NSInteger)seatIndex userId:(NSString *)userId callback:(ActionCallback)callback{
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        if ([self isOnSeatWithUserId:userId]) {
            [self runOnDelegateQueue:^{
                if (callback) {
                    callback(-1, @"该用户已经是上麦主播了");
                }
            }];
            return;
        }
        self.pickSeatCallback = callback;
        [self.roomService pickSeat:seatIndex userId:userId callback:^(int code, NSString * _Nonnull message) {
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

- (void)kickSeat:(NSInteger)seatIndex callback:(ActionCallback)callback {
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        self.kickSeatCallback = callback;
        [self.roomService kickSeat:seatIndex callback:^(int code, NSString * _Nonnull message) {
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

- (void)muteSeat:(NSInteger)seatIndex isMute:(BOOL)isMute callback:(ActionCallback)callback {
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self.roomService muteSeat:seatIndex mute:isMute callback:^(int code, NSString * _Nonnull message) {
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

- (void)closeSeat:(NSInteger)seatIndex isClose:(BOOL)isClose callback:(ActionCallback)callback{
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self.roomService closeSeat:seatIndex isClose:isClose callback:^(int code, NSString * _Nonnull message) {
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
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self.roomTRTCService muteLocalAudio:mute];
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

- (void)muteRemoteAudio:(NSString *)userId mute:(BOOL)mute{
    @weakify(self)
       [self runMainQueue:^{
           @strongify(self)
           if (!self) {
               return;
           }
           [self.roomTRTCService muteRemoteAudioWithUserId:userId isMute:mute];
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

- (NSString *)sendInvitation:(NSString *)cmd userId:(NSString *)userId content:(NSString *)content callback:(ActionCallback)callback{
    @weakify(self)
    return [self.roomService sendInvitation:cmd userId:userId content:content callback:^(int code, NSString * _Nonnull message) {
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

#pragma mark - VoiceRoomTRTCServiceDelegate

- (void)onTRTCAnchorEnter:(NSString *)userId {
    [self.anchorSeatList addObject:userId];
}

- (void)onTRTCAnchorExit:(NSString *)userId {
    if (self.roomService.isOwner) {
        if (self.seatInfoList.count > 0) {
            NSInteger kickSeatIndex = -1;
            for (int i = 0; i<self.seatInfoList.count; i+=1) {
                if ([userId isEqualToString:self.seatInfoList[i].userId]) {
                    kickSeatIndex = i;
                    break;
                }
            }
            if (kickSeatIndex != -1) {
                [self kickSeat:kickSeatIndex callback:nil];
            }
        }
    }
}

- (void)onTRTCAudioAvailable:(NSString *)userId available:(BOOL)available {
    
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
        [userVolumes enumerateObjectsUsingBlock:^(TRTCVolumeInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self canDelegateResponseMethod:@selector(onUserVolumeUpdate:volume:)] && obj.userId) {
                [self.delegate onUserVolumeUpdate:obj.userId volume:obj.volume];
            }
        }];
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

- (void)onRoomRecvRoomTextMsg:(NSString *)roomID message:(NSString *)message userInfo:(TXVoiceRoomUserInfo *)userInfo {
    @weakify(self)
    [self runOnDelegateQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        VoiceRoomUserInfo* user = [[VoiceRoomUserInfo alloc] init];
        user.userId = userInfo.userId;
        user.userName = userInfo.userName;
        user.userAvatar = userInfo.avatarURL;
        if ([self canDelegateResponseMethod:@selector(onRecvRoomTextMsg:userInfo:)]) {
            [self.delegate onRecvRoomTextMsg:message userInfo:user];
        }
    }];
}

- (void)onRoomRecvRoomCustomMsg:(NSString *)roomID cmd:(NSString *)cmd message:(NSString *)message userInfo:(TXVoiceRoomUserInfo *)userInfo {
    @weakify(self)
    [self runOnDelegateQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        VoiceRoomUserInfo* user = [[VoiceRoomUserInfo alloc] init];
        user.userId = userInfo.userId;
        user.userName = userInfo.userName;
        user.userAvatar = userInfo.avatarURL;
        if ([self canDelegateResponseMethod:@selector(onRecvRoomCustomMsg:message:userInfo:)]) {
            [self.delegate onRecvRoomCustomMsg:cmd message:message userInfo:user];
        }
    }];
}

- (void)onRoomInfoChange:(TXRoomInfo *)roomInfo{
    @weakify(self)
    [self runOnDelegateQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        if ([roomInfo.roomId intValue] == 0) {
            return;
        }
        VoiceRoomInfo *room = [[VoiceRoomInfo alloc] init];
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

- (void)onSeatInfoListChange:(NSArray<TXSeatInfo *> *)seatInfoList{
    @weakify(self)
    [self runOnDelegateQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        NSMutableArray* roomSeatList = [[NSMutableArray alloc] initWithCapacity:2];
        for (TXSeatInfo* info in seatInfoList) {
            VoiceRoomSeatInfo* seat = [[VoiceRoomSeatInfo alloc] init];
            seat.userId = info.user;
            seat.mute = info.mute;
            seat.status = info.status;
            [roomSeatList addObject:seat];
        }
        self.seatInfoList = roomSeatList;
        if ([self canDelegateResponseMethod:@selector(onSeatInfoChange:)]) {
            [self.delegate onSeatInfoChange:roomSeatList];
        }
    }];
}

- (void)onRoomAudienceEnter:(TXVoiceRoomUserInfo *)userInfo {
    @weakify(self)
    [self runOnDelegateQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        VoiceRoomUserInfo* user = [[VoiceRoomUserInfo alloc] init];
        user.userId = userInfo.userId;
        user.userName = userInfo.userName;
        user.userAvatar = userInfo.avatarURL;
        if ([self canDelegateResponseMethod:@selector(onAudienceEnter:)]) {
            [self.delegate onAudienceEnter:user];
        }
    }];
}

- (void)onRoomAudienceLeave:(TXVoiceRoomUserInfo *)userInfo {
    @weakify(self)
    [self runOnDelegateQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        VoiceRoomUserInfo* user = [[VoiceRoomUserInfo alloc] init];
        user.userId = userInfo.userId;
        user.userName = userInfo.userName;
        user.userAvatar = userInfo.avatarURL;
        if ([self canDelegateResponseMethod:@selector(onAudienceExit:)]) {
            [self.delegate onAudienceExit:user];
        }
    }];
}

- (void)onSeatTakeWithIndex:(NSInteger)index userInfo:(TXVoiceRoomUserInfo *)userInfo{
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        BOOL isSelfEnterSeat = [userInfo.userId isEqualToString:self.userId];
        if (isSelfEnterSeat) {
            // 是自己上线了
            self.takeSeatIndex = index;
            [self.roomTRTCService switchToAnchor];
            BOOL mute = self.seatInfoList[index].mute;
            [self.roomTRTCService muteLocalAudio:mute];
        }
        [self runOnDelegateQueue:^{
            @strongify(self)
            if (!self) {
                return;
            }
            VoiceRoomUserInfo* user = [[VoiceRoomUserInfo alloc] init];
            user.userId = userInfo.userId;
            user.userName = userInfo.userName;
            user.userAvatar = userInfo.avatarURL;
            if ([self canDelegateResponseMethod:@selector(onAnchorEnterSeat:user:)]) {
                [self.delegate onAnchorEnterSeat:index user:user];
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

- (void)onSeatCloseWithIndex:(NSInteger)index isClose:(BOOL)isClose {
    @weakify(self)
    [self runMainQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        if (self.takeSeatIndex == index) {
            [self.roomTRTCService switchToAudience];
            self.takeSeatIndex = -1;
        }
        [self runOnDelegateQueue:^{
            @strongify(self)
            if (!self) {
                return;
            }
            if ([self canDelegateResponseMethod:@selector(onSeatClose:isClose:)]) {
                [self.delegate onSeatClose:index isClose:isClose];
            }
        }];
    }];
}

- (void)onSeatLeaveWithIndex:(NSInteger)index userInfo:(TXVoiceRoomUserInfo *)userInfo {
    @weakify(self)
    [self runOnDelegateQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        if ([self.userId isEqualToString:userInfo.userId]) {
            self.takeSeatIndex = -1;
            [self.roomTRTCService switchToAudience];
        }
        VoiceRoomUserInfo* user = [[VoiceRoomUserInfo alloc] init];
        user.userId = userInfo.userId;
        user.userName = userInfo.userName;
        user.userAvatar = userInfo.avatarURL;
        if ([self canDelegateResponseMethod:@selector(onAnchorLeaveSeat:user:)]) {
            [self.delegate onAnchorLeaveSeat:index user:user];
        }
        if (self.kickSeatCallback) {
            self.kickSeatCallback(0, @"kick seat success.");
            self.kickSeatCallback = nil;
        }
        if ([self.userId isEqualToString:userInfo.userId]) {
            if (self.leaveSeatCallback) {
                self.leaveSeatCallback(0, @"leave seat success.");
                self.leaveSeatCallback = nil;
            }
        }
    }];
}

- (void)onSeatMuteWithIndex:(NSInteger)index mute:(BOOL)isMute {
    @weakify(self)
    [self runOnDelegateQueue:^{
        @strongify(self)
        if (!self) {
            return;
        }
        if (self.takeSeatIndex == index) {
            [self.roomTRTCService muteLocalAudio:isMute];
        }
        if ([self canDelegateResponseMethod:@selector(onSeatMute:isMute:)]) {
            [self.delegate onSeatMute:index isMute:isMute];
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

@end
