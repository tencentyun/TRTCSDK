//
//  SwitchRoomViewController.m
//  TRTC-API-Example-OC
//
//  Created by adams on 2021/4/20.
//

/*
 快速切换房间示例
 TRTC APP 支持快速切换房间功能
 本文件展示如何集成快速切换房间功能
 1、进入TRTC房间。 API:[self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE];
 2、快速切换房间。  API:[self.trtcCloud switchRoom:self.switchRoomConfig];
 参考文档：https://cloud.tencent.com/document/product/647/32258
 */
/*
 Switching Rooms
 The TRTC app supports quick room switching.
 This document shows how to integrate the room switching feature.
 1. Enter a room: [self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE]
 2. Switch rooms: [self.trtcCloud switchRoom:self.switchRoomConfig]
 Documentation: https://cloud.tencent.com/document/product/647/32258
 */

#import "SwitchRoomViewController.h"

@interface SwitchRoomViewController () <TRTCCloudDelegate>

@property (weak, nonatomic) IBOutlet UILabel *toastLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomIdLabel;
@property (weak, nonatomic) IBOutlet UITextField *roomIdTextField;
@property (weak, nonatomic) IBOutlet UIButton *changeRoomButton;
@property (weak, nonatomic) IBOutlet UIButton *pushStreamButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *toastView;

@property (strong, nonatomic) TRTCCloud *trtcCloud;
@property (strong, nonatomic) TRTCSwitchRoomConfig *switchRoomConfig;
@end

@implementation SwitchRoomViewController

- (TRTCSwitchRoomConfig *)switchRoomConfig {
    if (!_switchRoomConfig) {
        _switchRoomConfig = [[TRTCSwitchRoomConfig alloc] init];
    }
    return _switchRoomConfig;
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
    self.roomIdTextField.text = [NSString generateRandomRoomNumber];
    self.title = LocalizeReplace(Localize(@"TRTC-API-Example.SwitchRoom.Title"), self.roomIdTextField.text);
    self.roomIdLabel.text = Localize(@"TRTC-API-Example.SwitchRoom.roomId");
    self.toastLabel.text = Localize(@"TRTC-API-Example.SwitchRoom.inputRoomIDNumber");
    [self.changeRoomButton setTitle:Localize(@"TRTC-API-Example.SwitchRoom.changeRoom") forState:UIControlStateNormal];
    [self.changeRoomButton setBackgroundColor:[UIColor themeGrayColor]];
    [self.changeRoomButton setUserInteractionEnabled:false];
    [self.pushStreamButton setTitle:Localize(@"TRTC-API-Example.SwitchRoom.startPush") forState:UIControlStateNormal];
    [self.pushStreamButton setTitle:Localize(@"TRTC-API-Example.SwitchRoom.stopPush") forState:UIControlStateSelected];
    [self.pushStreamButton setBackgroundColor:UIColor.themeGreenColor];
    
    self.changeRoomButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.pushStreamButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.toastView.alpha = 0;
}

#pragma mark - StartPushStream & StopPushStream
- (void)startPushStream {
    self.title = LocalizeReplace(Localize(@"TRTC-API-Example.SwitchRoom.Title"), self.roomIdTextField.text);
    [self.trtcCloud startLocalPreview:true view:self.view];

    TRTCParams *params = [[TRTCParams alloc] init];
    params.sdkAppId = SDKAppID;
    params.roomId = [self.roomIdTextField.text intValue];
    params.userId = [NSString generateRandomUserId];
    params.userSig = [GenerateTestUserSig genTestUserSig:params.userId];
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
    self.title = LocalizeReplace(Localize(@"TRTC-API-Example.SwitchRoom.Title"), self.roomIdTextField.text);
    [self.trtcCloud stopLocalPreview];
    [self.trtcCloud stopLocalAudio];
    [self.trtcCloud exitRoom];
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
- (IBAction)onChangeRoomClick:(UIButton *)sender {
    if (self.roomIdTextField.text.length < 8) {
        [UIView animateWithDuration:0.35 animations:^{
            self.toastView.alpha = 1;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.35 delay:1.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.toastView.alpha = 0;
            } completion:nil];
        }];
        return;
    }
    self.switchRoomConfig.roomId = [self.roomIdTextField.text intValue];
    [self.trtcCloud switchRoom:self.switchRoomConfig];
    self.title = LocalizeReplace(Localize(@"TRTC-API-Example.SwitchRoom.Title"), self.roomIdTextField.text);
}

- (IBAction)onPushStreamClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self startPushStream];
    } else {
        [self stopPushStream];
    }
    if (sender.selected) {
        [self.changeRoomButton setBackgroundColor:[UIColor themeGreenColor]];
        [self.changeRoomButton setUserInteractionEnabled:true];
    } else {
        [self.changeRoomButton setBackgroundColor:[UIColor themeGrayColor]];
        [self.changeRoomButton setUserInteractionEnabled:false];
    }
}

#pragma mark - TRTCCloudDelegate
- (void)onSwitchRoom:(TXLiteAVError)errCode errMsg:(NSString *)errMsg {
    NSLog(@"onSwitchRoom errCode:%d errMsg:%@",errCode,errMsg);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.roomIdTextField resignFirstResponder];
}

- (void)dealloc {
    [self removeKeyboardObserver];
    [self.trtcCloud stopLocalPreview];
    [self.trtcCloud stopLocalAudio];
    [self.trtcCloud exitRoom];
    [TRTCCloud destroySharedIntance];
}


@end
