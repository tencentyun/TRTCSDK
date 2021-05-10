//
//  LiveEnterViewController.m
//  TRTCSimpleDemo-OC
//
//  Created by adams on 2021/4/14.
//

#import "LiveEnterViewController.h"
#import "LiveAnchorViewController.h"
#import "LiveAudienceViewController.h"

typedef NS_ENUM(NSUInteger, UserType) {
    Anchor,
    Audience,
};

@interface LiveEnterViewController ()
@property (weak, nonatomic) IBOutlet UILabel *enterRoomLabel;
@property (weak, nonatomic) IBOutlet UITextField *enterRoomTextField;
@property (weak, nonatomic) IBOutlet UILabel *enterUserNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *enterUserNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *userIdentifyLabel;
@property (weak, nonatomic) IBOutlet UIButton *anchorButton;
@property (weak, nonatomic) IBOutlet UIButton *audienceButton;
@property (weak, nonatomic) IBOutlet UIButton *enterRoomButton;

@property (nonatomic, assign) UserType userType;

@end

@implementation LiveEnterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = Localize(@"TRTC-API-Example.Live.Title");
    [self setupDefaultUIConfig];
}

- (void)setupDefaultUIConfig {
    self.enterRoomLabel.text = Localize(@"TRTC-API-Example.Live.EnterRoomNumber");
    self.enterUserNameLabel.text = Localize(@"TRTC-API-Example.Live.EnterUserName");
    self.userIdentifyLabel.text = Localize(@"TRTC-API-Example.Live.ChooseUserIdentify");
    [self.anchorButton setTitle:Localize(@"TRTC-API-Example.Live.Anchor") forState:UIControlStateNormal];
    [self.audienceButton setTitle:Localize(@"TRTC-API-Example.Live.Audience") forState:UIControlStateNormal];
    [self.enterRoomButton setTitle:Localize(@"TRTC-API-Example.Live.EnterRoom") forState:UIControlStateNormal];
    
    self.enterRoomTextField.text = @"1256732";
    self.enterUserNameTextField.text = @"324532";
    self.audienceButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.userType = Anchor;
}

- (void)setUserType:(UserType)userType {
    _userType = userType;
    switch (userType) {
        case Audience:
            [self.audienceButton setBackgroundColor:[UIColor themeGreenColor]];
            [self.anchorButton setBackgroundColor:[UIColor themeGrayColor]];
            break;
        case Anchor:
            [self.anchorButton setBackgroundColor:[UIColor themeGreenColor]];
            [self.audienceButton setBackgroundColor:[UIColor themeGrayColor]];
            break;
            
        default:
            break;
    }
}

#pragma mark - IBActions
- (IBAction)onAudienceClick:(UIButton *)sender {
    self.userType = Audience;
}

- (IBAction)onAnchorClick:(UIButton *)sender {
    self.userType = Anchor;
}

- (IBAction)onEnterRoomButtonClick:(id)sender {
    if (self.enterRoomTextField.text.length == 0 || self.enterUserNameTextField.text == 0) {
        [self showAlertViewController:Localize(@"TRTC-API-Example.AlertViewController.ponit") message:Localize(@"TRTC-API-Example.Live.tips") handler:nil];
        return;
    }
    UInt32 roomId = [self.enterRoomTextField.text intValue];
    NSString *userId = self.enterUserNameTextField.text;
    switch (self.userType) {
        case Anchor:
        {
            LiveAnchorViewController *anchorVC =
            [[LiveAnchorViewController alloc] initWithRoomId:roomId userId:userId];
            anchorVC.title = LocalizeReplace(Localize(@"TRTC-API-Example.LiveAnchor.Title"), self.enterRoomTextField.text);
            [self.navigationController pushViewController:anchorVC animated:YES];
        }
            break;
        case Audience:
        {
            LiveAudienceViewController *audienceVC =
            [[LiveAudienceViewController alloc] initWithRoomId:roomId userId:userId];
            audienceVC.title = LocalizeReplace(Localize(@"TRTC-API-Example.LiveAudience.Title"), self.enterRoomTextField.text);
            [self.navigationController pushViewController:audienceVC animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.enterRoomTextField resignFirstResponder];
    [self.enterUserNameTextField resignFirstResponder];
}

@end
