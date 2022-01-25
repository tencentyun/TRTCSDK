//
//  ThirdBeautyBytedViewController.m
//  TRTC-API-Example-OC
//
//  Created by adams on 2021/4/22.
//

/**
 第三方美颜接入火山美颜功能
 接入步骤：
 第一步：集成火山美颜SDK（可参考火山美颜提供的接入文档：http://ailab-cv-sdk.bytedance.com/docs/2036/157784/）
 1.1、拷贝 iossample 项目中的 Core/Core 目录下的文件到自己项目中
 <p>
 第二步：打开火山美颜的调用代码
 2.1、依次取消此文件内被注释的所有代码
 <p>
 第三步：在TRTC中使用火山美颜功能
 3.1、编译并运行此工程
 */

#import "ThirdBeautyBytedViewController.h"
#import <OpenGLES/ES2/gl.h>
//#import "BEEffectManager.h"
//#import "BEEffectResourceHelper.h"
//#import "BEEffectDataManager.h"
//#import "BEGLUtils.h"
//#import "BEGLView.h"

static const NSInteger RemoteUserMaxNum = 6;

@interface ThirdBeautyBytedViewController () <TRTCCloudDelegate, TRTCVideoFrameDelegate>

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

// {zh} / 特效 SDK {en} /Special effects SDK
//@property (nonatomic, strong) BEEffectManager *manager;
//@property (nonatomic, strong) BEImageUtils *imageUtils;
//@property (nonatomic, strong) BEEffectDataManager *dataManager;
@property (nonatomic, assign) BOOL initData;

@end

@implementation ThirdBeautyBytedViewController

//- (BEEffectDataManager *)dataManager {
//    if (_dataManager == nil) {
//        _dataManager = [[BEEffectDataManager alloc] initWithType:BEEffectCamera];
//    }
//    return _dataManager;
//}

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
    self.initData = NO;
    self.trtcCloud.delegate = self;
    [self setupDefaultUIConfig];
    [self addKeyboardObserver];
}


- (void)setupDefaultUIConfig {
    
//    self.imageUtils = [[BEImageUtils alloc] init];
    
    self.roomIdTextField.text = [NSString generateRandomRoomNumber];
    self.userIdTextField.text = [NSString generateRandomUserId];
    self.title = LocalizeReplace(Localize(@"TRTC-API-Example.ThirdBeauty.Title"), self.roomIdTextField.text);
    
    self.roomIdLabel.text = Localize(@"TRTC-API-Example.ThirdBeauty.roomId");
    self.userIdLabel.text = Localize(@"TRTC-API-Example.ThirdBeauty.userId");
    self.setBeautyLabel.text = Localize(@"TRTC-API-Example.ThirdBeauty.SetBeautyLevel");
    float value = self.setBeautySlider.value;
    self.beautyNumLabel.text = [NSString stringWithFormat:@"%.2f",value];
    
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

#pragma mark - sdk lifecycle

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
    float value = sender.value ;
    self.beautyNumLabel.text = [NSString stringWithFormat:@"%.2f",value];
//    [self.manager updateComposerNodes:[NSArray arrayWithObject:@"beauty_IOS_live"]];
//    [self.manager updateComposerNodeIntensity:@"beauty_IOS_live" key:@"whiten" intensity:value];
//    [self.manager setStickerPath:@"baibianfaxing"];
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

#pragma mark - TRTCVideoFrameDelegate
- (uint32_t)onProcessVideoFrame:(TRTCVideoFrame *_Nonnull)srcFrame dstFrame:(TRTCVideoFrame *_Nonnull)dstFrame {
    if (!self.initData) {
        self.initData = YES;
        [self initSDK];
    }
//    int ret = [self.manager processTexture:srcFrame.textureId outputTexture:dstFrame.textureId width:srcFrame.width height:srcFrame.height rotate:[self getDeviceOrientation] timeStamp:srcFrame.timestamp];
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
   
    return 0;
}

//- (bef_ai_rotate_type)getDeviceOrientation {
//    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
//    switch (orientation) {
//        case UIDeviceOrientationPortrait:
//            return BEF_AI_CLOCKWISE_ROTATE_0;
//
//        case UIDeviceOrientationPortraitUpsideDown:
//            return BEF_AI_CLOCKWISE_ROTATE_180;
//
//        case UIDeviceOrientationLandscapeLeft:
//            return BEF_AI_CLOCKWISE_ROTATE_270;
//
//        case UIDeviceOrientationLandscapeRight:
//            return BEF_AI_CLOCKWISE_ROTATE_90;
//
//        default:
//            return BEF_AI_CLOCKWISE_ROTATE_0;
//    }
//}

#pragma mark - StartPushStream & StopPushStream
- (void)startPushStream {
    self.title = LocalizeReplace(Localize(@"TRTC-API-Example.ThirdBeauty.Title"), self.roomIdTextField.text);
    [self.trtcCloud startLocalPreview:true view:self.view];

    TRTCParams *params = [[TRTCParams alloc] init];
    params.sdkAppId = SDKAppID;
    params.roomId = [self.roomIdTextField.text intValue];
    params.userId = self.userIdTextField.text;
    params.userSig = [GenerateTestUserSig genTestUserSig:self.userIdTextField.text];
    params.role = TRTCRoleAnchor;
    
    [self.trtcCloud setLocalVideoProcessDelegete:self pixelFormat:TRTCVideoPixelFormat_Texture_2D bufferType:TRTCVideoBufferType_Texture];
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
    [self destroySDK];

}

- (void)initSDK {
//    self.manager = [[BEEffectManager alloc] initWithResourceProvider:[BEEffectResourceHelper new]];
//    [self.manager initTask];
//    [self resetToDefaultEffect:self.dataManager.buttonItemArrayWithDefaultIntensity];
}

//- (void)resetToDefaultEffect:(NSArray<BEEffectItem *> *)items {
//    [self.manager setFilterPath:@""];
//    [self.manager setStickerPath:@""];
//
//    [self updateComposerNode:items];
//    for (BEEffectItem *item in items) {
//        [self updateComposerNodeIntensity:item];
//    }
//}

//- (void)updateComposerNode:(NSArray<BEEffectItem *> *)items {
//    NSMutableArray<NSString *> *nodes = [NSMutableArray arrayWithCapacity:items.count];
//    NSMutableArray<NSString *> *tags = [NSMutableArray arrayWithCapacity:items.count];
//    for (BEEffectItem *item in items) {
//        [nodes addObject:item.model.path];
//        [tags addObject:item.model.tag == nil ? @"" : item.model.tag];
//    }
//    [self.manager updateComposerNodes:nodes withTags:tags];
//}
//
//- (void)updateComposerNodeIntensity:(BEEffectItem *)item {
//    for (int i = 0; i < item.model.keyArray.count; i++) {
//        [self.manager updateComposerNodeIntensity:item.model.path key:item.model.keyArray[i] intensity:[item.intensityArray[i] floatValue]];
//    }
//}

- (void)destroySDK {
//    [self.manager destroyTask];
}

@end
