/*
* Module:   TRTCPKSettingsViewController
*
* Function: 跨房PK页
*
*    1. 通过TRTCCloudManager来开启关闭跨房连麦。
*
*/

#import "TRTCPKSettingsViewController.h"
#import "ColorMacro.h"

@interface TRTCPKSettingsViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *roomIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@end

@implementation TRTCPKSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTextField:self.roomIdTextField];
    [self setupTextField:self.userIdTextField];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.actionButton.selected = self.manager.isCrossingRoom;
}

- (void)setupTextField:(UITextField *)textField {
    NSDictionary *attributes = @{
        NSForegroundColorAttributeName : UIColorFromRGB(0x888888),
        NSFontAttributeName : [UIFont systemFontOfSize:15]
    };
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder
                                                                      attributes:attributes];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:NO];
}

#pragma mark - Actions

- (IBAction)onClickActionButton:(UIButton *)button {
    button.selected = !button.isSelected;
    
    if (self.manager.isCrossingRoom) {
        [self stopPK];
    } else {
        [self startPK];
    }
}

- (void)startPK {
    if (self.roomIdTextField.text.length == 0 || self.userIdTextField.text.length == 0) {
        return;
    }
    [self.manager startCrossRoom:self.roomIdTextField.text
                          userId:self.userIdTextField.text];
    [self.view endEditing:YES];
}

- (void)stopPK {
    [self.manager stopCrossRomm];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.roomIdTextField) {
        [self.userIdTextField becomeFirstResponder];
    } else if (textField == self.userIdTextField) {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
