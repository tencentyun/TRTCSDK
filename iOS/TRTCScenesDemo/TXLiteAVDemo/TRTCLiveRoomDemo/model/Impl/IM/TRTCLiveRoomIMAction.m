//
//  TRTCLiveRoomIMAction.m
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/8.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TRTCLiveRoomIMAction.h"
#import "TXLiveRoomCommonDef.h"
#import <ImSDK/ImSDK.h>
#import "TRTCLiveRoomDef.h"
#import <MJExtension.h>
#import "AppLocalized.h"

typedef NS_ENUM(NSUInteger, ConvType) {
    ConvTypeUser,
    ConvTypeGroup,
};

@interface ConversationParams : NSObject

@property (nonatomic, assign) ConvType type;
@property (nonatomic, copy) NSString *userID;

@property (nonatomic, copy) NSString *gourpID;
@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, assign) V2TIMMessagePriority priority;


@end

@implementation ConversationParams

@end


@implementation TRTCLiveRoomIMAction

// FIXME: - 无用参数移除
+ (BOOL)setupSDKWithSDKAppID:(int)sdkAppId userSig:(NSString *)userSig messageLister:(id<V2TIMAdvancedMsgListener,V2TIMGroupListener>)listener {
    BOOL reslut = [[V2TIMManager sharedInstance] initSDK:sdkAppId config:nil listener:nil];
    if (reslut) {
        [[V2TIMManager sharedInstance] removeAdvancedMsgListener:listener]; //  添加前先移除，避免重复初始化导致收到重复消息
        [[V2TIMManager sharedInstance] addAdvancedMsgListener:listener];
        [[V2TIMManager sharedInstance] setGroupListener:listener];
    }
    return reslut;
}

+ (void)releaseSdk {
    [[V2TIMManager sharedInstance] unInitSDK];
}

+ (void)loginWithUserID:(NSString *)userID userSig:(NSString *)userSig callback:(LRIMCallback)callback {
    if (!userID || [userID isEqualToString:@""]) {
        if (callback) {
            callback(-1, @"user id error.");
        }
        return;
    }
    if ([[[V2TIMManager sharedInstance] getLoginUser] isEqualToString:userID]) {
        callback(0, @"alerady login");
        return;
    }
    [[V2TIMManager sharedInstance] login:userID userSig:userSig succ:^{
        if (callback) {
            callback(0, @"success");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc ?: @"login failed.");
        }
    }];
}

+ (void)logout:(LRIMCallback)callback {
    [[V2TIMManager sharedInstance] logout:^{
        if (callback) {
            callback(0, @"success");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc ?: @"login failed.");
        }
    }];
}

+ (void)setProfileWithName:(NSString *)name avatar:(NSString *)avatar callback:(LRIMCallback)callback {
    V2TIMUserFullInfo* info = [[V2TIMUserFullInfo alloc] init];
    info.nickName = name;
    info.faceURL = avatar;
    [[V2TIMManager sharedInstance] setSelfInfo:info succ:^{
        if (callback) {
            callback(0, @"success");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc ?: @"set profile failed.");
        }
    }];
}

+ (void)createRoomWithRoomID:(NSString *)roomID roomParam:(TRTCCreateRoomParam *)roomParam success:(LREnterRoomCallback)success error:(LRIMCallback)errorCallback {
    [[V2TIMManager sharedInstance] createGroup:@"AVChatRoom" groupID:roomID groupName:roomParam.roomName succ:^(NSString *groupID) {
        if (success) {
            success(@[], @{}, nil);
        }
        V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
        info.groupID = roomID;
        info.faceURL = roomParam.coverUrl;
        info.groupName = roomParam.roomName;
        [[V2TIMManager sharedInstance] setGroupInfo:info succ:nil fail:nil];
    } fail:^(int code, NSString *desc) {
        if (code == ERR_SVR_GROUP_GROUPID_IN_USED_FOR_SUPER) {
            // 房间是自己创建的
            [[V2TIMManager sharedInstance] joinGroup:roomID msg:nil succ:^{
                [TRTCLiveRoomIMAction getAllMembersWithRoomID:roomID success:^(NSArray<TRTCLiveUserInfo *> * _Nonnull members) {
                    if (success) {
                        success(members, @{}, nil);
                    }
                } error:errorCallback];
                V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
                info.groupID = roomID;
                info.faceURL = roomParam.coverUrl;
                info.groupName = roomParam.roomName;
                [[V2TIMManager sharedInstance] setGroupInfo:info succ:nil fail:nil];
            } fail:^(int code, NSString *desc) {
                if (errorCallback) {
                    errorCallback(code, desc ?: @"joinGroup failed.");
                }
            }];
        } else {
            if (errorCallback) {
                errorCallback(code, desc ?: @"joinGroup failed.");
            }
        }
    }];
}

