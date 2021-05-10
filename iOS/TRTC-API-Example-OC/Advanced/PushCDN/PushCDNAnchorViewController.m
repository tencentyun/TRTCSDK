//
//  PushCDNAnchorViewController.m
//  TRTC-API-Example-OC
//
//  Created by abyyxwang on 2021/4/20.
//

/*
 CDN发布功能 - 主播端
 TRTC APP CDN发布功能
 本文件展示如何集成CDN发布功能
 1、进入TRTC房间。 API:[self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE];
 2、多云端混流。 API: [self.trtcCloud setMixTranscodingConfig:self.transcodingConfig];
 参考文档：https://cloud.tencent.com/document/product/647/16827
 */
/*
 CDN Publishing - Anchor
 TRTC CDN Publishing
 This document shows how to integrate the CDN publishing feature.
 1. Enter a room: [self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE]
 2. Mix multiple streams on the cloud: [self.trtcCloud setMixTranscodingConfig:self.transcodingConfig]
 Documentation: https://cloud.tencent.com/document/product/647/16827
 */

#import "PushCDNAnchorViewController.h"

static const NSInteger RemoteUserMaxNum = 3;

typedef NS_ENUM(NSInteger, ShowMode) {
    Manual,
    LeftAndRight,
    PictureAndPicture,
};

@interface PushCDNAnchorViewController ()<TRTCCloudDelegate>

@property (weak, nonatomic) IBOutlet UIView *anchorView;
@property (weak, nonatomic) IBOutlet UIView *audienceViewA;
@property (weak, nonatomic) IBOutlet UIView *audienceViewB;
@property (weak, nonatomic) IBOutlet UIView *audienceViewC;

@property (weak, nonatomic) IBOutlet UITextView *streamURLTextView;
@property (weak, nonatomic) IBOutlet UILabel *roomNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *streamIDLabel;
@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *streamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPushButton;
@property (weak, nonatomic) IBOutlet UIButton *manualModeButton;
@property (weak, nonatomic) IBOutlet UIButton *leftRightModeButton;
@property (weak, nonatomic) IBOutlet UIButton *pictureinPictureModeButton;
@property (weak, nonatomic) IBOutlet UIButton *moreMixStreamButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomButtonConstraint;

@property (strong, nonatomic) TRTCCloud *trtcCloud;
@property (strong, nonatomic) NSString *userID;
@property (assign, nonatomic) ShowMode showMode;
@property (strong, nonatomic) NSMutableOrderedSet *remoteUserIdSet;
@property (strong, nonatomic) TRTCTranscodingConfig *transcodingConfig;
@property (strong, nonatomic) NSMutableArray *mixUsers;
@property (assign, nonatomic) BOOL isStartPush;

@end

@implementation PushCDNAnchorViewController

- (NSMutableArray *)mixUsers {
    if (!_mixUsers) {
        _mixUsers = [NSMutableArray array];
    }
    return _mixUsers;
}

- (TRTCTranscodingConfig *)transcodingConfig {
    if (!_transcodingConfig) {
        _transcodingConfig = [[TRTCTranscodingConfig alloc] init];
        _transcodingConfig.videoWidth      = 720;
        _transcodingConfig.videoHeight     = 1280;
        _transcodingConfig.videoBitrate    = 1500;
        _transcodingConfig.videoFramerate  = 20;
        _transcodingConfig.videoGOP        = 2;
        _transcodingConfig.audioSampleRate = 48000;
        _transcodingConfig.audioBitrate    = 64;
        _transcodingConfig.audioChannels   = 2;
        _transcodingConfig.appId   = CDNAPPID;
        _transcodingConfig.bizId   = CDNBIZID;
        _transcodingConfig.backgroundColor = 0x000000;
        _transcodingConfig.backgroundImage = nil;
    }
    return _transcodingConfig;
}

- (NSMutableOrderedSet *)remoteUserIdSet {
    if (!_remoteUserIdSet) {
        _remoteUserIdSet = [[NSMutableOrderedSet alloc] initWithCapacity:RemoteUserMaxNum];
    }
    return _remoteUserIdSet;
}

