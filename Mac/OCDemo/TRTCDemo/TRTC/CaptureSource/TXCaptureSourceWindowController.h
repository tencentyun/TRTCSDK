//
//  TXCaptureSourceViewController.h
//  TXLiteAVMacDemo
//
//  Created by shengcui on 2018/10/24.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SDKHeader.h"

NS_ASSUME_NONNULL_BEGIN
@interface TXCaptureSourceWindowController : NSWindowController

@property (weak, nonatomic) TRTCCloud *engine;
@property (copy, nonatomic) void(^onSelectSource)(TRTCScreenCaptureSourceInfo * _Nullable);
@property (nonatomic, readonly) BOOL usesBigStream;

- (instancetype)initWithTRTCCloud:(TRTCCloud *)engine;

@end

NS_ASSUME_NONNULL_END
