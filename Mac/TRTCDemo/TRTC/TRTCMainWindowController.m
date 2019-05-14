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
#import <CommonCrypto/CommonCrypto.h>

static NSString * const AudioIcon[2] = {@"main_tool_audio_on", @"main_tool_audio_off"};
static NSString * const VideoIcon[2] = {@"main_tool_video_on", @"main_tool_video_off"};

@interface UserVideoInfo : NSObject
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, assign) uint32_t width;
@property (nonatomic, assign) uint32_t height;
@property (nonatomic, assign) uint32_t fps;
@property (nonatomic, assign) TRTCVideoStreamType streamType;
@property (nonatomic, assign) uint32_t videoBitrate;
@end
@implementation UserVideoInfo
- (BOOL)isEqual:(UserVideoInfo *)object
{
    if (self == object) return YES;
    if (object == nil)  return NO;
    return self.width == object.width  && self.height == object.height ;//&&
//           self.fps == object.fps      && self.streamType == object.streamType &&
//           self.videoBitrate == object.videoBitrate && [self.userId isEqualToString:object.userId];
}
@end

@interface TRTCMainWindowController () <NSWindowDelegate,NSTableViewDelegate,NSTableViewDataSource, TRTCCloudDelegate, TRTCLogDelegate>
{
    NSMutableDictionary *_mixTransCodeInfo;
    NSString *_screenShareUidSuffix;
}
/// TRTC SDK 实例对象
@property(nonatomic,strong) TRTCCloud *trtcEngine;

// 进房参数
@property(nonatomic,readonly,strong) TRTCParams *currentUserParam;
@property(nonatomic,readonly,assign) TRTCAppScene scene;
// 用于鼠标移出后隐藏菜单栏
@property(nonatomic,strong) NSTrackingArea *trackingArea;
@property (nonatomic, copy) NSTimer *mouseTimer;
@property(nonatomic,assign) int frames;

// 视频容器
@property(nonatomic,strong) NSView *videoLayoutView;

@property(nonatomic,strong) NSMutableArray *micArr;
@property(nonatomic,strong) NSMutableArray *speakerArr;
@property(nonatomic,strong) NSMutableArray *cameraArr;

// key为uid, value为对应的渲染view
@property(nonatomic,strong) NSMutableDictionary *allRenderViews;
// 排序的uid
@property(nonatomic,strong) NSMutableArray *allUids;
// 1. 画廊模式, 2. 演讲者模式
@property(nonatomic,assign) int layoutStyle;

// 屏幕捕捉
@property(nonatomic,strong) TXCaptureSourceWindowController *captureSourceWindowController;
@property(nonatomic,copy) NSString * presentingScreenCaptureUid;

// 各路视频的旋转方向, key为uid
@property(nonatomic,strong) NSMutableDictionary<NSString *, NSNumber *> *rotationState;
// 各路视频的大小流设置, key为uid
@property(nonatomic,strong) NSMutableDictionary<NSString *, NSNumber *> *bigSmallStreamState;

@end

@implementation TRTCMainWindowController

- (instancetype)initWithEngine:(TRTCCloud *)engine params:(TRTCParams *)params scene:(TRTCAppScene)scene {
    if (self = [super initWithWindowNibName:@"TRTCMainWindowController"]) {
        _currentUserParam = params;
        _scene = scene;
        self.layoutStyle = 1;
        self.trtcEngine = engine;
        self.trtcEngine.delegate = self;
        self.allRenderViews = [NSMutableDictionary dictionary];
        self.rotationState = [NSMutableDictionary dictionary];
        self.bigSmallStreamState = [NSMutableDictionary dictionary];
        self.allUids = [NSMutableArray array];
        _mixTransCodeInfo = [NSMutableDictionary dictionary];
        _screenShareUidSuffix = @"屏幕分享";
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)_configButton:(NSButton *)button title:(NSString *)title color:(NSColor *)color {
    button.title = title;
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    button.attributedTitle = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:color,
                                                                                                  NSParagraphStyleAttributeName: style}];
    button.imagePosition = NSImageAbove;
    button.imageScaling = NSImageScaleProportionallyDown;
    button.alignment = NSTextAlignmentCenter;
}

