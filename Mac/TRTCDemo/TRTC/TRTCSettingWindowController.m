//
//  TRTCSettingWindowController.m
//  TXLiteAVMacDemo
//
//  Created by ericxwli on 2018/10/17.
//  Copyright © 2018年 Tencent. All rights reserved.
//
//
// 用于对视频通话的分辨率、帧率和流畅模式进行调整，并支持记录下这些设置项

#import "TRTCSettingWindowController.h"

#define CLAMP(x, min, max) MIN(MAX((x),(min)), (max))

#define DECL_DEFAULT_KEY(x) static NSString * const DefaultKey##x = @"TRTC_"#x;
DECL_DEFAULT_KEY(FPS)
DECL_DEFAULT_KEY(Resolution)
DECL_DEFAULT_KEY(Bitrate)
DECL_DEFAULT_KEY(QosPreference)
DECL_DEFAULT_KEY(QosMode)

@interface TRTCSettingBitrateTable : NSObject
@property (nonatomic, assign) int resolution;
@property (nonatomic, assign) int defaultBitrate;
@property (nonatomic, assign) int minBitrate;
@property (nonatomic, assign) int maxBitrate;
@property (nonatomic, assign) int step;
- (instancetype)initWithResolution:(int)resolution defaultBitrate:(int)defaultBitrate
                        minBitrate:(int)minBitrate maxBitrate:(int)maxBitrate step:(int)step;
@end

@interface TRTCSettingWindowController () <NSTableViewDelegate,NSTableViewDataSource,NSWindowDelegate>
{
    NSArray<TRTCSettingBitrateTable *> *_paramArray;
}
@property (weak) IBOutlet NSLevelIndicator *volumeMeter;
@property (weak) IBOutlet NSLevelIndicator *speakerVolumeMeter;
@property (nonatomic, strong) TRTCCloud *trtcEngine;
@end

@implementation TRTCSettingWindowController
+ (void)load {
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
                                                              DefaultKeyFPS : @15,
                                                              DefaultKeyResolution: @(TRTCVideoResolution_640_480),
                                                              DefaultKeyBitrate: @500,
                                                              DefaultKeyQosPreference: @(TRTCVideoQosPreferenceSmooth),
                                                              DefaultKeyQosMode: @(TRTCQosControlModeServer)
                                                              }];
}

- (instancetype)initWithWindowNibName:(NSNibName)windowNibName engine:(TRTCCloud *)engine {
    if (self = [super initWithWindowNibName:windowNibName]) {
        self.trtcEngine = engine;
        _tabIndex = TXAVSettingTabIndexVideo;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // 初始化界面数据
    [self setup];
}

#pragma mark - Class Properties
+ (int)fps {
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:DefaultKeyFPS];
}

+ (TRTCVideoResolution)resolution {
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:DefaultKeyResolution];
}

+ (int)bitrate {
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:DefaultKeyBitrate];
}

+ (TRTCVideoQosPreference)qosControlPreference {
    return (TRTCVideoQosPreference)[[NSUserDefaults standardUserDefaults] integerForKey:DefaultKeyQosPreference];
}

+ (TRTCQosControlMode)qosControlMode {
    return (TRTCQosControlMode)[[NSUserDefaults standardUserDefaults] integerForKey:DefaultKeyQosMode];
}

