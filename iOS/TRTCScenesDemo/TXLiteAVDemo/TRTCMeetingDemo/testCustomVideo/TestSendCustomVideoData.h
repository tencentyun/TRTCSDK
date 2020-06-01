//
//  TRTCCustomVideoTest.h
//  TXLiteAVDemo
//
//  Created by rushanting on 2019/3/26.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "TCMediaFileReader.h"

@class TRTCCloud;

NS_ASSUME_NONNULL_BEGIN

@interface TestSendCustomVideoData : NSObject

@property (nonatomic, readonly) TCMediaFileReader* mediaReader;

+ (instancetype)new __attribute__((unavailable("user initWithTRTCCloud:mediaAsset instead")));
- (instancetype)init __attribute__((unavailable("user initWithTRTCCloud:mediaAsset instead")));

- (instancetype)initWithTRTCCloud:(TRTCCloud*)cloud mediaAsset:(AVAsset*)asset;

- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
