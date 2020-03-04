/*
* Module:   TRTCVideoSettingsViewController
*
* Function: 视频设置页
*
*    1. 通过TRTCCloudManager来设置视频参数
*
*    2. 设置分辨率后，码率的设置范围以及默认值会根据分辨率进行调整
*
*/

#import "TRTCVideoSettingsViewController.h"

@interface TRTCVideoSettingsViewController ()

@property (strong, nonatomic) TRTCSettingsSliderItem *bitrateItem;

@end

@implementation TRTCVideoSettingsViewController

- (NSString *)title {
    return @"视频";
}

- (void)viewDidLoad {
    [super viewDidLoad];

    TRTCVideoConfig *config = self.settingsManager.videoConfig;
    __weak __typeof(self) wSelf = self;
    
    self.bitrateItem = [[TRTCSettingsSliderItem alloc]
                        initWithTitle:@"码率"
                        value:0 min:0 max:0 step:0
                        continuous:NO
                        action:^(float bitrate) {
        [wSelf onSetBitrate:bitrate];
    }];
    
    self.items = @[
        [[TRTCSettingsSelectorItem alloc] initWithTitle:@"分辨率"
                                                  items:TRTCVideoConfig.resolutionNames
                                          selectedIndex:config.resolutionIndex
                                                 action:^(NSInteger index) {
            [wSelf onSelectResolutionIndex:index];
        }],
        [[TRTCSettingsSelectorItem alloc] initWithTitle:@"帧率"
                                                  items:TRTCVideoConfig.fpsList
                                          selectedIndex:config.fpsIndex
                                                 action:^(NSInteger index) {
            [wSelf onSelectFpsIndex:index];
        }],
        self.bitrateItem,
        [[TRTCSettingsSegmentItem alloc] initWithTitle:@"画质偏好"
                                                 items:@[@"优先流畅", @"优先清晰"]
                                         selectedIndex:config.qosPreferenceIndex
                                                action:^(NSInteger index) {
            [wSelf onSelectQosPreferenceIndex:index];
        }],
        [[TRTCSettingsSegmentItem alloc] initWithTitle:@"画面方向"
                                                 items:@[@"横屏模式", @"竖屏模式"]
                                         selectedIndex:config.videoEncConfig.resMode
                                                action:^(NSInteger index) {
            [wSelf onSelectResolutionModelIndex:index];
        }],
        [[TRTCSettingsSegmentItem alloc] initWithTitle:@"填充模式"
                                                 items:@[@"充满", @"适应"]
                                         selectedIndex:config.fillMode
                                                action:^(NSInteger index) {
            [wSelf onSelectFillModeIndex:index];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"开启视频采集"
                                                 isOn:config.isEnabled
                                               action:^(BOOL isOn) {
            [wSelf onEnableVideo:isOn];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"开启推送视频"
                                                 isOn:!config.isMuted
                                               action:^(BOOL isOn) {
            [wSelf onMuteVideo:!isOn];
        }],
        [[TRTCSettingsSegmentItem alloc] initWithTitle:@"开启预览镜像"
                                                 items:TRTCVideoConfig.localMirrorTypeNames
                                         selectedIndex:config.localMirrorType
                                                action:^(NSInteger index) {
            [wSelf onSelectLocalMirror:index];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"开启远程镜像"
                                                 isOn:config.isRemoteMirrorEnabled
                                               action:^(BOOL isOn) {
            [wSelf onEnableRemoteMirror:isOn];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"开启视频水印" isOn:NO action:^(BOOL isOn) {
            [wSelf onEnableWatermark:isOn];
        }],
        [[TRTCSettingsButtonItem alloc] initWithTitle:@"截图分享" buttonTitle:@"分享" action:^{
            [wSelf snapshotLocalVideo];
        }],
    ];
    
    [self updateBitrateItemWithResolution:config.videoEncConfig.videoResolution];
}

#pragma mark - Actions

- (void)onSelectResolutionIndex:(NSInteger)index {
    TRTCVideoResolution resolution = [TRTCVideoConfig.resolutions[index] integerValue];
    [self.settingsManager setResolution:resolution];
    [self updateBitrateItemWithResolution:resolution];
}

- (void)onSelectFpsIndex:(NSInteger)index {
    [self.settingsManager setVideoFps:[TRTCVideoConfig.fpsList[index] intValue]];
}

- (void)onSetBitrate:(float)bitrate {
    [self.settingsManager setVideoBitrate:bitrate];
}

- (void)onSelectQosPreferenceIndex:(NSInteger)index {
    TRTCVideoQosPreference qos = index == 0 ? TRTCVideoQosPreferenceSmooth : TRTCVideoQosPreferenceClear;
    [self.settingsManager setQosPreference:qos];
}

- (void)onSelectResolutionModelIndex:(NSInteger)index {
    TRTCVideoResolutionMode mode = index == 0 ? TRTCVideoResolutionModeLandscape : TRTCVideoResolutionModePortrait;
    [self.settingsManager setResolutionMode:mode];
}

- (void)onSelectFillModeIndex:(NSInteger)index {
    TRTCVideoFillMode mode = index == 0 ? TRTCVideoFillMode_Fill : TRTCVideoFillMode_Fit;
    [self.settingsManager setVideoFillMode:mode];
}

- (void)onEnableVideo:(BOOL)isOn {
    [self.settingsManager setVideoEnabled:isOn];
}

- (void)onMuteVideo:(BOOL)isMuted {
    [self.settingsManager setVideoMuted:isMuted];
}

- (void)onSelectLocalMirror:(NSInteger)index {
    [self.settingsManager setLocalMirrorType:index];
}

- (void)onEnableRemoteMirror:(BOOL)isOn {
    [self.settingsManager setRemoteMirrorEnabled:isOn];
}

- (void)onEnableWatermark:(BOOL)isOn {
    if (isOn) {
        UIImage *image = [UIImage imageNamed:@"watermark"];
        [self.settingsManager setWaterMark:image inRect:CGRectMake(0.7, 0.1, 0.2, 0)];
    } else {
        [self.settingsManager setWaterMark:nil inRect:CGRectZero];
    }
}

- (void)snapshotLocalVideo {
    __weak __typeof(self) wSelf = self;
    [self.settingsManager.trtc snapshotVideo:nil
                                        type:TRTCVideoStreamTypeBig
                             completionBlock:^(TXImage *image) {
        if (image) {
            [wSelf shareImage:image];
        }
    }];
}

- (void)updateBitrateItemWithResolution:(TRTCVideoResolution)resolution {
    TRTCBitrateRange *range = [TRTCVideoConfig bitrateRangeOf:resolution
                                                        scene:self.settingsManager.scene];
    self.bitrateItem.maxValue = range.maxBitrate;
    self.bitrateItem.minValue = range.minBitrate;
    self.bitrateItem.step = range.step;
    self.bitrateItem.sliderValue = range.defaultBitrate;
    
    [self.settingsManager setVideoBitrate:(int)range.defaultBitrate];
    [self.tableView reloadData];
}

- (void)shareImage:(UIImage *)image {
    UIActivityViewController *vc = [[UIActivityViewController alloc]
                                    initWithActivityItems:@[image]
                                    applicationActivities:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
