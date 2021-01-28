//
//  TXLiteAVRoomWC.m
//  TXLiteAVMacDemo
//
//  Created by ericxwli on 2018/10/10.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TRTCMainWindowController.h"
#import "SDKHeader.h"
#import <AVFoundation/AVFoundation.h>
#import "TXCaptureSourceWindowController.h"
#import "TRTCSettingWindowController.h"
#import "TXRenderView.h"
#import "HoverView.h"
#import "TRTCVideoListView.h"
#import "TRTCMemberListView.h"
#import "TRTCUserManager.h"
#import <CommonCrypto/CommonCrypto.h>

// TRTC的bizid的appid用于转推直播流，https://console.cloud.tencent.com/rav 点击【应用】【帐号信息】
// 在【直播信息】中可以看到bizid和appid，分别填到下面这两个符号
#define TX_BIZID 0
#define TX_APPID 0
#define PLACE_HOLDER_LOCAL_MAIN   @"$PLACE_HOLDER_LOCAL_MAIN$"
#define PLACE_HOLDER_LOCAL_SUB   @"$PLACE_HOLDER_LOCAL_SUB$"
#define PLACE_HOLDER_REMOTE     @"$PLACE_HOLDER_REMOTE$"

#define kButtonTitleAttr @{ NSForegroundColorAttributeName : [NSColor whiteColor] }

static NSString * const AudioIcon[2] = {@"main_tool_audio_on", @"main_tool_audio_off"};
static NSString * const VideoIcon[2] = {@"main_tool_video_on", @"main_tool_video_off"};

typedef NS_ENUM(NSUInteger, LayoutStyle) {
    LayoutStyleGalleryView        = 0,
    LayoutStylePresenterView      = 1,
};

@interface TRTCMainWindowController () <
    NSWindowDelegate,
    NSTableViewDelegate,
    NSTableViewDataSource,
    NSSplitViewDelegate,
    TRTCCloudDelegate,
    TRTCLogDelegate,
    TRTCVideoListViewDelegate>
{
    NSMutableDictionary *_mixTransCodeInfo;
}
/// TRTC SDK 实例对象
@property(nonatomic,strong) TRTCCloud *trtcEngine;
@property (nonatomic, strong) TRTCUserManager *userManager;

// 进房参数
@property(nonatomic,readonly,strong) TRTCParams *currentUserParam;
@property(nonatomic,readonly,assign) TRTCAppScene scene;
@property(nonatomic,readonly,assign) BOOL audioOnly;

// 用于鼠标移出后隐藏菜单栏
@property(nonatomic,strong) NSTrackingArea *trackingArea;

// 视频容器
@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSView *videoLayoutView;
@property (weak) IBOutlet TRTCMemberListView *memberListView;

// Function bar
@property (weak) IBOutlet NSView *anchorFunctionBar;
@property (weak) IBOutlet NSButton *muteAudioButton;
@property (weak) IBOutlet NSButton *micDeviceButton;
@property (weak) IBOutlet NSButton *muteVideoButton;
@property (weak) IBOutlet NSButton *outputDeviceButton;
@property (weak) IBOutlet NSButton *screenShareButton;
@property (weak) IBOutlet NSButton *roomPKButton;
@property (weak) IBOutlet NSButton *beautyButton;

@property (weak) IBOutlet NSView *functionBar;
@property (weak) IBOutlet NSButton *memberButton;
@property (weak) IBOutlet NSButton *layoutButton;
@property (weak) IBOutlet NSButton *logButton;
@property (weak) IBOutlet NSButton *closeButton;

@property(nonatomic,strong) NSMutableArray *micArr;
@property(nonatomic,strong) NSMutableArray *speakerArr;
@property(nonatomic,strong) NSMutableArray *cameraArr;

// 1. 画廊模式, 2. 演讲者模式
@property(nonatomic,assign) LayoutStyle layoutStyle;
// 屏幕捕捉
@property(nonatomic,strong) TXCaptureSourceWindowController *captureSourceWindowController;
@property(nonatomic,copy) NSString * presentingScreenCaptureUid;

// 混流信息，key为uid value为roomId
@property(nonatomic, strong) NSMutableDictionary* pkInfos;

// 正在进行的屏幕分享源
@property(nonatomic, strong) TRTCScreenCaptureSourceInfo *screenCaptureInfo;

// 显示屏幕分享按钮
@property (nonatomic, strong) NSTitlebarAccessoryViewController *titleBarAccessoryViewController;

// 演讲者模式
@property (weak) IBOutlet TRTCVideoListView *videoListView;
@property (weak) IBOutlet NSLayoutConstraint *videoListTrailing;
@property (weak) IBOutlet NSLayoutConstraint *videoListHeight;
@property (weak) IBOutlet NSButton *videoListToggleButton;

@end

@implementation TRTCMainWindowController

- (instancetype)initWithEngine:(TRTCCloud *)engine params:(TRTCParams *)params scene:(TRTCAppScene)scene audioOnly:(BOOL)audioOnly {
    if (self = [super initWithWindowNibName:@"TRTCMainWindowController"]) {
        _currentUserParam = params;
        _scene = scene;
        _audioOnly = audioOnly;
        self.trtcEngine = engine;
        self.trtcEngine.delegate = self;
        self.userManager = [[TRTCUserManager alloc] initWithUserId:_currentUserParam.userId];
        _mixTransCodeInfo = [NSMutableDictionary dictionary];
        _pkInfos = [NSMutableDictionary new];
        [TRTCSettingWindowController addObserver:self forKeyPath:NSStringFromSelector(@selector(mixMode)) options:NSKeyValueObservingOptionNew context:NULL];
        [TRTCSettingWindowController addObserver:self forKeyPath:NSStringFromSelector(@selector(isAudience)) options:NSKeyValueObservingOptionNew context:NULL];
        
        _titleBarAccessoryViewController = [[NSTitlebarAccessoryViewController alloc] initWithNibName:@"TRTCMainWindowAccessory" bundle:nil];
        _titleBarAccessoryViewController.layoutAttribute = NSLayoutAttributeRight;
        NSButton *button = _titleBarAccessoryViewController.view.subviews.firstObject;
        if ([button isKindOfClass:[NSButton class]]) {
            button.target = self;
            button.action = @selector(onClickPlayScreenShare:);
        }
    }
    return self;
}

