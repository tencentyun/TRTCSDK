/*
 * Module:   TRTCMainViewController
 * 
 * Function: 使用TRTC SDK完成 1v1 和 1vn 的视频通话功能
 *
 *    1. 支持九宫格平铺和前后叠加两种不同的视频画面布局方式，该部分由 TRTCVideoViewLayout 来计算每个视频画面的位置排布和大小尺寸
 *
 *    2. 支持对视频通话的视频、音频等功能进行设置，该部分在 TRTCFeatureContainerViewController 中实现
 *       支持添加播放BGM和多种音效，该部分在 TRTCBgmContainerViewController 中实现
 *       支持对其它用户音视频的播放进行控制，该部分在 TRTCRemoteUserListViewController 中实现
 *
 *    3. 创建或者加入某一个通话房间，需要先指定 roomid 和 userid，这部分由 TRTCNewViewController 来实现
 *
 *    4. 对TRTC Engine的调用以及参数记录，定义在Settings/SDKManager目录中
 */

#import <AVFoundation/AVFoundation.h>
#import "TRTCMainViewController.h"
#import "UIView+Additions.h"
#import "ColorMacro.h"
#import "TRTCCloudDelegate.h"
#import "TRTCVideoViewLayout.h"
#import "TRTCVideoView.h"
#import "TXLivePlayer.h"
#import "TRTCCloudDef.h"
#import "ThemeConfigurator.h"
#import "TRTCFloatWindow.h"
#import "TRTCBgmContainerViewController.h"
#import "TRTCFeatureContainerViewController.h"
#import "TRTCCdnPlayerSettingsViewController.h"
#import "TRTCRemoteUserListViewController.h"
#import "TRTCBgmManager.h"
#import "TRTCAudioEffectManager.h"
#import "TRTCAudioRecordManager.h"
#import "TRTCCdnPlayerManager.h"
#import "UIButton+TRTC.h"
#import "Masonry.h"

@interface TRTCMainViewController() <
    TRTCCloudDelegate,
    TRTCVideoViewDelegate,
    BeautyLoadPituDelegate,
    TRTCCloudManagerDelegate,
    TXLivePlayListener> {
    
    NSString                 *_mainViewUserId;     //视频画面支持点击切换，需要用一个变量记录当前哪一路画面是全屏状态的
    
    TRTCVideoViewLayout      *_layoutEngine;
    NSMutableDictionary*      _remoteViewDic;      //一个或者多个远程画面的view

    BOOL                     _linkMicSwitch;       //观众是否连麦中，用于处理UI布局
    NSInteger                _showLogType;         //LOG浮层显示详细信息还是精简信息
    NSInteger                _layoutBtnState;      //布局切换按钮状态
    CGFloat                  _dashboardTopMargin;
}

@property (weak, nonatomic) IBOutlet UIView *holderView;
@property (weak, nonatomic) IBOutlet UIView *cdnPlayerView;
@property (weak, nonatomic) IBOutlet UIView *settingsContainerView;

@property (weak, nonatomic) IBOutlet UIButton *cdnPlayButton; //旁路播放切换
@property (weak, nonatomic) IBOutlet TCBeautyPanel *beautyPanel;

@property (weak, nonatomic) IBOutlet UIStackView *toastStackView;
@property (weak, nonatomic) IBOutlet UIButton *linkMicButton;
@property (weak, nonatomic) IBOutlet UIButton *logButton; //仪表盘开关，仪表盘浮层是SDK中覆盖在视频画面上的一系列数值状态
@property (weak, nonatomic) IBOutlet UIButton *cdnPlayLogButton; //CDN播放页的仪表盘开关
@property (weak, nonatomic) IBOutlet UIButton *layoutButton; //布局切换（九宫格 OR 前后叠加）
@property (weak, nonatomic) IBOutlet UIButton *beautyButton; //美颜开关
@property (weak, nonatomic) IBOutlet UIButton *cameraButton; //前后摄像头切换
@property (weak, nonatomic) IBOutlet UIButton *muteButton; //音频上行静音开关
@property (weak, nonatomic) IBOutlet UIButton *bgmButton; //BGM设置，点击打开TRTCBgmContainerViewController
@property (weak, nonatomic) IBOutlet UIButton *featureButton; //功能设置，点击打开TRTCFeatureContainerViewController
@property (weak, nonatomic) IBOutlet UIButton *cdnPlaySettingsButton; //Cdn播放设置，点击打开TRTCFeatureContainerViewController
@property (weak, nonatomic) IBOutlet UIButton *remoteUserButton; //远端用户设置，关联打开TRTCRemoteUserListViewController

