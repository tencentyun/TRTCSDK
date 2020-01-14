/*
* Module:    TRTCAudioCallAudioConfig
*
* Function: 保存音频的设置项
*
*    1. 在init中，会检查UserDefauls是否有历史记录，如存在则用历史记录初始化对象
*
*    2. 在dealloc中，将对象当前的值保存进UserDefaults中
*
*/

#import "TRTCAudioCallAudioConfig.h"

@implementation  TRTCAudioCallAudioConfig

- (instancetype)init {
    if (self = [super init]) {
        self.isEnabled = YES;
        self.isSilent = NO;
        self.isMuteLocalAudio = NO;
        self.isCustomCapture = NO;
        [self loadFromLocal];
    }
    return self;
}

- (void)dealloc {
    [self saveToLocal];
}

- (void)loadFromLocal {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"TRTCAudioConfig"];
    if (!dict) {
        return;
    }
    self.route = [dict[@"route"] intValue];
    self.volumeType = [dict[@"volumeType"] integerValue];
    self.isEarMonitoringEnabled = [dict[@"isEarMonitoringEnabled"] boolValue];
    self.isAgcEnabled = [dict[@"isAgcEnabled"] boolValue];
    self.isAnsEnabled = [dict[@"isAnsEnabled"] boolValue];
    self.sampleRate = [dict[@"sampleRate"] integerValue];
    self.isVolumeEvaluationEnabled = [dict[@"isVolumeEvaluationEnabled"] boolValue];
}

- (void)saveToLocal {
    NSDictionary *dict = @{
        @"route" : @(self.route),
        @"volumeType" : @(self.volumeType),
        @"isEarMonitoringEnabled" : @(self.isEarMonitoringEnabled),
        @"isAgcEnabled" : @(self.isAgcEnabled),
        @"isAnsEnabled" : @(self.isAnsEnabled),
        @"sampleRate" : @(self.sampleRate),
        @"isVolumeEvaluationEnabled" : @(self.isVolumeEvaluationEnabled),
    };
    [[NSUserDefaults standardUserDefaults] setValue:dict forKey:@"TRTCAudioConfig"];
}

@end
