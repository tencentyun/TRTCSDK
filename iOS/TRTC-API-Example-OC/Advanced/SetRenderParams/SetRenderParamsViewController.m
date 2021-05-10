//
//  SetRenderParamsViewController.m
//  TRTC-API-Example-OC
//
//  Created by bluedang on 2021/4/20.
//

/*
 渲染控制功能
 TRTC 渲染控制页面
 本文件展示如何集成渲染控制功能
 1、设置预览图像镜像模式 API: [self.trtcCloud setLocalRenderParams:renderParams];
 2、设置预览图像渲染模式 API: [self.trtcCloud setLocalRenderParams:renderParams];
 3、设置预览图像旋转角度(顺时针) API: [self.trtcCloud setLocalRenderParams:renderParams];
 4、设置远端图像渲染模式 API: [self.trtcCloud setRemoteRenderParams:_remoteUserIdButton.currentTitle
                                    streamType:TRTCVideoStreamTypeSmall
                                        params:renderParams];
 5、设置远端图像旋转角度(顺时针) API: [self.trtcCloud setRemoteRenderParams:_remoteUserIdButton.currentTitle
                                    streamType:TRTCVideoStreamTypeSmall
                                        params:renderParams];

 参考文档：https://cloud.tencent.com/document/product/647/32237
 */
/*
 Rendering Control
 TRTC Rendering Control View
 This document shows how to integrate the rendering control feature.
 1. Set the mirror mode for the preview image: [self.trtcCloud setLocalRenderParams:renderParams]
 2. Set the rendering mode for the preview image: [self.trtcCloud setLocalRenderParams:renderParams]
 3. Set the rotation (clockwise) of the preview image: [self.trtcCloud setLocalRenderParams:renderParams]
 4. Set the rendering mode of a remote image: [self.trtcCloud setRemoteRenderParams:_remoteUserIdButton.currentTitle
                                    streamType:TRTCVideoStreamTypeSmall
                                        params:renderParams]
 5. Set the rotation (clockwise) of a remote image: [self.trtcCloud setRemoteRenderParams:_remoteUserIdButton.currentTitle
                                    streamType:TRTCVideoStreamTypeSmall
                                        params:renderParams]

 Documentation: https://cloud.tencent.com/document/product/647/32237
 */


#import "SetRenderParamsViewController.h"

static const NSInteger maxRemoteUserNum = 6;

@interface SetRenderParamsViewController () <TRTCCloudDelegate>
@property (weak, nonatomic) IBOutlet UILabel *roomIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *localRotateLabel;
@property (weak, nonatomic) IBOutlet UILabel *localRenderModeLabel;
@property (weak, nonatomic) IBOutlet UILabel *remoteRotateLabel;
@property (weak, nonatomic) IBOutlet UILabel *remoteRenderModeLabel;
@property (weak, nonatomic) IBOutlet UILabel *localMirrorModeLabel;
@property (weak, nonatomic) IBOutlet UILabel *remoteUserIdLabel;

@property (weak, nonatomic) IBOutlet UITextField *roomIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;

@property (weak, nonatomic) IBOutlet UIButton *localRotateButton;
@property (weak, nonatomic) IBOutlet UIButton *localMirrorModeButton;
@property (weak, nonatomic) IBOutlet UIButton *localFillModeButton;
@property (weak, nonatomic) IBOutlet UIButton *remoteRotateButton;
@property (weak, nonatomic) IBOutlet UIButton *remoteFillModeButton;
@property (weak, nonatomic) IBOutlet UIButton *remoteUserIdButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (weak, nonatomic) IBOutlet UIView *localVideoView;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *remoteViewArr;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *remoteUserIdLabelArr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (strong, nonatomic) TRTCCloud *trtcCloud;
@property (assign, nonatomic) TRTCVideoRotation localRotation;
@property (assign, nonatomic) TRTCVideoFillMode localFillMode;
@property (assign, nonatomic) TRTCVideoMirrorType localMirroType;
@property (strong, nonatomic) NSMutableOrderedSet *remoteUidSet;
@property (strong, nonatomic) NSMutableDictionary<NSString*, TRTCRenderParams*> *remoteRenderParamsDic;
@end

@implementation SetRenderParamsViewController

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

