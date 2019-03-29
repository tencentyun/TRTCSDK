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
        
        TRTCVideoFrame* videoFrame = [TRTCVideoFrame new];
        videoFrame.bufferType = TRTCVideoBufferType_PixelBuffer;
        videoFrame.pixelFormat = TRTCVideoPixelFormat_NV12;
        videoFrame.pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        [weakSelf.trtcCloud sendCustomVideoData:videoFrame];
        
    } readFinished:^{
        [weakSelf.mediaReader resetVideoReader];
        [weakSelf start];
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
