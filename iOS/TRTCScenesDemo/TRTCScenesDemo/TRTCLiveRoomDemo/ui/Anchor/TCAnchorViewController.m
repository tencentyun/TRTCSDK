/**
 * Module: TCAnchorViewController
 *
 * Function: 主播推流模块主控制器，里面承载了渲染view，逻辑view，以及推流相关逻辑，同时也是SDK层事件通知的接收者
 */

#import "TCAnchorViewController.h"
#import <Foundation/Foundation.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import "TCMsgModel.h"
#import "NSString+Common.h"
#import <CWStatusBarNotification/CWStatusBarNotification.h>
#import "TCStatusInfoView.h"
#import "UIView+Additions.h"
#import <TCBeautyPanel/TCBeautyPanel.h>
#import "TRTCScenesDemo-Swift.h"

#define MAX_LINKMIC_MEMBER_SUPPORT  3

#define VIDEO_VIEW_WIDTH            100
#define VIDEO_VIEW_HEIGHT           150
#define VIDEO_VIEW_MARGIN_BOTTOM    56
#define VIDEO_VIEW_MARGIN_RIGHT     8
#define VIDEO_VIEW_MARGIN_SPACE     5

@implementation TCAnchorViewController
{
    BOOL _camera_switch;
    float  _beauty_level;
    float  _whitening_level;
    float  _ruddiness_level;
    float  _eye_level;
    float  _face_level;
    TRTCLiveUserInfo *curRequest;
    
    NSString*       _testPath;
    BOOL            _isPreviewing;
    
    BOOL       _appIsInterrupt;
    BOOL       _isPKEnter;
    
    TRTCLiveRoomInfo *_liveInfo;
    
    TCAnchorToolbarView *_logicView;
    
    CWStatusBarNotification *_notification;
    
    float _bgmVolume;
    float _micVolume;
    float _bgmPosition;
    
    //link mic
    NSString*               _sessionId;
    NSString*               _userIdRequest;
    NSMutableArray*         _statusInfoViewArray;
    BOOL                    _isSupprotHardware;
    uint64_t                _beginTime;
    uint64_t                _endTime;
    NSInteger               _curBgmDuration;
    BOOL                    _isStop;
}

- (instancetype)initWithPublishInfo:(TRTCLiveRoomInfo *)liveInfo {
    if (self = [super init]) {
        _liveInfo = liveInfo;
        _liveRoom = nil;
        //link mic
        _sessionId = [self getLinkMicSessionID];
        
        _statusInfoViewArray = [NSMutableArray array];
        
        _setLinkMemeber = [NSMutableSet set];
        self.curPkRoom = nil;
        _isPKEnter = NO;
        
        _isSupprotHardware = ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0);
        
        _bgmVolume = 1.f;
        _micVolume = 1.f;
        _bgmPosition = 0.f;
        
        _camera_switch   = NO;
        _beauty_level    = 6.3;
        _whitening_level = 6.0;
        _ruddiness_level = 2.7;
        _log_switch      = NO;
        _isStop = NO;
        
        _notification = [CWStatusBarNotification new];
        _notification.notificationLabelBackgroundColor = [UIColor redColor];
        _notification.notificationLabelTextColor = [UIColor whiteColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        _bgmVolume = 1.f;
        _micVolume = 1.f;
    }
    return self;
}

- (void)dealloc {
    [self stopRtmp];
    _logicView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    NSLog(@"dealloc anchorVC");
}

- (void)onAppWillEnterForeground:(UIApplication*)app {
    [self.liveRoom.bgmManager resumeBgm];
}

- (void)onAppDidEnterBackGround:(UIApplication*)app {
    // 暂停背景音乐
    [self.liveRoom.bgmManager pauseBgm];
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
    }];
}


- (void)onAppWillResignActive:(NSNotification*)notification {
    _appIsInterrupt = YES;
}

