//
//  TRTCSettingWindowController.h
//  TXLiteAVMacDemo
//
//  Created by ericxwli on 2018/10/17.
//  Copyright © 2018年 Tencent. All rights reserved.
//

// 用于对视频通话的分辨率、帧率和流畅模式进行调整，并支持记录下这些设置项

#import <Cocoa/Cocoa.h>
#import "TRTCCloud.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TXAVSettingTabIndex) {
    TXAVSettingTabIndexVideo,
    TXAVSettingTabIndexAudio
};

@interface TRTCSettingWindowController : NSWindowController
@property (class, readonly) int fps;
@property (class, readonly) TRTCVideoResolution resolution;
@property (class, readonly) int bitrate;
@property (class, readonly) TRTCVideoQosPreference qosControlPreference;
@property (class, readonly) TRTCQosMode qosControlMode;

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

// 流畅按钮
@property (strong) IBOutlet NSButton *smoothBtn;
// 清晰按钮
@property (strong) IBOutlet NSButton *clearBtn;

// 客户端
@property (strong) IBOutlet NSButton *clientBtn;
// 云控
@property (strong) IBOutlet NSButton *cloudBtn;

- (instancetype)initWithWindowNibName:(NSNibName)windowNibName engine:(TRTCCloud *)engine;

@end

NS_ASSUME_NONNULL_END
