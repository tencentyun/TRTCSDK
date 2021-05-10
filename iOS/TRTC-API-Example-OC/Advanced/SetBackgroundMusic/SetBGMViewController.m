//
//  SetBGMViewController.m
//  TRTC-API-Example-OC
//
//  Created by adams on 2021/4/20.
//

/*
 设置背景音乐功能示例
 TRTC APP 支持设置背景音乐功能
 本文件展示如何集成设置背景音乐功能
 1、进入TRTC房间。 API:[self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE];
 2、播放背景音乐。  API:[[self.trtcCloud getAudioEffectManager] startPlayMusic:self.bgmParam onStart:^(NSInteger errCode) {} onProgress:^(NSInteger progressMs, NSInteger durationMs) {} onComplete:^(NSInteger errCode) {}];
 3、暂停背景音乐。  API:[[self.trtcCloud getAudioEffectManager] stopPlayMusic:self.bgmParam.ID];
 4、调整播放的背景音乐音量。API:[[self.trtcCloud getAudioEffectManager] setMusicPlayoutVolume:self.bgmParam.ID volume:volume];
 5、调整远端播放的背景音乐音量。API:[[self.trtcCloud getAudioEffectManager] setMusicPublishVolume:self.bgmParam.ID volume:volume];
 参考文档：https://cloud.tencent.com/document/product/647/32258
 */
/*
 Setting Background Music
 The TRTC app supports background music setting.
 This document shows how to integrate the background music setting feature.
 1. Enter a room: [self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE]
 2. Play background music: [[self.trtcCloud getAudioEffectManager] startPlayMusic:self.bgmParam onStart:^(NSInteger errCode) {} onProgress:^(NSInteger progressMs, NSInteger durationMs) {} onComplete:^(NSInteger errCode) {}]
 3. Pause background music: [[self.trtcCloud getAudioEffectManager] stopPlayMusic:self.bgmParam.ID]
 4. Adjust the playback volume of background music: [[self.trtcCloud getAudioEffectManager] setMusicPlayoutVolume:self.bgmParam.ID volume:volume]
 5. Adjust the remote playback volume of background music: [[self.trtcCloud getAudioEffectManager] setMusicPublishVolume:self.bgmParam.ID volume:volume]
 Documentation: https://cloud.tencent.com/document/product/647/32258
 */

#import "SetBGMViewController.h"

static const NSInteger RemoteUserMaxNum = 6;

@interface SetBGMViewController () <TRTCCloudDelegate>
@property (weak, nonatomic) IBOutlet UIButton *startPushButton;
@property (weak, nonatomic) IBOutlet UIButton *bgmButtonA;
@property (weak, nonatomic) IBOutlet UIButton *bgmButtonB;
@property (weak, nonatomic) IBOutlet UIButton *bgmButtonC;
@property (weak, nonatomic) IBOutlet UILabel *roomIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *bgmVolumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *bgmLabel;
@property (weak, nonatomic) IBOutlet UILabel *bgmVolumeNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftRemoteLabelA;
@property (weak, nonatomic) IBOutlet UILabel *leftRemoteLabelB;
@property (weak, nonatomic) IBOutlet UILabel *leftRemoteLabelC;
@property (weak, nonatomic) IBOutlet UILabel *rightRemoteLabelA;
@property (weak, nonatomic) IBOutlet UILabel *rightRemoteLabelB;
@property (weak, nonatomic) IBOutlet UILabel *rightRemoteLabelC;
@property (weak, nonatomic) IBOutlet UISlider *bgmVolumeSlider;
@property (weak, nonatomic) IBOutlet UIView *leftRemoteViewA;
@property (weak, nonatomic) IBOutlet UIView *leftRemoteViewB;
@property (weak, nonatomic) IBOutlet UIView *leftRemoteViewC;
@property (weak, nonatomic) IBOutlet UIView *rightRemoteViewA;
@property (weak, nonatomic) IBOutlet UIView *rightRemoteViewB;
@property (weak, nonatomic) IBOutlet UIView *rightRemoteViewC;
@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (strong, nonatomic) TRTCCloud *trtcCloud;
@property (strong, nonatomic) NSMutableOrderedSet *remoteUserIdSet;
@property (strong, nonatomic) NSArray *bgmURLArray;
@property (strong, nonatomic) TXAudioMusicParam *bgmParam;
@end

