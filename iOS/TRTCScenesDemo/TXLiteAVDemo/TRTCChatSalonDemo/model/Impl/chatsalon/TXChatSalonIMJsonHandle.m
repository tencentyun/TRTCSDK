//
//  TXChatSalonIMJsonHandle.m
//  TRTCChatSalonOCDemo
//
//  Created by abyyxwang on 2020/7/2.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TXChatSalonIMJsonHandle.h"
#import <MJExtension.h>

@implementation TXChatSalonIMJsonHandle

+ (NSDictionary<NSString *,NSString *> *)getInitRoomDicWithRoomInfo:(TXChatSalonRoomInfo *)roominfo seatInfoList:(NSDictionary<NSString *,TXChatSalonSeatInfo *> *)seatInfoList{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:2];
    [result setValue:VOICE_ROOM_KEY_ATTR_VERSION forKey:VOICE_ROOM_VALUE_ATTR_VERSION];
    NSString *jsonRoomInfo = [roominfo mj_JSONString];
    [result setValue:jsonRoomInfo forKey:VOICE_ROOM_KEY_ROOM_INFO];
    for (int index = 0; index < seatInfoList.allKeys.count; index += 1) {
        NSString *key = [seatInfoList.allKeys objectAtIndex:index];
        NSLog(@"======--- key: %@", key);
        NSString *jsonInfo = [seatInfoList[key] mj_JSONString];
        TXChatSalonSeatInfo *info = seatInfoList[key];
        NSString *jsonkey = [NSString stringWithFormat:@"%@%@", VOICE_ROOM_KEY_SEAT, info.user];
        [result setValue:jsonInfo forKey:jsonkey];
    }
    return result;
}

+ (NSDictionary<NSString *,NSString *> *)getSeatInfoListJsonStrWithSeatInfoList:(NSArray<TXChatSalonSeatInfo *> *)seatInfoList {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:2];
    [seatInfoList enumerateObjectsUsingBlock:^(TXChatSalonSeatInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = [NSString stringWithFormat:@"%@%@", VOICE_ROOM_KEY_SEAT, obj.user];
        [result setValue:obj forKey:key];
    }];
    return result;
}

+ (NSDictionary<NSString *,NSString *> *)getSeatInfoJsonStrWithUserID:(NSString *)userID info:(TXChatSalonSeatInfo *)info {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:2];
    NSString *json = [info mj_JSONString];
    NSString *key = [NSString stringWithFormat:@"%@%@", VOICE_ROOM_KEY_SEAT, userID];
    [result setValue:json forKey:key];
    return result;
}

+ (TXChatSalonRoomInfo *)getRoomInfoFromAttr:(NSDictionary<NSString *,NSString *> *)attr {
    NSString *jsonStr = [attr objectForKey:VOICE_ROOM_KEY_ROOM_INFO];
    return [TXChatSalonRoomInfo mj_objectWithKeyValues:jsonStr];
}

+ (NSDictionary<NSString *, TXChatSalonSeatInfo *> *)getSeatListFromAttr:(NSDictionary<NSString *,NSString *> *)attr {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:2];
    [attr enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key containsString:VOICE_ROOM_KEY_SEAT]) {
            TXChatSalonSeatInfo *seatInfo = [TXChatSalonSeatInfo mj_objectWithKeyValues:obj];
            if (![seatInfo.user isEqualToString:@""]) {
                [result setValue:seatInfo forKey:seatInfo.user];
            }
        }
    }];
    return result;
}

+ (NSString *)getInvitationMsgWithRoomId:(NSString *)roomId cmd:(NSString *)cmd content:(NSString *)content {
    TXChatSalonInviteData *data = [[TXChatSalonInviteData alloc] init];
    data.roomId = roomId;
    data.command = cmd;
    data.message = content;
    NSString *jsonString = [data mj_JSONString];
    return jsonString;
}

+ (TXChatSalonInviteData *)parseInvitationMsgWithJson:(NSString *)json {
    return [TXChatSalonInviteData mj_objectWithKeyValues:json];
}

+ (NSString *)getRoomdestroyMsg {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:2];
    [result setValue:VOICE_ROOM_VALUE_ATTR_VERSION forKey:VOICE_ROOM_KEY_ATTR_VERSION];
    [result setValue:@(kChatSalonCodeDestroy) forKey:VOICE_ROOM_KEY_CMD_ACTION];
    return [result mj_JSONString];
}

+ (NSString *)getCusMsgJsonStrWithCmd:(NSString *)cmd msg:(NSString *)msg {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:2];
    [result setValue:VOICE_ROOM_VALUE_ATTR_VERSION forKey:VOICE_ROOM_KEY_ATTR_VERSION];
    [result setValue:@(kChatSalonCodeCustomMsg) forKey:VOICE_ROOM_KEY_CMD_ACTION];
    [result setValue:cmd forKey:VOICE_ROOM_KEY_INVITATION_CMD];
    [result setValue:msg forKey:@"message"];
    return [result mj_JSONString];
}

+ (NSDictionary<NSString *,NSString *> *)parseCusMsgWithJsonDic:(NSDictionary *)jsonDic {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:2];
    result[@"cmd"] = [jsonDic objectForKey:VOICE_ROOM_KEY_INVITATION_CMD] ?: @"";
    result[@"message"] = [jsonDic objectForKey:@"message"] ?: @"";
    return result;
}

+ (NSString *)getKickMsgJsonStrWithUserID:(NSString *)userID {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setValue:VOICE_ROOM_VALUE_ATTR_VERSION forKey:VOICE_ROOM_KEY_ATTR_VERSION];
    [result setValue:@(kChatSalonCodeKickSeatMsg) forKey:VOICE_ROOM_KEY_CMD_ACTION];
    [result setValue:userID forKey:VOICE_ROOM_KEY_USER_ID];
    
    return [result mj_JSONString];
}

+ (NSString *)getPickMsgJsonStrWithUserID:(NSString *)userID {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setValue:VOICE_ROOM_VALUE_ATTR_VERSION forKey:VOICE_ROOM_KEY_ATTR_VERSION];
    [result setValue:@(kChatSalonCodePickSeatMsg) forKey:VOICE_ROOM_KEY_CMD_ACTION];
    [result setValue:userID forKey:VOICE_ROOM_KEY_USER_ID];
    
    return [result mj_JSONString];
}

@end