- (void)_configButton:(NSButton *)button title:(NSString *)title {
    [self _configButton:button title:title color:[NSColor whiteColor]];
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
    self.beautyEnabled = NO;
    self.beautyLevel = self.rednessLevel = self.whitenessLevel = 5;

    // 配置窗口信息
    self.window.delegate = self;
    [self.window setMinSize:CGSizeMake(455, 370)];
    self.window.title = [NSString stringWithFormat:@"房间%u",self.roomID];
    self.window.backgroundColor = [NSColor whiteColor];
    
    // 添加本地视频预览view
    [self.window.contentView addSubview:self.videoLayoutView positioned:NSWindowBelow relativeTo:nil];
    
    self.controlBar.wantsLayer = true;
    self.controlBar.layer.backgroundColor = [NSColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1.0].CGColor;
    self.controlBar.hidden = YES;
    
    // 配置底部工具栏自动隐藏
    [_mouseTimer invalidate];
    _mouseTimer = nil;
    _mouseTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(onMouseTimer) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_mouseTimer forMode:NSDefaultRunLoopMode];
    
    [self setupMouseTracking];

    //音频选择列表
    [self _configPopUpMenu:self.audioSelectView];
    self.audioSelectView.frame = CGRectMake(self.audioSelectView.frame.origin.x, self.audioSelectView.frame.origin.y, self.audioSelectView.frame.size.width, (self.micArr.count+self.speakerArr.count+1)*26);
    
    [self _configPopUpMenu:self.videoSelectView];
    self.videoSelectView.frame = CGRectMake(self.videoSelectView.frame.origin.x, self.videoSelectView.frame.origin.y, self.videoSelectView.frame.size.width, (self.micArr.count+1)*26);
    
    // 配置工具栏按钮样式
    self.videoLayoutStyleBtn.layer.backgroundColor = [NSColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1.0].CGColor;
    self.videoLayoutStyleBtn.hidden = YES;

    // 设置按钮在鼠标悬浮时高亮
    [self.controlBar.subviews enumerateObjectsUsingBlock:^(__kindof NSButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSButton class]] && obj.title.length > 0) {
            [self _configButton:obj title:obj.title];
        }
        [obj setHover];

    }];
    [self _configButton:self.videoLayoutStyleBtn title:self.videoLayoutStyleBtn.title];

    // 进房
    [self enterRoom];
}

// 窗口改变时重新布局
- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize
{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        [self _layoutInBounds:(NSRect){NSZeroPoint, frameSize}];
    } completionHandler:nil];
    
    return frameSize;
}

//窗口缩放
- (void)windowDidResize:(NSNotification *)notification {
    [self updateLayoutVideoFrame];
}

#pragma mark - 底部工具栏控制
//控制层定时隐藏
- (void)onMouseTimer{
    self.frames++;
    if (self.frames > 3) {
        self.frames = 0;
        [self setPanelHidden:YES];
    }
}

// 鼠标跟踪移动检测
- (void)setupMouseTracking{
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.videoLayoutView.bounds
                                                     options:  (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved |
                                                                NSTrackingActiveInKeyWindow )
                                                       owner:self userInfo:nil];
    [self.videoLayoutView addTrackingArea:self.trackingArea];
}
- (void)mouseMoved:(NSEvent *)event{
    self.frames = 0;
    [self setPanelHidden:NO];
}
- (void)mouseDown:(NSEvent *)event
{
    [self.videoSelectView enclosingScrollView].hidden = YES;
    [self.audioSelectView enclosingScrollView].hidden = YES;
}

- (void)setPanelHidden:(BOOL)hidden{
    self.controlBar.hidden = hidden;
    if ([self.audioSelectView enclosingScrollView].hidden == NO || [self.videoSelectView enclosingScrollView].hidden == NO) {
        self.controlBar.hidden = NO;
    }
}

#pragma mark - Notification Observer
//关闭窗口退出房间
-(void)windowWillClose:(NSNotification *)notification{
    [self.trtcEngine exitRoom];
    [self.trtcEngine stopLocalPreview];
    [self.mouseTimer invalidate];
    self.mouseTimer = nil;
    [self.beautyPanel close];
    [self.capturePreviewWindow close];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Logout" object:self];
}

#pragma mark - KVC
// 更新美颜设置
- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
    if ([key isEqualToString:@"beautyEnabled"]) {
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
        keys = [NSSet setWithObjects:@"beautyEnabled", @"beautyLevel", @"rednessLevel", @"whitenessLevel", @"beautyStyle", nil];
    });
    if ([keys containsObject:key]) {
        // 更新美颜设置参数
        [self _updateBeautySettings];
    }
}

#pragma mark - Accessors
- (uint32_t)roomID {
    return _currentUserParam.roomId;
}

- (NSString *)userId {
    return _currentUserParam.userId;
}

// 本地预览视图
- (TXRenderView *)localVideoRenderView {
    return _allRenderViews[self.userId];
}

- (NSString *)localScreenshareUid {
    NSString *uid = [NSString stringWithFormat:@"%@-%@", self.currentUserParam.userId, _screenShareUidSuffix];
    return uid;
}

- (TXRenderView *)localScreenSharePreview {
    NSString *uid = [self localScreenshareUid];
    TXRenderView *view = _allRenderViews[uid];
    if (nil == view) {
        view = [self addRenderViewAt:uid];
    }
    return view;
}

- (TXRenderView *)renderViewForUser:(NSString *)userId {
    return _allRenderViews[userId];
}

