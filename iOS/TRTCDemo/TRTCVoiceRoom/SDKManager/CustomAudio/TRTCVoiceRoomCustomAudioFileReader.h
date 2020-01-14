#ifndef TRTCVoiceRoomCustomAudioFileReader_h
#define TRTCVoiceRoomCustomAudioFileReader_h

@protocol TRTCVoiceRoomCustomAudioFileReaderDelegate

- (void)onAudioCapturePcm:(NSData *)pcmData sampleRate:(int)sampleRate channels:(int)channels ts:(uint32_t)timestampMs;

@end

@interface TRTCVoiceRoomCustomAudioFileReader : NSObject

@property(nonatomic, weak)id<TRTCVoiceRoomCustomAudioFileReaderDelegate> delegate;

+ (instancetype) sharedInstance;

- (void)start:(int)sampleRate channels:(int)channels framLenInSample:(int)framLenInSample;

- (void)stop;

@end

#endif /* CustomAudioFileReader_h */
