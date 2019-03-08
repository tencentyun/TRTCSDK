//
//  TRTCApp.h
//  TXLiteAVMacDemo
//
//  Created by cui on 2019/3/7.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TRTCApp : NSObject
@property (copy, nonatomic) void(^onQuit)(void);
- (void)start;
- (void)stop;
- (void)awake;
- (void)showPreference;
@end

NS_ASSUME_NONNULL_END
