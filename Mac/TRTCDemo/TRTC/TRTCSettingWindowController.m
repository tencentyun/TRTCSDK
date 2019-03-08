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
#import <objc/message.h>

#define CLAMP(x, min, max) MIN(MAX((x),(min)), (max))

#define DECL_DEFAULT_KEY(type, key, property) \
static NSString * const DefaultKey##key = @"TRTC_"#key; \
static type s_##key; \
+ (void)set##key:(type)value { \
    s_##key = value; \
} \
+ (type)property { \
    return s_##key;\
}


@interface TRTCSettingBitrateTable : NSObject
@property (nonatomic, assign) int resolution;
@property (nonatomic, assign) int defaultBitrate;
@property (nonatomic, assign) int minBitrate;
@property (nonatomic, assign) int maxBitrate;
@property (nonatomic, assign) int step;

- (instancetype)initWithResolution:(int)resolution defaultBitrate:(int)defaultBitrate
                        minBitrate:(int)minBitrate maxBitrate:(int)maxBitrate step:(int)step;
@end

static NSArray *defaultKeys;

@interface TRTCSettingWindowController () <NSTableViewDelegate,NSTableViewDataSource,NSWindowDelegate>
{
    NSArray<TRTCSettingBitrateTable *> *_paramArray;
    NSArray<TRTCSettingBitrateTable *> *_subStreamParamArray;

    NSArray<NSArray<NSString*>*>* _menu;
}
@property (nonatomic, strong) TRTCCloud *trtcEngine;
@property (nonatomic, readonly) BOOL shouldSaveToDefaults;
@end

@implementation TRTCSettingWindowController

// 生成配置项的UserDefaults Key以及对应的accessor

// 场景
DECL_DEFAULT_KEY(TRTCAppScene, Scene, scene)

// 是否显示音量
DECL_DEFAULT_KEY(BOOL, ShowVolume, showVolume)
// 是否开启云端画面混合
DECL_DEFAULT_KEY(BOOL, CloudMixEnabled, cloudMixEnabled)
// 分辨率模式
DECL_DEFAULT_KEY(TRTCVideoResolutionMode, ResolutionMode, resolutionMode);
// 大小流
DECL_DEFAULT_KEY(int, Fps, fps)
DECL_DEFAULT_KEY(TRTCVideoResolution, Resolution, resolution)
DECL_DEFAULT_KEY(int, Bitrate, bitrate)
DECL_DEFAULT_KEY(TRTCVideoQosPreference, QosPreference, qosPreference)
DECL_DEFAULT_KEY(TRTCQosControlMode, QosControlMode, qosControlMode)

// 是否保存配置。当设置为不保存时应用退出后所有设置将被恢复
DECL_DEFAULT_KEY(BOOL, ShouldSaveToDefaults, shouldSaveToDefaults)

// 辅流配置
DECL_DEFAULT_KEY(int, SubStreamFps, subStreamFps)
DECL_DEFAULT_KEY(TRTCVideoResolution, SubStreamResolution, subStreamResolution)
DECL_DEFAULT_KEY(int, SubStreamBitrate, subStreamBitrate)

// 推拉流类型配置
DECL_DEFAULT_KEY(BOOL, PushDoubleStream, pushDoubleStream)
DECL_DEFAULT_KEY(BOOL, PlaySmallStream, playSmallStream)

+ (void)load {
    // 默认配置表
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *defaultValues = @{
                                 DefaultKeyShouldSaveToDefaults: @(YES),
                                 
                                 DefaultKeyScene: @(TRTCAppSceneVideoCall),
                                 DefaultKeyShowVolume: @(YES),

                                 DefaultKeyResolutionMode: @(TRTCVideoResolutionModeLandscape),
                                 DefaultKeyCloudMixEnabled: @(NO),
                                 
                                 DefaultKeyFps : @(15),
                                 DefaultKeyResolution: @(TRTCVideoResolution_640_480),
                                 DefaultKeyBitrate: @500,
                                 DefaultKeyQosPreference: @(TRTCVideoQosPreferenceSmooth),
                                 DefaultKeyQosControlMode: @(TRTCQosControlModeServer),

                                 DefaultKeySubStreamFps: @10,
                                 DefaultKeySubStreamBitrate: @(800),
                                 DefaultKeySubStreamResolution: @(TRTCVideoResolution_1280_720),
                                 
                                 DefaultKeyPushDoubleStream: @(NO),
                                 DefaultKeyPlaySmallStream: @(NO),
                                 };
    [userDefaults registerDefaults:defaultValues];
    defaultKeys = defaultValues.allKeys;
    // 将设置导入静态变量
    for (NSString *key in defaultValues) {
        NSString *sel = [[key stringByReplacingOccurrencesOfString:@"TRTC_" withString:@"set"] stringByAppendingString:@":"];
        void(*setProperty)(id, SEL, NSInteger) = (void(*)(id, SEL, NSInteger))objc_msgSend;
        setProperty(self, NSSelectorFromString(sel), [userDefaults integerForKey:key]);
    };
}

