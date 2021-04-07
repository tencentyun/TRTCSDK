/**
 * Module: TCAudienceViewController
 *
 * Function: 观众播放模块主控制器，里面承载了渲染view，逻辑view，以及播放相关逻辑，同时也是SDK层事件通知的接收者
 */

#import "TCAudienceViewController.h"
#import "TCAnchorViewController.h"
#import <mach/mach.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import "TCMsgModel.h"
#import "NSString+Common.h"
#import "TCStatusInfoView.h"
#import "UIView+Additions.h"
#import "HUDHelper.h"
#import "TXLiteAVDemo-Swift.h"

#define VIDEO_VIEW_WIDTH            100
#define VIDEO_VIEW_HEIGHT           150
#define VIDEO_VIEW_MARGIN_BOTTOM    56
#define VIDEO_VIEW_MARGIN_RIGHT     8
#define VIDEO_VIEW_MARGIN_SPACE     5

@interface TCAudienceViewController() <
    UITextFieldDelegate,
    TCAudienceToolbarDelegate,
    TXLiveRecordListener,
TRTCLiveRoomDelegate>

@end

@implementation TCAudienceViewController
{

    TX_Enum_PlayType     _playType;
    
    long long            _trackingTouchTS;
    BOOL                 _startSeek;
    BOOL                 _videoPause;
    BOOL                 _videoFinished;
    float                _sliderValue;
    BOOL                 _isLivePlay;
    BOOL                 _isInVC;
    NSString             *_rtmpUrl;

    BOOL                  _rotate;
    BOOL                 _isErrorAlert; //是否已经弹出了错误提示框，用于保证在同时收到多个错误通知时，只弹一个错误提示框
    
    //link mic
    BOOL                    _isBeingLinkMic;
    BOOL                    _isWaitingResponse;
    
    UITextView *            _waitingNotice;
    UIButton*               _btnCamera;
    UIButton*               _btnLinkMic;
    BOOL                    _isStop;
    
    NSMutableArray*         _statusInfoViewArray;         //小画面播放列表
    UILabel                *_noOwnerTip;
    
    int                     _errorCode;
    NSString *              _errorMsg;
    
    uint64_t                _beginTime;
    uint64_t                _endTime;
}

- (id)initWithPlayInfo:(TRTCLiveRoomInfo *)info videoIsReady:(videoIsReadyBlock)videoIsReady {
    if (self = [super init]) {
        _liveInfo = info;
        _videoIsReady = videoIsReady;
        _videoPause   = NO;
        _videoFinished = YES;
        _isInVC       = NO;
        _log_switch   = NO;
        _errorCode    = 0;
        _errorMsg     = @"";
        
        _isLivePlay = YES;
        
        if ([_rtmpUrl hasPrefix:@"http:"]) {
            _rtmpUrl = [_rtmpUrl stringByReplacingOccurrencesOfString:@"http:" withString:@"https:"];
        }
        _rotate       = NO;
        _isErrorAlert = NO;
        _isOwnerEnter = NO;
        _isStop = NO;
        
        //link mic
        _isBeingLinkMic = false;
        _isWaitingResponse = false;
        self.liveRoom.delegate = self;
        
        _roomStatus = TRTCLiveRoomLiveStatusNone;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)onAppWillResignActive:(NSNotification *)notification {
    if (_isBeingLinkMic) {
    }
}

- (void)onAppDidBecomeActive:(NSNotification *)notification {
    if (_isBeingLinkMic) {
    }
}

- (void)onAppDidEnterBackGround:(UIApplication *)app {
    if (_isBeingLinkMic) {
    }
}

- (void)onAppWillEnterForeground:(UIApplication *)app {
    if (_isBeingLinkMic) {
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self startRtmp];
    _isInVC = YES;
    if (_errorCode != 0) {
        [self onError:_errorCode errMsg:_errorMsg extraInfo:nil];
        _errorCode = 0;
        _errorMsg  = @"";
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopRtmp];
    _isInVC = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupToast];
    //加载背景图
    UIImage *backImage = [UIImage imageNamed:@"avatar0_100"];
    UIImage *clipImage = nil;
    if (backImage) {
        CGFloat backImageNewHeight = self.view.height;
        CGFloat backImageNewWidth = backImageNewHeight * backImage.size.width / backImage.size.height;
        UIImage *gsImage = [TCUtil gsImage:backImage withGsNumber:10];
        UIImage *scaleImage = [TCUtil scaleImage:gsImage scaleToSize:CGSizeMake(backImageNewWidth, backImageNewHeight)];
        clipImage = [TCUtil clipImage:scaleImage inRect:CGRectMake((backImageNewWidth - self.view.width)/2, (backImageNewHeight - self.view.height)/2, self.view.width, self.view.height)];
    }
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    backgroundImageView.image = clipImage;
    backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    backgroundImageView.backgroundColor = [UIColor appBackGround];
    [self.view addSubview:backgroundImageView];
    
    _noOwnerTip = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height / 2 - 40, self.view.bounds.size.width, 30)];
    _noOwnerTip.backgroundColor = [UIColor clearColor];
    [_noOwnerTip setTextColor:[UIColor whiteColor]];
    [_noOwnerTip setTextAlignment:NSTextAlignmentCenter];
    [_noOwnerTip setText:TRTCLocalize(@"Demo.TRTC.LiveRoom.anchornotonline")];
    [self.view addSubview:_noOwnerTip];
    [_noOwnerTip setHidden:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.isOwnerEnter) {
            [self->_noOwnerTip setHidden:NO];
        }
    });
    
    //视频画面父view
    _videoParentView = [[UIView alloc] initWithFrame:self.view.frame];
    _videoParentView.tag = FULL_SCREEN_PLAY_VIDEO_VIEW;
    [self.view addSubview:_videoParentView];
    [_videoParentView setHidden:YES];
    
    [self initLogicView];
    _beginTime = [[NSDate date] timeIntervalSince1970];
}