- (void)dealloc {
    [TRTCSettingWindowController removeObserver:self forKeyPath:NSStringFromSelector(@selector(mixMode))];
    [TRTCSettingWindowController removeObserver:self forKeyPath:NSStringFromSelector(@selector(isAudience))];
    [self.userManager removeObserver:self forKeyPath:@"userConfigs"];
    [self.videoListView removeObserver:self forKeyPath:@"tableHeight"];
}

- (void)_configPopUpMenu:(NSTableView *)tableView  {
    [tableView setBackgroundColor:[NSColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1.0]];
    [[tableView enclosingScrollView] setDrawsBackground:NO];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView enclosingScrollView].hidden = YES;
    [tableView enclosingScrollView].borderType = NSNoBorder;
    tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
}

// 窗口加载后初始化控件
- (void)windowDidLoad {
    [super windowDidLoad];
    // 重置美颜窗口位置与参数
    NSRect frame = self.beautyPanel.frame;
    frame.origin.x = NSMinX(self.window.frame) - NSWidth(frame);
    frame.origin.y = NSMaxY(self.window.frame) - NSHeight(frame);
    [self.beautyPanel setFrameOrigin:frame.origin];
    self.beautyEnabled = YES;
    self.beautyLevel = self.rednessLevel = self.whitenessLevel = 5;

    // 配置窗口信息
    self.window.delegate = self;
    self.window.title = [NSString stringWithFormat:@"房间%u",self.roomID];
    self.window.backgroundColor = [NSColor whiteColor];
    
    // 本地视频预览 View
    self.videoLayoutView.wantsLayer = YES;
    self.videoLayoutView.layer.backgroundColor = [NSColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1.0].CGColor;
    
    // 底部工具栏
    self.anchorFunctionBar.wantsLayer = true;
    self.anchorFunctionBar.layer.backgroundColor = [NSColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1.0].CGColor;
    self.functionBar.wantsLayer = true;
    self.functionBar.layer.backgroundColor = [NSColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1.0].CGColor;
    NSArray *buttons = @[
        self.muteAudioButton,
        self.micDeviceButton,
        self.muteVideoButton,
        self.outputDeviceButton,
        self.screenShareButton,
        self.roomPKButton,
        self.beautyButton,
        self.memberButton,
        self.layoutButton,
        self.logButton,
        self.closeButton
    ];
    for (NSButton *button in buttons) {
        [button setHover];
        button.attributedTitle = [[NSAttributedString alloc] initWithString:button.title
                                                                 attributes:kButtonTitleAttr];
    }

    // 配置底部工具栏自动隐藏
    [self setupTrackingArea];

    //音频选择列表
    [self _configPopUpMenu:self.audioSelectView];
    self.audioSelectView.frame = CGRectMake(self.audioSelectView.frame.origin.x, self.audioSelectView.frame.origin.y, self.audioSelectView.frame.size.width, (self.micArr.count+self.speakerArr.count+1)*26);
    
    [self _configPopUpMenu:self.videoSelectView];
    self.videoSelectView.frame = CGRectMake(self.videoSelectView.frame.origin.x, self.videoSelectView.frame.origin.y, self.videoSelectView.frame.size.width, (self.micArr.count+1)*26);
    
    // 侧边视频列表
    self.videoListView.delegate = self;
    [self.videoListView observeUserManager:self.userManager];
    [self.videoListView addObserver:self forKeyPath:@"tableHeight" options:NSKeyValueObservingOptionNew context:nil];
    
    // 成员列表
    [self.memberListView observeUserManager:self.userManager];
    self.memberListView.hidden = YES;
    
    // 监听成员变化
    [self.userManager addObserver:self forKeyPath:@"userConfigs" options:NSKeyValueObservingOptionNew context:nil];
    
    // 进房
    [self enterRoom];
}

- (void)setupTrackingArea {
    if (self.trackingArea) {
        [self.window.contentView removeTrackingArea:self.trackingArea];
    }

    self.trackingArea = [[NSTrackingArea alloc] initWithRect: self.window.contentView.bounds
                                                                options: NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow
                                                                  owner: self
                                                               userInfo: nil];
    [self.window.contentView addTrackingArea:self.trackingArea];
}

- (void)windowDidResize:(NSNotification *)notification {
    [self setupTrackingArea];
    [self updateLayoutVideoFrame];
    [self updateVideoListHeight];
}

#pragma mark - 窗口标题
- (void)updateWindowTitle {
    NSString *title = [NSString stringWithFormat:@"房间%u",self.roomID];
    if (self.presentingScreenCaptureUid) {
        title = [title stringByAppendingFormat:@" %@ 正在分享屏幕",self.presentingScreenCaptureUid];
    } else if (self.screenCaptureInfo) {
        NSString *name = nil;
        if (self.screenCaptureInfo.type == TRTCScreenCaptureSourceTypeWindow) {
            NSDictionary *extInfo = self.screenCaptureInfo.extInfo;
            name = [NSString stringWithFormat:@"%@ - %@", extInfo[(__bridge NSString*)kCGWindowOwnerName], extInfo[(__bridge NSString*)kCGWindowName]];
        } else {
            name = self.screenCaptureInfo.sourceName;
        }
        title = [title stringByAppendingFormat:@" 您正在分享%@ (%@)", self.screenCaptureInfo.type == TRTCScreenCaptureSourceTypeScreen ? @"屏幕" : @"窗口", name];
    }
    self.window.title = title;
}