#pragma mark -
// 美颜参数更新
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
- (IBAction)micBtnClick:(id)sender {
    NSButton *shareBtn = (NSButton *)sender;
    if (shareBtn.state == 1) {
        [self.micBtn setImage:[NSImage imageNamed:AudioIcon[1]]];
        self.micBtn.title = @"解除静音";
        NSMutableAttributedString *attTitle = [[NSMutableAttributedString alloc]initWithAttributedString:self.micBtn.attributedTitle];
        NSDictionary *dicAtt =@{NSForegroundColorAttributeName:[NSColor whiteColor]};
        [attTitle addAttributes:dicAtt range:NSMakeRange(0,4)];
        self.micBtn.attributedTitle = attTitle;
        [self.trtcEngine muteLocalAudio:YES];
    }
    else{
        [self.micBtn setImage:[NSImage imageNamed:AudioIcon[0]]];
        self.micBtn.title = @"静音";
        NSMutableAttributedString *attTitle = [[NSMutableAttributedString alloc]initWithAttributedString:self.micBtn.attributedTitle];
        NSDictionary *dicAtt =@{NSForegroundColorAttributeName:[NSColor whiteColor]};
        [attTitle addAttributes:dicAtt range:NSMakeRange(0,2)];
        self.micBtn.attributedTitle = attTitle;
        [self.trtcEngine muteLocalAudio:NO];
    }
}

- (IBAction)videoBtnClick:(id)sender {
    NSButton *shareBtn = (NSButton *)sender;
    if (shareBtn.state == 1) {
        [self.videoBtn setImage:[NSImage imageNamed:VideoIcon[1]]];
        self.videoBtn.title = @"开启视频";
        NSMutableAttributedString *attTitle = [[NSMutableAttributedString alloc]initWithAttributedString:self.videoBtn.attributedTitle];
        NSDictionary *dicAtt =@{NSForegroundColorAttributeName:[NSColor whiteColor]};
        [attTitle addAttributes:dicAtt range:NSMakeRange(0,4)];
        self.videoBtn.attributedTitle = attTitle;
//        [self.trtcEngine stopVideoCapture];
        [self.trtcEngine stopLocalPreview];
    }
    else{
        [self.videoBtn setImage:[NSImage imageNamed:VideoIcon[0]]];
        self.videoBtn.title = @"停止视频";
        NSMutableAttributedString *attTitle = [[NSMutableAttributedString alloc]initWithAttributedString:self.videoBtn.attributedTitle];
        NSDictionary *dicAtt =@{NSForegroundColorAttributeName:[NSColor whiteColor]};
        [attTitle addAttributes:dicAtt range:NSMakeRange(0,4)];
        self.videoBtn.attributedTitle = attTitle;
        [self.trtcEngine startLocalPreview:[self renderViewForUser:self.userId].contentView];
    }
}

