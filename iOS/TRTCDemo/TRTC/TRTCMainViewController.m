/*
 * Module:   TRTCMainViewController
 * 
 * Function: 使用TRTC SDK完成 1v1 和 1vn 的视频通话功能
 *
 *    1. 支持九宫格平铺和前后叠加两种不同的视频画面布局方式，该部分由 TRTCVideoViewLayout 来计算每个视频画面的位置排布和大小尺寸
 *
 *    2. 支持对视频通话的分辨率、帧率和流畅模式进行调整，该部分由 TRTCSettingViewController 来实现
 *
 *    3. 创建或者加入某一个通话房间，需要先指定 roomid 和 userid，这部分由 TRTCNewViewController 来实现
 */

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "TRTCMainViewController.h"
#import "TRTCSettingViewController.h"
#import "UIView+Additions.h"
#import "ColorMacro.h"
#import "TRTCCloud.h"
#import "TRTCCloudDelegate.h"
#import "TRTCVideoViewLayout.h"
#import "TRTCVideoView.h"
#import "TRTCMoreViewController.h"
#import "TRTCCloudDef.h"
#import "TestSendCustomVideoData.h"
#import "TestRenderVideoFrame.h"
#import "BeautySettingPanel.h"
#import "TRTCFloatWindow.h"


typedef enum : NSUInteger {
    TRTC_IDLE,       // SDK 没有进入视频通话状态
    TRTC_ENTERED,    // SDK 视频通话进行中
} TRTCStatus;

@interface TRTCMainViewController() <UITextFieldDelegate, TRTCCloudDelegate, TRTCSettingVCDelegate, TRTCVideoViewDelegate, TRTCMoreSettingDelegate> {
    TRTCStatus                _roomStatus;
    
    NSString                 *_mainViewUserId;     //视频画面支持点击切换，需要用一个变量记录当前哪一路画面是全屏状态的
    
    TRTCVideoViewLayout      *_layoutEngine;
    UIView                   *_holderView;
    
    NSMutableDictionary*      _remoteViewDic;      //一个或者多个远程画面的view
    
    UIButton                 *_btnLog;             //用于显示通话质量的log按钮
    UIButton                 *_btnVideoMute;        //上行静画
    UIButton                 *_btnLayoutSwitch;    //布局切换按钮（九宫格 OR 前后叠加）
    UIButton                 *_btnBeauty;          //是否开启美颜（磨皮）
    UIButton                 *_btnMute;            //上行静音
    UIButton                 *_btnSetting;         //设置面板，关联打开 TRTCSettingViewController
    UIButton                 *_btnMore;            //更多设置
    
    NSInteger                _showLogType;         //LOG浮层显示详细信息还是精简信息
    NSInteger                _layoutBtnState;      //布局切换按钮状态
    BOOL                     _videoMuted;
    BOOL                     _beautySwitch;
    BOOL                     _muteSwitch;
    CGFloat                  _dashboardTopMargin;
    
    BeautySettingPanel*     _vBeauty;
    TRTCMoreViewController* _moreSettingVC;
}

@property uint32_t sdkAppid;
@property (nonatomic, copy) NSString* roomID;
@property (nonatomic, copy) NSString* selfUserID;
@property NSString  *selfUserSig;
@property (nonatomic, assign) NSInteger toastMsgCount;      //当前tips数量
@property (nonatomic, assign) NSInteger toastMsgHeight;
@property (nonatomic, retain) TRTCCloud *trtc;               //TRTC SDK 实例对象
@property (nonatomic, retain) TestSendCustomVideoData* customVideoCaptureTester; //测试自定义采集
@property (nonatomic, retain) TestRenderVideoFrame* customVideoRenderTester; //测试自定义渲染
@property (nonatomic, retain) TRTCVideoView* localView;          //本地画面的view



@end

@implementation TRTCMainViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

}

/**
 * 检查当前APP是否已经获得摄像头和麦克风权限，没有获取边提示用户开启权限
 */
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _dashboardTopMargin = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
#if !TARGET_IPHONE_SIMULATOR
    //是否有摄像头权限
    AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (statusVideo == AVAuthorizationStatusDenied) {
        [self toastTip:@"获取摄像头权限失败，请前往隐私-相机设置里面打开应用权限"];
        return;
    }
    
    //是否有麦克风权限
    AVAuthorizationStatus statusAudio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (statusAudio == AVAuthorizationStatusDenied) {
        [self toastTip:@"获取麦克风权限失败，请前往隐私-麦克风设置里面打开应用权限"];
        return;
    }
#endif
    
}

- (void)setAppScene:(TRTCAppScene)appScene
{
    _appScene = appScene;
    [TRTCSettingViewController setAppScene:_appScene]; //设置界面针对不同场景参数设置有区别
}

- (void)setParam:(TRTCParams *)param
{
    _param = param;
    _sdkAppid = param.sdkAppId;
    _selfUserID = param.userId;
    _selfUserSig = param.userSig;
    _roomID = @(param.roomId).stringValue;
}