#pragma mark -
- (void)setup {
    NSArray<TRTCMediaDeviceInfo*> *cameras = [self.trtcEngine getCameraDevicesList];
    
    NSArray *resolutionArr = @[@"160x160", @"320x180", @"320x240", @"480x480", @"640x360", @"640x480", @"960x540",@"1280x720"];
    NSArray *fpsArr = @[@"15fps", @"20fps", @"24fps"];
    
    _paramArray = @[[[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_160_160 defaultBitrate:150 minBitrate:40 maxBitrate:120 step:10],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_320_180 defaultBitrate:250 minBitrate:80 maxBitrate:240 step:10],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_320_240 defaultBitrate:300 minBitrate:100 maxBitrate:300 step:10],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_480_480 defaultBitrate:400 minBitrate:200 maxBitrate:1000 step:10],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_640_360 defaultBitrate:500 minBitrate:200 maxBitrate:1000 step:10],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_640_480 defaultBitrate:600 minBitrate:250 maxBitrate:1000 step:50],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_960_540 defaultBitrate:800 minBitrate:400 maxBitrate:1600 step:50],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_1280_720 defaultBitrate:1150 minBitrate:500 maxBitrate:2000 step:50]];
    
    // 配置摄像头选择
    [self.cameraItems removeAllItems];
    [self.cameraItems addItemsWithTitles:[cameras valueForKey:@"deviceName"]];
    NSUInteger selected = [cameras indexOfObject:[self.trtcEngine getCurrentCameraDevice]];
    [self.cameraItems selectItemAtIndex:selected == NSNotFound ? 0 : selected];
    
    // 配置麦克风选择
    NSArray *micList = [self.trtcEngine getMicDevicesList];
    [self.micItems removeAllItems];
    [self.micItems addItemsWithTitles:[micList valueForKey:@"deviceName"]];
    NSUInteger micSelected = [micList indexOfObject:[self.trtcEngine getCurrentMicDevice]];
    [self.micItems selectItemAtIndex:micSelected == NSNotFound ? 0 : micSelected];
    
    // 配置扬声器选择
    NSArray *speakerList = [self.trtcEngine getSpeakerDevicesList];
    [self.speakerItems removeAllItems];
    [self.speakerItems addItemsWithTitles:[speakerList valueForKey:@"deviceName"]];
    NSUInteger speakerSelected = [speakerList indexOfObject:[self.trtcEngine getCurrentSpeakerDevice]];
    [self.speakerItems selectItemAtIndex:speakerSelected == NSNotFound ? 0 : speakerSelected];
    
    // 配置分辨率选择
    [self.resolutionItems removeAllItems];
    NSString *resolution = [self resolutionString:[[self class] resolution]];
    [self.resolutionItems addItemsWithTitles:resolutionArr];
    NSInteger index = [resolutionArr indexOfObject:resolution];
    TRTCSettingBitrateTable *config = _paramArray[index];
    [self.resolutionItems selectItemAtIndex:index];
    self.bitrateSlider.minValue = config.minBitrate;
    self.bitrateSlider.maxValue = config.maxBitrate;
    self.bitrateSlider.integerValue = config.defaultBitrate;
    // 配置fps
    [self.fpsItems removeAllItems];
    [self.fpsItems addItemsWithTitles:fpsArr];
    [self.fpsItems selectItemAtIndex:[fpsArr indexOfObject:[NSString stringWithFormat:@"%dfps", [[self class] fps]]]];
    
    // 配置音量
    self.micVolumeSlider.floatValue = [self.trtcEngine getCurrentMicDeviceVolume];
    self.speakerVolumeSlider.floatValue = [self.trtcEngine getCurrentSpeakerDeviceVolume];

    // 配置清晰流畅
    if (TRTCSettingWindowController.qosControlPreference == TRTCVideoQosPreferenceSmooth) {
        self.smoothBtn.state = NSControlStateValueOn;
    } else {
        self.clearBtn.state  = NSControlStateValueOn;
    }
    
    // 添加设置界面
    [self.settingField addSubview:self.videoSettingView];
    [self.settingField addSubview:self.audioSettingView];
    
    // 配置侧栏菜单
    [self _configureSidebarMenu];
}

- (IBAction)showWindow:(id)sender {
    [super showWindow:sender];
    // 开始相机测试
    [self.trtcEngine startCameraDeviceTestInView:self.cameraPreview];
    [self _updateVideoQuality];
    // 更新界面数据
    self.micVolumeSlider.floatValue = [self.trtcEngine getCurrentMicDeviceVolume] / 100.f;
    self.speakerVolumeSlider.floatValue = [self.trtcEngine getCurrentSpeakerDeviceVolume] / 100.f;
}

-(void)windowWillClose:(NSNotification *)notification{
    [self.trtcEngine stopCameraDeviceTest];
    [self.trtcEngine stopMicDeviceTest];
}