- (void)viewDidDisappear:(BOOL)animated {
    _endTime = [[NSDate date] timeIntervalSince1970];
}

- (void)dealloc {
    [self stopRtmp];
    NSLog(@"dealloc audienceVC");
}

- (void)initLogicView {
    if (!_logicView) {
        CGFloat bottom = 0;
        if (@available(iOS 11, *)) {
            bottom = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
        }
        CGRect frame = self.view.frame;
        frame.size.height -= bottom;
        _logicView = [[TCAudienceToolbarView alloc] initWithFrame:frame liveInfo:self.liveInfo withLinkMic: YES];
        _logicView.delegate = self;
        _logicView.liveRoom = _liveRoom;
        [self.view addSubview:_logicView];
        
        if (_btnLinkMic == nil) {
            int   icon_size = BOTTOM_BTN_ICON_WIDTH;
            float startSpace = 15;
            
            float icon_count = 7;
            float icon_center_interval = (_logicView.width - 2*startSpace - icon_size)/(icon_count - 1);
            float icon_center_y = _logicView.height - icon_size/2 - startSpace;
            
            //Button: 发起连麦
            _btnLinkMic = [UIButton buttonWithType:UIButtonTypeCustom];
            _btnLinkMic.center = CGPointMake(_logicView.closeBtn.center.x - icon_center_interval, icon_center_y);
            [_btnLinkMic setImage:[UIImage imageNamed:@"linkmic_on"] forState:UIControlStateNormal];
            [_btnLinkMic addTarget:self action:@selector(clickBtnLinkMic:) forControlEvents:UIControlEventTouchUpInside];
            [_logicView addSubview:_btnLinkMic];
            [_btnLinkMic mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self->_logicView.closeBtn).offset(-icon_center_interval*2.5);
                make.centerY.equalTo(self->_logicView.closeBtn);
                make.width.height.equalTo(@(icon_size));
            }];
            
            //Button: 前置后置摄像头切换
            CGRect rectBtnLinkMic = _btnLinkMic.frame;
            _btnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
            _btnCamera.center = CGPointMake(_btnLinkMic.center.x - icon_center_interval, icon_center_y);
            _btnCamera.bounds = CGRectMake(0, 0, CGRectGetWidth(rectBtnLinkMic), CGRectGetHeight(rectBtnLinkMic));
            [_btnCamera setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
            [_btnCamera addTarget:self action:@selector(clickBtnCamera:) forControlEvents:UIControlEventTouchUpInside];
            _btnCamera.hidden = YES;
            [_logicView addSubview:_btnCamera];
        }
        
        //初始化连麦播放小窗口
        if (_statusInfoViewArray == nil) {
            _statusInfoViewArray = [NSMutableArray new];
            [self initStatusInfoView:1];
            [self initStatusInfoView:2];
            [self initStatusInfoView:3];
        }
        
        //logicView不能被连麦小窗口挡住
        [self.logicView removeFromSuperview];
        [self.view addSubview:self.logicView];
    }
}

