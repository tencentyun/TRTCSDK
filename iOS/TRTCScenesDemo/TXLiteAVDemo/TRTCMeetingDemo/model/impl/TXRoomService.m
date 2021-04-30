//
//  TXRoomService.m
//  TRTCScenesDemo
//
//  Created by J J on 2020/5/29.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

#import "TXRoomService.h"

#import <V2TIMManager.h>
#import <TIMComm.h>
#import <TIMFriendshipManager.h>

#import "IMProtocol.h"
#import "TXMeetingPair.h"
#import "AppLocalized.h"

@interface TXRoomService() <V2TIMSimpleMsgListener, V2TIMGroupListener>

@property (nonatomic, assign) BOOL mIsInitIMSDK;
@property (nonatomic, assign) BOOL mIsLogin;
@property (nonatomic, assign) BOOL mIsEnterRoom;

@property (nonatomic, strong) NSString *mRoomId;
@property (nonatomic, strong) NSString *mSelfUserId;
@property (nonatomic, strong) NSString *mOwnerUserId;

@end

NSString *TAG = @"TXMeetingRoomService";
NSInteger CODE_ERROE = -1;

@implementation TXRoomService

static TXRoomService *_sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[TXRoomService alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mIsInitIMSDK = NO;
        self.mIsLogin = NO;
        self.mIsEnterRoom = NO;
        
        self.mSelfUserId = @"";
        self.mOwnerUserId = @"";
        self.mRoomId = @"";
    }
    return self;
}

- (void)login:(NSInteger)sdkAppId userId:(NSString *)userId userSign:(NSString *)userSign callback:(TXCallback)callback {
    // 先初始化 IM
    if (!_mIsInitIMSDK) {
        _mIsInitIMSDK = [V2TIMManager.sharedInstance initSDK:(int)sdkAppId config:nil listener:nil];
        [V2TIMManager.sharedInstance addSimpleMsgListener:self];
        [V2TIMManager.sharedInstance setGroupListener:self];
        
        if (!_mIsInitIMSDK) {
            if (callback) {
                callback(CODE_ERROE, @"init im sdk error.");
            }
            return;
        }
    }
    
    // 登陆到 IM
    NSString *loginedUserId = V2TIMManager.sharedInstance.getLoginUser;
    if (loginedUserId != nil && [loginedUserId isEqualToString:userId]) {
        //已经登陆过了
        _mIsLogin = YES;
        _mSelfUserId = userId;
        if (callback) {
            callback(0, @"login im successful.");
        }
        return;
    }
    
    if (self.isLogin) {
        if (callback) {
            callback(CODE_ERROE, @"start login fail, you have been login, can't login twice.");
        }
        return;
    }
    
    [V2TIMManager.sharedInstance login:userId userSig:userSign succ:^{
        self.mIsLogin = true;
        self.mSelfUserId = userId;
        if (callback) {
            callback(0, @"login im success.");
        }
        
    } fail:^(int code, NSString *desc) {
        NSLog(@"login failed: code[%d] desc[%@]", code, desc);
        if (callback) {
            callback(code, desc);
        }
    }];
}


- (void)logout:(TXCallback)callback {
    if (!self.isLogin) {
        if (callback) {
            callback(CODE_ERROE, @"start logout fail, not login yet.");
        }
        return;
    }
    
    if (self.isEnterRoom) {
        if (callback != nil) {
            callback(CODE_ERROE, [NSString stringWithFormat:@"start logout fail, you are in room: %@ , please exit room before logout.", _mRoomId]);
        }
        return;
    }
    
    [V2TIMManager.sharedInstance logout:^{
        self.mIsLogin = false;
        self.mSelfUserId = @"";
        if (callback) {
            callback(0, @"logout im success.");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc);
        }
    }];
}

- (void)setSelfProfile:(NSString *)userName avatarURL:(NSString *)avatarURL callback:(TXCallback)callback {
    if (!self.isLogin) {
        if (callback) {
            callback(CODE_ERROE, @"set profile fail, not login yet.");
        }
        return;
    }
    
    NSMutableDictionary *profileDictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
    [profileDictionary setValue:userName forKey:TIMProfileTypeKey_Nick];
    [profileDictionary setValue:avatarURL forKey:TIMProfileTypeKey_FaceUrl];
    [TIMFriendshipManager.sharedInstance modifySelfProfile:profileDictionary succ:^{
        if (callback) {
            callback(0, @"set profile success.");
        }
    } fail:^(int code, NSString *msg) {
        if (callback) {
            callback(code, msg);
        }
    }];
}

