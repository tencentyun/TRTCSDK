//
//  TXChatSalonService.m
//  TRTCChatSalonOCDemo
//
//  Created by abyyxwang on 2020/7/1.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TXChatSalonService.h"
#import <MJExtension.h>
#import <ImSDK/ImSDK.h>
#import "TXChatSalonIMJsonHandle.h"
#import "TXChatSalonCommonDef.h"
#import "AppLocalized.h"

@interface TXChatSalonService ()<V2TIMSDKListener, V2TIMSimpleMsgListener, V2TIMGroupListener, V2TIMSignalingListener>

@property (nonatomic, assign) BOOL isInitIMSDK;
@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, assign) BOOL isEnterRoom;

@property (nonatomic, strong) NSString *mRoomId;
@property (nonatomic, strong) NSString *selfUserId;
@property (nonatomic, strong) NSString *ownerUserId;
@property (nonatomic, strong) TXChatSalonRoomInfo *roomInfo;
@property (nonatomic, strong) NSMutableDictionary<NSString *, TXChatSalonSeatInfo *> *seatInfoList; // 懒加载初始化
@property (nonatomic, strong) NSString *selfUserName;

@property (nonatomic, strong, readonly)V2TIMManager* imManager;

@end

@implementation TXChatSalonService

+ (instancetype)sharedInstance {
    static TXChatSalonService* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TXChatSalonService alloc] init];
    });
    return instance;
}

- (NSMutableDictionary<NSString *,TXChatSalonSeatInfo *> *)seatInfoList {
    if (!_seatInfoList) {
        _seatInfoList = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    return _seatInfoList;
}

#pragma mark - public method
- (void)loginWithSdkAppId:(int)sdkAppId
                   userID:(NSString *)userID
                  userSig:(NSString *)userSig
                 callback:(TXCallback)callback {
    if (!self.isInitIMSDK) {
        V2TIMSDKConfig *config = [[V2TIMSDKConfig alloc] init];
        config.logLevel = TIM_LOG_ERROR;
        self.isInitIMSDK = [self.imManager initSDK:sdkAppId config:config listener:self];
        if (!self.isInitIMSDK) {
            if (callback) {
                callback(VOICE_ROOM_SERVICE_CODE_ERROR, @"init im sdk error.");
            }
            return;
        }
    }
    if (self.isLogin) {
        if (callback) {
            callback(VOICE_ROOM_SERVICE_CODE_ERROR, @"start login fail, you have been login, can not login twice.");
        }
        return;
    }
    @weakify(self)
    [self.imManager login:userID userSig:userSig succ:^{
        @strongify(self)
        if (!self) {
            return;
        }
        self.isLogin = YES;
        self.selfUserId = userID;
        if (callback) {
            callback(0, @"im login success.");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc ?: @"im login error");
        }
    }];
}

- (void)getSelfInfo{
    if (!self.selfUserId || [self.selfUserId isEqualToString:@""]) {
        return;
    }
    @weakify(self)
    [self.imManager getUsersInfo:@[self.selfUserId] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        @strongify(self)
        if (!self) { return; }
        if (infoList.count > 0) {
            self.selfUserName = infoList.firstObject.nickName ?: @"";
        }
    } fail:^(int code, NSString *desc) {
        TRTCLog(@"get self info fail,code: %d reason: %@",code, desc);
    }];
}

- (void)logout:(TXCallback)callback {
    if (!self.isLogin) {
        if (callback) {
            callback(VOICE_ROOM_SERVICE_CODE_ERROR, @"start logout fail. not login yet");
        }
        return;
    }
    if (self.isEnterRoom) {
        if (callback) {
            callback(VOICE_ROOM_SERVICE_CODE_ERROR, @"start logout fail. you are in room, please exit room before logout");
        }
        return;
    }
    [self.imManager logout:^{
        if (callback) {
            callback(0, @"login im success.");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc);
        }
    }];
}

- (void)setSelfProfileWithUserName:(NSString *)userName avatarUrl:(NSString *)avatarUrl callback:(TXCallback _Nullable)callback{
    if (!self.isLogin) {
        if (callback) {
            callback(VOICE_ROOM_SERVICE_CODE_ERROR, @"set profile fail, not login yet.");
        }
        return;
    }
    V2TIMUserFullInfo *userInfo = [[V2TIMUserFullInfo alloc] init];
    userInfo.nickName = userName;
    userInfo.faceURL = avatarUrl;
    [self.imManager setSelfInfo:userInfo succ:^{
        if (callback) {
            callback(0, @"set profile success");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(0, desc ?: @"set profile failed.");
        }
    }];
}

