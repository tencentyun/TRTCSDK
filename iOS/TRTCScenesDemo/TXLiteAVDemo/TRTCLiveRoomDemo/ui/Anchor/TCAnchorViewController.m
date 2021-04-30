/**
 * Module: TCAnchorViewController
 *
 * Function: 主播推流模块主控制器，里面承载了渲染view，逻辑view，以及推流相关逻辑，同时也是SDK层事件通知的接收者
 */

#import "TCAnchorViewController.h"
#import <Foundation/Foundation.h>
#import <Masonry.h>
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
#import "TXLiteAVDemo-Swift.h"
#import "UIColor+HexColor.h"

#define MAX_LINKMIC_MEMBER_SUPPORT  3

#define VIDEO_VIEW_WIDTH            100
#define VIDEO_VIEW_HEIGHT           150
#define VIDEO_VIEW_MARGIN_BOTTOM    56
#define VIDEO_VIEW_MARGIN_RIGHT     8
#define VIDEO_VIEW_MARGIN_SPACE     5

#define AUDIO_QUALITY_SELECTED_COLOR [UIColor hexColor:@"29CC85"]
#define AUDIO_QUALITY_DEFAULT_COLOR  [UIColor hexColor:@"F4F5F9"]

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
    
    BOOL       _appIsInterrupt;
    BOOL       _isPKEnter;
    
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
    UIButton*               _publishBtn;
    UIButton*               _cameraBtn;
    UIButton*               _beautyBtn;
    UIButton*               _closeBtn;
    
    UIButton*               _musicQualityButton;
    UIButton*               _standardQualityButton;
    
    //创建房间
    UIView*                 _createTopPanel;
    UIImageView*            _userAvatar;
    UILabel*                _userName;
    UITextField*            _roomName;
    // 定时器
    dispatch_source_t       _timer;
    TRTCLiveRoomSoundEffectViewModel *_effectViewModel;
}

- (instancetype) init {
    if (self = [super init]) {
        _liveRoom = nil;
        _liveInfo = [[TRTCLiveRoomInfo alloc] init];
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

- (void)setLiveInfo:(TRTCLiveRoomInfo *)liveInfo {
    _liveInfo = liveInfo;
    [_logicView setLiveInfo:_liveInfo];
}

- (void)setPreviewUIHidden:(BOOL)hide {
    [_publishBtn setHidden:hide];
    [_cameraBtn setHidden:hide];
    [_beautyBtn setHidden:hide];
    [_closeBtn setHidden:hide];
    [_createTopPanel setHidden:hide];
}

- (void)dealloc {
    [self stopRtmp];
    _logicView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [TRTCCloud destroySharedIntance]; // 直播结束的时候销毁实例
    NSLog(@"dealloc anchorVC");
}

- (void)onAppWillEnterForeground:(UIApplication*)app {
//    [[self.liveRoom getAudioEffectManager] stopPlayMusic:];
}

- (void)onAppDidEnterBackGround:(UIApplication*)app {
    // 暂停背景音乐
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
    }];
}


- (void)onAppWillResignActive:(NSNotification*)notification {
    if (!_appIsInterrupt) {
        if (self->_timer) {
            dispatch_suspend(self->_timer);
        }
        _appIsInterrupt = YES;
    }
}

