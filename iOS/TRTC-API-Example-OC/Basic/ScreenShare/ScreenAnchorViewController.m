//
//  ScreenAnchorViewController.m
//  TRTC-API-Example-OC
//
//  Created by bluedang on 2021/4/15.
//

/*
录屏直播功能
 TRTC APP 录屏直播功能
 本文件展示如何集成录屏直播功能
 1、开始屏幕分享 API:    [self.trtcCloud startScreenCaptureByReplaykit:_encParams
                            appGroup:@"group.com.tencent.liteav.RPLiveStreamShare"];
 2、静音 API: [_trtcCloud muteLocalAudio:true];
 参考文档：https://cloud.tencent.com/document/product/647/45750
 */

/*
 Screen Recording Live Streaming
 The TRTC app supports screen recording live streaming.
 This document shows how to integrate the screen recording live streaming feature.
 1. Start screen sharing: [self.trtcCloud startScreenCaptureByReplaykit:_encParams
                             appGroup:@"group.com.tencent.liteav.RPLiveStreamShare"]
 2. Mute: [_trtcCloud muteLocalAudio:true]
 Documentation: https://cloud.tencent.com/document/product/647/45750
 */

#import "ScreenAnchorViewController.h"
#import "TRTCBroadcastExtensionLauncher.h"

typedef NS_ENUM(NSInteger, ScreenStatus) {
    ScreenStart,
    ScreenWait,
    ScreenStop,
};

@interface ScreenAnchorViewController ()<TRTCCloudDelegate>
@property (weak, nonatomic) IBOutlet UILabel *roomIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *resolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *startScreenButton;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;

@property (strong, nonatomic) TRTCCloud *trtcCloud;
@property (strong, nonatomic) TRTCVideoEncParam *encParams;

@property (assign, nonatomic) ScreenStatus status;
@end

@implementation ScreenAnchorViewController

- (TRTCCloud*)trtcCloud {
    if (!_trtcCloud) {
        _trtcCloud = [TRTCCloud sharedInstance];
    }
    return _trtcCloud;
}

- (TRTCVideoEncParam *)encParams {
    if (!_encParams) {
        _encParams = [TRTCVideoEncParam new];
    }
    return _encParams;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.status = ScreenStop;
    
    self.trtcCloud.delegate = self;
    [self setupDefaultUIConfig];
    [self setupTRTCCloud];
}

- (void)setupDefaultUIConfig {
    self.title = Localize(@"TRTC-API-Example.ScreenAnchor.Title");
    _roomIdLabel.text = [Localize(@"TRTC-API-Example.ScreenAnchor.RoomNumber") stringByAppendingString:[@(_roomId) stringValue]];
    _userIdLabel.text = [Localize(@"TRTC-API-Example.ScreenAnchor.UserName") stringByAppendingString:_userId];
    _resolutionLabel.text = Localize(@"TRTC-API-Example.ScreenAnchor.Resolution");
    _tipLabel.text = Localize(@"TRTC-API-Example.ScreenAnchor.Description");
    [_startScreenButton setTitle:Localize(@"TRTC-API-Example.ScreenAnchor.BeginScreenShare") forState:UIControlStateNormal];
    [_muteButton setTitle:Localize(@"TRTC-API-Example.ScreenAnchor.cancelMute") forState:UIControlStateSelected];
    [_muteButton setTitle:Localize(@"TRTC-API-Example.ScreenAnchor.mute") forState:UIControlStateNormal];
    _roomIdLabel.adjustsFontSizeToFitWidth = true;
    _resolutionLabel.adjustsFontSizeToFitWidth = true;
    _tipLabel.adjustsFontSizeToFitWidth = true;
    _startScreenButton.titleLabel.adjustsFontSizeToFitWidth = true;
    _muteButton.titleLabel.adjustsFontSizeToFitWidth = true;
}

-(void)setupTRTCCloud {
    TRTCParams *params = [TRTCParams new];
    params.sdkAppId = SDKAppID;
    params.roomId = _roomId;
    params.userId = _userId;
    params.role = TRTCRoleAnchor;
    params.userSig = [GenerateTestUserSig genTestUserSig:params.userId];
    
    
    _encParams.videoResolution = TRTCVideoResolution_1280_720;
    _encParams.videoBitrate = 550;
    _encParams.videoFps = 10;
    
    [self.trtcCloud startLocalAudio:TRTCAudioQualityMusic];
    [self.trtcCloud startScreenCaptureByReplaykit:_encParams
                                         appGroup:@"group.com.tencent.liteav.RPLiveStreamShare"];
    
    [self.trtcCloud enterRoom:params appScene:TRTCAppSceneVideoCall];
}

- (void)dealloc {
    [self.trtcCloud exitRoom];
    [TRTCCloud destroySharedIntance];
}

#pragma mark - IBActions
- (IBAction)onScreenCaptureClick:(id)sender {
    switch (_status) {
        case ScreenStart:
            [self.trtcCloud stopScreenCapture];
            break;
        case ScreenStop:
            [self.trtcCloud startScreenCaptureByReplaykit:_encParams
                                                 appGroup:@"group.com.tencent.liteav.RPLiveStreamShare"];
            [TRTCBroadcastExtensionLauncher launch];
            [_startScreenButton setTitle:Localize(@"TRTC-API-Example.ScreenAnchor.WaitScreenShare")
                                forState:UIControlStateNormal];
            break;
        case ScreenWait:
            [TRTCBroadcastExtensionLauncher launch];
            break;
        default:
            break;
    }
    
}
- (IBAction)onMicCaptureClick:(UIButton*)sender {
    sender.selected = !sender.selected;
    if (sender.isSelected) {
        [_trtcCloud muteLocalAudio:true];
    } else {
        [_trtcCloud muteLocalAudio:false];
    }
}

# pragma mark - TRTCCloud Delegate

- (void)onScreenCaptureStarted {
    _status = ScreenStart;
    [_startScreenButton setTitle:Localize(@"TRTC-API-Example.ScreenAnchor.StopScreenShare")
                        forState:UIControlStateNormal];
}

- (void)onScreenCaptureStoped:(int)reason {
    _status = ScreenStop;
    [_startScreenButton setTitle:Localize(@"TRTC-API-Example.ScreenAnchor.BeginScreenShare")
                        forState:UIControlStateNormal];
}

@end
