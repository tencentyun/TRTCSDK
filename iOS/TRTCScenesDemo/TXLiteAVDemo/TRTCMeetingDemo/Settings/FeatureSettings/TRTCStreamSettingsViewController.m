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

@end

@implementation TRTCStreamSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TRTCStreamConfig *config = self.settingsManager.streamConfig;
    
    __weak __typeof(self) wSelf = self;
    self.items = @[
        [[TRTCSettingsSegmentItem alloc] initWithTitle:@"云端混流"
                                                 items:@[@"关闭", @"手动", @"纯音频", @"预设"]
                                         selectedIndex:config.mixMode
                                                action:^(NSInteger index) {
            [wSelf onSelectMixModeIndex:index];
        }],
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

- (void)onSelectMixModeIndex:(NSInteger)index {
    [self.settingsManager setMixMode:index];
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
    NSString *shareUrl = [self.settingsManager getCdnUrlOfUser:self.settingsManager.params.userId];
    self.qrCodeView.image = [QRCode qrCodeWithString:shareUrl size:self.qrCodeView.frame.size];
}

@end