- (instancetype)initWithWindowNibName:(NSNibName)windowNibName engine:(TRTCCloud *)engine {
    if (self = [super initWithWindowNibName:windowNibName]) {
        self.trtcEngine = engine;
        _menu = @[@[@"常规设置", @"settings_general"], @[@"视频设置", @"settings_video"], @[@"声音设置", @"settings_audio"], @[@"屏幕分享", @"settings_screen_share"]];
        _tabIndex = TXAVSettingTabIndexGeneral;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // 初始化界面数据
    [self setup];
}

-(void)windowWillClose:(NSNotification *)notification{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DefaultKeyShouldSaveToDefaults]) {
        [self _writeSettingsToUserDefaults];
    }
}

#pragma mark - Accessors
- (BOOL)shouldSaveToDefaults {
    return [[NSUserDefaults standardUserDefaults] boolForKey:DefaultKeyShouldSaveToDefaults];
}

- (void)setPlaySmallStream:(BOOL)playSmallStream {
    self.class.playSmallStream = playSmallStream;
}

- (BOOL)playSmallStream {
    return self.class.playSmallStream;
}

- (void)setPushDoubleStream:(BOOL)pushDoubleStream {
    self.class.pushDoubleStream = pushDoubleStream;
}

- (BOOL)pushDoubleStream {
    return self.class.pushDoubleStream;
}

- (void)setShowVolume:(BOOL)showVolume {
    self.class.showVolume = showVolume;
}

- (BOOL)showVolume {
    return self.class.showVolume;
}

- (void)setCloudMixEnabled:(BOOL)cloudMixEnabled {
    self.class.cloudMixEnabled = cloudMixEnabled;
}

- (BOOL)cloudMixEnabled {
    return self.class.cloudMixEnabled;
    //TODO
}

#pragma mark - Defaults Writer
- (void)_writeSettingsToUserDefaults {
    [self.trtcEngine stopCameraDeviceTest];
    [self.trtcEngine stopMicDeviceTest];
    if (self.shouldSaveToDefaults) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        for (NSString *key in defaultKeys) {
            NSMutableString *propKey = [[key stringByReplacingOccurrencesOfString:@"TRTC_" withString:@""] mutableCopy];
            char first = tolower([propKey characterAtIndex:0]);
            [propKey replaceCharactersInRange:NSMakeRange(0, 1) withString:[NSString stringWithFormat:@"%c", first]];
            int(*getValue)(id,SEL) = (int(*)(id,SEL))objc_msgSend;
            [userDefaults setInteger:getValue(self.class, NSSelectorFromString(propKey)) forKey:key];
        }
        [userDefaults synchronize];
    }
}