- (void)_configureSidebarMenu {
    switch(_tabIndex) {
        case TXAVSettingTabIndexAudio: {
            self.videoSettingView.hidden = YES;
            self.audioSettingView.hidden = NO;
            [self.sidebarMenu selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];
        } break;
        case TXAVSettingTabIndexVideo: {
            self.videoSettingView.hidden = NO;
            self.audioSettingView.hidden = YES;
            [self.sidebarMenu selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
            [self.trtcEngine stopMicDeviceTest];
            [self.trtcEngine stopSpeakerDeviceTest];
        } break;
    }
}

- (void)setTabIndex:(TXAVSettingTabIndex)tabIndex {
    if (_tabIndex == tabIndex) return;
    _tabIndex = tabIndex;
    [self _configureSidebarMenu];
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 2;
}

#pragma mark - NSTableViewDelegate
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"SettingModeRow" owner:tableView];
    if (row == 0) {
        cellView.textField.stringValue = @"视频";
        cellView.imageView.image = [NSImage imageNamed:@"video_on"];
    }
    else if(row== 1){
        cellView.textField.stringValue = @"音频";
        cellView.imageView.image = [NSImage imageNamed:@"audio"];
    }
    return cellView;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView *tableView = notification.object;
    self.tabIndex = tableView.selectedRow;
}

#pragma mark - User Actions
- (IBAction)selectCamera:(id)sender {
    NSInteger index = [sender indexOfSelectedItem];
    TRTCMediaDeviceInfo *selecteDevice = [self.trtcEngine getCameraDevicesList][index];
    [self.trtcEngine setCurrentCameraDevice:selecteDevice.deviceId];
}

- (IBAction)selectSpeaker:(id)sender {
    NSInteger index = [sender indexOfSelectedItem];
    TRTCMediaDeviceInfo *selecteDevice = [self.trtcEngine getSpeakerDevicesList][index];
    [self.trtcEngine setCurrentSpeakerDevice:selecteDevice.deviceId];
}

- (IBAction)selectMic:(id)sender {
    NSInteger index = [sender indexOfSelectedItem];
    TRTCMediaDeviceInfo *selecteDevice = [self.trtcEngine getMicDevicesList][index];
    [self.trtcEngine setCurrentMicDevice:selecteDevice.deviceId];
}

// 更改扬声器音量
- (IBAction)speakerVolumChange:(id)sender {
    NSSlider *slider = sender;
    float fvalue = slider.floatValue;
    [self.trtcEngine setCurrentSpeakerDeviceVolume:fvalue * 100];
}

// 更改麦克风音量
- (IBAction)micVolumChange:(id)sender {
    NSSlider *slider = sender;
    float fvalue = slider.floatValue;
    [self.trtcEngine setCurrentMicDeviceVolume:fvalue * 100];
}

// 分辨率选则
- (IBAction)selectResolution:(id)sender {
    NSInteger index = self.resolutionItems.indexOfSelectedItem;
    TRTCSettingBitrateTable *config = _paramArray[index];
    self.bitrateSlider.minValue = config.minBitrate;
    self.bitrateSlider.maxValue = config.maxBitrate;
    self.bitrateSlider.doubleValue = CLAMP(self.bitrateSlider.doubleValue, config.minBitrate, config.maxBitrate);
    [[NSUserDefaults standardUserDefaults] setInteger:config.resolution forKey:DefaultKeyResolution];
    [self _updateVideoQuality];
}

// 帧率选则
- (IBAction)selectFps:(NSPopUpButton *)sender {
    NSInteger fpsIndex = sender.indexOfSelectedItem;
    int fps = 0;
    if (fpsIndex == 0) {
        fps = 15;
    } else if (fpsIndex == 1) {
        fps = 20;
    } else if (fpsIndex == 2) {
        fps = 24;
    }

    [[NSUserDefaults standardUserDefaults] setInteger:fps forKey:DefaultKeyFPS];

    [self _updateVideoQuality];
}

// 比特率选则
- (IBAction)selectBitrate:(id)sender {
    NSSlider *slider = sender;
    int value = slider.intValue;
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:DefaultKeyBitrate];
    self.bitrateLabel.stringValue = [NSString stringWithFormat:@"%dkbps",value];
    [self _updateVideoQuality];
}

// 麦克风测试
- (IBAction)micTest:(id)sender {
    NSButton *btn = (NSButton *)sender;
    if (btn.state == 1) {
        __weak __typeof(self) wself = self;
        [self.trtcEngine startMicDeviceTest:500  testEcho:^(NSInteger volume) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself _updateInputVolume:volume];
            });
        }];
        btn.title = @"停止测试";
    }
    else{
        [self.trtcEngine stopMicDeviceTest];
        [self _updateInputVolume:0];
        btn.title = @"麦克风测试";
    }
}

