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

#define DECL_DEFAULT_KEY(type, x) \
static NSString * const DefaultKey##x = @"TRTC_"#x; \
static type s_##x; \
NS_INLINE void setGlobalDefault##x(type value) { \
s_##x = value; \
} \
NS_INLINE type getGlobalDefault##x(void) { \
return s_##x; \
}

#define DEFAULT_GETTER_KEY_PAIR(key) getGlobalDefault##key, (__bridge void *)DefaultKey##key
#define DEFAULT_SETTER_KEY_PAIR(key) setGlobalDefault##key, (__bridge void *)DefaultKey##key

// 去掉未使用的方法警告
#define UNUSED_ACCESSOR(type, x) \
static type getGlobalDefault##x(void) __attribute__((unused)); \
static void setGlobalDefault##x(type) __attribute__((unused));

UNUSED_ACCESSOR(BOOL, ShouldSaveToDefaults)

// 生成配置项的UserDefaults Key以及对应的accessor
// 大小流
DECL_DEFAULT_KEY(int, Fps)
DECL_DEFAULT_KEY(TRTCVideoResolution, Resolution)
DECL_DEFAULT_KEY(int, Bitrate)
DECL_DEFAULT_KEY(TRTCVideoQosPreference, QosPreference)
DECL_DEFAULT_KEY(TRTCQosControlMode, QosControlMode)

// 是否保存配置。当设置为不保存时应用退出后所有设置将被恢复
DECL_DEFAULT_KEY(BOOL, ShouldSaveToDefaults)

// 辅流配置
DECL_DEFAULT_KEY(int, SubStreamFps)
DECL_DEFAULT_KEY(TRTCVideoResolution, SubStreamResolution)
DECL_DEFAULT_KEY(TRTCVideoQosPreference, SubStreamBitrate)

// 推拉流类型配置
DECL_DEFAULT_KEY(int, PushDoubleStream)
DECL_DEFAULT_KEY(int, PlaySmallStream)

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
    NSArray<NSArray<NSString*>*>* _menu;
}
@property (nonatomic, strong) TRTCCloud *trtcEngine;
@property (nonatomic, readonly) BOOL shouldSaveToDefaults;
@end

@implementation TRTCSettingWindowController
+ (void)load {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:@{
                                 DefaultKeyShouldSaveToDefaults: @(YES),
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
                                 }];
    void * pairs[] = {
        DEFAULT_SETTER_KEY_PAIR(Fps),
        DEFAULT_SETTER_KEY_PAIR(Resolution),
        DEFAULT_SETTER_KEY_PAIR(Bitrate),
        DEFAULT_SETTER_KEY_PAIR(QosPreference),
        DEFAULT_SETTER_KEY_PAIR(QosControlMode),
        DEFAULT_SETTER_KEY_PAIR(SubStreamFps),
        DEFAULT_SETTER_KEY_PAIR(SubStreamResolution),
        DEFAULT_SETTER_KEY_PAIR(SubStreamBitrate),
        DEFAULT_SETTER_KEY_PAIR(PushDoubleStream),
        DEFAULT_SETTER_KEY_PAIR(PlaySmallStream),
        NULL
    };
    int i = 0;
    while (pairs[i] != NULL) {
        void(*setter)(int) = (void(*)(int))pairs[i];
        NSString *key = (__bridge NSString *)pairs[i+1];
        setter((int)[defaults integerForKey:key]);
        i+=2;
    }
}

- (instancetype)initWithWindowNibName:(NSNibName)windowNibName engine:(TRTCCloud *)engine {
    if (self = [super initWithWindowNibName:windowNibName]) {
        self.trtcEngine = engine;
        _menu = @[@[@"视频", @"video_on"], @[@"音频", @"audio"], @[@"辅流", @""]];
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

-(void)windowWillClose:(NSNotification *)notification{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DefaultKeyShouldSaveToDefaults]) {
        [self _writeSettingsToUserDefaults];
    }
}

#pragma mark - Class Properties
#pragma mark Main Stream
+ (int)fps {
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:DefaultKeyFps];
}

+ (TRTCVideoResolution)resolution {
    return getGlobalDefaultResolution();
}

+ (int)bitrate {
    return getGlobalDefaultBitrate();
}

+ (TRTCVideoQosPreference)qosControlPreference {
    return getGlobalDefaultQosPreference();
}

+ (TRTCQosControlMode)qosControlMode {
    return getGlobalDefaultQosControlMode();
}

