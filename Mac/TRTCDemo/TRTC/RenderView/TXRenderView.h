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

@class TRTCUserManager;

@interface TXRenderView : NSView

@property (nonatomic, copy) NSString *userId;
@property (nonatomic) BOOL isMe;
@property (nonatomic, weak) TRTCUserManager *userManager;

@property (nonatomic, weak, readonly) NSView *contentView;

+ (instancetype)renderViewWithUserId:(NSString *)userId isMe:(BOOL)isMe;

- (void)setVolumeHidden:(BOOL)volumeHidden;
- (void)setVolume:(double)volume;
- (void)setSignal:(TRTCQuality)quality;
- (void)setPlaysSmallStream:(BOOL)playsSmallStream;

- (void)setVideoOn:(BOOL)isVideoOn;
- (void)setAudioOn:(BOOL)isAudioOn;
- (void)setVideoMuted:(BOOL)isMuted;
- (void)setAudioMuted:(BOOL)isMuted;

@end

NS_ASSUME_NONNULL_END
