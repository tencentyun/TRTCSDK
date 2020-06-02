//
//  TestRenderCustomVideoData.m
//  TXLiteAVDemo
//
//  Created by rushanting on 2019/3/27.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TestRenderVideoFrame.h"

@interface TestRenderVideoFrame ()
@property (nonatomic, retain) UIImageView* localVideoView;
@property (nonatomic, retain) NSMutableDictionary* userVideoViews;
@end

@implementation TestRenderVideoFrame

- (instancetype)init
{
    if (self = [super init]) {
        _userVideoViews = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)addUser:(NSString *)userId videoView:(UIImageView *)videoView
{
    //userId是nil为自己
    if (!userId) {
        _localVideoView = videoView;
    }
    else {
        [_userVideoViews setObject:videoView forKey:userId];
    }
}


- (void)onRenderVideoFrame:(TRTCVideoFrame *)frame userId:(NSString *)userId streamType:(TRTCVideoStreamType)streamType
{
    //userId是nil时为本地画面，否则为远端画面
    CFRetain(frame.pixelBuffer);
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        TestRenderVideoFrame* strongSelf = weakSelf;
        UIImageView* videoView = nil;
        if (userId) {
            videoView = [strongSelf.userVideoViews objectForKey:userId];
        }
        else {
            videoView = strongSelf.localVideoView;
        }
        videoView.image = [UIImage imageWithCIImage:[CIImage imageWithCVImageBuffer:frame.pixelBuffer]];
        videoView.contentMode = UIViewContentModeScaleAspectFit;
        CFRelease(frame.pixelBuffer);
    });
}

@end
