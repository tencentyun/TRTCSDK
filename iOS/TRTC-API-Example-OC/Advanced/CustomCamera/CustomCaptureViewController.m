//
//  CustomCaptureViewController.m
//  TRTC-API-Example-OC
//
//  Created by abyyxwang on 2021/4/22.
//

/*
 自定义视屏采集和渲染示例
 TRTC APP 支持自定义视频数据采集, 本文件展示如何发送自定义采集数据
 1、进入TRTC房间。    API:[self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE];
 2、打开自定义采集功能。API:[self.trtcCloud enableCustomVideoCapture:YES];
 3、发送自定义采集数据。API:[self.trtcCloud enableCustomVideoCapture:YES];
 更多细节，详见：https://cloud.tencent.com/document/product/647/34066
 */
/*
 Custom Video Capturing and Rendering
 The TRTC app supports custom video capturing and rendering. This document shows how to send custom video data.
 1. Enter a room: [self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE]
 2. Enable custom video capturing: [self.trtcCloud enableCustomVideoCapture:YES]
 3. Send custom video data: [self.trtcCloud enableCustomVideoCapture:YES]
 For more information, please see https://cloud.tencent.com/document/product/647/34066
*/

#import "CustomCaptureViewController.h"
#import "CustomCameraHelper.h"
#import "CustomCameraFrameRender.h"


static const NSInteger maxRemoteUserNum = 6;

@interface CustomCaptureViewController ()<
CustomCameraHelperSampleBufferDelegate,
TRTCCloudDelegate,
TRTCVideoRenderDelegate
>
@property (weak, nonatomic) IBOutlet UIButton *startPushButton;
@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBtnConstraint;

@property (weak, nonatomic) IBOutlet UIImageView* previewView;
@property (strong, nonatomic) CustomCameraHelper *cameraHelper;
@property (strong, nonatomic) CustomCameraFrameRender *customFrameRender;

@property (strong, nonatomic) TRTCCloud *trtcCloud;
@property (strong, nonatomic) NSMutableArray<NSString *> *remoteUserIDArr;

@end

@implementation CustomCaptureViewController

- (TRTCCloud *)trtcCloud {
    if (!_trtcCloud) {
        _trtcCloud = [TRTCCloud sharedInstance];
    }
    return _trtcCloud;
}

- (NSMutableArray<NSString *> *)remoteUserIDArr {
    if (!_remoteUserIDArr) {
        _remoteUserIDArr = [NSMutableArray array];
    }
    return _remoteUserIDArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUIConfig];
    [self.cameraHelper createSession];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.cameraHelper startCameraCapture];
    [self.customFrameRender start:nil videoView:self.previewView];
    [self addKeyboardObserver];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.cameraHelper stopCameraCapture];
    [self.customFrameRender stop];
    [self removeKeyboardObserver];
}

