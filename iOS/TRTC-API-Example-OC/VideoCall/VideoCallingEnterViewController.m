//
//  VideoCallingEnterViewController.m
//  TRTC-API-Example-OC
//
//  Created by bluedang on 2021/4/12.
//
//  TRTC 视频通话入口界面
//  包含如下功能：
//  1、 进入房间，生成音频通话界面

#import "VideoCallingEnterViewController.h"
#import "VideoCallingViewController.h"

@interface VideoCallingEnterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *roomIdTextField;
@property (weak, nonatomic) IBOutlet UILabel *inputRoomLabel;
@property (weak, nonatomic) IBOutlet UILabel *inputUserLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@end

@implementation VideoCallingEnterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDefaultUIConfig];
    [self setupRandomId];
}

- (void)setupDefaultUIConfig {
    self.title = Localize(@"TRTC-API-Example.VideoCallingEnter.Title");
    _inputRoomLabel.text = Localize(@"TRTC-API-Example.VideoCallingEnter.EnterRoomNumber");
    _inputUserLabel.text = Localize(@"TRTC-API-Example.VideoCallingEnter.EnterUserName");
    [_startButton setTitle:Localize(@"TRTC-API-Example.VideoCallingEnter.EnterRoom") forState:UIControlStateNormal];
}

- (void)setupRandomId {
    _roomIdTextField.text = @"1356732";
    _userIdTextField.text = [NSString generateRandomUserId];
}

- (IBAction)onStartClick:(id)sender {
    VideoCallingViewController *videoCallingVC = [[VideoCallingViewController alloc]
                                                  initWithRoomId:[_roomIdTextField.text intValue]
                                                  userId:_userIdTextField.text];
    [self.navigationController pushViewController:videoCallingVC animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:true];
}

@end