- (NSMutableDictionary<NSString *,TRTCRenderParams *> *)remoteRenderParamsDic {
    if (!_remoteRenderParamsDic) {
        _remoteRenderParamsDic = [NSMutableDictionary new];
    }
    return _remoteRenderParamsDic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.trtcCloud.delegate = self;
    [self setupRandomId];
    [self setupDefaultUIConfig];
}

- (void)setupDefaultUIConfig {
    self.title = [Localize(@"TRTC-API-Example.RenderParams.Title")
                  stringByAppendingString:_roomIdTextField.text];

    _roomIdLabel.text = Localize(@"TRTC-API-Example.RenderParams.roomId");
    _userIdLabel.text = Localize(@"TRTC-API-Example.RenderParams.userId");
    _localRotateLabel.text = Localize(@"TRTC-API-Example.RenderParams.localRate");
    _localRenderModeLabel.text = Localize(@"TRTC-API-Example.RenderParams.localRenderMode");
    _remoteRotateLabel.text = Localize(@"TRTC-API-Example.RenderParams.remoteRate");
    _remoteRenderModeLabel.text = Localize(@"TRTC-API-Example.RenderParams.remoteRenderMode");
    _localMirrorModeLabel.text = Localize(@"TRTC-API-Example.RenderParams.localMirrorMode");
    _remoteUserIdLabel.text = Localize(@"TRTC-API-Example.RenderParams.remoteUserId");
    
    [_remoteUserIdButton setTitle:@"" forState:UIControlStateNormal];
    [_localRotateButton setTitle:Localize(@"TRTC-API-Example.RenderParams.rotate0") forState:UIControlStateNormal];
    [_localMirrorModeButton setTitle:Localize(@"TRTC-API-Example.RenderParams.frontSymmetric") forState:UIControlStateNormal];
    [_localFillModeButton setTitle:Localize(@"TRTC-API-Example.RenderParams.renderModeFill") forState:UIControlStateNormal];
    [_remoteRotateButton setTitle:Localize(@"TRTC-API-Example.RenderParams.rotate0") forState:UIControlStateNormal];
    [_remoteFillModeButton setTitle:Localize(@"TRTC-API-Example.RenderParams.renderModeFill") forState:UIControlStateNormal];
    [_startButton setTitle:Localize(@"TRTC-API-Example.RenderParams.start") forState:UIControlStateNormal];
    [_startButton setTitle:Localize(@"TRTC-API-Example.RenderParams.stop") forState:UIControlStateSelected];
    
    _roomIdLabel.adjustsFontSizeToFitWidth = true;
    _userIdLabel.adjustsFontSizeToFitWidth = true;
    _localRotateLabel.adjustsFontSizeToFitWidth = true;
    _localRenderModeLabel.adjustsFontSizeToFitWidth = true;
    _remoteRotateLabel.adjustsFontSizeToFitWidth = true;
    _remoteRenderModeLabel.adjustsFontSizeToFitWidth = true;
    _localMirrorModeLabel.adjustsFontSizeToFitWidth = true;
    _remoteUserIdLabel.adjustsFontSizeToFitWidth = true;
    _remoteUserIdButton.titleLabel.adjustsFontSizeToFitWidth = true;
    _localRotateButton.titleLabel.adjustsFontSizeToFitWidth = true;
    _localMirrorModeButton.titleLabel.adjustsFontSizeToFitWidth = true;
    _localFillModeButton.titleLabel.adjustsFontSizeToFitWidth = true;
    _remoteRotateButton.titleLabel.adjustsFontSizeToFitWidth = true;
    _remoteFillModeButton.titleLabel.adjustsFontSizeToFitWidth = true;
    _startButton.titleLabel.adjustsFontSizeToFitWidth = true;
    _roomIdTextField.adjustsFontSizeToFitWidth = true;
    _userIdTextField.adjustsFontSizeToFitWidth = true;

    [self setupRemoteViews];
    [self addKeyboardObserver];
}

- (void)setupRandomId {
    _roomIdTextField.text = [NSString generateRandomRoomNumber];
    _userIdTextField.text = [NSString generateRandomUserId];
}