- (void)setLocalView:(UIView *)localView remoteViewDic:(NSMutableDictionary *)remoteViewDic
{
    _trtc.delegate = self;
    _localView = (TRTCVideoView*)localView;
    _localView.delegate = self;
    _remoteViewDic = remoteViewDic;
    if (_param.role != TRTCRoleAudience)
        _mainViewUserId = @"";
    
    for (id userID in _remoteViewDic) {
        TRTCVideoView *playerView = [_remoteViewDic objectForKey:userID];
        playerView.delegate = self;
    }
    [self clickGird:nil];
    [self relayout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    _dashboardTopMargin = 0.15;
    if (_trtc == nil) {
        _trtc = [TRTCCloud sharedInstance];
        [_trtc setDelegate:self];
    }
    _roomStatus = TRTC_IDLE;
    _remoteViewDic = [[NSMutableDictionary alloc] init];

    _mainViewUserId = @"";
    _toastMsgCount = 0;
    _toastMsgHeight = 0;
    
    // 初始化 UI 控件
    [self initUI];
    
    // 开始登录、进房
    [self enterRoom];
}

- (void)onAppWillResignActive:(NSNotification *)notification {
    if (_trtc != nil) {
        ;
    }
}

- (void)onAppDidBecomeActive:(NSNotification *)notification {
    if (_trtc != nil) {
        ;
    }
}

- (void)onAppDidEnterBackGround:(NSNotification *)notification {
    if (_trtc != nil) {
        ;
    }
}

- (void)onAppWillEnterForeground:(NSNotification *)notification {
    if (_trtc != nil) {
        ;
    }
}

- (void)dealloc {
    if (_trtc != nil) {
        [_trtc exitRoom];
        [_customVideoCaptureTester stop];
        _customVideoCaptureTester = nil;
    }
    [[TRTCFloatWindow sharedInstance] close];
    [TRTCCloud destroySharedIntance];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - initUI

/**
 * 初始化界面控件，包括主要的视频显示View，以及底部的一排功能按钮
 */
- (void)initUI {
    self.title = _roomID;
    [self.view setBackgroundColor:UIColorFromRGB(0x333333)];
    
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    int ICON_SIZE = size.width / 8;
    
    float startSpace = 10;
    float centerInterVal = (size.width - 2 * startSpace - ICON_SIZE) / 6  - ICON_SIZE;
    float iconY = size.height - ICON_SIZE / 2 - 10;
    
    _btnLayoutSwitch = [self createBottomBtnIcon:@"float_b"
                                          Action:@selector(clickGird:)
                                          Center:CGPointMake(startSpace + ICON_SIZE / 2, iconY)
                                            Size:ICON_SIZE];
    
    
    _beautySwitch = NO;
    _btnBeauty = [self createBottomBtnIcon:@"beauty_b"
                                          Action:@selector(clickBeauty:)
                                          Center:CGPointMake(_btnLayoutSwitch.center.x + ICON_SIZE + centerInterVal, iconY)
                                            Size:ICON_SIZE];
    
    _videoMuted = NO;
    _btnVideoMute = [self createBottomBtnIcon:@"muteVideo"
                                          Action:@selector(clickVideoMute:)
                                          Center:CGPointMake(_btnBeauty.center.x + ICON_SIZE + centerInterVal, iconY)
                                            Size:ICON_SIZE];
    
    _muteSwitch = NO;
    _btnMute = [self createBottomBtnIcon:@"mute_b"
                                  Action:@selector(clickMute:)
                                  Center:CGPointMake(_btnVideoMute.center.x + ICON_SIZE + centerInterVal, iconY)
                                    Size:ICON_SIZE];
    
    _showLogType = 0;
    _btnLog = [self createBottomBtnIcon:@"log_b2"
                                 Action:@selector(clickLog:)
                                 Center:CGPointMake(_btnMute.center.x + ICON_SIZE + centerInterVal, iconY)
                                   Size:ICON_SIZE];
    
    _btnSetting = [self createBottomBtnIcon:@"set_b"
                                 Action:@selector(clickSetting:)
                                 Center:CGPointMake(_btnLog.center.x + ICON_SIZE + centerInterVal, iconY)
                                   Size:ICON_SIZE];
    

    _btnMore = [self createBottomBtnIcon:@"more_b"
                                  Action:@selector(clickMore:)
                                  Center:CGPointMake(_btnSetting.center.x + ICON_SIZE + centerInterVal, iconY)
                                    Size:ICON_SIZE];
    _btnMore.tag = 0;
    
    
    // 本地预览view
    _localView = [TRTCVideoView newVideoViewWithType:VideoViewType_Local userId:_selfUserID];

    _localView.delegate = self;
    [_localView setBackgroundColor:UIColorFromRGB(0x262626)];
    
    _holderView = [[UIView alloc] initWithFrame:self.view.bounds];
    [_holderView setBackgroundColor:UIColorFromRGB(0x262626)];
    [self.view insertSubview:_holderView atIndex:0];
    
    _layoutEngine = [[TRTCVideoViewLayout alloc] init];
    _layoutEngine.view = _holderView;
    [self relayout];

    NSUInteger controlHeight = [BeautySettingPanel getHeight];
    _vBeauty = [[BeautySettingPanel alloc] initWithFrame:CGRectMake(0, _btnBeauty.y - controlHeight, self.view.frame.size.width, controlHeight)];
    _vBeauty.hidden = YES;
    _vBeauty.delegate = self;
    _vBeauty.pituDelegate = self;
    [self.view addSubview:_vBeauty];
    
}


- (void)back2FloatingWindow
{
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

- (UIButton*)createBottomBtnIcon:(NSString*)icon Action:(SEL)action Center:(CGPoint)center  Size:(int)size
{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.center = center;
    btn.bounds = CGRectMake(0, 0, size, size);
    [btn setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    return btn;
}


/**
 * 视频窗口排布函数，此处代码用于调整界面上数个视频画面的大小和位置
 */
#define IsIPhoneX ([[UIScreen mainScreen] bounds].size.height >= 812)
- (void)relayout {
    NSMutableArray *views = @[].mutableCopy;
    if ([_mainViewUserId isEqual:@""] || [_mainViewUserId isEqual:_selfUserID]) {
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
        [_trtc setDebugViewMargin:_selfUserID margin:margin];
    } else {
        NSMutableArray *uids = [NSMutableArray arrayWithObject:_selfUserID];
        [uids addObjectsFromArray:[_remoteViewDic allKeys]];
        [uids removeObject:_mainViewUserId];
        for (NSString *uid in uids) {
            [_trtc setDebugViewMargin:uid margin:UIEdgeInsetsZero];
        }
        
        [_trtc setDebugViewMargin:_mainViewUserId margin:(_layoutEngine.type == TC_Float || _remoteViewDic.count == 0) ? margin : UIEdgeInsetsZero];
    }
}

/**
 * 防止iOS锁屏：如果视频通话进行中，则方式iPhone进入锁屏状态
 */
- (void)setRoomStatus:(TRTCStatus)roomStatus {
    _roomStatus = roomStatus;
    
    switch (_roomStatus) {
        case TRTC_IDLE:
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            break;
        case TRTC_ENTERED:
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            break;
        default:
            break;
    }
}


/**
 * 加入视频房间：需要 TRTCNewViewController 提供的  TRTCVideoEncParam 函数
 */
- (void)enterRoom {
	// 大画面的编码器参数设置
    // 设置视频编码参数，包括分辨率、帧率、码率等等，这些编码参数来自于 TRTCSettingViewController 的设置
	// 注意（1）：不要在码率很低的情况下设置很高的分辨率，会出现较大的马赛克
	// 注意（2）：不要设置超过25FPS以上的帧率，因为电影才使用24FPS，我们一般推荐15FPS，这样能将更多的码率分配给画质
    TRTCVideoEncParam* encParam = [TRTCVideoEncParam new];
    encParam.videoResolution = [TRTCSettingViewController getResolution];
    encParam.videoBitrate = [TRTCSettingViewController getBitrate];
    encParam.videoFps = [TRTCSettingViewController getFPS];
    encParam.resMode = [TRTCSettingViewController getResMode];

    TRTCNetworkQosParam * qosParam = [TRTCNetworkQosParam new];
    qosParam.preference = [TRTCSettingViewController getQosType] + 1;
    qosParam.controlMode = [TRTCSettingViewController getQosCtrlType];
    [_trtc setNetworkQosParam:qosParam];

    //小画面的编码器参数设置
    //TRTC SDK 支持大小两路画面的同时编码和传输，这样网速不理想的用户可以选择观看小画面
    //注意：iPhone & Android 不要开启大小双路画面，非常浪费流量，大小路画面适合 Windows 和 MAC 这样的有线网络环境
    TRTCVideoEncParam* smallVideoConfig = [TRTCVideoEncParam new];
    smallVideoConfig.videoResolution = TRTCVideoResolution_160_90;
    smallVideoConfig.videoFps = [TRTCSettingViewController getFPS];
    smallVideoConfig.videoBitrate = 100;
    
    [_trtc setLocalViewFillMode:[TRTCMoreViewController isFitScaleMode] ? TRTCVideoFillMode_Fit : TRTCVideoFillMode_Fill];
    [_trtc setGSensorMode:[TRTCMoreViewController isGsensorEnable] ? TRTCGSensorMode_UIFixLayout: TRTCGSensorMode_Disable];
    
    [_trtc setPriorRemoteVideoStreamType:[TRTCSettingViewController getPriorSmallStream]];
    [_trtc setAudioRoute:[TRTCMoreViewController isSpeakphoneMode] ? TRTCAudioModeSpeakerphone : TRTCAudioModeEarpiece];
    [_trtc enableAudioVolumeEvaluation:[TRTCMoreViewController isAudioVolumeEnable]?300:0];
    
    if (![TRTCMoreViewController isAudioCaptureEnable] || (_appScene == TRTCAppSceneLIVE && _param.role == TRTCRoleAudience) ) {
        [_trtc stopLocalAudio];
    } else {
        [_trtc startLocalAudio];
    }

    [self startPreview];
    
    if (self.enableCustomVideoCapture && self.customMediaAsset) {
        //源为视频用视频的fps
        [_trtc enableCustomVideoCapture:YES];
        encParam.videoFps = _customVideoCaptureTester.mediaReader.fps;
        smallVideoConfig.videoFps = _customVideoCaptureTester.mediaReader.fps;
    }
    
    [_trtc setVideoEncoderParam:encParam];
    [_trtc enableEncSmallVideoStream:[TRTCSettingViewController getEnableSmallStream] withQuality:smallVideoConfig];


   
    
    [self toastTip:@"开始进房"];
    
    // 进房
    [_trtc enterRoom:self.param appScene:_appScene];
}


/**
 * 退出房间，并且退出该页面
 */
- (void)exitRoom {
    [_trtc exitRoom];
    [_customVideoCaptureTester stop];
    _customVideoRenderTester = nil;
    
    [self setRoomStatus:TRTC_IDLE];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)startPreview
{
    //自定义视频文件
    if (self.enableCustomVideoCapture && self.customMediaAsset) {
        if (!_customVideoRenderTester)
            _customVideoCaptureTester = [[TestSendCustomVideoData alloc] initWithTRTCCloud:_trtc mediaAsset:self.customMediaAsset];
        [self.customVideoCaptureTester start];
        //同时测试自定义渲染
        if (!_customVideoRenderTester)
            _customVideoRenderTester = [TestRenderVideoFrame new];
        [_trtc setLocalVideoRenderDelegate:_customVideoRenderTester pixelFormat:TRTCVideoPixelFormat_NV12 bufferType:TRTCVideoBufferType_PixelBuffer];
        [_customVideoRenderTester addUser:nil videoView:_localView];
    }
    //开摄像头
    else {
        //视频通话默认开摄像头。直播模式主播才开摄像头
        if (_appScene == TRTCAppSceneVideoCall || _param.role == TRTCRoleAnchor) {
            [_trtc startLocalPreview:[TRTCMoreViewController isFrontCamera] view:_localView];
            [_vBeauty resetValues];
            [_vBeauty trigglerValues];
        }
    }
}

- (void)stopPreview
{
    if (self.enableCustomVideoCapture && self.customMediaAsset) {
        [self.customVideoCaptureTester stop];
    }
    else {
        [_trtc stopLocalPreview];
    }
}


- (void)updateCloudMixtureParams
{
    BOOL enable = [TRTCMoreViewController isCloudMixingEnable];
    if (enable) {
        int videoWidth  = 720;
        int videoHeight = 1280;
        
        // 小画面宽高
        int subWidth  = 180;
        int subHeight = 320;
        
        int offsetX = 5;
        int offsetY = 50;
        
        int bitrate = 200;
        
        int resolution = [TRTCSettingViewController getResolution];
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
                videoWidth  = 192;
                videoHeight = 336;
                subWidth    = 54;
                subHeight   = 96;
                offsetY     = 30;
                bitrate     = 400;
                break;
            }
            case TRTCVideoResolution_320_240:
            {
                videoWidth  = 240;
                videoHeight = 320;
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
                videoWidth  = 368;
                videoHeight = 640;
                subWidth    = 90;
                subHeight   = 160;
                bitrate     = 800;
                break;
            }
            case TRTCVideoResolution_640_480:
            {
                videoWidth  = 480;
                videoHeight = 640;
                subWidth    = 90;
                subHeight   = 160;
                bitrate     = 800;
                break;
            }
            case TRTCVideoResolution_960_540:
            {
                videoWidth  = 544;
                videoHeight = 960;
                subWidth    = 171;
                subHeight   = 304;
                bitrate     = 1000;
                break;
            }
            case TRTCVideoResolution_1280_720:
            {
                videoWidth  = 720;
                videoHeight = 1280;
                subWidth    = 180;
                subHeight   = 320;
                bitrate     = 1500;
                break;
            }
        }
        
        TRTCTranscodingConfig* config = [TRTCTranscodingConfig new];
        config.appId = 1252463788;
        config.bizId = 3891;
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
        broadCaster.userId = _selfUserID; // 以主播uid为broadcaster为例
        broadCaster.zOrder = 0;
        broadCaster.rect = CGRectMake(0, 0, videoWidth, videoHeight);
        broadCaster.roomID = nil;
        
        NSMutableArray* mixUsers = [NSMutableArray new];
        [mixUsers addObject:broadCaster];
        
        // 设置混流后各个小画面的位置
        int index = 0;
        NSDictionary* pkUsers = _moreSettingVC.getPKInfo;
        for (NSString* userId in _remoteViewDic.allKeys) {
            TRTCMixUser* audience = [TRTCMixUser new];
            audience.userId = userId;
            audience.zOrder = 1 + index;
            audience.roomID = [pkUsers objectForKey:userId];
            //辅流判断：辅流的Id为原userId + "-sub"
            if ([userId hasSuffix:@"-sub"]) {
                NSArray* spritStrs = [userId componentsSeparatedByString:@"-"];
                if (spritStrs.count < 2)
                    continue;
                NSString* realUserId = spritStrs[0];
                if (![_remoteViewDic.allKeys containsObject:realUserId])
                    return;
                audience.userId = realUserId;
                audience.streamType = TRTCVideoStreamTypeSub;
            }
            if (index < 3) {
                // 前三个小画面靠右从下往上铺
                audience.rect = CGRectMake(videoWidth - offsetX - subWidth, videoHeight - offsetY - index * subHeight - subHeight, subWidth, subHeight);
            } else if (index < 6) {
                // 后三个小画面靠左从下往上铺
                audience.rect = CGRectMake(offsetX, videoHeight - offsetY - (index - 3) * subHeight - subHeight, subWidth, subHeight);
            } else {
                // 最多只叠加六个小画面
            }
            
            [mixUsers addObject:audience];
            ++index;
        }
        config.mixUsers = mixUsers;
        [_trtc setMixTranscodingConfig:config];
    }
}

- (void)onSetMixTranscodingConfig:(int)err errMsg:(NSString *)errMsg
{
    NSLog(@"onSetMixTranscodingConfig err:%d errMsg:%@", err, errMsg);
}

- (void)onStatistics:(TRTCStatistics *)statistics
{

}

- (void)onFirstVideoFrame:(NSString *)userId streamType:(TRTCVideoStreamType)streamType width:(int)width height:(int)height
{
    NSLog(@"onFirstVideoFrame userId:%@ streamType:%d width:%d height:%d", userId, streamType, width, height);
}

#pragma mark - button

/**
 * 点击打开仪表盘浮层，仪表盘浮层是SDK中覆盖在视频画面上的一系列数值状态
 */
- (void)clickLog:(UIButton *)btn {
    _showLogType ++;
    if (_showLogType > 2) {
        _showLogType = 0;
        [btn setImage:[UIImage imageNamed:@"log_b2"] forState:UIControlStateNormal];
    } else {
        [btn setImage:[UIImage imageNamed:@"log_b"] forState:UIControlStateNormal];
    }
    
     [_trtc showDebugView:_showLogType];
}

/**
 * 点击切换视频画面的九宫格布局模式和前后叠加模式
 */
- (void)clickGird:(UIButton *)btn {
    const int kStateFloat       = 0;
    const int kStateGrid        = 1;
    const int kStateFloatWindow = 2;
    if (_layoutBtnState == kStateFloat) {
        _layoutBtnState = kStateGrid;
        [_btnLayoutSwitch setImage:[UIImage imageNamed:@"gird_b"] forState:UIControlStateNormal];
        _layoutEngine.type = TC_Gird;
        [_trtc setDebugViewMargin:_mainViewUserId margin:UIEdgeInsetsZero];
    } else if (_layoutBtnState == kStateGrid){
        _layoutBtnState = kStateFloatWindow;
        [self back2FloatingWindow];
        return;
    }
    else if (_layoutBtnState == kStateFloatWindow) {
        [_btnLayoutSwitch setImage:[UIImage imageNamed:@"float_b"] forState:UIControlStateNormal];
        _layoutBtnState = kStateFloat;
        _layoutEngine.type = TC_Float;
        [_trtc setDebugViewMargin:_mainViewUserId margin:UIEdgeInsetsMake(_dashboardTopMargin, 0, 0, 0)];
    }
    
    [_trtc showDebugView:_showLogType];
}

/**
 * 打开或关闭本地视频上行
 */
- (void)clickVideoMute:(UIButton *)btn {
    _videoMuted = !_videoMuted;
    
    [btn setImage:[UIImage imageNamed:(_videoMuted ? @"unmuteVideo" : @"muteVideo")] forState:UIControlStateNormal];
    
    if (_videoMuted) {
        [_trtc stopLocalPreview];
        [_localView showVideoCloseTip:YES];
    }
    else {
        [_trtc startLocalPreview:YES view:_localView];
        [_localView showVideoCloseTip:NO];
    }
    [_trtc muteLocalVideo:_videoMuted];
}

/**
 * 点击开启或关闭美颜
 */
- (void)clickBeauty:(UIButton *)btn {
    _beautySwitch = !_beautySwitch;
    _vBeauty.hidden = !_beautySwitch;
}

/**
 * 点击关闭或者打开本地的音频上行
 */
- (void)clickMute:(UIButton *)btn {
    _muteSwitch = !_muteSwitch;
     [_trtc muteLocalAudio:_muteSwitch];
    [_btnMute setImage:[UIImage imageNamed:(_muteSwitch ? @"mute_b2" : @"mute_b")] forState:UIControlStateNormal];
}


/**
 * 打开编码参数设置面板，用于调整画质和音质
 */
- (void)clickSetting:(UIButton *)btn {
    TRTCSettingViewController *vc = [[TRTCSettingViewController alloc] init];
    [vc setDelegate:self];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 * 打开更多功能的设置面板
 */
- (void)clickMore:(UIButton*)btn
{
    [TRTCMoreViewController setRole:self.param.role];
    if (!_moreSettingVC) {
        _moreSettingVC = [[TRTCMoreViewController alloc] initWithTRTCEngine:_trtc roomId:_roomID userId:_selfUserID];
        _moreSettingVC.delegate = self;
    }
    if (btn.tag == 0) {
        btn.tag = 1;
        [self addChildViewController:_moreSettingVC];
        _moreSettingVC.view.frame = CGRectMake(0, self.view.height * 0.15, self.view.width, self.view.height * 0.7);
        [self.view addSubview:_moreSettingVC.view];
        [_moreSettingVC didMoveToParentViewController:self];
    }
    else {
        btn.tag = 0;
        [_moreSettingVC willMoveToParentViewController:nil];
        [_moreSettingVC.view removeFromSuperview];
        [_moreSettingVC removeFromParentViewController];        
    }
    
    [_moreSettingVC enableRoleSwitch:_appScene == TRTCAppSceneLIVE];
}

#pragma mark - TRTCMoreSettingDelegate
- (void)onAudioVolumeEnableChanged:(BOOL)enable
{
    for (TRTCVideoView* videoView in _remoteViewDic.allValues) {
        [videoView showAudioVolume:enable];
    }
}

- (void)onCloudMixingEnable:(BOOL)enable
{
    if (enable) {
        [self updateCloudMixtureParams];
    }
    else {
        [_trtc setMixTranscodingConfig:nil];
    }
}

- (void)onClickedSwitch2Role:(BOOL)isAudience
{
    if (_appScene == TRTCAppSceneVideoCall)
        return;
    _param.role = isAudience? TRTCRoleAudience : TRTCRoleAnchor;
    
    [_trtc switchRole:_param.role];
    
    if (isAudience) {
        [_trtc stopLocalAudio];
        [self stopPreview];
    }
    else {
        [_trtc startLocalAudio];
        [self startPreview];
    }
    [self relayout];
}

#pragma mark TRTCVideoViewDelegate
- (void)onMuteVideoBtnClick:(TRTCVideoView *)view stateChanged:(BOOL)stateChanged
{
    if (stateChanged) {
        [_trtc stopRemoteView:view.userId];
    }
    else {
        [_trtc startRemoteView:view.userId view:view];
    }
}

- (void)onMuteAudioBtnClick:(TRTCVideoView *)view stateChanged:(BOOL)stateChanged
{
    [_trtc muteRemoteAudio:view.userId mute:stateChanged];
}

- (void)onScaleModeBtnClick:(TRTCVideoView *)view stateChanged:(BOOL)stateChanged
{
    if (stateChanged) {
        [_trtc setRemoteViewFillMode:view.userId mode:TRTCVideoFillMode_Fill];
    }
    else {
        [_trtc setRemoteViewFillMode:view.userId mode:TRTCVideoFillMode_Fit];
    }
}


#pragma mark - TRtcEngineDelegate

/**
 * WARNING 大多是一些可以忽略的事件通知，SDK内部会启动一定的补救机制
 */
- (void)onWarning:(TXLiteAVWarning)warningCode warningMsg:(NSString *)warningMsg {
    
}


/**
 * WARNING 大多是不可恢复的错误，需要通过 UI 提示用户
 */
- (void)onError:(TXLiteAVError)errCode errMsg:(NSString *)errMsg extInfo:(nullable NSDictionary *)extInfo {

    if(errCode == ERR_ROOM_REQUEST_TOKEN_HTTPS_TIMEOUT ||
       errCode == ERR_ROOM_REQUEST_IP_TIMEOUT ||
       errCode == ERR_ROOM_REQUEST_ENTER_ROOM_TIMEOUT) {
        [self toastTip:[NSString stringWithFormat:@"进房超时，请检查网络或稍后重试:%d[%@]", errCode, errMsg]];
        [self exitRoom];
        return;
    }
    
    if(errCode == ERR_ROOM_REQUEST_TOKEN_INVALID_PARAMETER ||
       errCode == ERR_ENTER_ROOM_PARAM_NULL ||
       errCode == ERR_SDK_APPID_INVALID ||
       errCode == ERR_ROOM_ID_INVALID ||
       errCode == ERR_USER_ID_INVALID ||
       errCode == ERR_USER_SIG_INVALID) {
        [self toastTip:[NSString stringWithFormat:@"进房参数错误:%d[%@]", errCode, errMsg]];
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
        [self toastTip:[NSString stringWithFormat:@"进房失败，请稍后重试:%d[%@]", errCode, errMsg]];
        [self exitRoom];
        return;
    }
    
    if(errCode == ERR_SERVER_CENTER_ROOM_FULL ||
       errCode == ERR_SERVER_CENTER_REACH_PROXY_MAX) {
        [self toastTip:[NSString stringWithFormat:@"进房失败，房间满了，请稍后重试:%d[%@]", errCode, errMsg]];
        [self exitRoom];
        return;
    }
    
    if(errCode == ERR_SERVER_CENTER_ROOM_ID_TOO_LONG) {
        [self toastTip:[NSString stringWithFormat:@"进房失败，roomID超出有效范围:%d[%@]", errCode, errMsg]];
        [self exitRoom];
        return;
    }
    
    if(errCode == ERR_SERVER_ACC_ROOM_NOT_EXIST ||
       errCode == ERR_SERVER_CENTER_ROOM_NOT_EXIST) {
        [self toastTip:[NSString stringWithFormat:@"进房失败，请确认房间号正确:%d[%@]", errCode, errMsg]];
        [self exitRoom];
        return;
    }
    
    if(errCode == ERR_SERVER_INFO_SERVICE_SUSPENDED) {
        [self toastTip:[NSString stringWithFormat:@"进房失败，请确认腾讯云实时音视频账号状态是否欠费:%d[%@]", errCode, errMsg]];
        [self exitRoom];
        return;
    }
    
    if(errCode == ERR_SERVER_INFO_PRIVILEGE_FLAG_ERROR ||
       errCode == ERR_SERVER_CENTER_NO_PRIVILEDGE_CREATE_ROOM ||
       errCode == ERR_SERVER_CENTER_NO_PRIVILEDGE_ENTER_ROOM) {
        [self toastTip:[NSString stringWithFormat:@"进房失败，无权限进入房间:%d[%@]", errCode, errMsg]];
        [self exitRoom];
        return;
    }
    
    if(errCode <= ERR_SERVER_SSO_SIG_EXPIRED  &&
       errCode >= ERR_SERVER_SSO_INTERNAL_ERROR) {
        // 错误参考 https://cloud.tencent.com/document/product/269/1671#.E5.B8.90.E5.8F.B7.E7.B3.BB.E7.BB.9F
        [self toastTip:[NSString stringWithFormat:@"进房失败，userSig错误:%d[%@]", errCode, errMsg]];
        [self exitRoom];
        return;
    }

    NSString *msg = [NSString stringWithFormat:@"didOccurError: %@[%d]", errMsg, errCode];
    [self toastTip:msg];
}


- (void)onEnterRoom:(NSInteger)elapsed {
    NSString *msg = [NSString stringWithFormat:@"[%@]进房成功[%@]: elapsed[%ld]", _selfUserID, _roomID, (long)elapsed];
    [self toastTip:msg];
    
    [self setRoomStatus:TRTC_ENTERED];
}


- (void)onExitRoom:(NSInteger)reason {
    NSString *msg = [NSString stringWithFormat:@"离开房间[%@]: reason[%ld]", _roomID, (long)reason];
    [self toastTip:msg];
}

/**
 * 有新的用户加入了当前视频房间
 */
- (void)onUserEnter:(NSString *)userId {
    // 创建一个新的 View 用来显示新的一路画面
    TRTCVideoView *remoteView = [TRTCVideoView newVideoViewWithType:VideoViewType_Remote userId:userId];
    if (![TRTCMoreViewController isAudioVolumeEnable]) {
        [remoteView showAudioVolume:NO];
    }
    remoteView.delegate = self;
    [remoteView setBackgroundColor:UIColorFromRGB(0x262626)];
    [self.view addSubview:remoteView];
    [_remoteViewDic setObject:remoteView forKey:userId];

    // 将新进来的成员设置成大画面
    _mainViewUserId = userId;

    [self relayout];
    [self updateCloudMixtureParams];
}

/**
 * 有用户离开了当前视频房间
 */
- (void)onUserExit:(NSString *)userId reason:(NSInteger)reason {
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
        _mainViewUserId = _selfUserID;
    }

    [self relayout];
    [self updateCloudMixtureParams];

}

- (void)onUserAudioAvailable:(NSString *)userId available:(BOOL)available
{
    TRTCVideoView *playerView = [_remoteViewDic objectForKey:userId];
    if (!available) {
        [playerView setAudioVolumeRadio:0.f];
    }
    NSLog(@"onUserAudioAvailable:userId:%@ alailable:%u", userId, available);
}


- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available
{
    if (userId != nil) {
        TRTCVideoView* remoteView = [_remoteViewDic objectForKey:userId];
        if (available) {
            // 启动远程画面的解码和显示逻辑，FillMode 可以设置是否显示黑边
            if (!self.enableCustomVideoCapture) {
                [_trtc startRemoteView:userId view:remoteView];
                [_trtc setRemoteViewFillMode:userId mode:TRTCVideoFillMode_Fit];
            }
            else {
                //测试自定义渲染
                [_trtc setRemoteVideoRenderDelegate:userId delegate:_customVideoRenderTester pixelFormat:TRTCVideoPixelFormat_NV12 bufferType:TRTCVideoBufferType_PixelBuffer];
                [_customVideoRenderTester addUser:userId videoView:remoteView];
                [_trtc startRemoteView:userId view:nil];
            }
        }
        else {
            [_trtc stopRemoteView:userId];
        }

        [remoteView showVideoCloseTip:!available];
    }
    
    NSLog(@"onUserVideoAvailable:userId:%@ alailable:%u", userId, available);

}

- (void)onUserSubStreamAvailable:(NSString *)userId available:(BOOL)available
{
    NSLog(@"onUserSubStreamAvailable:userId:%@ alailable:%u", userId, available);
    NSString* viewId = [NSString stringWithFormat:@"%@-sub", userId];
    if (available) {
        TRTCVideoView *remoteView = [TRTCVideoView newVideoViewWithType:VideoViewType_Remote userId:userId];
        if (![TRTCMoreViewController isAudioVolumeEnable]) {
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
            _mainViewUserId = _selfUserID;
        }
    }
    [self relayout];
}

- (void)onAudioRouteChanged:(TRTCAudioRoute)route fromRoute:(TRTCAudioRoute)fromRoute {
    NSLog(@"TRTC onAudioRouteChanged %ld -> %ld", (long)fromRoute, route);
}


- (void)onSwitchRole:(TXLiteAVError)errCode errMsg:(NSString *)errMsg
{
    NSLog(@"onSwitchRole errCode:%d, errMsg:%@", errCode, errMsg);
}
#pragma mark - TRTCSettingVCDelegate

- (void)settingVC:(TRTCSettingViewController *)settingVC
         Property:(TRTCSettingsProperty *)property {

    TRTCVideoEncParam* encParam = [[TRTCVideoEncParam alloc] init];
    encParam.videoResolution = property.resolution;
    encParam.videoFps = property.fps;
    encParam.videoBitrate = property.bitRate;
    encParam.resMode = property.resMode;

    [_trtc setVideoEncoderParam:encParam];
    
    TRTCNetworkQosParam * qosParam = [TRTCNetworkQosParam new];
    qosParam.preference = property.qosType + 1;
    TRTCQosControlMode qosControl = property.qosControl;
    qosParam.controlMode = qosControl;
    [_trtc setNetworkQosParam:qosParam];
    
    TRTCVideoEncParam* smallVideoConfig = [TRTCVideoEncParam new];
    smallVideoConfig.videoResolution = TRTCVideoResolution_160_90;
    smallVideoConfig.videoFps = property.fps;
    smallVideoConfig.videoBitrate = 100;
    smallVideoConfig.resMode = property.resMode;
    [_trtc enableEncSmallVideoStream:property.enableSmallStream withQuality:smallVideoConfig];
    
    [_trtc setPriorRemoteVideoStreamType:property.priorSmallStream];
    
}


- (void)onConnectOtherRoom:(NSString *)userId errCode:(TXLiteAVError)errCode errMsg:(NSString *)errMsg
{
    [self toastTip:[NSString stringWithFormat:@"连麦结果:%u %@", errCode, errMsg]];
    if (errCode != 0) {
        [_moreSettingVC.getPKInfo removeObjectForKey:userId];
    }
}

- (void)onNetworkQuality:(TRTCQualityInfo *)localQuality remoteQuality:(NSArray<TRTCQualityInfo *> *)remoteQuality
{
    [_localView setNetworkIndicatorImage:[self imageForNetworkQuality:localQuality.quality]];
    for (TRTCQualityInfo* qualityInfo in remoteQuality) {
        TRTCVideoView* remoteVideoView = [_remoteViewDic objectForKey:qualityInfo.userId];
        [remoteVideoView setNetworkIndicatorImage:[self imageForNetworkQuality:qualityInfo.quality]];
    }
}

- (void)onUserVoiceVolume:(NSArray<TRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume
{
    [_remoteViewDic enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, TRTCVideoView * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj setAudioVolumeRadio:0.f];
        [obj showAudioVolume:YES];
    }];
    
    for (TRTCVolumeInfo* volumeInfo in userVolumes) {
        TRTCVideoView* videoView = [_remoteViewDic objectForKey:volumeInfo.userId];
        if (videoView) {
            float radio = ((float)volumeInfo.volume) / 100;
            [videoView setAudioVolumeRadio:radio];
        }
    }
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
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

/**
 @method 获取指定宽度width的字符串在UITextView上的高度
 @param textView 待计算的UITextView
 @param width 限制字符串显示区域的宽度
 @result float 返回的高度
 */
- (float)heightForString:(UITextView *)textView andWidth:(float)width {
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}

- (void)toastTip:(NSString *)toastInfo {
    _toastMsgCount++;
    
    CGRect frameRC = [[UIScreen mainScreen] bounds];
    frameRC.origin.y = frameRC.size.height - 110;
    frameRC.size.height -= 110;
    __block UITextView *toastView = [[UITextView alloc] init];
    
    toastView.editable = NO;
    toastView.selectable = NO;
    
    frameRC.size.height = [self heightForString:toastView andWidth:frameRC.size.width];
    
    // 避免新的tips将之前未消失的tips覆盖掉，现在是不断往上偏移
    frameRC.origin.y -= _toastMsgHeight;
    _toastMsgHeight += frameRC.size.height;
    
    toastView.frame = frameRC;
    
    toastView.text = toastInfo;
    toastView.backgroundColor = [UIColor whiteColor];
    toastView.alpha = 0.5;
    
    [self.view addSubview:toastView];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    
    __weak __typeof(self) weakSelf = self;
    dispatch_after(popTime, dispatch_get_main_queue(), ^() {
        [toastView removeFromSuperview];
        toastView = nil;
        if (weakSelf.toastMsgCount > 0) {
            weakSelf.toastMsgCount--;
        }
        if (weakSelf.toastMsgCount == 0) {
            weakSelf.toastMsgHeight = 0;
        }
    });
}

#pragma mark - 系统事件
/**
 * 在前后堆叠模式下，响应手指触控事件，用来切换视频画面的布局
 */

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
     _vBeauty.hidden = YES;
}

- (void)onViewTap:(TRTCVideoView *)view touchCount:(NSInteger)touchCount
{
    if (_roomStatus != TRTC_ENTERED) {
        return;
    }
    
    if (_layoutEngine.type == TC_Gird)
        return;
    
    if (view == _localView) {
        _mainViewUserId = _selfUserID;
    } else {
        for (id userID in _remoteViewDic) {
            UIView *pw = [_remoteViewDic objectForKey:userID];
            if (view == pw ) {
                _mainViewUserId = userID;
            }
        }
    }
    [self relayout];
    return;
}

- (void)onAudioCapturePcm:(NSData *)pcmData sampleRate:(int)sampleRate channels:(int)channels ts:(uint32_t)timestampMs {
    TRTCAudioFrame * frame = [[TRTCAudioFrame alloc] init];
    frame.data = pcmData;
    frame.sampleRate = sampleRate;
    frame.channels = channels;
    frame.timestamp = timestampMs;
    [_trtc sendCustomAudioData:frame];
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

#pragma mark - BeautySettingPanelDelegate
- (void)onSetBeautyStyle:(int)beautyStyle beautyLevel:(float)beautyLevel whitenessLevel:(float)whitenessLevel ruddinessLevel:(float)ruddinessLevel
{
    [_trtc setBeautyStyle:beautyStyle beautyLevel:beautyLevel whitenessLevel:whitenessLevel ruddinessLevel:ruddinessLevel];
}

- (void)onSetEyeScaleLevel:(float)eyeScaleLevel
{
    [_trtc setEyeScaleLevel:eyeScaleLevel];
}

- (void)onSetFaceScaleLevel:(float)faceScaleLevel
{
    [_trtc setFaceScaleLevel:faceScaleLevel];
}

- (void)onSetFilter:(UIImage *)filterImage
{
    [_trtc setFilter:filterImage];
}

- (void)onSetGreenScreenFile:(NSURL *)file
{
    [_trtc setGreenScreenFile:file];
}

- (void)onSelectMotionTmpl:(NSString *)tmplName inDir:(NSString *)tmplDir
{
    [_trtc selectMotionTmpl:[tmplDir stringByAppendingPathComponent:tmplName]];
}

- (void)onSetFaceVLevel:(float)vLevel
{
    [_trtc setFaceVLevel:vLevel];
}

- (void)onSetFaceShortLevel:(float)shortLevel
{
    [_trtc setFaceShortLevel:shortLevel];
}

- (void)onSetNoseSlimLevel:(float)slimLevel
{
    [_trtc setNoseSlimLevel:slimLevel];
}

- (void)onSetChinLevel:(float)chinLevel
{
    [_trtc setChinLevel:chinLevel];
}

- (void)onSetMixLevel:(float)mixLevel
{
    [_trtc setFilterConcentration:mixLevel / 10.0];
}

@end