#pragma mark - UI Setup
- (void)setup {
    self.window.titleVisibility = NSWindowTitleHidden;
    NSArray<TRTCMediaDeviceInfo*> *cameras = [self.trtcEngine getCameraDevicesList];
    
    NSArray *resolutionArr = @[@"160x160", @"320x180", @"320x240", @"480x480", @"640x360", @"640x480", @"960x540",@"1280x720"];
    NSArray *fpsArr = @[@"15fps", @"20fps", @"24fps"];
    
    NSArray *substreamResolutionArr = @[@"960x540",@"960x720", @"1280x720", @"1920x1080"];
    
    _paramArray = @[[[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_160_160 defaultBitrate:150 minBitrate:40 maxBitrate:120 step:10],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_320_180 defaultBitrate:250 minBitrate:80 maxBitrate:240 step:10],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_320_240 defaultBitrate:300 minBitrate:100 maxBitrate:300 step:10],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_480_480 defaultBitrate:400 minBitrate:200 maxBitrate:1000 step:10],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_640_360 defaultBitrate:500 minBitrate:200 maxBitrate:1000 step:10],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_640_480 defaultBitrate:600 minBitrate:250 maxBitrate:1000 step:50],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_960_540 defaultBitrate:800 minBitrate:400 maxBitrate:1600 step:50],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_1280_720 defaultBitrate:1150 minBitrate:500 maxBitrate:2000 step:50]];
    
    _subStreamParamArray = @[[[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_960_540 defaultBitrate:450 minBitrate:300 maxBitrate:1200 step:10],
                            [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_960_720 defaultBitrate:500 minBitrate:300 maxBitrate:1200 step:50],
                            [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_1280_720 defaultBitrate:600 minBitrate:400 maxBitrate:1600 step:50],
                            [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_1920_1080 defaultBitrate:800 minBitrate:400 maxBitrate:2000 step:50]];
    
    // 配置场景
    if (self.class.scene == TRTCAppSceneVideoCall) {
        self.callSceneButton.state = NSOnState;
    } else {
        self.callSceneButton.state = NSOffState;
    }
    self.callSceneButton.tag = TRTCAppSceneVideoCall;
    self.liveSceneButton.tag = TRTCAppSceneLIVE;
    
    if (self.class.resolutionMode == TRTCVideoResolutionModeLandscape) {
        self.landscapeResolutionBtn.state = NSOnState;
    } else {
        self.portraitResolutionBtn.state = NSOnState;
    }
    self.landscapeResolutionBtn.tag = TRTCVideoResolutionModeLandscape;
    self.portraitResolutionBtn.tag  = TRTCVideoResolutionModePortrait;
    
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
    
    [self _setBitRate:[[self class] bitrate]];

    // 配置fps
    [self.fpsItems removeAllItems];
    [self.fpsItems addItemsWithTitles:fpsArr];
    [self.fpsItems selectItemAtIndex:[fpsArr indexOfObject:[NSString stringWithFormat:@"%dfps", [[self class] fps]]]];
    
    // 辅流
    [self.substreamResolutionItems removeAllItems];
    [self.substreamResolutionItems addItemsWithTitles:substreamResolutionArr];
    index = [substreamResolutionArr indexOfObject:[self subResolutionString:[[self class] subStreamResolution]]];
    [self.substreamResolutionItems selectItemAtIndex:index];
    config = _subStreamParamArray[index];
    self.substreamBitrateSlider.minValue = config.minBitrate;
    self.substreamBitrateSlider.maxValue = config.maxBitrate;
    self.substreamBitrateSlider.intValue = [self.class subStreamBitrate];

    
    [self.substreamFpsItems removeAllItems];
    [self.substreamFpsItems addItemsWithTitles: [@[@"10fps"] arrayByAddingObjectsFromArray:fpsArr]];
    [self.substreamFpsItems selectItemAtIndex:[self.substreamFpsItems.itemTitles indexOfObject:[NSString stringWithFormat:@"%dfps", [[self class] subStreamFps]]]];
    
    // 配置音量
    self.micVolumeSlider.floatValue = [self.trtcEngine getCurrentMicDeviceVolume];
    self.speakerVolumeSlider.floatValue = [self.trtcEngine getCurrentSpeakerDeviceVolume];
    
    // 配置清晰流畅
    if (TRTCSettingWindowController.qosPreference == TRTCVideoQosPreferenceSmooth) {
        self.smoothBtn.state = NSControlStateValueOn;
    } else {
        self.clearBtn.state  = NSControlStateValueOn;
    }
    if (TRTCSettingWindowController.qosControlMode == TRTCQosControlModeClient) {
        self.clientBtn.state = NSControlStateValueOn;
    } else {
        self.cloudBtn.state  = NSControlStateValueOn;
    }
    
    // 添加设置界面
    for (NSView *v in @[self.generalSettingView, self.videoSettingView, self.audioSettingView, self.subStreamSettingView]) {
        [self.settingField addSubview:v];
    }

    // 配置侧栏菜单
    [self _configureSidebarMenu];
}

- (IBAction)showWindow:(id)sender {
    [super showWindow:sender];
    // 开始相机测试
    [self _updateVideoConfig];
    // 更新界面数据
    self.micVolumeSlider.floatValue = [self.trtcEngine getCurrentMicDeviceVolume] / 100.f;
    self.speakerVolumeSlider.floatValue = [self.trtcEngine getCurrentSpeakerDeviceVolume] / 100.f;
}