- (void)mouseDown:(NSEvent *)event {
    [self.videoSelectView enclosingScrollView].hidden = YES;
    [self.audioSelectView enclosingScrollView].hidden = YES;
}

#pragma mark - Notification Observer
//关闭窗口退出房间
-(void)windowWillClose:(NSNotification *)notification{
    [self.trtcEngine exitRoom];
    [self.trtcEngine stopLocalPreview];
    [self.beautyPanel close];
    [self.screenShareWindow close];
}

#pragma mark - Setting Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"mixMode"]) {
        [self updateCloudMixtureParams];
    } else if ([keyPath isEqualToString:@"isAudience"]) {
        BOOL isAudience = ((NSNumber*)change[@"new"]).boolValue;
        [self roleChanged:isAudience];
    } else if ([keyPath isEqualToString:@"userConfigs"]) {
        [self updateLayoutVideoFrame];
        [self checkToStopRenderHiddenUser];
    } else if ([keyPath isEqualToString:@"tableHeight"]) {
        [self updateVideoListHeight];
    }
}

#pragma mark - Accessors
- (uint32_t)roomID {
    return _currentUserParam.roomId;
}

- (NSString *)userId {
    return _currentUserParam.userId;
}

#pragma mark - 美颜参数更新
- (void)_updateBeautySettings {
    [self.trtcEngine setBeautyStyle:self.beautyStyle beautyLevel:self.beautyLevel whitenessLevel:self.whitenessLevel ruddinessLevel:self.rednessLevel];
}

#pragma mark - Utils
- (BOOL)isSelectSpeakerDevice:(NSString *)deviceId{
    if ([[self.trtcEngine getCurrentSpeakerDevice].deviceId isEqualToString:deviceId]) {
        return YES;
    }
    return NO;
}

// 判断是否是当前使用的麦克
-(BOOL)isSelectedMicDevice:(NSString *)deviceId{
    return [[self.trtcEngine getCurrentMicDevice].deviceId isEqualToString:deviceId];
}

// 判断是否是当前使用的摄像头
-(BOOL)isSelectedCameraDevice:(NSString *)deviceId{
    return [deviceId isEqualToString: [self.trtcEngine getCurrentCameraDevice].deviceId];
}

#pragma mark - 控制栏按钮操作
- (IBAction)onClickAudioMute:(NSButton *)button {
    button.image = [NSImage imageNamed:AudioIcon[button.state]];
    button.attributedTitle = [[NSAttributedString alloc] initWithString:@[@"静音", @"解除静音"][button.state]
                                                             attributes:kButtonTitleAttr];
    [self.userManager setUser:self.userId audioAvailable:button.state != NSControlStateValueOn];
}

- (IBAction)onClickVideoMute:(NSButton *)button {
    button.image = [NSImage imageNamed:VideoIcon[button.state]];
    button.attributedTitle = [[NSAttributedString alloc] initWithString:@[@"停止视频", @"开启视频"][button.state]
                                                             attributes:kButtonTitleAttr];
    [self.userManager setUser:self.userId videoAvailable:button.state != NSControlStateValueOn];
}

- (IBAction)onClickAudioSource:(id)sender {
    [self.audioSelectView enclosingScrollView].hidden = ![self.audioSelectView enclosingScrollView].hidden;
    if ([self.audioSelectView enclosingScrollView].hidden == NO) {
        [self.videoSelectView enclosingScrollView].hidden = YES;
    }
    [self.micArr removeAllObjects];
    [self.speakerArr removeAllObjects];
    self.micArr = [NSMutableArray arrayWithArray:[self.trtcEngine getMicDevicesList]];
    self.speakerArr = [NSMutableArray arrayWithArray:[self.trtcEngine getSpeakerDevicesList]];
    [self.micArr insertObject:@"选择麦克风" atIndex:0];
    [self.speakerArr insertObject:@"选择扬声器" atIndex:0];
    [self.audioSelectView reloadData];
}

- (IBAction)onClickCameraSource:(id)sender {
    [self.videoSelectView enclosingScrollView].hidden = ![self.videoSelectView enclosingScrollView].hidden;
    if ([self.videoSelectView enclosingScrollView].hidden == NO) {
        [self.audioSelectView enclosingScrollView].hidden = YES;
    }
    [self.cameraArr removeAllObjects];
    self.cameraArr = [NSMutableArray arrayWithArray:[self.trtcEngine getCameraDevicesList]];
    [self.cameraArr insertObject:@"选择摄像头" atIndex:0];
    [self.videoSelectView reloadData];
}

- (IBAction)onClickScreenCapture:(id)sender {
    self.captureSourceWindowController = [[TXCaptureSourceWindowController alloc] initWithTRTCCloud:_trtcEngine];
    __weak TRTCMainWindowController *wself = self;
    self.captureSourceWindowController.onSelectSource = ^(TRTCScreenCaptureSourceInfo * _Nonnull source) {
        __strong TRTCMainWindowController *self = wself;
        if (!self) return;
        
        [self.trtcEngine stopScreenCapture];

        if (source && source.type != TRTCScreenCaptureSourceTypeUnknown) {
            if (source.type == TRTCScreenCaptureSourceTypeWindow) {
                [self.trtcEngine selectScreenCaptureTarget:source rect:CGRectZero capturesCursor:NO highlight:YES];
            } else if (source.type == TRTCScreenCaptureSourceTypeScreen) {
                [self.trtcEngine selectScreenCaptureTarget:source rect:CGRectZero capturesCursor:YES highlight:NO];
            }
            if (self.captureSourceWindowController.usesBigStream) {
                [self.trtcEngine startScreenCapture:nil streamType:TRTCVideoStreamTypeBig encParam:nil];
            } else {
                [self.trtcEngine startScreenCapture:nil];
            }
        }
        self.screenCaptureInfo = source;
        [self updateWindowTitle];
        [self.window endSheet:self.captureSourceWindowController.window];
        [self.captureSourceWindowController.window close];
    };
    NSRect frame = self.window.frame;
    NSWindow *window = self.captureSourceWindowController.window;
    [window setFrame:frame display:YES animate:NO];
    [self.window beginSheet:window completionHandler:nil];
    [self.window addChildWindow:window ordered:NSWindowAbove];
}

