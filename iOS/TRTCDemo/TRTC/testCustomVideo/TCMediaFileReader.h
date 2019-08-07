//
//  AVReader.h
//  TXXiaoshipin
//
//  Created by taopu-iMac on 16/12/1.
//  Copyright © 2016年 qqcloud. All rights reserved.
//

#ifndef AVReader_h
#define AVReader_h

#import <CoreMedia/CoreMedia.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^readOneFrame)(CMSampleBufferRef sampleBuffer);
typedef void(^readFinished)();

typedef NS_ENUM(NSInteger,VideoCutType)
{
    VideoCutType_None,
    VideoCutType_Pieces,
    VideoCutType_Duration,
};

typedef NS_ENUM(NSInteger,VideoReadFormat)
{
    VideoReadFormat_NV12,
    VideoReadFormat_BGRA,
};

@interface TCMediaFileReader : NSObject

@property (atomic, readonly) CMTime  duration;

@property (atomic, readonly) int  bitrate;

@property (atomic, readonly) float  fps;

@property (atomic, readonly) int  width;

@property (atomic, readonly) int  height;

@property (atomic, readonly) float angle;

@property (atomic, readonly) int   audioSampleRate;

@property (atomic, readonly) int   audioChannels;

@property (atomic, readonly) int   audioBytesPerFrame;

@property (atomic, readonly) long long  totalSampleDataLength;

@property (atomic, readonly) BOOL  hasAudioData;

@property (atomic, readonly) VideoCutType  videoCutType;

@property (atomic, readonly) BOOL videoCanRead;

@property (atomic, readonly) BOOL audioCanRead;

- (instancetype) initWithMediaAsset:(NSObject *)pathAsset videoReadFormat:(VideoReadFormat)videoReadFormat;

- (void) readVideoFrameFromTime:(float)startTime
                         toTime:(float)endTime
                            fps:(int)fps
                   readOneFrame:(readOneFrame)readOneFrame
                   readFinished:(readFinished)readFinished;


- (void) readAudioFrameFromTime:(float)startTime
                         toTime:(float)endTime
                   readOneFrame:(readOneFrame)readOneFrame
                   readFinished:(readFinished)readFinished;

- (void) startVideoRead;

- (void) stopVideoRead;

- (void) startAudioRead;

- (void) stopAudioRead;

- (void) resetVideoReader;

- (void) resetAudioReader;

@end

#endif /* AVReader_h */
