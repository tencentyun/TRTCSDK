/*
 * Module:   TRTCNewViewController
 *
 * Function: 该界面可以让用户输入一个【房间号】和一个【用户名】
 *
 * Notice:
 *
 *  （1）房间号为数字类型，用户名为字符串类型
 *
 *  （2）在真实的使用场景中，房间号大多不是用户手动输入的，而是系统分配的，
 *       比如视频会议中的会议号是会控系统提前预定好的，客服系统中的房间号也是根据客服员工的工号决定的。
 */

#import "TRTCNewViewController.h"
#import "TRTCMainViewController.h"
#import "UIView+Additions.h"
#import "ColorMacro.h"

#import "GenerateTestUserSig.h"
#import "QBImagePickerController.h"
#import "TRTCFloatWindow.h"
#import "TRTCCloudManager.h"
#import "TRTCRemoteUserManager.h"

#import "UIButton+TRTC.h"
#import "Masonry.h"
#import "AppDelegate.h"

#define kLastTRTCRoomId @"kLastTRTCRoomId"

@interface TRTCNewViewController () <UIPickerViewDelegate, UIPickerViewDataSource, QBImagePickerControllerDelegate>

@property (strong, nonatomic) TRTCSettingsLargeInputItem *roomItem;
@property (strong, nonatomic) TRTCSettingsLargeInputItem *nameItem;
@property (strong, nonatomic) TRTCSettingsSegmentItem *videoInputItem;
@property (strong, nonatomic) TRTCSettingsSegmentItem *audioRecvModeItem;
@property (strong, nonatomic) TRTCSettingsSegmentItem *videoRecvModeItem;
@property (strong, nonatomic) TRTCSettingsSegmentItem *roleItem;

@property (strong, nonatomic) UIButton *joinButton;
@property (nonatomic, retain) AVAsset* customSourceAsset;

@end

@implementation TRTCNewViewController

- (UISegmentedControl *)addOptionsWithLabel:(NSString *)label options:(NSArray<NSString *> *)options topLeft:(CGPoint *)topLeft {
    UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:options];
    UIFont *font = [UIFont boldSystemFontOfSize:14.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:NSFontAttributeName];
    [segmentControl setTitleTextAttributes:attributes
                               forState:UIControlStateNormal];
    segmentControl.bounds = CGRectMake(0, 0, self.view.width * 0.4, 35);
    segmentControl.center = CGPointMake(self.view.width - segmentControl.width / 2 - 10, topLeft->y + 25);
    segmentControl.tintColor = UIColorFromRGB(0x05a764);
    segmentControl.selectedSegmentIndex = 0;
    [segmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColor.whiteColor} forState:UIControlStateSelected];
    [segmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x939393)} forState:UIControlStateNormal];

    [self.view addSubview:segmentControl];
    UILabel *customVideoCaptureLabel = [[UILabel alloc] init];
    customVideoCaptureLabel.textColor = UIColorFromRGB(0x999999);
    customVideoCaptureLabel.text = label;
    [customVideoCaptureLabel sizeToFit];
    customVideoCaptureLabel.center = CGPointMake(topLeft->x + customVideoCaptureLabel.width / 2, segmentControl.center.y);
    [self.view addSubview:customVideoCaptureLabel];
    topLeft->y = segmentControl.bottom;
    return segmentControl;
}