- (IBAction)audioSelect:(id)sender {
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

- (IBAction)videoSelect:(id)sender {
    [self.videoSelectView enclosingScrollView].hidden = ![self.videoSelectView enclosingScrollView].hidden;
    if ([self.videoSelectView enclosingScrollView].hidden == NO) {
        [self.audioSelectView enclosingScrollView].hidden = YES;
    }
    [self.cameraArr removeAllObjects];
    self.cameraArr = [NSMutableArray arrayWithArray:[self.trtcEngine getCameraDevicesList]];
    [self.cameraArr insertObject:@"选择摄像头" atIndex:0];
    [self.videoSelectView reloadData];
}

- (IBAction)onShowInputSource:(id)sender {
    self.captureSourceWindowController = [[TXCaptureSourceWindowController alloc] initWithTRTCCloud:_trtcEngine];
    __weak TRTCMainWindowController *wself = self;
    self.captureSourceWindowController.onSelectSource = ^(TRTCScreenCaptureSourceInfo * _Nonnull source) {
        if (source == nil) {
            [wself.trtcEngine startLocalPreview:[wself.allRenderViews[wself.userId] contentView]];
        } else if (source.type == TRTCScreenCaptureSourceTypeWindow) {
            [wself.trtcEngine selectScreenCaptureTarget:source rect:CGRectZero capturesCursor:NO highlight:YES];
        } else if (source.type == TRTCScreenCaptureSourceTypeScreen) {
            [wself.trtcEngine selectScreenCaptureTarget:source rect:CGRectZero capturesCursor:NO highlight:YES];
        }
        if (source == nil) {
            [wself.trtcEngine stopScreenCapture];
            [wself removeRenderViewForUser:[wself localScreenshareUid]];
        } else {
            TRTCVideoEncParam* subEncParam = [TRTCVideoEncParam new];
            subEncParam.videoResolution = TRTCSettingWindowController.subStreamResolution;
            subEncParam.videoFps = TRTCSettingWindowController.subStreamFps;
            subEncParam.videoBitrate = TRTCSettingWindowController.subStreamBitrate;
            [wself.trtcEngine setSubStreamEncoderParam:subEncParam];
            [wself.trtcEngine startScreenCapture:[wself localScreenSharePreview]];
        }
        [wself.window endSheet:wself.captureSourceWindowController.window];
        [wself.captureSourceWindowController.window close];
    };
    NSRect frame = self.window.frame;
    NSWindow *window = self.captureSourceWindowController.window;
    [window setFrame:frame display:YES animate:NO];
    [self.window beginSheet:window completionHandler:nil];
    [self.window addChildWindow:window ordered:NSWindowAbove];
}

- (IBAction)closeRoom:(id)sender {
    [self close];
    _trtcEngine = nil;
}
- (IBAction)showLog:(id)sender {
    NSButton *shareBtn = (NSButton *)sender;
    if (shareBtn.state == 1) {
        [self.trtcEngine showDebugView:2];
    }
    else{
        [self.trtcEngine showDebugView:0];
    }
}

- (IBAction)videoLayoutChange:(id)sender {
    if (self.layoutStyle == 1) {
        self.layoutStyle = 2;
        self.videoLayoutStyleBtn.title = @"演讲者视图";
        self.videoLayoutStyleBtn.image = [NSImage imageNamed:@"speakerMode"];
        NSMutableAttributedString *attTitle = [[NSMutableAttributedString alloc]initWithAttributedString:self.videoLayoutStyleBtn.attributedTitle];
        NSDictionary *dicAtt =@{NSForegroundColorAttributeName:[NSColor whiteColor]};
        [attTitle addAttributes:dicAtt range:NSMakeRange(0,5)];
        self.videoLayoutStyleBtn.attributedTitle = attTitle;
    }
    else if(self.layoutStyle == 2){
        self.layoutStyle = 1;
        self.videoLayoutStyleBtn.title = @"画廊视图";
        self.videoLayoutStyleBtn.image = [NSImage imageNamed:@"main_layout_gallery"];
        NSMutableAttributedString *attTitle = [[NSMutableAttributedString alloc]initWithAttributedString:self.videoLayoutStyleBtn.attributedTitle];
        NSDictionary *dicAtt =@{NSForegroundColorAttributeName:[NSColor whiteColor]};
        [attTitle addAttributes:dicAtt range:NSMakeRange(0,4)];
        self.videoLayoutStyleBtn.attributedTitle = attTitle;
    }
    [self updateLayoutVideoFrame];
}

- (IBAction)onChangeStyle:(NSButton *)button {
    self.beautyStyle = (TRTCBeautyStyle)button.tag;
    if (self.beautyEnabled) {
        [self _updateBeautySettings];
    }
}

- (IBAction)onShowBeautyPanel:(id)sender {
    [self.window addChildWindow:self.beautyPanel ordered:NSWindowAbove];
}

- (void)onCameraDidReady {
    
}

#pragma makr - 跨房通话
- (IBAction)onConnectAnotherRoom:(id)sender {

    [self.window beginSheet:self.connectRoomWindow completionHandler:^(NSModalResponse returnCode) {
    }];
}

+ (NSSet *)keyPathsForValuesAffectingCanConnectRoom {
    return [NSSet setWithObjects:@"connectingRoom", @"connectRoomId", @"connectUserId", nil];
}
+ (NSSet *)keyPathsForValuesAffectingCanStopConnectRoom {
    return [NSSet setWithObjects:@"connectingRoom", nil];
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
    [self.window endSheet:self.connectRoomWindow];
}
- (IBAction)onCloseConnectRoom:(id)sender {
    [self.window endSheet:self.connectRoomWindow];
}
- (IBAction)onStopConnectRoom:(id)sender {
    [self.trtcEngine disconnectOtherRoom];
    self.connectingRoom = NO;
}

- (BOOL)canConnectRoom {
    return self.connectRoomId.length > 0 && self.connectUserId.length > 0 && !self.connectingRoom;
}
- (BOOL)canStopConnectRoom {
    return self.connectingRoom;
}
#pragma mark - 播放录屏
- (void)_playScreenCaptureForUser:(NSString *)userId {
    [self.trtcEngine startRemoteSubStreamView:userId view:self.capturePreviewWindow.contentView];
    [self.capturePreviewWindow orderFront:self];
    self.capturePreviewWindow.title = [NSString stringWithFormat:@"%@的屏幕分享", userId];
    self.presentingScreenCaptureUid = userId;
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
    [self.trtcEngine setLocalViewFillMode:TRTCVideoFillMode_Fit];
    
    //        [self.trtcEngine setPriorRemoteVideoStreamType:TRTCVideoStreamTypeSmall];
    if (TRTCSettingWindowController.pushDoubleStream) {
        TRTCVideoEncParam *smallVideoConfig = [[TRTCVideoEncParam alloc] init];
        smallVideoConfig.videoResolution = TRTCVideoResolution_160_120;
        smallVideoConfig.videoFps = 15;
        smallVideoConfig.videoBitrate = 100;
        
        [self.trtcEngine enableEncSmallVideoStream:TRTCSettingWindowController.pushDoubleStream
                                       withQuality:smallVideoConfig];
    }
    //        config.renderMode = ETRTCVideoRenderModeFit; // 默认带黑边的渲染模式
    
    // 开启视频采集预览
    TXRenderView *videoView = [self addRenderViewAt:self.userId];
    [self.trtcEngine setLocalViewFillMode:TRTCVideoFillMode_Fit];
    [self.trtcEngine startLocalPreview:videoView.contentView];
    [self.trtcEngine startLocalAudio];
    [self.trtcEngine muteLocalAudio:NO];
    // 进房
    [self.trtcEngine enterRoom:param appScene:_scene];
}

- (void)onEnterRoom:(NSInteger)elapsed{
    [self.trtcEngine enableAudioVolumeEvaluation:300];
    self.controlBar.hidden = NO;
    [self updateLayoutVideoFrame];
    
    [self.trtcEngine startSpeedTest:self.currentUserParam.sdkAppId
                             userId:self.currentUserParam.userId
                            userSig:self.currentUserParam.userSig
                         completion:^(TRTCSpeedTestResult *result, NSInteger finishedCount, NSInteger totalCount) {
                             NSLog(@"SpeedTest progress: %d/%d, result: %@", (int)finishedCount, (int)totalCount, result);
    }];
}

- (void)onUserExit:(NSString *)userId reason:(NSInteger)reason {
    [self onUserSubStreamAvailable:userId available:NO];
    [self removeRenderViewForUser:userId];
}

- (void)onUserSubStreamAvailable:(NSString *)userId available:(BOOL)available {
    if (available) {
        if (![self.capturePreviewWindow isVisible]) {
            [self _playScreenCaptureForUser:userId];
        }
        TXRenderView *renderView = [self renderViewForUser: userId];
        [renderView addTextToolbarItem:@"屏" target:self action:@selector(onRenderViewToolbarScreenShareClicked:) context:userId];
    } else {
        if ([userId isEqualToString:self.presentingScreenCaptureUid]){
            [self.capturePreviewWindow orderOut:nil];
        }
        TXRenderView *renderView = [self renderViewForUser: userId];
        [renderView removeToolbarWithTitle:@"屏"];
    }
}

- (void)onUserEnter:(NSString *)userId {
    NSView *videoView = [self addRenderViewAt:userId].contentView;
    [self.trtcEngine setRemoteViewFillMode:userId mode:TRTCVideoFillMode_Fit];
    if (TRTCSettingWindowController.playSmallStream) {
        self.bigSmallStreamState[userId] = @(TRTCVideoStreamTypeSmall);
        [self.trtcEngine setRemoteVideoStreamType:userId type:TRTCVideoStreamTypeSmall];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateLayoutVideoFrame];
    });
}

- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available
{
    //远程画面
    if (userId != nil) {
        TXRenderView* videoView = [self renderViewForUser:userId];
        if (available) {
            [self.trtcEngine startRemoteView:userId view:videoView];
        }
        else {
            [self.trtcEngine stopRemoteView:userId];
        }
    }
}

- (void)onDevice:(NSString *)deviceId type:(TRTCMediaDeviceType)deviceType stateChanged:(NSInteger)state
{
    NSLog(@"onDevice:%@ type:%ld state:%ld", deviceId, (long)deviceType, (long)state);
}

- (void)onLog:(NSString *)log LogLevel:(TRTCLogLevel)level WhichModule:(NSString *)module
{
    NSLog(@"myLOG:[%@] %@ %ld", module, log, (long)level);
}

- (void)onNetworkQuality:(TRTCQualityInfo *)localQuality remoteQuality:(NSArray<TRTCQualityInfo *> *)remoteQuality
{
    NSLog(@"localQuality:%u", (unsigned)localQuality.quality);
    for (TRTCQualityInfo* qualityInfo in remoteQuality) {
        NSLog(@"remote:%@ quality:%ld", qualityInfo.userId, (long)(unsigned)qualityInfo.quality);
    }
    
    [[self localVideoRenderView] setSignal:localQuality.quality];
    
    for (TRTCQualityInfo* qualityInfo in remoteQuality) {
        [[self renderViewForUser:qualityInfo.userId] setSignal:qualityInfo.quality];
    }

}

- (void)onUserVoiceVolume:(NSArray<TRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume
{
    [userVolumes enumerateObjectsUsingBlock:^(TRTCVolumeInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *uid = obj.userId;
        if (uid == nil) {
            [self.localVideoRenderView setVolume:obj.volume / 100.f];
        } else {
            TXRenderView *view = [self renderViewForUser:obj.userId];
            [view setVolume:obj.volume/100.f];
        }
    }];
}

- (void)onStatistics:(TRTCStatistics *)statistics {
    if (TRTCSettingWindowController.cloudMixEnabled) {
        TRTCLocalStatistics *statistic = [statistics.localStatistics filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"streamType = %d", TRTCVideoStreamTypeBig]].lastObject;
        NSMutableArray *videoInfoArray = [[NSMutableArray alloc]initWithCapacity:4];
        if (statistic) {
            UserVideoInfo *info = [[UserVideoInfo alloc] init];
            info.userId = self.currentUserParam.userId;
            info.width = statistic.width;
            info.height = statistic.height;
            info.streamType = statistic.streamType;
            info.fps = statistic.frameRate;
            info.videoBitrate = statistic.videoBitrate;
            [videoInfoArray addObject:info];
        } else {
            // 确保第一个是local
            [videoInfoArray addObject:[[UserVideoInfo alloc] init]];
        }
        for (TRTCRemoteStatistics *statistic in statistics.remoteStatistics) {
            if (statistic.streamType == TRTCVideoStreamTypeBig) {
                UserVideoInfo *info = [[UserVideoInfo alloc] init];
                info.userId = statistic.userId;
                info.width = statistic.width;
                info.height = statistic.height;
                info.streamType = statistic.streamType;
                [videoInfoArray addObject:info];
            }
        }
        [self setupTranscoding:videoInfoArray];
    } else {
        [self stopTranscoding];
    }
}
#pragma mark - 混流
- (void)stopTranscoding {
    _mixTransCodeInfo = [NSMutableDictionary dictionary];
    [self.trtcEngine setMixTranscodingConfig:nil];
}

