/*
 * Module:   TRTCMainWindowController
 *
 * Function: 使用TRTC SDK完成 1v1 和 1vn 的视频通话功能
 *
 *    1. 支持九宫格平铺和前后叠加两种不同的视频画面布局方式，该部分由 _layoutInBounds 方法来计算每个视频画面的位置排布和大小尺寸
 *
 *    2. 支持对视频通话的分辨率、帧率和流畅模式进行调整，该部分由 TRTCSettingViewController 来实现
 *
 *    3. 创建或者加入某一个通话房间，需要先指定 roomid 和 userid，这部分由 TRTCNewViewController 来实现
 */

#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>
#import "TRTCCloud.h"
NS_ASSUME_NONNULL_BEGIN

@interface TRTCMainWindowController : NSWindowController

/// 视频开关
@property (strong) IBOutlet NSButton *videoBtn;

/// 静音按钮
@property (strong) IBOutlet NSButton *micBtn;

/// 底部工具栏
@property (strong) IBOutlet NSView *controlBar;

/// 音频设备选则列表
@property (strong) IBOutlet NSTableView *audioSelectView;

/// 视频设备选则列表
@property (strong) IBOutlet NSTableView *videoSelectView;

/// 弹出视频设备选则列表按钮
@property (strong) IBOutlet NSButton *videoSelectBtn;

/// 弹出音频设备选则列表按钮
@property (strong) IBOutlet NSButton *audioSelectBtn;

/// 退房按钮
@property (strong) IBOutlet NSButton *closeBtn;

/// 布局切换按钮（九宫格 OR 前后叠加）
@property (strong) IBOutlet NSButton *videoLayoutStyleBtn;

/// 日志按钮
@property (strong) IBOutlet NSButton *logBtn;

/// 美颜窗口
@property (strong) IBOutlet NSPanel *beautyPanel;

/// 美颜按钮
@property (strong) IBOutlet NSButton *beautyBtn;

///是否开启美颜（磨皮）
@property BOOL beautyEnabled;

// 以下为美颜参数
@property NSInteger beautyLevel;
@property NSInteger rednessLevel;
@property NSInteger whitenessLevel;
@property TRTCBeautyStyle beautyStyle;


- (instancetype)initWithParams:(TRTCParams *)params;
@end

NS_ASSUME_NONNULL_END
