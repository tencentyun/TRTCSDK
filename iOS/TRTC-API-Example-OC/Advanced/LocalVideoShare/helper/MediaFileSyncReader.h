//
//  MediaFileSyncReader.h
//  TRTC-API-Example-OC
//
//  Created by bluedang on 2021/4/22.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@protocol MediaFileSyncReaderDelegate <NSObject>

- (void)onReadVideoFrameAtFrameIntervals:(CVImageBufferRef)imageBuffer timeStamp:(UInt64)timeStamp;
- (void)onReadAudioFrameAtFrameIntervals:(NSData*)pcmData timeStamp:(UInt64)timeStamp;

@end

@interface MediaFileSyncReader : NSObject

@property (weak, nonatomic) id<MediaFileSyncReaderDelegate> delegate;
@property (atomic, readonly) int audioSampleRate;
@property (atomic, readonly) int audioChannels;
@property (atomic, readonly) float angle;

- (instancetype)initWithAVAsset:(AVAsset*)asset;

- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
