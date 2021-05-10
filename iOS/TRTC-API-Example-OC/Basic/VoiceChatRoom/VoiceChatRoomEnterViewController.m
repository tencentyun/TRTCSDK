//
//  VoiceChatRoomEnterViewController.m
//  TRTCSimpleDemo-OC
//
//  Created by adams on 2021/4/14.
//

#import "VoiceChatRoomEnterViewController.h"
#import "VoiceChatRoomAnchorViewController.h"
#import "VoiceChatRoomAudienceViewController.h"

typedef NS_ENUM(NSUInteger, UserType) {
    Anchor,
    Audience,
};

@interface VoiceChatRoomEnterViewController ()
@property (weak, nonatomic) IBOutlet UILabel *enterRoomLabel;
@property (weak, nonatomic) IBOutlet UILabel *enterUserNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdentifyLabel;
@property (weak, nonatomic) IBOutlet UITextField *enterRoomTextField;
@property (weak, nonatomic) IBOutlet UITextField *enterUserNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *anchorButton;
@property (weak, nonatomic) IBOutlet UIButton *audienceButton;
@property (weak, nonatomic) IBOutlet UIButton *enterRoomButton;

@property (nonatomic, assign) UserType userType;

@end

@implementation VoiceChatRoomEnterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = Localize(@"TRTC-API-Example.VoiceChatRoom.Title");
    [self setupDefaultUIConfig];
}

- (void)setupDefaultUIConfig {
    self.enterRoomLabel.text = Localize(@"TRTC-API-Example.VoiceChatRoom.EnterRoomNumber");
    self.enterUserNameLabel.text = Localize(@"TRTC-API-Example.VoiceChatRoom.EnterUserName");
    self.userIdentifyLabel.text = Localize(@"TRTC-API-Example.VoiceChatRoom.ChooseUserIdentify");
    [self.anchorButton setTitle:Localize(@"TRTC-API-Example.VoiceChatRoom.Anchor") forState:UIControlStateNormal];
    [self.audienceButton setTitle:Localize(@"TRTC-API-Example.VoiceChatRoom.Audience") forState:UIControlStateNormal];
    [self.audienceButton setTitle:Localize(@"TRTC-API-Example.VoiceChatRoom.Audience") forState:UIControlStateNormal];
    [self.enterRoomButton setTitle:Localize(@"TRTC-API-Example.VoiceChatRoom.EnterRoom") forState:UIControlStateNormal];
    
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

- (IBAction)onEnterRoomClick:(id)sender {
    if (self.enterRoomTextField.text.length == 0 || self.enterUserNameTextField.text == 0) {
        [self showAlertViewController:Localize(@"TRTC-API-Example.AlertViewController.ponit") message:Localize(@"TRTC-API-Example.VoiceChatRoom.tips") handler:nil];
        return;
    }
    UInt32 roomId = [self.enterRoomTextField.text intValue];
    NSString *userId = self.enterUserNameTextField.text;
    switch (self.userType) {
        case Anchor:
        {
            VoiceChatRoomAnchorViewController *anchorVC =
            [[VoiceChatRoomAnchorViewController alloc] initWithRoomId:roomId userId:userId];
            anchorVC.title = LocalizeReplace(Localize(@"TRTC-API-Example.VoiceChatRoomAnchor.Title"), self.enterRoomTextField.text);
            [self.navigationController pushViewController:anchorVC animated:YES];
        }
            break;
        case Audience:
        {
            VoiceChatRoomAudienceViewController *audienceVC =
            [[VoiceChatRoomAudienceViewController alloc] initWithRoomId:roomId userId:userId];
            audienceVC.title = LocalizeReplace(Localize(@"TRTC-API-Example.VoiceChatRoomAudience.Title"), self.enterRoomTextField.text);
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
