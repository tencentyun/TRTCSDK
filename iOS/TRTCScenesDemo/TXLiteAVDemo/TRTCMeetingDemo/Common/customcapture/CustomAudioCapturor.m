#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <mach/mach_time.h>
#import <sys/time.h>
#import "CustomAudioCapturor.h"

static const int kNumberBuffers = 3;
typedef struct _AQRecorderState {
    AudioStreamBasicDescription  mDataFormat;
    AudioQueueRef                mQueue;
    AudioQueueBufferRef          mBuffers[kNumberBuffers];
    AudioFileID                  mAudioFile;
    UInt32                       bufferByteSize;
    SInt64                       mCurrentPacket;
    bool                         mIsRunning;
}AQRecorderState;

static UInt64 convertMachTime(UInt64 machTime){
    static mach_timebase_info_data_t timeBaseInfo = {0};
    kern_return_t rst = mach_timebase_info(&timeBaseInfo);
    if (rst != KERN_SUCCESS || timeBaseInfo.denom == 0) {
        struct timeval tv;
        gettimeofday(&tv,NULL);
        return tv.tv_sec * 1000 + tv.tv_usec / 1000;
    } else {
        double time2nsFactor = (double) timeBaseInfo.numer / timeBaseInfo.denom;
        return (machTime * time2nsFactor)/ NSEC_PER_MSEC;
    }
}

@interface CustomAudioCapturor ()

- (void)sendPcmData:(unsigned char *)pcmData len:(int)pcmDataLen ts:(uint32_t)timestampMs;

@end

static void HandleInputBuffer (
                               void                                 *aqData,
                               AudioQueueRef                        inAQ,
                               AudioQueueBufferRef                  inBuffer,
                               const AudioTimeStamp                 *inStartTime,
                               UInt32                               inNumPackets,
                               const AudioStreamPacketDescription   *inPacketDesc
                               ) {
    AQRecorderState *pAqData = (AQRecorderState *) aqData;               // 1
    
    if (inNumPackets == 0 &&                                             // 2
        pAqData->mDataFormat.mBytesPerPacket != 0)
        inNumPackets =
        inBuffer->mAudioDataByteSize / pAqData->mDataFormat.mBytesPerPacket;
    
    [[CustomAudioCapturor sharedInstance] sendPcmData:inBuffer->mAudioData len:inBuffer->mAudioDataByteSize ts:(uint32_t)convertMachTime(inStartTime->mHostTime)];
    
    pAqData->mCurrentPacket += inNumPackets;                     // 4
    
    if (pAqData->mIsRunning == 0)                                         // 5
        return;
    
    AudioQueueEnqueueBuffer (                                            // 6
                             pAqData->mQueue,
                             inBuffer,
                             0,
                             NULL
                             );
}

static void DeriveBufferSize (
                              AudioQueueRef                audioQueue,                  // 1
                              AudioStreamBasicDescription  *asbDescription,             // 2
                              Float64                      seconds,                     // 3
                              UInt32                       *outBufferSize               // 4
) {
    static const int maxBufferSize = 0x50000;                 // 5
    
    int maxPacketSize = asbDescription->mBytesPerPacket;       // 6
    if (maxPacketSize == 0) {                                 // 7
        UInt32 maxVBRPacketSize = sizeof(maxPacketSize);
        AudioQueueGetProperty (
                               audioQueue,
                               kAudioQueueProperty_MaximumOutputPacketSize,
                               // in Mac OS X v10.5, instead use
                               //   kAudioConverterPropertyMaximumOutputPacketSize
                               &maxPacketSize,
                               &maxVBRPacketSize
                               );
    }
    
    Float64 numBytesForTime =
    asbDescription->mSampleRate * maxPacketSize * seconds; // 8
    *outBufferSize =
    (UInt32) (numBytesForTime < maxBufferSize ?
            numBytesForTime : maxBufferSize);                     // 9
}

@implementation CustomAudioCapturor
{
    AQRecorderState aqData;
    
    unsigned char *_sendBuf;
    int _sendBufLen;
    
    int _sampleLen;
}

static CustomAudioCapturor *_instance;

+ (instancetype)sharedInstance {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _instance = [[CustomAudioCapturor alloc] initPrivate];
    });
    return _instance;
}

- (instancetype)initPrivate {
    self = [super init];
    if (nil != self) {
        //do init
    }
    return self;
}

