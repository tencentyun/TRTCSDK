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

typedef enum : NSUInteger {
    TRTC_IDLE,       // SDK 没有进入视频通话状态
    TRTC_ENTERED,    // SDK 视频通话进行中
} TRTCStatus;

@interface TRTCMainViewController() <UITextFieldDelegate, TRTCCloudDelegate, TRTCSettingVCDelegate> {
    TRTCCloud                *_trtc;               //TRTC SDK 实例对象
    TRTCStatus                _roomStatus;
    
    NSString                 *_mainViewUserId;     //视频画面支持点击切换，需要用一个变量记录当前哪一路画面是全屏状态的
    
    NSInteger                 _toastMsgCount;      //当前tips数量
    NSInteger                 _toastMsgHeight;
    TRTCVideoViewLayout      *_layoutEngine;
    UIView                   *_holderView;
    
    UIView                   *_localView;          //本地画面的view
    NSMutableDictionary*      _remoteViewDic;      //一个或者多个远程画面的view
    
    UIButton                 *_btnLog;             //用于显示通话质量的log按钮
    UIButton                 *_btnCameraSwitch;    //前置和后置摄像头切换
    UIButton                 *_btnLayoutSwitch;    //布局切换按钮（九宫格 OR 前后叠加）
    UIButton                 *_btnBeauty;          //是否开启美颜（磨皮）
    UIButton                 *_btnMute;            //是否静音本地画面
    UIButton                 *_btnSetting;         //设置面板，关联打开 TRTCSettingViewController
    
    NSInteger                _showLogType;         //LOG浮层显示详细信息还是精简信息
    BOOL                     _cameraSwitch;
    BOOL                     _beautySwitch;
    BOOL                     _muteSwitch;
}

@property uint32_t sdkAppid;
@property (nonatomic, copy) NSString* roomID;
@property (nonatomic, copy) NSString* selfUserID;
@property NSString  *selfUserSig;

@end

@implementation TRTCMainViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

/**
 * 检查当前APP是否已经获得摄像头和麦克风权限，没有获取边提示用户开启权限
 */
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
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

