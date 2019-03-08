//
//  TXRenderView.h
//  TXLiteAVMacDemo
//
//  Created by cui on 2018/12/3.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface TXRenderView : NSView
@property (readonly, nonatomic) NSView *contentView;
@property (nonatomic, assign) BOOL volumeHidden;
- (void)addTextToolbarItem:(NSString *)title target:(id)target action:(SEL)action context:(id)context;
- (void)addImageToolbarItem:(NSImage *)image target:(id)target action:(SEL)action context:(id)context;
- (void)addToggleImageToolbarItem:(NSArray<NSImage *> *)images target:(id)target action:(SEL)action context:(id)context;

- (void)removeToolbarWithTitle:(NSString *)title;

- (void)setVolume:(float)volume;
- (void)setSignal:(TRTCQuality)quality;

@end

NS_ASSUME_NONNULL_END
