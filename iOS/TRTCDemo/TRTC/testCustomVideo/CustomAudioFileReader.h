#ifndef CustomAudioFileReader_h
#define CustomAudioFileReader_h

@protocol CustomAudioFileReaderDelegate

- (void)onAudioCapturePcm:(NSData *)pcmData sampleRate:(int)sampleRate channels:(int)channels ts:(uint32_t)timestampMs;

@end

@interface CustomAudioFileReader : NSObject

@property(nonatomic, weak)id<CustomAudioFileReaderDelegate> delegate;

+ (instancetype) sharedInstance;

- (void)start:(int)sampleRate channels:(int)channels framLenInSample:(int)framLenInSample;

- (void)stop;

@end

#endif /* CustomAudioFileReader_h */