- (void)createRoomWithRoomId:(NSString *)roomId
                    roomName:(NSString *)roomName
                    coverUrl:(NSString *)coverUrl
                 needRequest:(BOOL)needRequest
                    callback:(TXCallback)callback {
    if (!self.isLogin) {
        if (callback) {
            callback(VOICE_ROOM_SERVICE_CODE_ERROR, @"im not login yet, create room fail");
        }
        return;
    }
    if (self.isEnterRoom) {
        if (callback) {
            callback(VOICE_ROOM_SERVICE_CODE_ERROR, @"you have been in room");
        }
        return;
    }
    self.mRoomId = roomId;
    self.ownerUserId = self.selfUserId;
    self.roomInfo = [[TXChatSalonRoomInfo alloc] init];
    [self.seatInfoList removeAllObjects]; // 进房时刷新
    self.roomInfo.ownerId = self.selfUserId;
    self.roomInfo.ownerName = self.selfUserName;
    self.roomInfo.roomName = roomName;
    self.roomInfo.cover = coverUrl;
    self.roomInfo.needRequest = needRequest ? 1 : 0;
    @weakify(self)
    [self.imManager createGroup:@"AVChatRoom" groupID:roomId groupName:roomName succ:^(NSString *groupID) {
        @strongify(self)
        if (!self) {
            return;
        }
        [self setGroupInfoWithRoomId:roomId roomName:roomName coverUrl:coverUrl userName:self.selfUserName];
        [self onCreateSuccess:callback];
    } fail:^(int code, NSString *desc) {
        @strongify(self)
        if (!self) {
            return;
        }
        TRTCLog(@"create room error: %d, msg: %@", code, desc);
        NSString *msg = desc ?: @"create room fiald";
        if (code == 10036) {
            msg = LocalizeReplaceXX(TRTCLocalize(@"Demo.TRTC.Buy.chatroom"), @"https://cloud.tencent.com/document/product/269/11673");
        } else if (code == 10037) {
            msg = LocalizeReplaceXX(TRTCLocalize(@"Demo.TRTC.Buy.grouplimit"), @"https://cloud.tencent.com/document/product/269/11673");
        } else if (code == 10038) {
            msg = LocalizeReplaceXX(TRTCLocalize(@"Demo.TRTC.Buy.groupmemberlimit"), @"https://cloud.tencent.com/document/product/269/11673");
        }
        
        if (code == 10025 || code == 10021) {
            // 表明群主是自己，认为创建成功
            // 群ID已被他人使用，走进房的逻辑
            [self setGroupInfoWithRoomId:roomId roomName:roomName coverUrl:coverUrl userName:self.selfUserName];
            [self.imManager joinGroup:roomId msg:@"" succ:^{
                TRTCLog(@"gorup has benn created. join group success");
                [self onCreateSuccess:callback];
            } fail:^(int code, NSString *desc) {
                TRTCLog(@"error: group has been created. join group fail. code:%d, message: %@", code, desc);
                if (callback) {
                    callback(code, desc ?: @"");
                }
            }];
        } else {
            if (callback) {
                callback(code, msg);
            }
        }
    }];
}

- (void)destroyRoom:(TXCallback)callback {
    if (!self.isOwner) {
        if (callback) {
            callback(-1, @"only owner could destroy room");
        }
        return;
    }
    @weakify(self)
    [self.imManager dismissGroup:self.mRoomId succ:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self unInitIMListener];
        [self cleanRoomStatus];
        if (callback) {
            callback(0, @"destroy room success.");
        }
    } fail:^(int code, NSString *desc) {
        @strongify(self)
        if (!self) {
            return;
        }
        if (code == 10007) {
            TRTCLog(@"your are not real owner, start logic destroy.");
            [self cleanGroupAttr];
            [self sendGroupMsg:[TXChatSalonIMJsonHandle getRoomdestroyMsg] callback:callback];
            [self unInitIMListener];
            [self cleanRoomStatus];
        } else {
            if (callback) {
                callback(code, desc ?: @"destroy room failed");
            }
        }
    }];
}

- (void)enterRoom:(NSString *)roomId callback:(TXCallback)callback {
    [self cleanRoomStatus];
    self.mRoomId = roomId;
    @weakify(self)
    [self.imManager joinGroup:roomId msg:@"" succ:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self onJoinRoomSuccessWithRoomId:roomId callback:callback];
    } fail:^(int code, NSString *desc) {
        @strongify(self)
        if (!self) {
            return;
        }
        if (code == 10013) {
            [self onJoinRoomSuccessWithRoomId:roomId callback:callback];
        } else {
            if (callback) {
                callback(-1, [NSString stringWithFormat:@"join group eror, enter room fail. code:%d, msg:%@", code ,desc]);
            }
        }
    }];
}