- (void)setParam:(TRTCParams *)param
{
    _param = param;
    _sdkAppid = param.sdkAppId;
    _selfUserID = param.userId;
    _selfUserSig = param.userSig;
    _roomID = @(param.roomId).stringValue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    _trtc = [[TRTCCloud alloc] init];
    [_trtc setDelegate:self];
    
    _roomStatus = TRTC_IDLE;
    _remoteViewDic = [[NSMutableDictionary alloc] init];
    _mainViewUserId = @"";
    _toastMsgCount = 0;
    _toastMsgHeight = 0;
    
    // 初始化 UI 控件
    [self initUI];
    
    // 开始登录、进房
    [self enterRoom];
    [TRTCCloud setConsoleEnabled:YES];
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
    }
    
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
    
    float startSpace = 20;
    float centerInterVal = (size.width - 2 * startSpace - ICON_SIZE) / 5  - ICON_SIZE;
    float iconY = size.height - ICON_SIZE / 2 - 10;
    
    _btnLayoutSwitch = [self createBottomBtnIcon:@"float_b"
                                          Action:@selector(clickGird:)
                                          Center:CGPointMake(startSpace + ICON_SIZE / 2, iconY)
                                            Size:ICON_SIZE];
    [_btnLayoutSwitch setImage:[UIImage imageNamed:@"gird_b"] forState:UIControlStateSelected];
    
    _cameraSwitch = NO;
    _btnCameraSwitch = [self createBottomBtnIcon:@"camera_b"
                                          Action:@selector(clickCamera:)
                                          Center:CGPointMake(_btnLayoutSwitch.center.x + ICON_SIZE + centerInterVal, iconY)
                                            Size:ICON_SIZE];
    
    _beautySwitch = NO;
    _btnBeauty = [self createBottomBtnIcon:@"beauty_b2"
                                          Action:@selector(clickBeauty:)
                                          Center:CGPointMake(_btnCameraSwitch.center.x + ICON_SIZE + centerInterVal, iconY)
                                            Size:ICON_SIZE];
    
    _muteSwitch = NO;
    _btnMute = [self createBottomBtnIcon:@"mute_b"
                                  Action:@selector(clickMute:)
                                  Center:CGPointMake(_btnBeauty.center.x + ICON_SIZE + centerInterVal, iconY)
                                    Size:ICON_SIZE];
    
    _btnSetting = [self createBottomBtnIcon:@"set_b"
                                 Action:@selector(clickSetting:)
                                 Center:CGPointMake(_btnMute.center.x + ICON_SIZE + centerInterVal, iconY)
                                   Size:ICON_SIZE];
    
    _showLogType = 0;
    _btnLog = [self createBottomBtnIcon:@"log_b2"
                                 Action:@selector(clickLog:)
                                 Center:CGPointMake(_btnSetting.center.x + ICON_SIZE + centerInterVal, iconY)
                                   Size:ICON_SIZE];
    
    // 本地预览view
    _localView = [[UIView alloc] initWithFrame:self.view.bounds];
    [_localView setBackgroundColor:UIColorFromRGB(0x262626)];
    
    _holderView = [[UIView alloc] initWithFrame:self.view.bounds];
    [_holderView setBackgroundColor:UIColorFromRGB(0x262626)];
    [self.view insertSubview:_holderView atIndex:0];
    
    _layoutEngine = [[TRTCVideoViewLayout alloc] init];
    _layoutEngine.view = _holderView;
    
    [self relayout];
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
    } else if([_remoteViewDic objectForKey:_mainViewUserId] != nil) {
        [views addObject:_remoteViewDic[_mainViewUserId]];
    }
    for (id userID in _remoteViewDic) {
        UIView *playerView = [_remoteViewDic objectForKey:userID];
        if ([_mainViewUserId isEqual:userID]) {
            [views addObject:_localView];
        } else {
            [views addObject:playerView];
        }
    }
    UIEdgeInsets edge = UIEdgeInsetsZero;
    if (_layoutEngine.type == TC_Float || views.count == 1) {
        edge = UIEdgeInsetsMake(0.12, 0, 0, 0);
    }
    if ([_mainViewUserId isEqual:@""]) {
        [_trtc setDebugViewMargin:_selfUserID margin:edge];
    } else {
        [_trtc setDebugViewMargin:_mainViewUserId margin:edge];
    }
    
    [_layoutEngine relayout:views];
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
    if (!_pureAudioMode) {
        TRTCVideoEncParam* encParam = [TRTCVideoEncParam new];
        encParam.videoResolution = [TRTCSettingViewController getResolution];
        encParam.videoBitrate = [TRTCSettingViewController getBitrate];
        encParam.videoFps = [TRTCSettingViewController getFPS];
        encParam.resMode = TRTCVideoResolutionModePortrait;
        [_trtc setVideoEncoderParam:encParam];
        
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
        
        [_trtc enableEncSmallVideoStream:[TRTCSettingViewController getEnableSmallStream] withQuality:smallVideoConfig];
        [_trtc setPriorRemoteVideoStreamType:[TRTCSettingViewController getPriorSmallStream]];
        
    //    [_trtc setLocalViewFillMode:TRTCVideoFillMode_Fit];
        [_trtc setGSensorMode:TRTCGSensorMode_UIAutoLayout];

        // 开启视频采集预览
        [_trtc startLocalPreview:YES view:_localView];
    }
    [_trtc startLocalAudio];
    
    [self toastTip:@"开始进房"];
    
    // 进房
    TRTCAppScene scene = [TRTCSettingViewController getAppScene];
    [_trtc enterRoom:self.param appScene:scene];
}

- (void)onStatistics:(TRTCStatistics *)statistics
{

}

- (void)onNetworkQuality:(TRTCQualityInfo *)localQuality remoteQuality:(NSArray<TRTCQualityInfo *> *)remoteQuality
{

}

/**
 * 退出房间，并且退出该页面
 */
- (void)exitRoom {
    [_trtc exitRoom];
    
    [self setRoomStatus:TRTC_IDLE];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
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
    btn.selected = !btn.selected;
    if (btn.selected) {
        _layoutEngine.type = TC_Gird;
    } else {
        _layoutEngine.type = TC_Float;
    }
    [_trtc showDebugView:_showLogType];
}

/**
 * 点击切换前后置摄像头
 */
- (void)clickCamera:(UIButton *)btn {
    _cameraSwitch = !_cameraSwitch;
    
    [btn setImage:[UIImage imageNamed:(_cameraSwitch ? @"camera_b2" : @"camera_b")] forState:UIControlStateNormal];
    
    [_trtc switchCamera];
}

/**
 * 点击开启或关闭美颜
 */
