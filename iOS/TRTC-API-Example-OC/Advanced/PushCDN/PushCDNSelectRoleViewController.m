//
//  PushCDNSelectRoleViewController.m
//  TRTC-API-Example-OC
//
//  Created by abyyxwang on 2021/4/20.
//

// CDN发布功能 - 进房入口
// 1、选择角色身份，进入房间

/**
  CDN Publishing - enter
  1. Select a role and enter the room
 */

#import "PushCDNSelectRoleViewController.h"
#import "PushCDNAnchorViewController.h"
#import "PushCDNAudienceViewController.h"

typedef NS_ENUM(NSInteger, UserType) {
    Anchor,
    Audience,
};

@interface PushCDNSelectRoleViewController ()

@property (weak, nonatomic) IBOutlet UIButton *nextStepButton;
@property (weak, nonatomic) IBOutlet UILabel *tipsLable;
@property (weak, nonatomic) IBOutlet UILabel *tipItemOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipItemTowLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipItemThreeLabel;
@property (weak, nonatomic) IBOutlet UIButton *anchorButton;
@property (weak, nonatomic) IBOutlet UIButton *audienceButton;
@property (weak, nonatomic) IBOutlet UITextView *tipsTextView;

@property (assign, nonatomic) UserType userType;

@end

@implementation PushCDNSelectRoleViewController

- (void)setUserType:(UserType)userType {
    _userType = userType;
    switch (userType) {
        case Anchor:
        {
            self.anchorButton.selected = true;
            self.audienceButton.selected = false;
        }
        break;
            
        case Audience:
        {
            self.anchorButton.selected = false;
            self.audienceButton.selected = true;
        }
        break;
            
        default:
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUIConfig];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.tipsTextView setContentOffset:CGPointZero animated:false];
}

- (void)setupDefaultUIConfig {
    self.title = Localize(@"TRTC-API-Example.PushCDN.Title");
    
    [self.tipsLable setText:Localize(@"TRTC-API-Example.PushCDN.TipsTitle")];
    [self.tipItemOneLabel setText:Localize(@"TRTC-API-Example.PushCDN.TipsOne")];
    [self.tipItemTowLabel setText:Localize(@"TRTC-API-Example.PushCDN.TipsTwo")];
    [self.tipItemThreeLabel setText:Localize(@"TRTC-API-Example.PushCDN.TipsThree")];
    
    UIImage *normalBackgroundImage = [[UIColor themeGrayColor] trans2Image:CGSizeMake(1, 1)];
    UIImage *selectBackgroundImage = [[UIColor themeGreenColor] trans2Image:CGSizeMake(1, 1)];
    
    [self.anchorButton setTitle:Localize(@"TRTC-API-Example.PushCDN.AnchorStart") forState:UIControlStateNormal];
    [self.anchorButton setBackgroundImage:normalBackgroundImage forState:UIControlStateNormal];
    [self.anchorButton setBackgroundImage:selectBackgroundImage forState:UIControlStateSelected];
    
    [self.audienceButton setTitle:Localize(@"TRTC-API-Example.PushCDN.AudienceStart") forState:UIControlStateNormal];
    [self.audienceButton setBackgroundImage:normalBackgroundImage forState:UIControlStateNormal];
    [self.audienceButton setBackgroundImage:selectBackgroundImage forState:UIControlStateSelected];
    
    self.tipsTextView.text = Localize(@"TRTC-API-Example.PushCDN.TipsURL");
    [self.nextStepButton setTitle:Localize(@"TRTC-API-Example.PushCDN.NextStep") forState:UIControlStateNormal];
    
    // Layer Corner
    self.anchorButton.layer.cornerRadius = 60;
    self.anchorButton.layer.masksToBounds = YES;
    self.audienceButton.layer.cornerRadius = 60;
    self.audienceButton.layer.masksToBounds = YES;
    self.nextStepButton.layer.cornerRadius = 8;
    self.nextStepButton.layer.masksToBounds = YES;
    
    self.userType = Anchor;
}

#pragma mark - IBActions
- (IBAction)onAnchorClick:(UIButton *)sender {
    self.userType = Anchor;
}

- (IBAction)onAudienceClick:(UIButton *)sender {
    self.userType = Audience;
}

- (IBAction)onNextStepClick:(UIButton *)sender {
    switch (self.userType) {
        case Anchor:
        {
            PushCDNAnchorViewController *anchorVC = [[PushCDNAnchorViewController alloc] initWithNibName:@"PushCDNAnchorViewController" bundle:nil];
            [self.navigationController pushViewController:anchorVC animated:true];
        }
            break;
        case Audience:
        {
            PushCDNAudienceViewController *audienceVC = [[PushCDNAudienceViewController alloc] initWithNibName:@"PushCDNAudienceViewController" bundle:nil];
            [self.navigationController pushViewController:audienceVC animated:true];
        }
            break;
        default:
            break;
    }
}


@end
