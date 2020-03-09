//
//  TRTCSettingWindowController.h
//  TXLiteAVMacDemo
//
//  Created by ericxwli on 2018/10/17.
//  Copyright © 2018年 Tencent. All rights reserved.
//

// 用于对视频通话的分辨率、帧率和流畅模式进行调整，并支持记录下这些设置项

#import <Cocoa/Cocoa.h>
#import "SDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TXAVSettingTabIndex) {
    TXAVSettingTabIndexGeneral,
    TXAVSettingTabIndexVideo,
    TXAVSettingTabIndexAudio
};

@interface TRTCSettingWindowController : NSWindowController
@property (class, readonly) int fps;
@property (class, readonly) TRTCVideoResolution resolution;
@property (class, readonly) int bitrate;
@property (class, readonly) TRTCVideoResolutionMode resolutionMode;
@property (class, readonly) TRTCVideoQosPreference qosPreference;
@property (class, readonly) TRTCQosControlMode qosControlMode;
@property (class, readonly) BOOL isAudience;

@property (class, readonly) BOOL pushDoubleStream;
@property (class, readonly) BOOL playSmallStream;
@property (class, readonly) TRTCAppScene scene;
@property (class, readonly) BOOL showVolume;
@property (class, readonly) TRTCTranscodingConfigMode mixMode;


@property (nonatomic, strong, nullable) NSString *userID;
@property (nonatomic, strong, nullable) NSString *roomID;

// 通话场景按钮
@property (strong) IBOutlet NSButton *callSceneButton;
// 直播场景按钮
@property (strong) IBOutlet NSButton *liveSceneButton;

// 优先流畅按钮
@property (strong) IBOutlet NSButton *smoothBtn;
// 优先清晰按钮
@property (strong) IBOutlet NSButton *clearBtn;

// 客户端控
@property (strong) IBOutlet NSButton *clientBtn;
// 云控
@property (strong) IBOutlet NSButton *cloudBtn;

// 横屏
@property (strong) IBOutlet NSButton *portraitResolutionBtn;
@property (strong) IBOutlet NSButton *landscapeResolutionBtn;
// 竖屏

// 通用设置界面
@property (strong) IBOutlet NSView *generalSettingView;

// 音频设置界面
@property (strong) IBOutlet NSView *audioSettingView;
// 视频设置界面
@property (strong) IBOutlet NSView *videoSettingView;
// 设置界面容器
@property (strong) IBOutlet NSView *settingField;
// 视频设置界面预览视图
@property (strong) IBOutlet NSView *cameraPreview;
// 左边菜单
@property (strong) IBOutlet NSTableView *sidebarMenu;
// 当前选中视频还是音频
@property (assign, nonatomic) TXAVSettingTabIndex tabIndex;
// 摄像头选择控件
@property (strong) IBOutlet NSPopUpButton *cameraItems;
// 扬声器选择控件
@property (strong) IBOutlet NSPopUpButton *speakerItems;
// 麦克风选择控件
@property (strong) IBOutlet NSPopUpButton *micItems;
// 分辨率选择控件
@property (strong) IBOutlet NSPopUpButton *resolutionItems;
// fps选择控件
@property (strong) IBOutlet NSPopUpButton *fpsItems;
// 码率显示
@property (strong) IBOutlet NSTextField *bitrateLabel;
// 码率滑杆
@property (strong) IBOutlet NSSlider *bitrateSlider;
// 麦克风音量滑杆
@property (strong) IBOutlet NSSlider *micVolumeSlider;
// 扬声器音量滑杆
@property (strong) IBOutlet NSSlider *speakerVolumeSlider;
// 录音音量指示器
@property (weak) IBOutlet NSLevelIndicator *volumeMeter;
// 扬声器音量指示器
@property (weak) IBOutlet NSLevelIndicator *speakerVolumeMeter;
// 分享按钮
@property (weak) IBOutlet NSButton *shareButton;
// 设置BGM播放音量
@property (strong) IBOutlet NSSlider *BGMVolumeSlider;
// 设置BGM远端播放音量
@property (strong) IBOutlet NSSlider *BGMPublishVolumeSlider;
// 设备BGM本地播放音量
@property (strong) IBOutlet NSSlider *BGMPlayoutVolumeSlider;

// For Cocoa Bindings
// 推流设置
@property (assign, nonatomic) BOOL pushDoubleStream;
@property (assign, nonatomic) BOOL playSmallStream;
@property (assign, nonatomic) BOOL showVolume;
// 开启云端混流
@property (assign, nonatomic) TRTCTranscodingConfigMode mixMode;
@property (assign, nonatomic) BOOL isAudience;

- (instancetype)initWithWindowNibName:(NSNibName)windowNibName engine:(TRTCCloud *)engine;

- (IBAction)onSelectScene:(NSButton *)sender;

- (IBAction)onRoleBtnClicked:(NSButton *)sender;

- (IBAction)onSelectResolutionMode:(NSButton *)sender;

- (IBAction)onSelectCamera:(id)sender;

- (IBAction)onSelectSpeaker:(id)sender;

- (IBAction)onSelectMic:(id)sender;
// 更改扬声器音量
- (IBAction)onSpeakerVolumChange:(id)sender;
// 更改麦克风音量
- (IBAction)onMicVolumChange:(id)sender;
// 分辨率选则
- (IBAction)onSelectResolution:(id)sender;
// 帧率选则
- (IBAction)onSelectFps:(NSPopUpButton *)sender;
// 比特率选则
- (IBAction)onSelectBitrate:(id)sender;
// 麦克风测试
- (IBAction)onClickMicTest:(id)sender;
// 开始扬声器测试
- (IBAction)onClickSpeakerTest:(NSButton *)sender;
// 更改流控模式，流畅还是清晰
- (IBAction)onClickQOSPreference:(NSButton *)sender;
//  更改流控方式，使用SDK固定配置还是使用下发配置
- (IBAction)onClickQOSControlMode:(NSButton *)sender;
// 响应分享播放地址按钮
- (IBAction)onClickShowCloudMixURL:(id)sender;
@end

NS_ASSUME_NONNULL_END
