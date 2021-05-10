//
//  SetAudioQualityViewController.m
//  TRTC-API-Example-OC
//
//  Created by bluedang on 2021/4/19.
//

/*
 设置音频质量功能
 TRTC APP 设置音频质量功能
 本文件展示如何集成设置音频质量功能
 1、设置音频质量 API: [self.trtcCloud startLocalAudio:_audioQuality];
 2、设置采集音量 API: [self.trtcCloud setAudioCaptureVolume:(UInt32)_volumeSlider.value];
 参考文档：https://cloud.tencent.com/document/product/647/32258
 */
/*
 Setting Audio Quality
 TRTC Audio Quality Setting
 This document shows how to integrate the audio quality setting feature.
 1. Set audio quality: [self.trtcCloud startLocalAudio:_audioQuality]
 2. Set capturing volume: [self.trtcCloud setAudioCaptureVolume:(UInt32)_volumeSlider.value]
 Documentation: https://cloud.tencent.com/document/product/647/32258
 */

#import "SetAudioQualityViewController.h"

static const NSInteger maxRemoteUserNum = 6;

@interface SetAudioQualityViewController () <TRTCCloudDelegate>
@property (weak, nonatomic) IBOutlet UILabel *roomIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *audioQualityLabel;
@property (weak, nonatomic) IBOutlet UILabel *audioVolumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;

@property (weak, nonatomic) IBOutlet UITextField *roomIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UIButton *audioSpeechButton;
@property (weak, nonatomic) IBOutlet UIButton *audioDefaultButton;
@property (weak, nonatomic) IBOutlet UIButton *audioMusicButton;
@property (weak, nonatomic) IBOutlet UIButton *startPublisherButton;

@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (strong, nonatomic) IBOutlet UIView *localVideoView;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *remoteViewArr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (assign, nonatomic) BOOL running;
@property (assign, nonatomic) TRTCAudioQuality audioQuality;
@property (strong, nonatomic) TRTCCloud *trtcCloud;
@property (strong, nonatomic) NSMutableOrderedSet *remoteUidSet;

@end

@implementation SetAudioQualityViewController

- (TRTCCloud*)trtcCloud {
    if (!_trtcCloud) {
        _trtcCloud = [TRTCCloud sharedInstance];
    }
    return _trtcCloud;
}

- (NSMutableOrderedSet *)remoteUidSet {
    if (!_remoteUidSet) {
        _remoteUidSet = [[NSMutableOrderedSet alloc]initWithCapacity:maxRemoteUserNum];
    }
    return _remoteUidSet;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.trtcCloud.delegate = self;
    [self setupRandomId];
    [self setupDefaultUIConfig];
    
    _audioQuality = TRTCAudioQualityDefault;
    _running = false;
}

- (void)setupDefaultUIConfig {
    self.title = [Localize(@"TRTC-API-Example.SetAudioQuality.Title") stringByAppendingString:_roomIdTextField.text];
    _roomIdLabel.text = Localize(@"TRTC-API-Example.SetAudioQuality.roomId");
    _userIdLabel.text = Localize(@"TRTC-API-Example.SetAudioQuality.userId");
    _audioQualityLabel.text = Localize(@"TRTC-API-Example.SetAudioQuality.chooseQuality");
    _audioVolumeLabel.text = Localize(@"TRTC-API-Example.SetAudioQuality.chooseVolume");
    [_audioSpeechButton setTitle:Localize(@"TRTC-API-Example.SetAudioQuality.qualitySpeech") forState:UIControlStateNormal];
    [_audioDefaultButton setTitle:Localize(@"TRTC-API-Example.SetAudioQuality.qualityDefalut") forState:UIControlStateNormal];
    [_audioMusicButton setTitle:Localize(@"TRTC-API-Example.SetAudioQuality.qualityMusic") forState:UIControlStateNormal];
    [_startPublisherButton setTitle:Localize(@"TRTC-API-Example.SetAudioQuality.start") forState:UIControlStateNormal];
    [_startPublisherButton setTitle:Localize(@"TRTC-API-Example.SetAudioQuality.stop") forState:UIControlStateSelected];
    
    _roomIdLabel.adjustsFontSizeToFitWidth = true;
    _userIdLabel.adjustsFontSizeToFitWidth = true;
    _audioQualityLabel.adjustsFontSizeToFitWidth = true;
    _audioVolumeLabel.adjustsFontSizeToFitWidth = true;
    _audioSpeechButton.titleLabel.adjustsFontSizeToFitWidth = true;
    _audioDefaultButton.titleLabel.adjustsFontSizeToFitWidth = true;
    _audioMusicButton.titleLabel.adjustsFontSizeToFitWidth = true;
    _startPublisherButton.titleLabel.adjustsFontSizeToFitWidth = true;
    _roomIdTextField.adjustsFontSizeToFitWidth = true;
    _userIdTextField.adjustsFontSizeToFitWidth = true;

    
    _volumeSlider.value = [_volumeLabel.text intValue];
    [self addKeyboardObserver];
}