- (void)initRoomLogic {
    _liveRoom.delegate = self;
    __weak __typeof(self) wself = self;
    [_liveRoom enterRoomWithRoomID:[_liveInfo.roomId intValue] callback:^(int code, NSString * error) {
        __strong __typeof(wself) self = wself;
        if (self == nil) {
            return ;
        }
        if (code == 0) {
            __block BOOL isGetList = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //获取成员列表
                [self.liveRoom getAudienceList:^(int code, NSString * error, NSArray<TRTCLiveUserInfo *> * users) {
                    isGetList = (code == 0);
                    [self->_logicView initAudienceList:users];
                }];
            });
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (isGetList) {
                    return;
                }
                //获取成员列表
                [self.liveRoom getAudienceList:^(int code, NSString * error, NSArray<TRTCLiveUserInfo *> * users) {
                    [self->_logicView initAudienceList:users];
                }];
            });
            
        } else {
            __strong __typeof(wself) self = wself;
            if (self == nil) {
                return ;
            }
            [self makeToastWithMessage:error.length > 0 ? error : TRTCLocalize(@"Demo.TRTC.LiveRoom.enterroomfailed")];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //退房
                [self closeVCWithRefresh:YES popViewController:YES];
            });
            
        }
    }];
}

- (void)startLinkMic {
    if (_isBeingLinkMic || _isWaitingResponse) {
        return;
    }
    __weak __typeof(self) wself = self;
    _isWaitingResponse = YES;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onWaitLinkMicResponseTimeOut) object:nil];
    [self performSelector:@selector(onWaitLinkMicResponseTimeOut) withObject:nil afterDelay:20];
    
    [_btnLinkMic setImage:[UIImage imageNamed:@"linkmic_off"] forState:UIControlStateNormal];
    [_btnLinkMic setEnabled:NO];
    
    [self showWaitingNotice:TRTCLocalize(@"Demo.TRTC.LiveRoom.waitforanchoraccept")];
    
    [self.liveRoom requestJoinAnchor:@"" responseCallback:^(BOOL agreed, NSString * reason) {
        __strong __typeof(wself) self = wself;
        if (self == nil) {
            return ;
        }
        if (self->_isWaitingResponse == NO || !self->_isInVC) {
            return;
        }
        self->_isWaitingResponse = NO;
        [self->_btnLinkMic setEnabled:YES];
        [self hideWaitingNotice];
        if (agreed) {
            self->_isBeingLinkMic = YES;
            [self->_btnLinkMic setImage:[UIImage imageNamed:@"linkmic_off"] forState:UIControlStateNormal];
            [TCUtil toastTip:TRTCLocalize(@"Demo.TRTC.LiveRoom.anchoracceptreqandbegan") parentView:self.view];
            
            //推流允许前后切换摄像头
            self->_btnCamera.hidden = NO;
            
            //查找空闲的TCSmallPlayer, 开始loading
            for (TCStatusInfoView * statusInfoView in self->_statusInfoViewArray) {
                if (statusInfoView.userID == nil || statusInfoView.userID.length == 0) {
                    [[AppUtils shared] alertUserTips:self];
                    
                    statusInfoView.userID = [[ProfileManager shared] curUserID];
                    [self.liveRoom startCameraPreviewWithFrontCamera:YES view:statusInfoView.videoView callback:^(int code, NSString * error) {
                        
                    }];
                    NSString *streamID = [NSString stringWithFormat:@"%@_stream",[[ProfileManager shared] curUserID]];
                    [self.liveRoom startPublishWithStreamID:streamID callback:^(int code, NSString * error) {
                        
                    }];
                    break;
                }
            }
        } else {
            self->_isBeingLinkMic = NO;
            self->_isWaitingResponse = NO;
            [self->_btnLinkMic setImage:[UIImage imageNamed:@"linkmic_on"] forState:UIControlStateNormal];
            if ([reason length] > 0) {
                [TCUtil toastTip:reason parentView:self.view];
            } else {
                [TCUtil toastTip:TRTCLocalize(@"Demo.TRTC.LiveRoom.refusemicconnectionreq") parentView:self.view];
            }
        }
    }];
}

