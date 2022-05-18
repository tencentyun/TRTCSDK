//
//  ThirdBeautyTencentEffectViewController.m
//  TRTC-API-Example-OC
//
//  Created by summer on 2022/5/11.
//  Copyright © 2022 Tencent. All rights reserved.
//

/*
 第三方美颜功能示例
 接入步骤：
 第一步：集成腾讯特效SDK并拷贝资源（可参考腾讯特效提供的接入文档：https://cloud.tencent.com/document/product/616/65887 ）
 第二步：腾讯特效SDK的鉴权与初始化,详见[self setupBeautySDK],License获取请参考 {https://cloud.tencent.com/document/product/616/65878}
 第三步：在TRTC中使用腾讯特效美颜，详见[self.trtcCloud setLocalVideoProcessDelegete:self pixelFormat:TRTCVideoPixelFormat_Texture_2D bufferType:TRTCVideoBufferType_Texture]
 
 注意：腾讯特效提供的 License 与 applicationId 一一对应的，测试过程中需要修改 applicationId 为 License对应的applicationId
 
 Access steps：
 First step：Integrate Tencent Effect SDK and copy resources（You can refer to the access document provided by Tencent Effects：https://cloud.tencent.com/document/product/616/65888）
 Second step：Authentication and initialization of Tencent Effect SDK,
 see details[self setupBeautySDK],to obtain the license, please refer to {https://cloud.tencent.com/document/product/616/65878}
 Third step：Using Tencent Effect in TRTC，see details[self.trtcCloud setLocalVideoProcessDelegete:self pixelFormat:TRTCVideoPixelFormat_Texture_2D bufferType:TRTCVideoBufferType_Texture]
 
 Note：The applicationId and License provided by Tencent Effects are in one-to-one correspondence.
 During the test process, the applicationId needs to be modified to the applicationId corresponding to the License.
 */

#import "ThirdBeautyTencentEffectViewController.h"
//#import "XMagic.h"
//#import "TELicenseCheck.h"

static const NSInteger RemoteUserMaxNum = 6;

@interface ThirdBeautyTencentEffectViewController () <TRTCCloudDelegate, TRTCVideoFrameDelegate>
@property (weak, nonatomic) IBOutlet UIView *leftRemoteViewA;
@property (weak, nonatomic) IBOutlet UIView *leftRemoteViewB;
@property (weak, nonatomic) IBOutlet UIView *leftRemoteViewC;
@property (weak, nonatomic) IBOutlet UIView *rightRemoteViewA;
@property (weak, nonatomic) IBOutlet UIView *rightRemoteViewB;
@property (weak, nonatomic) IBOutlet UIView *rightRemoteViewC;

@property (weak, nonatomic) IBOutlet UILabel *leftRemoteLabelA;
@property (weak, nonatomic) IBOutlet UILabel *leftRemoteLabelB;
@property (weak, nonatomic) IBOutlet UILabel *leftRemoteLabelC;
@property (weak, nonatomic) IBOutlet UILabel *rightRemoteLabelA;
@property (weak, nonatomic) IBOutlet UILabel *rightRemoteLabelB;
@property (weak, nonatomic) IBOutlet UILabel *rightRemoteLabelC;
@property (weak, nonatomic) IBOutlet UILabel *setBeautyLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *beautyNumLabel;

@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *roomIdTextField;

@property (weak, nonatomic) IBOutlet UISlider *setBeautySlider;
@property (weak, nonatomic) IBOutlet UIButton *startPushStreamButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (strong, nonatomic) TRTCCloud *trtcCloud;
@property (strong, nonatomic) NSMutableOrderedSet *remoteUserIdSet;

//@property (nonatomic, strong) XMagic *xMagicKit;
//@property (nonatomic, assign) CGSize renderSize;

@end

@implementation ThirdBeautyTencentEffectViewController