- (void)onAppDidBecomeActive:(NSNotification*)notification {
    if (_appIsInterrupt) {
        _appIsInterrupt = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor* bgColor = [UIColor appBackGround];
    [self.view setBackgroundColor:bgColor];
    
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
    
    //视频画面的父view
    _videoParentView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_videoParentView];
    
    //link mic
    //初始化连麦播放小窗口
    [self initStatusInfoView: 1];
    [self initStatusInfoView: 2];
    [self initStatusInfoView: 3];
    
    //logicView
    _logicView = [[TCAnchorToolbarView alloc] initWithFrame:self.view.frame];
    _logicView.delegate = self;
    [_logicView setLiveRoom:_liveRoom];
    [_logicView setLiveInfo:_liveInfo];
    [self.view addSubview:_logicView];

    _logicView.vBeauty.actionPerformer = [[BeautyPerformer alloc] initWithLiveRoom:_liveRoom];
    [_logicView.vBeauty resetAndApplyValues];
    _beauty_level = _logicView.vBeauty.beautyLevel;
    _whitening_level = _logicView.vBeauty.whiteLevel;
    _ruddiness_level = _logicView.vBeauty.ruddyLevel;

    [self startRtmp];
    
    //初始化连麦播放小窗口里的踢人Button
    CGFloat width = self.view.size.width;
    CGFloat height = self.view.size.height;
    int index = 1;
    for (TCStatusInfoView* statusInfoView in _statusInfoViewArray) {
        statusInfoView.btnKickout = [[UIButton alloc] initWithFrame:CGRectMake(width - BOTTOM_BTN_ICON_WIDTH/2 - VIDEO_VIEW_MARGIN_RIGHT - 5, height - VIDEO_VIEW_MARGIN_BOTTOM - VIDEO_VIEW_HEIGHT * index + 5, BOTTOM_BTN_ICON_WIDTH/2, BOTTOM_BTN_ICON_WIDTH/2)];
        [statusInfoView.btnKickout addTarget:self action:@selector(clickBtnKickout:) forControlEvents:UIControlEventTouchUpInside];
        [statusInfoView.btnKickout setImage:[UIImage imageNamed:@"kickout"] forState:UIControlStateNormal];
        statusInfoView.btnKickout.hidden = YES;
        [self.view addSubview:statusInfoView.btnKickout];
        ++index;
    }
    
    [_logicView triggeValue];
    _curBgmDuration = 0;
    
}

- (void)initStatusInfoView: (int)index {
    CGFloat width = self.view.size.width;
    CGFloat height = self.view.size.height;
    
    TCStatusInfoView* statusInfoView = [[TCStatusInfoView alloc] init];
    statusInfoView.videoView = [[UIView alloc] initWithFrame:CGRectMake(width - VIDEO_VIEW_WIDTH - VIDEO_VIEW_MARGIN_RIGHT, height - VIDEO_VIEW_MARGIN_BOTTOM - VIDEO_VIEW_HEIGHT * index - VIDEO_VIEW_MARGIN_SPACE * (index - 1), VIDEO_VIEW_WIDTH, VIDEO_VIEW_HEIGHT)];
    statusInfoView.linkFrame = CGRectMake(width - VIDEO_VIEW_WIDTH - VIDEO_VIEW_MARGIN_RIGHT, height - VIDEO_VIEW_MARGIN_BOTTOM - VIDEO_VIEW_HEIGHT * index - VIDEO_VIEW_MARGIN_SPACE * (index - 1), VIDEO_VIEW_WIDTH, VIDEO_VIEW_HEIGHT);
    [self.view addSubview:statusInfoView.videoView];
    
    statusInfoView.pending = false;
    [_statusInfoViewArray addObject:statusInfoView];
    _beginTime = [[NSDate date] timeIntervalSince1970];
}

