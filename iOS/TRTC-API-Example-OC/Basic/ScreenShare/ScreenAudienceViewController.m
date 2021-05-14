//
//  ScreenAudienceViewController.m
//  TRTC-API-Example-OC
//
//  Created by bluedang on 2021/4/15.
//


#import "ScreenAudienceViewController.h"

@interface ScreenAudienceViewController () <TRTCCloudDelegate>
@property (weak, nonatomic) IBOutlet UIView *remoteView;
@property (strong, nonatomic) TRTCCloud *trtcCloud;
@end

@implementation ScreenAudienceViewController


- (TRTCCloud*)trtcCloud {
    if (!_trtcCloud) {
        _trtcCloud = [TRTCCloud sharedInstance];
    }
    return _trtcCloud;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [Localize(@"TRTC-API-Example.ScreenAudience.Title")
                  stringByAppendingString: [@(_roomId) stringValue]];
    
    self.trtcCloud.delegate = self;

    TRTCParams *params = [TRTCParams new];
    params.sdkAppId = SDKAppID;
    params.roomId = _roomId;
    params.userId = _userId;
    params.role = TRTCRoleAudience;
    params.userSig = [GenerateTestUserSig genTestUserSig:params.userId];
    
    [self.trtcCloud startLocalAudio:TRTCAudioQualityMusic];
    [self.trtcCloud enterRoom:params appScene:TRTCAppSceneVideoCall];
}

- (void)dealloc {
    [self.trtcCloud exitRoom];
    [TRTCCloud destroySharedIntance];
}

#pragma mark - TRTCCloud Delegate

- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available {
    if (available) {
        [_remoteView setHidden:false];
        [_trtcCloud startRemoteView:userId streamType:TRTCVideoStreamTypeBig
                           view:_remoteView];
    } else {
        [_remoteView setHidden:true];
    }
}

@end