+ (void)destroyRoomWithRoomID:(NSString *)roomID callback:(LRIMCallback)callback {
    [[V2TIMManager sharedInstance] dismissGroup:roomID succ:^{
        if (callback) {
            callback(0, @"success");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc ?: @"");
        }
    }];
}

+ (void)enterRoomWithRoomID:(NSString *)roomID success:(LREnterRoomCallback)success error:(LRIMCallback)errorCallback {
    [[V2TIMManager sharedInstance] joinGroup:roomID msg:@"" succ:^{
        [TRTCLiveRoomIMAction getAllMembersWithRoomID:roomID success:^(NSArray<TRTCLiveUserInfo *> * _Nonnull members) {
            [[V2TIMManager sharedInstance] getGroupsInfo:@[roomID] succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
                if (!groupResultList || groupResultList.count == 0) {
                    TRTCLog(@"failed to query group info");
                    return;
                }
                V2TIMGroupInfoResult *infoResult = groupResultList[0];
                V2TIMGroupInfo* info = infoResult.info;
                NSDictionary *customInfo = [info.introduction mj_JSONObject];
                if (info && customInfo) {
                    TRTCLiveRoomInfo* roomInfo = nil;
                    NSArray *userDic = customInfo[@"list"];
                    NSDictionary *owner = userDic.count > 0 ? userDic[0] : nil;
                    NSNumber *type = customInfo[@"type"] ?: @(1);
                    if (owner) {
                        roomInfo = [[TRTCLiveRoomInfo alloc] initWithRoomId:roomID
                                                                   roomName:@""
                                                                   coverUrl:@""
                                                                    ownerId:owner[@"userId"] ?: @""
                                                                  ownerName:owner[@"name"] ?: @""
                                                                   streamUrl:owner[@"streamId"]
                                                                memberCount:0
                                                                 roomStatus:[type intValue]];
                    }
                    [TRTCLiveRoomIMAction getRoomInfoWithRoomIds:@[roomID] success:^(NSArray<TRTCLiveRoomInfo *> * _Nonnull roomInfos) {
                        if (roomInfos.count > 0) {
                            roomInfo.roomName = roomInfos[0].roomName ?: @"";
                            roomInfo.coverUrl = roomInfos[0].coverUrl ?: @"";
                            if (success) {
                                success(members, customInfo, roomInfo);
                            }
                        }
                    } error:^(int code, NSString * _Nonnull message) {
                        if (success) {
                            success(members, customInfo, roomInfo);
                        }
                    }];
                }
            } fail:errorCallback];
        } error:errorCallback];
    } fail:errorCallback];
}

+ (void)exitRoomWithRoomID:(NSString *)roomID callback:(LRIMCallback)callback {
    [[V2TIMManager sharedInstance] quitGroup:roomID succ:^{
        if (callback) {
            callback(0, @"");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc ?: @"quit group failed.");
        }
    }];
}

+ (void)getRoomInfoWithRoomIds:(NSArray<NSString *> *)roomIds success:(LRRoomInfosCallback)success error:(LRIMCallback)error {
    [[V2TIMManager sharedInstance] getGroupsInfo:roomIds succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
        if (!groupResultList) {
            error(-1, TRTCLocalize(@"Demo.TRTC.LiveRoom.cannotgetroominfo"));
            return;
        }
        NSMutableArray<TRTCLiveRoomInfo *> *roomInfos = [[NSMutableArray alloc] initWithCapacity:2];
        [groupResultList enumerateObjectsUsingBlock:^(V2TIMGroupInfoResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            V2TIMGroupInfo* info = obj.info;
            NSDictionary *customInfo = [info.introduction mj_JSONObject];
            if (info && customInfo) {
                TRTCLiveRoomInfo* roomInfo = nil;
                NSArray *userDic = customInfo[@"list"];
                NSDictionary *owner = userDic.count > 0 ? userDic[0] : nil;
                NSNumber *type = customInfo[@"type"] ?: @(1);
                if (owner) {
                    roomInfo = [[TRTCLiveRoomInfo alloc] initWithRoomId:info.groupID
                                                               roomName:info.groupName
                                                               coverUrl:info.faceURL
                                                                ownerId:owner[@"userId"] ?: @""
                                                              ownerName:owner[@"name"] ?: @""
                                                               streamUrl:owner[@"streamId"]
                                                            memberCount:info.memberCount
                                                             roomStatus:[type intValue]];
                }
                if (roomInfo) {
                    [roomInfos addObject:roomInfo];
                }
            }
        }];
        if (success) {
            success(roomInfos);
        }
    } fail:^(int code, NSString *desc) {
        if (error) {
            error(code, desc ?: TRTCLocalize(@"Demo.TRTC.LiveRoom.getroominfofailed"));
        }
    }];
}