- (void)setShowMode:(ShowMode)showMode {
    _showMode = showMode;
    switch (showMode) {
        case Manual:
            self.manualModeButton.selected = true;
            self.leftRightModeButton.selected = false;
            self.pictureinPictureModeButton.selected = false;
            break;
        case LeftAndRight:
            self.manualModeButton.selected = false;
            self.leftRightModeButton.selected = true;
            self.pictureinPictureModeButton.selected = false;
            break;
        case PictureAndPicture:
            self.manualModeButton.selected = false;
            self.leftRightModeButton.selected = false;
            self.pictureinPictureModeButton.selected = true;
            break;
        default:
            break;
    }
}

- (TRTCCloud *)trtcCloud {
    if (!_trtcCloud) {
        _trtcCloud = [TRTCCloud sharedInstance];
    }
    return _trtcCloud;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userID = [NSString generateRandomUserId];
    self.trtcCloud.delegate = self;
    [self setupDefaultUIConfig];
    [self addKeyboardObserver];
}

#pragma mark - IBActions
- (IBAction)onStartPushTRTCClick:(UIButton *)sender {
    if (self.roomIDTextField.text.length == 0) {
        return;
    }
    if (self.streamIDTextField.text.length == 0) {
        return;
    }
    sender.selected = !sender.selected;
    [self resignTextFieldFirstResponder];
    if (sender.selected) {
        self.isStartPush = true;
        [self refreshViewTitle];
        [self enterTRTCRoom];
    } else {
        self.isStartPush = false;
        [self exitTRTCRoom];
    }
}

- (IBAction)onStartPublishCDNStreamClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    NSString *streamId = self.streamIDTextField.text;
    NSString *roomId = self.roomIDTextField.text;
    if (streamId == 0 || roomId == 0) {
        return;
    }
    [self showMixConfigLink];
    self.transcodingConfig.streamId = streamId;
    switch (self.showMode) {
        case Manual:
            [self setManualModeShowStatus];
            break;
        case LeftAndRight:
            [self setLeftRightModeShowStatus];
            break;
        case PictureAndPicture:
            [self setPictureinPictureModeShowStatus];
            break;
        default:
            break;
    }
    [self.trtcCloud setMixTranscodingConfig:self.transcodingConfig];
}

- (IBAction)onManualModeClick:(UIButton *)sender {
    self.showMode = Manual;
    if (self.isStartPush) {
        [self setManualModeShowStatus];
    }
}

- (IBAction)onLeftRightModeClick:(UIButton *)sender {
    self.showMode = LeftAndRight;
    if (self.isStartPush) {
        [self setLeftRightModeShowStatus];
    }
}

- (IBAction)onPictureInPictureModeClick:(UIButton *)sender {
    self.showMode = PictureAndPicture;
    if (self.isStartPush) {
        [self setPictureinPictureModeShowStatus];
    }
}

#pragma mark -  SetMixConfig
- (void)setManualModeShowStatus {
    self.transcodingConfig.mode = TRTCTranscodingConfigMode_Manual;
    [self.mixUsers removeAllObjects];
    
    TRTCMixUser* local = [TRTCMixUser new];
    local.userId = self.userID;
    local.zOrder = 1;
    local.rect   = CGRectMake(0, 0, self.transcodingConfig.videoWidth, self.transcodingConfig.videoHeight);
    local.roomID = nil;
    local.inputType = TRTCMixInputTypeAudioVideo;
    local.streamType = TRTCVideoStreamTypeBig;
    [self.mixUsers addObject:local];
    
    for (int i = 0; i < self.remoteUserIdSet.count; i++) {
        TRTCMixUser* remote = [TRTCMixUser new];
        remote.userId = self.remoteUserIdSet[i];
        remote.zOrder = i + 2;
        remote.rect   = CGRectMake(self.transcodingConfig.videoWidth * 0.2 * (i + 1), self.transcodingConfig.videoHeight * 0.2 * (i + 1), 180, 180 * 1.6);
        remote.roomID = self.roomIDTextField.text;
        remote.inputType = TRTCMixInputTypeAudioVideo;
        remote.streamType = TRTCVideoStreamTypeBig;
        [self.mixUsers addObject:remote];
    }
    
    self.transcodingConfig.mixUsers = self.mixUsers;
    [self.trtcCloud setMixTranscodingConfig:self.transcodingConfig];
}

