/*
* Module:   TRTCAudioRecordManager
*
* Function: TRTC SDK的录音功能调用
*
*    1. 音频的文件名生成方式定义在generateFilePath中，app可更改生成方式和保存的目录
*
*/

#import "TRTCAudioRecordManager.h"

@interface TRTCAudioRecordManager()

@property (nonatomic) BOOL isRecording;
@property (strong, nonatomic, nullable) NSString *audioFilePath;
@property (strong, nonatomic) TRTCCloud *trtc;

@end


@implementation TRTCAudioRecordManager

- (instancetype)initWithTrtc:(TRTCCloud *)trtc {
    if (self = [super init]) {
        _trtc = trtc;
    }
    return self;
}

- (void)startRecord {
    self.audioFilePath = [self generateFilePath];

    TRTCAudioRecordingParams* params = [[TRTCAudioRecordingParams alloc] init];
    params.filePath = self.audioFilePath;
    self.isRecording = YES;
    [self.trtc startAudioRecording:params];
}

- (void)stopRecord {
    self.isRecording = NO;
    [self.trtc stopAudioRecording];
}

- (NSString *)generateFilePath {
    NSString *name = [NSString stringWithFormat:@"%.0f.aac", [[NSDate date] timeIntervalSince1970] * 1000];
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject
            stringByAppendingPathComponent:name];
}

@end