@property (strong, nonatomic) TRTCVideoView* localView; //本地画面的view
@property (strong, nonatomic, nullable) TRTCCdnPlayerManager *cdnPlayer; //直播观众的CDN拉流播放页面

// 设置页
@property (strong, nonatomic, nullable) UIViewController *currentEmbededVC;
@property (strong, nonatomic, nullable) TRTCFeatureContainerViewController *settingsVC;
@property (strong, nonatomic, nullable) TRTCBgmContainerViewController *bgmContainerVC;
@property (strong, nonatomic, nullable) TRTCCdnPlayerSettingsViewController *cdnPlayerVC;
@property (strong, nonatomic, nullable) TRTCRemoteUserListViewController *remoteUserListVC;

@property (strong, nonatomic) TRTCCloud *trtc;
@property (strong, nonatomic) TRTCBgmManager *bgmManager;
@property (strong, nonatomic) TRTCAudioEffectManager *effectManager;
@property (strong, nonatomic) TRTCAudioRecordManager *recordManager;

@property (nonatomic) BOOL isLivePlayingViaCdn;

@end

@implementation TRTCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self observeKeyboard];

    _dashboardTopMargin = 0.15;
    _trtc = [TRTCCloud sharedInstance];
    [_trtc setDelegate:self];

    self.beautyPanel.actionPerformer = [TCBeautyPanelActionProxy proxyWithSDKObject:_trtc];
    [ThemeConfigurator configBeautyPanelTheme:self.beautyPanel];

    self.bgmManager = [[TRTCBgmManager alloc] initWithTrtc:self.trtc];
    self.effectManager = [[TRTCAudioEffectManager alloc] initWithTrtc:self.trtc];
    self.settingsManager.remoteUserManager = self.remoteUserManager;
    self.recordManager = [[TRTCAudioRecordManager alloc] initWithTrtc:self.trtc];

    _remoteViewDic = [[NSMutableDictionary alloc] init];
    _mainViewUserId = @"";

    // 初始化 UI 控件
    [self initUI];
    self.settingsManager.videoView = self.localView;

    // 开始登录、进房
    [self enterRoom];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    _dashboardTopMargin = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    [self relayout];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)setLocalView:(UIView *)localView remoteViewDic:(NSMutableDictionary *)remoteViewDic {
    _trtc.delegate = self;
    _localView = (TRTCVideoView*)localView;
    _localView.delegate = self;
    self.settingsManager.videoView = self.localView;
    _remoteViewDic = remoteViewDic;
    if (_param.role != TRTCRoleAudience)
        _mainViewUserId = @"";
    
    for (id userID in _remoteViewDic) {
        TRTCVideoView *playerView = [_remoteViewDic objectForKey:userID];
        playerView.delegate = self;
    }
    [self onClickGird:nil];
    [self relayout];
}

- (void)dealloc {
    [self.settingsManager exitRoom];
    [[TRTCFloatWindow sharedInstance] close];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeKeyboard {
    __weak TRTCMainViewController *wSelf = self;
    [self.view tx_observeKeyboardOnChange:^(CGFloat keyboardTop, CGFloat height) {
        __strong TRTCMainViewController *sSelf = wSelf;
        CGFloat keyboardHeight = sSelf.view.size.height - keyboardTop;
        [sSelf.settingsContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(sSelf.view);
            make.centerY.equalTo(sSelf.view).offset(-keyboardHeight / 2);
            make.width.equalTo(sSelf.view).multipliedBy(0.95);
            make.height.mas_equalTo(keyboardTop * 0.88);
        }];
    }];
}