- (IBAction)onClickClose:(id)sender {
    [self close];
    _trtcEngine = nil;
}

- (IBAction)onClickLog:(NSButton *)button {
    if (button.state == NSControlStateValueOn) {
        [self.trtcEngine showDebugView:2];
    } else {
        [self.trtcEngine showDebugView:0];
    }
}

- (IBAction)onClickLayoutButton:(NSButton *)button {
    self.layoutStyle = (self.layoutStyle + 1) % 2;
    
    button.image = [NSImage imageNamed:@[@"main_layout_gallery", @"main_layout_presenter"][self.layoutStyle]];
    button.attributedTitle = [[NSAttributedString alloc] initWithString:@[@"画廊视图", @"演讲视图"][self.layoutStyle]
                                                             attributes:kButtonTitleAttr];

    [self toggleVideoList:self.layoutStyle == LayoutStylePresenterView];

    [self updateLayoutVideoFrame];
    [self checkToStopRenderHiddenUser];
}

- (IBAction)onClickVideoListToggleButton:(NSButton *)button {
    [self toggleVideoList:button.state == NSControlStateValueOn];
    [self checkToStopRenderHiddenUser];
}

- (IBAction)onChangeBeautyStyle:(NSButton *)button {
    self.beautyStyle = (TRTCBeautyStyle)button.tag;
    if (self.beautyEnabled) {
        [self _updateBeautySettings];
    }
}

- (IBAction)onClickBeauty:(id)sender {
    [self.window addChildWindow:self.beautyPanel ordered:NSWindowAbove];
}

- (IBAction)onClickMemberButton:(NSButton *)button {
    self.memberListView.hidden = button.state == NSControlStateValueOff;
    CGRect frame = self.window.frame;
    frame.size.width += self.memberListView.hidden ? -self.memberListView.frame.size.width : self.memberListView.frame.size.width;
    [self.window setFrame:frame display:YES animate:NO];
}

- (IBAction)onClickPlayScreenShare:(id)sender {
    [self.screenShareWindow orderFront:nil];
}

- (IBAction)onClickMuteAllVideoButton:(NSButton *)button {
    BOOL mutesVideo = button.state == NSControlStateValueOn;
    button.title = mutesVideo ? @"取消禁画" : @"全部禁画";
    [self.userManager muteAllRemoteVideo:mutesVideo];
}

- (IBAction)onClickMuteAllAudioButton:(NSButton *)button {
    BOOL mutesAudio = button.state == NSControlStateValueOn;
    button.title = button.state == NSControlStateValueOn ? @"取消静音" : @"全部静音";
    [self.userManager muteAllRemoteAudio:mutesAudio];
}

#pragma makr - 跨房通话
- (IBAction)onConnectAnotherRoom:(id)sender {
    [self.window beginSheet:self.connectRoomWindow completionHandler:^(NSModalResponse returnCode) {
    }];
}

- (IBAction)onConfirmConnectRoom:(id)sender {
    NSString *signature = @"";
    NSDictionary *param = @{@"strRoomId": self.connectRoomId, @"userId": self.connectUserId, @"sign":signature};
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:&error];
    if (error) {
        NSLog(@"error when creating connect room param: %@", error);
        return;
    }
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    self.connectingRoom = YES;
    [self.trtcEngine connectOtherRoom:jsonString];
    [self.pkInfos setObject:self.connectRoomId forKey:self.connectUserId];
    [self.window endSheet:self.connectRoomWindow];
}
- (IBAction)onCloseConnectRoom:(id)sender {
    [self.window endSheet:self.connectRoomWindow];
}
- (IBAction)onStopConnectRoom:(id)sender {
    [self.trtcEngine disconnectOtherRoom];
    [self.pkInfos removeAllObjects];
    self.connectingRoom = NO;
}

- (void)toggleVideoList:(BOOL)displays {
    self.videoListTrailing.constant = displays ? 0 : -self.videoListView.frame.size.width;
    self.videoListToggleButton.state = displays ? NSControlStateValueOn : NSControlStateValueOff;
    self.videoListToggleButton.image = [NSImage imageNamed:displays ? @"NSGoRightTemplate" : @"NSGoLeftTemplate"];
}

#pragma mark - KVC
+ (NSSet *)keyPathsForValuesAffectingCanConnectRoom {
    return [NSSet setWithObjects:@"connectingRoom", @"connectRoomId", @"connectUserId", nil];
}

+ (NSSet *)keyPathsForValuesAffectingCanStopConnectRoom {
    return [NSSet setWithObjects:@"connectingRoom", nil];
}

// 更新美颜设置
- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
    if ([key isEqualToString:NSStringFromSelector(@selector(beautyEnabled))]) {
        if (!self.beautyEnabled) {
            // 关闭美颜设置
            [self.trtcEngine setBeautyStyle:self.beautyStyle beautyLevel:0 whitenessLevel:0 ruddinessLevel:0];
        }
    }
    if (!self.beautyEnabled) {
        return;
    }
    
    static NSSet *keys = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = [NSSet setWithObjects:
                NSStringFromSelector(@selector(beautyEnabled)),
                NSStringFromSelector(@selector(beautyLevel)),
                NSStringFromSelector(@selector(rednessLevel)),
                NSStringFromSelector(@selector(whitenessLevel)),
                NSStringFromSelector(@selector(beautyStyle)),
                nil];
    });
    if ([keys containsObject:key]) {
        // 更新美颜设置参数
        [self _updateBeautySettings];
    }
}