- (void)_configureSidebarMenu {
    self.generalSettingView.hidden   = YES;
    self.videoSettingView.hidden     = YES;
    self.audioSettingView.hidden     = YES;
    self.subStreamSettingView.hidden = YES;
    if (_tabIndex != TXAVSettingTabIndexVideo) {
        [self.trtcEngine stopCameraDeviceTest];
    }
    if (_tabIndex != TXAVSettingTabIndexAudio) {
        [self.trtcEngine stopMicDeviceTest];
        [self.trtcEngine stopSpeakerDeviceTest];
    }
    switch(_tabIndex) {
        case TXAVSettingTabIndexGeneral: {
            self.generalSettingView.hidden = NO;
        }   break;
        case TXAVSettingTabIndexAudio: {
            self.audioSettingView.hidden = NO;
            [self.sidebarMenu selectRowIndexes:[NSIndexSet indexSetWithIndex:TXAVSettingTabIndexAudio] byExtendingSelection:NO];
        } break;
        case TXAVSettingTabIndexVideo: {
            self.videoSettingView.hidden = NO;
            [self.trtcEngine startCameraDeviceTestInView:self.cameraPreview];
            [self.sidebarMenu selectRowIndexes:[NSIndexSet indexSetWithIndex:TXAVSettingTabIndexVideo] byExtendingSelection:NO];
        } break;
        case TXAVSettingTabIndexSubStream: {
            self.subStreamSettingView.hidden = NO;
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
    return _menu.count;
}

#pragma mark - NSTableViewDelegate
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"SettingModeRow" owner:tableView];
    NSArray *item = _menu[row];
    
    cellView.textField.stringValue = item.firstObject;
    cellView.imageView.image = [NSImage imageNamed:item.lastObject];
    
    return cellView;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView *tableView = notification.object;
    self.tabIndex = tableView.selectedRow;
}

#pragma mark - User Actions
- (IBAction)selectScene:(NSButton *)sender {
    self.class.scene = ((TRTCAppScene)sender.tag);
}

- (IBAction)selectResolutionMode:(NSButton *)sender {
    TRTCVideoResolutionMode mode = (TRTCVideoResolutionMode)sender.tag;
    if (mode != self.class.resolutionMode) {
        self.class.resolutionMode = mode;
        [self _updateVideoConfig];
    }
}

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
    [self _setBitRate:self.bitrateSlider.doubleValue];
    self.class.resolution = [self _resolutionFromIndex:index];
    [self _updateVideoConfig];
}

- (void)_setBitRate:(double)bitrate {
    NSInteger index = self.resolutionItems.indexOfSelectedItem;
    TRTCSettingBitrateTable *config = _paramArray[index];
    double value = CLAMP(bitrate, config.minBitrate, config.maxBitrate);
    self.bitrateSlider.doubleValue = value;
    self.bitrateLabel.stringValue = [NSString stringWithFormat:@"%.0lfkbps", value];
    self.class.bitrate = value;
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
    self.class.fps = fps;
    [self _updateVideoConfig];
}