- (void)initUI {
    self.title = @(self.param.roomId).stringValue;
    [self.cdnPlayButton setupBackground];
    // 布局底部工具栏
    [self relayoutBottomBar];

    // 本地预览view
    _localView = [TRTCVideoView newVideoViewWithType:VideoViewType_Local userId:self.param.userId];
    _localView.delegate = self;
    [_localView setBackgroundColor:UIColorFromRGB(0x262626)];
    
    _layoutEngine = [[TRTCVideoViewLayout alloc] init];
    _layoutEngine.view = self.holderView;
    [self relayout];

    _beautyPanel.pituDelegate = self;
}

- (void)relayoutBottomBar {
    // 切换三种模式（主播，观众，连麦的观众）对应显示的button
    BOOL isAudience = _appScene == TRTCAppSceneLIVE && _param.role == TRTCRoleAudience;
    BOOL isLinkedMicAudience = _appScene == TRTCAppSceneLIVE && _linkMicSwitch;
    
    self.linkMicButton.hidden = !(isAudience || isLinkedMicAudience);
    self.layoutButton.hidden = isAudience;
    self.cdnPlayButton.hidden = !(isAudience || isLinkedMicAudience);
    self.beautyButton.hidden = isAudience;
    self.cameraButton.hidden = isAudience;
    self.muteButton.hidden = isAudience;
    self.bgmButton.hidden = isAudience;
    self.featureButton.hidden = isAudience;

    // 切换观众模式下UDP或CDN观看直播对应的button
    BOOL isUsingCdnPlay = self.cdnPlayer.isPlaying;
    self.logButton.hidden = isUsingCdnPlay;
    self.remoteUserButton.hidden = isUsingCdnPlay;
    self.cdnPlayLogButton.hidden = !isUsingCdnPlay;
    self.cdnPlaySettingsButton.hidden = !isUsingCdnPlay;
}

- (void)back2FloatingWindow {
    [_trtc showDebugView:0];
    [TRTCFloatWindow sharedInstance].localView = _localView;
    [TRTCFloatWindow sharedInstance].remoteViewDic = _remoteViewDic;
    for (NSString* uid in _remoteViewDic) {
        TRTCVideoView* view = _remoteViewDic[uid];
        [view removeFromSuperview];
    }
    [TRTCFloatWindow sharedInstance].backController = self;
    // pop
    [self.navigationController popViewControllerAnimated:YES];
    [[TRTCFloatWindow sharedInstance] show];
}

/**
 * 视频窗口排布函数，此处代码用于调整界面上数个视频画面的大小和位置
 */
- (void)relayout {
    NSMutableArray *views = @[].mutableCopy;
    if ([_mainViewUserId isEqual:@""] || [_mainViewUserId isEqual:self.param.userId]) {
        [views addObject:_localView];
        _localView.enableMove = NO;
    } else if([_remoteViewDic objectForKey:_mainViewUserId] != nil) {
        [views addObject:_remoteViewDic[_mainViewUserId]];
    }
    for (id userID in _remoteViewDic) {
        TRTCVideoView *playerView = [_remoteViewDic objectForKey:userID];
        if ([_mainViewUserId isEqual:userID]) {
            [views addObject:_localView];
            playerView.enableMove = NO;
            _localView.enableMove = YES;
        } else {
            playerView.enableMove = YES;
            [views addObject:playerView];
        }
    }
    
    [_layoutEngine relayout:views];
    
    //观众角色隐藏预览view
     _localView.hidden = NO;
     if (_appScene == TRTCAppSceneLIVE && _param.role == TRTCRoleAudience)
         _localView.hidden = YES;
    
    // 更新 dashboard 边距
    UIEdgeInsets margin = UIEdgeInsetsMake(_dashboardTopMargin,  0, 0, 0);
    if (_remoteViewDic.count == 0) {
        [_trtc setDebugViewMargin:self.param.userId margin:margin];
    } else {
        NSMutableArray *uids = [NSMutableArray arrayWithObject:self.param.userId];
        [uids addObjectsFromArray:[_remoteViewDic allKeys]];
        [uids removeObject:_mainViewUserId];
        for (NSString *uid in uids) {
            [_trtc setDebugViewMargin:uid margin:UIEdgeInsetsZero];
        }
        
        [_trtc setDebugViewMargin:_mainViewUserId margin:(_layoutEngine.type == TC_Float || _remoteViewDic.count == 0) ? margin : UIEdgeInsetsZero];
    }
}