- (void)exitRoom:(TXCallback)callback {
    if (!self.isEnterRoom) {
        if (callback) {
            callback(-1,@"not enter room yet, can't exit room.");
        }
        return;
    }
    @weakify(self)
    [self.imManager quitGroup:self.mRoomId succ:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self unInitIMListener];
        [self cleanRoomStatus];
        if (callback) {
            callback(0, @"exite room success.");
        }
    } fail:^(int code, NSString *desc) {
        @strongify(self)
        if (!self) {
            return;
        }
        [self unInitIMListener];
        if (callback) {
            callback(code, desc ?: @"exite room failed.");
        }
    }];
}

- (void)takeSeat:(TXCallback)callback {
    if (!callback) {
        callback = ^(int code, NSString* message){
            
        };
    }
    if ([self.seatInfoList objectForKey:self.selfUserId]) {
        // 已经在麦位上了
        callback(-1, @"already on the seat");
        return;
    }
    TXChatSalonSeatInfo* changeInfo = [[TXChatSalonSeatInfo alloc] init];
    changeInfo.user = self.selfUserId;
    changeInfo.mute = NO;
    NSDictionary *dic = [TXChatSalonIMJsonHandle getSeatInfoJsonStrWithUserID:self.selfUserId info:changeInfo];
    [self modeifyGroupAttrs:dic callback:callback];
}

- (void)leaveSeat:(TXCallback)callback {
    if (!callback) {
        callback = ^(int code, NSString* message){
            
        };
    }
    TXChatSalonSeatInfo *info = [self.seatInfoList objectForKey:self.selfUserId];
    if (info) {
        NSString *key = [NSString stringWithFormat:@"%@%@", VOICE_ROOM_KEY_SEAT, self.selfUserId];
        [self removeGroupAttrs:@[key] callback:callback];
    } else {
        callback(-1, @"already leave seat.");
    }
}

- (void)pickSeat:(NSString *)userID callback:(TXCallback)callback {
    if (!callback) {
        callback = ^(int code, NSString* message){};
    }
    if (!self.isOwner) {
        callback(-1, @"only owner can pick someone on the seat.");
        return;
    }
    if ([self.seatInfoList objectForKey:userID]) {
        // 已经在麦位上了
        callback(-1, @"already on the seat");
        return;
    }
    
    NSString *msg = [TXChatSalonIMJsonHandle getPickMsgJsonStrWithUserID:userID];
    [self.imManager sendC2CCustomMessage:[msg dataUsingEncoding:NSUTF8StringEncoding] to:userID succ:^{
        if (callback) {
            callback(0, @"send c2c custom message success.");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc);
        }
    }];
}

- (void)kickSeat:(NSString *)userID callback:(TXCallback)callback {
    if (!callback) {
        callback = ^(int code, NSString* message){};
    }
    if (!self.isOwner) {
        callback(-1, @"only owner can kick someone on the seat.");
        return;
    }
    
    NSString *msg = [TXChatSalonIMJsonHandle getKickMsgJsonStrWithUserID:userID];
    [self.imManager sendC2CCustomMessage:[msg dataUsingEncoding:NSUTF8StringEncoding] to:userID succ:^{
        if (callback) {
            callback(0, @"send c2c custom message success.");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc);
        }
    }];
}

- (void)muteSeat:(NSString *)userID mute:(BOOL)mute callback:(TXCallback)callback {
    if (!callback) {
        callback = ^(int code, NSString* message){};
    }
    TXChatSalonSeatInfo *info = self.seatInfoList[userID];
    TXChatSalonSeatInfo *changeInfo = [[TXChatSalonSeatInfo alloc] init];
    changeInfo.user = info.user;
    changeInfo.mute = mute;
    NSDictionary *dic = [TXChatSalonIMJsonHandle getSeatInfoJsonStrWithUserID:userID info:changeInfo];
    [self modeifyGroupAttrs:dic callback:callback];
}

- (void)getUserInfo:(NSArray<NSString *> *)userList callback:(TXUserListCallback)callback {
    if (!self.isEnterRoom) {
        if (callback) {
            callback(VOICE_ROOM_SERVICE_CODE_ERROR, @"get user info list fail, not enter room yet", @[]);
        }
        return;
    }
    if (!userList || userList.count == 0) {
        if (callback) {
            callback(VOICE_ROOM_SERVICE_CODE_ERROR, @"get user info list fail, user id list is empty.", @[]);
        }
        return;
    }
    [self.imManager getUsersInfo:userList succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        NSMutableArray *txUserInfo = [[NSMutableArray alloc] initWithCapacity:2];
        [infoList enumerateObjectsUsingBlock:^(V2TIMUserFullInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TXChatSalonUserInfo *userInfo = [[TXChatSalonUserInfo alloc] init];
            userInfo.userName = obj.nickName ?: @"";
            userInfo.userID = obj.userID ?: @"";
            userInfo.avatarURL = obj.faceURL ?: @"";
            [txUserInfo addObject:userInfo];
        }];
        if (callback) {
            callback(0, @"success", txUserInfo);
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc ?: @"get user info failed", @[]);
        }
    }];
}

