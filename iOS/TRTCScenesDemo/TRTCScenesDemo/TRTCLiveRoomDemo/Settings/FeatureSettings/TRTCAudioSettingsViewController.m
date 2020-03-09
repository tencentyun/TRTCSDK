/*
* Module:   TRTCAudioSettingsViewController
*
* Function: 音频设置页
*
*    1. 通过TRTCCloudManager来设置音频参数。
*
*    2. TRTCAudioRecordManager用来控制录音，demo录音停止后会弹出分享。
*
*/

#import "TRTCAudioSettingsViewController.h"

@interface TRTCAudioSettingsViewController()

@property (strong, nonatomic) TRTCSettingsButtonItem *recordItem;

@end

@implementation TRTCAudioSettingsViewController

- (NSString *)title {
    return @"音频";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TRTCAudioConfig *config = self.settingsManager.audioConfig;
    __weak __typeof(self) wSelf = self;
    
    self.recordItem = [[TRTCSettingsButtonItem alloc] initWithTitle:@"音频录制"
                                      buttonTitle:self.recordManager.isRecording ? @"停止" : @"录制"
                                           action:^{
        [wSelf onClickRecordButton];
    }];
    
    self.items = @[
        [[TRTCSettingsSegmentItem alloc] initWithTitle:@"音频采样率"
                                                 items:@[@"48K", @"16K"]
                                         selectedIndex:config.sampleRate == 48000 ? 0 : 1
                                                action:^(NSInteger index) {
            [wSelf onSelectSampleRateIndex:index];
        }],
        [[TRTCSettingsSegmentItem alloc] initWithTitle:@"音量类型"
                                                 items:@[@"自动", @"媒体", @"通话"]
                                         selectedIndex:config.volumeType
                                                action:^(NSInteger index) {
            [wSelf onSelectVolumeTypeIndex:index];
        }],
        [[TRTCSettingsSliderItem alloc] initWithTitle:@"采集音量"
                                                value:self.settingsManager.captureVolume min:0 max:100 step:1
                                           continuous:YES
                                               action:^(float volume) {
            [wSelf onUpdateCaptureVolume:(NSInteger)volume];
        }],
        [[TRTCSettingsSliderItem alloc] initWithTitle:@"播放音量"
                                                value:self.settingsManager.playoutVolume min:0 max:100 step:1
                                           continuous:YES
                                               action:^(float volume) {
            [wSelf onUpdatePlayoutVolume:(NSInteger)volume];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"自动增益"
                                                 isOn:config.isAgcEnabled
                                               action:^(BOOL isOn) {
            [wSelf onEnableAgc:isOn];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"噪音消除"
                                                 isOn:config.isAnsEnabled
                                               action:^(BOOL isOn) {
            [wSelf onEnableAns:isOn];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"开启耳返"
                                                 isOn:config.isEarMonitoringEnabled
                                               action:^(BOOL isOn) {
            [wSelf onEnableEarMonitoring:isOn];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"声音采集"
                                                 isOn:config.isEnabled
                                               action:^(BOOL isOn) {
            [wSelf onEnableAudio:isOn];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"免提模式"
                                                 isOn:config.route == TRTCAudioModeSpeakerphone
                                               action:^(BOOL isOn) {
            [wSelf onEnableHandsFree:isOn];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"音量提示"
                                                 isOn:config.isVolumeEvaluationEnabled
                                               action:^(BOOL isOn) {
            [wSelf onEnableVolumeEvaluation:isOn];
        }],
        self.recordItem,
    ];
}

#pragma mark - Actions

- (void)onSelectSampleRateIndex:(NSInteger)index {
    NSInteger sampleRate = index == 0 ? 48000 : 16000;
    [self.settingsManager setSampleRate:sampleRate];
}

- (void)onSelectVolumeTypeIndex:(NSInteger)index {
    TRTCSystemVolumeType type = (TRTCSystemVolumeType)index;
    [self.settingsManager setVolumeType:type];
}

- (void)onUpdateCaptureVolume:(NSInteger)volume {
    [self.settingsManager setCaptureVolume:volume];
}

- (void)onUpdatePlayoutVolume:(NSInteger)volume {
    [self.settingsManager setPlayoutVolume:volume];
}

- (void)onEnableAgc:(BOOL)isOn {
    [self.settingsManager setAgcEnabled:isOn];
}

- (void)onEnableAns:(BOOL)isOn {
    [self.settingsManager setAnsEnabled:isOn];
}

- (void)onEnableEarMonitoring:(BOOL)isOn {
    [self.settingsManager setEarMonitoringEnabled:isOn];
}

- (void)onEnableAudio:(BOOL)isOn {
    [self.settingsManager setAudioEnabled:isOn];
}

- (void)onEnableHandsFree:(BOOL)isOn {
    TRTCAudioRoute route = isOn ? TRTCAudioModeSpeakerphone : TRTCAudioModeEarpiece;
    [self.settingsManager setAudioRoute:route];
}

- (void)onEnableVolumeEvaluation:(BOOL)isOn {
    [self.settingsManager setVolumeEvaluationEnabled:isOn];
}

- (void)onClickRecordButton {
    if (self.recordManager.isRecording) {
        [self.recordManager stopRecord];
        [self shareAudioFile];
    } else {
        [self.recordManager startRecord];
    }
    self.recordItem.buttonTitle = self.recordManager.isRecording ? @"停止" : @"录制";
    [self.tableView reloadData];
}

- (void)shareAudioFile {
    if (self.recordManager.audioFilePath.length == 0) {
        return;
    }
    NSURL *fileUrl = [NSURL fileURLWithPath:self.recordManager.audioFilePath];
    UIActivityViewController *activityView =
    [[UIActivityViewController alloc] initWithActivityItems:@[fileUrl]
                                      applicationActivities:nil];
    [self presentViewController:activityView animated:YES completion:nil];
}

@end