- (void)dealloc {
    [[TRTCFloatWindow sharedInstance] close];
    if (self.appScene == TRTCAppSceneVideoCall) {
        [TRTCCloud destroySharedIntance];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0x333333);
    self.title = self.menuTitle;
    [self observeKeyboard];
    
    self.roomItem = [[TRTCSettingsLargeInputItem alloc] initWithTitle:@"请输入房间号："
                                                          placeHolder:[self defaultRoomId]];
    self.nameItem = [[TRTCSettingsLargeInputItem alloc] initWithTitle:@"请输入用户名："
                                                          placeHolder:[self randomId]];
    self.videoInputItem = [[TRTCSettingsSegmentItem alloc] initWithTitle:@"视频输入"
                                                                   items:@[@"前摄像头", @"视频文件"]
                                                           selectedIndex:0
                                                                  action:nil];
    self.audioRecvModeItem = [[TRTCSettingsSegmentItem alloc] initWithTitle:@"音频接收"
                                             items:@[@"自动", @"手动"]
                                     selectedIndex:0
                                            action:nil];
    self.videoRecvModeItem = [[TRTCSettingsSegmentItem alloc] initWithTitle:@"视频接收"
                                             items:@[@"自动", @"手动"]
                                     selectedIndex:0
                                            action:nil];
    self.roleItem = [[TRTCSettingsSegmentItem alloc] initWithTitle:@"角色选择"
                                                             items:@[@"上麦主播", @"普通观众"]
                                                     selectedIndex:0
                                                            action:nil];
    
    NSMutableArray *items = [@[self.roomItem,
                               self.nameItem,
                               self.videoInputItem,
                               self.audioRecvModeItem,
                               self.videoRecvModeItem]
                             mutableCopy];

    // 在线直播场景，才有角色选择按钮
    if (self.appScene == TRTCAppSceneLIVE) {
        [items insertObject:self.roleItem atIndex:2];
    }
    self.items = items;
    
    self.joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.joinButton.layer.cornerRadius = 8;
    self.joinButton.layer.masksToBounds = YES;
    self.joinButton.layer.shadowOffset = CGSizeMake(1, 1);
    self.joinButton.layer.shadowColor = UIColorFromRGB(0x019b5c).CGColor;
    self.joinButton.layer.shadowOpacity = 0.8;
    self.joinButton.backgroundColor = UIColorFromRGB(0x05a764);
    [self.joinButton setTitle:@"创建并自动加入该房间" forState:UIControlStateNormal];
    [self.joinButton addTarget:self action:@selector(onJoinBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.joinButton];
    [self.joinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottomLayoutGuide).offset(-20);
        make.leading.equalTo(self.view).offset(20);
        make.trailing.equalTo(self.view).offset(-20);
        make.height.mas_equalTo(50);
    }];
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.joinButton.mas_top).offset(-20);
    }];

    
    // 如果没有填 sdkappid 或者 secretkey，就结束流程。
    if (_SDKAppID == 0 || [_SECRETKEY isEqualToString:@""]) {
        self.joinButton.enabled = NO;
        
        NSString *msg = @"";
        if (_SDKAppID == 0) {
            msg = @"没有填写SDKAPPID";
        }
        if ([_SECRETKEY isEqualToString:@""]) {
            msg = [NSString stringWithFormat:@"%@ 没有填写SECRETKEY", msg];
        }
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"提示"
                                                                    message:msg
                                                             preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil];
        [ac addAction:ok];
        [self.navigationController presentViewController:ac animated:YES completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)observeKeyboard {
    __weak TRTCNewViewController *wSelf = self;
    [self.view tx_observeKeyboardOnChange:^(CGFloat keyboardTop, CGFloat height) {
        __strong TRTCNewViewController *self = wSelf;
        UIEdgeInsets insets = self.tableView.contentInset;
        insets.bottom = self.tableView.frame.size.height - keyboardTop;
        self.tableView.scrollIndicatorInsets = insets;
        self.tableView.contentInset = insets;
    }];
}

#pragma mark - Events