- (void)enterRoom {
    [self toastTip:@"开始进房"];
    [self.settingsManager enterRoom];
    [_beautyPanel resetAndApplyValues];
//    [_beautyPanel trigglerValues];
}

- (void)exitRoom {
    [self.settingsManager exitRoom];
}

#pragma mark - Actions

- (IBAction)onClickLinkMicButton:(UIButton *)button {
    if (self.cdnPlayer.isPlaying) {
        [self toggleCdnPlay];
    }

    [self.settingsManager switchRole:_linkMicSwitch ? TRTCRoleAudience : TRTCRoleAnchor];
    _linkMicSwitch = !_linkMicSwitch;
    button.selected = _linkMicSwitch;
    [self relayoutBottomBar];
    [self relayout];
}

- (IBAction)onClickLogButton:(UIButton *)button {
    _showLogType ++;
    if (_showLogType > 2) {
        _showLogType = 0;
        [button setImage:[UIImage imageNamed:@"log_b2"] forState:UIControlStateNormal];
    } else {
        [button setImage:[UIImage imageNamed:@"log_b"] forState:UIControlStateNormal];
    }
    
    [_trtc showDebugView:_showLogType];
}

- (IBAction)onClickCdnPlayLogButton:(UIButton *)button {
    button.selected = !button.selected;
    [self.cdnPlayer setDebugLogEnabled:button.selected];
}

- (IBAction)onClickGird:(UIButton *)button {
    const int kStateFloat       = 0;
    const int kStateGrid        = 1;
    const int kStateFloatWindow = 2;
    if (_layoutBtnState == kStateFloat) {
        _layoutBtnState = kStateGrid;
        [_layoutButton setImage:[UIImage imageNamed:@"gird_b"] forState:UIControlStateNormal];
        _layoutEngine.type = TC_Gird;
        [_trtc setDebugViewMargin:_mainViewUserId margin:UIEdgeInsetsZero];
    } else if (_layoutBtnState == kStateGrid){
        _layoutBtnState = kStateFloatWindow;
        [self back2FloatingWindow];
        return;
    }
    else if (_layoutBtnState == kStateFloatWindow) {
        [_layoutButton setImage:[UIImage imageNamed:@"float_b"] forState:UIControlStateNormal];
        _layoutBtnState = kStateFloat;
        _layoutEngine.type = TC_Float;
        [_trtc setDebugViewMargin:_mainViewUserId margin:UIEdgeInsetsMake(_dashboardTopMargin, 0, 0, 0)];
    }
    
    [_trtc showDebugView:_showLogType];
}

- (IBAction)onClickCdnPlayButton:(UIButton *)button {
    [self.settingsManager switchRole:TRTCRoleAudience];
    [self toggleCdnPlay];
}

- (IBAction)onClickBeautyButton:(UIButton *)button {
    _beautyPanel.hidden = !_beautyPanel.hidden;
}

- (IBAction)onClickSwitchCameraButton:(UIButton *)button {
    [self.settingsManager switchCamera];
}

- (IBAction)onClickMuteButton:(UIButton *)button {
    button.selected = !button.selected;
    [_trtc muteLocalAudio:button.selected];
}

- (IBAction)onClickBgmSettingsButton:(UIButton *)button {
    if (!self.bgmContainerVC) {
        self.bgmContainerVC = [[TRTCBgmContainerViewController alloc] init];
        self.bgmContainerVC.bgmManager = self.bgmManager;
        self.bgmContainerVC.effectManager = self.effectManager;
    }
    [self toggleEmbedVC:self.bgmContainerVC];
}

- (IBAction)onClickFeatureSettingsButton:(UIButton *)button {
    if (!self.settingsVC) {
        self.settingsVC = [[TRTCFeatureContainerViewController alloc] init];
        self.settingsVC.settingsManager = self.settingsManager;
        self.settingsVC.recordManager = self.recordManager;
    }
    [self toggleEmbedVC:self.settingsVC];
}