- (void)setupTranscoding:(NSArray<UserVideoInfo *> *)userInfoArray {
    UserVideoInfo *localInfo = userInfoArray.firstObject;
    if (localInfo.userId == nil) {
        if (_mixTransCodeInfo.count > 0) {
            [self stopTranscoding];
        }
        return;
    }
    if (_mixTransCodeInfo.count == 0) {
        NSString* streamId = [NSString stringWithFormat:@"%u_%@_main", self.currentUserParam.roomId, self.currentUserParam.userId] ;
        const char *cStr = [streamId UTF8String];
        unsigned char result[CC_MD5_DIGEST_LENGTH];
        CC_MD5(cStr, (uint32_t)strlen(cStr), result);
        NSString *md5StreamId = [NSString stringWithFormat:
                                @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                                result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
                                result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
                                ];
        
       
        NSString* playUrl = [NSString stringWithFormat:@"http://3891.liveplay.myqcloud.com/live/3891_%@.flv", md5StreamId];
        NSLog(@"play address: %@", playUrl);
    }
    if (userInfoArray.count != _mixTransCodeInfo.count) {
        [_mixTransCodeInfo removeAllObjects];
    } else {
        BOOL allEqual = YES;
        for (UserVideoInfo *info in userInfoArray) {
            if (![_mixTransCodeInfo[info.userId] isEqual:info]) {
                [_mixTransCodeInfo removeAllObjects];
                allEqual = NO;
                break;
            }
        }
        if (allEqual) {
            return;
        }
    }
    
    for (UserVideoInfo *info in userInfoArray) {
        _mixTransCodeInfo[info.userId] = info;
    }
    
    // 更新混流信息
    TRTCTranscodingConfig *config = [[TRTCTranscodingConfig alloc] init];
    config.mode = TRTCTranscodingConfigMode_Manual;
    config.appId = _currentUserParam.sdkAppId;
    config.bizId = <#bizID#>; // 请进入 "实时音视频"控制台 https://console.cloud.tencent.com/rav，点击对应的应用，然后进入“帐号信息”菜单中，复制“直播信息”模块中的"bizid"
    config.videoWidth = localInfo.width;
    config.videoHeight = localInfo.height;
    config.videoBitrate = localInfo.videoBitrate;
    config.videoFramerate = 15;
    config.videoGOP = 3;
    config.audioSampleRate = 48000;
    config.audioBitrate = 64;
    config.audioChannels = 1;
    
    NSUInteger remoteCount = userInfoArray.count - 1;
    NSMutableArray *mixUserArray = [[NSMutableArray alloc] initWithCapacity:remoteCount];
    TRTCMixUser *localUser = [[TRTCMixUser alloc]init];
    localUser.userId = localInfo.userId;
    localUser.rect = CGRectMake(0, 0, localInfo.width, localInfo.height);
    localUser.zOrder = 1;
    localUser.streamType = TRTCVideoStreamTypeBig;
    [mixUserArray addObject:localUser];
    
    if (remoteCount > 0) {
        int zOrder = 2;
        int mixWidth = localInfo.width / 3.0;
        int mixHeight = localInfo.height / 3.0;

        // 最多叠加6路小画面
        for (NSInteger i = 1; i < remoteCount + 1 && i < 7; ++i) {
            UserVideoInfo *info = userInfoArray[i];
            TRTCMixUser *mixUser = [[TRTCMixUser alloc]init];
            mixUser.userId = info.userId;
            CGRect container;
            // 前三个小画面靠右从下往上铺
            if (i < 4) {
                container = CGRectMake(config.videoWidth - mixWidth, localInfo.height - i * mixHeight, mixWidth, mixHeight);
            } else {
                // 后三个小画面靠左从下往上铺
                container = CGRectMake(0, localInfo.height - (i - 3) * mixHeight, mixWidth, mixHeight);
            }
            mixUser.rect = AVMakeRectWithAspectRatioInsideRect(CGSizeMake(info.width, info.height), container);
            mixUser.zOrder = zOrder;
            mixUser.streamType = TRTCVideoStreamTypeBig;
            zOrder++;
            [mixUserArray addObject:mixUser];
        }
    }
    config.mixUsers = mixUserArray;
    [self.trtcEngine setMixTranscodingConfig:config];
}

#pragma mark - 画面布局渲染
- (NSView *)videoLayoutView{
    if (!_videoLayoutView) {
        _videoLayoutView = [[NSView alloc] initWithFrame:self.window.contentView.bounds];
        _videoLayoutView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        _videoLayoutView.wantsLayer = YES;
        _videoLayoutView.layer.backgroundColor = [NSColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1.0].CGColor;
        [_videoLayoutView setNeedsDisplay:YES];
    }
    return _videoLayoutView;
}