+ (void)getAllMembersWithRoomID:(NSString *)roomID success:(LRMemberCallback)success error:(LRIMCallback)error {
    [[V2TIMManager sharedInstance] getGroupMemberList:roomID filter:V2TIM_GROUP_MEMBER_FILTER_ALL nextSeq:0 succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        if (success) {
            NSMutableArray *infos = [[NSMutableArray alloc] initWithCapacity:2];
            if (memberList) {
                [memberList enumerateObjectsUsingBlock:^(V2TIMGroupMemberFullInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    TRTCLiveUserInfo* user = [[TRTCLiveUserInfo alloc] initWithProfile:obj];
                    [infos addObject:user];
                }];
            }
            success(infos);
        }
    } fail:^(int code, NSString *desc) {
        if (error) {
            error(code, desc ?: @"");
        }
    }];
}

#pragma mark - Action Message
+ (void)requestJoinAnchorWithUserID:(NSString *)userID reason:(NSString *)reason callback:(LRIMCallback)callback {
    NSDictionary *data = @{
        @"action": @(TRTCLiveRoomIMActionTypeRequestJoinAnchor),
        @"reason": reason ?: @"",
        @"version": trtcLiveRoomProtocolVersion
    };
    ConversationParams *params = [[ConversationParams alloc] init];
    params.type = ConvTypeUser;
    params.userID = userID;
    [TRTCLiveRoomIMAction sendMessage:data convType:params callback:callback];
}

+ (void)respondJoinAnchorWithUserID:(NSString *)userID agreed:(BOOL)agreed reason:(NSString *)reason callback:(LRIMCallback)callback {
    NSDictionary *data = @{
        @"action": @(TRTCLiveRoomIMActionTypeRespondJoinAnchor),
        @"accept": agreed ? @(1) : @(0),
        @"reason": reason ?: @"",
        @"version": trtcLiveRoomProtocolVersion,
    };
    ConversationParams *params = [[ConversationParams alloc] init];
    params.type = ConvTypeUser;
    params.userID = userID;
    [TRTCLiveRoomIMAction sendMessage:data convType:params callback:callback];
}

+ (void)kickoutJoinAnchorWithUserID:(NSString *)userID callback:(LRIMCallback)callback {
    NSDictionary *data = @{
        @"action": @(TRTCLiveRoomIMActionTypeKickoutJoinAnchor),
        @"version": trtcLiveRoomProtocolVersion,
    };
    ConversationParams *params = [[ConversationParams alloc] init];
    params.type = ConvTypeUser;
    params.userID = userID;
    [TRTCLiveRoomIMAction sendMessage:data convType:params callback:callback];
}

+ (void)notifyStreamToAnchorWithUserId:(NSString *)userID streamID:(NSString *)streamID callback:(LRIMCallback)callback {
    NSDictionary *data = @{
        @"action": @(TRTCLiveRoomIMActionTypeNotifyJoinAnchorStream),
        @"stream_id": streamID,
        @"version": trtcLiveRoomProtocolVersion,
    };
    ConversationParams *params = [[ConversationParams alloc] init];
    params.type = ConvTypeUser;
    params.userID = userID;
    [TRTCLiveRoomIMAction sendMessage:data convType:params callback:callback];
}

+ (void)requestRoomPKWithUserID:(NSString *)userID fromRoomID:(NSString *)fromRoomID fromStreamID:(NSString *)fromStreamID callback:(LRIMCallback)callback {
    NSDictionary *data = @{
        @"action": @(TRTCLiveRoomIMActionTypeRequestRoomPK),
        @"from_room_id": fromRoomID,
        @"from_stream_id": fromStreamID,
        @"version": trtcLiveRoomProtocolVersion,
    };
    ConversationParams *params = [[ConversationParams alloc] init];
    params.type = ConvTypeUser;
    params.userID = userID;
    [TRTCLiveRoomIMAction sendMessage:data convType:params callback:callback];
}

+ (void)responseRoomPKWithUserID:(NSString *)userID agreed:(BOOL)agreed reason:(NSString *)reason streamID:(NSString *)streamID callback:(LRIMCallback)callback {
    NSDictionary *data = @{
        @"action": @(TRTCLiveRoomIMActionTypeRespondRoomPK),
        @"accept": agreed ? @1 : @0,
        @"reason": reason ?: @"",
        @"stream_id": streamID,
        @"version": trtcLiveRoomProtocolVersion,
    };
    ConversationParams *params = [[ConversationParams alloc] init];
    params.type = ConvTypeUser;
    params.userID = userID;
    [TRTCLiveRoomIMAction sendMessage:data convType:params callback:callback];
}