- (void)createRoom:(NSString *)roomId roomInfo:(NSString *)roomInfo coverUrl:(NSString *)coverUrl callback:(TXCallback)callback {
    if (self.isEnterRoom) {
        if (callback) {
            callback(CODE_ERROE, [NSString stringWithFormat:@"you have been in room :%@ can't create another room: %@", _mRoomId, roomId]);
        }
        return;
    }
    
    if (!self.isLogin) {
        if (callback) {
            callback(CODE_ERROE, @"im  not login yet, create room fail.");
        }
        return;
    }
    
    TIMCreateGroupInfo *groupInfomation = [[TIMCreateGroupInfo alloc] init];
    groupInfomation.groupType = @"ChatRoom";
    groupInfomation.groupName = roomInfo;
    groupInfomation.faceURL = coverUrl;
    groupInfomation.group = roomId;
    
    [V2TIMManager.sharedInstance createGroup:@"AVChatRoom" groupID:roomId groupName:roomInfo succ:^(NSString *groupID) {
        self.mIsEnterRoom = true;
        self.mRoomId = roomId;
        self.mOwnerUserId = self.mSelfUserId;
        
        if (callback) {
            callback(0, @"create room success.");
        }
        
    } fail:^(int code, NSString *desc) {
        NSString *msg = [NSString stringWithFormat:@"%@", desc];
        if (code == 10036) {
            msg = LocalizeReplaceXX(TRTCLocalize(@"Demo.TRTC.Buy.chatroom"), @"https://cloud.tencent.com/document/product/269/11673");
        } else if (code == 10037) {
            msg = LocalizeReplaceXX(TRTCLocalize(@"Demo.TRTC.Buy.grouplimit"), @"https://cloud.tencent.com/document/product/269/11673");
        } else if (code == 10038) {
            msg = LocalizeReplaceXX(TRTCLocalize(@"Demo.TRTC.Buy.groupmemberlimit"), @"https://cloud.tencent.com/document/product/269/11673");
        }
        
        if (code == 10025) {
            self.mIsEnterRoom = true;
            self.mRoomId = roomId;
            self.mOwnerUserId = self.mSelfUserId;
            
            if(callback) {
                callback(0, @"create room success.");
            }
        }
        else {
            NSLog(@"createGroup failed: code[%d] msg[%@]", code, msg);
            if (callback) {
                callback(code, msg);
            }
        }
    }];
}

- (void)destroyRoom:(TXCallback)callback {
    [V2TIMManager.sharedInstance dismissGroup:self.mRoomId succ:^{
        [self cleanStatus];
        
        
        if (callback) {
            callback(0, @"destroy room success.");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc);
        }
    }];
}

- (void)enterRoom:(NSString *)roomId callback:(TXCallback)callback {
    [V2TIMManager.sharedInstance joinGroup:roomId msg:@"" succ:^{
        NSArray *groupArray = [[NSArray alloc] initWithObjects:roomId, nil];
        [V2TIMManager.sharedInstance getGroupsInfo:groupArray succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
            V2TIMGroupInfoResult *result = [groupResultList objectAtIndex:0];
            if (result) {
                self.mRoomId = roomId;
                self.mIsEnterRoom = true;
                self.mOwnerUserId = result.info.owner;
                
                if (callback) {
                    callback(0, @"enter room success.");
                }
            } else {
                if (callback) {
                    callback(-1, @"groupResultList is null");
                }
            }
            
        } fail:^(int code, NSString *desc) {
            if (callback) {
                callback(-1, [NSString stringWithFormat:@"getGroupsInfo error, enter room fail. code: %d msg:%@", code, desc]);
            }
        }];
        
    } fail:^(int code, NSString *desc) {
        if (code == 10013) {
            self.mRoomId = roomId;
            self.mIsEnterRoom = true;
            // self.mOwnerUserId = ""; // TODO
            
            if (callback) {
                callback(0, @"enter room success.");
            }
        } else {
            //10015: 群组 ID 非法，请检查群组 ID 是否填写正确。
            if (callback) {
                callback(code, desc);
            }
        }
    }];
}

- (void)exitRoom:(TXCallback)callback {
    if (!self.isEnterRoom) {
        if (callback) {
            callback(CODE_ERROE, @"not enter room yet, can't exit room.");
        }
        return;
    }
    
    [V2TIMManager.sharedInstance quitGroup:self.mRoomId succ:^{
        [self cleanStatus];
        if (callback) {
            callback(0, @"exit room success.");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc);
        }
    }];
}

- (void)getUserInfo:(NSArray *)userList callback:(TXUserListCallback)callback {
    NSArray<TXUserInfo *> *array = [[NSArray alloc] init];
    if (!self.isEnterRoom) {
        if (callback) {
            callback(CODE_ERROE, @"get user info list fail, not enter room yet", array);
        }
        return;
    }
    
    if (userList == nil || userList.count == 0) {
        if (callback) {
            callback(CODE_ERROE, @"get user info list fail, user list is empty", array);
        }
        return;
    }
    
    [TIMFriendshipManager.sharedInstance getUsersProfile:userList forceUpdate:true succ:^(NSArray<TIMUserProfile *> *profiles) {
        NSMutableArray<TXUserInfo *>*infoArray = [NSMutableArray array];
        if (profiles != nil && profiles.count != 0) {
            for (int i = 0; i < profiles.count; i ++) {
                TXUserInfo *userInfo = [[TXUserInfo alloc] init];
                userInfo.userName = profiles[i].nickname;
                userInfo.userId = profiles[i].identifier;
                userInfo.avatarURL = profiles[i].faceURL;
                [infoArray addObject:userInfo];
            }
        }
        if (callback) {
            callback(0, @"success", infoArray);
        }
        
    } fail:^(int code, NSString *msg) {
        if (callback) {
            callback(code, msg, array);
        }
    }];
}

