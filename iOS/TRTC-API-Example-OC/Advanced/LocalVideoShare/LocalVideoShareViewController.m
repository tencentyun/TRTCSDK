//
//  LocalVideoShareViewController.m
//  TRTC-API-Example-OC
//
//  Created by bluedang on 2021/4/22.
//

/*
 本地视频分享功能
 TRTC 本地视频分享
 
 本文件展示如何集成本地视频分享

 1、设置自定义视频发送 API: [self.trtcCloud enableCustomVideoCapture:true];
 2、设置自定义音频发送 API: [self.trtcCloud enableCustomAudioCapture:true];
 3、发送自定义视频 API: [self.trtcCloud sendCustomVideoData:videoFrame];
 4、发送自定义音频 API: [self.trtcCloud sendCustomAudioData:audioFrame];
 
 参考文档：https://cloud.tencent.com/document/product/647/32258
 */
/*
 Sharing Local Video
 TRTC Local Video Sharing

 This document shows how to integrate the local video sharing feature.

 1. Enable custom video capturing: [self.trtcCloud enableCustomVideoCapture:true]
 2. Enable custom audio capturing: [self.trtcCloud enableCustomAudioCapture:true]
 3. Send custom video: [self.trtcCloud sendCustomVideoData:videoFrame]
 4. Send custom audio: [self.trtcCloud sendCustomAudioData:audioFrame]

 Documentation: https://cloud.tencent.com/document/product/647/32258
 */

#import "LocalVideoShareViewController.h"
#import "CustomFrameRender.h"
#import "MediaFileSyncReader.h"
#import "AudioQueuePlay.h"

static const NSInteger maxRemoteUserNum = 6;

@interface LocalVideoShareViewController () <TRTCCloudDelegate, TRTCVideoRenderDelegate,
    TRTCAudioFrameDelegate, MediaFileSyncReaderDelegate,
    UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *videoFileLable;
@property (weak, nonatomic) IBOutlet UILabel *roomIdLable;

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *chooseVideoButton;
@property (weak, nonatomic) IBOutlet UITextField *roomIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *localFileTextField;

@property (strong, nonatomic) IBOutlet UIImageView *localVideoView;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *remoteUserIdLabelArr;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *remoteViewArr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (strong, nonatomic) NSMutableOrderedSet *remoteUidSet;

@property (strong, nonatomic) NSURL* videoURL;
@property (strong, nonatomic) TRTCCloud* trtcCloud;
@property (strong, nonatomic) MediaFileSyncReader *mediaReader;
@property (strong, nonatomic) AudioQueuePlay* audioPlayer;
@property (strong, nonatomic) dispatch_queue_t audioPlayerQueue;

@end

@implementation LocalVideoShareViewController

- (TRTCCloud*)trtcCloud {
    if (!_trtcCloud) {
        _trtcCloud = [TRTCCloud sharedInstance];
    }
    return _trtcCloud;
}

- (NSMutableOrderedSet *)remoteUidSet {
    if (!_remoteUidSet) {
        _remoteUidSet = [[NSMutableOrderedSet alloc] initWithCapacity:maxRemoteUserNum];
    }
    return _remoteUidSet;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.trtcCloud.delegate = self;
    [self.trtcCloud setLocalVideoRenderDelegate:self
                                pixelFormat:TRTCVideoPixelFormat_NV12
                                 bufferType:TRTCVideoBufferType_PixelBuffer];
    [self.trtcCloud setAudioFrameDelegate:self];

    [self setupRandomId];
    [self setupDefaultUIConfig];
    [self setupRemoteViews];
    
    dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_DEFAULT, 0);
    _audioPlayerQueue = dispatch_queue_create("com.media.audioplayer", attr);
}