- (void)stopLinkMic {
    // 关闭所有的播放器
    for (TCStatusInfoView* statusInfoView in _statusInfoViewArray) {
        [statusInfoView stopLoading];
        [statusInfoView stopPlay];
        if (statusInfoView.userID.length) {
            [self.liveRoom stopPlayWithUserID:statusInfoView.userID callback:^(int code, NSString * error) {
                
            }];
        }
        [statusInfoView emptyPlayInfo];
    }
}

- (void)stopLocalPreview {
    if (_isBeingLinkMic == YES) {
        [self.liveRoom stopPublish:^(int code, NSString * error) {
            
        }];
        
        //关闭本地摄像头，停止推流
        for (TCStatusInfoView* statusInfoView in _statusInfoViewArray) {
            if ([statusInfoView.userID isEqualToString:[[ProfileManager shared] curUserID]]) {
                [self.liveRoom stopCameraPreview];
                [statusInfoView stopLoading];
                [statusInfoView stopPlay];
                [statusInfoView emptyPlayInfo];
                break;
            }
        }
        //UI重置
        [_btnLinkMic setImage:[UIImage imageNamed:@"linkmic_on"] forState:UIControlStateNormal];
        [_btnLinkMic setEnabled:YES];
        _btnCamera.hidden = YES;
        
        _isBeingLinkMic = NO;
        _isWaitingResponse = NO;
    }
}

- (void)initStatusInfoView: (int)index {
    CGFloat width = self.view.size.width;
    CGFloat height = self.view.size.height;
    
    TCStatusInfoView* statusInfoView = [[TCStatusInfoView alloc] init];
    statusInfoView.videoView = [[UIView alloc] initWithFrame:CGRectMake(width - VIDEO_VIEW_WIDTH - VIDEO_VIEW_MARGIN_RIGHT, height - VIDEO_VIEW_MARGIN_BOTTOM - VIDEO_VIEW_HEIGHT * index - VIDEO_VIEW_MARGIN_SPACE * (index - 1), VIDEO_VIEW_WIDTH, VIDEO_VIEW_HEIGHT)];
    statusInfoView.linkFrame = CGRectMake(width - VIDEO_VIEW_WIDTH - VIDEO_VIEW_MARGIN_RIGHT, height - VIDEO_VIEW_MARGIN_BOTTOM - VIDEO_VIEW_HEIGHT * index - VIDEO_VIEW_MARGIN_SPACE * (index - 1), VIDEO_VIEW_WIDTH, VIDEO_VIEW_HEIGHT);
    [self.view addSubview:statusInfoView.videoView];
    [_statusInfoViewArray addObject:statusInfoView];
}

- (void)onWaitLinkMicResponseTimeOut {
    if (_isWaitingResponse == YES) {
        _isWaitingResponse = NO;
        [_btnLinkMic setImage:[UIImage imageNamed:@"linkmic_on"] forState:UIControlStateNormal];
        [_btnLinkMic setEnabled:YES];
        [self hideWaitingNotice];
        [TCUtil toastTip:TRTCLocalize(@"Demo.TRTC.LiveRoom.micconnecttimeoutandanchornoresponse") parentView:self.view];
    }
}

- (void)showWaitingNotice:(NSString*)notice {
    CGRect frameRC = [[UIScreen mainScreen] bounds];
    frameRC.origin.y = frameRC.size.height - (IPHONE_X ? 114 : 80);
    frameRC.size.height -= 110;
    if (_waitingNotice == nil) {
        _waitingNotice = [[UITextView alloc] init];
        _waitingNotice.editable = NO;
        _waitingNotice.selectable = NO;
        
        frameRC.size.height = [TCUtil heightForString:_waitingNotice andWidth:frameRC.size.width];
        _waitingNotice.frame = frameRC;
        _waitingNotice.textColor = [UIColor blackColor];
        _waitingNotice.backgroundColor = [UIColor whiteColor];
        _waitingNotice.alpha = 0.5;
        
        [self.view addSubview:_waitingNotice];
    }
    
    _waitingNotice.text = notice;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 500 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^(){
        [self freshWaitingNotice:notice withIndex: [NSNumber numberWithLong:0]];
    });
}