- (void)sendRoomTextMsg:(NSString *)msg callback:(TXCallback)callback {
    if (!self.isEnterRoom) {
        if (callback) {
            callback(-1, @"send room text fail. not enter room yet.");
        }
        return;
    }
    [self.imManager sendGroupTextMessage:msg to:self.mRoomId priority:V2TIM_PRIORITY_NORMAL succ:^{
        if (callback) {
            callback(0, @"send gourp message success.");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc ?: @"send group message error.");
        }
    }];
}

- (void)sendRoomCustomMsg:(NSString *)cmd message:(NSString *)message callback:(TXCallback)callback {
    if (!self.isEnterRoom) {
        if (callback) {
            callback(-1, @"send room text fail. not enter room yet.");
        }
        return;
    }
    [self sendGroupMsg:[TXChatSalonIMJsonHandle getCusMsgJsonStrWithCmd:cmd msg:message] callback:callback];
}

- (void)sendGroupMsg:(NSString *)message callback:(TXCallback)callback {
    if (!self.mRoomId || [self.mRoomId isEqualToString:@""]) {
        if (callback) {
            callback(-1, @"gourp id is wrong.please check it.");
        }
        return;
    }
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        callback(-1, @"message can't covert to data");
        return;
    }
    [self.imManager sendGroupCustomMessage:data to:self.mRoomId priority:V2TIM_PRIORITY_NORMAL succ:^{
        if (callback) {
            callback(0, @"send group message success.");
        }
    } fail:^(int code, NSString *desc) {
        TRTCLog(@"error: send group message error. error:%d, message:%@", code, desc);
        if (callback) {
            callback(code, desc);
        }
    }];
}

- (void)getAudienceList:(TXUserListCallback)callback {
    [self.imManager getGroupMemberList:self.mRoomId filter:V2TIM_GROUP_MEMBER_FILTER_COMMON nextSeq:0 succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        if (memberList) {
            NSMutableArray *resultList = [[NSMutableArray alloc] initWithCapacity:2];
            [memberList enumerateObjectsUsingBlock:^(V2TIMGroupMemberFullInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                TXChatSalonUserInfo *info = [[TXChatSalonUserInfo alloc] init];
                info.userID = obj.userID;
                info.userName = obj.nickName;
                info.avatarURL = obj.faceURL;
                [resultList addObject:info];
            }];
            if (callback) {
                callback(0, @"get audience list success.", resultList);
            }
        } else {
            if (callback) {
                callback(-1, @"get audience list fail, results is nil", @[]);
            }
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc ?: @"get sudience list fail.", @[]);
        }
    }];
}

- (void)getRoomInfoList:(NSArray<NSString *> *)roomIds calback:(TXChatSalonRoomInfoListCallback)callback {
    [self.imManager getGroupsInfo:roomIds succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
        if (groupResultList) {
            NSMutableArray *groupResults = [[NSMutableArray alloc] initWithCapacity:2];
            NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithCapacity:2];
            [groupResultList enumerateObjectsUsingBlock:^(V2TIMGroupInfoResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj && obj.info.groupID) {
                    tempDic[obj.info.groupID] = obj;
                }
            }];
            [roomIds enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                TXChatSalonRoomInfo *roomInfo = [[TXChatSalonRoomInfo alloc] init];
                V2TIMGroupInfoResult* groupInfo = tempDic[obj];
                if (groupInfo) {
                    roomInfo.roomId = groupInfo.info.groupID;
                    roomInfo.cover = groupInfo.info.faceURL;
                    roomInfo.memberCount = groupInfo.info.memberCount;
                    roomInfo.ownerId = groupInfo.info.owner;
                    roomInfo.roomName = groupInfo.info.groupName;
                    roomInfo.ownerName = groupInfo.info.introduction;
                }
                [groupResults addObject:roomInfo];
            }];
            if (callback) {
                callback(0, @"success.", groupResults);
            }
        } else {
            if (callback) {
                callback(-1, @"get group info failed. result is nil.", @[]);
            }
        }
    } fail:^(int code, NSString *desc) {
        
    }];
}

- (void)destroy {
    
}

