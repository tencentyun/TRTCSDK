//
//  TXLiteAVRoomWC.m
//  TXLiteAVMacDemo
//
//  Created by ericxwli on 2018/10/10.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TRTCMainWindowController.h"
#import "TRTCCloud.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "TXRenderView.h"
#import "HoverView.h"

@interface TRTCMainWindowController () <NSWindowDelegate,NSTableViewDelegate,NSTableViewDataSource, TRTCCloudDelegate, TRTCLogDelegate>
/// TRTC SDK 实例对象
@property(nonatomic,strong) TRTCCloud *trtcEngine;

// 进房参数
@property(nonatomic,readonly,strong) TRTCParams *currentUserParam;
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
// 各路视频的旋转方向, key为uid
@property(nonatomic,strong) NSMutableDictionary<NSString *, NSNumber *> *rotationState;
// 各路视频的大小流设置, key为uid
@property(nonatomic,strong) NSMutableDictionary<NSString *, NSNumber *> *bigSmallStreamState;

@end

@implementation TRTCMainWindowController

- (instancetype)initWithParams:(TRTCParams *)params {
    if (self = [super initWithWindowNibName:@"TRTCMainWindowController"]) {
        _currentUserParam = params;
        
        self.layoutStyle = 1;
        self.trtcEngine = [(AppDelegate*)[NSApp delegate] getTRTCEngine];
        self.trtcEngine.delegate = self;
        self.allRenderViews = [NSMutableDictionary dictionary];
        self.rotationState = [NSMutableDictionary dictionary];
        self.bigSmallStreamState = [NSMutableDictionary dictionary];
        
        self.allUids = [NSMutableArray array];
    }
    return self;
}

- (void)_configButton:(NSButton *)button title:(NSString *)title color:(NSColor *)color {
    button.title = title;
    button.attributedTitle = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:color}];
    button.imagePosition = NSImageAbove;
    button.imageScaling = NSImageScaleNone;
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
    [self _configButton:self.micBtn title:@"静音"];
    [self _configButton:self.videoBtn title:@"停止视频"];
    [self _configButton:self.beautyBtn title:@"美颜" color:[NSColor redColor]];
    [self _configButton:self.closeBtn title:@"结束会议" color:[NSColor redColor]];
    [self _configButton:self.logBtn title:@"仪表盘" color:[NSColor redColor]];
    [self _configButton:self.videoLayoutStyleBtn title:@"画廊视图"];
    self.videoLayoutStyleBtn.layer.backgroundColor = [NSColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1.0].CGColor;
    self.videoLayoutStyleBtn.hidden = YES;

    // 设置按钮在鼠标悬浮时高亮
    [self.micBtn setHover];
    [self.videoBtn setHover];
    [self.videoSelectBtn setHover];
    [self.audioSelectBtn setHover];
    [self.closeBtn setHover];
    [self.videoLayoutStyleBtn setHover];

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
    [(AppDelegate*)[NSApp delegate] closePreference];
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
- (UInt32)roomID {
    return _currentUserParam.roomId;
}

- (NSString *)userId {
    return _currentUserParam.userId;
}