- (void)freshWaitingNotice:(NSString *)notice withIndex:(NSNumber *)numIndex {
    if (_waitingNotice) {
        long index = [numIndex longValue];
        ++index;
        index = index % 4;
        
        NSString * text = notice;
        for (long i = 0; i < index; ++i) {
            text = [NSString stringWithFormat:@"%@.....", text];
        }
        [_waitingNotice setText:text];
        
        numIndex = [NSNumber numberWithLong:index];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 500 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^(){
            [self freshWaitingNotice:notice withIndex: numIndex];
        });
    }
}

- (void)hideWaitingNotice {
    if (_waitingNotice) {
        [_waitingNotice removeFromSuperview];
        _waitingNotice = nil;
    }
}

- (void)showAlertWithTitle:(NSString *)title sureAction:(void(^)(void))callback {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:TRTCLocalize(@"Demo.TRTC.LiveRoom.confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (callback) {
            callback();
        }
    }];
    [alertController addAction:sureAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - liveroom listener
- (void)onDebugLog:(NSString *)msg {
    NSLog(@"onDebugMsg:%@", msg);
}

- (void)onRoomDestroy:(NSString *)roomID {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"onRoomDestroy, roomID:%@", roomID);
        __weak __typeof(self) weakSelf = self;
        [self showAlertWithTitle:TRTCLocalize(@"Demo.TRTC.LiveRoom.anchorcloseinteraction") sureAction:^{
            [weakSelf closeVCWithRefresh:YES popViewController:YES];
        }];
    });
}

- (void)onError:(int)errCode errMsg:(NSString *)errMsg extraInfo:(NSDictionary *)extraInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"onError:%d, %@", errCode, errMsg);
        if(errCode != 0){
            if (self->_isInVC) {
                __weak __typeof(self) weakSelf = self;
                [self showAlertWithTitle:TRTCLocalize(@"Demo.TRTC.LiveRoom.anchorcloseinteractionroom") sureAction:^{
                    [weakSelf closeVCWithRefresh:YES popViewController:YES];
                }];
            }else{
                self->_errorCode = errCode;
                self->_errorMsg = errMsg;
            }
        }
    });
}


- (void)onKickoutJoinAnchor {
    [TCUtil toastTip:TRTCLocalize(@"Demo.TRTC.LiveRoom.sorryforkicked") parentView:self.view];
    [self stopLocalPreview];
}


#pragma mark- MiscFunc
- (TCStatusInfoView *)getStatusInfoViewFrom:(NSString *)userID {
    if (userID) {
        for (TCStatusInfoView* statusInfoView in _statusInfoViewArray) {
            if ([userID isEqualToString:statusInfoView.userID]) {
                return statusInfoView;
            }
        }
    }
    return nil;
}

- (BOOL)isNoAnchorINStatusInfoView {
    for (TCStatusInfoView* statusInfoView in _statusInfoViewArray) {
        if ([statusInfoView.userID length] > 0) {
            return NO;
        }
    }
    return YES;
}

- (void)onLiveEnd {
    [self onRecvGroupDeleteMsg];
}

- (void)onAnchorEnter:(NSString *)userID {
    BOOL noAnchor = [self isNoAnchorINStatusInfoView];
    if ([userID isEqualToString:[[ProfileManager shared] curUserID]]) {
        return;
    }
    
    if (userID == nil || userID.length == 0) {
        return;
    }
    
    BOOL bExist = NO;
    for (TCStatusInfoView * statusInfoView in _statusInfoViewArray) {
        if ([userID isEqualToString:statusInfoView.userID]) {
            bExist = YES;
            break;
        }
    }
    if (bExist == YES) {
        return;
    }
    
    for (TCStatusInfoView * statusInfoView in _statusInfoViewArray) {
        if (statusInfoView.userID == nil || statusInfoView.userID.length == 0) {
            statusInfoView.userID = userID;
            [statusInfoView startLoading];
            __weak __typeof(self) weakSelf = self;
            [self.liveRoom startPlayWithUserID:userID view:statusInfoView.videoView callback:^(int code, NSString * error) {
                if (code == 0) {
                    [statusInfoView stopLoading];
                } else {
                    [weakSelf onAnchorExit:userID];
                }
            }];
            break;
        }
    }
    
    if(noAnchor && self.roomStatus == TRTCLiveRoomLiveStatusRoomPK) {
        [self switchPKMode];
    }
        
}