- (void)setupTRTCCloud {
    [self.trtcCloud startLocalPreview:YES view:_localVideoView];

    TRTCParams *params = [TRTCParams new];
    params.sdkAppId = SDKAppID;
    params.roomId = [_roomIdTextField.text intValue];
    params.userId = _userIdTextField.text;
    params.role = TRTCRoleAnchor;
    params.userSig = [GenerateTestUserSig genTestUserSig:params.userId];
    
    [self.trtcCloud enterRoom:params appScene:TRTCAppSceneVideoCall];
    
    TRTCVideoEncParam *encParams = [TRTCVideoEncParam new];
    encParams.videoResolution = TRTCVideoResolution_640_360;
    encParams.videoBitrate = 550;
    encParams.videoFps = 15;
    
    [self.trtcCloud setVideoEncoderParam:encParams];
    [self.trtcCloud startLocalAudio:TRTCAudioQualityMusic];
}

- (void)setupRemoteViews {
    for (NSInteger i = 0; i < maxRemoteUserNum; i++) {
        [_remoteViewArr[i] setHidden:true];
        [_remoteUserIdLabelArr[i] setHidden:true];
    }
}

- (void)destroyTRTCCloud {
    [TRTCCloud destroySharedIntance];
    _trtcCloud = nil;
}

- (void)dealloc {
    [self destroyTRTCCloud];
    [self removeKeyboardObserver];
}

- (void)showRateMenuListWithIsLocal:(BOOL)isLocal handler:(void (^ __nullable)(TRTCVideoRotation rotate))handler {
    NSString* alertTitle = isLocal ? Localize(@"TRTC-API-Example.RenderParams.localRate") : Localize(@"TRTC-API-Example.RenderParams.remoteRate");
     
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:alertTitle message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:Localize(@"TRTC-API-Example.RenderParams.rotate0") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if (handler) { handler(TRTCVideoRotation_0); }
    }];
    UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:Localize(@"TRTC-API-Example.RenderParams.rotate90") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if (handler) { handler(TRTCVideoRotation_90); }
    }];
    UIAlertAction *alertAction2 = [UIAlertAction actionWithTitle:Localize(@"TRTC-API-Example.RenderParams.rotate180") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if (handler) { handler(TRTCVideoRotation_180); }
    }];
    UIAlertAction *alertAction3 = [UIAlertAction actionWithTitle:Localize(@"TRTC-API-Example.RenderParams.rotate270") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if (handler) { handler(TRTCVideoRotation_270); }
    }];

    [alertVC addAction:alertAction];
    [alertVC addAction:alertAction1];
    [alertVC addAction:alertAction2];
    [alertVC addAction:alertAction3];

    [self presentViewController:alertVC animated:true completion:nil];
}

- (void)showFillModeListWithIsLocal:(BOOL)isLocal handler:(void (^ __nullable)(TRTCVideoFillMode))handler {
    NSString* alertTitle = isLocal ? Localize(@"TRTC-API-Example.RenderParams.localRenderMode") : Localize(@"TRTC-API-Example.RenderParams.remoteRenderMode");

    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:alertTitle message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:Localize(@"TRTC-API-Example.RenderParams.renderModeFill") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if (handler) { handler(TRTCVideoFillMode_Fill); }
    }];
    UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:Localize(@"TRTC-API-Example.RenderParams.renderModeAdaptor") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if (handler) { handler(TRTCVideoFillMode_Fit); }
    }];

    [alertVC addAction:alertAction];
    [alertVC addAction:alertAction1];

    [self presentViewController:alertVC animated:true completion:nil];
}

- (void)showMirrorTypeListWithHandler:(void (^ __nullable)(TRTCVideoMirrorType))handler {
    NSString* alertTitle = Localize(@"TRTC-API-Example.RenderParams.localMirrorMode");

    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:alertTitle message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:Localize(@"TRTC-API-Example.RenderParams.frontSymmetric") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if (handler) { handler(TRTCVideoMirrorTypeAuto); }
    }];
    UIAlertAction *alertAction1 = [UIAlertAction
        actionWithTitle:Localize(@"TRTC-API-Example.RenderParams.allSymmetric") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if (handler) { handler(TRTCVideoMirrorTypeEnable); }
    }];
    UIAlertAction *alertAction2 = [UIAlertAction
        actionWithTitle:Localize(@"TRTC-API-Example.RenderParams.allKeep") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if (handler) { handler(TRTCVideoMirrorTypeDisable); }
    }];

    [alertVC addAction:alertAction];
    [alertVC addAction:alertAction1];
    [alertVC addAction:alertAction2];

    [self presentViewController:alertVC animated:true completion:nil];
}

