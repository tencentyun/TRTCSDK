//
//  TXChatSalonBaseDef.m
//  TRTCChatSalonOCDemo
//
//  Created by abyyxwang on 2020/6/30.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TXChatSalonBaseDef.h"

@implementation TXChatSalonRoomInfo

@end

@implementation TXChatSalonUserInfo


@end

@implementation TXChatSalonSeatInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mute = NO;
        self.user = @"";
    }
    return self;
}

@end

@implementation TXChatSalonInviteData


@end

@implementation TXChatSalonSendInviteInfo



@end