+ (void)quitRoomPKWithUserID:(NSString *)userID callback:(LRIMCallback)callback {
    NSDictionary *data = @{
        @"action": @(TRTCLiveRoomIMActionTypeQuitRoomPK),
        @"version": trtcLiveRoomProtocolVersion,
    };
    ConversationParams *params = [[ConversationParams alloc] init];
    params.type = ConvTypeUser;
    params.userID = userID;
    [TRTCLiveRoomIMAction sendMessage:data convType:params callback:callback];
}

+ (void)sendRoomTextMsgWithRoomID:(NSString *)roomID message:(NSString *)message callback:(LRIMCallback)callback {
    NSDictionary *data = @{
        @"action": @(TRTCLiveRoomIMActionTypeRoomTextMsg),
        @"version": trtcLiveRoomProtocolVersion,
    };
    ConversationParams *params = [[ConversationParams alloc] init];
    params.type = ConvTypeGroup;
    params.gourpID = roomID;
    params.text = message;
    params.priority = V2TIM_PRIORITY_LOW;
    [TRTCLiveRoomIMAction sendMessage:data convType:params callback:callback];
}

+ (void)sendRoomCustomMsgWithRoomID:(NSString *)roomID command:(NSString *)command message:(NSString *)message callback:(LRIMCallback)callback {
    NSDictionary *data = @{
        @"action": @(TRTCLiveRoomIMActionTypeRoomCustomMsg),
        @"command": command,
        @"message": message,
        @"version": trtcLiveRoomProtocolVersion,
    };
    ConversationParams *params = [[ConversationParams alloc] init];
    params.type = ConvTypeGroup;
    params.gourpID = roomID;
    params.text = nil;
    params.priority = V2TIM_PRIORITY_LOW;
    [TRTCLiveRoomIMAction sendMessage:data convType:params callback:callback];
}

+ (void)updateGroupInfoWithRoomID:(NSString *)roomID groupInfo:(NSDictionary<NSString *,id> *)groupInfo callback:(LRIMCallback)callback {
    NSMutableDictionary *data = [groupInfo mutableCopy];
    data[@"version"] = trtcLiveRoomProtocolVersion;
    NSString *groupInfoString = [data mj_JSONString];
    TRTCLog(@" updateGroupInfo:%@, size:%lu", groupInfoString, (unsigned long)groupInfoString.length);
    V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
    info.groupID = roomID;
    info.introduction = groupInfoString;
    [[V2TIMManager sharedInstance] setGroupInfo:info succ:^{
        data[@"action"] = @(TRTCLiveRoomIMActionTypeUpdateGroupInfo);
        ConversationParams *params = [[ConversationParams alloc] init];
           params.type = ConvTypeGroup;
           params.gourpID = roomID;
           params.text = @"";
           params.priority = V2TIM_PRIORITY_LOW;
        [TRTCLiveRoomIMAction sendMessage:data convType:params callback:callback];
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc ?: @"update group info failed.");
        }
    }];
}

#pragma mark - private method
+ (void)sendMessage:(NSDictionary<NSString *, id> *)data convType:(ConversationParams *)params callback:(LRIMCallback _Nullable)callback {
    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingFragmentsAllowed error:&error];
    if (error) {
        if (callback) {
             callback(-1, @"JSON data serialization failed.");
        }
        return;
    }
    V2TIMMessage *message = nil;
    if (params.text && params.type == ConvTypeGroup) {
        message = [[V2TIMManager sharedInstance] createTextMessage:params.text];
    } else {
        message = [[V2TIMManager sharedInstance] createCustomMessage:jsonData];
        params.priority = V2TIM_PRIORITY_NORMAL;
    }
    switch (params.type) {
        case ConvTypeGroup:
        {
            [[V2TIMManager sharedInstance] sendMessage:message
                                              receiver:nil
                                               groupID:params.gourpID
                                              priority:params.priority
                                        onlineUserOnly:NO
                                       offlinePushInfo:nil
                                              progress:nil
                                                  succ:^{
                if (callback) {
                    callback(0, @"send successfully!");
                }
            } fail:^(int code, NSString *desc) {
                if (callback) {
                    callback(0, desc ?: @"send message error.");
                }
            }];
        }
            break;
        case ConvTypeUser:
        {
            [[V2TIMManager sharedInstance] sendMessage:message
                                              receiver:params.userID
                                               groupID:nil
                                              priority:params.priority
                                        onlineUserOnly:NO
                                       offlinePushInfo:nil
                                              progress:nil
                                                  succ:^{
                if (callback) {
                    callback(0, @"send successfully!");
                }
            } fail:^(int code, NSString *desc) {
                if (callback) {
                    callback(0, desc ?: @"send message error.");
                }
            }];
        }
            break;
        default:
            break;
    }
}

@end