// 开始扬声器测试
- (IBAction)speakerTest:(NSButton *)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp3"];

    NSButton *btn = (NSButton *)sender;
    if (btn.state == NSControlStateValueOn) {
        __weak __typeof(self) wself = self;
        [self.trtcEngine startSpeakerDeviceTest:path onVolumeChanged:^(NSInteger volume, BOOL playFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself _updateOutputVolume:volume];
                if (playFinished) {
                    sender.state = NSControlStateValueOff;
                }
            });
        }];
    } else {
        [self.trtcEngine stopSpeakerDeviceTest];
        [self _updateOutputVolume:0];
    }
}

// 更改流控模式，流畅还是清晰
- (IBAction)onChangeControlMode:(NSButton *)sender {
    TRTCVideoQosPreference preference = sender.tag == 0 ? TRTCVideoQosPreferenceSmooth : TRTCVideoQosPreferenceClear;
    [[NSUserDefaults standardUserDefaults] setInteger:preference forKey:DefaultKeyQosPreference];
    [self _updateVideoQuality];
}

//  更改流控方式，使用SDK固定配置还是使用下发配置
//- (IBAction)onChangeControlType:(NSButton *)sender {
//    TRTCQosControlMode mode = sender.tag == 0 ? TRTCQosControlModeClient : TRTCQosControlModeServer;
//    [[NSUserDefaults standardUserDefaults] setInteger:mode forKey:DefaultKeyQosMode];
//    [self _updateVideoQuality];
//}

#pragma mark - Utils
- (TRTCVideoResolution)resolutionFromIndex:(NSInteger)resolutionIndex
{
    switch (resolutionIndex) {
        case 0:
            return TRTCVideoResolution_160_160;
        case 1:
            return TRTCVideoResolution_320_180;
        case 2:
            return TRTCVideoResolution_320_240;
        case 3:
            return TRTCVideoResolution_480_480;
        case 4:
            return TRTCVideoResolution_640_360;
        case 5:
            return TRTCVideoResolution_640_480;
        case 6:
            return TRTCVideoResolution_960_540;
        case 7:
            return TRTCVideoResolution_1280_720;
        default:
            return TRTCVideoResolution_640_480;
    }
}

- (NSString *)resolutionString:(TRTCVideoResolution)resolution {
    if (resolution == TRTCVideoResolution_160_160) return @"160x160";
    if (resolution == TRTCVideoResolution_320_180) return @"320x180";
    if (resolution == TRTCVideoResolution_320_240) return @"320x240";
    if (resolution == TRTCVideoResolution_640_360) return @"640x360";
    if (resolution == TRTCVideoResolution_480_480) return @"480x480";
    if (resolution == TRTCVideoResolution_640_480) return @"640x480";
    if (resolution == TRTCVideoResolution_960_540) return @"960x540";
    if (resolution == TRTCVideoResolution_1280_720) return @"1280x720";
    return @"";
}

#pragma mark - 数据更新
- (void)_updateVideoQuality {
    NSInteger resolutionIndex = [self.resolutionItems indexOfSelectedItem];
    
    TRTCVideoEncParam *config = [TRTCVideoEncParam new];
    config.videoBitrate = TRTCSettingWindowController.bitrate ;
    config.videoResolution = [self resolutionFromIndex:resolutionIndex];
    config.videoFps = TRTCSettingWindowController.fps;
    [self.trtcEngine setVideoEncoderParam:config];
}

// 更新麦克音量指示器
- (void)_updateInputVolume:(NSInteger)volume {
    // volume range: 0~100
    self.volumeMeter.doubleValue = volume / 10.0 ;
}

// 更新扬声器音量指示器
- (void)_updateOutputVolume:(NSInteger)volume {
    self.speakerVolumeMeter.doubleValue = volume / 255.0 * 10;
}

@end

@implementation TRTCSettingBitrateTable
- (instancetype)initWithResolution:(int)resolution defaultBitrate:(int)defaultBitrate
                        minBitrate:(int)minBitrate maxBitrate:(int)maxBitrate step:(int)step {
    if (self = [super init]) {
        self.resolution = resolution;
        self.defaultBitrate = defaultBitrate;
        self.minBitrate = minBitrate;
        self.maxBitrate = maxBitrate;
        self.step = step;
    }
    return self;
}
@end
