//
//  LiveAnchorViewController.m
//  TRTC-API-Example-OC
//
//  Created by adams on 2021/4/14.
//

/*
 视频互动直播功能 - 主播端示例
 TRTC APP 支持视频互动直播功能
 本文件展示如何集成视频互动直播功能
 1、进入TRTC房间。 API:[self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE];
 2、开启本地视频预览。  API:[self.trtcCloud startLocalPreview:true view:self.view];
 3、切换摄像头：API:[[self.trtcCloud getDeviceManager] switchCamera:!sender.selected];
 4、本地静音：API:[self.trtcCloud muteLocalAudio:sender.selected];
 参考文档：https://cloud.tencent.com/document/product/647/43181
 */

/*
 Interactive Live Video Streaming - Anchor
  The TRTC app supports interactive live video streaming.
  This document shows how to integrate the interactive live video streaming feature.
  1. Enter a room: [self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE]
  2. Enable local video preview: [self.trtcCloud startLocalPreview:true view:self.view]
  3. Switch camera: [[self.trtcCloud getDeviceManager] switchCamera:!sender.selected]
  4. Mute local audio: [self.trtcCloud muteLocalAudio:sender.selected]
  Documentation: https://cloud.tencent.com/document/product/647/43181
 */

#import "LiveAnchorViewController.h"

@interface LiveAnchorViewController () <TRTCCloudDelegate>
@property (weak, nonatomic) IBOutlet UILabel *videoOperatingLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *openCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (weak, nonatomic) IBOutlet UILabel *audioOperatingLabel;

@property (nonatomic, strong) TRTCCloud *trtcCloud;
@end

@implementation LiveAnchorViewController

- (TRTCCloud *)trtcCloud {
    if (!_trtcCloud) {
        _trtcCloud = [TRTCCloud sharedInstance];
    }
    return _trtcCloud;
}

- (instancetype)initWithRoomId:(UInt32)roomId userId:(NSString *)userId {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        [self onEnterRoom:roomId userId:userId];
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUIConfig];
}

- (void)onEnterRoom:(UInt32)roomId userId:(NSString *)userId {
    TRTCParams *params = [[TRTCParams alloc] init];
    params.sdkAppId = SDKAppID;
    params.roomId = roomId;
    params.userId = userId;
    params.userSig = [GenerateTestUserSig genTestUserSig:userId];
    params.role = TRTCRoleAnchor;
    
    self.trtcCloud.delegate = self;
    [self.trtcCloud startLocalPreview:true view:self.view];
    [self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE];
    [self.trtcCloud startLocalAudio:TRTCAudioQualityMusic];
    
    TRTCVideoEncParam *videoEncParam = [[TRTCVideoEncParam alloc] init];
    videoEncParam.videoFps = 24;
    videoEncParam.resMode = TRTCVideoResolutionModePortrait;
    videoEncParam.videoResolution = TRTCVideoResolution_960_540;
    [self.trtcCloud setVideoEncoderParam:videoEncParam];
    
}

- (void)setupDefaultUIConfig {
    self.videoOperatingLabel.text = Localize(@"TRTC-API-Example.LiveAnchor.VideoOptions");
    self.audioOperatingLabel.text = Localize(@"TRTC-API-Example.LiveAnchor.AudioOptions");
    
    [self.changeCameraButton setTitle:Localize(@"TRTC-API-Example.LiveAnchor.rearcamera") forState:UIControlStateNormal];
    [self.changeCameraButton setTitle:Localize(@"TRTC-API-Example.LiveAnchor.frontcamera") forState:UIControlStateSelected];
    [self.openCameraButton setTitle:Localize(@"TRTC-API-Example.LiveAnchor.closecamera") forState:UIControlStateNormal];
    [self.openCameraButton setTitle:Localize(@"TRTC-API-Example.LiveAnchor.opencamera") forState:UIControlStateSelected];
    [self.muteButton setTitle:Localize(@"TRTC-API-Example.LiveAnchor.mute") forState:UIControlStateNormal];
    [self.muteButton setTitle:Localize(@"TRTC-API-Example.LiveAnchor.cancelmute") forState:UIControlStateSelected];
    
    self.videoOperatingLabel.adjustsFontSizeToFitWidth = true;
    self.changeCameraButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.openCameraButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.audioOperatingLabel.adjustsFontSizeToFitWidth = true;
    self.muteButton.titleLabel.adjustsFontSizeToFitWidth = true;
}

#pragma mark - IBActions
- (IBAction)onOpenCameraClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.trtcCloud stopLocalPreview];
    } else {
        [self.trtcCloud startLocalPreview:true view:self.view];
    }
}

- (IBAction)onChangeCameraClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    [[self.trtcCloud getDeviceManager] switchCamera:!sender.selected];
}

- (IBAction)onMuteClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.trtcCloud muteLocalAudio:sender.selected];
}

- (void)dealloc
{
    [self.trtcCloud stopLocalPreview];
    [self.trtcCloud stopLocalAudio];
    [self.trtcCloud exitRoom];
    [TRTCCloud destroySharedIntance];
}

@end