- (BOOL)canConnectRoom {
    return self.connectRoomId.length > 0 && self.connectUserId.length > 0 && !self.connectingRoom;
}

- (BOOL)canStopConnectRoom {
    return self.connectingRoom;
}

#pragma mark - 播放录屏
- (void)_playScreenCaptureForUser:(NSString *)userId {
    if (![self.presentingScreenCaptureUid isEqualToString:userId]) {
        [self.trtcEngine startRemoteSubStreamView:userId view:self.screenShareWindow.contentView];
    }
    [self.screenShareWindow orderFront:self];
    self.screenShareWindow.title = [NSString stringWithFormat:@"%@的屏幕分享", userId];
    self.presentingScreenCaptureUid = userId;
}

#pragma mark - 错误与警告
- (void)onError:(TXLiteAVError)errCode errMsg:(NSString *)errMsg extInfo:(NSDictionary *)extInfo {
    if (errCode == ERR_SERVER_CENTER_ANOTHER_USER_PUSH_SUB_VIDEO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.screenCaptureInfo = nil;
            [self updateWindowTitle];
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"屏幕分享发起失败";
            alert.informativeText = @"房间内已经有人发起了屏幕分享";
            [alert runModal];
        });
    }
    else {
        NSString *msg = [NSString stringWithFormat:@"didOccurError: %@[%d]", errMsg, errCode];
        NSLog(@"%@", msg);
        [self exitRoom];
    }
}
#pragma mark - 进房与音视频事件
/**
 * 加入视频房间：使用从 TRTCNewWindowController 实例化时传入的 TRTCParams
 */
- (void)enterRoom {
    TRTCParams *param = _currentUserParam;
    TRTCVideoEncParam *qualityConfig = [[TRTCVideoEncParam alloc] init];
    qualityConfig.videoResolution = TRTCSettingWindowController.resolution;
    qualityConfig.videoFps = TRTCSettingWindowController.fps;
    qualityConfig.videoBitrate = TRTCSettingWindowController.bitrate;
    qualityConfig.resMode = TRTCSettingWindowController.resolutionMode;
    [self.trtcEngine setVideoEncoderParam:qualityConfig];
    
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

    [self.userManager addUser:self.userId];

    // 开启视频采集预览
    if (!self.audioOnly) {
        [self.userManager setUser:self.userId videoAvailable:YES];
    } else {
        param.bussInfo = @"{\"Str_uc_params\":{\"pure_audio_push_mod\":1}}";
    }
    
    [self.userManager setUser:self.userId audioAvailable:YES];
    [self.trtcEngine enterRoom:param appScene:_scene];
}

- (void)onEnterRoom:(NSInteger)result {
    if (result >= 0) {
        [self.trtcEngine enableAudioVolumeEvaluation:300];
        
        [self.trtcEngine startSpeedTest:self.currentUserParam.sdkAppId
                                 userId:self.currentUserParam.userId
                                userSig:self.currentUserParam.userSig
                             completion:^(TRTCSpeedTestResult *result, NSInteger finishedCount, NSInteger totalCount) {
                                 NSLog(@"SpeedTest progress: %d/%d, result: %@", (int)finishedCount, (int)totalCount, result);
        }];
    } else {
        NSString *msg = [NSString stringWithFormat:@"进房失败: [%ld]", (long)result];
        NSLog(@"%@", msg);
        [self exitRoom];
    }
}

- (void)onFirstVideoFrame:(NSString *)userId streamType:(TRTCVideoStreamType)streamType width:(int)width height:(int)height {
    if (streamType == TRTCVideoStreamTypeSub && [userId isEqualToString:self.presentingScreenCaptureUid]) {
        NSSize maxSize = self.screenShareWindow.screen.visibleFrame.size;
        maxSize.width /= 2;
        maxSize.height /= 2;
        if (width > maxSize.width) {
            width = maxSize.width;
        }
        if (height > maxSize.height) {
            height = maxSize.height;
        }
        [self.screenShareWindow setContentSize:NSMakeSize(width, height)];
        [self.screenShareWindow orderFront:nil];
    }
}

- (void)onUserSubStreamAvailable:(NSString *)userId available:(BOOL)available {
    if (available) {
        if (![self.screenShareWindow isVisible]) {
            [self _playScreenCaptureForUser:userId];
        }
        [self.window addTitlebarAccessoryViewController:self.titleBarAccessoryViewController];
    } else {
        if ([userId isEqualToString:self.presentingScreenCaptureUid]){
            [self.screenShareWindow close];
            self.presentingScreenCaptureUid = nil;
            if (self.window.titlebarAccessoryViewControllers.count > 0) {
                [self.window removeTitlebarAccessoryViewControllerAtIndex:0];
            }
        }
    }
    [self updateWindowTitle];
}

- (void)onScreenCaptureStarted {
    NSLog(@"onScreenCaptureStarted");
}

- (void)onScreenCaptureStoped:(int)reason {
    NSLog(@"onScreenCaptureStoped: %@", @(reason));
}

- (void)onRemoteUserEnterRoom:(NSString *)userId {
    [self.userManager addUser:userId];
}

- (void)onRemoteUserLeaveRoom:(NSString *)userId reason:(NSInteger)reason {
    [self onUserSubStreamAvailable:userId available:NO];
    [self.userManager removeUser:userId];
}

- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available {
    if (!userId) { return; }

    [self.userManager setUser:userId videoAvailable:available];
    [self updateCloudMixtureParams];
}

- (void)onUserAudioAvailable:(NSString *)userId available:(BOOL)available {
    [self.userManager setUser:userId audioAvailable:available];
}

- (void)onDevice:(NSString *)deviceId type:(TRTCMediaDeviceType)deviceType stateChanged:(NSInteger)state
{
    NSLog(@"onDevice:%@ type:%ld state:%ld", deviceId, (long)deviceType, (long)state);
}