- (IBAction)onClickCdnPlaySettingsButton:(UIButton *)button {
    if (!self.cdnPlayerVC) {
        self.cdnPlayerVC = [[TRTCCdnPlayerSettingsViewController alloc] init];
        self.cdnPlayerVC.manager = self.cdnPlayer;
    }
    [self toggleEmbedVC:self.cdnPlayerVC];
}

- (IBAction)onClickRemoteUserSettingsButton:(UIButton *)button {
    if (!self.remoteUserListVC) {
        self.remoteUserListVC = [[TRTCRemoteUserListViewController alloc] init];
        self.remoteUserListVC.userManager = self.remoteUserManager;
    }
    [self toggleEmbedVC:self.remoteUserListVC];
}

#pragma mark - Settings ViewController Embeding

- (void)toggleEmbedVC:(UIViewController *)vc {
    if (self.currentEmbededVC != vc) {
        [self embedChildVC:vc];
    } else {
        [self unembedChildVC:vc];
    }
}

- (void)embedChildVC:(UIViewController *)vc {
    if (self.currentEmbededVC) {
        [self unembedChildVC:self.currentEmbededVC];
    }

    UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:vc];
    [self addChildViewController:naviVC];
    [self.settingsContainerView addSubview:naviVC.view];
    [naviVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.settingsContainerView);
    }];
    [naviVC didMoveToParentViewController:self];

    self.settingsContainerView.hidden = NO;
    self.currentEmbededVC = vc;
}

- (void)unembedChildVC:(UIViewController * _Nullable)vc {
    if (!vc) { return; }
    [vc.navigationController willMoveToParentViewController:nil];
    [vc.navigationController.view removeFromSuperview];
    [vc.navigationController removeFromParentViewController];
    self.currentEmbededVC = nil;
    self.settingsContainerView.hidden = YES;
}

#pragma mark - Live Player

- (void)toggleCdnPlay {
    if (!self.cdnPlayer) {
        self.cdnPlayer = [[TRTCCdnPlayerManager alloc] initWithContainerView:self.cdnPlayerView delegate:self];
    }

    self.isLivePlayingViaCdn = !self.isLivePlayingViaCdn;
    self.cdnPlayerView.hidden = !self.isLivePlayingViaCdn;
    self.cdnPlayButton.selected = self.isLivePlayingViaCdn;

    if (self.isLivePlayingViaCdn) {
        [self exitRoom];
        NSString *anchorId = _mainViewUserId.length > 0 ? _mainViewUserId : self.remoteUserManager.remoteUsers.allKeys.firstObject;
        [self.cdnPlayer startPlay:[self.settingsManager getCdnUrlOfUser:anchorId]];
    } else {
        [self.cdnPlayer stopPlay];
        [self enterRoom];
    }
    [self relayoutBottomBar];
    [self relayout];
}

#pragma mark - TRTCVideoViewDelegate

- (void)onMuteVideoBtnClick:(TRTCVideoView *)view stateChanged:(BOOL)stateChanged {
    if (view.streamType == TRTCVideoStreamTypeSub) {
        if (stateChanged) {
            [_trtc stopRemoteSubStreamView:view.userId];
        } else {
            [_trtc startRemoteSubStreamView:view.userId view:view];
        }
    } else {
        [self.remoteUserManager setUser:view.userId isVideoMuted:stateChanged];
    }
}

- (void)onMuteAudioBtnClick:(TRTCVideoView *)view stateChanged:(BOOL)stateChanged {
    [self.remoteUserManager setUser:view.userId isAudioMuted:stateChanged];
}

- (void)onScaleModeBtnClick:(TRTCVideoView *)view stateChanged:(BOOL)stateChanged {
    [self.remoteUserManager setUser:view.userId fillMode:stateChanged ? TRTCVideoFillMode_Fill : TRTCVideoFillMode_Fit];
}

- (void)onViewTap:(TRTCVideoView *)view touchCount:(NSInteger)touchCount {
    if (_layoutEngine.type == TC_Gird) {
        return;
    }
    if (view == _localView) {
        _mainViewUserId = self.param.userId;
    } else {
        for (id userID in _remoteViewDic) {
            UIView *pw = [_remoteViewDic objectForKey:userID];
            if (view == pw ) {
                _mainViewUserId = userID;
            }
        }
    }
    [self relayout];
}