#pragma mark Sub Stream
+ (int)subStreamFps {
    return getGlobalDefaultSubStreamFps();
}

+ (TRTCVideoResolution)subStreamResolution {
    return getGlobalDefaultSubStreamResolution();
}

+ (int)subStreamBitrate {
    return getGlobalDefaultSubStreamBitrate();
}

#pragma mark Push & Play

+ (BOOL)pushDoubleStream {
    return getGlobalDefaultPushDoubleStream();
}

+ (BOOL)playSmallStream {
    return getGlobalDefaultPlaySmallStream();
}


#pragma mark - Accessors
- (BOOL)shouldSaveToDefaults {
    return [[NSUserDefaults standardUserDefaults] boolForKey:DefaultKeyShouldSaveToDefaults];
}

- (void)setPlaySmallStream:(BOOL)playSmallStream {
    setGlobalDefaultPlaySmallStream(playSmallStream);
}

- (BOOL)playSmallStream {
    return getGlobalDefaultPlaySmallStream();
}

- (void)setPushDoubleStream:(BOOL)pushDoubleStream {
    setGlobalDefaultPushDoubleStream(pushDoubleStream);
}

- (BOOL)pushDoubleStream {
    return getGlobalDefaultPushDoubleStream();
}

#pragma mark - Defaults Writer
- (void)_writeSettingsToUserDefaults {
    [self.trtcEngine stopCameraDeviceTest];
    [self.trtcEngine stopMicDeviceTest];
    if (self.shouldSaveToDefaults) {
        void *intValueAndKeys[] = {
            DEFAULT_GETTER_KEY_PAIR(Fps),
            DEFAULT_GETTER_KEY_PAIR(Bitrate),
            DEFAULT_GETTER_KEY_PAIR(QosPreference),
            DEFAULT_GETTER_KEY_PAIR(QosControlMode),
            DEFAULT_GETTER_KEY_PAIR(Resolution),
            DEFAULT_GETTER_KEY_PAIR(SubStreamFps),
            DEFAULT_GETTER_KEY_PAIR(SubStreamResolution),
            DEFAULT_GETTER_KEY_PAIR(SubStreamBitrate),
            DEFAULT_GETTER_KEY_PAIR(PushDoubleStream),
            DEFAULT_GETTER_KEY_PAIR(PlaySmallStream),
            NULL
        };
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        int i = 0;
        while (1) {
            if (intValueAndKeys[i] == NULL) {
                break;
            }
            
            int(*valueFunc)(void) = (int(*)(void))intValueAndKeys[i];
            NSString *key = (__bridge NSString *)intValueAndKeys[i+1];
            [defaults setInteger:valueFunc() forKey:key];
            i += 2;
        };
        [defaults synchronize];
    }

}