- (void)setupDefaultUIConfig {
    self.cameraHelper = [[CustomCameraHelper alloc] init];
    self.customFrameRender = [[CustomCameraFrameRender alloc] init];
    if (@available(iOS 13.0, *)) {
        self.cameraHelper.windowOrientation = self.view.window.windowScene.interfaceOrientation;
    } else {
        self.cameraHelper.windowOrientation = UIInterfaceOrientationPortrait;
    }
    self.cameraHelper.delegate = self;
    self.roomIDLabel.text = Localize(@"TRTC-API-Example.CustomCamera.roomId");
    self.userIDLabel.text = Localize(@"TRTC-API-Example.CustomCamera.userId");
    self.roomIDTextField.text = [NSString generateRandomRoomNumber];
    self.userIDTextField.text= [NSString generateRandomUserId];
    UIImage *backgroundImage = [[UIColor themeGreenColor] trans2Image:CGSizeMake(1, 1)];
    [self.startPushButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [self.startPushButton setTitle:Localize(@"TRTC-API-Example.CustomCamera.startPush")
                          forState:UIControlStateNormal];
    [self.startPushButton setTitle:Localize(@"TRTC-API-Example.CustomCamera.stopPush") forState:UIControlStateSelected];
    [self refreshViewTitle];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (self.roomIDTextField.isFirstResponder) {
        [self.roomIDTextField resignFirstResponder];
    }
    if (self.userIDTextField.isFirstResponder) {
        [self.userIDTextField resignFirstResponder];
    }
}

- (void)refreshViewTitle {
    self.title = LocalizeReplace(Localize(@"TRTC-API-Example.CustomCamera.viewTitle"), self.roomIDTextField.text);
}

- (IBAction)startPushTRTC:(UIButton *)sender {
    if (self.roomIDTextField.text.length == 0) {
        return;
    }
    if (self.userIDTextField.text.length == 0) {
        return;
    }
    sender.selected = !sender.selected;
    sender.enabled = NO;
    if (sender.selected) {
        [self refreshViewTitle];
        [self enterRoom];
    } else {
        [self exitRoom];
    }
}


- (void)enterRoom {
    // Enter trtc room.
    TRTCParams *params = [[TRTCParams alloc] init];
    params.sdkAppId = SDKAppID;
    params.roomId = [self.roomIDTextField.text intValue];
    params.userId = self.userIDTextField.text;
    params.userSig = [GenerateTestUserSig genTestUserSig:self.userIDTextField.text];
    params.role = TRTCRoleAnchor;
    self.trtcCloud.delegate = self;
    [self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE];
    [self.trtcCloud startLocalAudio:TRTCAudioQualityMusic];
    // Enable custom video Capture.
    [self.trtcCloud enableCustomVideoCapture:YES];
    [self.trtcCloud setLocalVideoRenderDelegate:self
                                    pixelFormat:TRTCVideoPixelFormat_NV12
                                     bufferType:TRTCVideoBufferType_PixelBuffer];
}

- (void)exitRoom {
    [self.trtcCloud exitRoom];
}

#pragma mark - Keyboard Observer
- (BOOL)keyboardWillShow:(NSNotification *)noti {
    CGFloat animationDuration = [[[noti userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardBounds = [[[noti userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:animationDuration animations:^{
        self.bottomBtnConstraint.constant = keyboardBounds.size.height;
        [self.view layoutIfNeeded];
    }];
    return YES;
}

- (BOOL)keyboardWillHide:(NSNotification *)noti {
     CGFloat animationDuration = [[[noti userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
     [UIView animateWithDuration:animationDuration animations:^{
         self.bottomBtnConstraint.constant = 20;
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

#pragma mark - CustomCameraHelperSampleBufferDelegate
-(void)onVideoSampleBuffer:(CMSampleBufferRef)videoBuffer {
    TRTCVideoFrame *videoFrame = [[TRTCVideoFrame alloc] init];
    videoFrame.bufferType = TRTCVideoBufferType_PixelBuffer;
    videoFrame.pixelFormat = TRTCVideoPixelFormat_NV12;
    videoFrame.pixelBuffer = CMSampleBufferGetImageBuffer(videoBuffer);
    [self.trtcCloud sendCustomVideoData:videoFrame];
}

- (void)refreshRemoteVideoViews {
    [self.remoteUserIDArr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger tag = 3001 + idx;
        UIView *view = [self.view viewWithTag:tag];
        if (view) {
            [self.trtcCloud startRemoteView:obj streamType:TRTCVideoStreamTypeSmall view:view];
        }
    }];
}

#pragma mark - TRTCCloudDelegate
-(void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available {
    if (available) {
        if (self.remoteUserIDArr.count >= maxRemoteUserNum) {
            return;
        }
        if (![self.remoteUserIDArr containsObject:userId]) {
            [self.remoteUserIDArr addObject:userId];
            [self refreshRemoteVideoViews];
        }
    } else {
        if ([self.remoteUserIDArr containsObject:userId]) {
            NSInteger index = [self.remoteUserIDArr indexOfObject:userId];
            NSInteger tag = 3001 + index;
            UIView *view = [self.view viewWithTag:tag];
            if (view) {
                [self.trtcCloud stopRemoteView:userId streamType:TRTCVideoStreamTypeSmall];
            }
            [self.remoteUserIDArr removeObject:userId];
        }
    }
}

- (void)onExitRoom:(NSInteger)reason {
    [self.customFrameRender stop];
    if (!self.startPushButton.isEnabled) {
        self.startPushButton.enabled = YES;
    }
}

- (void)onEnterRoom:(NSInteger)result {
    if (!self.startPushButton.isEnabled) {
        self.startPushButton.enabled = YES;
    }
}

- (void)onRenderVideoFrame:(TRTCVideoFrame *)frame userId:(NSString *)userId streamType:(TRTCVideoStreamType)streamType {
    [self.customFrameRender onRenderVideoFrame:frame userId:userId streamType:streamType];
}

                                                                        
@end
