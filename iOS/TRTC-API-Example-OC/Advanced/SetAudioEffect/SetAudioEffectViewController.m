//
//  SetAudioEffectViewController.m
//  TRTC-API-Example-OC
//
//  Created by adams on 2021/4/19.
//

/*
 设置音效功能示例
 TRTC APP 支持设置音效功能
 本文件展示如何集成设置音效功能
 1、进入TRTC房间。 API:[self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE];
 2、选择变声。API:[[self.trtcCloud getAudioEffectManager] setVoiceChangerType:TXVoiceChangeType_0];
 3、选择混响。 API:[[self.trtcCloud getAudioEffectManager] setVoiceReverbType:TXVoiceReverbType_0];
 参考文档：https://cloud.tencent.com/document/product/647/32258
 */
/*
 Setting Audio Effects
 The TRTC app supports audio effect setting.
 This document shows how to integrate the audio effect setting feature.
 1. Enter a room: [self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE]
 2. Select a voice change effect: [[self.trtcCloud getAudioEffectManager] setVoiceChangerType:TXVoiceChangeType_0]
 3. Select a reverb effect: [[self.trtcCloud getAudioEffectManager] setVoiceReverbType:TXVoiceReverbType_0]
 Documentation: https://cloud.tencent.com/document/product/647/32258
 */

#import "SetAudioEffectViewController.h"

static const NSInteger RemoteUserMaxNum = 6;

@interface SetAudioEffectViewController () <TRTCCloudDelegate>
@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;
@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;
@property (weak, nonatomic) IBOutlet UILabel *voiceChangerLabel;
@property (weak, nonatomic) IBOutlet UIButton *originVoiceButton;
@property (weak, nonatomic) IBOutlet UIButton *childVoiceButton;
@property (weak, nonatomic) IBOutlet UIButton *loliVoiceButton;
@property (weak, nonatomic) IBOutlet UIButton *metalVoiceButton;
@property (weak, nonatomic) IBOutlet UIButton *uncleVoiceButton;
@property (weak, nonatomic) IBOutlet UILabel *reverberationLabel;
@property (weak, nonatomic) IBOutlet UIButton *normalButton;
@property (weak, nonatomic) IBOutlet UIButton *ktvButton;
@property (weak, nonatomic) IBOutlet UIButton *smallRoomButton;
@property (weak, nonatomic) IBOutlet UIButton *greatHallButton;
@property (weak, nonatomic) IBOutlet UIButton *muffledButton;
@property (weak, nonatomic) IBOutlet UIButton *pushStreamButton;

@property (weak, nonatomic) IBOutlet UIView *leftRemoteUserViewA;
@property (weak, nonatomic) IBOutlet UIView *leftRemoteUserViewB;
@property (weak, nonatomic) IBOutlet UIView *leftRemoteUserViewC;
@property (weak, nonatomic) IBOutlet UIView *rightRemoteUserViewA;
@property (weak, nonatomic) IBOutlet UIView *rightRemoteUserViewB;
@property (weak, nonatomic) IBOutlet UIView *rightRemoteUserViewC;

@property (weak, nonatomic) IBOutlet UILabel *leftRemoteUserIDLabelA;
@property (weak, nonatomic) IBOutlet UILabel *leftRemoteUserIDLabelB;
@property (weak, nonatomic) IBOutlet UILabel *leftRemoteUserIDLabelC;

@property (weak, nonatomic) IBOutlet UILabel *rightRemoteUserIDLabelA;
@property (weak, nonatomic) IBOutlet UILabel *rightRemoteUserIDLabelB;
@property (weak, nonatomic) IBOutlet UILabel *rightRemoteUserIDLabelC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textfieldBottomConstraint;

@property (nonatomic, strong) TRTCCloud *trtcCloud;
@property (strong, nonatomic) NSMutableOrderedSet *remoteUserIdSet;

@end

