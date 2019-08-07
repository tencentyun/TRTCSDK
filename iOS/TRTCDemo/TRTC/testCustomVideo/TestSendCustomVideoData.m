//
//  TRTCCustomVideoTest.m
//  TXLiteAVDemo
//
//  Created by rushanting on 2019/3/26.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TestSendCustomVideoData.h"
#import "TXLiteAVSDK.h"
#import "TRTCSettingViewController.h"

@interface TestSendCustomVideoData ()
@property (nonatomic, retain) TRTCCloud* trtcCloud;
@property (nonatomic, retain) TCMediaFileReader* mediaReader;
@end

@implementation TestSendCustomVideoData

- (instancetype)initWithTRTCCloud:(TRTCCloud *)cloud mediaAsset:(AVAsset *)asset
{
    if (self = [super init]) {
        _trtcCloud = cloud;
        _mediaReader = [[TCMediaFileReader alloc] initWithMediaAsset:asset videoReadFormat:VideoReadFormat_NV12];
    }
    
    return self;
}

- (void)start
{
    __weak __typeof(self) weakSelf = self;
    [weakSelf.mediaReader startVideoRead];
    [weakSelf.mediaReader readVideoFrameFromTime:0 toTime:(float)weakSelf.mediaReader.duration.value/weakSelf.mediaReader.duration.timescale fps:weakSelf.mediaReader.fps readOneFrame:^(CMSampleBufferRef sampleBuffer) {
        __typeof(self) strongSelf = weakSelf;
        TRTCVideoFrame* videoFrame = [TRTCVideoFrame new];
        videoFrame.bufferType = TRTCVideoBufferType_PixelBuffer;
        videoFrame.pixelFormat = TRTCVideoPixelFormat_NV12;
        videoFrame.pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        TRTCVideoRotation rotation = TRTCVideoRotation_0;
        if (strongSelf.mediaReader.angle == 90) {
            rotation = TRTCVideoRotation_90;
        }
        else if (strongSelf.mediaReader.angle == 180) {
            rotation = TRTCVideoRotation_180;
        }
        else if (strongSelf.mediaReader.angle == 270) {
            rotation = TRTCVideoRotation_270;
        }
        videoFrame.rotation = rotation;
        
        [strongSelf.trtcCloud sendCustomVideoData:videoFrame];
        
    } readFinished:^{
        __typeof(self) strongSelf = weakSelf;

        [strongSelf.mediaReader resetVideoReader];
        [strongSelf start];
    }];
}

- (void)stop
{
    [self.mediaReader stopVideoRead];
}

- (TCMediaFileReader*)mediaReader
{
    return _mediaReader;
}

@end