- (NSMutableOrderedSet *)remoteUserIdSet {
    if (!_remoteUserIdSet) {
        _remoteUserIdSet = [[NSMutableOrderedSet alloc] initWithCapacity:RemoteUserMaxNum];
    }
    return _remoteUserIdSet;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _trtcCloud = [TRTCCloud sharedInstance];
    _trtcCloud.delegate = self;
    [self setupDefaultUIConfig];
    [self setupBeautySDK];
    [self addKeyboardObserver];
}

- (void)setupBeautySDK {
//    [TELicenseCheck setTELicense:@"https://license.vod2.myqcloud.com/license/v2/1258289294_1/v_cube.license" key:@"3c16909893f53b9600bc63941162cea3" completion:^(NSInteger authresult, NSString * _Nonnull errorMsg) {
//        if (authresult == TELicenseCheckOk) {
//            NSLog(@"XMagic 授权成功");
//        } else {
//            NSLog(@"XMagic 授权失败");
//        }
//    }];
}

- (void)setupDefaultUIConfig {
    
    self.roomIdTextField.text = [NSString generateRandomRoomNumber];
    self.userIdTextField.text = [NSString generateRandomUserId];
    self.title = LocalizeReplace(Localize(@"TRTC-API-Example.ThirdBeauty.Title"), self.roomIdTextField.text);
    
    self.roomIdLabel.text = Localize(@"TRTC-API-Example.ThirdBeauty.roomId");
    self.userIdLabel.text = Localize(@"TRTC-API-Example.ThirdBeauty.userId");
    self.setBeautyLabel.text = Localize(@"TRTC-API-Example.ThirdBeauty.SetBeautyLevel");
    NSInteger value = self.setBeautySlider.value * 6;
    self.beautyNumLabel.text = [NSString stringWithFormat:@"%ld",value];
    
    [self.startPushStreamButton setTitle:Localize(@"TRTC-API-Example.ThirdBeauty.startPush") forState:UIControlStateNormal];
    [self.startPushStreamButton setTitle:Localize(Localize(@"TRTC-API-Example.ThirdBeauty.stopPush")) forState:UIControlStateSelected];
    
    self.startPushStreamButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
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
    
}

- (void)buildBeautySDK {
//    if (_renderSize.width == 0 || _renderSize.height == 0) {
//        return;
//    }
//    NSString *beautyConfigPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    beautyConfigPath = [beautyConfigPath stringByAppendingPathComponent:@"beauty_config.json"];
//    NSFileManager *localFileManager=[[NSFileManager alloc] init];
//    BOOL isDir = YES;
//    NSDictionary * beautyConfigJson = @{};
//    if ([localFileManager fileExistsAtPath:beautyConfigPath isDirectory:&isDir] && !isDir) {
//        NSString *beautyConfigJsonStr = [NSString stringWithContentsOfFile:beautyConfigPath encoding:NSUTF8StringEncoding error:nil];
//        NSError *jsonError;
//        NSData *objectData = [beautyConfigJsonStr dataUsingEncoding:NSUTF8StringEncoding];
//        beautyConfigJson = [NSJSONSerialization JSONObjectWithData:objectData
//                                                           options:NSJSONReadingMutableContainers
//                                                             error:&jsonError];
//    }
//    NSDictionary *assetsDict = @{@"core_name":@"LightCore.bundle",
//                                 @"root_path":[[NSBundle mainBundle] bundlePath],
//                                 @"plugin_3d":@"Light3DPlugin.bundle",
//                                 @"plugin_hand":@"LightHandPlugin.bundle",
//                                 @"plugin_segment":@"LightSegmentPlugin.bundle",
//                                 @"beauty_config":beautyConfigJson
//    };
//    _xMagicKit = [[XMagic alloc] initWithRenderSize:_renderSize assetsDict:assetsDict];
//
//    //去掉磨皮
//    [self.xMagicKit configPropertyWithType:@"beauty" withName:@"beauty.smooth" withData:@"0.0" withExtraInfo:nil];
    
}

