//
//  TestRenderCustomVideoData.h
//  TXLiteAVDemo
//
//  Created by rushanting on 2019/3/27.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXLiteAVSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestRenderVideoFrame : NSObject<TRTCVideoRenderDelegate>

//传入的userId是nil为本地画面
- (void)addUser:(nullable NSString*)userId videoView:(UIImageView*)videoView;
@end

NS_ASSUME_NONNULL_END