- (void)onAppDidBecomeActive:(NSNotification*)notification {
    if (_appIsInterrupt) {
        if (self->_timer) {
            dispatch_resume(self->_timer);
        }
        _appIsInterrupt = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupToast];
    
    //加载背景图
    NSArray *colors = [NSArray arrayWithObjects:
                       (__bridge id)[UIColor colorWithRed:19.0 / 255.0 green:41.0 / 255.0 blue:75.0 / 255.0 alpha:1].CGColor,
                       (__bridge id)[UIColor colorWithRed:5.0 / 255.0 green:12.0 / 255.0 blue:23.0 / 255.0 alpha:1].CGColor, nil];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = colors;
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    gradientLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:gradientLayer atIndex:0];
    
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
    [self.view addSubview:_logicView];

    _logicView.vBeauty.actionPerformer = [[BeautyPerformer alloc] initWithLiveRoom:_liveRoom];
    [_logicView.vBeauty resetAndApplyValues];
    _beauty_level = _logicView.vBeauty.beautyLevel;
    _whitening_level = _logicView.vBeauty.whiteLevel;
    _ruddiness_level = _logicView.vBeauty.ruddyLevel;

    //初始化连麦播放小窗口里的踢人Button
    CGFloat width = self.view.size.width;
    CGFloat height = self.view.size.height;
    int index = 1;
    for (TCStatusInfoView* statusInfoView in _statusInfoViewArray) {
        statusInfoView.btnKickout = [[UIButton alloc] initWithFrame:CGRectMake(width - BOTTOM_BTN_ICON_WIDTH/2 - VIDEO_VIEW_MARGIN_RIGHT - 5, height - VIDEO_VIEW_MARGIN_BOTTOM - VIDEO_VIEW_HEIGHT * index + 5, BOTTOM_BTN_ICON_WIDTH/2, BOTTOM_BTN_ICON_WIDTH/2)];
        [statusInfoView.btnKickout addTarget:self action:@selector(clickBtnKickout:) forControlEvents:UIControlEventTouchUpInside];
        [statusInfoView.btnKickout setImage:[UIImage imageNamed:@"kickout"] forState:UIControlStateNormal];
        statusInfoView.btnKickout.hidden = YES;
        [self->_logicView insertSubview:statusInfoView.btnKickout belowSubview:self->_logicView.vMusicPanel];
        ++index;
    }
    
    [self startPreview];
    
    [_logicView triggeValue];
    _curBgmDuration = 0;
    
    [self initRoomPreview];
#ifdef TRTC_APPSTORE
    [self makeToastWithMessage:TRTCLocalize(@"Demo.TRTC.LiveRoom.alerttoexperienceandshowlongestduration") duration:5];
#endif
}

