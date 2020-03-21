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
#import "GenerateTestUserSig.h"
#import <objc/message.h>
#import <CommonCrypto/CommonCrypto.h>

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

@interface TRTCSettingWindowController () <NSTableViewDelegate,NSTableViewDataSource,NSWindowDelegate, NSSharingServicePickerDelegate>
{
    NSArray<TRTCSettingBitrateTable *> *_paramArray;

    NSArray<NSArray<NSString*>*>* _menu;
}
@property (nonatomic, strong) TRTCCloud *trtcEngine;
@property (nonatomic, readonly) BOOL shouldSaveToDefaults;
@property (weak) IBOutlet NSBox *roleBox;
@property (weak) IBOutlet NSButton *radioAnchor;
@property (weak) IBOutlet NSButton *radioAudience;
@end

@implementation TRTCSettingWindowController

// 生成配置项的UserDefaults Key以及对应的accessor

// 场景
DECL_DEFAULT_KEY(TRTCAppScene, Scene, scene)

// 是否显示音量
DECL_DEFAULT_KEY(BOOL, ShowVolume, showVolume)
// 是否开启云端画面混合
DECL_DEFAULT_KEY(TRTCTranscodingConfigMode, MixMode, mixMode)
// 是否观众角色
DECL_DEFAULT_KEY(BOOL, IsAudience, isAudience)
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

                                 DefaultKeyIsAudience: @(NO),
                                 DefaultKeyResolutionMode: @(TRTCVideoResolutionModeLandscape),
                                 DefaultKeyMixMode: @(0),
                                 
                                 DefaultKeyFps : @(15),
                                 DefaultKeyResolution: @(TRTCVideoResolution_640_480),
                                 DefaultKeyBitrate: @500,
                                 DefaultKeyQosPreference: @(TRTCVideoQosPreferenceSmooth),
                                 DefaultKeyQosControlMode: @(TRTCQosControlModeServer),
                                 
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
        _menu = @[@[@"常规设置", @"settings_general"], @[@"视频设置", @"settings_video"], @[@"声音设置", @"settings_audio"]];
        _tabIndex = TXAVSettingTabIndexGeneral;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.shareButton sendActionOn:NSLeftMouseDownMask];
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
    [self _updateVideoConfig];
}

- (BOOL)playSmallStream {
    return self.class.playSmallStream;
}