- (NSString *)sendInvitation:(NSString *)cmd userID:(NSString *)userID content:(NSString *)content callback:(TXCallback)callback {
    NSString* jsonString = [TXChatSalonIMJsonHandle getInvitationMsgWithRoomId:self.mRoomId cmd:cmd content:content];
    return [self.imManager invite:userID data:jsonString timeout:20 succ:^{
        TRTCLog(@"send invitation success.");
        if (callback) {
            callback(0, @"send invitation success.");
        }
    } fail:^(int code, NSString *desc) {
        TRTCLog(@"send invitation failed");
        if (callback) {
            callback(code, desc ?: @"send invatiaon failed");
        }
    }];
}

- (void)acceptInvitation:(NSString *)identifier callback:(TXCallback)callback {
    TRTCLog(@"accept %@", identifier);
    [self.imManager accept:identifier data:nil succ:^{
        TRTCLog(@"accept invitation success.");
        if (callback) {
            callback(0, @"accept invitation success.");
        }
    } fail:^(int code, NSString *desc) {
        TRTCLog(@"accept invitation failed");
        if (callback) {
            callback(code, desc ?: @"accept invatiaon failed");
        }
    }];
}

- (void)rejectInvitaiton:(NSString *)identifier callback:(TXCallback)callback {
    TRTCLog(@"reject %@", identifier);
    [self.imManager reject:identifier data:nil succ:^{
        TRTCLog(@"reject invitation success.");
        if (callback) {
            callback(0, @"reject invitation success.");
        }
    } fail:^(int code, NSString *desc) {
        TRTCLog(@"reject invitation failed");
        if (callback) {
            callback(code, desc ?: @"reject invatiaon failed");
        }
    }];
}

- (void)cancelInvitation:(NSString *)identifier callback:(TXCallback)callback {
    TRTCLog(@"cancel %@", identifier);
    [self.imManager cancel:identifier data:nil succ:^{
        TRTCLog(@"cancel invitation success.");
        if (callback) {
            callback(0, @"cancel invitation success.");
        }
    } fail:^(int code, NSString *desc) {
        TRTCLog(@"cancel invitation success.");
        if (callback) {
            callback(0, @"cancel invitation success.");
        }
    }];
}
#pragma mark - V2TIMSDKListener

#pragma mark - V2TIMSimpleMsgListener
- (void)onRecvC2CTextMessage:(NSString *)msgID sender:(V2TIMUserInfo *)info text:(NSString *)text {
    
}

- (void)onRecvC2CCustomMessage:(NSString *)msgID sender:(V2TIMUserInfo *)info customData:(NSData *)data {
    if (!data) {
        return;
    }
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dic = [jsonString mj_JSONObject];
    NSString *version = [dic objectForKey:VOICE_ROOM_KEY_ATTR_VERSION];
    if (!version || ![version isEqualToString:VOICE_ROOM_VALUE_ATTR_VERSION]) {
        TRTCLog(@"protocol version is nil or not match, ignore c2c msg");
        return;
    }
    NSNumber *action = [dic objectForKey:VOICE_ROOM_KEY_CMD_ACTION];
    if (!action) {
        TRTCLog(@"c2c action can't parse from data");
        return;
    }
    int actionValue = [action intValue];
    switch (actionValue) {
        case kChatSalonCodeKickSeatMsg:
            if ([self canDelegateResponseMethod:@selector(onSeatKick)]) {
                [self.delegate onSeatKick];
            }
            break;
        case kChatSalonCodePickSeatMsg:
            if ([self canDelegateResponseMethod:@selector(onSeatPick)]) {
                [self.delegate onSeatPick];
            }
            break;
        default:
            break;
    }
}

- (void)onRecvGroupTextMessage:(NSString *)msgID groupID:(NSString *)groupID sender:(V2TIMGroupMemberInfo *)info text:(NSString *)text {
    TRTCLog(@"im get tet msg group:%@, userID:%@, text:%@", groupID, info.userID, text);
    if (![groupID isEqualToString:self.mRoomId]) {
        return;
    }
    TXChatSalonUserInfo* userInfo = [[TXChatSalonUserInfo alloc] init];
    userInfo.userID = info.userID;
    userInfo.avatarURL = info.faceURL;
    userInfo.userName = info.nickName;
    if ([self canDelegateResponseMethod:@selector(onRoomRecvRoomTextMsg:message:userInfo:)]) {
        [self.delegate onRoomRecvRoomTextMsg:self.mRoomId message:text userInfo:userInfo];
    }
}

