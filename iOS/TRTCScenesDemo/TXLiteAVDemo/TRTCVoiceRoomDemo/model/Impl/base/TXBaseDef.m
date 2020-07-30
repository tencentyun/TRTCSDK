//
//  TXBaseDef.m
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/6/30.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TXBaseDef.h"

@implementation TXRoomInfo

@end

@implementation TXVoiceRoomUserInfo


@end

@implementation TXSeatInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.status = 0;
        self.mute = NO;
        self.user = @"";
    }
    return self;
}

@end

@implementation TXInviteData


@end
