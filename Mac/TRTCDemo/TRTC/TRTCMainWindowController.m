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

typedef NS_ENUM(NSUInteger, LayoutStyle) {
    LayoutStyleGalleryView        = 1,
    LayoutStylePresenterView      = 2,
    LayoutStyleGalleryDefault = LayoutStyleGalleryView,
};

@interface TRTCMainWindowController () <NSWindowDelegate,NSTableViewDelegate,NSTableViewDataSource, TRTCCloudDelegate, TRTCLogDelegate>
{
    NSMutableDictionary *_mixTransCodeInfo;
    dispatch_source_t _hidePanelTimer;
    BOOL _shouldHideControlBar;
}
/// TRTC SDK 实例对象
@property(nonatomic,strong) TRTCCloud *trtcEngine;

// 进房参数
@property(nonatomic,readonly,strong) TRTCParams *currentUserParam;
@property(nonatomic,readonly,assign) TRTCAppScene scene;
@property(nonatomic,readonly,assign) BOOL audioOnly;

// 用于鼠标移出后隐藏菜单栏
@property(nonatomic,strong) NSTrackingArea *trackingArea;

// 视频容器
@property(nonatomic,strong) NSView *videoLayoutView;

@property(nonatomic,strong) NSMutableArray *micArr;
@property(nonatomic,strong) NSMutableArray *speakerArr;
@property(nonatomic,strong) NSMutableArray *cameraArr;

// key为uid, value为对应的渲染view
@property(nonatomic,strong) NSMutableDictionary *renderViewMap;
// 排序的uid
@property(nonatomic,strong) NSMutableArray *allUids;
// 1. 画廊模式, 2. 演讲者模式
@property(nonatomic,assign) LayoutStyle layoutStyle;

// 屏幕捕捉
@property(nonatomic,strong) TXCaptureSourceWindowController *captureSourceWindowController;
@property(nonatomic,copy) NSString * presentingScreenCaptureUid;

// 各路视频的旋转方向, key为uid
@property(nonatomic,strong) NSMutableDictionary<NSString *, NSNumber *> *rotationState;
// 各路视频的大小流设置, key为uid
@property(nonatomic,strong) NSMutableDictionary<NSString *, NSNumber *> *bigSmallStreamState;
// 混流信息，key为uid value为roomId
@property(nonatomic, strong) NSMutableDictionary* pkInfos;

// 正在进行的屏幕分享源
@property(nonatomic, strong) TRTCScreenCaptureSourceInfo *screenCaptureInfo;

@end

@implementation TRTCMainWindowController

