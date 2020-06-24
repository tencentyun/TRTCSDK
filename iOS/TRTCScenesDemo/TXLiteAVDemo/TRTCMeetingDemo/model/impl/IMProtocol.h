//
//  IMProtocol.h
//  TRTCScenesDemo
//
//  Created by J J on 2020/5/30.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXMeetingPair.h"

#define KEY_VERSION                    @"version"
#define KEY_ACTION                     @"action"
#define VALUE_PROTOCOL_VERSION         @"1.0.0"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CODE_MESSAGE_STATE) {
    CODE_UNKNOWN                     = 0,
    CODE_ROOM_TEXT_MESSAGE           = 300,
    CODE_ROOM_CUSTOM_MESSAGE         = 301,
};

@interface IMProtocol : NSObject

+ (NSString *)getRoomTextMsgHeadJsonStr;

+ (NSString *)getCusMsgJsonStr:(NSString *)cmd msg:(NSString *)msg;

+ (TXMeetingPair *)parseCusMsg:(NSDictionary *)jsonObject;


@end

NS_ASSUME_NONNULL_END