- (void)showRemoteUsersListWithHandle:(void (^ __nullable)(NSString*))handler {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:Localize(@"TRTC-API-Example.RenderParams.chooseUserId") message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    for (NSString* userId in _remoteUidSet) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:userId style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            if (handler) { handler(userId); }
        }];
        
        [alertVC addAction:alertAction];
    }
    
    [self presentViewController:alertVC animated:true completion:nil];
}

- (void)reloadRenderParamsWithIsLocal:(BOOL)isLocal {
    UIButton* rotateButton = isLocal ? _localRotateButton : _remoteRotateButton;
    UIButton* fillModeButton = isLocal ? _localFillModeButton : _remoteFillModeButton;
    
    TRTCVideoRotation rotate = isLocal ? _localRotation : _remoteRenderParamsDic[_remoteUserIdButton.currentTitle].rotation;
    TRTCVideoFillMode fillMode = isLocal ? _localFillMode : _remoteRenderParamsDic[_remoteUserIdButton.currentTitle].fillMode;

    [self refreshRotationButton:rotateButton withRotation:rotate];
    [self refreshFillModeButton:fillModeButton withFillMode:fillMode];
    if (isLocal) { [self refreshLocalMirrorModeButton]; }
    
    TRTCRenderParams *renderParams = [TRTCRenderParams new];
    renderParams.fillMode = fillMode;
    renderParams.rotation = rotate;
    if (isLocal) {
        renderParams.mirrorType = _localMirroType;
        [self.trtcCloud setLocalRenderParams:renderParams];
    } else {
        renderParams.mirrorType = TRTCVideoMirrorTypeDisable;
        [self.trtcCloud setRemoteRenderParams:_remoteUserIdButton.currentTitle
                                   streamType:TRTCVideoStreamTypeSmall
                                       params:renderParams];
    }
}

- (void)refreshRotationButton:(UIButton*)button withRotation:(TRTCVideoRotation)rotate {
    switch (rotate) {
        case TRTCVideoRotation_0:
            [button setTitle:Localize(@"TRTC-API-Example.RenderParams.rotate0")
                          forState:UIControlStateNormal];
            break;
        case TRTCVideoRotation_90:
            [button setTitle:Localize(@"TRTC-API-Example.RenderParams.rotate90")
                          forState:UIControlStateNormal];
            break;
        case TRTCVideoRotation_180:
            [button setTitle:Localize(@"TRTC-API-Example.RenderParams.rotate180")
                          forState:UIControlStateNormal];
            break;
        case TRTCVideoRotation_270:
            [button setTitle:Localize(@"TRTC-API-Example.RenderParams.rotate270")
                          forState:UIControlStateNormal];
            break;
    }
}

- (void)refreshFillModeButton:(UIButton*)button withFillMode:(TRTCVideoFillMode)fillMode {
    switch (fillMode) {
        case TRTCVideoFillMode_Fill:
            [button setTitle:Localize(@"TRTC-API-Example.RenderParams.renderModeFill")
                          forState:UIControlStateNormal];
            break;
        case TRTCVideoFillMode_Fit:
            [button setTitle:Localize(@"TRTC-API-Example.RenderParams.renderModeAdaptor")
                          forState:UIControlStateNormal];
            break;
    }
}

- (void)refreshLocalMirrorModeButton {
    switch (_localMirroType) {
        case TRTCVideoMirrorTypeAuto:
            [_localMirrorModeButton setTitle:Localize(@"TRTC-API-Example.RenderParams.frontSymmetric")
                          forState:UIControlStateNormal];
            break;
        case TRTCVideoMirrorTypeEnable:
            [_localMirrorModeButton setTitle:Localize(@"TRTC-API-Example.RenderParams.allSymmetric")
                          forState:UIControlStateNormal];
            break;
        case TRTCVideoMirrorTypeDisable:
            [_localMirrorModeButton setTitle:Localize(@"TRTC-API-Example.RenderParams.allKeep")
                          forState:UIControlStateNormal];
            break;
    }
}