//- (int)processVideoFrameWithTextureId:(int)textureId textureWidth:(int)textureWidth textureHeight:(int)textureHeight {
//    if (textureWidth != _renderSize.width || textureHeight != _renderSize.height) {
//        _renderSize = CGSizeMake(textureWidth, textureHeight);
//        if (!_xMagicKit) {
//            [self buildBeautySDK];
//        } else {
//            [_xMagicKit setRenderSize:_renderSize];
//        }
//    }
//    YTProcessInput *input = [[YTProcessInput alloc] init];
//    input.textureData = [[YTTextureData alloc] init];
//    input.textureData.texture = textureId;
//    input.textureData.textureWidth = textureWidth;
//    input.textureData.textureHeight = textureHeight;
//    input.dataType = kYTTextureData;
//    YTProcessOutput *output = [self.xMagicKit process:input withOrigin:YtLightImageOriginTopLeft withOrientation:YtLightCameraRotation0];
//    return output.textureData.texture;
//}

- (void)showRemoteUserViewWith:(NSString *)userId {
    if (self.remoteUserIdSet.count < RemoteUserMaxNum) {
        NSInteger count = self.remoteUserIdSet.count;
        [self.remoteUserIdSet addObject:userId];
        UIView *userView = [self.view viewWithTag:count + 200];
        UILabel *userIdLabel = [self.view viewWithTag:count + 300];
        userView.alpha = 1;
        userIdLabel.text = LocalizeReplace(Localize(@"TRTC-API-Example.ThirdBeauty.UserIdxx"), userId);
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
- (IBAction)onPushStreamClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self startPushStream];
    } else {
        [self stopPushStream];
    }
}

#pragma mark - Slider ValueChange
- (IBAction)setBeautySliderValueChange:(UISlider *)sender {
//    NSDictionary *extraInfo = [NSDictionary dictionary];
//    [self.xMagicKit configPropertyWithType:@"beauty" withName:@"beauty.smooth" withData:[NSString stringWithFormat:@"%f",sender.value*100] withExtraInfo:extraInfo];
    NSInteger value = sender.value * 6;
    self.beautyNumLabel.text = [NSString stringWithFormat:@"%ld",value];
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

- (void)onError:(TXLiteAVError)errCode errMsg:(NSString *)errMsg extInfo:(NSDictionary *)extInfo  {
    NSLog(@"");
}



#pragma mark - TRTCVideoFrameDelegate
- (uint32_t)onProcessVideoFrame:(TRTCVideoFrame *_Nonnull)srcFrame dstFrame:(TRTCVideoFrame *_Nonnull)dstFrame {
//    dstFrame.textureId = [self processVideoFrameWithTextureId:srcFrame.textureId textureWidth:srcFrame.width textureHeight:srcFrame.height];
    return 0;
}

#pragma mark - StartPushStream & StopPushStream
- (void)startPushStream {
    self.title = LocalizeReplace(Localize(@"TRTC-API-Example.ThirdBeauty.Title"), self.roomIdTextField.text);
    [self.trtcCloud startLocalPreview:YES view:self.view];

    TRTCParams *params = [[TRTCParams alloc] init];
    params.sdkAppId = SDKAppID;
    params.roomId = [self.roomIdTextField.text intValue];
    params.userId = self.userIdTextField.text;
    params.userSig = [GenerateTestUserSig genTestUserSig:self.userIdTextField.text];
    params.role = TRTCRoleAnchor;

//    [self.trtcCloud setLocalVideoProcessDelegete:self pixelFormat:TRTCVideoPixelFormat_Texture_2D bufferType:TRTCVideoBufferType_Texture];
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
//    if (_xMagicKit) {
//        [_xMagicKit deinit];
//        _xMagicKit = nil;
//    }
    [TRTCCloud destroySharedIntance];
}

@end