#pragma mark - UI Setup
- (void)setup {
    self.window.titleVisibility = NSWindowTitleHidden;
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
    
    [self _setBitRate:[[self class] bitrate]];

    // 配置fps
    [self.fpsItems removeAllItems];
    [self.fpsItems addItemsWithTitles:fpsArr];
    [self.fpsItems selectItemAtIndex:[fpsArr indexOfObject:[NSString stringWithFormat:@"%dfps", [[self class] fps]]]];
    
    // 辅流
    [self.substreamResolutionItems removeAllItems];
    [self.substreamResolutionItems addItemsWithTitles:resolutionArr];
    [self.substreamResolutionItems selectItemAtIndex:[resolutionArr indexOfObject:[self resolutionString:[[self class] subStreamResolution]]]];
    
    [self.substreamFpsItems removeAllItems];
    [self.substreamFpsItems addItemsWithTitles: [@[@"10fps"] arrayByAddingObjectsFromArray:fpsArr]];
    [self.substreamFpsItems selectItemAtIndex:[self.substreamFpsItems.itemTitles indexOfObject:[NSString stringWithFormat:@"%dfps", [[self class] subStreamFps]]]];

    self.substreamBitrateSlider.intValue = [self.class subStreamBitrate];
    
    // 配置音量
    self.micVolumeSlider.floatValue = [self.trtcEngine getCurrentMicDeviceVolume];
    self.speakerVolumeSlider.floatValue = [self.trtcEngine getCurrentSpeakerDeviceVolume];
    
    // 配置清晰流畅
    if (TRTCSettingWindowController.qosControlPreference == TRTCVideoQosPreferenceSmooth) {
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
    [self.settingField addSubview:self.videoSettingView];
    [self.settingField addSubview:self.audioSettingView];
    [self.settingField addSubview:self.subStreamSettingView];

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


- (void)_configureSidebarMenu {
    self.videoSettingView.hidden     = YES;
    self.audioSettingView.hidden     = YES;
    self.subStreamSettingView.hidden = YES;
    
    switch(_tabIndex) {
        case TXAVSettingTabIndexAudio: {
            self.audioSettingView.hidden = NO;
            [self.sidebarMenu selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];
        } break;
        case TXAVSettingTabIndexVideo: {
            self.videoSettingView.hidden = NO;
            [self.sidebarMenu selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
            [self.trtcEngine stopMicDeviceTest];
            [self.trtcEngine stopSpeakerDeviceTest];
        } break;
        case TXAVSettingTabIndexSubStream: {
            self.subStreamSettingView.hidden = NO;
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
    setGlobalDefaultResolution([self _resolutionFromIndex:index]);
    [self _updateVideoQuality];
}

- (void)_setBitRate:(double)bitrate {
    NSInteger index = self.resolutionItems.indexOfSelectedItem;
    TRTCSettingBitrateTable *config = _paramArray[index];
    double value = CLAMP(bitrate, config.minBitrate, config.maxBitrate);
    self.bitrateSlider.doubleValue = value;
    self.bitrateLabel.stringValue = [NSString stringWithFormat:@"%.0lfkbps", value];
    setGlobalDefaultBitrate(value);
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
    setGlobalDefaultFps(fps);
    [self _updateVideoQuality];
}

// 比特率选则
- (IBAction)selectBitrate:(id)sender {
    NSSlider *slider = sender;
    int value = slider.intValue;
    setGlobalDefaultBitrate(value);
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
- (IBAction)onChangeQOSPreference:(NSButton *)sender {
    TRTCVideoQosPreference preference = sender.tag == 0 ? TRTCVideoQosPreferenceSmooth : TRTCVideoQosPreferenceClear;
    setGlobalDefaultQosPreference(preference);
    [self _updateQOSParam];
}

//  更改流控方式，使用SDK固定配置还是使用下发配置
- (IBAction)onChangeQOSControlMode:(NSButton *)sender {
    TRTCQosControlMode mode = sender.tag == 0 ? TRTCQosControlModeClient : TRTCQosControlModeServer;
    setGlobalDefaultQosControlMode(mode);
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
    config.videoResolution = [self _resolutionFromIndex:resolutionIndex];
    config.videoFps = TRTCSettingWindowController.fps;
    
    [self.trtcEngine setVideoEncoderParam:config];
}
- (void)_updateQOSParam {
    TRTCNetworkQosParam *param = [[TRTCNetworkQosParam alloc] init];
    param.preference = getGlobalDefaultQosPreference();
    param.controlMode = getGlobalDefaultQosControlMode();
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
    NSInteger index = self.resolutionItems.indexOfSelectedItem;
    setGlobalDefaultSubStreamResolution([self _resolutionFromIndex:index]);
    [self _subStram_updateVideoQuality];
}

- (void)_subStream_setBitRate:(double)bitrate {
    NSInteger index = self.resolutionItems.indexOfSelectedItem;
    TRTCSettingBitrateTable *config = _paramArray[index];
    double value = CLAMP(bitrate, config.minBitrate, config.maxBitrate);
    self.substreamBitrateSlider.minValue = config.minBitrate;
    self.substreamBitrateSlider.maxValue = config.maxBitrate;
    setGlobalDefaultSubStreamBitrate(value);
    self.substreamBitrateSlider.doubleValue = value;
    self.substreamBitrateLabel.stringValue = [NSString stringWithFormat:@"%.0lfkbps", value];
    [self _subStram_updateVideoQuality];

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
    setGlobalDefaultSubStreamFps([self _subStreamFpsFromIndex:fpsIndex]);
    [self _subStram_updateVideoQuality];
}

// 比特率选则
- (IBAction)subStram_selectBitrate:(id)sender {
    NSSlider *slider = sender;
    int value = slider.intValue;
    [self _subStream_setBitRate: value];
}

- (void)_subStram_updateVideoQuality {
    NSInteger resolutionIndex = [self.substreamResolutionItems indexOfSelectedItem];
    
    TRTCVideoEncParam *config = [TRTCVideoEncParam new];
    config.videoBitrate = self.substreamBitrateSlider.intValue;
    config.videoResolution = [self _resolutionFromIndex:resolutionIndex];
    
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