- (void)sendRoomTextMsg:(NSString *)msg callback:(TXCallback)callback {
    if (!self.isEnterRoom) {
        if (callback) {
            callback(-1, @"send room text fail, not enter room yet.");
        }
        return;
    }

    [V2TIMManager.sharedInstance sendGroupTextMessage:msg to:self.mRoomId priority:V2TIM_PRIORITY_LOW succ:^{
        if (callback) {
            callback(0, @"send group message success.");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc);
        }
    }];
}

- (void)sendRoomCustomMsg:(NSString *)cmd message:(NSString *)message callback:(TXCallback)callback {
    if (!self.isEnterRoom) {
        if (callback) {
            callback(-1, @"send room custom msg fail, not enter room yet.");
        }
        return;
    }
    
    NSData *customData = [[IMProtocol getCusMsgJsonStr:cmd msg:message] dataUsingEncoding:NSUTF8StringEncoding];
    
    [V2TIMManager.sharedInstance sendGroupCustomMessage:customData to:self.mRoomId priority:V2TIM_PRIORITY_LOW succ:^{
        if (callback) {
            callback(0, @"send group message success.");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc);
        }
    }];
}

- (BOOL)isLogin {
    return _mIsLogin;
}

- (BOOL)isEnterRoom {
    return _mIsLogin && _mIsEnterRoom;
}

- (NSString *)getOwnerUserId {
    return _mOwnerUserId;
}

- (BOOL)isOwner {
    return [_mSelfUserId isEqualToString:_mOwnerUserId];
}

- (void)cleanStatus {
    self.mIsEnterRoom = false;
    self.mRoomId = @"";
    self.mOwnerUserId = @"";
}

#pragma mark - V2TIMSimpleMsgListener

/// 收到群文本消息
- (void)onRecvGroupTextMessage:(NSString *)msgID groupID:(NSString *)groupID sender:(V2TIMGroupMemberInfo *)info text:(NSString *)text {
    if (![groupID isEqualToString:self.mRoomId]) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onRoomRecvRoomTextMsg:message:userInfo:)]) {
        TXUserInfo *userInfo = [[TXUserInfo alloc] init];
        userInfo.avatarURL = info.faceURL;
        userInfo.userId = info.userID;
        userInfo.userName = info.nickName;
        [self.delegate onRoomRecvRoomTextMsg:self.mRoomId message:text userInfo:userInfo];
    }
}

/// 收到群自定义（信令）消息
- (void)onRecvGroupCustomMessage:(NSString *)msgID groupID:(NSString *)groupID sender:(V2TIMGroupMemberInfo *)info customData:(NSData *)data {
    if (![groupID isEqualToString:self.mRoomId]) {
        return;
    }
    
    NSError *err = NULL;
    NSDictionary *jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        NSLog(@"json parse failed");
        return;
    }

    NSString *version = [jsonObj valueForKey:KEY_VERSION];
    if (![version isEqualToString:VALUE_PROTOCOL_VERSION]) {
        NSLog(@"protocol version is not match, ignore msg.");
        return;
    }
    
    int action = [[jsonObj valueForKey:KEY_ACTION] intValue];
    if (action == CODE_ROOM_CUSTOM_MESSAGE) {
        TXUserInfo *userInfo = [[TXUserInfo alloc] init];
        userInfo.avatarURL = info.faceURL;
        userInfo.userId = info.userID;
        userInfo.userName = info.nickName;
        
        TXMeetingPair *cusPair = [[TXMeetingPair alloc] init];
        cusPair = [IMProtocol parseCusMsg:jsonObj];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onRoomRecvRoomCustomMsg:cmd:message:userInfo:)]) {
            [self.delegate onRoomRecvRoomCustomMsg:self.mRoomId cmd:cusPair.first message:cusPair.second userInfo:userInfo];
        }
    }
}

#pragma mark - V2TIMGroupListener
         
/// 某个已加入的群被解散了（该群所有的成员都能收到）
- (void)onGroupDismissed:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser {
    // 如果发现房间已经解散，那么内部退一次房间
    [self exitRoom:^(NSInteger code, NSString *msg) {
        NSString *roomId = self.mRoomId;
        [self cleanStatus];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onRoomDestroy:)]) {
            [self.delegate onRoomDestroy:roomId];
        }
    }];
}


@end