//预览相关视图
- (void)initRoomPreview {
    //开始推送
    _publishBtn = [[UIButton alloc] init];
    [_publishBtn setBackgroundColor:[UIColor appTint]];
    [[_publishBtn layer] setCornerRadius:25];
    [_publishBtn setTitle:TRTCLocalize(@"Demo.TRTC.LiveRoom.start") forState:UIControlStateNormal];
    [[_publishBtn titleLabel] setFont:[UIFont systemFontOfSize:22]];
    [self.view addSubview:_publishBtn];
    [_publishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@(-(IPHONE_X ? 66 : 34)));
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(160);
    }];
    [_publishBtn addTarget:self action:@selector(startPublish) forControlEvents:UIControlEventTouchUpInside];
    
    //前置后置摄像头切换
    _cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cameraBtn setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [self.view addSubview:_cameraBtn];
    [_cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_publishBtn);
        make.centerX.equalTo(self.view).multipliedBy(0.5).offset(-40);
        make.height.width.mas_equalTo(BOTTOM_BTN_ICON_WIDTH);
    }];
    [_cameraBtn addTarget:self action:@selector(clickCamera:) forControlEvents:UIControlEventTouchUpInside];
    
    //美颜开关按钮
    _beautyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_beautyBtn setImage:[UIImage imageNamed:@"meeting_beauty"] forState:UIControlStateNormal];
    [self.view addSubview:_beautyBtn];
    [_beautyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_publishBtn);
        make.centerX.equalTo(self.view).multipliedBy(1.5).offset(40);
        make.height.width.mas_equalTo(BOTTOM_BTN_ICON_WIDTH);
    }];
    [_beautyBtn addTarget:self action:@selector(clickBeauty:) forControlEvents:UIControlEventTouchUpInside];
    
    //退出VC
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [self.view addSubview:_closeBtn];
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(SafeAreaTopHeight + 20);
        make.trailing.mas_equalTo(-20);
        make.height.width.mas_equalTo(BOTTOM_BTN_ICON_WIDTH);
    }];
    [_closeBtn addTarget:self action:@selector(taggleCloseVC) forControlEvents:UIControlEventTouchUpInside];
    
    _createTopPanel = [[UIView alloc] init];
    [_createTopPanel setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.4]];
    [[_createTopPanel layer] setCornerRadius:6];
    [self.view addSubview:_createTopPanel];
    [_createTopPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(20);
        make.trailing.equalTo(self.view).offset(-20);
        make.top.mas_equalTo(110);
    }];

    _userAvatar = [[UIImageView alloc] init];
    [_createTopPanel addSubview:_userAvatar];
    [[_userAvatar layer] setMasksToBounds:YES];
    [[_userAvatar layer] setCornerRadius:10];
    [_userAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(70);
        make.leading.mas_equalTo(12);
        make.top.mas_equalTo(10);
    }];
    [_userAvatar sd_setImageWithURL:[NSURL URLWithString:[ProfileManager shared].curUserModel.avatar]];
    
    _userName = [[UILabel alloc] init];
    [_userName setBackgroundColor:[UIColor clearColor]];
    [_userName setTextColor:[UIColor whiteColor]];
    [_userName setFont:[UIFont boldSystemFontOfSize:18]];
    [_userName setText:[ProfileManager shared].curUserModel.name];
    [_createTopPanel addSubview:_userName];
    [_userName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.leading.equalTo(_userAvatar.mas_trailing).offset(8);
        make.trailing.mas_equalTo(-12);
        make.top.mas_equalTo(_userAvatar).offset(8);
    }];
    
    _roomName = [[UITextField alloc] init];
    [_roomName setBackgroundColor:[UIColor clearColor]];
    [_roomName setTextColor:[UIColor whiteColor]];
    [_roomName setReturnKeyType:UIReturnKeyDone];
    [_roomName setFont:[UIFont boldSystemFontOfSize:22]];
    [_roomName setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:TRTCLocalize(@"Demo.TRTC.LiveRoom.titlefuncanattractpopularity") attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.8 alpha:1]}]];
    NSString *userName = [ProfileManager shared].curUserModel.name;
    if (!userName) {
        userName = @"";
    }
    NSString *defaultName = LocalizeReplaceXX(TRTCLocalize(@"Demo.TRTC.VoiceRoom.xxxsroom"), userName);
    if (defaultName.length > 15) {
        defaultName = [defaultName substringToIndex:15];
    }
    _roomName.text = defaultName;
    [_createTopPanel addSubview:_roomName];
    [_roomName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(32);
        make.leading.equalTo(_userAvatar.mas_trailing).offset(8);
        make.trailing.mas_equalTo(-12);
        make.top.mas_equalTo(_userName.mas_bottom).offset(4);
    }];
    [_roomName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _roomName.delegate = self;
    
    UILabel *audioQualityLabel = [[UILabel alloc] init];
    audioQualityLabel.text = TRTCLocalize(@"Demo.TRTC.LiveRoom.soundquality");
    audioQualityLabel.font = [UIFont systemFontOfSize:16];
    audioQualityLabel.textColor = [UIColor whiteColor];
    audioQualityLabel.textAlignment = NSTextAlignmentCenter;
    [_createTopPanel addSubview:audioQualityLabel];
    [audioQualityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_userAvatar);
        make.top.equalTo(_userAvatar.mas_bottom).offset(6);
        make.bottom.equalTo(_createTopPanel).offset(-20);
    }];
    
    _standardQualityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_standardQualityButton setBackgroundColor:AUDIO_QUALITY_DEFAULT_COLOR];
    [_standardQualityButton setTitle:TRTCLocalize(@"Demo.TRTC.LiveRoom.standard") forState:UIControlStateNormal];
    [_standardQualityButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_standardQualityButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    _standardQualityButton.titleLabel.font = [UIFont systemFontOfSize:15];
    _standardQualityButton.layer.cornerRadius = 16;
    [_standardQualityButton addTarget:self
                               action:@selector(onAudioQualityButtonClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
    [_createTopPanel addSubview:_standardQualityButton];
    [_standardQualityButton sizeToFit];
    CGFloat width = _standardQualityButton.width;
    [_standardQualityButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(32);
        make.left.equalTo(audioQualityLabel.mas_right).offset(20);
        make.centerY.equalTo(audioQualityLabel);
        make.width.mas_equalTo(16+width);
    }];
    
    _musicQualityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_musicQualityButton setBackgroundColor:AUDIO_QUALITY_SELECTED_COLOR];
    [_musicQualityButton setTitle:TRTCLocalize(@"Demo.TRTC.LiveRoom.music") forState:UIControlStateNormal];
    _musicQualityButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_musicQualityButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_musicQualityButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    _musicQualityButton.layer.cornerRadius = 16;
    [_musicQualityButton addTarget:self
                            action:@selector(onAudioQualityButtonClicked:)
                  forControlEvents:UIControlEventTouchUpInside];
    _musicQualityButton.selected = YES;
    [_createTopPanel addSubview:_musicQualityButton];
    [_musicQualityButton sizeToFit];
    width = _musicQualityButton.width;
    [_musicQualityButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(32);
        make.left.equalTo(_standardQualityButton.mas_right).offset(20);
        make.centerY.equalTo(audioQualityLabel);
        make.width.mas_equalTo(16+width);
    }];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_logicView.isPreview) {
        if (![_roomName isFirstResponder]) {
           [_roomName becomeFirstResponder];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    _endTime = [[NSDate date] timeIntervalSince1970];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)startPreview{
    [[AppUtils shared] alertUserTips:self];
    
    //liveRoom
    if (_liveRoom != nil) {
        [_liveRoom startCameraPreviewWithFrontCamera:YES view:_videoParentView callback:^(int code, NSString * error) {
            if (code == 0) {
                [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            }
        }];
        [_liveRoom setDelegate:self];
    }
}

- (void)startPublish {
    if ([_roomName isFirstResponder]) {
        [_roomName resignFirstResponder];
    }
    if (_roomName.text.length <= 0) {
        [self makeToastWithMessage:TRTCLocalize(@"Demo.TRTC.LiveRoom.roomnamecantbeempty")];
        return;
    }
#ifdef TRTC_APPSTORE
    [self createTimer];
#endif
    __weak __typeof(self) weakSelf = self;
    __weak UIButton *weakStandardQualityButton = _standardQualityButton;
    [self _startPublishWithSdkAppID:SDKAPPID roomName:_roomName.text roomID:[self generateRoomID]  callback:^(NSInteger code, NSString * error) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (self == nil) {
            return ;
        }
        if (code == 0) {
            [self setPreviewUIHidden:YES];
            NSString *streamID = [NSString stringWithFormat:@"%@_stream",[[ProfileManager shared] curUserID]];
            if (weakStandardQualityButton.selected) {
                [self.liveRoom setAudioQuality:2];
            } else {
                [self.liveRoom setAudioQuality:3];
            }
            [self.liveRoom startPublishWithStreamID:streamID callback:^(int code, NSString * error) {
                NSLog(@"%ld",(long)code);
            }];
        } else {
            [self makeToastWithMessage:error.length > 0 ? error : TRTCLocalize(@"Demo.TRTC.LiveRoom.createroomfailed")];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self stopRtmp];
                [self closeVC];
            });
        }
    }];
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
   [_liveRoom stopPublish:^(int code, NSString * error) {
       
   }];
   [_liveRoom destroyRoom:^(int code, NSString * error) {
       [[RoomManager shared] destroyRoomWithSdkAppID:SDKAPPID roomID:roomID success:^{
           
       } failed:^(int32_t code, NSString * error) {
           NSLog(@"%d,%@",code,error);
       }];
   }];
    [self.liveRoom showVideoDebugLog:NO];
    [_logicView.vBeauty resetAndApplyValues];
   [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark - 定时器 (GCD)
- (void)createTimer {
#ifdef TRTC_APPSTORE
    //设置倒计时时间
    //通过检验发现，方法调用后，timeout会先自动-1，所以如果从15秒开始倒计时timeout应该写16
    __block int timeout = 1;
   
    //获取全局队列
    dispatch_queue_t global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //创建一个定时器，并将定时器的任务交给全局队列执行(并行，不会造成主线程阻塞)
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, global);
    
    // 设置触发的间隔时间
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 600 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    //600 * NSEC_PER_SEC  代表设置定时器触发的时间间隔为10miin
    //0 * NSEC_PER_SEC    代表时间允许的误差是 0s
    __weak __typeof(self)weakSelf = self;
    //设置定时器的触发事件
    dispatch_source_set_event_handler(_timer, ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (timeout <= 0) {
            dispatch_source_cancel(strongSelf->_timer);
            strongSelf->_timer = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.logicView.topView pauseLive];
                [strongSelf stopRtmp];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:TRTCLocalize(@"Demo.TRTC.LiveRoom.alerttoexperienceandupperlimit") message:nil preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:TRTCLocalize(@"Demo.TRTC.LiveRoom.confirm") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                    //添加PK view
                    [strongSelf closeVC];
                }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
        timeout -= 1;
    });
    dispatch_resume(self->_timer);
