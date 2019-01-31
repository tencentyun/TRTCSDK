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
    TXAVSettingTabIndexVideo,
    TXAVSettingTabIndexAudio,
    TXAVSettingTabIndexSubStream
};

@interface TRTCSettingWindowController : NSWindowController
@property (class, readonly) int fps;
@property (class, readonly) TRTCVideoResolution resolution;
@property (class, readonly) int bitrate;
@property (class, readonly) TRTCVideoQosPreference qosControlPreference;
@property (class, readonly) TRTCQosControlMode qosControlMode;

@property (class, readonly) int subStreamFps;
@property (class, readonly) TRTCVideoResolution subStreamResolution;
@property (class, readonly) int subStreamBitrate;

@property (class, readonly) BOOL pushDoubleStream;
@property (class, readonly) BOOL playSmallStream;


// 音频设置界面
@property (strong) IBOutlet NSView *audioSettingView;
// 视频设置界面
@property (strong) IBOutlet NSView *videoSettingView;
// 辅流设置界面
@property (strong) IBOutlet NSView *subStreamSettingView;
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

// 流畅按钮
@property (strong) IBOutlet NSButton *smoothBtn;
// 清晰按钮
@property (strong) IBOutlet NSButton *clearBtn;

// 客户端
@property (strong) IBOutlet NSButton *clientBtn;
// 云控
@property (strong) IBOutlet NSButton *cloudBtn;

// 辅流分辨率选择控件
@property (strong) IBOutlet NSPopUpButton *substreamResolutionItems;
// 辅流fps选择控件
@property (strong) IBOutlet NSPopUpButton *substreamFpsItems;
// 辅流码率显示
@property (strong) IBOutlet NSTextField *substreamBitrateLabel;
// 辅流码率滑杆
@property (strong) IBOutlet NSSlider *substreamBitrateSlider;

// 推流设置
@property (assign, nonatomic) BOOL pushDoubleStream;
@property (assign, nonatomic) BOOL playSmallStream;

- (instancetype)initWithWindowNibName:(NSNibName)windowNibName engine:(TRTCCloud *)engine;

// 更改流控模式，流畅还是清晰
- (IBAction)onChangeQOSPreference:(NSButton *)sender;

//  更改流控方式，使用SDK固定配置还是使用下发配置
- (IBAction)onChangeQOSControlMode:(NSButton *)sender;
@end

NS_ASSUME_NONNULL_END
