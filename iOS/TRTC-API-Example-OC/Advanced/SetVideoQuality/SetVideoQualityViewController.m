//
//  SetVideoQualityViewController.m
//  TRTC-API-Example-OC
//
//  Created by bluedang on 2021/4/19.
//

/*
设置画面质量功能
 TRTC APP 设置画面质量功能
 本文件展示如何集成设置画面质量功能
 1、设置分辨率 API: [self.trtcCloud setVideoEncoderParam:self.videoEncParam];
 2、设置码率 API: [self.trtcCloud setVideoEncoderParam:self.videoEncParam];
 3、设置帧率 API: [self.trtcCloud setVideoEncoderParam:self.videoEncParam];
 参考文档：https://cloud.tencent.com/document/product/647/32236
 */

/*
 Setting Video Quality
  TRTC Video Quality Setting
  This document shows how to integrate the video quality setting feature.
  1. Set resolution: [self.trtcCloud setVideoEncoderParam:self.videoEncParam]
  2. Set bitrate: [self.trtcCloud setVideoEncoderParam:self.videoEncParam]
  3. Set frame rate: [self.trtcCloud setVideoEncoderParam:self.videoEncParam]
  Documentation: https://cloud.tencent.com/document/product/647/32236
 */


#import "SetVideoQualityViewController.h"

static const NSInteger maxRemoteUserNum = 6;

@interface BitrateRange : NSObject
@property (assign, nonatomic) UInt32 minBitrate;
@property (assign, nonatomic) UInt32 maxBitrate;
@property (assign, nonatomic) UInt32 defaultBitrate;
- (instancetype)initWithMinBitrate:(UInt32)minBitrate maxBitRate:(UInt32)maxBitrate defaultBitrate:(UInt32)defaultBitrate;
@end

@interface SetVideoQualityViewController () <TRTCCloudDelegate>
@property (weak, nonatomic) IBOutlet UILabel *roomIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *chooseBitrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *chooseFpsLabel;
@property (weak, nonatomic) IBOutlet UILabel *chooseResolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *bitrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *fpsLabel;

@property (weak, nonatomic) IBOutlet UITextField *roomIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;

@property (weak, nonatomic) IBOutlet UIButton *video360PButton;
@property (weak, nonatomic) IBOutlet UIButton *video540PButton;
@property (weak, nonatomic) IBOutlet UIButton *video720PButton;
@property (weak, nonatomic) IBOutlet UIButton *video1080PButton;
@property (weak, nonatomic) IBOutlet UIButton *startPublisherButton;
@property (weak, nonatomic) IBOutlet UISlider *bitrateSlider;
@property (weak, nonatomic) IBOutlet UISlider *fpsSlider;

@property (weak, nonatomic) IBOutlet UIView *localVideoView;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *remoteViewArr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (strong, nonatomic) TRTCCloud *trtcCloud;
@property (strong, nonatomic) TRTCVideoEncParam *videoEncParam;
@property (assign, nonatomic) TRTCVideoResolution videoResolution;
@property (strong, nonatomic) NSMutableOrderedSet *remoteUidSet;
@property (strong, nonatomic) NSMutableDictionary *bitrateDic;

@end

@implementation SetVideoQualityViewController


- (TRTCCloud*)trtcCloud {
    if (!_trtcCloud) {
        _trtcCloud = [TRTCCloud sharedInstance];
    }
    return _trtcCloud;
}

- (TRTCVideoEncParam *)videoEncParam {
    if (!_videoEncParam) {
        _videoEncParam = [[TRTCVideoEncParam alloc] init];
    }
    return _videoEncParam;
}

- (NSMutableOrderedSet *)remoteUidSet {
    if (!_remoteUidSet) {
        _remoteUidSet = [[NSMutableOrderedSet alloc]initWithCapacity:maxRemoteUserNum];
    }
    return _remoteUidSet;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _videoResolution = TRTCVideoResolution_960_540;
    self.trtcCloud.delegate = self;
    [self setupBitrateDic];
    [self setupRandomId];
    [self setupDefaultUIConfig];
}