@implementation SetAudioEffectViewController

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
    self.title = LocalizeReplace(Localize(@"TRTC-API-Example.SetAudioEffect.Title"), self.roomIDTextField.text);
    
    self.roomIDLabel.text = Localize(@"TRTC-API-Example.SetAudioEffect.roomId");
    self.userIDLabel.text = Localize(@"TRTC-API-Example.SetAudioEffect.userId");
    self.voiceChangerLabel.text = Localize(@"TRTC-API-Example.SetAudioEffect.voiceChanger");
    self.reverberationLabel.text = Localize(@"TRTC-API-Example.SetAudioEffect.reverberation");
    
    [self.originVoiceButton setTitle:Localize(@"TRTC-API-Example.SetAudioEffect.origin") forState:UIControlStateNormal];
    [self.childVoiceButton setTitle:Localize(@"TRTC-API-Example.SetAudioEffect.child") forState:UIControlStateNormal];
    [self.loliVoiceButton setTitle:Localize(@"TRTC-API-Example.SetAudioEffect.loli") forState:UIControlStateNormal];
    [self.metalVoiceButton setTitle:Localize(@"TRTC-API-Example.SetAudioEffect.metal") forState:UIControlStateNormal];
    [self.uncleVoiceButton setTitle:Localize(@"TRTC-API-Example.SetAudioEffect.uncle") forState:UIControlStateNormal];
    [self.normalButton setTitle:Localize(@"TRTC-API-Example.SetAudioEffect.normal") forState:UIControlStateNormal];
    [self.ktvButton setTitle:Localize(@"TRTC-API-Example.SetAudioEffect.ktv") forState:UIControlStateNormal];
    [self.smallRoomButton setTitle:Localize(@"TRTC-API-Example.SetAudioEffect.smallRoom") forState:UIControlStateNormal];
    [self.greatHallButton setTitle:Localize(@"TRTC-API-Example.SetAudioEffect.greatHall") forState:UIControlStateNormal];
    [self.muffledButton setTitle:Localize(@"TRTC-API-Example.SetAudioEffect.muffled") forState:UIControlStateNormal];
    
    [self.pushStreamButton setTitle:Localize(@"TRTC-API-Example.SetAudioEffect.startPush") forState:UIControlStateNormal];
    [self.pushStreamButton setTitle:Localize(Localize(@"TRTC-API-Example.SetAudioEffect.stopPush")) forState:UIControlStateSelected];
    
    self.originVoiceButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.childVoiceButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.loliVoiceButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.metalVoiceButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.uncleVoiceButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.pushStreamButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.normalButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.ktvButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.smallRoomButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.greatHallButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.muffledButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    self.leftRemoteUserIDLabelA.adjustsFontSizeToFitWidth = true;
    self.leftRemoteUserIDLabelA.tag = 300;
    self.leftRemoteUserIDLabelB.adjustsFontSizeToFitWidth = true;
    self.leftRemoteUserIDLabelB.tag = 301;
    self.leftRemoteUserIDLabelC.adjustsFontSizeToFitWidth = true;
    self.leftRemoteUserIDLabelC.tag = 302;
    
    self.rightRemoteUserIDLabelA.adjustsFontSizeToFitWidth = true;
    self.rightRemoteUserIDLabelA.tag = 303;
    self.rightRemoteUserIDLabelB.adjustsFontSizeToFitWidth = true;
    self.rightRemoteUserIDLabelB.tag = 304;
    self.rightRemoteUserIDLabelC.adjustsFontSizeToFitWidth = true;
    self.rightRemoteUserIDLabelC.tag = 305;
    
    self.leftRemoteUserViewA.alpha = 0;
    self.leftRemoteUserViewA.tag = 200;
    
    self.leftRemoteUserViewB.alpha = 0;
    self.leftRemoteUserViewB.tag = 201;
    
    self.leftRemoteUserViewC.alpha = 0;
    self.leftRemoteUserViewC.tag = 202;
    
    self.rightRemoteUserViewA.alpha = 0;
    self.rightRemoteUserViewA.tag = 203;
    
    self.rightRemoteUserViewB.alpha = 0;
    self.rightRemoteUserViewB.tag = 204;
    
    self.rightRemoteUserViewC.alpha = 0;
    self.rightRemoteUserViewC.tag = 205;
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
        self.textfieldBottomConstraint.constant = keyboardBounds.size.height;
    }];
    return YES;
}

- (BOOL)keyboardWillHide:(NSNotification *)noti {
     CGFloat animationDuration = [[[noti userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
     [UIView animateWithDuration:animationDuration animations:^{
         self.textfieldBottomConstraint.constant = 25;
     }];
     return YES;
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

#pragma mark - IBActions
- (IBAction)onOriginVoiceClick:(UIButton *)sender {
    [[self.trtcCloud getAudioEffectManager] setVoiceChangerType:TXVoiceChangeType_0];
}

- (IBAction)onChildVoiceClick:(UIButton *)sender {
    [[self.trtcCloud getAudioEffectManager] setVoiceChangerType:TXVoiceChangeType_1];
}

- (IBAction)onLoliVoiceClick:(UIButton *)sender {
    [[self.trtcCloud getAudioEffectManager] setVoiceChangerType:TXVoiceChangeType_2];
}

- (IBAction)onMetalVoiceClick:(UIButton *)sender {
    [[self.trtcCloud getAudioEffectManager] setVoiceChangerType:TXVoiceChangeType_4];
}

- (IBAction)onUncleVoiceClick:(UIButton *)sender {
    [[self.trtcCloud getAudioEffectManager] setVoiceChangerType:TXVoiceChangeType_3];
}

- (IBAction)onNormalClick:(UIButton *)sender {
    [[self.trtcCloud getAudioEffectManager] setVoiceReverbType:TXVoiceReverbType_0];
}

- (IBAction)onKtvClick:(UIButton *)sender {
    [[self.trtcCloud getAudioEffectManager] setVoiceReverbType:TXVoiceReverbType_1];
}

- (IBAction)onSmallRoomClick:(UIButton *)sender {
    [[self.trtcCloud getAudioEffectManager] setVoiceReverbType:TXVoiceReverbType_2];
}

- (IBAction)onGreatHallClick:(UIButton *)sender {
    [[self.trtcCloud getAudioEffectManager] setVoiceReverbType:TXVoiceReverbType_3];
}

- (IBAction)onMuffledClick:(UIButton *)sender {
    [[self.trtcCloud getAudioEffectManager] setVoiceReverbType:TXVoiceReverbType_4];
}

- (IBAction)onPushStreamClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self startPushStream];
    } else {
        [self stopPushStream];
    }
}

#pragma mark - StartPushStream & StopPushStream
- (void)startPushStream {
    [self.trtcCloud startLocalPreview:true view:self.view];

    self.title = LocalizeReplace(Localize(@"TRTC-API-Example.SetAudioEffect.Title"), self.roomIDTextField.text);
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