- (instancetype)initWithEngine:(TRTCCloud *)engine params:(TRTCParams *)params scene:(TRTCAppScene)scene {
    if (self = [super initWithWindowNibName:@"TRTCMainWindowController"]) {
        _currentUserParam = params;
        _scene = scene;
        self.layoutStyle = LayoutStyleGalleryDefault;
        self.trtcEngine = engine;
        self.trtcEngine.delegate = self;
        self.renderViewMap = [NSMutableDictionary dictionary];
        self.rotationState = [NSMutableDictionary dictionary];
        self.bigSmallStreamState = [NSMutableDictionary dictionary];
        self.allUids = [NSMutableArray array];
        _mixTransCodeInfo = [NSMutableDictionary dictionary];
        _pkInfos = [NSMutableDictionary new];
        [TRTCSettingWindowController addObserver:self forKeyPath:NSStringFromSelector(@selector(cloudMixEnabled)) options:NSKeyValueObservingOptionNew context:NULL];
        [TRTCSettingWindowController addObserver:self forKeyPath:NSStringFromSelector(@selector(isAudience)) options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)dealloc {
    [TRTCSettingWindowController removeObserver:self forKeyPath:NSStringFromSelector(@selector(cloudMixEnabled))];
    [TRTCSettingWindowController removeObserver:self forKeyPath:NSStringFromSelector(@selector(isAudience))];

    [self _cancelHidePanelTimer];
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
    self.window.title = [NSString stringWithFormat:@"房间%u",self.roomID];
    self.window.backgroundColor = [NSColor whiteColor];
    
    // 添加本地视频预览 View
    [self.window.contentView addSubview:self.videoLayoutView positioned:NSWindowBelow relativeTo:nil];
    
    // 底部工具栏
    self.controlBar.wantsLayer = true;
    self.controlBar.layer.backgroundColor = [NSColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1.0].CGColor;
    self.controlBar.hidden = YES;
    
    // 配置底部工具栏自动隐藏
    [self setupTrackingArea];

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

// 窗口改变时重新布局
- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize
{
    if (frameSize.width < sender.minSize.width) {
        frameSize.width = sender.minSize.width;
    }
    if (frameSize.height < sender.minSize.height) {
        frameSize.height = sender.minSize.height;
    }
    NSSize size = frameSize;
    size.height = [NSWindow contentRectForFrameRect:(NSRect){NSZeroPoint, frameSize} styleMask:sender.styleMask].size.height;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        [self _layoutInBounds:(NSRect){NSZeroPoint, size}];
    } completionHandler:nil];
    return frameSize;
}

- (void)windowDidResize:(NSNotification *)notification {
    [self setupTrackingArea];
}

#pragma mark - 窗口标题
- (void)updateWindowTitle {
    NSString *title = [NSString stringWithFormat:@"房间%u",self.roomID];
    if (self.screenCaptureInfo) {
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

#pragma mark - 底部工具栏控制
// 鼠标跟踪移动检测
- (void)mouseEntered:(NSEvent *)event {
    [self setControlBarHidden:NO];
    [self _cancelHidePanelTimer];
}

- (void)mouseExited:(NSEvent *)event {
    [self setControlBarHidden:YES];
}

- (void)mouseDown:(NSEvent *)event
{
    [self.videoSelectView enclosingScrollView].hidden = YES;
    [self.audioSelectView enclosingScrollView].hidden = YES;
}

- (void)_createHidePanelTimerWithBlock:(void(^)(TRTCMainWindowController*))action {
    __weak __typeof(self) wself = self;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0.1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        TRTCMainWindowController *self = wself;
        if (self && self->_hidePanelTimer) {
            action(self);
        }
    });
    dispatch_resume(timer);
    _hidePanelTimer = timer;
}

- (void)_cancelHidePanelTimer {
    if (_hidePanelTimer) {
        dispatch_source_cancel(_hidePanelTimer);
        _hidePanelTimer = nil;
    }
}

- (void)setControlBarHidden:(BOOL)hidden {
    BOOL shouldHide = hidden;
    if ([self.audioSelectView enclosingScrollView].hidden == NO || [self.videoSelectView enclosingScrollView].hidden == NO) {
        shouldHide = NO;
    }
    _shouldHideControlBar = shouldHide;
    if (self.controlBar.hidden == shouldHide) {
        return;
    }
    
    void (^animationBlock)(TRTCMainWindowController *self) = ^(TRTCMainWindowController *self){
        if (nil == self) return;
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            context.allowsImplicitAnimation = YES;
            self.controlBar.alphaValue = shouldHide ? 0.0 : 1.0;
        } completionHandler:^{
            self.controlBar.hidden = self->_shouldHideControlBar;
            self.controlBar.alphaValue = 1.0;
            [self _cancelHidePanelTimer];
        }];
    };
    
    if (hidden) {
        if (_hidePanelTimer) {
            return;
        }
        [self _createHidePanelTimerWithBlock:animationBlock];
    } else {
        if (_hidePanelTimer) {
            dispatch_cancel(_hidePanelTimer);
            _hidePanelTimer = nil;
        }
        animationBlock(self);
    }
}

#pragma mark - Notification Observer
//关闭窗口退出房间
-(void)windowWillClose:(NSNotification *)notification{
    [self.trtcEngine exitRoom];
    [self.trtcEngine stopLocalPreview];
    [self.beautyPanel close];
    [self.capturePreviewWindow close];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Logout" object:self];
}