- (void)onRecvGroupCustomMessage:(NSString *)msgID groupID:(NSString *)groupID sender:(V2TIMGroupMemberInfo *)info customData:(NSData *)data {
    TRTCLog(@"im get custom msg group:%@, userID:%@, text:%@", groupID, info.userID, data);
    if (![groupID isEqualToString:self.mRoomId]) {
        return;
    }
    if (!data) {
        return;
    }
    NSString* jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary* dic = [jsonString mj_JSONObject];
    NSString *version = [dic objectForKey:VOICE_ROOM_KEY_ATTR_VERSION];
    if (!version || ![version isEqualToString:VOICE_ROOM_VALUE_ATTR_VERSION]) {
        TRTCLog(@"protocol version is not match, ignore msg");
        return;
    }
    NSNumber* action = [dic objectForKey:VOICE_ROOM_KEY_CMD_ACTION];
    if (!action) {
        TRTCLog(@"action can't parse from data");
        return;
    }
    int actionValue = [action intValue];
    switch (actionValue) {
        case kChatSalonCodeUnknown:
            break;
        case kChatSalonCodeCustomMsg:
        {
            NSDictionary *cusPair = [TXChatSalonIMJsonHandle parseCusMsgWithJsonDic:dic];
            TXChatSalonUserInfo *userInfo = [[TXChatSalonUserInfo alloc] init];
            userInfo.userID = info.userID;
            userInfo.avatarURL = info.faceURL;
            userInfo.userName = info.nickName;
            if ([self canDelegateResponseMethod:@selector(onRoomRecvRoomCustomMsg:cmd:message:userInfo:)]) {
                [self.delegate onRoomRecvRoomCustomMsg:self.mRoomId cmd:cusPair[@"cmd"] message:cusPair[@"message"] userInfo:userInfo];
            }
        }
            break;
        case kChatSalonCodeDestroy:
        {
            [self exitRoom:nil];
            if ([self canDelegateResponseMethod:@selector(onRoomDestroyWithRoomId:)]) {
                [self.delegate onRoomDestroyWithRoomId:self.mRoomId];
            }
            [self cleanRoomStatus];
        }
            break;
        default:
            break;
    }
}
#pragma mark - V2TIMGroupListener
- (void)onMemberEnter:(NSString *)groupID memberList:(NSArray<V2TIMGroupMemberInfo *> *)memberList{
    if (![groupID isEqualToString:self.mRoomId]) {
        return;
    }
    [memberList enumerateObjectsUsingBlock:^(V2TIMGroupMemberInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TXChatSalonUserInfo* userInfo = [[TXChatSalonUserInfo alloc] init];
        userInfo.userID = obj.userID;
        userInfo.avatarURL = obj.faceURL;
        userInfo.userName = obj.nickName;
        if ([self canDelegateResponseMethod:@selector(onRoomAudienceEnter:)]) {
            [self.delegate onRoomAudienceEnter:userInfo];
        }
    }];
}

- (void)onMemberLeave:(NSString *)groupID member:(V2TIMGroupMemberInfo *)member{
    if (![groupID isEqualToString:self.mRoomId]) {
        return;
    }
    if (!member) {
        return;
    }
    TXChatSalonUserInfo *userInfo = [[TXChatSalonUserInfo alloc] init];
    userInfo.userID = member.userID;
    userInfo.avatarURL = member.faceURL;
    userInfo.userName = member.nickName;
    if ([self canDelegateResponseMethod:@selector(onRoomAudienceLeave:)]) {
        [self.delegate onRoomAudienceLeave:userInfo];
    }
}

- (void)onGroupDismissed:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser{
    if (![groupID isEqualToString:self.mRoomId]) {
        return;
    }
    [self cleanRoomStatus];
    if ([self canDelegateResponseMethod:@selector(onRoomDestroyWithRoomId:)]) {
        [self.delegate onRoomDestroyWithRoomId:groupID];
    }
}

- (void)onGroupAttributeChanged:(NSString *)groupID attributes:(NSMutableDictionary<NSString *,NSString *> *)attributes{
    TRTCLog(@"on group attr changed:%@", attributes);
    if (![groupID isEqualToString:self.mRoomId]) {
        return;
    }
    if (!attributes) {
        TRTCLog(@"attributes error");
        return;
    }
    NSDictionary<NSString *, TXChatSalonSeatInfo *> *seatInfoList = [TXChatSalonIMJsonHandle getSeatListFromAttr:attributes];
    NSDictionary *oldSeatInfoList = [self.seatInfoList copy];
    self.seatInfoList = [seatInfoList mutableCopy];
    NSSet* allKeys = [NSSet setWithArray:oldSeatInfoList.allKeys];
    allKeys = [allKeys setByAddingObjectsFromArray:seatInfoList.allKeys];
    for (NSString *key in allKeys) {
        TXChatSalonSeatInfo *old = [oldSeatInfoList objectForKey:key];
        TXChatSalonSeatInfo *new = [seatInfoList objectForKey:key];
        if (old == nil & new != nil) {
            // 有人进入
//            [self onSeatTakeWithUser:new.user];
        }
        if (old != nil & new == nil) {
//            [self onSeatLeaveWithUser:old.user];
        }
        if ((old != nil & new != nil) & (old.mute != new.mute)) {
//            [self onSeatMuteWithUser:new.user mute:new.mute];
        }
        if (old == nil && new == nil) {
            NSAssert(NO, @"seat info error, old and new info all be nil.");
        }
    }
}