- (void)dealloc {
    [self destroyTRTCCloud];
}

- (void)setupDefaultUIConfig {
    self.title = Localize(@"TRTC-API-Example.SetVideoQuality.Title");
    _roomIdLabel.text = Localize(@"TRTC-API-Example.SetVideoQuality.roomId");
    _userIdLabel.text = Localize(@"TRTC-API-Example.SetVideoQuality.userId");
    _chooseBitrateLabel.text = Localize(@"TRTC-API-Example.SetVideoQuality.chooseBitrate");
    _chooseFpsLabel.text = Localize(@"TRTC-API-Example.SetVideoQuality.chooseFps");
    _chooseResolutionLabel.text = Localize(@"TRTC-API-Example.SetVideoQuality.chooseResolution");
    [_startPublisherButton setTitle:Localize(@"TRTC-API-Example.SetVideoQuality.start") forState:UIControlStateNormal];
    [_startPublisherButton setTitle:Localize(@"TRTC-API-Example.SetVideoQuality.stop") forState:UIControlStateSelected];
    _fpsSlider.value = 15;
    _roomIdLabel.adjustsFontSizeToFitWidth = true;
    _userIdLabel.adjustsFontSizeToFitWidth = true;
    _chooseFpsLabel.adjustsFontSizeToFitWidth = true;
    _chooseBitrateLabel.adjustsFontSizeToFitWidth = true;
    _chooseResolutionLabel.adjustsFontSizeToFitWidth = true;
    _roomIdTextField.adjustsFontSizeToFitWidth = true;
    _userIdTextField.adjustsFontSizeToFitWidth = true;
    [self refreshBitrateSlider];
    [self addKeyboardObserver];
}

- (void)setupBitrateDic {
    if (!_bitrateDic) {
        _bitrateDic = [NSMutableDictionary new];
        [_bitrateDic setObject:[[BitrateRange alloc] initWithMinBitrate:200 maxBitRate:1000 defaultBitrate:800]  forKey:[@(TRTCVideoResolution_640_360) stringValue]];
        [_bitrateDic setObject:[[BitrateRange alloc] initWithMinBitrate:400 maxBitRate:1600 defaultBitrate:900]  forKey:[@(TRTCVideoResolution_960_540) stringValue]];
        [_bitrateDic setObject:[[BitrateRange alloc] initWithMinBitrate:500 maxBitRate:2000 defaultBitrate:1250]  forKey:[@(TRTCVideoResolution_1280_720) stringValue]];
        [_bitrateDic setObject:[[BitrateRange alloc] initWithMinBitrate:800 maxBitRate:3000 defaultBitrate:1900]  forKey:[@(TRTCVideoResolution_1920_1080) stringValue]];
    }
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
    [self.trtcCloud startLocalPreview:YES view:_localVideoView];

    TRTCParams *params = [TRTCParams new];
    params.sdkAppId = SDKAppID;
    params.roomId = [_roomIdTextField.text intValue];
    params.userId = _userIdTextField.text;
    params.role = TRTCRoleAnchor;
    params.userSig = [GenerateTestUserSig genTestUserSig:params.userId];
    
    [self.trtcCloud enterRoom:params appScene:TRTCAppSceneAudioCall];
    
    self.videoEncParam.videoResolution = _videoResolution;
    self.videoEncParam.videoBitrate = (UInt32)_bitrateSlider.value;
    self.videoEncParam.videoFps = (UInt32)_fpsSlider.value;
    
    [self.trtcCloud setVideoEncoderParam:self.videoEncParam];
}

- (void)destroyTRTCCloud {
    [TRTCCloud destroySharedIntance];
    _trtcCloud = nil;
    [self removeKeyboardObserver];
}

- (void)refreshBitrateSlider {
    BitrateRange *bitrateRange = [_bitrateDic objectForKey:[@(_videoResolution) stringValue]];
    _bitrateSlider.maximumValue = bitrateRange.maxBitrate;
    _bitrateSlider.minimumValue = bitrateRange.minBitrate;
    _bitrateSlider.value = bitrateRange.defaultBitrate;
    
    [self onBitrateChanged:_bitrateSlider];
}