- (void)viewDidDisappear:(BOOL)animated {
    _endTime = [[NSDate date] timeIntervalSince1970];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)startRtmp{
    //liveRoom
    if (_liveRoom != nil) {
        __weak __typeof(self) weakSelf = self;
        [_liveRoom startCameraPreviewWithFrontCamera:YES view:_videoParentView callback:^(NSInteger code, NSString * error) {
            if (code == 0) {
                [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
                NSString *streamID = [NSString stringWithFormat:@"%@_stream",[[ProfileManager shared] curUserID]];
                [weakSelf.liveRoom startPublishWithStreamID:streamID callback:^(NSInteger code, NSString * error) {
                    NSLog(@"%ld",(long)code);
                }];
            }
        }];
        [_liveRoom setDelegate:self];
    }
}

- (void)stopRtmp {
    if (!_isStop) {
        _isStop = YES;
    } else {
        return;
    }
   _liveRoom.delegate = nil;
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   NSString *roomID = _liveInfo.roomId;
   [_liveRoom stopCameraPreview];
   [_liveRoom stopPublishWithCallback:^(NSInteger code, NSString * error) {
       
   }];
   [_liveRoom destroyRoomWithCallback:^(NSInteger code, NSString * error) {
       [[RoomManager shared] destroyRoomWithSdkAppID:SDKAPPID roomID:roomID success:^{
           
       } failed:^(int32_t code, NSString * error) {
           NSLog(@"%d,%@",code,error);
       }];
   }];
   [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)onAnchorEnter:(NSString *)userID {
    if (userID == _liveInfo.ownerId) {
        return;
    }
    
    if (userID == nil || userID.length == 0) {
        return;
    }
    BOOL isPKMode = (_curPkRoom != nil && [userID isEqualToString:_curPkRoom.ownerId]);
    if(isPKMode) {
         _isPKEnter = YES;
        [_logicView.btnPK setBackgroundImage:[UIImage imageNamed:@"pk_stop"] forState:UIControlStateNormal];
    }

    for (TCStatusInfoView * statusInfoView in _statusInfoViewArray) {
        if ([userID isEqualToString:statusInfoView.userID]) {
            if ([statusInfoView pending]) {
                statusInfoView.pending = NO;
                __weak typeof(self) weakSelf = self;
                [self.liveRoom startPlayWithUserID:userID view:statusInfoView.videoView callback:^(NSInteger code, NSString * error) {
                    if (code == 0) {
                         [statusInfoView.btnKickout setHidden:isPKMode];
                         [statusInfoView stopLoading];
                    } else {
                        if (!isPKMode) {
                            [weakSelf.liveRoom kickoutJoinAnchorWithUserID:userID callback:^(NSInteger code, NSString * error) {
                                
                            }];
                            [weakSelf onAnchorExit:userID];
                        }
                    }
                }];
            }
            break;
        }
    }
    
}

- (void)onAnchorExit: (NSString *)userID {
    if (userID == _liveInfo.ownerId) {
        return;
    }
    
    TCStatusInfoView * statusInfoView = [self getStatusInfoViewFrom:userID];
    if (statusInfoView) {
        [statusInfoView stopLoading];
        [statusInfoView stopPlay];
        [self.liveRoom stopPlayWithUserID:statusInfoView.userID callback:^(NSInteger code, NSString * error) {
            
        }];
        [statusInfoView emptyPlayInfo];
        [_setLinkMemeber removeObject:userID];
    }
    
    if (_curPkRoom != nil && [userID isEqualToString:_curPkRoom.ownerId]) {
        [self linkFrameRestore];
    }
}

#pragma mark- LinkMic Func

- (void)onRequestJoinAnchor:(TRTCLiveUserInfo *)user reason:(NSString *)reason timeout: (double)timeout {
    if ([_setLinkMemeber count] >= MAX_LINKMIC_MEMBER_SUPPORT) {
        [TCUtil toastTip:@"连麦请求拒绝，主播端连麦人数超过最大限制" parentView:self.view];
        [self.liveRoom responseJoinAnchorWithUser:user agree:NO reason:@"主播端连麦人数超过最大限制" callback:^(NSInteger code, NSString * error) {
            
        }];
    }
    else if (_userIdRequest.length > 0) {
        if (![_userIdRequest isEqualToString:user.userId]) {
            [TCUtil toastTip:@"连麦请求拒绝，主播正在处理其它人的连麦请求" parentView:self.view];
            [self.liveRoom responseJoinAnchorWithUser:user agree:NO reason:@"请稍后，主播正在处理其它人的连麦请求" callback:^(NSInteger code, NSString * error) {
                
            }];
        }
    } else if (_curPkRoom != nil) {
        [TCUtil toastTip:@"连麦请求拒绝，正在进行PK操作" parentView:self.view];
        [self.liveRoom responseJoinAnchorWithUser:user agree:NO reason:@"请稍后，主播正在进行PK" callback:^(NSInteger code, NSString * error) {
            
        }];
    }
    else {
        TCStatusInfoView * statusInfoView = [self getStatusInfoViewFrom:user.userId];
        if (statusInfoView){
            [self.liveRoom kickoutJoinAnchorWithUserID:user.userId callback:^(NSInteger code, NSString * error) {
                
            }];
            [_setLinkMemeber removeObject:statusInfoView.userID];
            [statusInfoView stopLoading];
            [statusInfoView stopPlay];
            [statusInfoView emptyPlayInfo];
        }
        _userIdRequest = user.userId;
        curRequest = user;
        UIAlertView* _alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@向您发起连麦请求", user.userName]  delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"接受", nil];
        
        [_alertView show];
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleTimeOutRequest:) object:_alertView];
        [self performSelector:@selector(handleTimeOutRequest:) withObject:_alertView afterDelay:timeout];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (_userIdRequest != nil && _userIdRequest.length > 0) {
        if (buttonIndex == 0) {
            //拒绝连麦
            [self.liveRoom responseJoinAnchorWithUser:curRequest agree:NO reason:@"主播拒绝了您的连麦请求" callback:^(NSInteger code, NSString * error) {
                
            }];
        }
        else if (buttonIndex == 1) {
            //接受连麦
            [self.liveRoom responseJoinAnchorWithUser:curRequest agree:YES reason:@"" callback:^(NSInteger code, NSString * error) {
                
            }];
            //查找空闲的TCLinkMicSmallPlayer, 开始loading
            for (TCStatusInfoView * statusInfoView in _statusInfoViewArray) {
                if (statusInfoView.userID == nil || statusInfoView.userID.length == 0) {
                    statusInfoView.pending = YES;
                    statusInfoView.userID = _userIdRequest;
                    [statusInfoView startLoading];
                    break;
                }
            }
            
            //设置超时逻辑
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onLinkMicTimeOut:) object:_userIdRequest];
            [self performSelector:@selector(onLinkMicTimeOut:) withObject:_userIdRequest afterDelay:3];
            
            //加入连麦成员列表
            [_setLinkMemeber addObject:_userIdRequest];
        }
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleTimeOutRequest:) object:alertView];
    _userIdRequest = @"";
}

