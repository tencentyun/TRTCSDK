//
//  UserModel.m
//  TXLiteAVDemo_Professional
//
//  Created by Melody on 2019/11/28.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

- (id)initWithUid:(NSString *)uid volume:(int)volume {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.uid = uid;
    self.volume = volume;
    
    return self;
}

@end
