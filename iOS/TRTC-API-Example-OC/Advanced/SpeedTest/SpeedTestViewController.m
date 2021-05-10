//
//  SpeedTestViewController.m
//  TRTC-API-Example-OC
//
//  Created by bluedang on 2021/4/20.
//

/*
 网络测速功能
 TRTC 网络测速
 本文件展示如何集成网络测速
 1、网络测试 API: [self.trtcCloud startSpeedTest:SDKAppID userId:_userIdTextField.text userSig:userSig completion:
                    ^(TRTCSpeedTestResult* result, NSInteger completedCount, NSInteger totalCount){}];
 参考文档：https://cloud.tencent.com/document/product/647/32239
 */
/*
 Network Speed Testing
 TRTC Network Speed Testing
 This document shows how to integrate the network speed testing capability.
 1. Test the network: [self.trtcCloud startSpeedTest:SDKAppID userId:_userIdTextField.text userSig:userSig completion:
                    ^(TRTCSpeedTestResult* result, NSInteger completedCount, NSInteger totalCount){}]
 Documentation: https://cloud.tencent.com/document/product/647/32239
 */

#import "SpeedTestViewController.h"

@interface SpeedTestViewController () <TRTCCloudDelegate>
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedTestLabel;
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextView *speedResultTextView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (strong, nonatomic) TRTCCloud *trtcCloud;
@property (assign, nonatomic) BOOL isSpeedTesting;
@end

@implementation SpeedTestViewController

- (TRTCCloud*)trtcCloud {
    if (!_trtcCloud) {
        _trtcCloud = [TRTCCloud sharedInstance];
    }
    return _trtcCloud;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isSpeedTesting = false;
    self.trtcCloud.delegate = self;
    [self setupRandomId];
    [self setupDefaultUIConfig];
}

- (void)setupDefaultUIConfig {
    self.title = Localize(@"TRTC-API-Example.SpeedTest.title");
    _userIdLabel.text = Localize(@"TRTC-API-Example.SpeedTest.userId");
    _speedTestLabel.text = Localize(@"TRTC-API-Example.SpeedTest.speedTestResult");
    [_startButton setTitle:Localize(@"TRTC-API-Example.SpeedTest.beginTest")
                  forState:UIControlStateNormal];
    _userIdLabel.adjustsFontSizeToFitWidth = true;
    _speedTestLabel.adjustsFontSizeToFitWidth = true;
    _startButton.adjustsImageWhenHighlighted = true;
}

- (void)setupRandomId {
    _userIdTextField.text = [NSString generateRandomUserId];
}

- (void)beginSpeedTest {
    _isSpeedTesting = true;
    
    NSString* userSig = [GenerateTestUserSig genTestUserSig:_userIdTextField.text];
    
    __weak typeof(self) weakSelf = self;
    [self.trtcCloud startSpeedTest:SDKAppID userId:_userIdTextField.text userSig:userSig completion:
     ^(TRTCSpeedTestResult* result, NSInteger completedCount, NSInteger totalCount){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSString *printResult = [[NSString alloc]
                                 initWithFormat:@"current server：%ld, total server: %ld\n"
                                 "current ip: %@, quality: %ld, upLostRate: %.2f%%\n"
                                 "downLostRate: %.2f%%, rtt: %u\n\n", (long)completedCount,
                                 (long)totalCount, result.ip, result.quality, result.upLostRate * 100,
                                 result.downLostRate * 100, result.rtt];
        
        strongSelf.speedResultTextView.text = [strongSelf.speedResultTextView.text stringByAppendingString:printResult];
        
        if (completedCount == totalCount) {
            self.isSpeedTesting = false;
            [self.startButton setTitle:Localize(@"TRTC-API-Example.SpeedTest.completedTest")
                              forState:UIControlStateNormal];
            return;
        }
        
        float percent = completedCount / (float)totalCount;
        NSString *strPercent = [[NSString alloc] initWithFormat:@"%.2f %%", percent * 100];
        [strongSelf.startButton setTitle:strPercent forState:UIControlStateNormal];
    }];
}

- (IBAction)onStartButtonClick:(UIButton*)sender {
    if (_isSpeedTesting) {
        return;
    }
    
    if ([_startButton isSelected]) {
        [_startButton setTitle:Localize(@"TRTC-API-Example.SpeedTest.beginTest")
                      forState:UIControlStateNormal];
        _speedResultTextView.text = @"";
    } else {
        [self beginSpeedTest];
        self.startButton.highlighted = true;
        [_startButton setTitle:@"0 %" forState:UIControlStateNormal];
    }
    
    _startButton.selected = !_startButton.selected;
}

@end
