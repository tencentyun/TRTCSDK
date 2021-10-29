//
//  TestRenderCustomVideoData.h
//  TXLiteAVDemo
//
//  Created by rushanting on 2019/3/27.
//  Copyright © 2019 Tencent. All rights reserved.
//
//  传入的userId是nil为本地画面


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomCameraFrameRender : NSObject

- (void)start:(nullable NSString*)userId videoView:(UIImageView*)videoView;
- (void)onRenderVideoFrame:(TRTCVideoFrame *)frame userId:(NSString *)userId streamType:(TRTCVideoStreamType)streamType;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