#endif
}

- (void)onAnchorEnter:(NSString *)userID {
    if ([userID isEqualToString:_liveInfo.ownerId]) {
        return;
    }
    if (userID == nil || userID.length == 0) {
        return;
    }
    BOOL isPKMode = (_curPkRoom != nil && [userID isEqualToString:_curPkRoom.ownerId]);
    if(isPKMode) {
         _isPKEnter = YES;
        [_logicView.btnPK setImage:[UIImage imageNamed:@"live_pk_start"] forState:UIControlStateNormal];
    }
    for (TCStatusInfoView * statusInfoView in _statusInfoViewArray) {
        if ([userID isEqualToString:statusInfoView.userID]) {
            if ([statusInfoView pending]) {
                statusInfoView.pending = NO;
                __weak __typeof(self) weakSelf = self;
                [self.liveRoom startPlayWithUserID:userID view:statusInfoView.videoView callback:^(int code, NSString * error) {
                    [statusInfoView stopLoading];
                    if (code == 0) {
                         [statusInfoView.btnKickout setHidden:isPKMode];
                    } else {
                        if (!isPKMode) {
                            [weakSelf.liveRoom kickoutJoinAnchor:userID callback:^(int code, NSString * error) {
                                
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
    //将PK按钮还原
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangePKToStopNotificationKey" object:nil];
    
    TCStatusInfoView * statusInfoView = [self getStatusInfoViewFrom:userID];
    if (statusInfoView) {
        [statusInfoView stopLoading];
        [statusInfoView stopPlay];
        [self.liveRoom stopPlayWithUserID:statusInfoView.userID callback:^(int code, NSString * error) {
            
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
        [TCUtil toastTip:TRTCLocalize(@"Demo.TRTC.LiveRoom.micconnectionrefusedandanchorpeopleexceedsmaxlimit") parentView:self.view];
        [self.liveRoom responseJoinAnchor:user.userId agree:NO reason:TRTCLocalize(@"Demo.TRTC.LiveRoom.anchorpeopleexceedsmaxlimit")];
    }
    else if (_userIdRequest.length > 0) {
        if (![_userIdRequest isEqualToString:user.userId]) {
            [TCUtil toastTip:TRTCLocalize(@"Demo.TRTC.LiveRoom.micconnectionrefusedandanchordealotherreq") parentView:self.view];
            [self.liveRoom responseJoinAnchor:user.userId agree:NO reason:TRTCLocalize(@"Demo.TRTC.LiveRoom.waitforhandleotherreq")];
        }
    } else if (_curPkRoom != nil) {
        [TCUtil toastTip:TRTCLocalize(@"Demo.TRTC.LiveRoom.micconnectionrefusedandinpk") parentView:self.view];
        [self.liveRoom responseJoinAnchor:user.userId agree:NO reason:TRTCLocalize(@"Demo.TRTC.LiveRoom.micconnectionrefusedandinpk")];
    }
    else {
        TCStatusInfoView * statusInfoView = [self getStatusInfoViewFrom:user.userId];
        if (statusInfoView){
            [self.liveRoom kickoutJoinAnchor:user.userId callback:^(int code, NSString * error) {
                
            }];
            [_setLinkMemeber removeObject:statusInfoView.userID];
            [statusInfoView stopLoading];
            [statusInfoView stopPlay];
            [statusInfoView emptyPlayInfo];
        }
        _userIdRequest = user.userId;
        curRequest = user;
        UIAlertView* _alertView = [[UIAlertView alloc] initWithTitle:TRTCLocalize(@"Demo.TRTC.LiveRoom.prompt") message:LocalizeReplaceXX(TRTCLocalize(@"Demo.TRTC.LiveRoom.xxinitiateamicconnectionreq"), user.userName)  delegate:self cancelButtonTitle:TRTCLocalize(@"Demo.TRTC.LiveRoom.refuse") otherButtonTitles:TRTCLocalize(@"Demo.TRTC.LiveRoom.accept"), nil];
        
        [_alertView show];
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleTimeOutRequest:) object:_alertView];
        [self performSelector:@selector(handleTimeOutRequest:) withObject:_alertView afterDelay:timeout];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (_userIdRequest != nil && _userIdRequest.length > 0) {
        if (buttonIndex == 0) {
            //拒绝连麦
            [self.liveRoom responseJoinAnchor:curRequest.userId agree:NO reason:TRTCLocalize(@"Demo.TRTC.LiveRoom.refusemicconnectionreq")];
        }
        else if (buttonIndex == 1) {
            //接受连麦
            [self.liveRoom responseJoinAnchor:curRequest.userId agree:YES reason:@""];
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
            [self.liveRoom kickoutJoinAnchor:statusInfoView.userID callback:^(int code, NSString * error) {
                
            }];
            [_setLinkMemeber removeObject:userID];
            [statusInfoView stopPlay];
            [statusInfoView emptyPlayInfo];
            [TCUtil toastTip:LocalizeReplaceXX(TRTCLocalize(@"Demo.TRTC.LiveRoom.xxmicconnectiontimeout"), userID) parentView:self.view];
        }
    }
}

- (void)handleTimeOutRequest:(UIAlertView*)alertView {
    _userIdRequest = @"";
    if (alertView) {
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
    }
    [TCUtil toastTip: TRTCLocalize(@"Demo.TRTC.LiveRoom.dealmicconnectionreqtimeout") parentView:self.view];
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
            [self.liveRoom stopPlayWithUserID:statusInfoView.userID callback:^(int code, NSString * error) {
                
            }];
            [self.liveRoom kickoutJoinAnchor:statusInfoView.userID callback:^(int code, NSString * error) {
                
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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LocalizeReplaceXX(TRTCLocalize(@"Demo.TRTC.LiveRoom.xxinitiatepk"), user.userName) message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    __weak __typeof(self) weakSelf = self;
    UIAlertAction *reject = [UIAlertAction actionWithTitle:TRTCLocalize(@"Demo.TRTC.LiveRoom.refuse") style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf linkFrameRestore];
        [weakSelf.liveRoom responseRoomPKWithUserID:user.userId agree:NO reason:TRTCLocalize(@"Demo.TRTC.LiveRoom.anchorrefuse")];
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:TRTCLocalize(@"Demo.TRTC.LiveRoom.accept") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.liveRoom responseRoomPKWithUserID:user.userId agree:YES reason:@""];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PKNotificationKey" object:nil];
        //添加PK view
    }];
    [alert addAction:reject];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    [self performSelector:@selector(PKAlertCheck:) withObject:alert afterDelay:timeout];
}

- (void)PKAlertCheck: (UIAlertController*)alert {
    if (alert.presentingViewController == self.navigationController) {
        [TCUtil toastTip:LocalizeReplaceXX(TRTCLocalize(@"Demo.TRTC.LiveRoom.dealxxpktimeout"), _curPkRoom.ownerName) parentView:self.view];
        [alert dismissViewControllerAnimated:YES completion:nil];
        [self linkFrameRestore];
    }
}

- (void)QuitPK {
    [self.liveRoom quitRoomPK:^(int code, NSString * error) {
        
    }];
    [UIView animateWithDuration:0.1 animations:^{
        [self onAnchorExit:self->_curPkRoom.ownerId];
    }];
}

- (void)setCurPkRoom:(TRTCLiveRoomInfo *)curPkRoom {
    _curPkRoom = curPkRoom;
    if (_curPkRoom == nil) {
        _isPKEnter = NO;
        [_logicView.btnPK setImage:[UIImage imageNamed:@"live_pk_start"] forState:UIControlStateNormal];
    }
}

#pragma mark -  TCAnchorToolbarDelegate

- (void)closeRTMP {
    [self setPreviewUIHidden:YES];
    for (TCStatusInfoView* statusInfoView in _statusInfoViewArray) {
        if (statusInfoView.userID.length > 0 && [_setLinkMemeber containsObject:statusInfoView.userID]) {
            [self.liveRoom kickoutJoinAnchor:statusInfoView.userID callback:^(int code, NSString * error) {
                
            }];
        }
        [statusInfoView stopPlay];
    }
    if (_curPkRoom != nil) {
        [self QuitPK];
    }
    [self stopRtmp];
}

- (void)taggleCloseVC {
    if([_roomName isFirstResponder]) {
        [_roomName resignFirstResponder];
    }
    [self closeRTMP];
    [self closeVC];
}

- (void)closeVC {
#ifdef TRTC_APPSTORE
    if (self->_timer) {
        dispatch_source_cancel(_timer);
        self->_timer = nil;
    }
#endif
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickScreen:(UITapGestureRecognizer *)gestureRecognizer {
    _logicView.vBeauty.hidden = YES;
    if(_logicView.isPreview) {
        if([_roomName isFirstResponder]) {
            [_roomName resignFirstResponder];
        }
        if (!_isStop) {
            [self setPreviewUIHidden:NO];
        }
        return;
    }
    [_logicView setButtonHidden:NO];
    [_logicView.vMusicPanel hide];
    _logicView.vPKPanel.hidden = YES;
    
}

- (void)clickCamera:(UIButton *)button {
    _camera_switch = !_camera_switch;
    [self.liveRoom switchCamera];
}

- (void)clickBeauty:(UIButton *)button {
    [self setPreviewUIHidden:YES];
    _logicView.vBeauty.hidden = NO;
    [_logicView setButtonHidden:YES];
}

- (void)clickMusic:(UIButton *)button {
    if (!_effectViewModel) {
        _effectViewModel = [[TRTCLiveRoomSoundEffectViewModel alloc] initWithLiveRoom:_liveRoom];
    }
    TRTCLiveRoomSoundEffectAlert *alert = [[TRTCLiveRoomSoundEffectAlert alloc] initWithEffectViewModel:_effectViewModel];
    UIView *superview = [UIApplication sharedApplication].windows.firstObject;
    if (!superview) {
        superview = self.view;
    }
    [superview addSubview:alert];
    [alert mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superview);
    }];
    [superview layoutIfNeeded];
    [alert show];
}

- (void)clickPK:(UIButton *)button {
    if (_isPKEnter) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PKNotificationKey" object:nil];
    } else {
        _logicView.vPKPanel.hidden = NO;
        [_logicView.vPKPanel loadRoomsInfo];
    }
}

- (void)pkWithRoom:(TRTCLiveRoomInfo*)room {
    if (_setLinkMemeber.count > 0) {
        [TCUtil toastTip:TRTCLocalize(@"Demo.TRTC.LiveRoom.micconnectingandwaitforpk") parentView:self.view];
        return;
    }
    
    __weak __typeof(self) weakSelf = self;

    [_liveRoom requestRoomPKWithRoomID:[room.roomId intValue] userID:room.ownerId responseCallback:^(BOOL accept, NSString * error) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (self == nil) {
            return ;
        }
        if (accept) {
            [TCUtil toastTip:LocalizeReplaceXX(TRTCLocalize(@"Demo.TRTC.LiveRoom.xxacceptpkreq"), room.ownerName) parentView:self.view];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PKNotificationKey" object:nil];
            //添加PK view
            
        } else {
            if (error.length > 0) {
                [TCUtil toastTip: error parentView:self.view];
            } else {
               [TCUtil toastTip:LocalizeReplaceXX(TRTCLocalize(@"Demo.TRTC.LiveRoom.xxrefusepkreq"), room.ownerName) parentView:self.view];
            }
            if (self->_roomStatus != TRTCLiveRoomLiveStatusRoomPK) {
                self.curPkRoom = nil;
            }
        }
    }];
    
    if (_roomStatus != TRTCLiveRoomLiveStatusRoomPK) {
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
    [_logicView.vMusicPanel hide];
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
    } else if (obj.tag == 5) { // 麦克风音量
        _micVolume = obj.value/obj.maximumValue;
    } else if (obj.tag == 6) { // bgm seek
        _bgmPosition = obj.value/obj.maximumValue;
        if (_curBgmDuration != 0) {
        }
    }
}

- (void)sliderValueChangeEx:(UISlider*)obj {
    // todo
}

- (void)selectEffect:(NSInteger)index {
}

- (void)selectEffect2:(NSInteger)index {
}

#pragma mark -

- (IBAction)onAudioQualityButtonClicked:(UIButton *)sender
{
    sender.selected = YES;
    if (sender == _standardQualityButton) {
        _musicQualityButton.selected = NO;
        [_musicQualityButton setBackgroundColor:AUDIO_QUALITY_DEFAULT_COLOR];
        [_standardQualityButton setBackgroundColor:AUDIO_QUALITY_SELECTED_COLOR];
    } else {
        _standardQualityButton.selected = NO;
        [_musicQualityButton setBackgroundColor:AUDIO_QUALITY_SELECTED_COLOR];
        [_standardQualityButton setBackgroundColor:AUDIO_QUALITY_DEFAULT_COLOR];
    }
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
    [self.liveRoom stopPlayWithUserID:_curPkRoom.ownerId callback:^(int code, NSString * error) {
        
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

#pragma mark UITextFiled Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _roomName) {
        [self startPublish];
    }
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if(textField == _roomName){
        NSInteger kMaxLength = 15;
        NSString *toBeString = textField.text;
        NSString *lang = [[UIApplication sharedApplication]textInputMode].primaryLanguage; //ios7之前使用[UITextInputMode currentInputMode].primaryLanguage
        if ([lang isEqualToString:@"zh-Hans"]) { //中文输入
            UITextRange *selectedRange = [textField markedTextRange];
            //获取高亮部分
            UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
            if (!position) {// 没有高亮选择的字，则对已输入的文字进行字数统计和限制
                if (toBeString.length > kMaxLength) {
                    textField.text = [toBeString substringToIndex:kMaxLength];
                }
            }
            else{//有高亮选择的字符串，则暂不对文字进行统计和限制
            }
        } else {//中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
            if (toBeString.length > kMaxLength) {
                textField.text = [toBeString substringToIndex:kMaxLength];
            }
        }
    }
}
@end

