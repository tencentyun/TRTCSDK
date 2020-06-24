//
//  TRTCMeetingDef.m
//  TRTCScenesDemo
//
//  Created by xcoderliu on 4/21/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "TRTCMeetingDef.h"

@implementation TXUserInfo

- (instancetype)init {
    if (self = [super init]) {
        self.userId = @"";
        self.userName = @"";
        self.avatarURL = @"";
    }
    return self;
}

@end


@implementation TRTCMeetingUserInfo

- (instancetype)init {
    if (self = [super init]) {
        self.isVideoAvailable = NO;
        self.isAudioAvailable = NO;
        self.isMuteAudio = NO;
        self.isMuteVideo = NO;
    }
    return self;
}

@end
