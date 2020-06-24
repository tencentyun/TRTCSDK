//
//  IMProtocol.m
//  TRTCScenesDemo
//
//  Created by J J on 2020/5/30.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

#import "IMProtocol.h"

@implementation IMProtocol

+ (NSString *)getRoomTextMsgHeadJsonStr {
    NSMutableDictionary *dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setValue:VALUE_PROTOCOL_VERSION forKey:KEY_VERSION];
    NSNumber *codeRoomTextMsg = [NSNumber numberWithInt:CODE_ROOM_TEXT_MESSAGE];
    [dicJson setValue:codeRoomTextMsg forKey:KEY_ACTION];
    
    return [IMProtocol convertToJsonData:dicJson];
}

+ (NSString *)getCusMsgJsonStr:(NSString *)cmd msg:(NSString *)msg {
    NSMutableDictionary *dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setValue:VALUE_PROTOCOL_VERSION forKey:KEY_VERSION];
    [dicJson setValue:[NSNumber numberWithInt:CODE_ROOM_CUSTOM_MESSAGE] forKey:KEY_ACTION];
    [dicJson setValue:cmd forKey:@"command"];
    [dicJson setValue:msg forKey:@"message"];
    
    return [IMProtocol convertToJsonData:dicJson];
}

+ (TXMeetingPair *)parseCusMsg:(NSDictionary *)jsonObject {
    NSString *cmd = [jsonObject valueForKey:@"command"];
    NSString *message = [jsonObject valueForKey:@"message"];
    TXMeetingPair *pair = [[TXMeetingPair alloc] init];
    pair.first = cmd;
    pair.second = message;
    return pair;
}

+ (NSString *)convertToJsonData:(NSDictionary *)dict {
    NSError *error = NULL;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@", error);
        return @"";
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
