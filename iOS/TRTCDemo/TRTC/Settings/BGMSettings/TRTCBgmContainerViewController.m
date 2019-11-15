/*
* Module:   TRTCBgmContainerViewController
*
* Function: BGM设置弹出页，包含两个子页面：BGM和音效
*
*/

#import "TRTCBgmContainerViewController.h"
#import "TRTCBgmSettingsViewController.h"
#import "TRTCEffectSettingsViewController.h"

@interface TRTCBgmContainerViewController ()

@property (strong, nonatomic) TRTCBgmSettingsViewController *bgmVC;
@property (strong, nonatomic) TRTCEffectSettingsViewController *effectVC;

@end

@implementation TRTCBgmContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bgmVC = [[TRTCBgmSettingsViewController alloc] init];
    self.bgmVC.manager = self.bgmManager;
    
    self.effectVC = [[TRTCEffectSettingsViewController alloc] init];
    self.effectVC.manager = self.effectManager;
    
    self.settingVCs = @[ self.bgmVC, self.effectVC ];
}

@end
