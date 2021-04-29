//
//  AudioQueuePlay.m
//  TRTC-API-Example-OC
//
//  Created by dangjiahe on 2021/4/24.
//

#import "AudioQueuePlay.h"
#import <AVFoundation/AVFoundation.h>

#define MIN_SIZE_PER_FRAME 5000
#define QUEUE_BUFFER_SIZE 10

@interface AudioQueuePlay() {
    AudioQueueRef _audioQueue;
    AudioStreamBasicDescription _audioDescription;
    AudioQueueBufferRef _audioQueueBuffers[QUEUE_BUFFER_SIZE];
    BOOL _audioQueueBufferUsed[QUEUE_BUFFER_SIZE];
    NSMutableData *_tempData;
    OSStatus _osState;
    BOOL _running;
}
@end

@implementation AudioQueuePlay

- (instancetype)init {
    self = [super init];
    if (self) {
        _running = false;
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error: nil];

        if (_audioDescription.mSampleRate <= 0) {
            _audioDescription.mSampleRate = 48000;
            _audioDescription.mFormatID = kAudioFormatLinearPCM;
            _audioDescription.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
            _audioDescription.mChannelsPerFrame = 1;
            _audioDescription.mFramesPerPacket = 1;
            _audioDescription.mBitsPerChannel = 16;
            _audioDescription.mBytesPerFrame = (_audioDescription.mBitsPerChannel / 8) * _audioDescription.mChannelsPerFrame;
            _audioDescription.mBytesPerPacket = _audioDescription.mBytesPerFrame * _audioDescription.mFramesPerPacket;
        }
        
        AudioQueueNewOutput(&_audioDescription, AudioPlayerAQInputCallback, (__bridge void * _Nullable)(self), nil, nil, 0, &_audioQueue);
        AudioQueueSetParameter(_audioQueue, kAudioQueueParam_Volume, 1.0);
        
        for (int i = 0; i < QUEUE_BUFFER_SIZE; i++) {
            _audioQueueBufferUsed[i] = false;
            
            _osState = AudioQueueAllocateBuffer(_audioQueue, MIN_SIZE_PER_FRAME, &_audioQueueBuffers[i]);
            
            printf("第 %d 个AudioQueueAllocateBuffer 初始化结果 %d (0表示成功)", i + 1, _osState);
        }
    }
    return self;
}

- (void)resetBufferUsed {
    for (int i = 0; i < QUEUE_BUFFER_SIZE; i++) {
        _audioQueueBufferUsed[i] = false;
    }
}

- (void)start {
    _running = true;

    [self resetBufferUsed];
    
    _osState = AudioQueueStart(_audioQueue, NULL);
    
    if (_osState != noErr) {
        printf("AudioQueueStart Error");
    }
}

- (void)stop {
    _running = false;

    _osState = AudioQueueStop(_audioQueue, true);
    
    if (_osState != noErr) {
        printf("AudioQueueStop Error");
    }
    [self resetBufferUsed];
}

- (void)resetPlay {
    if (_audioQueue != nil) {
        AudioQueueReset(_audioQueue);
    }
}

BOOL audioQueueUsed[QUEUE_BUFFER_SIZE];

-(void)playWithData:(NSData *)data {
    
    int i = 0;
    while (true) {
        if (!_audioQueueBufferUsed[i]) {
            _audioQueueBufferUsed[i] = true;
            break;
        }else {
            if (!_running) {
                return;
            }
            i++;
            if (i >= QUEUE_BUFFER_SIZE) {
                i = 0;
            }
        }
    }

    _audioQueueBuffers[i] -> mAudioDataByteSize =  (unsigned int)data.length;

    memcpy(_audioQueueBuffers[i] -> mAudioData, data.bytes, data.length);

    AudioQueueEnqueueBuffer(_audioQueue, _audioQueueBuffers[i], 0, NULL);
}

static void AudioPlayerAQInputCallback(void* inUserData, AudioQueueRef audioQueueRef, AudioQueueBufferRef audioQueueBufferRef) {
    
    AudioQueuePlay* player = (__bridge AudioQueuePlay*)inUserData;
    
    [player resetBufferState:audioQueueRef and:audioQueueBufferRef];
}

- (void)resetBufferState:(AudioQueueRef)audioQueueRef and:(AudioQueueBufferRef)audioQueueBufferRef {
    
    
    for (int i = 0; i < QUEUE_BUFFER_SIZE; i++) {
        if (audioQueueBufferRef == _audioQueueBuffers[i]) {
            _audioQueueBufferUsed[i] = false;
        }
    }
    
    for (int i = 0; i < QUEUE_BUFFER_SIZE; i++) {
        if (_audioQueueBufferUsed[i]) {
            return;
        }
    }
    
    _audioQueueBufferUsed[0] = true;
    memset(_audioQueueBuffers[0]->mAudioData, 0, _audioQueueBuffers[0]->mAudioDataByteSize);
    AudioQueueEnqueueBuffer(_audioQueue, _audioQueueBuffers[0], 0, NULL);
}

- (void)dealloc {
    if (_audioQueue != nil) {
        AudioQueueStop(_audioQueue, true);
    }
    
    _audioQueue = nil;
}


@end