@implementation SetBGMViewController

- (TXAudioMusicParam *)bgmParam {
    if (!_bgmParam) {
        _bgmParam = [[TXAudioMusicParam alloc] init];
    }
    return _bgmParam;
}


- (NSArray *)bgmURLArray {
    if (!_bgmURLArray) {
        _bgmURLArray = @[@"https://sdk-liteav-1252463788.cos.ap-hongkong.myqcloud.com/app/res/bgm/trtc/PositiveHappyAdvertising.mp3",
                         @"https://sdk-liteav-1252463788.cos.ap-hongkong.myqcloud.com/app/res/bgm/trtc/SadCinematicPiano.mp3",
                         @"https://sdk-liteav-1252463788.cos.ap-hongkong.myqcloud.com/app/res/bgm/trtc/WonderWorld.mp3"];
    }
    return _bgmURLArray;
}

- (NSMutableOrderedSet *)remoteUserIdSet {
    if (!_remoteUserIdSet) {
        _remoteUserIdSet = [[NSMutableOrderedSet alloc] initWithCapacity:RemoteUserMaxNum];
    }
    return _remoteUserIdSet;
}

- (TRTCCloud *)trtcCloud {
    if (!_trtcCloud) {
        _trtcCloud = [TRTCCloud sharedInstance];
    }
    return _trtcCloud;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.trtcCloud.delegate = self;
    [self setupDefaultUIConfig];
    [self addKeyboardObserver];
}

- (void)setupDefaultUIConfig {
    
    self.roomIDTextField.text = [NSString generateRandomRoomNumber];
    self.userIDTextField.text = [NSString generateRandomUserId];
    self.title = LocalizeReplace(Localize(@"TRTC-API-Example.SetBGM.Title"), self.roomIDTextField.text);
    
    self.roomIdLabel.text = Localize(@"TRTC-API-Example.SetBGM.roomId");
    self.userIdLabel.text = Localize(@"TRTC-API-Example.SetBGM.userId");
    self.bgmLabel.text = Localize(@"TRTC-API-Example.SetBGM.bgmChanger");
    self.bgmVolumeLabel.text = Localize(@"TRTC-API-Example.SetBGM.setBgmVolume");
    
    [self.bgmButtonA setTitle:Localize(@"TRTC-API-Example.SetBGM.bgm1") forState:UIControlStateNormal];
    [self.bgmButtonB setTitle:Localize(@"TRTC-API-Example.SetBGM.bgm2") forState:UIControlStateNormal];
    [self.bgmButtonC setTitle:Localize(@"TRTC-API-Example.SetBGM.bgm3") forState:UIControlStateNormal];
    
    [self.startPushButton setTitle:Localize(@"TRTC-API-Example.SetBGM.startPush") forState:UIControlStateNormal];
    [self.startPushButton setTitle:Localize(Localize(@"TRTC-API-Example.SetBGM.stopPush")) forState:UIControlStateSelected];
    
    self.bgmButtonA.titleLabel.adjustsFontSizeToFitWidth = true;
    self.bgmButtonB.titleLabel.adjustsFontSizeToFitWidth = true;
    self.bgmButtonC.titleLabel.adjustsFontSizeToFitWidth = true;
    self.startPushButton.titleLabel.adjustsFontSizeToFitWidth = true;
  
    self.leftRemoteLabelA.adjustsFontSizeToFitWidth = true;
    self.leftRemoteLabelA.tag = 300;
    self.leftRemoteLabelB.adjustsFontSizeToFitWidth = true;
    self.leftRemoteLabelB.tag = 301;
    self.leftRemoteLabelC.adjustsFontSizeToFitWidth = true;
    self.leftRemoteLabelC.tag = 302;
    
    self.rightRemoteLabelA.adjustsFontSizeToFitWidth = true;
    self.rightRemoteLabelA.tag = 303;
    self.rightRemoteLabelB.adjustsFontSizeToFitWidth = true;
    self.rightRemoteLabelB.tag = 304;
    self.rightRemoteLabelC.adjustsFontSizeToFitWidth = true;
    self.rightRemoteLabelC.tag = 305;
    
    self.leftRemoteViewA.alpha = 0;
    self.leftRemoteViewA.tag = 200;
    
    self.leftRemoteViewB.alpha = 0;
    self.leftRemoteViewB.tag = 201;
    
    self.leftRemoteViewC.alpha = 0;
    self.leftRemoteViewC.tag = 202;
    
    self.rightRemoteViewA.alpha = 0;
    self.rightRemoteViewA.tag = 203;
    
    self.rightRemoteViewB.alpha = 0;
    self.rightRemoteViewB.tag = 204;
    
    self.rightRemoteViewC.alpha = 0;
    self.rightRemoteViewC.tag = 205;
    self.bgmVolumeNumberLabel.adjustsFontSizeToFitWidth = true;
    self.bgmVolumeNumberLabel.text = [NSString stringWithFormat:@"%d",(int)self.bgmVolumeSlider.value];
}