- (void)onLog:(NSString *)log LogLevel:(TRTCLogLevel)level WhichModule:(NSString *)module
{
    NSLog(@"myLOG:[%@] %@ %ld", module, log, (long)level);
}

- (void)onNetworkQuality:(TRTCQualityInfo *)localQuality remoteQuality:(NSArray<TRTCQualityInfo *> *)remoteQuality {
    [self.userManager setLocalNetQuality:localQuality];
    [self.userManager setRemoteNetQuality:remoteQuality];
}

- (void)onUserVoiceVolume:(NSArray<TRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume {
    [self.userManager setVolumes:userVolumes];
}

- (void)exitRoom {
    [self.trtcEngine exitRoom];
}

#pragma mark - 混流
- (void)stopCloudMixTranscoding {
    _mixTransCodeInfo = [NSMutableDictionary dictionary];
    [self.trtcEngine setMixTranscodingConfig:nil];
}

- (void)updateCloudMixtureParams
{
    TRTCTranscodingConfigMode mixMode = [TRTCSettingWindowController mixMode];
    if (mixMode == TRTCTranscodingConfigMode_Unknown) {
        [self stopCloudMixTranscoding];
        return;
        } else if (mixMode == TRTCTranscodingConfigMode_Template_PureAudio ||
                   mixMode == TRTCTranscodingConfigMode_Template_ScreenSharing) {
        TRTCTranscodingConfig* config = [TRTCTranscodingConfig new];
        config.appId = TX_APPID;//
        config.mode = mixMode;
        [_trtcEngine setMixTranscodingConfig:config];
        return;
    }
    int videoWidth  = 720;
    int videoHeight = 1280;
    
    // 小画面宽高
    int subWidth  = 180;
    int subHeight = 320;
    
    int offsetX = 5;
    int offsetY = 50;
    
    int bitrate = 200;
    
    int resolution = [TRTCSettingWindowController resolution];
    switch (resolution) {
        case TRTCVideoResolution_160_160:
        {
            videoWidth  = 160;
            videoHeight = 160;
            subWidth    = 27;
            subHeight   = 48;
            offsetY     = 20;
            bitrate     = 200;
            break;
        }
        case TRTCVideoResolution_320_180:
        {
            videoWidth  = 336;
            videoHeight = 192;
            subWidth    = 54;
            subHeight   = 96;
            offsetY     = 30;
            bitrate     = 400;
            break;
        }
        case TRTCVideoResolution_320_240:
        {
            videoWidth  = 320;
            videoHeight = 240;
            subWidth    = 54;
            subHeight   = 96;
            bitrate     = 400;
            break;
        }
        case TRTCVideoResolution_480_480:
        {
            videoWidth  = 480;
            videoHeight = 480;
            subWidth    = 72;
            subHeight   = 128;
            bitrate     = 600;
            break;
        }
        case TRTCVideoResolution_640_360:
        {
            videoWidth  = 640;
            videoHeight = 368;
            subWidth    = 90;
            subHeight   = 160;
            bitrate     = 800;
            break;
        }
        case TRTCVideoResolution_640_480:
        {
            videoWidth  = 640;
            videoHeight = 480;
            subWidth    = 90;
            subHeight   = 160;
            bitrate     = 800;
            break;
        }
        case TRTCVideoResolution_960_540:
        {
            videoWidth  = 960;
            videoHeight = 544;
            subWidth    = 171;
            subHeight   = 304;
            bitrate     = 1000;
            break;
        }
        case TRTCVideoResolution_1280_720:
        {
            videoWidth  = 1280;
            videoHeight = 720;
            subWidth    = 180;
            subHeight   = 320;
            bitrate     = 1500;
            break;
        }
    }
    
    TRTCTranscodingConfig* config = [TRTCTranscodingConfig new];
    config.appId = TX_APPID;//
    config.videoWidth = videoWidth;
    config.videoHeight = videoHeight;
    config.videoGOP = 1;
    config.videoFramerate = 15;
    config.videoBitrate = bitrate;
    config.audioSampleRate = 48000;
    config.audioBitrate = 64;
    config.audioChannels = 1;
    
    // 设置混流后主播的画面位置
    TRTCMixUser* broadCaster = [TRTCMixUser new];
    broadCaster.userId = mixMode == TRTCTranscodingConfigMode_Template_PresetLayout ? PLACE_HOLDER_LOCAL_MAIN : self.currentUserParam.userId; // 以主播uid为broadcaster为例
    broadCaster.zOrder = 0;
    broadCaster.rect = CGRectMake(0, 0, videoWidth, videoHeight);
    broadCaster.roomID = nil;
    
    NSMutableArray* mixUsers = [NSMutableArray new];
    [mixUsers addObject:broadCaster];
    
    // 设置混流后各个小画面的位置
    NSDictionary* pkUsers = self.pkInfos;
    int i = 0;
    
    int mixWidth = subWidth;// videoWidth / 3.0;
    int mixHeight = subHeight;// videoHeight / 3.0;
    
    NSMutableArray* userIdArray = self.userManager.userList.allKeys.mutableCopy;
    if (self.presentingScreenCaptureUid) {
        [userIdArray addObject:self.presentingScreenCaptureUid];
    }
    
    for (NSString* userId in userIdArray) {
        if ([userId isEqualToString:self.currentUserParam.userId]) {
            continue;
        }
        TRTCMixUser* audience = [TRTCMixUser new];
        audience.userId = mixMode == TRTCTranscodingConfigMode_Template_PresetLayout ? PLACE_HOLDER_REMOTE : userId;
        audience.zOrder = i + 1;
        audience.roomID = [pkUsers objectForKey:userId];
        audience.rect = CGRectMake(config.videoWidth - (mixWidth + 5) - (i % 5) * (mixWidth + 5),
                                   videoHeight - (i / 5 + 1) * (mixHeight + 1), mixWidth, mixHeight);
        
        [mixUsers addObject:audience];
        ++i;
    }
    config.mixUsers = mixUsers;
    config.mode = mixMode;
    [_trtcEngine setMixTranscodingConfig:config];
}

#pragma makr - 角色变化
- (void)roleChanged:(BOOL)isAudience {
    [self.userManager setUser:self.userId videoAvailable:!isAudience];
    [self.userManager setUser:self.userId audioAvailable:!isAudience];
    [self.trtcEngine switchRole:isAudience ? TRTCRoleAudience : TRTCRoleAnchor];
    
}

#pragma mark - 画面布局渲染

- (void)updateLayoutVideoFrame {
    if (self.layoutStyle == LayoutStyleGalleryView) {
        [self layoutWithGridStyle];
    } else {
        [self layoutWithPresenterStyle];
    }
    self.videoListToggleButton.hidden = self.layoutStyle != LayoutStylePresenterView;
}

- (void)updateVideoListHeight {
    CGFloat height = MIN(self.videoListView.tableHeight, self.videoLayoutView.frame.size.height);
    self.videoListHeight.constant = height;
}

- (void)layoutWithGridStyle {
    NSUInteger count = self.userManager.userConfigs.count;
    if (count == 0) return;
    
    NSRect bounds = self.videoLayoutView.bounds;
    NSUInteger col = ceil(sqrt(count));
    NSUInteger row = ceil(count / (float)col);
    
    NSSize size = NSMakeSize(NSWidth(bounds) / col, NSHeight(bounds) / row);
    
    NSRect frame = NSMakeRect(0, NSHeight(bounds) - size.height, size.width, size.height);
    for (NSInteger i = 0; i < count; ++ i) {
        TXRenderView *view = self.userManager.userConfigs[i].renderView;
        [self.videoLayoutView addSubview:view];
        view.frame = frame;
        if ((i+1) % col == 0) {
            frame.origin.x = 0;
            frame.origin.y -= size.height;
        } else {
            frame.origin.x += size.width;
        }
    }
}

- (void)layoutWithPresenterStyle {
    TRTCUserConfig *presenter = self.videoListView.mainUser;
    [self.videoLayoutView addSubview:presenter.renderView];
    presenter.renderView.frame = self.videoLayoutView.bounds;
    
    [self.videoListView reloadData];
}

#pragma mark - 连麦回调
- (void)onConnectOtherRoom:(NSString*)userId errCode:(TXLiteAVError)errCode errMsg:(nullable NSString *)errMsg;
{
    if (errCode != 0) {
        self.connectingRoom = NO;
        NSString *msg = [NSString stringWithFormat:@"%@ (%d)", errMsg, (int)errCode];
        [self.window presentError:[NSError errorWithDomain:@"TRTC" code:errCode userInfo:@{NSLocalizedDescriptionKey: msg}]];
        [self.pkInfos removeObjectForKey:userId];
    }
}

- (void)onDisconnectOtherRoom:(TXLiteAVError)errCode errMsg:(NSString *)errMsg {
    if (errCode != 0) {
        NSString *msg = [NSString stringWithFormat:@"%@ (%d)", errMsg, (int)errCode];
        [self.window presentError:[NSError errorWithDomain:@"TRTC" code:errCode userInfo:@{NSLocalizedDescriptionKey: msg}]];
    }
    [self.pkInfos removeAllObjects];
    self.connectingRoom = NO;
}

#pragma mark - 音频设备列表
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == self.audioSelectView) {
        return self.micArr.count + self.speakerArr.count + 1;
    } else {
        return self.cameraArr.count + 1;
    }
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 26;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if (tableView == self.audioSelectView) {
        NSTableCellView *view;
        if (row < self.micArr.count) {
            id object =  self.micArr[row];
            if ([object isKindOfClass:[NSString class]]) {
                view = [tableView  makeViewWithIdentifier:@"SelectMicRow" owner:self];
                view.textField.stringValue = object;
                view.textField.textColor = [NSColor whiteColor];
            }
            else if([object isKindOfClass:[TRTCMediaDeviceInfo class]]){
                view = [tableView makeViewWithIdentifier:@"MicDeviceRow" owner:self];
                view.textField.stringValue = ((TRTCMediaDeviceInfo *)object).deviceName;
                view.imageView.hidden = ![self isSelectedMicDevice:((TRTCMediaDeviceInfo *)object).deviceId];
                view.textField.textColor = [NSColor colorWithRed:0.64 green:0.64 blue:0.64 alpha:1.0];
                [view setHover];
            }
            if (row == self.micArr.count - 1) {
                NSView *bottomLine = [[NSView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, 1)];
                bottomLine.wantsLayer = YES;
                bottomLine.layer.backgroundColor = [NSColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1.0].CGColor;
                [view addSubview:bottomLine];
            }
        }
        else if(row < self.micArr.count + self.speakerArr.count){
            id object = self.speakerArr[row - self.micArr.count];
            if ([object isKindOfClass:[NSString class]]) {
                view = [tableView  makeViewWithIdentifier:@"SelectSpeakerRow" owner:self];
                view.textField.stringValue = object;
                view.textField.textColor = [NSColor whiteColor];
            }
            else if([object isKindOfClass:[TRTCMediaDeviceInfo class]]){
                view = [tableView makeViewWithIdentifier:@"SpeakerDeviceRow" owner:self];
                view.textField.stringValue = ((TRTCMediaDeviceInfo *)object).deviceName;
                view.textField.textColor = [NSColor colorWithRed:0.64 green:0.64 blue:0.64 alpha:1.0];;
                view.imageView.hidden = ![self isSelectSpeakerDevice:((TRTCMediaDeviceInfo *)object).deviceId];
                [view setHover];
            }
            if ((row - self.micArr.count) == self.speakerArr.count - 1) {
                NSView *bottomLine = [[NSView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, 1)];
                bottomLine.wantsLayer = YES;
                bottomLine.layer.backgroundColor = [NSColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1.0].CGColor;
                [view addSubview:bottomLine];
            }
        }
        else{
            view = [tableView makeViewWithIdentifier:@"AudioSettingRow" owner:self];
            view.textField.stringValue = @"音频设置";
            view.textField.textColor = [NSColor colorWithRed:0.64 green:0.64 blue:0.64 alpha:1.0];;
            [view setHover];
        }
        return view;
    } else {
        NSTableCellView *view;
        if (row < self.cameraArr.count) {
            id object =  self.cameraArr[row];
            if ([object isKindOfClass:[NSString class]]) {
                view = [tableView  makeViewWithIdentifier:@"SelectVideoRow" owner:self];
                view.textField.stringValue = object;
                view.textField.textColor = [NSColor whiteColor];
            }
            else if([object isKindOfClass:[TRTCMediaDeviceInfo class]]){
                view = [tableView makeViewWithIdentifier:@"VideoDeviceRow" owner:self];
                view.textField.stringValue = ((TRTCMediaDeviceInfo *)object).deviceName;
                view.imageView.hidden = ![self isSelectedCameraDevice:((TRTCMediaDeviceInfo *)object).deviceId];
                view.textField.textColor = [NSColor colorWithRed:0.64 green:0.64 blue:0.64 alpha:1.0];
                [view setHover];
            }
            if (row == self.cameraArr.count - 1) {
                NSView *bottomLine = [[NSView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, 1)];
                bottomLine.wantsLayer = YES;
                bottomLine.layer.backgroundColor = [NSColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1.0].CGColor;
                [view addSubview:bottomLine];
            }
        }
        else{
            view = [tableView makeViewWithIdentifier:@"VideoSettingRow" owner:self];
            view.textField.stringValue = @"视频设置";
            view.textField.textColor = [NSColor colorWithRed:0.64 green:0.64 blue:0.64 alpha:1.0];
            [view setHover];
        }
        return view;
    }
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    if (tableView == self.audioSelectView) {
        if (row < self.micArr.count) {
            id object =  self.micArr[row];
            if ([object isKindOfClass:[NSString class]]) {
                return NO;
            }
            else if([object isKindOfClass:[TRTCMediaDeviceInfo class]]){
                return YES;
            }
        }
        else if(row < self.micArr.count + self.speakerArr.count){
            id object = self.speakerArr[row - self.micArr.count];
            if ([object isKindOfClass:[NSString class]]) {
                return NO;
            }
            else if([object isKindOfClass:[TRTCMediaDeviceInfo class]]){
                return YES;
            }
        }
        return YES;
    }
    else{
        if (row < self.cameraArr.count) {
            id object =  self.micArr[row];
            if ([object isKindOfClass:[NSString class]]) {
                return NO;
            }
            else if([object isKindOfClass:[TRTCMediaDeviceInfo class]]){
                return YES;
            }
        }
        return YES;
    }
}

