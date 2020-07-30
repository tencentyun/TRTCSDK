//
//  TRTCVoiceRoomDef.m
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/6/30.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TRTCVoiceRoomDef.h"

@implementation VoiceRoomParam

@end

@implementation VoiceRoomSeatInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.status = 0;
        self.mute = NO;
        self.userId = @"";
    }
    return self;
}

@end

@implementation VoiceRoomUserInfo

- (void)setUserName:(NSString *)userName{
    if (!userName) {
        userName = @"";
    }
    _userName = userName;
}

- (void)setUserAvatar:(NSString *)userAvatar{
    if (!userAvatar) {
        userAvatar = @"";
    }
    _userAvatar = userAvatar;
}

@end

@implementation VoiceRoomInfo

-(instancetype)initWithRoomID:(NSInteger)roomID ownerId:(NSString *)ownerId memberCount:(NSInteger)memberCount {
    self = [super init];
    if (self) {
        self.roomID = roomID;
        self.ownerId = ownerId;
        self.memberCount = memberCount;
    }
    return self;
}

@end