// 比特率选则
- (IBAction)selectBitrate:(id)sender {
    NSSlider *slider = sender;
    int value = slider.intValue;
    self.class.bitrate = value;
    self.bitrateLabel.stringValue = [NSString stringWithFormat:@"%dkbps",value];
    [self _updateVideoConfig];
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
- (IBAction)onChangeQOSPreference:(NSButton *)sender {
    TRTCVideoQosPreference preference = sender.tag == 0 ? TRTCVideoQosPreferenceSmooth : TRTCVideoQosPreferenceClear;
    self.class.qosPreference = preference;
    [self _updateQOSParam];
}

//  更改流控方式，使用SDK固定配置还是使用下发配置
- (IBAction)onChangeQOSControlMode:(NSButton *)sender {
    TRTCQosControlMode mode = sender.tag == 0 ? TRTCQosControlModeClient : TRTCQosControlModeServer;
    self.class.qosControlMode = mode;
    [self _updateQOSParam];
}

#pragma mark - Utils
- (TRTCVideoResolution)_resolutionFromIndex:(NSInteger)resolutionIndex
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

- (TRTCVideoResolution)_subResolutionFromIndex:(NSInteger)resolutionIndex
{
    switch (resolutionIndex) {
        case 0:
            return TRTCVideoResolution_960_540;
        case 1:
            return TRTCVideoResolution_960_720;
        case 2:
            return TRTCVideoResolution_1280_720;
        case 3:
            return TRTCVideoResolution_1920_1080;
        default:
            return TRTCVideoResolution_1280_720;
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

- (NSString *)subResolutionString:(TRTCVideoResolution)resolution {
    if (resolution == TRTCVideoResolution_960_540) return @"960x540";
    if (resolution == TRTCVideoResolution_960_720) return @"960x720";
    if (resolution == TRTCVideoResolution_1280_720) return @"1280x720";
    if (resolution == TRTCVideoResolution_1920_1080) return @"1920x1080";
    return @"1280x720";
}

#pragma mark - 数据更新
- (void)_updateVideoConfig {
    NSInteger resolutionIndex = [self.resolutionItems indexOfSelectedItem];
    
    TRTCVideoEncParam *config = [TRTCVideoEncParam new];
    config.videoBitrate = TRTCSettingWindowController.bitrate ;
    config.videoResolution = [self _resolutionFromIndex:resolutionIndex];
    config.videoFps = TRTCSettingWindowController.fps;
    config.resMode = TRTCSettingWindowController.resolutionMode;
    [self.trtcEngine setVideoEncoderParam:config];
}
- (void)_updateQOSParam {
    TRTCNetworkQosParam *param = [[TRTCNetworkQosParam alloc] init];
    param.preference = self.class.qosPreference;
    param.controlMode = self.class.qosControlMode;
    [self.trtcEngine setNetworkQosParam:param];
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

#pragma mark - Sub Stream Settings

// 分辨率选则
- (IBAction)subStram_selectResolution:(id)sender {
    NSInteger index = self.substreamResolutionItems.indexOfSelectedItem;
    self.class.subStreamResolution = [self _subResolutionFromIndex:index];
    [self _subStram_updateVideoConfig];
}

- (void)_subStream_setBitRate:(double)bitrate {
    NSInteger index = self.substreamResolutionItems.indexOfSelectedItem;
    TRTCSettingBitrateTable *config = _subStreamParamArray[index];
    double value = CLAMP(bitrate, config.minBitrate, config.maxBitrate);
    self.substreamBitrateSlider.minValue = config.minBitrate;
    self.substreamBitrateSlider.maxValue = config.maxBitrate;
    self.class.subStreamBitrate = value;
    self.substreamBitrateSlider.doubleValue = value;
    self.substreamBitrateLabel.stringValue = [NSString stringWithFormat:@"%.0lfkbps", value];
    [self _subStram_updateVideoConfig];

}


// 帧率选则
- (int)_subStreamFpsFromIndex:(NSInteger)fpsIndex {
    int fps = 0;
    if (fpsIndex == 0) {
        fps = 10;
    } else if (fpsIndex == 1) {
        fps = 15;
    } else if (fpsIndex == 2) {
        fps = 20;
    } else {
        fps = 24;
    }
    return fps;
}

- (IBAction)subStram_selectFps:(NSPopUpButton *)sender {
    NSInteger fpsIndex = sender.indexOfSelectedItem;
    self.class.subStreamFps = [self _subStreamFpsFromIndex:fpsIndex];
    [self _subStram_updateVideoConfig];
}

// 比特率选则
- (IBAction)subStram_selectBitrate:(id)sender {
    NSSlider *slider = sender;
    int value = slider.intValue;
    [self _subStream_setBitRate: value];
}

- (void)_subStram_updateVideoConfig {
    NSInteger resolutionIndex = [self.substreamResolutionItems indexOfSelectedItem];
    
    TRTCVideoEncParam *config = [TRTCVideoEncParam new];
    config.videoBitrate = self.substreamBitrateSlider.intValue;
    config.videoResolution = [self _subResolutionFromIndex:resolutionIndex];
    
    NSInteger fpsIndex = self.substreamFpsItems.indexOfSelectedItem;
    int fps = 0;
    if (fpsIndex == 0) {
        fps = 10;
    } else if (fpsIndex == 1) {
        fps = 15;
    } else if (fpsIndex == 2) {
        fps = 20;
    } else {
        fps = 24;
    }

    config.videoFps =  fps;
    [self.trtcEngine setSubStreamEncoderParam:config];
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
