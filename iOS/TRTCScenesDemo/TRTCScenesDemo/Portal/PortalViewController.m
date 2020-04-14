
#import "PortalViewController.h"
#import <TRTCCloudDef.h>

#import "ColorMacro.h"
#import "MainMenuCell.h"
#import "trtcScenesDemo-Swift.h"

#if DEBUG
#define SdkBusiId (18069)
#else
#define SdkBusiId (18070)
#endif


@interface PortalViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray<MainMenuItem *> *mainMenuItems;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) VideoCallMainViewController *videoCallVC;
@property (nonatomic, strong) AudioCallMainViewController *audioCallVC;
@property (nonatomic, strong) TRTCLiveRoomImpl *liveRoom;
@end

@implementation PortalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0x0d0d0d);
    
    _videoCallVC = [[VideoCallMainViewController alloc] init];
    _audioCallVC = [[AudioCallMainViewController alloc] init];
    [[TRTCVideoCall shared] setup];
    [TRTCVideoCall shared].delegate = _videoCallVC;
    
    [[TRTCAudioCall shared] setup];
    [TRTCAudioCall shared].delegate = _audioCallVC;
    
    _liveRoom = [[TRTCLiveRoomImpl alloc] init];
    
    __weak __typeof(self) wSelf = self;
    self.mainMenuItems = @[
        [[MainMenuItem alloc]
         initWithIcon:[UIImage imageNamed:@"MenuVideoCall"]
         title:@"视频通话"
         content:@"支持1080P超清视频，50%丢包率可正常视频，自备美颜特效，带来高品质视频通话体验"
         onSelect:^{ [wSelf gotoVideoCallView]; }],
        [[MainMenuItem alloc]
         initWithIcon:[UIImage imageNamed:@"MenuLive"]
         title:@"视频互动直播"
         content:@"观众时延低至800ms，上下麦无需loading，适用于低延时、十万人高并发的大型互动直播"
         onSelect:^{ [wSelf gotoLiveView]; }],
        [[MainMenuItem alloc]
        initWithIcon:[UIImage imageNamed:@"MenuAudioCall"]
        title:@"语音通话"
        content:@"48kHz高音质语音，60%丢包可正常语音，领先行业的3A处理，杜绝回声和啸叫"
        onSelect:^{ [wSelf gotoAudioCallView]; }],
        [[MainMenuItem alloc]
         initWithIcon:[UIImage imageNamed:@"MenuVoiceRoom"]
         title:@"语音聊天房"
         content:@"内含变声、音效、伴奏、背景音乐等声音玩法，适用于闲聊房、K歌房和开黑房等场景"
         onSelect:^{ [wSelf gotoVoiceRoomView]; }]
    ];
    
    [self setupFooter];
}

- (void)dealloc {
    [[TRTCVideoCall shared] destroy];
    [[TRTCAudioCall shared] destroy];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    NSString *userID = [[ProfileManager shared] curUserID];
    NSString *userSig = [GenerateTestUserSig genTestUserSig:userID];
    
    if (![[[TIMManager sharedInstance] getLoginUser] isEqual:userID]) {
        [[ProfileManager shared] IMLoginWithUserSig:userSig success:^{
            [[TRTCAudioCall shared] loginWithSdkAppID:SDKAPPID user:userID userSig:userSig success:^{
            } failed:^(NSInteger code, NSString *error) {
                
            }];
            
            [[TRTCVideoCall shared] loginWithSdkAppID:SDKAPPID user:userID userSig:userSig success:^{
            } failed:^(NSInteger code, NSString *error) {
                
            }];
            TRTCLiveRoomConfig *config = [[TRTCLiveRoomConfig alloc] init];
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"liveRoomConfig_useCDNFirst"] != nil) {
                config.useCDNFirst = [[[NSUserDefaults standardUserDefaults] objectForKey:@"liveRoomConfig_useCDNFirst"] boolValue];
            }
            
            if (config.useCDNFirst && [[NSUserDefaults standardUserDefaults] objectForKey:@"liveRoomConfig_cndPlayDomain"] != nil) {
                config.cdnPlayDomain = [[NSUserDefaults standardUserDefaults] objectForKey:@"liveRoomConfig_cndPlayDomain"];
            }
            
            [self.liveRoom loginWithSdkAppID:SDKAPPID userID:userID userSig:userSig config:config callback:^(NSInteger code, NSString * error) {
                
            }];
            
            loginResultModel *curUser = [[ProfileManager shared] curUserModel];
            [self.liveRoom setSelfProfileWithName:curUser.name avatarURL:curUser.avatar callback:^(NSInteger code, NSString * error) {
                
            }];
        } failed:^(NSString * error) {
            
        }];
    }
}

- (void)gotoVideoCallView {
    [self.navigationController pushViewController:self.videoCallVC animated:YES];
}

- (void)gotoLiveView {
    LiveRoomMainViewController *vc = [[LiveRoomMainViewController alloc] initWithLiveRoom:_liveRoom];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoAudioCallView {
    [self.navigationController pushViewController:self.audioCallVC animated:YES];
}


- (void)gotoVoiceRoomView {
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"TRTCVoiceRoom" bundle:nil];
    UIViewController *vc = [stroyBoard instantiateViewControllerWithIdentifier:@"CreateTRTCVoiceRoomViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)logout:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定要退出登录吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    __weak __typeof(self) wSelf = self;
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[ProfileManager shared] removeLoginCache];
        [[appUtils shared] showLoginController];
        [[TIMManager sharedInstance] logout:^{
            
        } fail:^(int code, NSString *msg) {
            
        }];
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mainMenuItems.count;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MainMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainMenuCell" forIndexPath:indexPath];
    cell.item = self.mainMenuItems[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.mainMenuItems[indexPath.row].selectBlock();
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

- (void) setupFooter {
    CGFloat width = self.view.bounds.size.width;
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 60)];
    UILabel *versionTip = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, width, 12)];
    UILabel *bottomTip = [[UILabel alloc] initWithFrame:CGRectMake(0, 14, width, 30)];
    
    versionTip.textAlignment = NSTextAlignmentCenter;
    versionTip.font = [UIFont systemFontOfSize:14];
    versionTip.textColor = [UIColor colorWithRed:82.0 / 255.0 green:82.0 / 255.0 blue:82.0 / 255.0 alpha:1.0];
    versionTip.text = [NSString stringWithFormat:@"腾讯云 TRTC v%@", [TRTCCloud getSDKVersion]];
    versionTip.adjustsFontSizeToFitWidth = YES;
    bottomTip.textAlignment = NSTextAlignmentCenter;
    bottomTip.font = [UIFont systemFontOfSize:14];
    bottomTip.textColor = [UIColor colorWithRed:82.0 / 255.0 green:82.0 / 255.0 blue:82.0 / 255.0 alpha:1.0];
    bottomTip.text = @"本APP用于展示腾讯云实时音视频的各类功能";
    bottomTip.adjustsFontSizeToFitWidth = YES;
    
    [footer addSubview:versionTip];
    [footer addSubview:bottomTip];
    
    self.table.tableFooterView = footer;
}

@end
