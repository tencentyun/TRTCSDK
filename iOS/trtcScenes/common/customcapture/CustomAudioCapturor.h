#ifndef CustomAudioCapturor_h
#define CustomAudioCapturor_h

@protocol CustomAudioCapturorDelegate

- (void)onAudioCapturePcm:(NSData *)pcmData sampleRate:(int)sampleRate channels:(int)channels ts:(uint32_t)timestampMs;

@end

@interface CustomAudioCapturor : NSObject

@property(nonatomic, weak)id<CustomAudioCapturorDelegate> delegate;

+ (instancetype) sharedInstance;

- (void)start:(int)sampleRate nChannels:(int)channels nSampleLen:(int)sampleLen;

- (void)stop;

@end

#endif /* CustomAudioCapturor_h */