- (void)setLeftRightModeShowStatus {
    self.transcodingConfig.mode = TRTCTranscodingConfigMode_Template_PresetLayout;
    [self.mixUsers removeAllObjects];
    
    TRTCMixUser* local = [TRTCMixUser new];
    local.userId = @"$PLACE_HOLDER_LOCAL_MAIN$";
    local.zOrder = 0;
    local.rect   = CGRectMake(0, 0, self.transcodingConfig.videoWidth * 0.5, self.transcodingConfig.videoHeight);
    local.roomID = nil;
    [self.mixUsers addObject:local];
    
    TRTCMixUser* remote = [TRTCMixUser new];
    remote.userId = @"$PLACE_HOLDER_REMOTE$";
    remote.zOrder = 1;
    remote.rect   = CGRectMake(self.transcodingConfig.videoWidth * 0.5, 0, self.transcodingConfig.videoWidth * 0.5, self.transcodingConfig.videoHeight);
    remote.roomID = self.roomIDTextField.text;
    [self.mixUsers addObject:remote];
    
    self.transcodingConfig.mixUsers = self.mixUsers;
    [self.trtcCloud setMixTranscodingConfig:self.transcodingConfig];
}

- (void)setPictureinPictureModeShowStatus {
    self.transcodingConfig.mode = TRTCTranscodingConfigMode_Template_PresetLayout;
    [self.mixUsers removeAllObjects];
    
    TRTCMixUser* local = [TRTCMixUser new];
    local.userId = @"$PLACE_HOLDER_LOCAL_MAIN$";
    local.zOrder = 0;
    local.rect   = CGRectMake(0, 0, self.transcodingConfig.videoWidth, self.transcodingConfig.videoHeight);
    local.roomID = nil;
    [self.mixUsers addObject:local];
    
    TRTCMixUser* remote = [TRTCMixUser new];
    remote.userId = @"$PLACE_HOLDER_REMOTE$";
    remote.zOrder = 1;
    remote.rect   = CGRectMake(self.transcodingConfig.videoWidth - 180 - 20, self.transcodingConfig.videoHeight * 0.1, 180, 180 * 1.6);
    remote.roomID = self.roomIDTextField.text;
    [self.mixUsers addObject:remote];
    
    self.transcodingConfig.mixUsers = self.mixUsers;
    [self.trtcCloud setMixTranscodingConfig:self.transcodingConfig];
}

#pragma mark - trtc method

- (void)enterTRTCRoom {
    [self.trtcCloud startLocalPreview:YES view:self.anchorView];

    TRTCParams *params = [[TRTCParams alloc] init];
    params.sdkAppId = SDKAppID;
    params.roomId = [self.roomIDTextField.text intValue];
    params.userId = self.userID;
    params.userSig = [GenerateTestUserSig genTestUserSig:self.userID];
    params.role = TRTCRoleAnchor;
    params.streamId = self.streamIDTextField.text;
    [self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE];
    [self.trtcCloud startLocalAudio:TRTCAudioQualityMusic];
}

- (void)showMixConfigLink {
    NSString *streamUrl = Localize(@"TRTC-API-Example.PushCDNAnchor.pushStreamAddress");
    self.streamURLTextView.text = streamUrl;
    self.streamURLTextView.alpha = 0.8;
}

- (void)exitTRTCRoom {
    [self.trtcCloud stopLocalPreview];
    [self.trtcCloud stopLocalAudio];
    [self.trtcCloud exitRoom];
    
    for (int i = 0; i < self.remoteUserIdSet.count; i++) {
        UIView *remoteView = [self.view viewWithTag: i + 200];
        remoteView.alpha = 0;
        [self.trtcCloud stopRemoteView:self.remoteUserIdSet[i] streamType:TRTCVideoStreamTypeSmall];
    }
    [self.remoteUserIdSet removeAllObjects];
}