// 本地预览视图
- (NSView *)localVideoRenderView {
    return _allRenderViews[self.userId];
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
        [self.micBtn setImage:[NSImage imageNamed:@"mic_dis"]];
        self.micBtn.title = @"解除静音";
        NSMutableAttributedString *attTitle = [[NSMutableAttributedString alloc]initWithAttributedString:self.micBtn.attributedTitle];
        NSDictionary *dicAtt =@{NSForegroundColorAttributeName:[NSColor whiteColor]};
        [attTitle addAttributes:dicAtt range:NSMakeRange(0,4)];
        self.micBtn.attributedTitle = attTitle;
        [self.trtcEngine muteLocalAudio:YES];

    }
    else{
        [self.micBtn setImage:[NSImage imageNamed:@"mic"]];
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
        [self.videoBtn setImage:[NSImage imageNamed:@"video_off"]];
        self.videoBtn.title = @"开启视频";
        NSMutableAttributedString *attTitle = [[NSMutableAttributedString alloc]initWithAttributedString:self.videoBtn.attributedTitle];
        NSDictionary *dicAtt =@{NSForegroundColorAttributeName:[NSColor whiteColor]};
        [attTitle addAttributes:dicAtt range:NSMakeRange(0,4)];
        self.videoBtn.attributedTitle = attTitle;
//        [self.trtcEngine stopVideoCapture];
        [self.trtcEngine stopLocalPreview];
    }
    else{
        [self.videoBtn setImage:[NSImage imageNamed:@"video_on"]];
        self.videoBtn.title = @"停止视频";
        NSMutableAttributedString *attTitle = [[NSMutableAttributedString alloc]initWithAttributedString:self.videoBtn.attributedTitle];
        NSDictionary *dicAtt =@{NSForegroundColorAttributeName:[NSColor whiteColor]};
        [attTitle addAttributes:dicAtt range:NSMakeRange(0,4)];
        self.videoBtn.attributedTitle = attTitle;
        [self.trtcEngine startLocalPreview:_allRenderViews[self.userId]];
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
        self.videoLayoutStyleBtn.image = [NSImage imageNamed:@"galleryMode"];
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

#pragma mark - 进房与音视频事件
/**
 * 加入视频房间：使用从 TRTCNewViewController 实例化时传入的 TRTCParams
 */
- (void)enterRoom {
    TRTCParams *param = _currentUserParam;
    TRTCVideoEncParam *qualityConfig = [[TRTCVideoEncParam alloc] init];
    qualityConfig.videoResolution = TRTCSettingWindowController.resolution;
    qualityConfig.videoFps = TRTCSettingWindowController.fps;
    qualityConfig.videoBitrate = TRTCSettingWindowController.bitrate;
    
    [self.trtcEngine setLocalVideoQuality:qualityConfig qosControl:TRTCSettingWindowController.qosControlMode qosPreference:TRTCSettingWindowController.qosControlPreference];
    [self.trtcEngine setLocalViewFillMode:TRTCVideoFillMode_Fit];
    
    //        [self.trtcEngine setPriorRemoteVideoStreamType:TRTCVideoStreamTypeSmall];
    
    TRTCVideoEncParam *smallVideoConfig = [[TRTCVideoEncParam alloc] init];
    smallVideoConfig.videoResolution = TRTCVideoResolution_160_120;
    smallVideoConfig.videoFps = 15;
    smallVideoConfig.videoBitrate = 100;
    
    [self.trtcEngine enableEncSmallVideoStream:YES withQuality:smallVideoConfig];
    //        config.renderMode = ETRTCVideoRenderModeFit; // 默认带黑边的渲染模式
    
    // 开启视频采集预览
    NSView *videoView = [self addRenderViewAt:self.userId];
    [self.trtcEngine setLocalViewFillMode:TRTCVideoFillMode_Fit];
    [self.trtcEngine startLocalPreview:videoView];
    // 进房
    [self.trtcEngine enterRoom:param];
}

- (void)onEnterRoom:(NSInteger)elapsed{
//  [self.trtcEngine enableAudioVolumeIndication:0.1 smooth:3];
    
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
    [self removeRenderViewAt:userId];
}

- (void)onUserEnter:(NSString *)userId {
    NSView *videoView = [self addRenderViewAt:userId];
    [self.trtcEngine startRemoteView:userId view:videoView];
    [self.trtcEngine setRemoteViewFillMode:userId mode:TRTCVideoFillMode_Fit];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateLayoutVideoFrame];
    });
    
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

- (NSView *)addRenderViewAt:(NSString *)videoId{
    TXRenderView *videoView = _allRenderViews[videoId];
    if (!videoView) {
        videoView = [[TXRenderView alloc] init];
        [videoView addToolbarItem:@"R" target:self action:@selector(onRenderViewToolbarRotateClicked:) context:videoId];

        if (![videoId isEqualToString:self.userId]) {
            [videoView addToolbarItem:@"流" target:self action:@selector(onRenderViewToolbarStreamClicked:) context:videoId];
        }
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

- (void)removeRenderViewAt:(NSString *)videoId{
    NSView *videoView = _allRenderViews[videoId];
    [videoView removeFromSuperview];
    [_allRenderViews removeObjectForKey:videoId];
    [_allUids removeObject:videoId];
    [self.rotationState removeObjectForKey:videoId];
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
        [(AppDelegate*)[NSApp delegate] showPreferenceWithTabIndex:TXAVSettingTabIndexVideo];
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
        [(AppDelegate*)[NSApp delegate] showPreferenceWithTabIndex:TXAVSettingTabIndexAudio];
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
    TRTCVideoStreamType type = box ? box.integerValue : TRTCVideoStreamTypeBig;
    type = type == TRTCVideoStreamTypeBig ? TRTCVideoStreamTypeSmall : TRTCVideoStreamTypeBig;
    self.bigSmallStreamState[userId] = @(type);
    [self.trtcEngine setRemoteVideoStreamType:userId type:type];
}
@end