#pragma mark - TRTCCloudDelegate

/**
 * WARNING 大多是一些可以忽略的事件通知，SDK内部会启动一定的补救机制
 */
- (void)onWarning:(TXLiteAVWarning)warningCode warningMsg:(NSString *)warningMsg {
    
}

/**
 * 大多是不可恢复的错误，需要通过 UI 提示用户
 */
- (void)onError:(TXLiteAVError)errCode errMsg:(NSString *)errMsg extInfo:(nullable NSDictionary *)extInfo {
    // 有些手机在后台时无法启动音频，这种情况下，TRTC会在恢复到前台后尝试重启音频，不应调用exitRoom。
    BOOL isStartingRecordInBackgroundError =
        errCode == ERR_MIC_START_FAIL &&
        [UIApplication sharedApplication].applicationState != UIApplicationStateActive;
    
    if (!isStartingRecordInBackgroundError) {
        NSString *msg = [NSString stringWithFormat:@"发生错误: %@ [%d]", errMsg, errCode];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"已退房"
                                                                                 message:msg
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
            [self exitRoom];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)onEnterRoom:(NSInteger)result {
    if (result >= 0) {
        [self toastTip:[NSString stringWithFormat:@"[%@]进房成功[%@]: elapsed[%@]",
                        self.param.userId,
                        @(self.param.roomId),
                        @(result)]];
    } else {
        [self exitRoom];
        [self toastTip:[NSString stringWithFormat:@"进房失败: [%ld]", (long)result]];
    }
}


- (void)onExitRoom:(NSInteger)reason {
    NSString *msg = [NSString stringWithFormat:@"离开房间[%@]: reason[%ld]", @(self.param.roomId), (long)reason];
    [self toastTip:msg];
}

- (void)onSwitchRole:(TXLiteAVError)errCode errMsg:(NSString *)errMsg {
    _linkMicSwitch = self.param.role == TRTCRoleAnchor;
    self.linkMicButton.selected = _linkMicSwitch;
    [self toastTip:[NSString stringWithFormat:@"切换到%@身份",
                    self.param.role == TRTCRoleAnchor ? @"主播" : @"观众"]];
}

- (void)onConnectOtherRoom:(NSString *)userId errCode:(TXLiteAVError)errCode errMsg:(NSString *)errMsg {
    [self toastTip:[NSString stringWithFormat:@"连麦结果:%u %@", errCode, errMsg]];
    if (errCode != 0) {
        [self.remoteUserManager removeUser:userId];
    }
}

/**
 * 有新的用户加入了当前视频房间
 */
- (void)onRemoteUserEnterRoom:(NSString *)userId {
    NSLog(@"onRemoteUserEnterRoom: %@", userId);
    [self.remoteUserManager addUser:userId roomId:[NSString stringWithFormat:@"%@", @(self.param.roomId)]];
}
/**
 * 有用户离开了当前视频房间
 */
- (void)onRemoteUserLeaveRoom:(NSString *)userId reason:(NSInteger)reason {
    NSLog(@"onRemoteUserLeaveRoom: %@", userId);
    [self.remoteUserManager removeUser:userId];
    
    // 更新UI
    UIView *playerView = [_remoteViewDic objectForKey:userId];
    [playerView removeFromSuperview];
    [_remoteViewDic removeObjectForKey:userId];

    NSString* subViewId = [NSString stringWithFormat:@"%@-sub", userId];
    UIView *subStreamPlayerView = [_remoteViewDic objectForKey:subViewId];
    [subStreamPlayerView removeFromSuperview];
    [_remoteViewDic removeObjectForKey:subViewId];

    // 如果该成员是大画面，则当其离开后，大画面设置为本地推流画面
    if ([userId isEqual:_mainViewUserId] || [subViewId isEqualToString:_mainViewUserId]) {
        _mainViewUserId = self.param.userId;
    }

    [self relayout];
    [self.settingsManager updateCloudMixtureParams];
}

- (void)onUserAudioAvailable:(NSString *)userId available:(BOOL)available {
    NSLog(@"onUserAudioAvailable:userId:%@ available:%u", userId, available);
    [self.remoteUserManager updateUser:userId isAudioEnabled:available];

    TRTCVideoView *playerView = [_remoteViewDic objectForKey:userId];
    if (!available) {
        [playerView setAudioVolumeRadio:0.f];
    }
}

- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available {
    NSLog(@"onUserVideoAvailable:userId:%@ available:%u", userId, available);
    [self.remoteUserManager updateUser:userId isVideoEnabled:available];

    if (userId != nil) {
        TRTCVideoView* remoteView = [_remoteViewDic objectForKey:userId];
        if (available) {
            if(remoteView == nil) {
                // 创建一个新的 View 用来显示新的一路画面
                remoteView = [TRTCVideoView newVideoViewWithType:VideoViewType_Remote userId:userId];
                if (!self.settingsManager.audioConfig.isVolumeEvaluationEnabled) {
                    [remoteView showAudioVolume:NO];
                }
                remoteView.delegate = self;
                [remoteView setBackgroundColor:UIColorFromRGB(0x262626)];
                [self.view addSubview:remoteView];
                [_remoteViewDic setObject:remoteView forKey:userId];

                // 将新进来的成员设置成大画面
                _mainViewUserId = userId;

                [self relayout];
                [self.settingsManager updateCloudMixtureParams];
            }
            
            [_trtc startRemoteView:userId view:remoteView];
            [_trtc setRemoteViewFillMode:userId mode:TRTCVideoFillMode_Fit];
        }
        else {
            [_trtc stopRemoteView:userId];
        }

        [remoteView showVideoCloseTip:!available];
    }
}

- (void)onUserSubStreamAvailable:(NSString *)userId available:(BOOL)available {
    NSLog(@"onUserSubStreamAvailable:userId:%@ available:%u", userId, available);
    NSString* viewId = [NSString stringWithFormat:@"%@-sub", userId];
    if (available) {
        TRTCVideoView *remoteView = [TRTCVideoView newVideoViewWithType:VideoViewType_Remote userId:userId];
        remoteView.streamType = TRTCVideoStreamTypeSub;
        if (!self.settingsManager.audioConfig.isVolumeEvaluationEnabled) {
            [remoteView showAudioVolume:NO];
        }
        remoteView.delegate = self;
        [remoteView setBackgroundColor:UIColorFromRGB(0x262626)];
        [self.view addSubview:remoteView];
        [_remoteViewDic setObject:remoteView forKey:viewId];
        
        [_trtc startRemoteSubStreamView:userId view:remoteView];
        [_trtc setRemoteSubStreamViewFillMode:userId mode:TRTCVideoFillMode_Fit];
    }
    else {
        UIView *playerView = [_remoteViewDic objectForKey:viewId];
        [playerView removeFromSuperview];
        [_remoteViewDic removeObjectForKey:viewId];
        [_trtc stopRemoteSubStreamView:userId];
        
        if ([viewId isEqual:_mainViewUserId]) {
            _mainViewUserId = self.param.userId;
        }
    }
    [self relayout];
}

- (void)onFirstVideoFrame:(NSString *)userId streamType:(TRTCVideoStreamType)streamType width:(int)width height:(int)height {
    NSLog(@"onFirstVideoFrame userId:%@ streamType:%@ width:%d height:%d", userId, @(streamType), width, height);
}

- (void)onNetworkQuality:(TRTCQualityInfo *)localQuality remoteQuality:(NSArray<TRTCQualityInfo *> *)remoteQuality {
    [_localView setNetworkIndicatorImage:[self imageForNetworkQuality:localQuality.quality]];
    for (TRTCQualityInfo* qualityInfo in remoteQuality) {
        TRTCVideoView* remoteVideoView = [_remoteViewDic objectForKey:qualityInfo.userId];
        [remoteVideoView setNetworkIndicatorImage:[self imageForNetworkQuality:qualityInfo.quality]];
    }
}

- (void)onStatistics:(TRTCStatistics *)statistics {

}

- (void)onAudioRouteChanged:(TRTCAudioRoute)route fromRoute:(TRTCAudioRoute)fromRoute {
    NSLog(@"TRTC onAudioRouteChanged %@ -> %@", @(fromRoute), @(route));
}

- (void)onUserVoiceVolume:(NSArray<TRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume {
    [_remoteViewDic enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, TRTCVideoView * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj setAudioVolumeRadio:0.f];
        [obj showAudioVolume:NO];
    }];
    
    for (TRTCVolumeInfo* volumeInfo in userVolumes) {
        TRTCVideoView* videoView = [_remoteViewDic objectForKey:volumeInfo.userId];
        if (videoView) {
            float radio = ((float)volumeInfo.volume) / 100;
            [videoView setAudioVolumeRadio:radio];
            [videoView showAudioVolume:radio > 0];
        }
    }
}