- (void)setPushDoubleStream:(BOOL)pushDoubleStream {
    self.class.pushDoubleStream = pushDoubleStream;
    [self _updateVideoConfig];
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

- (void)setMixMode:(TRTCTranscodingConfigMode)mixMode {
    NSString *key = NSStringFromSelector(@selector(mixMode));
    [self.class willChangeValueForKey:key];
    self.class.mixMode = mixMode;
    [self.class didChangeValueForKey:key];
}

- (TRTCTranscodingConfigMode)mixMode {
    return self.class.mixMode;
}

- (void)setIsAudience:(BOOL)isAudience
{
    NSString *key = NSStringFromSelector(@selector(isAudience));
    [self.class willChangeValueForKey:key];
    self.class.isAudience = isAudience;
    [self.class didChangeValueForKey:key];
}

- (BOOL)isAudience
{
    return self.class.isAudience;
}

#pragma mark - Defaults Writer
- (void)_writeSettingsToUserDefaults {
    [self.trtcEngine stopCameraDeviceTest];
    [self.trtcEngine stopMicDeviceTest];
    if (self.shouldSaveToDefaults) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        for (NSString *key in defaultKeys) {
            if ([key isEqualToString:DefaultKeyShouldSaveToDefaults]) {
                continue;
            }
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
    
    _paramArray = @[[[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_160_160 defaultBitrate:150 minBitrate:40 maxBitrate:120 step:10],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_320_180 defaultBitrate:250 minBitrate:80 maxBitrate:240 step:10],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_320_240 defaultBitrate:300 minBitrate:100 maxBitrate:300 step:10],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_480_480 defaultBitrate:400 minBitrate:200 maxBitrate:1000 step:10],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_640_360 defaultBitrate:500 minBitrate:200 maxBitrate:1000 step:10],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_640_480 defaultBitrate:600 minBitrate:250 maxBitrate:1000 step:50],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_960_540 defaultBitrate:800 minBitrate:400 maxBitrate:1600 step:50],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_1280_720 defaultBitrate:1150 minBitrate:500 maxBitrate:2000 step:50]];
    
    // 配置场景
    if (self.class.scene == TRTCAppSceneVideoCall) {
        self.callSceneButton.state = NSOnState;
        self.roleBox.hidden = YES;
    } else {
        self.liveSceneButton.state = NSOnState;
        self.roleBox.hidden = NO;
        self.radioAnchor.state = TRTCSettingWindowController.isAudience ? NSOffState : NSOnState;
        self.radioAudience.state = TRTCSettingWindowController.isAudience ? NSOnState : NSOffState;
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
    for (NSView *v in @[self.generalSettingView, self.videoSettingView, self.audioSettingView]) {
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
- (IBAction)onSelectScene:(NSButton *)sender {
    self.class.scene = ((TRTCAppScene)sender.tag);
    if (self.class.scene == TRTCAppSceneVideoCall) {
        self.roleBox.hidden = YES;
    }
    else {
        self.roleBox.hidden = NO;
        self.radioAnchor.state = NSControlStateValueOn;
    }
}
- (IBAction)onRoleBtnClicked:(NSButton *)sender {
    if (sender == self.radioAnchor) {
        self.radioAudience.state = NSControlStateValueOff;
        self.isAudience = NO;
    }
    else if (sender == self.radioAudience) {
        self.radioAnchor.state = NSControlStateValueOff;
        self.isAudience = YES;
    }
}

- (IBAction)onSelectResolutionMode:(NSButton *)sender {
    TRTCVideoResolutionMode mode = (TRTCVideoResolutionMode)sender.tag;
    if (mode != self.class.resolutionMode) {
        self.class.resolutionMode = mode;
        [self _updateVideoConfig];
    }
}

- (IBAction)onSelectCamera:(id)sender {
    NSInteger index = [sender indexOfSelectedItem];
    TRTCMediaDeviceInfo *selecteDevice = [self.trtcEngine getCameraDevicesList][index];
    [self.trtcEngine setCurrentCameraDevice:selecteDevice.deviceId];
}

- (IBAction)onSelectSpeaker:(id)sender {
    NSInteger index = [sender indexOfSelectedItem];
    TRTCMediaDeviceInfo *selecteDevice = [self.trtcEngine getSpeakerDevicesList][index];
    [self.trtcEngine setCurrentSpeakerDevice:selecteDevice.deviceId];
}

- (IBAction)onSelectMic:(id)sender {
    NSInteger index = [sender indexOfSelectedItem];
    TRTCMediaDeviceInfo *selecteDevice = [self.trtcEngine getMicDevicesList][index];
    [self.trtcEngine setCurrentMicDevice:selecteDevice.deviceId];
}

// 更改扬声器音量
- (IBAction)onSpeakerVolumChange:(id)sender {
    NSSlider *slider = sender;
    float fvalue = slider.floatValue;
    [self.trtcEngine setCurrentSpeakerDeviceVolume:fvalue * 100];
}

// 更改麦克风音量
- (IBAction)onMicVolumChange:(id)sender {
    NSSlider *slider = sender;
    float fvalue = slider.floatValue;
    [self.trtcEngine setCurrentMicDeviceVolume:fvalue * 100];
}

// 分辨率选则
- (IBAction)onSelectResolution:(id)sender {
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
- (IBAction)onSelectFps:(NSPopUpButton *)sender {
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
- (IBAction)onSelectBitrate:(id)sender {
    NSSlider *slider = sender;
    int value = slider.intValue;
    self.class.bitrate = value;
    self.bitrateLabel.stringValue = [NSString stringWithFormat:@"%dkbps",value];
    [self _updateVideoConfig];
}

// 麦克风测试
- (IBAction)onClickMicTest:(id)sender {
    NSButton *btn = (NSButton *)sender;
    if (btn.state == 1) {
        __weak __typeof(self) wself = self;
        [self.trtcEngine startMicDeviceTest:300  testEcho:^(NSInteger volume) {
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
- (IBAction)onClickSpeakerTest:(NSButton *)sender {
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

- (IBAction)onPlayBGM:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"bgm_demo" ofType:@"mp3"];

    [self.trtcEngine setBGMVolume:(self.BGMVolumeSlider.floatValue * 100)];
    [self.trtcEngine setBGMPublishVolume:(self.BGMPublishVolumeSlider.floatValue * 100)];
    [self.trtcEngine setBGMPlayoutVolume:(self.BGMPlayoutVolumeSlider.floatValue * 100)];
    
    [self.trtcEngine playBGM:path withBeginNotify:^(NSInteger errCode) {
        
    } withProgressNotify:^(NSInteger progressMS, NSInteger durationMS) {
        
    } andCompleteNotify:^(NSInteger errCode) {
        
    }];
}

- (IBAction)onStopBGM:(id)sender {
    [self.trtcEngine stopBGM];
}

- (IBAction)onSetBGMVolume:(id)sender {
    NSSlider *slider = sender;
    [self.trtcEngine setBGMVolume:(slider.floatValue * 100)];
    self.BGMPublishVolumeSlider.floatValue = slider.floatValue;
    self.BGMPlayoutVolumeSlider.floatValue = slider.floatValue;
}

- (IBAction)onSetBGMPublishVolume:(id)sender {
    NSSlider *slider = sender;
    [self.trtcEngine setBGMPublishVolume:(slider.floatValue * 100)];
}

- (IBAction)onSetBGMPlayoutVolume:(id)sender {
    NSSlider *slider = sender;
    [self.trtcEngine setBGMPlayoutVolume:(slider.floatValue * 100)];
}

// 更改流控模式，流畅还是清晰
- (IBAction)onClickQOSPreference:(NSButton *)sender {
    TRTCVideoQosPreference preference = sender.tag == 0 ? TRTCVideoQosPreferenceSmooth : TRTCVideoQosPreferenceClear;
    self.class.qosPreference = preference;
    [self _updateQOSParam];
}

//  更改流控方式，使用SDK固定配置还是使用下发配置
- (IBAction)onClickQOSControlMode:(NSButton *)sender {
    TRTCQosControlMode mode = sender.tag == 0 ? TRTCQosControlModeClient : TRTCQosControlModeServer;
    self.class.qosControlMode = mode;
    [self _updateQOSParam];
}

- (IBAction)onClickShowCloudMixURL:(NSButton *)sender {
    if (self.roomID == nil || self.userID == nil) {
        NSAlert *alert = [NSAlert alertWithError:[NSError errorWithDomain:self.className
                                                    code:-1
                                                userInfo:@{NSLocalizedDescriptionKey:@"请先进入房间"}]];
        [alert runModal];
        return;
    }
    
    NSString* streamId = [NSString stringWithFormat:@"%@_%@_%@_main", @(_SDKAppID), self.roomID, self.userID];
    NSString* playUrl = [NSString stringWithFormat:@"http://3891.liveplay.myqcloud.com/live/%@.flv", streamId];
    
    NSSharingServicePicker *picker = [[NSSharingServicePicker alloc] initWithItems:@[playUrl]];
    picker.delegate = self;
    [picker showRelativeToRect:sender.bounds ofView:sender preferredEdge:NSRectEdgeMaxX];
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"混流地址";
    alert.informativeText = playUrl;
    [alert runModal];
}

- (IBAction)onClickMixModeButton:(NSPopUpButton *)button {
    self.mixMode = button.indexOfSelectedItem;
}

#pragma mark - NSSharingServicePickerDelegate
- (NSArray<NSSharingService *> *)sharingServicePicker:(NSSharingServicePicker *)sharingServicePicker sharingServicesForItems:(NSArray *)items proposedSharingServices:(NSArray<NSSharingService *> *)proposedServices
{
    NSImage *image = [NSImage imageNamed:@"copy"];
    if (nil == image){
        return proposedServices;
    }
    NSMutableArray<NSSharingService *> * share = [proposedServices mutableCopy];
    NSSharingService *service = [[NSSharingService alloc] initWithTitle:@"复制" image:image alternateImage:image handler:^{
        [[NSPasteboard generalPasteboard] clearContents];
        NSString *urlString = items.firstObject;
        if (urlString) {
            [[NSPasteboard generalPasteboard] setString:urlString forType:NSPasteboardTypeString];
        }
    }];
    [share insertObject:service atIndex:0];

    return share;
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
- (void)_updateVideoConfig {
    NSInteger resolutionIndex = [self.resolutionItems indexOfSelectedItem];
    
    TRTCVideoEncParam *config = [TRTCVideoEncParam new];
    config.videoBitrate = TRTCSettingWindowController.bitrate ;
    config.videoResolution = [self _resolutionFromIndex:resolutionIndex];
    config.videoFps = TRTCSettingWindowController.fps;
    config.resMode = TRTCSettingWindowController.resolutionMode;
    [self.trtcEngine setVideoEncoderParam:config];
    
    if (TRTCSettingWindowController.pushDoubleStream) {
        TRTCVideoEncParam *smallVideoConfig = [[TRTCVideoEncParam alloc] init];
        smallVideoConfig.videoResolution = TRTCVideoResolution_160_120;
        smallVideoConfig.videoFps = 15;
        smallVideoConfig.videoBitrate = 100;
        smallVideoConfig.resMode = TRTCSettingWindowController.resolutionMode;
        [self.trtcEngine enableEncSmallVideoStream:TRTCSettingWindowController.pushDoubleStream
                                       withQuality:smallVideoConfig];
    } else {
        [self.trtcEngine enableEncSmallVideoStream:NO withQuality:nil];
    }
    
    [self.trtcEngine setPriorRemoteVideoStreamType:TRTCSettingWindowController.playSmallStream
        ? TRTCVideoStreamTypeSmall
        : TRTCVideoStreamTypeBig];
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