- (void)showMeidaPicker {
    QBImagePickerController* imagePicker = [[QBImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsMultipleSelection = YES;
    imagePicker.showsNumberOfSelectedAssets = YES;
    imagePicker.minimumNumberOfSelection = 1;
    imagePicker.maximumNumberOfSelection = 1;
    imagePicker.mediaType = QBImagePickerMediaTypeVideo;
    imagePicker.title = @"选择视频源";

    [self.navigationController pushViewController:imagePicker animated:YES];
}

#pragma mark - QBImagePickerControllerDelegate
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets
{
    [self.navigationController popViewControllerAnimated:YES];
    PHVideoRequestOptions *options = [PHVideoRequestOptions new];
    // 最高质量的视频
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
    // 可从iCloud中获取图片
    options.networkAccessAllowed = YES;
    
    __weak __typeof(self) weakSelf = self;
    [[PHImageManager defaultManager] requestAVAssetForVideo:assets.firstObject options:options resultHandler:^(AVAsset * _Nullable avAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        weakSelf.customSourceAsset = avAsset;
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                [weakSelf joinRoom];

            };
        });
    }];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  Function: 读取用户输入，并创建（或加入）音视频房间
 *
 *  此段示例代码最主要的作用是组装 TRTC SDK 进房所需的 TRTCParams
 *  
 *  TRTCParams.sdkAppId => 可以在腾讯云实时音视频控制台（https://console.cloud.tencent.com/rav）获取
 *  TRTCParams.userId   => 此处即用户输入的用户名，它是一个字符串
 *  TRTCParams.roomId   => 此处即用户输入的音视频房间号，比如 125
 *  TRTCParams.userSig  => 此处示例代码展示了两种获取 usersig 的方式，一种是从【控制台】获取，一种是从【服务器】获取
 *
 * （1）控制台获取：可以获得几组已经生成好的 userid 和 usersig，他们会被放在一个 json 格式的配置文件中，仅适合调试使用
 * （2）服务器获取：直接在服务器端用我们提供的源代码，根据 userid 实时计算 usersig，这种方式安全可靠，适合线上使用
 *
 *  参考文档：https://cloud.tencent.com/document/product/647/17275
 */

- (void)joinRoom {
    // 房间号，注意这里是32位无符号整型
    NSString *roomId = self.roomItem.content.length == 0 ? self.roomItem.placeHolder : self.roomItem.content;
    NSString *userId = self.nameItem.content.length == 0 ? self.nameItem.placeHolder : self.nameItem.content;
    [[NSUserDefaults standardUserDefaults] setObject:roomId forKey:kLastTRTCRoomId];
    
    // TRTC相关参数设置
    TRTCParams *param = [[TRTCParams alloc] init];
    param.sdkAppId = _SDKAppID;
    param.userId = userId;
    param.roomId = (UInt32)roomId.integerValue;
    param.userSig = [GenerateTestUserSig genTestUserSig:userId];
    param.privateMapKey = @"";
    param.role = self.roleItem.selectedIndex == 1 ? TRTCRoleAudience : TRTCRoleAnchor;

    TRTCRemoteUserManager *remoteManager = [[TRTCRemoteUserManager alloc] initWithTrtc:[TRTCCloud sharedInstance]];
    [remoteManager enableAutoReceiveAudio:self.audioRecvModeItem.selectedIndex == 0
                         autoReceiveVideo:self.videoRecvModeItem.selectedIndex == 0];
    
    TRTCCloudManager *manager = [[TRTCCloudManager alloc] initWithTrtc:[TRTCCloud sharedInstance]
                                                                params:param
                                                                 scene:self.appScene
                                                                 appId:TX_APPID
                                                                 bizId:TX_BIZID];
    

    if (self.videoInputItem.selectedIndex == 1) {
        [manager setCustomVideo:_customSourceAsset];
    }
    
    TRTCMainViewController *vc = [[UIStoryboard storyboardWithName:@"TRTC" bundle:nil] instantiateViewControllerWithIdentifier:@"TRTCMainViewController"];
    vc.settingsManager = manager;
    vc.remoteUserManager = remoteManager;
    vc.param = param;
    vc.appScene = self.appScene;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onJoinBtnClicked:(UIButton *)sender {
    if ([TRTCFloatWindow sharedInstance].localView) {
        [[TRTCFloatWindow sharedInstance] close];
    }

    if (self.videoInputItem.selectedIndex == 1) {
        [self showMeidaPicker];
    } else {
        [self joinRoom];
    }
}

- (NSString *)defaultRoomId {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kLastTRTCRoomId] ?: [self randomId];
}

- (NSString *)randomId {
    return [NSString stringWithFormat:@"%@", @(arc4random() % 100000)];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:NO];
}


@end
