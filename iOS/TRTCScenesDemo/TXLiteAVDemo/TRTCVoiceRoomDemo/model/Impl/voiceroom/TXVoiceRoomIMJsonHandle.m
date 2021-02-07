//
//  TXVoiceRoomIMJsonHandle.m
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/2.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TXVoiceRoomIMJsonHandle.h"
#import <MJExtension.h>

@implementation TXVoiceRoomIMJsonHandle

+ (NSDictionary<NSString *,NSString *> *)getInitRoomDicWithRoomInfo:(TXRoomInfo *)roominfo seatInfoList:(NSArray<TXSeatInfo *> *)seatInfoList{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:2];
    [result setValue:VOICE_ROOM_KEY_ATTR_VERSION forKey:VOICE_ROOM_VALUE_ATTR_VERSION];
    NSString *jsonRoomInfo = [roominfo mj_JSONString];
    [result setValue:jsonRoomInfo forKey:VOICE_ROOM_KEY_ROOM_INFO];
    for (int index = 0; index < seatInfoList.count; index += 1) {
        NSString *jsonInfo = [seatInfoList[index] mj_JSONString];
        NSString *key = [NSString stringWithFormat:@"%@%d", VOICE_ROOM_KEY_SEAT, index];
        [result setValue:jsonInfo forKey:key];
    }
    return result;
}

+ (NSDictionary<NSString *,NSString *> *)getSeatInfoListJsonStrWithSeatInfoList:(NSArray<TXSeatInfo *> *)seatInfoList {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:2];
    [seatInfoList enumerateObjectsUsingBlock:^(TXSeatInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = [NSString stringWithFormat:@"%@%lu", VOICE_ROOM_KEY_SEAT, (unsigned long)idx];
        [result setValue:obj forKey:key];
    }];
    return result;
}

+ (NSDictionary<NSString *,NSString *> *)getSeatInfoJsonStrWithIndex:(NSInteger)index info:(TXSeatInfo *)info {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:2];
    NSString *json = [info mj_JSONString];
    NSString *key = [NSString stringWithFormat:@"%@%ld", VOICE_ROOM_KEY_SEAT, (long)index];
    [result setValue:json forKey:key];
    return result;
}

+ (TXRoomInfo *)getRoomInfoFromAttr:(NSDictionary<NSString *,NSString *> *)attr {
    NSString *jsonStr = [attr objectForKey:VOICE_ROOM_KEY_ROOM_INFO];
    return [TXRoomInfo mj_objectWithKeyValues:jsonStr];
}

+ (NSArray<TXSeatInfo *> *)getSeatListFromAttr:(NSDictionary<NSString *,NSString *> *)attr seatSize:(NSUInteger)seatSize {
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:2];
    for (int index = 0; index < seatSize; index += 1) {
        NSString *key = [NSString stringWithFormat:@"%@%d", VOICE_ROOM_KEY_SEAT, index];
        NSString *jsonStr = [attr objectForKey:key];
        if (jsonStr) {
            TXSeatInfo *seatInfo = [TXSeatInfo mj_objectWithKeyValues:jsonStr];
            [result addObject:seatInfo];
        } else {
            TXSeatInfo *seatInfo = [[TXSeatInfo alloc] init];
            [result addObject:seatInfo];
        }
    }
    return result;
}

+ (NSString *)getInvitationMsgWithRoomId:(NSString *)roomId cmd:(NSString *)cmd content:(NSString *)content {
    TXInviteData *data = [[TXInviteData alloc] init];
    data.roomId = roomId;
    data.command = cmd;
    data.message = content;
    NSString *jsonString = [data mj_JSONString];
    return jsonString;
}

+ (TXInviteData *)parseInvitationMsgWithJson:(NSString *)json {
    return [TXInviteData mj_objectWithKeyValues:json];
}

+ (NSString *)getRoomdestroyMsg {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:2];
    [result setValue:VOICE_ROOM_VALUE_ATTR_VERSION forKey:VOICE_ROOM_KEY_ATTR_VERSION];
    [result setValue:@(kVoiceRoomCodeDestroy) forKey:VOICE_ROOM_KEY_CMD_ACTION];
    return [result mj_JSONString];
}

+ (NSString *)getCusMsgJsonStrWithCmd:(NSString *)cmd msg:(NSString *)msg {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:2];
    [result setValue:VOICE_ROOM_VALUE_ATTR_VERSION forKey:VOICE_ROOM_KEY_ATTR_VERSION];
    [result setValue:@(kVoiceRoomCodeCustomMsg) forKey:VOICE_ROOM_KEY_CMD_ACTION];
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

@end