- (void)start:(int)sampleRate nChannels:(int)channels nSampleLen:(int)sampleLen {
    aqData.mDataFormat.mFormatID         = kAudioFormatLinearPCM; // 2
    aqData.mDataFormat.mSampleRate       = sampleRate;            // 3
    aqData.mDataFormat.mChannelsPerFrame = channels;              // 4
    aqData.mDataFormat.mBitsPerChannel   = 16;                    // 5
    aqData.mDataFormat.mBytesPerPacket   =                        // 6
    aqData.mDataFormat.mBytesPerFrame =
    aqData.mDataFormat.mChannelsPerFrame * sizeof (SInt16);
    aqData.mDataFormat.mFramesPerPacket  = 1;                     // 7
    aqData.mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    
    _sendBuf = malloc(sampleLen);
    _sendBufLen = 0;
    
    _sampleLen = sampleLen;
    
    [self setAudioSession];
    
    AudioQueueNewInput (                              // 1
                        &aqData.mDataFormat,                          // 2
                        HandleInputBuffer,                            // 3
                        &aqData,                                      // 4
                        NULL,                                         // 5
                        kCFRunLoopCommonModes,                        // 6
                        0,                                            // 7
                        &aqData.mQueue                                // 8
                        );
    
    UInt32 dataFormatSize = sizeof (aqData.mDataFormat);       // 1
    
    AudioQueueGetProperty (                                    // 2
                           aqData.mQueue,                                         // 3
                           kAudioQueueProperty_StreamDescription,                 // 4
                           // in Mac OS X, instead use
                           //    kAudioConverterCurrentInputStreamDescription
                           &aqData.mDataFormat,                                   // 5
                           &dataFormatSize                                        // 6
                           );
    
    DeriveBufferSize (                               // 1
                      aqData.mQueue,                               // 2
                      &aqData.mDataFormat,                          // 3
                      0.03,                                         // 4
                      &aqData.bufferByteSize                       // 5
                      );
    
    for (int i = 0; i < kNumberBuffers; ++i) {           // 1
        AudioQueueAllocateBuffer (                       // 2
                                  aqData.mQueue,                               // 3
                                  aqData.bufferByteSize,                       // 4
                                  &aqData.mBuffers[i]                          // 5
                                  );
        
        AudioQueueEnqueueBuffer (                        // 6
                                 aqData.mQueue,                               // 7
                                 aqData.mBuffers[i],                          // 8
                                 0,                                           // 9
                                 NULL                                         // 10
                                 );
    }
    
    aqData.mCurrentPacket = 0;                           // 1
    aqData.mIsRunning = true;                            // 2
    
    AudioQueueStart (                                    // 3
                     aqData.mQueue,                                   // 4
                     NULL                                             // 5
                     );
}

- (void)stop {
    // Wait, on user interface thread, until user stops the recording
    AudioQueueStop (                                     // 6
                    aqData.mQueue,                                   // 7
                    true                                             // 8
                    );
    
    aqData.mIsRunning = false;                           // 9
    
    AudioQueueDispose (                                 // 1
                       aqData.mQueue,                                  // 2
                       true                                            // 3
                       );
    
    free(_sendBuf);
    _sendBuf = NULL;
}

- (void) setAudioSession {
    NSError *error;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    [session setActive:YES error:&error]; // should not invoke every time
    if (nil != error) {
        NSLog(@"AudioSession setActive error:%@", error.localizedDescription);
        return;
    }
    
    error = nil;
    NSString *category;
    category = AVAudioSessionCategoryPlayAndRecord;
    [[AVAudioSession sharedInstance] setCategory:category error:&error];
    if (nil != error) {
        NSLog(@"AudioSession setCategory(AVAudioSessionCategoryPlayAndRecord) error:%@", error.localizedDescription);
        return;
    } else {
        NSLog(@"set category to %@", category);
    }
}

- (void)sendPcmData:(unsigned char *)pcmData len:(int)pcmDataLen ts:(uint32_t)timestampMs {
    NSLog(@"realing test");
    
    unsigned char *orgData = pcmData;
    int orgDataLen = pcmDataLen;
    while (orgDataLen) {
        if (_sendBufLen + orgDataLen < _sampleLen) {
            memcpy(_sendBuf+_sendBufLen, orgData, orgDataLen);
            _sendBufLen += orgDataLen;
            orgDataLen = 0;
        } else {
            int cpyLen = _sampleLen-_sendBufLen;
            memcpy(_sendBuf+_sendBufLen, orgData, cpyLen);
            orgData += cpyLen;
            orgDataLen -= cpyLen;
            _sendBufLen += cpyLen;
            
            if (self.delegate) {
                [self.delegate onAudioCapturePcm:[NSData dataWithBytes:_sendBuf length:_sendBufLen]
                                      sampleRate:aqData.mDataFormat.mSampleRate
                                        channels:aqData.mDataFormat.mChannelsPerFrame
                                              ts:timestampMs];
                _sendBufLen = 0;
            }
        }
    }
}

@end