- (void)setupRandomId {
    _roomIdTextField.text = [NSString generateRandomRoomNumber];
    _userIdTextField.text = [NSString generateRandomUserId];
    _roomIdTextField.textColor = [UIColor themeGrayColor];
    _userIdTextField.textColor = [UIColor themeGrayColor];
    _roomIdTextField.enabled = false;
    _userIdTextField.enabled = false;
}

- (void)setupTRTCCloud {
    _running = true;
    [self.trtcCloud startLocalPreview:YES view:_localVideoView];
    
    TRTCParams *params = [TRTCParams new];
    params.sdkAppId = SDKAppID;
    params.roomId = [_roomIdTextField.text intValue];
    params.userId = _userIdTextField.text;
    params.role = TRTCRoleAnchor;
    params.userSig = [GenerateTestUserSig genTestUserSig:params.userId];
    
    [self.trtcCloud enterRoom:params appScene:TRTCAppSceneAudioCall];
    
    TRTCVideoEncParam *encParams = [TRTCVideoEncParam new];
    encParams.videoResolution = TRTCVideoResolution_640_360;
    encParams.videoBitrate = 550;
    encParams.videoFps = 15;
    
    [self.trtcCloud setVideoEncoderParam:encParams];
    [self.trtcCloud setAudioCaptureVolume:(UInt32)_volumeSlider.value];
    [self.trtcCloud startLocalAudio:_audioQuality];
}

- (void)destroyTRTCCloud {
    _running = false;
    [TRTCCloud destroySharedIntance];
    _trtcCloud = nil;
}

- (void)dealloc {
    [self destroyTRTCCloud];
    [self removeKeyboardObserver];
}

- (IBAction)onSpeechButtonClick:(id)sender {
    _audioQuality = TRTCAudioQualitySpeech;
    if (_running) {  [self.trtcCloud startLocalAudio:_audioQuality]; }
    
    _audioSpeechButton.backgroundColor = [UIColor themeGreenColor];
    _audioDefaultButton.backgroundColor = [UIColor themeGrayColor];
    _audioMusicButton.backgroundColor = [UIColor themeGrayColor];
}

- (IBAction)onDefaultButtonClick:(id)sender {
    _audioQuality = TRTCAudioQualityDefault;
    if (_running) {  [self.trtcCloud startLocalAudio:_audioQuality]; }
    
    _audioSpeechButton.backgroundColor = [UIColor themeGrayColor];
    _audioDefaultButton.backgroundColor = [UIColor themeGreenColor];
    _audioMusicButton.backgroundColor = [UIColor themeGrayColor];
}
- (IBAction)onMusicButtonClick:(id)sender {
    _audioQuality = TRTCAudioQualityMusic;
    if (_running) {  [self.trtcCloud startLocalAudio:_audioQuality]; }

    _audioSpeechButton.backgroundColor = [UIColor themeGrayColor];
    _audioDefaultButton.backgroundColor = [UIColor themeGrayColor];
    _audioMusicButton.backgroundColor = [UIColor themeGreenColor];
}

- (IBAction)onVolumeChanged:(UISlider *)sender {
    _volumeLabel.text = [@((UInt32)_volumeSlider.value) stringValue];
    [_trtcCloud setAudioCaptureVolume:(UInt32)_volumeSlider.value];
}

- (IBAction)onStartButtonClick:(UIButton*)sender {
    if ([sender isSelected]) {
        [self.trtcCloud exitRoom];
        [self destroyTRTCCloud];
    } else {
        self.title = [Localize(@"TRTC-API-Example.SetAudioQuality.Title") stringByAppendingString:_roomIdTextField.text];
        [self setupTRTCCloud];
    }
    sender.selected = !sender.selected;
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
         self.bottomConstraint.constant = 20;
     }];
     return YES;
}


#pragma mark - TRTCCloud Delegate

- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available {
    NSInteger index = [self.remoteUidSet indexOfObject:userId];
    if (available) {
        if (index != NSNotFound) { return; }
        [_remoteUidSet addObject:userId];
    } else {
        [_trtcCloud stopRemoteView:userId streamType:TRTCVideoStreamTypeSmall];
        [_remoteUidSet removeObject:userId];
    }
    [self refreshRemoteVideoViews];
}

- (void)refreshRemoteVideoViews {
    NSInteger index = 0;
    for (NSString* userId in _remoteUidSet) {
        if (index >= maxRemoteUserNum) { return; }
        [_remoteViewArr[index] setHidden:false];
        [_trtcCloud startRemoteView:userId streamType:TRTCVideoStreamTypeSmall
                               view:_remoteViewArr[index++]];
    }
}

@end
