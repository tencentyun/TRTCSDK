//
//  LocalRecordViewController.m
//  TRTC-API-Example-OC
//
//  Created by adams on 2021/4/21.
//

/*
 本地媒体录制示例
 TRTC APP 支持本地媒体录制功能
 本文件展示如何集成本地媒体录制功能
 1、进入TRTC房间。 API:[self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE];
 2、开启本地录制。  API:[self.trtcCloud startLocalRecording];
 3、结束本地录制。  API:[self.trtcCloud stopLocalRecording];
 参考文档：https://cloud.tencent.com/document/product/647/32258
 */
/*
 Local Recording
 The TRTC app supports local recording.
 This document shows how to integrate the local recording feature.
 1. Enter a room: [self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE]
 2. Start local recording: [self.trtcCloud startLocalRecording]
 3. Stop local recording: [self.trtcCloud stopLocalRecording]
 Documentation: https://cloud.tencent.com/document/product/647/32258
 */

#import "LocalRecordViewController.h"
#import <PhotosUI/PhotosUI.h>

@interface LocalRecordViewController () <TRTCCloudDelegate>
@property (weak, nonatomic) IBOutlet UILabel *recordLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomIdLabel;

@property (weak, nonatomic) IBOutlet UITextField *recordAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *roomIdTextField;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *pushStreamButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (assign, nonatomic) BOOL isStartPushStream;
@property (assign, nonatomic) BOOL isRecording;
@property (strong, nonatomic) TRTCCloud *trtcCloud;

@end

@implementation LocalRecordViewController

- (TRTCCloud *)trtcCloud {
    if (!_trtcCloud) {
        _trtcCloud = [TRTCCloud sharedInstance];
    }
    return _trtcCloud;
}

- (void)setIsRecording:(BOOL)isRecording {
    _isRecording = !isRecording;
    self.recordButton.selected = isRecording;
    [self.recordAddressTextField setUserInteractionEnabled:!isRecording];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.trtcCloud.delegate = self;
    [self setupDefaultUIConfig];
    [self addKeyboardObserver];
}

- (void)setupDefaultUIConfig {
    [self.recordLabel setHidden: true];
    self.recordAddressLabel.text = Localize(@"TRTC-API-Example.LocalRecord.recordFileAddress");
    self.roomIdLabel.text = Localize(@"TRTC-API-Example.LocalRecord.roomId");
    [self.recordButton setTitle:Localize(@"TRTC-API-Example.LocalRecord.startRecord") forState:UIControlStateNormal];
    [self.recordButton setTitle:Localize(@"TRTC-API-Example.LocalRecord.stopRecord") forState:UIControlStateSelected];
    [self.recordButton setBackgroundColor:UIColor.themeGrayColor];
    [self.recordButton setUserInteractionEnabled:false];
    
    [self.pushStreamButton setTitle:Localize(@"TRTC-API-Example.LocalRecord.startPush") forState:UIControlStateNormal];
    [self.pushStreamButton setTitle:Localize(@"TRTC-API-Example.LocalRecord.stopPush") forState:UIControlStateSelected];
    self.roomIdTextField.text = [NSString generateRandomRoomNumber];
    self.title = LocalizeReplace(Localize(@"TRTC-API-Example.LocalRecord.Title"), self.roomIdTextField.text);
    self.isStartPushStream = false;
    self.isRecording = false;
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
- (IBAction)onRecordClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self startRecord];
    } else {
        [self stopRecord];
    }
}

- (IBAction)onStartPushStreamClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self startPushStream];
        self.isStartPushStream = true;
    } else {
        [self stopPushStream];
        self.isStartPushStream = false;
    }
    
    if (self.recordAddressTextField.text.length > 0 && self.isStartPushStream) {
        [self.recordButton setBackgroundColor:UIColor.themeGreenColor];
        [self.recordButton setUserInteractionEnabled:true];
    } else {
        [self.recordButton setBackgroundColor:UIColor.themeGrayColor];
        [self.recordButton setUserInteractionEnabled:false];
    }
}

#pragma mark - StartPushStream & StopPushStream
- (void)startPushStream {
    UInt32 roomId = [self.roomIdTextField.text intValue];
    self.title = LocalizeReplace(Localize(@"TRTC-API-Example.LocalRecord.Title"), self.roomIdTextField.text);
   
    [self.trtcCloud startLocalPreview:true view:self.view];

    TRTCParams *params = [[TRTCParams alloc] init];
    params.sdkAppId = SDKAppID;
    params.roomId = roomId;
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
    [self.trtcCloud stopLocalPreview];
    [self.trtcCloud stopLocalAudio];
    [self.trtcCloud exitRoom];
}

#pragma mark - StartRecord & StopRecord
- (void)startRecord {
    NSString *fileName = self.recordAddressTextField.text;
    if (![fileName hasSuffix:@".mp4"]) {
        fileName = [NSString stringWithFormat:@"%@.mp4",fileName];
    }
    
    NSArray * path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString * cachePath = [path lastObject];
    NSString * filePath = [cachePath stringByAppendingPathComponent:fileName];
    
    TRTCLocalRecordingParams *recordParams = [[TRTCLocalRecordingParams alloc] init];
    recordParams.interval = 1000;
    recordParams.filePath = filePath;
    recordParams.recordType = TRTCRecordTypeBoth;
    [self.trtcCloud startLocalRecording:recordParams];
    self.isRecording = true;
}

- (void)stopRecord {
    [self.trtcCloud stopLocalRecording];
    self.isRecording = false;
}

#pragma mark - TRTCCloudDelegate
- (void)onLocalRecordBegin:(NSInteger)errCode storagePath:(NSString *)storagePath {
    NSLog(@"onLocalRecordBegin - errCode = %ld, storagePath = %@",(long)errCode,storagePath);
}

- (void)onLocalRecording:(NSInteger)duration storagePath:(NSString *)storagePath {
    NSInteger second = duration / 1000;
    NSLog(@"onLocalRecording - duration = %ld, storagePath = %@",second,storagePath);
    NSInteger sec = 0;
    NSInteger min = 0;
    NSInteger hor = 0;
    sec = second % 60;
    min = second / 60;
    if (min >= 60) {
        hor = second / (60 * 60);
        min %= min;
    }
    [self.recordLabel setHidden: false];
    self.recordLabel.text = LocalizeReplace(Localize(@"TRTC-API-Example.LocalRecord.recordingxx"), [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld",hor,min,sec]);
}

- (void)onLocalRecordComplete:(NSInteger)errCode storagePath:(NSString *)storagePath {
    NSLog(@"onLocalRecordComplete - errCode = %ld, storagePath = %@",errCode,storagePath);
    self.isRecording = false;
    [self.recordLabel setHidden: true];
    self.recordLabel.text = @"";
    
    __weak typeof(self)weakSelf = self;
    [self requestPhotoAuthorization:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
        [photoLibrary performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL
        fileURLWithPath:storagePath]];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf showAlertViewController:Localize(@"TRTC-API-Example.LocalRecord.recordSuccess") message:Localize(@"TRTC-API-Example.LocalRecord.recordSuccessPath") handler:nil];
                });
            }
        }];
    }];
}

- (void)dealloc {
    [self removeKeyboardObserver];
    [self.trtcCloud stopLocalPreview];
    [self.trtcCloud stopLocalAudio];
    [self.trtcCloud exitRoom];
    [self.trtcCloud stopLocalRecording];
    [TRTCCloud destroySharedIntance];
}

@end
