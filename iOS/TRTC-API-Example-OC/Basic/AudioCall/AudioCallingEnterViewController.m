//
//  AudioCallingEnterViewController.m
//  TRTC-API-Example-OC
//
//  Created by bluedang on 2021/4/14.
//


#import "AudioCallingEnterViewController.h"
#import "AudioCallingViewController.h"

@interface AudioCallingEnterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *roomIdTextField;
@property (weak, nonatomic) IBOutlet UILabel *inputRoomLabel;
@property (weak, nonatomic) IBOutlet UILabel *inputUserLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@end

@implementation AudioCallingEnterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDefaultUIConfig];
    [self setupRandomId];
}

- (void)setupDefaultUIConfig {
    self.title = Localize(@"TRTC-API-Example.AudioCallingEnter.Title");
    _inputRoomLabel.text = Localize(@"TRTC-API-Example.AudioCallingEnter.EnterRoomNumber");
    _inputUserLabel.text = Localize(@"TRTC-API-Example.AudioCallingEnter.EnterUserName");
    [_startButton setTitle:Localize(@"TRTC-API-Example.AudioCallingEnter.EnterRoom") forState:UIControlStateNormal];
}

- (void)setupRandomId {
    _roomIdTextField.text = @"1356732";
    _userIdTextField.text = [NSString generateRandomUserId];
}

- (IBAction)onStartClick:(id)sender {    
    AudioCallingViewController *audioCallingVC = [[AudioCallingViewController alloc] initWithRoomId:[_roomIdTextField.text intValue] userId:_userIdTextField.text];
    
    [self.navigationController pushViewController:audioCallingVC animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:true];
}

@end
