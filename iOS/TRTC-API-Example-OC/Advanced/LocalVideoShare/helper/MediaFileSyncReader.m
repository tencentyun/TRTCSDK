//
//  TRTCCustomVideoTest.m
//  TXLiteAVDemo
//
//  Created by rushanting on 2019/3/26.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "MediaFileSyncReader.h"

#import "MediaFileReader.h"
#include <objc/runtime.h>

@interface MediaFileSyncReader ()
@property (nonatomic, strong) MediaFileReader* mediaReader;
@end

@implementation MediaFileSyncReader

- (instancetype)initWithAVAsset:(AVAsset *)asset
{
    self = [super init];
    if (self) {
        _mediaReader = [[MediaFileReader alloc] initWithMediaAsset:asset videoReadFormat:VideoReadFormat_NV12];
        _audioSampleRate = self.mediaReader.audioSampleRate;
        _audioChannels = self.mediaReader.audioChannels;
        _angle = self.mediaReader.angle;
    }
    return self;
}

- (NSData *)createPCMData:(CMSampleBufferRef)sampleBuffer {
    const CMAudioFormatDescriptionRef formatDesc = (CMAudioFormatDescriptionRef)CMSampleBufferGetFormatDescription(sampleBuffer);
    const AudioStreamBasicDescription *asbd = NULL;
    if(formatDesc) {
        asbd = CMAudioFormatDescriptionGetStreamBasicDescription(formatDesc);
    }
    AudioBufferList audioBufferList;
    CMBlockBufferRef blockBuffer;
    OSStatus state = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, &audioBufferList, sizeof(audioBufferList), NULL, NULL, 0, &blockBuffer);

    if (state == noErr) {
        NSMutableData *audioPCMData = [[NSMutableData alloc] init];
        for ( int i =0; i < audioBufferList.mNumberBuffers; i++)
        {
            AudioBuffer audioBuffer = audioBufferList.mBuffers[i];

            [audioPCMData appendBytes:audioBuffer.mData length:audioBuffer.mDataByteSize];
        }
        if (blockBuffer != nil){
            CFRelease(blockBuffer);
        }
        return audioPCMData;
    }
    else {
        return nil;
    }
}

- (void)start {
    [self startVideo];
    [self startAudio];
}

- (void)stop {
    [self.mediaReader stopVideoRead];
    [self.mediaReader stopAudioRead];
}

- (void)startVideo {
    __weak __typeof(self) weakSelf = self;
    [weakSelf.mediaReader startVideoRead];
    [weakSelf.mediaReader readVideoFrameFromTime:0 toTime:(float)weakSelf.mediaReader.duration.value/weakSelf.mediaReader.duration.timescale fps:weakSelf.mediaReader.fps readOneFrame:^(CMSampleBufferRef sampleBuffer) {
        @autoreleasepool {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            
            CMTime time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            UInt64 timeStamp = time.value;
            
            if ([strongSelf.delegate respondsToSelector:@selector(onReadVideoFrameAtFrameIntervals:timeStamp:)]) {
                [strongSelf.delegate onReadVideoFrameAtFrameIntervals:CMSampleBufferGetImageBuffer(sampleBuffer) timeStamp:timeStamp];
            }
            
            UInt64 standDelay = 1000 / strongSelf.mediaReader.fps * 1000;
            UInt32 fixTime = 4000;
            usleep((UInt32)(standDelay - fixTime));
        }
    } readFinished:^{
        __typeof(self) strongSelf = weakSelf;

        [strongSelf.mediaReader resetVideoReader];
        [strongSelf startVideo];
    }];
}


- (void)startAudio {
    __weak __typeof(self) weakSelf = self;
    [weakSelf.mediaReader startAudioRead];
    [weakSelf.mediaReader readAudioFrameFromTime:0 toTime:(float)weakSelf.mediaReader.duration.value/weakSelf.mediaReader.duration.timescale readOneFrame:^(CMSampleBufferRef sampleBuffer) {
        @autoreleasepool {
            __typeof(self) strongSelf = weakSelf;
            size_t size = CMSampleBufferGetTotalSampleSize(sampleBuffer);
            
            NSInteger delayUs = size / strongSelf.mediaReader.audioChannels * 8.0 / 16 / strongSelf.mediaReader.audioSampleRate * 1000000;
            
            usleep((unsigned int)delayUs);
            CMTime time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            UInt64 timeStamp = time.value;
            
            if ([self.delegate respondsToSelector:@selector(onReadAudioFrameAtFrameIntervals:timeStamp:)]) {
                [strongSelf.delegate onReadAudioFrameAtFrameIntervals:[self createPCMData:sampleBuffer] timeStamp:timeStamp];
            }
        }
    } readFinished:^{
        __typeof(self) strongSelf = weakSelf;

        [strongSelf.mediaReader resetAudioReader];
        [strongSelf startAudio];
    }];
}


@end