#pragma mark - Setting Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object != TRTCSettingWindowController.class) {
        return;
    }
    if ([keyPath isEqualToString:@"cloudMixEnabled"])
        [self updateCloudMixtureParams];
    
    if ([keyPath isEqualToString:@"isAudience"]) {
        BOOL isAudience = ((NSNumber*)change[@"new"]).boolValue;
        [self roleChanged:isAudience];
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
    return _renderViewMap[self.userId];
}

- (TXRenderView *)renderViewForUser:(NSString *)userId {
    return _renderViewMap[userId];
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
- (IBAction)onClickAudioMute:(id)sender {
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

- (IBAction)onClickVideoMute:(id)sender {
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
        if (self == nil) return;
        if (source == nil) {
            [self.trtcEngine stopScreenCapture];
        } else if (source.type != TRTCScreenCaptureSourceTypeUnknown) {
            if (source.type == TRTCScreenCaptureSourceTypeWindow) {
                [self.trtcEngine selectScreenCaptureTarget:source rect:CGRectZero capturesCursor:NO highlight:YES];
            } else if (source.type == TRTCScreenCaptureSourceTypeScreen) {
                [self.trtcEngine selectScreenCaptureTarget:source rect:CGRectZero capturesCursor:YES highlight:NO];
            }
            [self.trtcEngine startScreenCapture:nil];
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

- (IBAction)onClickLog:(id)sender {
    NSButton *shareBtn = (NSButton *)sender;
    if (shareBtn.state == 1) {
        [self.trtcEngine showDebugView:2];
    } else {
        [self.trtcEngine showDebugView:0];
    }
}

- (IBAction)onClickLayout:(id)sender {
    if (self.layoutStyle == LayoutStyleGalleryView) {
        self.layoutStyle = LayoutStylePresenterView;
        self.videoLayoutStyleBtn.title = @"演讲者视图";
        self.videoLayoutStyleBtn.image = [NSImage imageNamed:@"speakerMode"];
        NSMutableAttributedString *attTitle = [[NSMutableAttributedString alloc]initWithAttributedString:self.videoLayoutStyleBtn.attributedTitle];
        NSDictionary *dicAtt =@{NSForegroundColorAttributeName:[NSColor whiteColor]};
        [attTitle addAttributes:dicAtt range:NSMakeRange(0,5)];
        self.videoLayoutStyleBtn.attributedTitle = attTitle;
    } else if (self.layoutStyle == LayoutStylePresenterView){
        self.layoutStyle = LayoutStyleGalleryView;
        self.videoLayoutStyleBtn.title = @"画廊视图";
        self.videoLayoutStyleBtn.image = [NSImage imageNamed:@"main_layout_gallery"];
        NSMutableAttributedString *attTitle = [[NSMutableAttributedString alloc]initWithAttributedString:self.videoLayoutStyleBtn.attributedTitle];
        NSDictionary *dicAtt =@{NSForegroundColorAttributeName:[NSColor whiteColor]};
        [attTitle addAttributes:dicAtt range:NSMakeRange(0,4)];
        self.videoLayoutStyleBtn.attributedTitle = attTitle;
    }
    [self updateLayoutVideoFrame];
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
        [self.trtcEngine startRemoteSubStreamView:userId view:self.capturePreviewWindow.contentView];
    }
    [self.capturePreviewWindow orderFront:self];
    self.capturePreviewWindow.title = [NSString stringWithFormat:@"%@的屏幕分享", userId];
    self.presentingScreenCaptureUid = userId;
}

#pragma mark - 错误与警告
- (void)onError:(TXLiteAVError)errCode errMsg:(NSString *)errMsg extInfo:(NSDictionary *)extInfo {
    if(errCode == ERR_ROOM_REQUEST_TOKEN_HTTPS_TIMEOUT ||
       errCode == ERR_ROOM_REQUEST_IP_TIMEOUT ||
       errCode == ERR_ROOM_REQUEST_ENTER_ROOM_TIMEOUT) {
        NSLog(@"%@",[NSString stringWithFormat:@"进房超时，请检查网络或稍后重试:%d[%@]", errCode, errMsg]);
        [self exitRoom];
        return;
    }
    
    if(errCode == ERR_ROOM_REQUEST_TOKEN_INVALID_PARAMETER ||
       errCode == ERR_ENTER_ROOM_PARAM_NULL ||
       errCode == ERR_SDK_APPID_INVALID ||
       errCode == ERR_ROOM_ID_INVALID ||
       errCode == ERR_USER_ID_INVALID ||
       errCode == ERR_USER_SIG_INVALID) {
        NSLog(@"%@", [NSString stringWithFormat:@"进房参数错误:%d[%@]", errCode, errMsg]);
        [self exitRoom];
        return;
    }
    
    if(errCode == ERR_ACCIP_LIST_EMPTY ||
       errCode == ERR_SERVER_INFO_UNPACKING_ERROR ||
       errCode == ERR_SERVER_INFO_TOKEN_ERROR ||
       errCode == ERR_SERVER_INFO_ALLOCATE_ACCESS_FAILED ||
       errCode == ERR_SERVER_INFO_GENERATE_SIGN_FAILED ||
       errCode == ERR_SERVER_INFO_TOKEN_TIMEOUT ||
       errCode == ERR_SERVER_INFO_INVALID_COMMAND ||
       errCode == ERR_SERVER_INFO_GENERATE_KEN_ERROR ||
       errCode == ERR_SERVER_INFO_GENERATE_TOKEN_ERROR ||
       errCode == ERR_SERVER_INFO_DATABASE ||
       errCode == ERR_SERVER_INFO_BAD_ROOMID ||
       errCode == ERR_SERVER_INFO_BAD_SCENE_OR_ROLE ||
       errCode == ERR_SERVER_INFO_ROOMID_EXCHANGE_FAILED ||
       errCode == ERR_SERVER_INFO_STRGROUP_HAS_INVALID_CHARS ||
       errCode == ERR_SERVER_ACC_TOKEN_TIMEOUT ||
       errCode == ERR_SERVER_ACC_SIGN_ERROR ||
       errCode == ERR_SERVER_ACC_SIGN_TIMEOUT ||
       errCode == ERR_SERVER_CENTER_INVALID_ROOMID ||
       errCode == ERR_SERVER_CENTER_CREATE_ROOM_FAILED ||
       errCode == ERR_SERVER_CENTER_SIGN_ERROR ||
       errCode == ERR_SERVER_CENTER_SIGN_TIMEOUT ||
       errCode == ERR_SERVER_CENTER_ADD_USER_FAILED ||
       errCode == ERR_SERVER_CENTER_FIND_USER_FAILED ||
       errCode == ERR_SERVER_CENTER_SWITCH_TERMINATION_FREQUENTLY ||
       errCode == ERR_SERVER_CENTER_LOCATION_NOT_EXIST ||
       errCode == ERR_SERVER_CENTER_ROUTE_TABLE_ERROR ||
       errCode == ERR_SERVER_CENTER_INVALID_PARAMETER) {
        NSLog(@"%@", [NSString stringWithFormat:@"进房失败，请稍后重试:%d[%@]", errCode, errMsg]);
        [self exitRoom];
        return;
    }
    
    if(errCode == ERR_SERVER_CENTER_ROOM_FULL ||
       errCode == ERR_SERVER_CENTER_REACH_PROXY_MAX) {
        NSLog(@"%@", [NSString stringWithFormat:@"进房失败，房间满了，请稍后重试:%d[%@]", errCode, errMsg]);
        [self exitRoom];
        return;
    }
    
    if(errCode == ERR_SERVER_CENTER_ROOM_ID_TOO_LONG) {
        NSLog(@"%@", [NSString stringWithFormat:@"进房失败，roomID超出有效范围:%d[%@]", errCode, errMsg]);
        [self exitRoom];
        return;
    }
    
    if(errCode == ERR_SERVER_ACC_ROOM_NOT_EXIST ||
       errCode == ERR_SERVER_CENTER_ROOM_NOT_EXIST) {
        NSLog(@"%@", [NSString stringWithFormat:@"进房失败，请确认房间号正确:%d[%@]", errCode, errMsg]);
        [self exitRoom];
        return;
    }
    
    if(errCode == ERR_SERVER_INFO_SERVICE_SUSPENDED) {
        NSLog(@"%@", [NSString stringWithFormat:@"进房失败，请确认腾讯云实时音视频账号状态是否欠费:%d[%@]", errCode, errMsg]);
        [self exitRoom];
        return;
    }
    
    if(errCode == ERR_SERVER_INFO_PRIVILEGE_FLAG_ERROR ||
       errCode == ERR_SERVER_CENTER_NO_PRIVILEDGE_CREATE_ROOM ||
       errCode == ERR_SERVER_CENTER_NO_PRIVILEDGE_ENTER_ROOM) {
        NSLog(@"%@", [NSString stringWithFormat:@"进房失败，无权限进入房间:%d[%@]", errCode, errMsg]);
        [self exitRoom];
        return;
    }
    
    if(errCode <= ERR_SERVER_SSO_SIG_EXPIRED  &&
       errCode >= ERR_SERVER_SSO_INTERNAL_ERROR) {
        // 错误参考 https://cloud.tencent.com/document/product/269/1671#.E5.B8.90.E5.8F.B7.E7.B3.BB.E7.BB.9F
        NSLog(@"%@", [NSString stringWithFormat:@"进房失败，userSig错误:%d[%@]", errCode, errMsg]);
        [self exitRoom];
        return;
    }

    if (errCode == ERR_SERVER_CENTER_ANOTHER_USER_PUSH_SUB_VIDEO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"屏幕分享发起失败";
            alert.informativeText = @"房间内已经有人发起了屏幕分享";
            [alert runModal];
        });
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
    [self.trtcEngine setLocalViewFillMode:TRTCVideoFillMode_Fit];
    
    //        [self.trtcEngine setPriorRemoteVideoStreamType:TRTCVideoStreamTypeSmall];
    if (TRTCSettingWindowController.pushDoubleStream) {
        TRTCVideoEncParam *smallVideoConfig = [[TRTCVideoEncParam alloc] init];
        smallVideoConfig.videoResolution = TRTCVideoResolution_160_120;
        smallVideoConfig.videoFps = 15;
        smallVideoConfig.videoBitrate = 100;
        smallVideoConfig.resMode = TRTCSettingWindowController.resolutionMode;
        [self.trtcEngine enableEncSmallVideoStream:TRTCSettingWindowController.pushDoubleStream
                                       withQuality:smallVideoConfig];
    }
    //        config.renderMode = ETRTCVideoRenderModeFit; // 默认带黑边的渲染模式
    
    // 开启视频采集预览
    TXRenderView *videoView = [self addRenderViewForUser:self.userId];
    [self.trtcEngine setLocalViewFillMode:TRTCVideoFillMode_Fit];
    if (!self.audioOnly) {
        [self.trtcEngine startLocalPreview:videoView.contentView];

    } else {
        param.bussInfo = @"{\"Str_uc_params\":{\"pure_audio_push_mod\":1}}";
    }
    [self.trtcEngine startLocalAudio];
    [self.trtcEngine muteLocalAudio:NO];
    // 进房
    [self.trtcEngine enterRoom:param appScene:_scene];
}

- (void)onEnterRoom:(NSInteger)elapsed{
    [self.trtcEngine enableAudioVolumeEvaluation:300];
    if (self.audioOnly) {
        [self.trtcEngine muteLocalVideo:YES];
    }
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
    [self updateCloudMixtureParams];
}

- (void)onFirstVideoFrame:(NSString *)userId streamType:(TRTCVideoStreamType)streamType width:(int)width height:(int)height {
    if (streamType == TRTCVideoStreamTypeSub && [userId isEqualToString:self.presentingScreenCaptureUid]) {
        NSSize maxSize = self.capturePreviewWindow.screen.visibleFrame.size;
        maxSize.width /= 2;
        maxSize.height /= 2;
        if (width > maxSize.width) {
            width = maxSize.width;
        }
        if (height > maxSize.height) {
            height = maxSize.height;
        }
        [self.capturePreviewWindow setContentSize:NSMakeSize(width, height)];
        [self.capturePreviewWindow orderFront:nil];
    }
}

- (void)onUserSubStreamAvailable:(NSString *)userId available:(BOOL)available {
    if (available) {
        if (![self.capturePreviewWindow isVisible]) {
            [self _playScreenCaptureForUser:userId];
        }
        [self.capturePreviewWindow orderOut:nil];
        TXRenderView *renderView = [self renderViewForUser: userId];
        [renderView addTextToolbarItem:@"屏" target:self action:@selector(onRenderViewToolbarScreenShareClicked:) context:userId];
    } else {
        if ([userId isEqualToString:self.presentingScreenCaptureUid]){
            [self.capturePreviewWindow close];
            self.presentingScreenCaptureUid = nil;
        }
        TXRenderView *renderView = [self renderViewForUser: userId];
        [renderView removeToolbarWithTitle:@"屏"];
    }
}

- (void)onUserEnter:(NSString *)userId {
    [self addRenderViewForUser:userId];
    [self.trtcEngine setRemoteViewFillMode:userId mode:TRTCVideoFillMode_Fit];

    if (TRTCSettingWindowController.playSmallStream) {
        self.bigSmallStreamState[userId] = @(TRTCVideoStreamTypeSmall);
        [self.trtcEngine setRemoteVideoStreamType:userId type:TRTCVideoStreamTypeSmall];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateLayoutVideoFrame];
    });
    [self updateCloudMixtureParams];
}

- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available
{
    //远程画面
    if (userId != nil) {
        TXRenderView* videoView = [self renderViewForUser:userId];
        if (available) {
            [self.trtcEngine startRemoteView:userId view:videoView.contentView];
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
    [[self localVideoRenderView] setSignal:localQuality.quality];
    
    for (TRTCQualityInfo* qualityInfo in remoteQuality) {
        [[self renderViewForUser:qualityInfo.userId] setSignal:qualityInfo.quality];
    }
}

- (void)onUserVoiceVolume:(NSArray<TRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume
{
    [_renderViewMap enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, TXRenderView * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj setVolume:0.f];
    }];
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
/*
- (void)onStatistics:(TRTCStatistics *)statistics {
    
}
 */

- (void)exitRoom
{
    [self.trtcEngine exitRoom];
    [self.trtcEngine stopLocalPreview];
}
#pragma mark - 混流
- (void)stopCloudMixTranscoding {
    _mixTransCodeInfo = [NSMutableDictionary dictionary];
    [self.trtcEngine setMixTranscodingConfig:nil];
}

- (void)updateCloudMixtureParams
{
    BOOL enable = [TRTCSettingWindowController cloudMixEnabled];
    if (!enable) {
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
            subWidth    = 48;
            subHeight   = 27;
            offsetY     = 20;
            bitrate     = 200;
            break;
        }
        case TRTCVideoResolution_320_180:
        {
            videoWidth  = 336;
            videoHeight = 192;
            subWidth    = 96;
            subHeight   = 54;
            offsetY     = 30;
            bitrate     = 400;
            break;
        }
        case TRTCVideoResolution_320_240:
        {
            videoWidth  = 320;
            videoHeight = 240;
            subWidth    = 96;
            subHeight   = 54;
            bitrate     = 400;
            break;
        }
        case TRTCVideoResolution_480_480:
        {
            videoWidth  = 480;
            videoHeight = 480;
            subWidth    = 128;
            subHeight   = 72;
            bitrate     = 600;
            break;
        }
        case TRTCVideoResolution_640_360:
        {
            videoWidth  = 640;
            videoHeight = 368;
            subWidth    = 160;
            subHeight   = 90;
            bitrate     = 800;
            break;
        }
        case TRTCVideoResolution_640_480:
        {
            videoWidth  = 640;
            videoHeight = 480;
            subWidth    = 160;
            subHeight   = 90;
            bitrate     = 800;
            break;
        }
        case TRTCVideoResolution_960_540:
        {
            videoWidth  = 960;
            videoHeight = 544;
            subWidth    = 304;
            subHeight   = 171;
            bitrate     = 1000;
            break;
        }
        case TRTCVideoResolution_1280_720:
        {
            videoWidth  = 1280;
            videoHeight = 720;
            subWidth    = 320;
            subHeight   = 180;
            bitrate     = 1500;
            break;
        }
    }
    
    TRTCTranscodingConfig* config = [TRTCTranscodingConfig new];
    config.appId = self.currentUserParam.sdkAppId;
    config.bizId = <#bizID#>;;
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
    broadCaster.userId = self.currentUserParam.userId; // 以主播uid为broadcaster为例
    broadCaster.zOrder = 0;
    broadCaster.rect = CGRectMake(0, 0, videoWidth, videoHeight);
    broadCaster.roomID = nil;
    
    NSMutableArray* mixUsers = [NSMutableArray new];
    [mixUsers addObject:broadCaster];
    
    // 设置混流后各个小画面的位置
    int index = 0;
    NSDictionary* pkUsers = self.pkInfos;
    int i = 0;
    
    int mixWidth = subWidth;// videoWidth / 3.0;
    int mixHeight = subHeight;// videoHeight / 3.0;
    
    NSMutableArray* userIdArray = _renderViewMap.allKeys.mutableCopy;
    if (self.presentingScreenCaptureUid) {
        [userIdArray addObject:self.presentingScreenCaptureUid];
    }
    
    for (NSString* userId in userIdArray) {
        if ([userId isEqualToString:self.currentUserParam.userId]) {
            continue;
        }
        ++i;
        TRTCMixUser* audience = [TRTCMixUser new];
        audience.userId = userId;
        audience.zOrder = 1 + index;
        audience.roomID = [pkUsers objectForKey:userId];
        
        CGRect container;
        if (i < 3) {
            container = CGRectMake(config.videoWidth - mixWidth, videoHeight - i * mixHeight, mixWidth, mixHeight);
        } else {
            // 后三个小画面靠左从下往上铺
            container = CGRectMake(0, videoHeight - (i - 3) * mixHeight, mixWidth, mixHeight);
        }
        audience.rect = container;
//        if (index < 3) {
//            // 前三个小画面靠右从下往上铺
//            audience.rect = CGRectMake(videoWidth - offsetX - subWidth, videoHeight - offsetY - index * subHeight - subHeight, subWidth, subHeight);
//        } else if (index < 6) {
//            // 后三个小画面靠左从下往上铺
//            audience.rect = CGRectMake(offsetX, videoHeight - offsetY - (index - 3) * subHeight - subHeight, subWidth, subHeight);
//        } else {
//            // 最多只叠加六个小画面
//        }
        
        [mixUsers addObject:audience];
        ++index;
    }
    config.mixUsers = mixUsers;
    [_trtcEngine setMixTranscodingConfig:config];
}

#pragma makr - 角色变化
- (void)roleChanged:(BOOL)isAudience
{
    if (!isAudience) {
        [self.trtcEngine startLocalPreview:[self renderViewForUser:self.userId].contentView];
        [self.trtcEngine startLocalAudio];
        [self.trtcEngine switchRole:TRTCRoleAnchor];
    }
    else {
        [self.trtcEngine stopLocalAudio];
        [self.trtcEngine stopLocalPreview];
        [self.trtcEngine switchRole:TRTCRoleAudience];
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

- (TXRenderView *)addRenderViewForUser:(NSString *)videoId {
    TXRenderView *videoView = _renderViewMap[videoId];
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
        [_renderViewMap setObject:videoView forKey:videoId];
        [self.videoLayoutView addSubview:videoView];
        videoView.wantsLayer = true;
        videoView.layer.backgroundColor = [NSColor blackColor].CGColor;
        videoView.layer.borderWidth = 1;
        videoView.layer.borderColor = [NSColor whiteColor].CGColor;
        
        NSTextField *identifierText = videoView.textLabel;
        identifierText.backgroundColor = [[NSColor blackColor] colorWithAlphaComponent:0.2];
        identifierText.bordered = NO;
        identifierText.stringValue = videoId;
        identifierText.editable = NO;
        identifierText.textColor = [NSColor whiteColor];
        identifierText.font = [NSFont systemFontOfSize:12];
        [self.trtcEngine setDebugViewMargin:videoId margin:NSEdgeInsetsMake(0.1, 0, 0, 0)];
    }
    [self updateLayoutVideoFrame];
    return videoView;
}

- (void)removeRenderViewForUser:(NSString *)userId{
    NSView *videoView = _renderViewMap[userId];
    [videoView removeFromSuperview];
    [_renderViewMap removeObjectForKey:userId];
    [_allUids removeObject:userId];
    [self.rotationState removeObjectForKey:userId];
    [self updateLayoutVideoFrame];
}

/// 画廊视图布局，每个人的视图大小相同
- (void)layoutWithGridStyle:(NSRect)bounds {
    NSUInteger count = _renderViewMap.count;
    if (count == 0) return;
    
    NSUInteger col = ceil(sqrt(count));
    NSUInteger row = ceil(count / (float)col);
    
    NSSize size = NSMakeSize(NSWidth(bounds) / col, NSHeight(bounds) / row);
    
    NSRect frame = NSMakeRect(0, NSHeight(bounds) - size.height, size.width, size.height);
    for (NSInteger i = 0; i < count; ++ i) {
        NSString *uid = _allUids[i];
        TXRenderView *view = [self renderViewForUser:uid];
        view.frame = frame;
        if ((i+1) % col == 0) {
            frame.origin.x = 0;
            frame.origin.y -= size.height;
        } else {
            frame.origin.x += size.width;
        }
        if (i == 0 && count > 1)  {
            CGRect layoutButtonFrame = [view convertRect:_videoLayoutStyleBtn.frame fromView:_videoLayoutStyleBtn.superview];
            CGFloat topMargin = NSHeight(view.bounds) - NSMinY(layoutButtonFrame);
            view.topIndicatorMargin = topMargin + 5;
        } else {
            view.topIndicatorMargin = 0;
        }
    }
}

/// 演讲者视图布局，上面小图，下面大图
- (void)layoutWithSplitStyle:(NSRect)bounds {
    const CGFloat TopHeight = 160; // 顶部视频区域显示高度
    const CGFloat Spacing   = 12;  // 顶部视频区域每个视频的间隔
    // 主画面
    TXRenderView *mainView = [self renderViewForUser:self.allUids.firstObject];
    
    if (_allUids.count == 1) {
        mainView.frame = bounds;
    } else if (_allUids.count > 1) {
        // 第0个是自己，第一个开始是对方
        mainView = [self renderViewForUser:self.allUids[1]];
        NSMutableArray *uids = [_allUids mutableCopy];
        [uids removeObjectAtIndex:1];
        
        const NSInteger topCount = uids.count;
        NSRect frame = bounds;
        frame.size.height -= TopHeight;
        mainView.frame = frame;
        
        CGFloat height = TopHeight - Spacing * 2;
        CGFloat width = round(height * 1.33);
        CGSize size = NSMakeSize(width, height);
        CGFloat totalWidth = (width + Spacing) * (topCount - 1) + width;
        CGFloat left = (NSWidth(bounds) - totalWidth) / 2;
        if (left < Spacing) {
            left = Spacing;
        }
        NSPoint point = NSMakePoint(left, NSHeight(bounds) - TopHeight + Spacing);
        for (NSInteger i = 0; i < uids.count; ++i) {
            TXRenderView *view = [self renderViewForUser:uids[i]];
            view.topIndicatorMargin = 0;
            view.frame = (NSRect){point, size};
            point.x += (width + Spacing);
        }
    }
    mainView.topIndicatorMargin = 0;
}

- (void)_layoutInBounds:(NSRect)bounds {
    if (self.layoutStyle == LayoutStyleGalleryView) {
        [self layoutWithGridStyle:bounds];
    } else {
        [self layoutWithSplitStyle:bounds];
    }
}

- (void)updateLayoutVideoFrame{
    [self _layoutInBounds:self.videoLayoutView.bounds];
    
    if (_renderViewMap.count > 1) {
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