#pragma mark - V2TIMSignalingListener
- (void)onReceiveNewInvitation:(NSString *)inviteID inviter:(NSString *)inviter groupID:(NSString *)groupID inviteeList:(NSArray<NSString *> *)inviteeList data:(NSString *)data{
    TXChatSalonInviteData *result = [TXChatSalonIMJsonHandle parseInvitationMsgWithJson:data];
    if (!result) {
        TRTCLog(@"parse data error");
        return;
    }
    if (![result.roomId isEqualToString:self.mRoomId]) {
        TRTCLog(@"room id is not right");
        return;
    }
    if ([self canDelegateResponseMethod:@selector(onReceiveNewInvitationWithIdentifier:inviter:cmd:content:)]) {
        [self.delegate onReceiveNewInvitationWithIdentifier:inviteID inviter:inviter cmd:result.command content:result.message];
    }
}

- (void)onInviteeAccepted:(NSString *)inviteID invitee:(NSString *)invitee data:(NSString *)data {
    if ([self canDelegateResponseMethod:@selector(onInviteeAcceptedWithIdentifier:invitee:)]) {
        [self.delegate onInviteeAcceptedWithIdentifier:inviteID invitee:invitee];
    }
}

-(void)onInviteeRejected:(NSString *)inviteID invitee:(NSString *)invitee data:(NSString *)data {
    if ([self canDelegateResponseMethod:@selector(onInviteeRejectedWithIdentifier:invitee:)]) {
        [self.delegate onInviteeRejectedWithIdentifier:inviteID invitee:invitee];
    }
}

- (void)onInvitationCancelled:(NSString *)inviteID inviter:(NSString *)inviter data:(NSString *)data {
    if ([self canDelegateResponseMethod:@selector(onInviteeCancelledWithIdentifier:invitee:)]) {
        [self.delegate onInviteeCancelledWithIdentifier:inviteID invitee:inviter];
    }
}

-(void)onInvitationTimeout:(NSString *)inviteID inviteeList:(NSArray<NSString *> *)inviteeList {
    if ([self canDelegateResponseMethod:@selector(onInvitationTimeout:)]) {
        [self.delegate onInvitationTimeout:inviteID];
    }
}

#pragma mark - private method
- (V2TIMManager *)imManager {
    return [V2TIMManager sharedInstance];
}

- (BOOL)isOwner {
    return [self.selfUserId isEqualToString:self.ownerUserId];
}

- (void)cleanRoomStatus {
    self.isEnterRoom = NO;
    self.mRoomId = @"";
    self.ownerUserId = @"";
}

- (BOOL)canDelegateResponseMethod:(SEL)method {
    return self.delegate && [self.delegate respondsToSelector:method];
}

- (void)onSeatTakeWithUser:(NSString *)userID {
    TRTCLog(@"onSeatTake: %ld, user: %@", (long)index, userID);
    @weakify(self)
    [self getUserInfo:@[userID] callback:^(int code, NSString * _Nonnull message, NSArray<TXChatSalonUserInfo *> * _Nonnull userInfos) {
        @strongify(self)
        if (!self) {
            return;
        }
        TXChatSalonUserInfo *userInfo = [[TXChatSalonUserInfo alloc] init];
        if (code == 0 && userInfos.count > 0) {
            userInfo = userInfos[0];
        } else {
            TRTCLog(@"onSeat Take get user info error!");
            userInfo.userID = userID;
            userInfo.userName = userID;
            // TODO: 添加默认用户头像
        }
        if ([self canDelegateResponseMethod:@selector(onSeatTakeWithUserInfo:)]) {
            [self.delegate onSeatTakeWithUserInfo:userInfo];
        }
    }];
}

- (void)onSeatLeaveWithUser:(NSString *)userID {
    TRTCLog(@"onSeatLeave user: %@", userID);
    @weakify(self)
    [self getUserInfo:@[userID] callback:^(int code, NSString * _Nonnull message, NSArray<TXChatSalonUserInfo *> * _Nonnull userInfos) {
        @strongify(self)
        if (!self) {
            return;
        }
        TXChatSalonUserInfo *userInfo = [[TXChatSalonUserInfo alloc] init];
        if (code == 0 && userInfos.count > 0) {
            userInfo = userInfos[0];
        } else {
            TRTCLog(@"onSeat Take get user info error!");
            userInfo.userID = userID;
            userInfo.userName = userID;
        }
        if ([self canDelegateResponseMethod:@selector(onSeatLeaveWithUserInfo:)]) {
            [self.delegate onSeatLeaveWithUserInfo:userInfo];
        }
    }];
}

