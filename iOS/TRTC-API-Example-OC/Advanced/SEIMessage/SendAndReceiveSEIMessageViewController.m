//
//  SendAndReceiveSEIMessageViewController.m
//  TRTC-API-Example-OC
//
//  Created by adams on 2021/4/21.
//

/*
 收发SEI消息功能示例
 TRTC APP 支持收发SEI消息功能
 本文件展示如何集成收发SEI消息功能
 1、进入TRTC房间。API:[self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE];
 2、发送SEI消息。 API:[self.trtcCloud sendSEIMsg:SEIData repeatCount:1];
 3、接收SEI消息。 API：TRTCCloudDelegate：- (void)onRecvSEIMsg:(NSString *)userId message:(NSData *)message;
 参考文档：https://cloud.tencent.com/document/product/647/32241
 */
/*
 SEI Message Receiving/Sending
 The TRTC app supports sending and receiving SEI messages.
 This document shows how to integrate the SEI message sending/receiving feature.
 1. Enter a room: [self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE]
 2. Send SEI messages: [self.trtcCloud sendSEIMsg:SEIData repeatCount:1]
 3. Receive SEI messages: TRTCCloudDelegate：- (void)onRecvSEIMsg:(NSString *)userId message:(NSData *)message
 Documentation: https://cloud.tencent.com/document/product/647/32241
 */

#import "SendAndReceiveSEIMessageViewController.h"

static NSString *SEIMessage = @"TRTC-API-Example.SendAndReceiveSEI.SEIMessage";
static const NSInteger RemoteUserMaxNum = 6;

@interface SendAndReceiveSEIMessageViewController () <TRTCCloudDelegate>
@property (weak, nonatomic) IBOutlet UIView *leftRemoteViewA;
@property (weak, nonatomic) IBOutlet UIView *leftRemoteViewB;
@property (weak, nonatomic) IBOutlet UIView *leftRemoteViewC;
@property (weak, nonatomic) IBOutlet UIView *rightRemoteViewA;
@property (weak, nonatomic) IBOutlet UIView *rightRemoteViewB;
@property (weak, nonatomic) IBOutlet UIView *rightRemoteViewC;
@property (weak, nonatomic) IBOutlet UIView *seiMessageView;

@property (weak, nonatomic) IBOutlet UILabel *leftRemoteLabelA;
@property (weak, nonatomic) IBOutlet UILabel *leftRemoteLabelB;
@property (weak, nonatomic) IBOutlet UILabel *leftRemoteLabelC;
@property (weak, nonatomic) IBOutlet UILabel *rightRemoteLabelA;
@property (weak, nonatomic) IBOutlet UILabel *rightRemoteLabelB;
@property (weak, nonatomic) IBOutlet UILabel *rightRemoteLabelC;
@property (weak, nonatomic) IBOutlet UILabel *seiMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *seiMessageDescLabel;

@property (weak, nonatomic) IBOutlet UITextField *roomIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *seiMessageTextField;

@property (weak, nonatomic) IBOutlet UIButton *startPushStreamButton;
@property (weak, nonatomic) IBOutlet UIButton *sendSEIMessageButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textfieldBottomConstraint;

@property (strong, nonatomic) TRTCCloud *trtcCloud;
@property (strong, nonatomic) NSMutableOrderedSet *remoteUserIdSet;

@end

@implementation SendAndReceiveSEIMessageViewController

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
    
    self.roomIdTextField.text = [NSString generateRandomRoomNumber];
    self.userIdTextField.text = [NSString generateRandomUserId];
    self.title = LocalizeReplace(Localize(@"TRTC-API-Example.SetAudioEffect.Title"), self.roomIdTextField.text);
    
    self.roomIdLabel.text = Localize(@"TRTC-API-Example.SendAndReceiveSEI.roomId");
    self.userIdLabel.text = Localize(@"TRTC-API-Example.SendAndReceiveSEI.userId");
    self.seiMessageDescLabel.text = Localize(@"TRTC-API-Example.SendAndReceiveSEI.SEIMessageDesc");
    self.seiMessageTextField.text = Localize(SEIMessage);
    [self.seiMessageTextField addTarget:self action:@selector(textFiledDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.startPushStreamButton setTitle:Localize(@"TRTC-API-Example.SendAndReceiveSEI.startPush") forState:UIControlStateNormal];
    [self.startPushStreamButton setTitle:Localize(@"TRTC-API-Example.SendAndReceiveSEI.stopPush") forState:UIControlStateSelected];
    
    [self.sendSEIMessageButton setTitle:Localize(Localize(@"TRTC-API-Example.SendAndReceiveSEI.SendSEIBtn")) forState:UIControlStateNormal];
    
    self.startPushStreamButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.sendSEIMessageButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
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
    
    self.seiMessageView.layer.borderColor = [UIColor hexColor:@"#ABABAD"].CGColor;
    self.seiMessageView.layer.borderWidth = 0.5;
    self.seiMessageView.alpha = 0;
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

#pragma mark - IBActions
- (IBAction)onSendSEIMessageClick:(UIButton *)sender {
    NSData *SEIData = [self.seiMessageTextField.text  dataUsingEncoding:NSUTF8StringEncoding];
    [self.trtcCloud sendSEIMsg:SEIData repeatCount:1];
    self.seiMessageLabel.text = LocalizeReplace(Localize(@"TRTC-API-Example.SendAndReceiveSEI.SendSEIxx"), self.seiMessageTextField.text);
    [UIView animateWithDuration:1 animations:^{
        self.seiMessageView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.seiMessageView.alpha = 0;
        } completion:nil];
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

- (void)onRecvSEIMsg:(NSString *)userId message:(NSData *)message {
    NSString *SEIMessage = [[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding];
    if (SEIMessage) {
        self.seiMessageLabel.text = LocalizeReplaceTwoCharacter(Localize(@"TRTC-API-Example.SendAndReceiveSEI.ReceiveSEIxxyy"), userId, SEIMessage);
        [UIView animateWithDuration:1 animations:^{
            self.seiMessageView.alpha = 1;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.seiMessageView.alpha = 0;
            } completion:nil];
        }];
    }
}

#pragma mark - UITextField Target
- (void)textFiledDidChange:(UITextField *)textField
{
    NSLog(@"%@", textField.text);
    NSUInteger length = textField.text.length;
    NSLog(@"%ld", length);
    if (length >= 10) {
        textField.text = [textField.text substringToIndex:10];
    }
}

#pragma mark - StartPushStream & StopPushStream
- (void)startPushStream {
    [self.trtcCloud startLocalPreview:true view:self.view];

    self.title = LocalizeReplace(Localize(@"TRTC-API-Example.SendAndReceiveSEI.Title"), self.roomIdTextField.text);
    TRTCParams *params = [[TRTCParams alloc] init];
    params.sdkAppId = SDKAppID;
    params.roomId = [self.roomIdTextField.text intValue];
    params.userId = self.userIdTextField.text;
    params.userSig = [GenerateTestUserSig genTestUserSig:self.userIdTextField.text];
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
    [self.userIdTextField resignFirstResponder];
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