- (void)onLinkMicTimeOut:(NSString*)userID {
    if (userID) {
        TCStatusInfoView* statusInfoView = [self getStatusInfoViewFrom:userID];
        if (statusInfoView && statusInfoView.pending == YES){
            [self.liveRoom kickoutJoinAnchorWithUserID:statusInfoView.userID callback:^(NSInteger code, NSString * error) {
                
            }];
            [_setLinkMemeber removeObject:userID];
            [statusInfoView stopPlay];
            [statusInfoView emptyPlayInfo];
            [TCUtil toastTip: [NSString stringWithFormat: @"%@连麦超时", userID] parentView:self.view];
        }
    }
}

- (void)handleTimeOutRequest:(UIAlertView*)alertView {
    _userIdRequest = @"";
    if (alertView) {
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
    }
    [TCUtil toastTip: @"处理连麦请求超时" parentView:self.view];
}

- (NSString*) getLinkMicSessionID {
    //说明：
    //1.sessionID是混流依据，sessionID相同的流，后台混流Server会混为一路视频流；因此，sessionID必须全局唯一
    
    //2.直播码频道ID理论上是全局唯一的，使用直播码作为sessionID是最为合适的
    //NSString* strSessionID = [TCLinkMicModel getStreamIDByStreamUrl:self.rtmpUrl];
    
    //3.直播码是字符串，混流Server目前只支持64位数字表示的sessionID，暂时按照下面这种方式生成sessionID
    //  待混流Server改造完成后，再使用直播码作为sessionID
    
    UInt64 timeStamp = [[NSDate date] timeIntervalSince1970] * 1000;
    
    UInt64 sessionID = ((UInt64)3891 << 48 | timeStamp); // 3891是bizid, timeStamp是当前毫秒值
    
    return [NSString stringWithFormat:@"%llu", sessionID];
}

