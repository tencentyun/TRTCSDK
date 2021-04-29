//
//  ScreenEntranceViewController.m
//  TRTC-API-Example-OC
//
//  Created by bluedang on 2021/4/15.
//

#import "ScreenEntranceViewController.h"
#import "ScreenAnchorViewController.h"
#import "ScreenAudienceViewController.h"
#import "UIColor+Hex.h"

@interface ScreenEntranceViewController ()

@property (weak, nonatomic) IBOutlet UILabel *inputRoomLabel;
@property (weak, nonatomic) IBOutlet UILabel *inputUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *roleLabel;
@property (weak, nonatomic) IBOutlet UITextField *roomIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UIButton *anchorButton;
@property (weak, nonatomic) IBOutlet UIButton *audienceButton;
@property (weak, nonatomic) IBOutlet UIButton *enterRoomButton;
@property (assign, nonatomic) BOOL isAnchorChoose;
@end

@implementation ScreenEntranceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDefaultUIConfig];
    [self setupRandomId];
    
    self.isAnchorChoose = true;
}

- (void)setupDefaultUIConfig {
    self.title = Localize(@"TRTC-API-Example.ScreenEntrance.Title");
    _inputRoomLabel.text = Localize(@"TRTC-API-Example.ScreenEntrance.EnterRoomNumber");
    _inputUserLabel.text = Localize(@"TRTC-API-Example.ScreenEntrance.EnterUserName");
    _roleLabel.text = Localize(@"TRTC-API-Example.ScreenEntrance.EnterRole");
    [_anchorButton setTitle:Localize(@"TRTC-API-Example.ScreenEntrance.Anchor") forState:UIControlStateNormal];
    [_audienceButton setTitle:Localize(@"TRTC-API-Example.ScreenEntrance.Audience") forState:UIControlStateNormal];
    [_enterRoomButton setTitle:Localize(@"TRTC-API-Example.ScreenEntrance.EnterRoom") forState:UIControlStateNormal];
    _inputRoomLabel.adjustsFontSizeToFitWidth = true;
    _inputUserLabel.adjustsFontSizeToFitWidth = true;
    _roleLabel.adjustsFontSizeToFitWidth = true;
    _anchorButton.titleLabel.adjustsFontSizeToFitWidth = true;
    _audienceButton.titleLabel.adjustsFontSizeToFitWidth = true;
    _enterRoomButton.titleLabel.adjustsFontSizeToFitWidth = true;
}

- (void)setupRandomId {
    _roomIdTextField.text = @"1356732";
    _userIdTextField.text = [NSString generateRandomUserId];
}

- (IBAction)onAnchorClick:(UIButton*)sender {
    _isAnchorChoose = true;
    _anchorButton.backgroundColor = [UIColor themeGreenColor];
    _audienceButton.backgroundColor = [UIColor hexColor:@"#d8d8d8"];
}

- (IBAction)onAudienceClick:(UIButton *)sender {
    _isAnchorChoose = false;
    _anchorButton.backgroundColor = [UIColor hexColor:@"#d8d8d8"];
    _audienceButton.backgroundColor = [UIColor themeGreenColor];
}

- (IBAction)onEnterRoomClick:(UIButton *)sender {
    if (_isAnchorChoose) {
        if (@available(iOS 13.0, *)) {
            ScreenAnchorViewController *anchroVC = [[ScreenAnchorViewController
                                        alloc] initWithNibName:@"ScreenAnchorViewController" bundle:nil];
            anchroVC.roomId = [_roomIdTextField.text intValue];
            anchroVC.userId = _userIdTextField.text;
            [self.navigationController pushViewController:anchroVC  animated:YES];
        } else {
            [self showAlertViewController:Localize(@"TRTC-API-Example.ScreenEntrance.versionTips") message:nil handler:nil];
        }
    } else {
        ScreenAudienceViewController *audienceVC = [[ScreenAudienceViewController alloc] initWithNibName:@"ScreenAudienceViewController" bundle:nil];
        audienceVC.roomId = [_roomIdTextField.text intValue];
        audienceVC.userId = _userIdTextField.text;
        [self.navigationController pushViewController:audienceVC  animated:YES];
    }
}

@end
