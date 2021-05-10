//
//  RoomPkViewController.m
//  TRTC-API-Example-OC
//
//  Created by bluedang on 2021/4/22.
//

/*
 跨房PK功能
 TRTC 跨房PK
 
 本文件展示如何集成跨房PK
 
 1、连接其他房间 API: [self.trtcCloud connectOtherRoom:jsonString];
 
 参考文档：https://cloud.tencent.com/document/product/647/32258
 */
/*
 Cross-room Competition
 The TRTC app supports cross-room competition.

 This document shows how to integrate the cross-room competition feature.

 1. Connect to another room: [self.trtcCloud connectOtherRoom:jsonString]

 Documentation: https://cloud.tencent.com/document/product/647/32258
 */

#import "RoomPkViewController.h"

@interface RoomPkViewController () <TRTCCloudDelegate>

@property (weak, nonatomic) IBOutlet UILabel *roomIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherRoomIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherUserIdLabel;

@property (weak, nonatomic) IBOutlet UIView *localView;
@property (weak, nonatomic) IBOutlet UIView *remoteView;
@property (weak, nonatomic) IBOutlet UITextField *roomIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *otherRoomIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *otherUserIdTextField;


@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *connectOtherRoomButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;


@property (strong, nonatomic) TRTCCloud *trtcCloud;
@end

@implementation RoomPkViewController

- (TRTCCloud*)trtcCloud {
    if (!_trtcCloud) {
        _trtcCloud = [TRTCCloud sharedInstance];
        [_trtcCloud createSubCloud];
    }
    return _trtcCloud;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.trtcCloud setDelegate:self];
    [self setupRandomRoomId];
    [self setupDefaultUIConfig];
}

- (void)setupDefaultUIConfig {
    self.title = [Localize(@"TRTC-API-Example.RoomPk.title") stringByAppendingString:_roomIdTextField.text];
    _roomIdLabel.text = Localize(@"TRTC-API-Example.RoomPk.roomId");
    _userIdLabel.text = Localize(@"TRTC-API-Example.RoomPk.UserId");
    _otherRoomIdLabel.text = Localize(@"TRTC-API-Example.RoomPk.pkRoomId");
    _otherUserIdLabel.text = Localize(@"TRTC-API-Example.RoomPk.pkUserId");

    [_startButton setTitle:Localize(@"TRTC-API-Example.RoomPk.start")
                  forState:UIControlStateNormal];
    [_startButton setTitle:Localize(@"TRTC-API-Example.RoomPk.stop")
                  forState:UIControlStateSelected];
    [_connectOtherRoomButton setTitle:Localize(@"TRTC-API-Example.RoomPk.startPK")
                  forState:UIControlStateNormal];
    [_connectOtherRoomButton setTitle:Localize(@"TRTC-API-Example.RoomPk.stopPK")
                  forState:UIControlStateSelected];
    _roomIdLabel.adjustsFontSizeToFitWidth = true;
    _userIdLabel.adjustsFontSizeToFitWidth = true;
    _otherRoomIdLabel.adjustsFontSizeToFitWidth = true;
    _otherUserIdLabel.adjustsFontSizeToFitWidth = true;
    _startButton.titleLabel.adjustsFontSizeToFitWidth = true;
    _connectOtherRoomButton.titleLabel.adjustsFontSizeToFitWidth = true;
    _userIdTextField.adjustsFontSizeToFitWidth = true;
    _roomIdTextField.adjustsFontSizeToFitWidth = true;
    _otherRoomIdLabel.adjustsFontSizeToFitWidth = true;
    _otherUserIdLabel.adjustsFontSizeToFitWidth = true;
    [self refreshPkButton];
    [self addKeyboardObserver];
}

- (void)setupRandomRoomId {
    _roomIdTextField.text = [NSString generateRandomRoomNumber];
    _userIdTextField.text = [NSString generateRandomUserId];
}

- (void)setupTRTCCloud {
    [self.trtcCloud startLocalPreview:YES view:_localView];

    TRTCParams *params = [TRTCParams new];
    params.sdkAppId = SDKAppID;
    params.roomId = [_roomIdTextField.text intValue];
    params.userId = _userIdTextField.text;
    params.role = TRTCRoleAnchor;
    params.userSig = [GenerateTestUserSig genTestUserSig:params.userId];
    
    [self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE];
    
    TRTCVideoEncParam *videoEncParam = [TRTCVideoEncParam new];
    
    videoEncParam.videoResolution = TRTCVideoResolution_1280_720;
    videoEncParam.videoBitrate = 1500;
    videoEncParam.videoFps = 15;
    
    [self.trtcCloud setVideoEncoderParam:videoEncParam];
    [self.trtcCloud startLocalAudio:TRTCAudioQualityDefault];
}

- (void)destroyTRTCCloud {
    [TRTCCloud destroySharedIntance];
    _trtcCloud = nil;
}

- (void)dealloc {
    [self destroyTRTCCloud];
    [self removeKeyboardObserver];
}

- (BOOL)checkPkRoomAndUserIdIsValid {
    if (_otherRoomIdTextField.text && ![_otherRoomIdTextField.text isEqualToString:@""]) {
        if (_otherUserIdTextField.text && ![_otherUserIdTextField.text isEqualToString:@""]) {
            return true;
        }
    }
    return false;
}

- (void)refreshPkButton {
    if ([_startButton isSelected]) {
        [_connectOtherRoomButton setEnabled:true];
        [_connectOtherRoomButton setBackgroundColor:[UIColor themeGreenColor]];
    } else {
        [_connectOtherRoomButton setEnabled:false];
        [_connectOtherRoomButton setBackgroundColor:[UIColor themeGrayColor]];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}

#pragma mark - IBActions

- (IBAction)onStartClick:(UIButton*)sender {
    sender.selected = !sender.selected;
    if ([sender isSelected]) {
        self.title = [Localize(@"TRTC-API-Example.RoomPk.title") stringByAppendingString:_roomIdTextField.text];
        [self setupTRTCCloud];
    } else {
        [self.trtcCloud exitRoom];
        [self destroyTRTCCloud];
    }
    [self refreshPkButton];
}

- (IBAction)onStartPkClick:(UIButton*)sender {
    sender.selected = !sender.selected;
    if ([sender isSelected] && [self checkPkRoomAndUserIdIsValid]) {
        NSMutableDictionary * jsonDict = [[NSMutableDictionary alloc] init];
        [jsonDict setObject:@([_otherRoomIdTextField.text intValue]) forKey:@"roomId"];
        [jsonDict setObject:_otherUserIdTextField.text forKey:@"userId"];
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:nil];
        NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [self.trtcCloud connectOtherRoom:jsonString];
    } else {
        sender.selected = false;
        [self.trtcCloud disconnectOtherRoom];
    }
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
    if (![userId isEqualToString:_otherUserIdTextField.text]) {
        return;
    }
    if (available) {
        [_trtcCloud startRemoteView:userId streamType:TRTCVideoStreamTypeSmall view:_remoteView];
    } else {
        [_trtcCloud stopRemoteView:userId streamType:TRTCVideoStreamTypeSmall];
    }
}

- (void)onConnectOtherRoom:(NSString *)userId errCode:(TXLiteAVError)errCode errMsg:(NSString *)errMsg {
    if (errCode != ERR_NULL) {
        [self showAlertViewController:Localize(@"TRTC-API-Example.RoomPk.connectRoomError") message:errMsg handler:nil];
        _connectOtherRoomButton.selected = false;
    }
}

@end