- (void)onRecvCustomCmdMsgUserId:(NSString *)userId cmdID:(NSInteger)cmdID seq:(UInt32)seq message:(NSData *)message {
    NSString *msg = [[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding];
    [self toastTip:[NSString stringWithFormat:@"%@: %@", userId, msg]];
}

- (void)onRecvSEIMsg:(NSString *)userId message:(NSData*)message {
    NSString *msg = [[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding];
    [self toastTip:[NSString stringWithFormat:@"%@: %@", userId, msg]];
}

- (void)onSetMixTranscodingConfig:(int)err errMsg:(NSString *)errMsg {
    NSLog(@"onSetMixTranscodingConfig err:%d errMsg:%@", err, errMsg);
}

- (void)onAudioEffectFinished:(int)effectId code:(int)code {
    [self.effectManager stopEffect:effectId];
}

- (UIImage*)imageForNetworkQuality:(TRTCQuality)quality
{
    UIImage* image = nil;
    switch (quality) {
        case TRTCQuality_Down:
        case TRTCQuality_Vbad:
            image = [UIImage imageNamed:@"signal5"];
            break;
        case TRTCQuality_Bad:
            image = [UIImage imageNamed:@"signal4"];
            break;
        case TRTCQuality_Poor:
            image = [UIImage imageNamed:@"signal3"];
            break;
        case TRTCQuality_Good:
            image = [UIImage imageNamed:@"signal2"];
            break;
        case TRTCQuality_Excellent:
            image = [UIImage imageNamed:@"signal1"];
            break;
        default:
            break;
    }
    
    return image;
}

- (void)toastTip:(NSString *)toastInfo {
    __block UITextView *toastView = [[UITextView alloc] init];
    
    toastView.userInteractionEnabled = NO;
    toastView.scrollEnabled = NO;
    toastView.text = toastInfo;
    toastView.backgroundColor = [UIColor whiteColor];
    toastView.alpha = 0.5;

    [self.toastStackView addArrangedSubview:toastView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [toastView removeFromSuperview];
    });
}

#pragma mark - BeautyLoadPituDelegate
- (void)onLoadPituStart
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self toastTip:@"开始加载资源"];
    });
}
- (void)onLoadPituProgress:(CGFloat)progress
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self toastTip:[NSString stringWithFormat:@"正在加载资源%d %%",(int)(progress * 100)]];
//    });
}
- (void)onLoadPituFinished
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self toastTip:@"资源加载成功"];
    });
}
- (void)onLoadPituFailed
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self toastTip:@"资源加载失败"];
    });
}

#pragma mark - TXLivePlayListener

- (void)onPlayEvent:(int)EvtID withParam:(NSDictionary *)param {
    if (EvtID == PLAY_ERR_NET_DISCONNECT) {
        [self toggleCdnPlay];
        [self toastTip:(NSString *) param[EVT_MSG]];
    } else if (EvtID == PLAY_EVT_PLAY_END) {
        [self toggleCdnPlay];
    }
}

#pragma mark - TRTCCloudManagerDelegate

- (void)roomSettingsManager:(TRTCCloudManager *)manager didSetVolumeEvaluation:(BOOL)isEnabled {
    for (TRTCVideoView* videoView in _remoteViewDic.allValues) {
        [videoView showAudioVolume:isEnabled];
    }
}

@end