- (TCStatusInfoView *)getStatusInfoViewFrom:(NSString*)userID {
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

- (void)clickBtnKickout:(UIButton *)btn {
    for (TCStatusInfoView* statusInfoView in _statusInfoViewArray) {
        if (statusInfoView.btnKickout == btn) {
            [self.liveRoom stopPlayWithUserID:statusInfoView.userID callback:^(NSInteger code, NSString * error) {
                
            }];
            [self.liveRoom kickoutJoinAnchorWithUserID:statusInfoView.userID callback:^(NSInteger code, NSString * error) {
                
            }];
            [_setLinkMemeber removeObject:statusInfoView.userID];
            [statusInfoView stopLoading];
            [statusInfoView stopPlay];
            [statusInfoView emptyPlayInfo];
            [_setLinkMemeber removeObject:statusInfoView.userID];
            break;
        }
    }
}

#pragma mark - PK
- (void)onRequestRoomPK:(TRTCLiveUserInfo *)user timeout: (double)timeout {
    self.curPkRoom = [[TRTCLiveRoomInfo alloc] init];
    self.curPkRoom.ownerId = user.userId;
    self.curPkRoom.ownerName = user.userName;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@发起了PK请求",user.userName] message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    __weak __typeof(self) weakSelf = self;
    UIAlertAction *reject = [UIAlertAction actionWithTitle:@"拒绝" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf linkFrameRestore];
        [weakSelf.liveRoom responseRoomPKWithUser:user agree:NO reason:@"主播拒绝" callback:^(NSInteger code, NSString * error) {
            
        }];
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"接受" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.liveRoom responseRoomPKWithUser:user agree:YES reason:@"" callback:^(NSInteger code, NSString * error) {
        }];
    }];
    [alert addAction:reject];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    [self performSelector:@selector(PKAlertCheck:) withObject:alert afterDelay:timeout];
}

- (void)PKAlertCheck: (UIAlertController*)alert {
    if (alert.presentingViewController == self.navigationController) {
        [TCUtil toastTip: [NSString stringWithFormat: @"处理%@PK超时", _curPkRoom.ownerName] parentView:self.view];
        [alert dismissViewControllerAnimated:YES completion:nil];
        [self linkFrameRestore];
    }
}

- (void)QuitPK {
    [self.liveRoom quitRoomPKWithCallback:^(NSInteger code, NSString * error) {
        
    }];
    [UIView animateWithDuration:0.1 animations:^{
        [self onAnchorExit:self->_curPkRoom.ownerId];
    }];
}

- (void)setCurPkRoom:(TRTCLiveRoomInfo *)curPkRoom {
    _curPkRoom = curPkRoom;
    if (_curPkRoom == nil) {
        _isPKEnter = NO;
        [_logicView.btnPK setBackgroundImage:[UIImage imageNamed:@"pk_start"] forState:UIControlStateNormal];
    }
}

#pragma mark -  TCAnchorToolbarDelegate

- (void)closeRTMP {
    for (TCStatusInfoView* statusInfoView in _statusInfoViewArray) {
        [statusInfoView stopPlay];
    }
    if (_curPkRoom != nil) {
        [self QuitPK];
    }
    [self stopRtmp];
}

