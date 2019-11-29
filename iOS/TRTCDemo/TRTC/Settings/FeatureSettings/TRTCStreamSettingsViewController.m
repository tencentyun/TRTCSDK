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

@property (strong, nonatomic) IBOutlet UISwitch *switcher;
@property (strong, nonatomic) IBOutlet UIImageView *qrCodeView;

@end

@implementation TRTCStreamSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupQRCode];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.switcher.on = self.settingsManager.videoConfig.isMixingInCloud;
}

- (void)setupQRCode {
    [self.qrCodeView layoutIfNeeded];
    NSString *shareUrl = [self.settingsManager getCdnUrlOfUser:self.settingsManager.params.userId];
    self.qrCodeView.image = [QRCode qrCodeWithString:shareUrl size:self.qrCodeView.frame.size];
}

#pragma mark - Actions

- (IBAction)onToggleSwitch:(id)sender {
    [self.settingsManager setMixingInCloud:self.switcher.isOn];
}

- (IBAction)onClickShareButton:(UIButton *)button{
    NSString *shareUrl = [self.settingsManager getCdnUrlOfUser:self.settingsManager.params.userId];
    UIActivityViewController *activityView = [[UIActivityViewController alloc]
                                              initWithActivityItems:@[shareUrl]
                                              applicationActivities:nil];
    [self presentViewController:activityView animated:YES completion:nil];
}

@end