- (void)onSeatMuteWithUser:(NSString *)userID mute:(BOOL)mute {
    TRTCLog(@"onSeatMute: %@, mute:%d", userID, mute);
    if ([self canDelegateResponseMethod:@selector(onSeatMuteWithUser:mute:)]) {
        [self.delegate onSeatMuteWithUser:userID mute:mute];
    }
}

- (void)initImListener {
    [self.imManager setGroupListener:self];
    // 设置前先remove下，防止在单例的情况下重复设置
    [self.imManager removeSignalingListener:self];
    [self.imManager removeSimpleMsgListener:self];
    [self.imManager addSignalingListener:self];
    [self.imManager addSimpleMsgListener:self];
}

- (void)unInitIMListener {
    [self.imManager setGroupListener:nil];
    [self.imManager removeSignalingListener:self];
    [self.imManager removeSimpleMsgListener:self];
}

- (void)onCreateSuccess:(TXCallback _Nullable)callback {
    [self initImListener];
    @weakify(self)
    [self.imManager initGroupAttributes:self.mRoomId
                             attributes:[TXChatSalonIMJsonHandle getInitRoomDicWithRoomInfo:self.roomInfo seatInfoList:self.seatInfoList]
                                   succ:^{
        @strongify(self)
        if (!self) { return; }
        self.isEnterRoom = YES;
        if (callback) {
            callback(0, @"init room info and seat success");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc ?: @"init group attributes failed");
        }
    }];
}

- (void)onJoinRoomSuccessWithRoomId:(NSString *)roomId callback:(TXCallback _Nullable)callback {
    @weakify(self)
    [self.imManager getGroupAttributes:roomId keys:nil succ:^(NSMutableDictionary<NSString *,NSString *> *groupAttributeList) {
        @strongify(self)
        if (!self) {
            return;
        }
        [self initImListener];
        if (!groupAttributeList) {
            return;
        }
        // 解析roomInfo
        TXChatSalonRoomInfo* roomInfo = [TXChatSalonIMJsonHandle getRoomInfoFromAttr:groupAttributeList];
        if (roomInfo) {
            roomInfo.roomId = roomId;
            roomInfo.memberCount = -1; // 当前房间的MemberCount无法从这个接口正确获取。
            self.roomInfo = roomInfo;
        } else {
            TRTCLog(@"group room info is empty, enter room failed.");
            if (callback) {
                callback(-1, @"group room info is empty, enter room failed.");
            }
            return;
        }
        TRTCLog(@"enter room successed.");
        self.mRoomId = roomId;
        self.seatInfoList = [[TXChatSalonIMJsonHandle getSeatListFromAttr:groupAttributeList] mutableCopy];
        self.isEnterRoom = true;
        self.ownerUserId = self.roomInfo.ownerId;
        if ([self canDelegateResponseMethod:@selector(onRoomInfoChange:)]) {
            [self.delegate onRoomInfoChange:self.roomInfo];
        }
//        if ([self canDelegateResponseMethod:@selector(onSeatInfoListChange:)]) {
//            [self.delegate onSeatInfoListChange:self.seatInfoList];
//        }
        if (callback) {
            callback(0, @"enter rooom success");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc ?: @"get group attr error");
        }
    }];
}

- (void)cleanGroupAttr {
    [self.imManager deleteGroupAttributes:self.mRoomId keys:nil succ:nil fail:nil];
}

- (void)modeifyGroupAttrs:(NSDictionary<NSString *, NSString *> *)attrs callback:(TXCallback _Nullable)callback {
    [self.imManager setGroupAttributes:self.mRoomId attributes:attrs succ:^{
        if (callback) {
            callback(0, @"modify group attrs success");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc ?: @"modify group attrs failed");
        }
    }];
}

- (void)removeGroupAttrs:(NSArray<NSString *> *)attrKeys callback:(TXCallback _Nullable)callback {
    [self.imManager deleteGroupAttributes:self.mRoomId keys:attrKeys succ:^{
        if (callback) {
            callback(0, @"delete group attrs success");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc ?: @"delete group attrs failed");
        }
    }];
}

- (void)setGroupInfoWithRoomId:(NSString *)roomId roomName:(NSString *)roomName coverUrl:(NSString *)coverUrl userName:(NSString *)userName {
    V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
    info.groupID = roomId;
    info.groupName = roomName;
    info.faceURL = coverUrl;
    info.introduction = userName;
    [self.imManager setGroupInfo:info succ:^{
        TRTCLog(@"success: set group info success.");
    } fail:^(int code, NSString *desc) {
        TRTCLog(@"fail: set group info fail.");
    }];
}

@end