- (void)showRemoteUserViewWith:(NSString *)userId {
    if (self.remoteUserIdSet.count < RemoteUserMaxNum) {
        NSInteger count = self.remoteUserIdSet.count;
        [self.remoteUserIdSet addObject:userId];
        UIView *userView = [self.view viewWithTag:count + 200];
        UILabel *userIdLabel = [self.view viewWithTag:count + 300];
        userView.alpha = 1;
        userIdLabel.text = LocalizeReplace(Localize(@"TRTC-API-Example.SendAndReceiveSEI.UserIdxx"), userId);
        [self.trtcCloud startRemoteView:userId streamType:TRTCVideoStreamTypeSmall view:userView];
    }
}

- (void)hiddenRemoteUserViewWith:(NSString *)userId {
    NSInteger viewTag = [self.remoteUserIdSet indexOfObject:userId];
    UIView *userView = [self.view viewWithTag:viewTag + 200];
    UILabel *userIdLabel = [self.view viewWithTag:viewTag + 300];
    userView.alpha = 0;
    userIdLabel.text = @"";
    [self.trtcCloud stopRemoteView:userId streamType:TRTCVideoStreamTypeSmall];
    [self.remoteUserIdSet removeObject:userId];
}

#pragma mark - Notification
- (void)addKeyboardObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)keyboardWillShow:(NSNotification *)noti {
    CGFloat animationDuration = [[[noti userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardBounds = [[[noti userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:animationDuration animations:^{
        self.bottomConstraint.constant = keyboardBounds.size.height;
    }];
    return YES;
}

- (BOOL)keyboardWillHide:(NSNotification *)noti {
     CGFloat animationDuration = [[[noti userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
     [UIView animateWithDuration:animationDuration animations:^{
         self.bottomConstraint.constant = 25;
     }];
     return YES;
}

#pragma mark - IBActions
- (IBAction)onBgmAClick:(UIButton *)sender {
    if (self.bgmParam.ID > 0) {
        [[self.trtcCloud getAudioEffectManager] stopPlayMusic:self.bgmParam.ID];
    }
    NSString *path = self.bgmURLArray[0];
    self.bgmParam.ID = 1234;
    self.bgmParam.path = path;
    self.bgmParam.publish = true;
    
    [[self.trtcCloud getAudioEffectManager] startPlayMusic:self.bgmParam onStart:^(NSInteger errCode) {
        NSLog(@"Start errCode = %ld",errCode);
    } onProgress:^(NSInteger progressMs, NSInteger durationMs) {
        NSLog(@"progressMs = %ld, durationMs = %ld",durationMs,durationMs);
    } onComplete:^(NSInteger errCode) {
        NSLog(@"Complete errCode = %ld",errCode);
    }];
}

- (IBAction)onBgmBClick:(UIButton *)sender {
    if (self.bgmParam.ID > 0) {
        [[self.trtcCloud getAudioEffectManager] stopPlayMusic:self.bgmParam.ID];
    }
    NSString *path = self.bgmURLArray[1];
    self.bgmParam.ID = 2234;
    self.bgmParam.path = path;
    self.bgmParam.publish = true;
    
    [[self.trtcCloud getAudioEffectManager] startPlayMusic:self.bgmParam onStart:^(NSInteger errCode) {
        NSLog(@"Start errCode = %ld",errCode);
    } onProgress:^(NSInteger progressMs, NSInteger durationMs) {
        NSLog(@"progressMs = %ld, durationMs = %ld",durationMs,durationMs);
    } onComplete:^(NSInteger errCode) {
        NSLog(@"Complete errCode = %ld",errCode);
    }];
}

- (IBAction)onBgmCClick:(UIButton *)sender {
    if (self.bgmParam.ID > 0) {
        [[self.trtcCloud getAudioEffectManager] stopPlayMusic:self.bgmParam.ID];
    }
    NSString *path = self.bgmURLArray[2];
    self.bgmParam.ID = 3234;
    self.bgmParam.path = path;
    self.bgmParam.publish = true;
    
    [[self.trtcCloud getAudioEffectManager] startPlayMusic:self.bgmParam onStart:^(NSInteger errCode) {
        NSLog(@"Start errCode = %ld",errCode);
    } onProgress:^(NSInteger progressMs, NSInteger durationMs) {
        NSLog(@"progressMs = %ld, durationMs = %ld",durationMs,durationMs);
    } onComplete:^(NSInteger errCode) {
        NSLog(@"Complete errCode = %ld",errCode);
    }];
}

- (IBAction)onPushStreamClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self startPushStream];
    } else {
        [self stopPushStream];
    }
}

#pragma mark - Slider ValueChange
- (IBAction)bgmVolumeSliderValueChange:(UISlider *)sender {
    NSInteger volume = sender.value;
    self.bgmVolumeNumberLabel.text = [NSString stringWithFormat:@"%ld",volume];
    if (self.bgmParam.ID == 0) {
        return;
    }
    [[self.trtcCloud getAudioEffectManager] setMusicPlayoutVolume:self.bgmParam.ID volume:volume];
    [[self.trtcCloud getAudioEffectManager] setMusicPublishVolume:self.bgmParam.ID volume:volume];
}

#pragma mark - TRTCCloudDelegate
- (void)onRemoteUserEnterRoom:(NSString *)userId {
    NSInteger index = [self.remoteUserIdSet indexOfObject:userId];
    if (index == NSNotFound) {
        [self showRemoteUserViewWith:userId];
    }
}

- (void)onRemoteUserLeaveRoom:(NSString *)userId reason:(NSInteger)reason {
    NSInteger index = [self.remoteUserIdSet indexOfObject:userId];
    if (index) {
        [self hiddenRemoteUserViewWith:userId];
    }
}

#pragma mark - StartPushStream & StopPushStream
- (void)startPushStream {
    self.title = LocalizeReplace(Localize(@"TRTC-API-Example.SetAudioEffect.Title"), self.roomIDTextField.text);
  
    [self.trtcCloud startLocalPreview:true view:self.view];
    
    TRTCParams *params = [[TRTCParams alloc] init];
    params.sdkAppId = SDKAppID;
    params.roomId = [self.roomIDTextField.text intValue];
    params.userId = self.userIDTextField.text;
    params.userSig = [GenerateTestUserSig genTestUserSig:self.userIDTextField.text];
    params.role = TRTCRoleAnchor;
    
    [self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE];
    [self.trtcCloud startLocalAudio:TRTCAudioQualityMusic];
    
    TRTCVideoEncParam *videoEncParam = [[TRTCVideoEncParam alloc] init];
    videoEncParam.videoFps = 24;
    videoEncParam.resMode = TRTCVideoResolutionModePortrait;
    videoEncParam.videoResolution = TRTCVideoResolution_960_540;
    [self.trtcCloud setVideoEncoderParam:videoEncParam];
}

- (void)stopPushStream {
    [self.trtcCloud stopLocalPreview];
    [self.trtcCloud stopLocalAudio];
    [self.trtcCloud exitRoom];
    for (int i = 0; i < self.remoteUserIdSet.count; i++) {
        UIView *remoteView = [self.view viewWithTag: i + 200];
        UILabel *remoteLabel = [self.view viewWithTag: i + 300];
        remoteView.alpha = 0;
        remoteLabel.text = @"";
        [self.trtcCloud stopRemoteView:self.remoteUserIdSet[i] streamType:TRTCVideoStreamTypeSmall];
    }
    [self.remoteUserIdSet removeAllObjects];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.userIDTextField resignFirstResponder];
    [self.roomIDTextField resignFirstResponder];
}

- (void)dealloc {
    [self removeKeyboardObserver];
    [self.trtcCloud stopLocalPreview];
    [self.trtcCloud stopLocalAudio];
    [self.trtcCloud exitRoom];
    [TRTCCloud destroySharedIntance];
}

@end