- (void)onAnchorExit:(NSString *)userID {
    if ([userID isEqualToString:_liveInfo.ownerId]) {
        [self.liveRoom stopPlayWithUserID:userID callback:^(int code, NSString * error) {
            
        }];
        self.isOwnerEnter = NO;
        return;
    }
    
    TCStatusInfoView * statusInfoView = [self getStatusInfoViewFrom:userID];
    if (![statusInfoView.userID isEqualToString:[[ProfileManager shared] curUserID]]) {
        [statusInfoView stopLoading];
        [statusInfoView stopPlay];
        [self.liveRoom stopPlayWithUserID:statusInfoView.userID callback:^(int code, NSString * error) {
            
        }];
        [statusInfoView emptyPlayInfo];
    } else {
        [self stopLocalPreview];
    }
    
    if ([self isNoAnchorINStatusInfoView]) {
        [self linkFrameRestore];
    }
}

- (UIView *)findFullScreenVideoView {
    for (id view in self.view.subviews) {
        if ([view isKindOfClass:[UIView class]] && ((UIView*)view).tag == FULL_SCREEN_PLAY_VIDEO_VIEW) {
            return (UIView*)view;
        }
    }
    return nil;
}


- (void)clickBtnCamera:(UIButton *)button {
    if (_isBeingLinkMic) {
        [self.liveRoom switchCamera];
    }
}

-(void)setIsOwnerEnter:(BOOL)isOwnerEnter {
    _isOwnerEnter = isOwnerEnter;
    [_videoParentView setHidden:!isOwnerEnter];
    [_noOwnerTip setHidden:_isOwnerEnter];
}

#pragma mark RTMP LOGIC