- (void)refreshEncParam {
    self.videoEncParam.videoResolution = _videoResolution;
    self.videoEncParam.videoBitrate = (UInt32)_bitrateSlider.value;
    self.videoEncParam.videoFps = (UInt32)_fpsSlider.value;
    
    [self.trtcCloud setVideoEncoderParam:self.videoEncParam];
}

# pragma mark - IBActions

- (IBAction)onVideo360PClick:(id)sender {
    _videoResolution = TRTCVideoResolution_640_360;
    
    _video360PButton.backgroundColor = [UIColor themeGreenColor];
    _video540PButton.backgroundColor = [UIColor themeGrayColor];
    _video720PButton.backgroundColor = [UIColor themeGrayColor];
    _video1080PButton.backgroundColor = [UIColor themeGrayColor];
    
    [self refreshBitrateSlider];
    [self refreshEncParam];
}

- (IBAction)onVideo540PClick:(id)sender {
    _videoResolution = TRTCVideoResolution_960_540;
    
    _video360PButton.backgroundColor = [UIColor themeGrayColor];
    _video540PButton.backgroundColor = [UIColor themeGreenColor];
    _video720PButton.backgroundColor = [UIColor themeGrayColor];
    _video1080PButton.backgroundColor = [UIColor themeGrayColor];

    [self refreshBitrateSlider];
    [self refreshEncParam];
}

- (IBAction)onVideo720PClick:(id)sender {
    _videoResolution = TRTCVideoResolution_1280_720;

    _video360PButton.backgroundColor = [UIColor themeGrayColor];
    _video540PButton.backgroundColor = [UIColor themeGrayColor];
    _video720PButton.backgroundColor = [UIColor themeGreenColor];
    _video1080PButton.backgroundColor = [UIColor themeGrayColor];

    [self refreshBitrateSlider];
    [self refreshEncParam];
}

- (IBAction)onVideo1080PClick:(id)sender {
    _videoResolution = TRTCVideoResolution_1920_1080;
    
    _video360PButton.backgroundColor = [UIColor themeGrayColor];
    _video540PButton.backgroundColor = [UIColor themeGrayColor];
    _video720PButton.backgroundColor = [UIColor themeGrayColor];
    _video1080PButton.backgroundColor = [UIColor themeGreenColor];

    [self refreshBitrateSlider];
    [self refreshEncParam];
}

- (IBAction)onStartButtonClick:(UIButton*)sender {
    if ([sender isSelected]) {
        self.title = Localize(@"TRTC-API-Example.SetVideoQuality.Title");
        [self.trtcCloud exitRoom];
        [self destroyTRTCCloud];
    } else {
        self.title = [Localize(@"TRTC-API-Example.SetVideoQuality.Title") stringByAppendingString:_roomIdTextField.text];
        [self setupTRTCCloud];
    }
    sender.selected = !sender.selected;
}

- (IBAction)onBitrateChanged:(id)sender {
    _bitrateLabel.text = [[@((UInt32)_bitrateSlider.value) stringValue] stringByAppendingString:@" kbps"];
    [self refreshEncParam];
}

- (IBAction)onFpsChanged:(id)sender {
    _fpsLabel.text = [[@((UInt32)_fpsSlider.value) stringValue] stringByAppendingString:@" fps"];
    [self refreshEncParam];
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

#pragma mark - BitrateRange

@implementation BitrateRange

- (instancetype)initWithMinBitrate:(UInt32)minBitrate maxBitRate:(UInt32)maxBitrate defaultBitrate:(UInt32)defaultBitrate {
    BitrateRange *bitrateRange = [BitrateRange new];
    bitrateRange.minBitrate = minBitrate;
    bitrateRange.maxBitrate = maxBitrate;
    bitrateRange.defaultBitrate = defaultBitrate;
    return bitrateRange;
}

@end