- (void)checkMixConfigButtonEnable {
    BOOL enable = self.remoteUserIdSet.count >= 1;
    [self.moreMixStreamButton setUserInteractionEnabled:enable];
    if (enable) {
        [self.moreMixStreamButton setTitle: Localize(@"TRTC-API-Example.PushCDNAnchor.mixConfig") forState:UIControlStateNormal];
        [self.moreMixStreamButton setBackgroundColor:[UIColor themeGreenColor]];
    } else {
        [self.moreMixStreamButton setTitle: Localize(@"TRTC-API-Example.PushCDNAnchor.mixConfignot") forState:UIControlStateNormal];
        [self.moreMixStreamButton setBackgroundColor:[UIColor themeGrayColor]];
    }
}

- (void)showRemoteUserViewWith:(NSString *)userId {
    if (self.remoteUserIdSet.count < RemoteUserMaxNum) {
        NSInteger count = self.remoteUserIdSet.count;
        [self.remoteUserIdSet addObject:userId];
        UIView *userView = [self.view viewWithTag:count + 200];
        userView.alpha = 1;
        [self.trtcCloud startRemoteView:userId streamType:TRTCVideoStreamTypeSmall view:userView];
    }
    if (self.isStartPush) {
        switch (self.showMode) {
            case Manual:
                [self setManualModeShowStatus];
                break;
            case LeftAndRight:
                [self setLeftRightModeShowStatus];
                break;
            case PictureAndPicture:
                [self setPictureinPictureModeShowStatus];
                break;
            default:
                break;
        }
    }
   
}

- (void)hiddenRemoteUserViewWith:(NSString *)userId {
    NSInteger viewTag = [self.remoteUserIdSet indexOfObject:userId];
    UIView *userView = [self.view viewWithTag:viewTag + 200];
    userView.alpha = 0;
    [self.trtcCloud stopRemoteView:userId streamType:TRTCVideoStreamTypeSmall];
    [self.remoteUserIdSet removeObject:userId];
    if (self.isStartPush) {
        switch (self.showMode) {
            case Manual:
                [self setManualModeShowStatus];
                break;
            case LeftAndRight:
                [self setLeftRightModeShowStatus];
                break;
            case PictureAndPicture:
                [self setPictureinPictureModeShowStatus];
                break;
            default:
                break;
        }
    }
}

#pragma mark - TRTCCloudDelegate
- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available {
    NSInteger index = [self.remoteUserIdSet indexOfObject:userId];
    if (available) {
        if (index == NSNotFound) {
            [self showRemoteUserViewWith:userId];
        }
    } else {
        if (index != NSNotFound) {
            [self hiddenRemoteUserViewWith:userId];
        }
    }
    [self checkMixConfigButtonEnable];
}