- (void)setupDefaultUIConfig {
    self.title = [Localize(@"TRTC-API-Example.LocalVideoShare.Title")
                  stringByAppendingString:_roomIdTextField.text];

    _roomIdLable.text = Localize(@"TRTC-API-Example.LocalVideoShare.roomId");
    _videoFileLable.text = Localize(@"TRTC-API-Example.LocalVideoShare.chooseLocalVideo");
    [_startButton setTitle:Localize(@"TRTC-API-Example.LocalVideoShare.start")
                  forState:UIControlStateNormal];
    [_startButton setTitle:Localize(@"TRTC-API-Example.LocalVideoShare.stop")
                  forState:UIControlStateSelected];
    [_chooseVideoButton setTitle:Localize(@"TRTC-API-Example.LocalVideoShare.choose")
                        forState:UIControlStateNormal];
    
    _roomIdLable.adjustsFontSizeToFitWidth = true;
    _videoFileLable.adjustsFontSizeToFitWidth = true;
    _roomIdLable.adjustsFontSizeToFitWidth = true;
    _startButton.titleLabel.adjustsFontSizeToFitWidth = true;
    _chooseVideoButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    [self addKeyboardObserver];
}

- (void)setupRandomId {
    _roomIdTextField.text = [NSString generateRandomRoomNumber];
}

- (void)setupTRTCCloud {
    TRTCParams *params = [TRTCParams new];
    
    params.sdkAppId = SDKAppID;
    params.roomId = [_roomIdTextField.text intValue];
    params.userId = @"4123567";
    params.role = TRTCRoleAnchor;
    params.userSig = [GenerateTestUserSig genTestUserSig:params.userId];
    
    [self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE];
    
    TRTCVideoEncParam *encParams = [TRTCVideoEncParam new];
    encParams.videoResolution = TRTCVideoResolution_480_270;
    encParams.videoBitrate = 550;
    encParams.videoFps = 10;
    
    [self.trtcCloud setVideoEncoderParam:encParams];
    
    [self.trtcCloud enableCustomVideoCapture:true];
    [self.trtcCloud enableCustomAudioCapture:true];
    [self.mediaReader start];
    [self.audioPlayer start];
}

- (void)setupRemoteViews {
    for (NSInteger i = 0; i < maxRemoteUserNum; i++) {
        [_remoteViewArr[i] setHidden:true];
        [_remoteUserIdLabelArr[i] setHidden:true];
    }
}

- (void)destroyTRTCCloud {
    [CustomFrameRender clearImageView:self.localVideoView];
    [self.mediaReader stop];
    [self.audioPlayer stop];
    
    [TRTCCloud destroySharedIntance];
    _trtcCloud = nil;
}

- (void)dealloc {
    [self destroyTRTCCloud];
    [self removeKeyboardObserver];
}

- (BOOL)checkVideoURLIsValid {
    if (self.videoURL) {
        return true;
    }
    return false;
}

- (void)hidenRemoteViewAndLabels {
    for (NSInteger i = 0; i < maxRemoteUserNum; i++) {
        [_remoteViewArr[i] setHidden:true];
        [_remoteUserIdLabelArr[i] setHidden:true];
    }
}

#pragma mark - IBActions

