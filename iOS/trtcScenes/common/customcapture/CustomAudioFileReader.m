#import <Foundation/Foundation.h>
#import <sys/time.h>
#import "CustomAudioFileReader.h"

#define WEAKIFY(x) __weak __typeof(x) w_##x = x;
#define STRONGIFY_OR_RET(x) __strong __typeof(w_##x) x = w_##x; if (nil == x) return;

@interface CustomAudioFileReader()

@property (atomic) BOOL isStart;

@end

@implementation CustomAudioFileReader
{
    uint32_t _sampleRate;
    uint32_t _channels;
    uint32_t _bits;
    uint32_t _framLenInSample;
    uint32_t _fileDataReadLen;
    uint32_t _dataSendTotalLen;
    uint64_t _firstReadTime;
    NSData *_fileData;
}

static CustomAudioFileReader *_instance;

+ (instancetype)sharedInstance {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _instance = [[CustomAudioFileReader alloc] initPrivate];
    });
    return _instance;
}

- (instancetype)initPrivate {
    self = [super init];
    if (nil != self) {
        _isStart = NO;
        _sampleRate = 0;
        _channels = 0;
        _bits = 16;
        _framLenInSample = 0;
        _fileDataReadLen = 0;
        _dataSendTotalLen = 0;
        _firstReadTime = 0;
    }
    return self;
}

- (void)start:(int)sampleRate channels:(int)channels framLenInSample:(int)framLenInSample {
    if (self.isStart) return;
    
    _sampleRate = sampleRate;
    _channels = channels;
    _fileDataReadLen = 0;
    _dataSendTotalLen = 0;
    _firstReadTime = 0;
    
    _framLenInSample = framLenInSample;
    int frameLenInBytes = framLenInSample*_channels*(_bits/8);
    int frameLenInMs = framLenInSample*1000/sampleRate;
    
    NSString *strFileName = [NSString stringWithFormat:@"CustomAudio%d_%d",_sampleRate,_channels];
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:strFileName ofType:@"pcm"];
    if (!resourcePath) {
        NSLog(@"文件打开失败，可能是没有对应格式的pcm文件，文件名[%@]！！",strFileName);
        return;
    }
    _fileData = [NSData dataWithContentsOfFile:resourcePath];
    
    dispatch_queue_t _unitQueue = dispatch_queue_create("audio_read_queue", DISPATCH_QUEUE_SERIAL);
    
    self.isStart = YES;
    WEAKIFY(self);
    dispatch_async(_unitQueue, ^{
        STRONGIFY_OR_RET(self);
        while (self.isStart) {
            struct timeval tv;
            gettimeofday(&tv,NULL);
            uint64_t currentTime = tv.tv_sec * 1000 + tv.tv_usec / 1000;
            int sendCount = 0;
            if (!self->_firstReadTime) {
                sendCount = 1;
                self->_firstReadTime = currentTime;
            } else {
                sendCount = ((currentTime - self->_firstReadTime)*self->_sampleRate/1000.f - self->_dataSendTotalLen/self->_channels/(self->_bits/8))/framLenInSample;
            }
            for (int i=0; i<sendCount; ++i) {
                if (self.delegate) {
                    [self.delegate onAudioCapturePcm:[NSData dataWithBytes:self->_fileData.bytes+self->_fileDataReadLen length:frameLenInBytes]
                                          sampleRate:self->_sampleRate
                                            channels:self->_channels
                                                  ts:(uint32_t)(currentTime + i*frameLenInMs)];
                }
                self->_fileDataReadLen += frameLenInBytes;
                self->_dataSendTotalLen += frameLenInBytes;
                if (self->_fileDataReadLen+frameLenInBytes > self->_fileData.length) {
                    self->_fileDataReadLen = 0;
                }
            }
            usleep(1000*5);
        }
        self->_fileData = nil;
    });
}

- (void)stop {
    self.isStart = NO;
}

@end