- (BOOL)checkPlayUrl:(NSString *)playUrl {
    if (!([playUrl hasPrefix:@"http:"] || [playUrl hasPrefix:@"https:"] || [playUrl hasPrefix:@"rtmp:"] )) {
        [TCUtil toastTip:TRTCLocalize(@"Demo.TRTC.LiveRoom.addressillegalandsupportrfhm") parentView:self.view];
        return NO;
    }
    if (_isLivePlay) {
        if ([playUrl hasPrefix:@"rtmp:"]) {
            _playType = PLAY_TYPE_LIVE_RTMP;
        } else if (([playUrl hasPrefix:@"https:"] || [playUrl hasPrefix:@"http:"]) && [playUrl rangeOfString:@".flv"].length > 0) {
            _playType = PLAY_TYPE_LIVE_FLV;
        } else{
            [TCUtil toastTip:TRTCLocalize(@"Demo.TRTC.LiveRoom.addressillegalandsupportrf") parentView:self.view];
            return NO;
        }
    } else {
        if ([playUrl hasPrefix:@"https:"] || [playUrl hasPrefix:@"http:"]) {
            if ([playUrl rangeOfString:@".flv"].length > 0) {
                _playType = PLAY_TYPE_VOD_FLV;
            } else if ([playUrl rangeOfString:@".m3u8"].length > 0){
                _playType= PLAY_TYPE_VOD_HLS;
            } else if ([playUrl rangeOfString:@".mp4"].length > 0){
                _playType= PLAY_TYPE_VOD_MP4;
            } else {
                [TCUtil toastTip:TRTCLocalize(@"Demo.TRTC.LiveRoom.addressillegalandsupportfhm") parentView:self.view];
                return NO;
            }
            
        } else {
            [TCUtil toastTip:TRTCLocalize(@"Demo.TRTC.LiveRoom.addressillegalandsupportfhm") parentView:self.view];
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)startPlay {
    [self initRoomLogic];
    return YES;
}

- (BOOL)startRtmp {
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    return [self startPlay];
}

- (void)stopRtmp {
    if (!_isStop) {
        _isStop = YES;
    } else {
        return;
    }
    [self.liveRoom showVideoDebugLog:NO];
    if (self.liveRoom) {
        [self.liveRoom exitRoom:^(int code, NSString * error) {
            NSLog(@"exitRoom: errCode[%ld] errMsg[%@]", (long)code, error);
        }];
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark - TCAudienceToolbarDelegate

- (void)closeVC:(BOOL)popViewController {
    [self stopLocalPreview];
    [self stopLinkMic];
    [self closeVCWithRefresh:NO popViewController:popViewController];
    [self hideWaitingNotice];
}

- (void)clickScreen:(CGPoint)position {
    
}

- (void)clickPlayVod {
    if (!_videoFinished) {
        if (_playType == PLAY_TYPE_VOD_FLV || _playType == PLAY_TYPE_VOD_HLS || _playType == PLAY_TYPE_VOD_MP4) {
            if (_videoPause) {
                NSAssert(NO, @"");
                //                [self.liveRoom resume];
                [_logicView.playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
                [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            } else {
                NSAssert(NO, @"");
                //                [self.liveRoom pause];
                [_logicView.playBtn setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
                [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            }
            _videoPause = !_videoPause;
        }
    }
    else {
        [self startRtmp];
        [_logicView.playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
}

- (void)onSeek:(UISlider *)slider {
    //    [self.liveRoom seek:_sliderValue];
    _trackingTouchTS = [[NSDate date]timeIntervalSince1970]*1000;
    _startSeek = NO;
}

- (void)onSeekBegin:(UISlider *)slider {
    _startSeek = YES;
}

- (void)onDrag:(UISlider *)slider {
    float progress = slider.value;
    int intProgress = progress + 0.5;
    _logicView.playLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",(int)intProgress / 3600,(int)(intProgress / 60), (int)(intProgress % 60)];
    _sliderValue = slider.value;
}

- (void)clickLog {
    _log_switch = !_log_switch;
    [self.liveRoom showVideoDebugLog:_log_switch];
}

- (void)onRecvGroupDeleteMsg {
    [self closeVC:NO];
    if (!_isErrorAlert) {
        _isErrorAlert = YES;
        __weak __typeof(self) weakSelf = self;
        [self showAlertWithTitle:TRTCLocalize(@"Demo.TRTC.LiveRoom.endedinteractive") sureAction:^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }
}

- (void)closeVCWithRefresh:(BOOL)refresh popViewController: (BOOL)popViewController {
    [self stopRtmp];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (refresh) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.onPlayError) {
                self.onPlayError();
            }
        });
    }
    if (popViewController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)clickBtnLinkMic:(UIButton *)button {
    if (_isBeingLinkMic == NO) {
        //检查麦克风权限
        AVAuthorizationStatus statusAudio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (statusAudio == AVAuthorizationStatusDenied) {
            [TCUtil toastTip:TRTCLocalize(@"Demo.TRTC.LiveRoom.micauthorityfailed") parentView:self.view];
            return;
        }
        
        //是否有摄像头权限
        AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (statusVideo == AVAuthorizationStatusDenied) {
            [TCUtil toastTip:TRTCLocalize(@"Demo.TRTC.LiveRoom.cameraauthorityfailed") parentView:self.view];
            return;
        }
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
            [TCUtil toastTip:TRTCLocalize(@"Demo.TRTC.LiveRoom.notsupporthardencodeandstartmicconnectfailed") parentView:self.view];
            return;
        }
        
        [self startLinkMic];
    }
    else {
        [self stopLocalPreview];
    }
}

#pragma mark PK
- (void)switchPKMode {
    //查找存在的视频流
    for (TCStatusInfoView * statusInfoView in _statusInfoViewArray) {
        if ([statusInfoView.userID length] > 0) {
            [statusInfoView.videoView setFrame:CGRectMake(self.view.frame.size.width / 2, 0, self.view.frame.size.width / 2, self.view.frame.size.height / 2)];
            break;
        }
    }
}

- (void)linkFrameRestore {
    for (TCStatusInfoView * statusInfoView in _statusInfoViewArray) {
        if ([statusInfoView.userID length] > 0) {
            [statusInfoView.videoView setFrame:statusInfoView.linkFrame];
        }
    }
}

@end