- (void)closeVC {
    [self.liveRoom showVideoDebugLog:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickScreen:(UITapGestureRecognizer *)gestureRecognizer {
    _logicView.vBeauty.hidden = YES;
    [_logicView setButtonHidden:NO];
    _logicView.vMusicPanel.hidden = YES;
    _logicView.vPKPanel.hidden = YES;
    
    //手动聚焦
//    CGPoint touchLocation = [gestureRecognizer locationInView:_videoParentView];
}

- (void)clickCamera:(UIButton *)button {
    _camera_switch = !_camera_switch;
    [self.liveRoom switchCamera];
}

- (void)clickBeauty:(UIButton *)button {
    _logicView.vBeauty.hidden = NO;
    [_logicView setButtonHidden:YES];
}

- (void)clickMusic:(UIButton *)button {
    _logicView.vMusicPanel.hidden = NO;
}

- (void)clickPK:(UIButton *)button {
    if (_isPKEnter) {
        [self QuitPK];
    } else {
        _logicView.vPKPanel.hidden = NO;
        [_logicView.vPKPanel loadRoomsInfo];
    }
}

- (void)pkWithRoom:(TRTCLiveRoomInfo*)room {
    if (_setLinkMemeber.count > 0) {
        [TCUtil toastTip:@"正在连麦中，请稍候尝试PK操作" parentView:self.view];
        return;
    }
    
    __weak __typeof(self) weakSelf = self;

    [_liveRoom requestRoomPKWithRoomID:[room.roomId intValue] userID:room.ownerId responseCallback:^(BOOL accept, NSString * error) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (self == nil) {
            return ;
        }
        if (accept) {
            [TCUtil toastTip:[NSString stringWithFormat:@"%@已接受您的PK请求",room.ownerName] parentView:self.view];
        } else {
            [TCUtil toastTip:[NSString stringWithFormat:@"%@拒绝了您的PK请求",room.ownerName] parentView:self.view];
            self.curPkRoom = nil;
        }
    } callback:^(NSInteger code, NSString * error) {
        if (code != 0) {
            if (error.length > 0) {
               [TCUtil toastTip:error parentView:self.view];
            } else {
                [TCUtil toastTip:@"出现错误，请稍候尝试" parentView:self.view];
            }
            if (self.roomType != TRTCLiveRoomLiveTypeRoomPK) {
                self.curPkRoom = nil;
            }
        } else {
            
        }
    }];
    
    if (_roomType != TRTCLiveRoomLiveTypeRoomPK) {
        self.curPkRoom = room;
    }
}

- (void)clickLog {
    _log_switch = !_log_switch;
    [self.liveRoom showVideoDebugLog:_log_switch];
}

- (void)clickMusicSelect:(UIButton *)button {
    //创建播放器控制器
    MPMediaPickerController *mpc = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
     __weak __typeof(self) weakSelf = self;
    mpc.delegate = weakSelf;
    mpc.editing = YES;
    mpc.showsCloudItems = NO;
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    [self presentViewController:mpc animated:YES completion:nil];
}

- (void)clickMusicClose:(UIButton *)button {
    _logicView.vMusicPanel.hidden = YES;
    [self.liveRoom.bgmManager stopBgm];
    _curBgmDuration = 0;
}

- (void)clickVolumeSwitch:(UIButton *)button {
    // todo
}

- (void)sliderValueChange:(UISlider *)obj {
    if (obj.tag == 0) { //美颜
        _beauty_level = obj.value;
    } else if (obj.tag == 1) { //美白
        _whitening_level = obj.value;
    } else if (obj.tag == 2) { //大眼
        _eye_level = obj.value;
    } else if (obj.tag == 3) { //瘦脸
        _face_level = obj.value;
    } else if (obj.tag == 4) {// 背景音乐音量
        _bgmVolume = obj.value/obj.maximumValue;
        if (_curBgmDuration != 0) {
            [self.liveRoom.bgmManager setBGMVolumeWithVolume:(_bgmVolume * 100)];
        }
    } else if (obj.tag == 5) { // 麦克风音量
        _micVolume = obj.value/obj.maximumValue;
        [self.liveRoom.bgmManager setAudioCaptureVolumeWithVolume:(_micVolume * 100)];
    } else if (obj.tag == 6) { // bgm seek
        _bgmPosition = obj.value/obj.maximumValue;
        if (_curBgmDuration != 0) {
            if ([self.liveRoom.bgmManager setBGMPositionWithPos:_curBgmDuration * _bgmPosition] != 0) {
                NSLog(@"error");
            }
        }
    }
}

- (void)sliderValueChangeEx:(UISlider*)obj {
    // todo
}

- (void)selectEffect:(NSInteger)index {
    [self.liveRoom.bgmManager setReverbTypeWithReverbType:index];
}

- (void)selectEffect2:(NSInteger)index {
    [self.liveRoom.bgmManager setVoiceChangerTypeWithVoiceChangerType:index];
}


#pragma mark - BGM
//选中后调用
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection{
    NSArray *items = mediaItemCollection.items;
    MPMediaItem *item = [items objectAtIndex:0];
    
    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    NSLog(@"MPMediaItemPropertyAssetURL = %@", url);
    
    if (mediaPicker.editing) {
        mediaPicker.editing = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.liveRoom.bgmManager stopBgm];
            [self saveAssetURLToFile: url];
        });
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//点击取消时回调
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 将AssetURL(音乐)导出到app的文件夹并播放
- (void)saveAssetURLToFile:(NSURL *)assetURL {
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:songAsset presetName:AVAssetExportPresetAppleM4A];
    NSLog (@"created exporter. supportedFileTypes: %@", exporter.supportedFileTypes);
    exporter.outputFileType = @"com.apple.m4a-audio";
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *exportFile = [docDir stringByAppendingPathComponent:@"exported.m4a"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportFile]) {
        [[NSFileManager defaultManager] removeItemAtPath:exportFile error:nil];
    }
    exporter.outputURL = [NSURL fileURLWithPath:exportFile];
    
    __weak __typeof(self) weakSelf = self;
    // do the export
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        int exportStatus = exporter.status;
        switch (exportStatus) {
            case AVAssetExportSessionStatusFailed: {
                NSLog (@"AVAssetExportSessionStatusFailed: %@", exporter.error);
                break;
            }
            case AVAssetExportSessionStatusCompleted: {
                NSLog(@"AVAssetExportSessionStatusCompleted: %@", exporter.outputURL);
                
                // 播放背景音乐
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong __typeof(weakSelf) self = weakSelf;
                    if (self == nil) {
                        return;
                    }
                    [self.liveRoom.bgmManager playBgm:exportFile progress:^(NSInteger progressMs, NSInteger duration) {
                        __strong __typeof(weakSelf) self = weakSelf;
                        if (self == nil) {
                            return;
                        }
                        self->_curBgmDuration = duration;
                    } completion:^(NSInteger code, NSString * message) {
                        __strong __typeof(weakSelf) self = weakSelf;
                                           if (self == nil) {
                                               return;
                                           }
                        self->_curBgmDuration = 0;
                    }];
                    [self.liveRoom.bgmManager setBGMVolumeWithVolume:(self->_bgmVolume * 100)];
                    [self.liveRoom.bgmManager setAudioCaptureVolumeWithVolume:(self->_micVolume * 100)];
                });
                break;
            }
            case AVAssetExportSessionStatusUnknown: { NSLog (@"AVAssetExportSessionStatusUnknown"); break;}
            case AVAssetExportSessionStatusExporting: { NSLog (@"AVAssetExportSessionStatusExporting"); break;}
            case AVAssetExportSessionStatusCancelled: { NSLog (@"AVAssetExportSessionStatusCancelled"); break;}
            case AVAssetExportSessionStatusWaiting: { NSLog (@"AVAssetExportSessionStatusWaiting"); break;}
            default: { NSLog (@"didn't get export status"); break;}
        }
    }];
}

