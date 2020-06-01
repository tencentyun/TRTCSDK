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
        self.mixMode = [[NSUserDefaults standardUserDefaults] integerForKey:@"TRTCStreamConfig.mixMode"];
    }
    return self;
}

- (void)setMixMode:(TRTCTranscodingConfigMode)mixMode {
    _mixMode = mixMode;
    [[NSUserDefaults standardUserDefaults] setInteger:mixMode forKey:@"TRTCStreamConfig.mixMode"];
}

@end