- (void)clickBeauty:(UIButton *)btn {
    _beautySwitch = !_beautySwitch;
    [btn setImage:[UIImage imageNamed:(_beautySwitch ? @"beauty_b" : @"beauty_b2")] forState:UIControlStateNormal];
    
    if (_beautySwitch) {
        // 为了简单，全部使用默认值
        [_trtc setBeautyStyle:TRTCBeautyStyleNature beautyLevel:5 whitenessLevel:5 ruddinessLevel:5];
    } else {
        // 全部设置0表示关闭美颜
        [_trtc setBeautyStyle:TRTCBeautyStyleNature beautyLevel:0 whitenessLevel:0 ruddinessLevel:0];
    }
}

/**
 * 点击关闭或者打开本地的麦克风采集
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

    
    if (errCode == ERR_ROOM_ENTER_FAIL) {
        [self toastTip:[NSString stringWithFormat:@"无法进入音视频房间[%@]", errMsg]];
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
    UIView *remoteView = [[UIView alloc] init];
    [remoteView setBackgroundColor:UIColorFromRGB(0x262626)];
    [self.view addSubview:remoteView];
    [_remoteViewDic setObject:remoteView forKey:userId];
    
    // 启动远程画面的解码和显示逻辑，FillMode 可以设置是否显示黑边
    [_trtc startRemoteView:userId view:remoteView];
    [_trtc setRemoteViewFillMode:userId mode:TRTCVideoFillMode_Fit];
    // 将新进来的成员设置成大画面
    _mainViewUserId = userId;
    
    [self relayout];
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
}

- (void)onUserAudioAvailable:(NSString *)userId available:(BOOL)available
{
    NSLog(@"onUserAudioAvailable:userId:%@ alailable:%u", userId, available);
}


- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available
{
    NSLog(@"onUserVideoAvailable:userId:%@ alailable:%u", userId, available);
    

}

- (void)onUserSubStreamAvailable:(NSString *)userId available:(BOOL)available
{
    NSLog(@"onUserSubStreamAvailable:userId:%@ alailable:%u", userId, available);
    NSString* viewId = [NSString stringWithFormat:@"%@-sub", userId];
    if (available) {
        UIView *remoteView = [[UIView alloc] init];
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
    NSLog(@"TRTC onAudioRouteChanged %ld -> %ld", fromRoute, route);
}
#pragma mark - TRTCSettingVCDelegate

- (void)settingVC:(TRTCSettingViewController *)settingVC
         Property:(TRTCSettingsProperty *)property {

    TRTCVideoEncParam* encParam = [[TRTCVideoEncParam alloc] init];
    encParam.videoResolution = property.resolution;
    encParam.videoFps = property.fps;
    encParam.videoBitrate = property.bitRate;

    [_trtc setVideoEncoderParam:encParam];
    
    TRTCNetworkQosParam * qosParam = [TRTCNetworkQosParam new];
    qosParam.preference = property.qosType + 1;
    TRTCQosControlMode qosControl = property.qosControl;
    qosParam.controlMode = qosControl;
    [_trtc setNetworkQosParam:qosParam];
    
    TRTCVideoEncParam* smallVideoConfig = [TRTCVideoEncParam new];
    smallVideoConfig.videoResolution = TRTCVideoResolution_160_120;
    smallVideoConfig.videoFps = property.fps;
    smallVideoConfig.videoBitrate = 100;
    [_trtc enableEncSmallVideoStream:property.enableSmallStream withQuality:smallVideoConfig];
    
    [_trtc setPriorRemoteVideoStreamType:property.priorSmallStream];
    
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
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^() {
        [toastView removeFromSuperview];
        toastView = nil;
        if (self->_toastMsgCount > 0) {
            self->_toastMsgCount--;
        }
        if (self->_toastMsgCount == 0) {
            self->_toastMsgHeight = 0;
        }
    });
}

#pragma mark - 系统事件
/**
 * 在前后堆叠模式下，响应手指触控事件，用来切换视频画面的布局
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_roomStatus != TRTC_ENTERED) {
        return;
    }
      
    if (_layoutEngine.type == TC_Gird)
        return;
    
    for (int i = (int)_holderView.subviews.count - 1; i >= 0; i--) {
        UIView *playerView = _holderView.subviews[i];
        CGPoint p = [[touches anyObject] locationInView:playerView];
        if ([playerView hitTest:p withEvent:event]) {
            if (playerView == _localView) {
                _mainViewUserId = _selfUserID;
            } else {
                for (id userID in _remoteViewDic) {
                    UIView *pw = [_remoteViewDic objectForKey:userID];
                    if (playerView == pw ) {
                        _mainViewUserId = userID;
                    }
                }
            }
            [self relayout];
            return;
        }
    }
}

@end