#pragma mark PK
- (void) linkFrameRestore {
    for (TCStatusInfoView * statusInfoView in _statusInfoViewArray) {
        if ([statusInfoView.userID length] > 0) {
            [statusInfoView.videoView setFrame:statusInfoView.linkFrame];
        }
    }
    [self.liveRoom stopPlayWithUserID:_curPkRoom.ownerId callback:^(NSInteger code, NSString * error) {
        
    }];
    self.curPkRoom = nil;
}

- (void)switchPKMode {
    TCStatusInfoView *info = [self getStatusInfoViewFrom:_curPkRoom.ownerId];
    if (info == nil) {
        //查找存在的视频流
        for (TCStatusInfoView * statusInfoView in _statusInfoViewArray) {
            if (statusInfoView.userID == nil || [statusInfoView.userID length] == 0) {
                [statusInfoView.videoView setFrame:CGRectMake(self.view.frame.size.width / 2, 0, self.view.frame.size.width / 2, self.view.frame.size.height / 2)];
                statusInfoView.pending = YES;
                statusInfoView.userID = _curPkRoom.ownerId;
                [statusInfoView startLoading];
                break;
            }
        }
    } else {
        [info.videoView setFrame:CGRectMake(self.view.frame.size.width / 2, 0, self.view.frame.size.width / 2, self.view.frame.size.height / 2)];
    }
    
}

@end

