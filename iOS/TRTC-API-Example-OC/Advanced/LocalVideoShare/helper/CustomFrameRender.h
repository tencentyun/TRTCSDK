//
//  TestRenderCustomVideoData.h
//  TRTC-API-Example-OC
//
//  Created by rushanting on 2019/3/27.
//  Copyright © 2019 Tencent. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomFrameRender : NSObject

+ (void)renderImageBuffer:(CVImageBufferRef)imageBufer forView:(UIImageView*)imageView;
+ (void)clearImageView:(UIImageView*)imageView;

@end

NS_ASSUME_NONNULL_END