- (IBAction)onClickCameraSourceTableItem:(id)sender {
    NSTableView *tableView = sender;
    NSInteger row = [tableView selectedRow];
    if (row < 0) return;
    NSMutableArray *cameraArr = [NSMutableArray arrayWithArray:self.cameraArr];
    [cameraArr addObject:@"视频设置"];
    id object = [cameraArr objectAtIndex:row];
    if ([object isKindOfClass:[TRTCMediaDeviceInfo class]]) {
        [self.trtcEngine setCurrentCameraDevice:((TRTCMediaDeviceInfo *)object).deviceId];
    } else if ([object isKindOfClass:[NSString class]]&& [object isEqualToString:@"视频设置"]){
        if (self.onVideoSettingsButton) {
            self.onVideoSettingsButton();
        }
    }
    [self.audioSelectView enclosingScrollView].hidden = YES;
    [self.videoSelectView enclosingScrollView].hidden = YES;
}

- (IBAction)onClickAudioSourceTableItem:(id)sender {
    NSTableView *tableView = sender;
    NSInteger row = [tableView selectedRow];
    NSMutableArray *audioArr = [NSMutableArray arrayWithArray:self.micArr];
    [audioArr addObjectsFromArray:self.speakerArr];
    [audioArr addObject:@"音频设置"];
    id object = [audioArr objectAtIndex:row];
    if ([object isKindOfClass:[TRTCMediaDeviceInfo class]]) {
        //选择默认设备
        TRTCMediaDeviceInfo *source = (TRTCMediaDeviceInfo *)object;
        if ([self.micArr containsObject:object] ) {
            [self.trtcEngine setCurrentMicDevice:source.deviceId];
        }
        else if ([self.speakerArr containsObject:object]){
            [self.trtcEngine setCurrentSpeakerDevice:source.deviceId];
        }
    }
    else if ([object isKindOfClass:[NSString class]] && [object isEqualToString:@"音频设置"]){
        if (self.onAudioSettingsButton) {
            self.onAudioSettingsButton();
        }
    }
    [self.audioSelectView enclosingScrollView].hidden = YES;
    [self.videoSelectView enclosingScrollView].hidden = YES;
}

#pragma mark - NSSplitViewDelegate

- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex {
    return self.memberButton.state == NSControlStateValueOff;
}

#pragma mark - TRTCVideoListViewDelegate

- (void)videoListView:(TRTCVideoListView *)videoListView onSelectUser:(nonnull TRTCUserConfig *)user {
    [self layoutWithPresenterStyle];
    [self checkToStopRenderHiddenUser];
}

- (void)checkToStopRenderHiddenUser {
    if (self.layoutStyle == LayoutStyleGalleryView) {
        [self.userManager recoverAllRenderViews];
    } else {
        if (self.videoListTrailing.constant == 0) {
            [self.userManager recoverAllRenderViews];
        } else {
            [self.userManager hideRenderViewExceptUser:self.videoListView.mainUser.userId];
        }
    }
}

@end
