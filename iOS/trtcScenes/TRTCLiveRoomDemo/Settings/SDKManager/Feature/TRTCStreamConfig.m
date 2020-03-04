//
//  TRTCStreamConfig.m
//  TXLiteAVDemo
//
//  Created by LiuXiaoya on 2019/12/9.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TRTCStreamConfig.h"

@implementation TRTCStreamConfig

- (instancetype)init {
    if (self = [super init]) {
        self.isMixingInCloud = [[NSUserDefaults standardUserDefaults] boolForKey:@"TRTCStreamConfig.isMixingInCloud"];
    }
    return self;
}

- (void)setIsMixingInCloud:(BOOL)isMixingInCloud {
    _isMixingInCloud = isMixingInCloud;
    [[NSUserDefaults standardUserDefaults] setBool:isMixingInCloud
                                            forKey:@"TRTCStreamConfig.isMixingInCloud"];
}

@end
