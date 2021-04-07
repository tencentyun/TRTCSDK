//
//  TRTCChatSalonDef.m
//  TRTCChatSalonOCDemo
//
//  Created by abyyxwang on 2020/6/30.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TRTCChatSalonDef.h"

@implementation ChatSalonParam

@end

@implementation ChatSalonSeatInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mute = YES;
        self.userID = @"";
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"SeatInfo user: %@", self.userID];
}

@end

@implementation ChatSalonUserInfo

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

@implementation ChatSalonInfo

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
