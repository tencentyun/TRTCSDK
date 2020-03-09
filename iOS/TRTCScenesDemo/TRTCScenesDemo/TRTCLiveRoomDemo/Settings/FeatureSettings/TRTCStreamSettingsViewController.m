/*
* Module:   TRTCStreamSettingsViewController
*
* Function: 混流设置页
*
*    1. 通过TRTCCloudManager来开启关闭云端混流。
*
*    2. 显示房间的直播地址二维码。
*
*/

#import "TRTCStreamSettingsViewController.h"
#import "NSString+Common.h"
#import "QRCode.h"
#import "Masonry.h"

@interface TRTCStreamSettingsViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *qrCodeView;
@property (strong, nonatomic) IBOutlet UILabel *qrCodeTitle;
@property (strong, nonatomic) TRTCSettingsSwitchItem *mixItem;

@end

@implementation TRTCStreamSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TRTCStreamConfig *config = self.settingsManager.streamConfig;
    
    __weak __typeof(self) wSelf = self;
    self.mixItem = [[TRTCSettingsSwitchItem alloc] initWithTitle:@"开启云端画面混合"
                                             isOn:config.isMixingInCloud
                                           action:^(BOOL isOn) {
        [wSelf onEnableMixingInCloud:isOn];
    }];
    
    self.items = @[
        self.mixItem,
    ];
    
    [self setupSubviews];
    [self.qrCodeView layoutIfNeeded];
    [self updateStreamInfo];
}

- (void)setupSubviews {
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.qrCodeTitle.mas_top).offset(-20);
    }];
}

#pragma mark - Actions

- (void)onEnableMixingInCloud:(BOOL)isEnabled {
    [self.settingsManager setMixingInCloud:isEnabled];
    [self updateStreamInfo];
}

- (IBAction)onClickShareButton:(UIButton *)button{
    NSString *shareUrl = [self.settingsManager getCdnUrlOfUser:self.settingsManager.params.userId];
    UIActivityViewController *activityView = [[UIActivityViewController alloc]
                                              initWithActivityItems:@[shareUrl]
                                              applicationActivities:nil];
    [self presentViewController:activityView animated:YES completion:nil];
}

- (void)updateStreamInfo {
    self.mixItem.isOn = self.settingsManager.streamConfig.isMixingInCloud;
    [self.tableView reloadData];
    
    NSString *shareUrl = [self.settingsManager getCdnUrlOfUser:self.settingsManager.params.userId];
    self.qrCodeView.image = [QRCode qrCodeWithString:shareUrl size:self.qrCodeView.frame.size];
}

@end