- (IBAction)onChooseVideoClick:(id)sender {
    UIImagePickerController *picker=[[UIImagePickerController alloc] init];
    [picker setDelegate:self];
    picker.allowsEditing = NO;
    picker.mediaTypes = [NSArray arrayWithObjects:@"public.movie", nil];
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)onStartClick:(UIButton*)sender {
    if (![self checkVideoURLIsValid]) {
        [self showAlertViewController:Localize(@"TRTC-API-Example.LocalVideoShare.chooseLocalVideo")
                              message:nil handler:nil];
        return;
    }
    sender.selected = !sender.selected;
    if ([sender isSelected]) {
        self.title = [Localize(@"TRTC-API-Example.LocalVideoShare.Title")
                      stringByAppendingString:_roomIdTextField.text];
        [self setupTRTCCloud];
        [self.chooseVideoButton setEnabled:false];
        [self.chooseVideoButton setBackgroundColor:[UIColor themeGrayColor]];
    } else {
        [self.remoteUidSet removeAllObjects];
        [self hidenRemoteViewAndLabels];
        [self.chooseVideoButton setEnabled:true];
        [self.chooseVideoButton setBackgroundColor:[UIColor themeGreenColor]];
        [self.trtcCloud exitRoom];
        [self destroyTRTCCloud];
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
        [_remoteUserIdLabelArr[index] setHidden:false];
        [_remoteUserIdLabelArr[index] setText:userId];
        [_trtcCloud startRemoteView:userId streamType:TRTCVideoStreamTypeSmall
                               view:_remoteViewArr[index++]];
    }
    for (NSInteger i = index; i < maxRemoteUserNum; i++) {
        [_remoteViewArr[i] setHidden:true];
        [_remoteUserIdLabelArr[i] setHidden:true];
    }
}

#pragma mark - TRTCVideoRenderDelegate

- (void)onRenderVideoFrame:(TRTCVideoFrame *)frame userId:(NSString *)userId
                streamType:(TRTCVideoStreamType)streamType {
    CFRetain(frame.pixelBuffer);
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (![strongSelf.startButton isSelected]) {
            return;
        }
        [CustomFrameRender renderImageBuffer:frame.pixelBuffer forView:strongSelf.localVideoView];
        CFRelease(frame.pixelBuffer);
    });
}

#pragma mark - TRTCAudioFrameDelegate

- (void)onMixedAllAudioFrame:(TRTCAudioFrame *)frame {
    __weak typeof(self) weakSelf = self;
    NSData* data = frame.data;
    dispatch_async(_audioPlayerQueue, ^{
        [weakSelf.audioPlayer playWithData:data];
    });
}

#pragma mark - MediaFileSyncReader Delegate
- (void)onReadVideoFrameAtFrameIntervals:(CVImageBufferRef)imageBuffer timeStamp:(UInt64)timeStamp {
    TRTCVideoFrame* videoFrame = [TRTCVideoFrame new];
    videoFrame.bufferType = TRTCVideoBufferType_PixelBuffer;
    videoFrame.pixelFormat = TRTCVideoPixelFormat_NV12;
    videoFrame.pixelBuffer = imageBuffer;
    TRTCVideoRotation rotation = TRTCVideoRotation_0;
    if (self.mediaReader.angle == 90) {
        rotation = TRTCVideoRotation_90;
    }
    else if (self.mediaReader.angle == 180) {
        rotation = TRTCVideoRotation_180;
    }
    else if (self.mediaReader.angle == 270) {
        rotation = TRTCVideoRotation_270;
    }
    videoFrame.rotation = rotation;
    videoFrame.timestamp = timeStamp;

    [self.trtcCloud sendCustomVideoData:videoFrame];
}

- (void)onReadAudioFrameAtFrameIntervals:(NSData *)pcmData timeStamp:(UInt64)timeStamp {
    TRTCAudioFrame *audioFrame = [TRTCAudioFrame new];
    audioFrame.channels = _mediaReader.audioChannels;
    audioFrame.sampleRate = _mediaReader.audioSampleRate;
    audioFrame.data = pcmData;
    audioFrame.timestamp = timeStamp;
    
    [self.trtcCloud sendCustomAudioData:audioFrame];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.movie"]){
        NSURL *url = info[UIImagePickerControllerMediaURL];//获得视频的URL
        self.videoURL = url;
        _localFileTextField.text = url.lastPathComponent;
        
        self.mediaReader = nil;
        self.mediaReader = [[MediaFileSyncReader alloc] initWithAVAsset:[AVAsset assetWithURL:self.videoURL]];
        [self.mediaReader setDelegate:self];
        
        self.audioPlayer = nil;
        self.audioPlayer = [[AudioQueuePlay alloc] init];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