- (TXRenderView *)addRenderViewAt:(NSString *)videoId{
    TXRenderView *videoView = _allRenderViews[videoId];
    if (!videoView) {
        videoView = [[TXRenderView alloc] init];
        videoView.volumeHidden = ![TRTCSettingWindowController showVolume];
        [videoView addImageToolbarItem:[NSImage imageNamed:@"stream_rotate"] target:self action:@selector(onRenderViewToolbarRotateClicked:) context:videoId];

        if (![videoId isEqualToString:self.userId]) {
            [videoView addTextToolbarItem:@"流" target:self action:@selector(onRenderViewToolbarStreamClicked:) context:videoId];
            [videoView addToggleImageToolbarItem:@[[NSImage imageNamed:@"main_tool_video_on"], [NSImage imageNamed:@"main_tool_video_off"]] target:self action:@selector(onRenderViewToolbarVideoClicked:index:) context:videoId];
            [videoView addToggleImageToolbarItem:@[[NSImage imageNamed:@"main_tool_audio_on"], [NSImage imageNamed:@"main_tool_audio_off"]] target:self action:@selector(onRenderViewToolbarAudioClicked:index:) context:videoId];
        }
        [videoView addToggleImageToolbarItem:@[[NSImage imageNamed:@"stream_fill_mode"], [NSImage imageNamed:@"stream_fill_mode"]] target:self action:@selector(onRenderViewToolbarFillModeChanged:index:) context:videoId];

        if (![videoId isEqualToString:self.userId] && [_allUids.firstObject isEqualToString:self.userId]) {
            [_allUids removeObject:self.userId];
            [_allUids insertObject:self.userId atIndex:0];
        }
        [_allUids addObject:videoId];
        [_allRenderViews setObject:videoView forKey:videoId];
        [self.videoLayoutView addSubview:videoView];
        videoView.wantsLayer = true;
        videoView.layer.backgroundColor = [NSColor blackColor].CGColor;
        videoView.layer.borderWidth = 1;
        videoView.layer.borderColor = [NSColor whiteColor].CGColor;
        
        NSTextField *identifierText = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, 180, 20)];
        identifierText.backgroundColor = [[NSColor blackColor] colorWithAlphaComponent:0.2];
        identifierText.bordered = NO;
        identifierText.alignment = NSTextAlignmentCenter;
        identifierText.stringValue = videoId;
        identifierText.editable = NO;
        identifierText.textColor = [NSColor whiteColor];
        identifierText.font = [NSFont systemFontOfSize:12];
        identifierText.tag = 1001;
        [videoView addSubview:identifierText];
        [self.trtcEngine setDebugViewMargin:videoId margin:NSEdgeInsetsMake(0.1, 0, 0, 0)];
    }
    [self updateLayoutVideoFrame];
    return videoView;
}

- (void)removeRenderViewForUser:(NSString *)userId{
    NSView *videoView = _allRenderViews[userId];
    [videoView removeFromSuperview];
    [_allRenderViews removeObjectForKey:userId];
    [_allUids removeObject:userId];
    [self.rotationState removeObjectForKey:userId];
    [self updateLayoutVideoFrame];
}

/// 画廊视图布局，每个人的视图大小相同
- (void)layoutWithGridStyle:(NSRect)bounds {
    NSUInteger count = _allRenderViews.count;
    if (count == 0) return;
    
    NSUInteger col = ceil(sqrt(count));
    NSUInteger row = ceil(count / (float)col);
    
    NSSize size = NSMakeSize(NSWidth(bounds) / col, NSHeight(bounds) / row);
    
    NSRect frame = NSMakeRect(0, NSHeight(bounds) - size.height, size.width, size.height);
    for (NSInteger i = 0; i < count; ++ i) {
        NSString *uid = _allUids[i];
        NSView *view = _allRenderViews[uid];
        view.frame = frame;
        view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        if ((i+1) % col == 0) {
            frame.origin.x = 0;
            frame.origin.y -= size.height;
        } else {
            frame.origin.x += size.width;
        }
    }
}

/// 演讲者视图布局，上面小图，下面大图
- (void)layoutWithSplitStyle:(NSRect)bounds {
    const CGFloat TopHeight = 160;
    const CGFloat Spacing   = 12;
    NSView *bigView = _allRenderViews[self.allUids.firstObject];
    if (_allUids.count == 1) {
        bigView.frame = bounds;
        bigView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    } else if (_allUids.count > 1) {
        bigView = _allRenderViews[self.allUids[1]];
        NSMutableArray *uids = [_allUids mutableCopy];
        [uids removeObjectAtIndex:1];
        
        const NSInteger topCount = uids.count;
        NSRect frame = bounds;
        frame.size.height -= TopHeight;
        bigView.frame = frame;
        bigView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        
        CGFloat height = TopHeight - Spacing * 2;
        CGFloat width = round(height * 1.33);
        CGSize size = NSMakeSize(width, height);
        CGFloat totalWidth = (width + Spacing) * (topCount - 1) + width;
        CGFloat left = (NSWidth(bounds) - totalWidth) / 2;
        if (left < Spacing) {
            left = Spacing;
        }
        NSPoint point = NSMakePoint(left, NSHeight(bounds) - Spacing - height);
        for (NSInteger i = 0; i < uids.count; ++i) {
            NSView *view = _allRenderViews[uids[i]];
            view.frame = (NSRect){point, size};
            view.autoresizingMask = NSViewMinYMargin | NSViewMinXMargin | NSViewMaxXMargin;
            point.x += (width + Spacing);
        }
    }
}