- (void)hidenRemoteViewAndLabels {
    for (NSInteger i = 0; i < maxRemoteUserNum; i++) {
        [_remoteViewArr[i] setHidden:true];
        [_remoteUserIdLabelArr[i] setHidden:true];
    }
}

#pragma mark - IBActions

- (IBAction)onLocalRateButtonClick:(UIButton *)sender {
    [self showRateMenuListWithIsLocal:true handler:^(TRTCVideoRotation rotate){
        self.localRotation = rotate;
        [self reloadRenderParamsWithIsLocal:true];
    }];
}

- (IBAction)onLocalFillModeClick:(id)sender {
    [self showFillModeListWithIsLocal:true handler:^(TRTCVideoFillMode fillMode) {
        self.localFillMode = fillMode;
        [self reloadRenderParamsWithIsLocal:true];
    }];
}

- (IBAction)onLocalMirrorModeClick:(id)sender {
    [self showMirrorTypeListWithHandler:^(TRTCVideoMirrorType mirrorType) {
        self.localMirroType = mirrorType;
        [self reloadRenderParamsWithIsLocal:true];
    }];
}

- (IBAction)onRemoteRotationClick:(id)sender {
    if ([_remoteUserIdButton.currentTitle isEqualToString:@""]) {
        [self showAlertViewController:nil
                              message:Localize(@"TRTC-API-Example.RenderParams.waitOtherUser")
                              handler:nil];
        return;
    }
    
    [self showRateMenuListWithIsLocal:false handler:^(TRTCVideoRotation rotate){
        self.remoteRenderParamsDic[self.remoteUserIdButton.titleLabel.text].rotation = rotate;
        [self reloadRenderParamsWithIsLocal:false];
    }];
}

- (IBAction)onRemoteFillModeClick:(id)sender {
    if ([_remoteUserIdButton.currentTitle isEqualToString:@""]) {
        [self showAlertViewController:nil
                              message:Localize(@"TRTC-API-Example.RenderParams.waitOtherUser")
                              handler:nil];
        return;
    }
    
    [self showFillModeListWithIsLocal:false handler:^(TRTCVideoFillMode fillMode) {
        self.remoteRenderParamsDic[self.remoteUserIdButton.titleLabel.text].fillMode = fillMode;
        [self reloadRenderParamsWithIsLocal:false];
    }];
}

- (IBAction)onRemoteUserIdClick:(id)sender {
    if (_remoteUidSet.count == 0) {
        [self showAlertViewController:nil
                              message:Localize(@"TRTC-API-Example.RenderParams.waitOtherUser")
                              handler:nil];
        return ;
    }
    
    [self showRemoteUsersListWithHandle:^(NSString* userId){
        [self.remoteUserIdButton setTitle:userId forState:UIControlStateNormal];
        [self reloadRenderParamsWithIsLocal:false];
    }];
    
}

- (IBAction)onStartButton:(UIButton*)sender {
    if ([sender isSelected]) {
        [_remoteUserIdButton setTitle:@"" forState:UIControlStateNormal];
        [self.remoteUidSet removeAllObjects];
        [self hidenRemoteViewAndLabels];
        [self.trtcCloud exitRoom];
        [self destroyTRTCCloud];
    } else {
        self.title = [Localize(@"TRTC-API-Example.RenderParams.Title")
                      stringByAppendingString:_roomIdTextField.text];
        [self setupTRTCCloud];
    }
    sender.selected = !sender.selected;
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
        [self.remoteRenderParamsDic setObject:[TRTCRenderParams new] forKey:userId];
        if ([_remoteUserIdButton.currentTitle isEqualToString:@""]) {
            [_remoteUserIdButton setTitle:userId forState:UIControlStateNormal];
        }
    } else {
        [_trtcCloud stopRemoteView:userId streamType:TRTCVideoStreamTypeSmall];
        [_remoteUidSet removeObject:userId];
        [self.remoteRenderParamsDic removeObjectForKey:userId];
        if (_remoteUidSet.count == 0) {
            [_remoteUserIdButton setTitle:@"" forState:UIControlStateNormal];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshRemoteVideoViews];
    });
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


@end
