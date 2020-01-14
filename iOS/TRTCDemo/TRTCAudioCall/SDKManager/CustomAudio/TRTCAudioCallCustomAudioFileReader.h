#ifndef TRTCAudioCallCustomAudioFileReader_h
#define TRTCAudioCallCustomAudioFileReader_h

@protocol TRTCAudioCallCustomAudioFileReaderDelegate

- (void)onAudioCapturePcm:(NSData *)pcmData sampleRate:(int)sampleRate channels:(int)channels ts:(uint32_t)timestampMs;

@end

@interface TRTCAudioCallCustomAudioFileReader : NSObject

@property(nonatomic, weak)id<TRTCAudioCallCustomAudioFileReaderDelegate> delegate;

+ (instancetype) sharedInstance;

- (void)start:(int)sampleRate channels:(int)channels framLenInSample:(int)framLenInSample;

- (void)stop;

@end

#endif /* CustomAudioFileReader_h */