- (void)_layoutInBounds:(NSRect)bounds {
    if (self.layoutStyle == 2) {
        [self layoutWithGridStyle:bounds];
    } else {
        [self layoutWithSplitStyle:bounds];
    }
}

- (void)updateLayoutVideoFrame{
    [self _layoutInBounds:self.videoLayoutView.bounds];
    
    for (int i = 0;i < _allRenderViews.count;i++) {
        NSView *videoView = [_allRenderViews objectForKey:[_allRenderViews allKeys][i]];
        NSTextField *titleView = [videoView viewWithTag:1001];
        NSSize size = [[_allRenderViews allKeys][i] sizeWithAttributes:@{NSFontAttributeName:titleView.font}];
        CGFloat height = 20;
        titleView.frame = CGRectMake(0, videoView.frame.size.height - height, size.width + 10, height);
        titleView.autoresizingMask = NSViewMinYMargin | NSViewMaxXMargin;
        [videoView addSubview:titleView positioned:NSWindowAbove relativeTo:nil];
        
    }
    if (_allRenderViews.count > 1) {
        self.videoLayoutStyleBtn.hidden = NO;
    }
    else{
        self.videoLayoutStyleBtn.hidden = YES;
    }
}

#pragma mark - 连麦回调
- (void)onConnectOtherRoom:(NSString*)userId errCode:(TXLiteAVError)errCode errMsg:(nullable NSString *)errMsg;
{
    if (errCode != 0) {
        self.connectingRoom = NO;
        NSString *msg = [NSString stringWithFormat:@"%@ (%d)", errMsg, (int)errCode];
        [self.window presentError:[NSError errorWithDomain:@"TRTC" code:errCode userInfo:@{NSLocalizedDescriptionKey: msg}]];
    }
}

- (void)onDisconnectOtherRoom:(TXLiteAVError)errCode errMsg:(NSString *)errMsg {
    if (errCode != 0) {
        NSString *msg = [NSString stringWithFormat:@"%@ (%d)", errMsg, (int)errCode];
        [self.window presentError:[NSError errorWithDomain:@"TRTC" code:errCode userInfo:@{NSLocalizedDescriptionKey: msg}]];
    }
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

- (IBAction)videoSelectViewClick:(id)sender {
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

- (IBAction)audioSelectViewClick:(id)sender {
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

#pragma mark - 渲染视图中的工具按钮事件
- (void)onRenderViewToolbarRotateClicked:(NSString *)userId {
    NSNumber *box = self.rotationState[userId];
    TRTCVideoRotation r = box ? box.integerValue : TRTCVideoRotation_0;
    r = (box.intValue + 1) % 4;
    self.rotationState[userId] = @(r);

    if ([userId isEqualToString:self.userId]) {
        [self.trtcEngine setLocalViewRotation:r];
    } else {
        [self.trtcEngine setRemoteViewRotation:userId rotation:r];
    }
}

- (void)onRenderViewToolbarStreamClicked:(NSString *)userId {
    NSNumber *box = self.bigSmallStreamState[userId];
    TRTCVideoStreamType typeList[] = {TRTCVideoStreamTypeBig, TRTCVideoStreamTypeSmall};
    NSInteger index = (box.integerValue + 1) % 2;
    TRTCVideoStreamType type = typeList[index];
    self.bigSmallStreamState[userId] = @(type);
    [self.trtcEngine setRemoteVideoStreamType:userId type:type];
}

- (void)onRenderViewToolbarVideoClicked:(NSString *)userId index:(NSNumber *)index {
    if (index.intValue == 1) {
        [self.trtcEngine stopRemoteView:userId];
    } else {
        [self.trtcEngine startRemoteView:userId view:[self renderViewForUser:userId].contentView];
    }

}

- (void)onRenderViewToolbarAudioClicked:(NSString *)userId index:(NSNumber *)index {
    [self.trtcEngine muteRemoteAudio:userId mute:index.intValue == 1];
}

- (void)onRenderViewToolbarScreenShareClicked:(NSString *)userId {
    [self _playScreenCaptureForUser:userId];
}

- (void)onRenderViewToolbarFillModeChanged:(NSString *)userId index:(NSNumber *)index {
    TRTCVideoFillMode mode = index.intValue == 1 ? TRTCVideoFillMode_Fill : TRTCVideoFillMode_Fit;
    if ([userId isEqualToString:self.currentUserParam.userId]) {
        [self.trtcEngine setLocalViewFillMode:mode];
    } else {
        [self.trtcEngine setRemoteViewFillMode:userId mode:mode];
    }
}
@end