#pragma mark - Keyboard Observer
- (BOOL)keyboardWillShow:(NSNotification *)noti {
    CGFloat animationDuration = [[[noti userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardBounds = [[[noti userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:animationDuration animations:^{
        self.bottomButtonConstraint.constant = keyboardBounds.size.height;
        [self.view layoutIfNeeded];
    }];
    return YES;
}

- (BOOL)keyboardWillHide:(NSNotification *)noti {
     CGFloat animationDuration = [[[noti userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
     [UIView animateWithDuration:animationDuration animations:^{
         self.bottomButtonConstraint.constant = 20;
         [self.view layoutIfNeeded];
     }];
     return YES;
}

- (void)addKeyboardObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)removeKeyboardObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self resignTextFieldFirstResponder];
}

- (void)resignTextFieldFirstResponder {
    if (self.roomIDTextField.isFirstResponder) {
        [self.roomIDTextField resignFirstResponder];
    }
    if (self.streamIDTextField.isFirstResponder) {
        [self.streamIDTextField resignFirstResponder];
    }
}

- (void)setupDefaultUIConfig {
    self.roomNumberLabel.text = Localize(@"TRTC-API-Example.PushCDNAnchor.roomId");
    self.streamIDLabel.text = Localize(@"TRTC-API-Example.PushCDNAnchor.StreamId");
    self.roomIDTextField.text = [NSString generateRandomRoomNumber];
    self.streamIDTextField.text= [NSString generateRandomStreamId];
    
    [self.startPushButton setBackgroundColor:UIColor.themeGreenColor];
    [self.startPushButton setTitle:Localize(@"TRTC-API-Example.PushCDNAnchor.startPush")
                          forState:UIControlStateNormal];
    [self.startPushButton setTitle:Localize(@"TRTC-API-Example.PushCDNAnchor.stopPush") forState:UIControlStateSelected];
    
    UIImage *normalImage = [[UIColor themeGrayColor] trans2Image:CGSizeMake(14, 14)];
    UIImage *selectImage = [[UIColor themeGreenColor] trans2Image:CGSizeMake(14, 14)];
    [self.manualModeButton setImage:normalImage forState:UIControlStateNormal];
    [self.manualModeButton setImage:selectImage forState:UIControlStateSelected];
    [self.manualModeButton setTitle:Localize(@"TRTC-API-Example.PushCDNAnchor.manualMode") forState:UIControlStateNormal];
    self.manualModeButton.imageView.layer.cornerRadius = 7;
    self.manualModeButton.imageView.layer.masksToBounds = true;
    self.manualModeButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    [self.leftRightModeButton setImage:normalImage forState:UIControlStateNormal];
    [self.leftRightModeButton setImage:selectImage forState:UIControlStateSelected];
    [self.leftRightModeButton setTitle:Localize(@"TRTC-API-Example.PushCDNAnchor.leftRightMode") forState:UIControlStateNormal];
    self.leftRightModeButton.imageView.layer.cornerRadius = 7;
    self.leftRightModeButton.imageView.layer.masksToBounds = true;
    self.leftRightModeButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    [self.pictureinPictureModeButton setImage:normalImage forState:UIControlStateNormal];
    [self.pictureinPictureModeButton setImage:selectImage forState:UIControlStateSelected];
    [self.pictureinPictureModeButton setTitle:Localize(@"TRTC-API-Example.PushCDNAnchor.previewMode") forState:UIControlStateNormal];
    self.pictureinPictureModeButton.imageView.layer.cornerRadius = 7;
    self.pictureinPictureModeButton.imageView.layer.masksToBounds = true;
    self.pictureinPictureModeButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    [self.moreMixStreamButton setTitle:Localize(@"TRTC-API-Example.PushCDNAnchor.mixConfignot") forState:UIControlStateNormal];
    [self.moreMixStreamButton setBackgroundColor:[UIColor themeGrayColor]];

    self.streamURLTextView.text = @"";
    self.streamURLTextView.layer.borderColor = UIColor.whiteColor.CGColor;
    self.streamURLTextView.layer.borderWidth = 0.5;
    self.streamURLTextView.backgroundColor = [UIColor themeGrayColor];
    self.streamURLTextView.alpha = 0;
    
    self.audienceViewA.tag = 200;
    self.audienceViewB.tag = 201;
    self.audienceViewC.tag = 202;
    
    self.startPushButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.moreMixStreamButton.titleLabel.adjustsFontSizeToFitWidth = YES;

    [self refreshViewTitle];
    self.isStartPush = false;
    self.showMode = PictureAndPicture;
}

- (void)refreshViewTitle {
    self.title = LocalizeReplace(Localize(@"TRTC-API-Example.PushCDNAnchor.Title"), self.roomIDTextField.text);
}

- (void)dealloc {
    [self removeKeyboardObserver];
    [self.trtcCloud stopLocalPreview];
    [self.trtcCloud stopLocalAudio];
    [self.trtcCloud exitRoom];
    [TRTCCloud destroySharedIntance];
}


@end
