//
//  CreateTRTCAudioCallViewController.m
//  TXLiteAVDemo_Professional
//
//  Created by Melody on 2019/11/18.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "CreateTRTCAudioCallViewController.h"
#import "TRTCAudioCallViewController.h"
#import "TRTCAudioCallTestUserSig.h"
#import <TRTCCloud.h>
#import <TRTCCloudDef.h>
#import "TRTCAudioCallCloudManager.h"

#import "ColorMacro.h"

#define KEY_AUDIOCALL_CURRENT_USERID      @"__audiocall_current_userid__"
#define KEY_AUDIOCALL_CURRENT_ROOMID      @"__audiocall_current_roomid__"

@interface CreateTRTCAudioCallViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *roomIdTextField;
@property (weak, nonatomic) IBOutlet UIView *roomIdLineView;
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UIView *userIdLineView;

@property (weak, nonatomic) IBOutlet UIButton *sample_48KBtn;
@property (weak, nonatomic) IBOutlet UIButton *sample_16KBtn;

@property (weak, nonatomic) IBOutlet UIButton *joinBtn;

@property (nonatomic, assign) TRTCAppScene scene;       //场景

/// 采样率，支持的值为8000, 16000, 32000, 44100, 48000
@property (nonatomic) NSInteger sampleRate;

@end

@implementation CreateTRTCAudioCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSAttributedString *attrRoomId = [[NSAttributedString alloc] initWithString:[self getRoomId] attributes:@{
        NSForegroundColorAttributeName:UIColorFromRGB(0x8c8c8c)
    }];
    self.roomIdTextField.attributedPlaceholder = attrRoomId;
    [self.roomIdLineView setBackgroundColor:UIColorFromRGB(0x8c8c8c)];

    NSAttributedString *attrUserId = [[NSAttributedString alloc] initWithString:[self getUserId] attributes:@{
        NSForegroundColorAttributeName:UIColorFromRGB(0x8c8c8c)
    }];
    self.userIdTextField.attributedPlaceholder = attrUserId;
    [self.userIdLineView setBackgroundColor:UIColorFromRGB(0x8c8c8c)];

    _sample_48KBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _sample_16KBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _sampleRate = 48000;     //默认选择高音质
    _sample_48KBtn.selected = YES;
    
    
    // 如果没有填 sdkappid 或者 secretkey，就结束流程。
    if (_SDKAppID == 0 || [_SECRETKEY isEqualToString:@""]) {
        _joinBtn.enabled = NO;
        NSString *msg = @"";
        if (_SDKAppID == 0) {
            msg = @"没有填写SDKAPPID";
        }
        if ([_SECRETKEY isEqualToString:@""]) {
            msg = [NSString stringWithFormat:@"%@ 没有填写SECRETKEY", msg];
        }
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil ];
        [ac addAction:ok];
        [self.navigationController presentViewController:ac animated:YES completion:nil];
        return;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark 如果没有填写roomId，随机生成并保存，测试用
- (NSString *)getRoomId {
    NSString* roomId = @"";
    NSObject *d = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_AUDIOCALL_CURRENT_ROOMID];
    if (d) {
        roomId = [NSString stringWithFormat:@"%@", d];
    } else {
        roomId = [NSString stringWithFormat:@"%d", (rand() % 10000) + 5];
        [[NSUserDefaults standardUserDefaults] setObject:roomId forKey:KEY_AUDIOCALL_CURRENT_ROOMID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return roomId;
}

#pragma mark 如果没有填写userid，随机生成并保存，测试用
- (NSString *)getUserId {
    NSString* userId = @"";
    NSObject *d = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_AUDIOCALL_CURRENT_USERID];
    if (d) {
        userId = [NSString stringWithFormat:@"%@", d];
    } else {
        double tt = [[NSDate date] timeIntervalSince1970];
        int user = ((uint64_t)(tt * 1000.0)) % 100000000;
        userId = [NSString stringWithFormat:@"%d", user];
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:KEY_AUDIOCALL_CURRENT_USERID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return userId;
}


#pragma mark 点击音质选择
- (IBAction)switchSample:(UIButton *)sender {
    _sample_48KBtn.selected = sender == _sample_48KBtn;
    _sample_16KBtn.selected = sender == _sample_16KBtn;
    _sampleRate = _sample_48KBtn.selected ? 48000 : 16000;
}


#pragma mark 点击加入房间
- (IBAction)onJoinBtnClicked:(id)sender {
    [self joinRoom];
}

/**
 *  Function: 读取用户输入，并创建（或加入）音频房间
 *
 *  此段示例代码最主要的作用是组装 TRTC SDK 进房所需的 TRTCParams
 *
 *  TRTCParams.sdkAppId => 可以在腾讯云实时音视频控制台（https://console.cloud.tencent.com/rav）获取
 *  TRTCParams.userId   => 此处即用户输入的用户名，它是一个字符串
 *  TRTCParams.roomId   => 此处即用户输入的音视频房间号，比如 125
 *  TRTCParams.userSig  => 此处示例代码展示了两种获取 usersig 的方式，一种是从【控制台】获取，一种是从【服务器】获取
 *
 * （1）控制台获取：可以获得几组已经生成好的 userid 和 usersig，他们会被放在一个 json 格式的配置文件中，仅适合调试使用
 * （2）服务器获取：直接在服务器端用我们提供的源代码，根据 userid 实时计算 usersig，这种方式安全可靠，适合线上使用
 *
 *  参考文档：https://cloud.tencent.com/document/product/647/17275
 */
#pragma mark 加入房间
- (void)joinRoom
{
    // 房间号，注意这里是32位无符号整型
    NSString *roomId = self.roomIdTextField.text;
    if (roomId.length == 0) {
        roomId = self.roomIdTextField.placeholder;
    }
    // 将当前userId保存，下次进来时会默认这个账号
    [[NSUserDefaults standardUserDefaults] setObject:roomId forKey:KEY_AUDIOCALL_CURRENT_ROOMID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 如果账号没填，为了简单起见，这里随机产生一个
    NSString* userId = self.userIdTextField.text;
    if(userId.length == 0) {
        userId = self.userIdTextField.placeholder;
    }
    
    // 将当前userId保存，下次进来时会默认这个账号
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:KEY_AUDIOCALL_CURRENT_USERID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // TRTC相关参数设置
    TRTCParams *param = [[TRTCParams alloc] init];
    param.sdkAppId = _SDKAppID;
    param.userId = userId;
    param.roomId = (UInt32)roomId.integerValue;
    param.userSig = [TRTCAudioCallTestUserSig genTestUserSig:userId];
    param.privateMapKey = @"";
    param.role = TRTCRoleAnchor;            //默认主播
    
    _scene = TRTCAppSceneAudioCall;      //默认直播场景
    
    TRTCCloud *trtc = [TRTCCloud sharedInstance];
    //自动接收音频数据，不接收视频数据
    [trtc setDefaultStreamRecvMode:YES video:NO];
    
    TRTCAudioCallCloudManager *manager = [[TRTCAudioCallCloudManager alloc] initWithTrtc:trtc params:param scene:_scene];
    //设置音频采样率
    [manager setSampleRate:_sampleRate];
    
    
    TRTCAudioCallViewController *vc = [[UIStoryboard storyboardWithName:@"TRTCAudioCall" bundle:nil] instantiateViewControllerWithIdentifier:@"TRTCAudioCallViewController"];
    vc.param = param;
    vc.scene = _scene;
    vc.audioCallCloudManager = manager;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.roomIdTextField) {
        [self.roomIdLineView setBackgroundColor:UIColorFromRGB(0x05A764)];
        [self.userIdLineView setBackgroundColor:UIColorFromRGB(0x8c8c8c)];
    }else if (textField == self.userIdTextField){
        [self.roomIdLineView setBackgroundColor:UIColorFromRGB(0x8c8c8c)];
        [self.userIdLineView setBackgroundColor:UIColorFromRGB(0x05A764)];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.roomIdTextField) {        //限制只能输入数字
        NSCharacterSet *numbersOnly = [NSCharacterSet characterSetWithCharactersInString:@"9876543210"];
        NSCharacterSet *characterSetFromTextField = [NSCharacterSet characterSetWithCharactersInString:string];
        
        BOOL stringIsValid = [numbersOnly isSupersetOfSet:characterSetFromTextField];
        return stringIsValid;
    }else if (textField == self.userIdTextField){       //限制只能输入数字/字母
        NSCharacterSet *numbersOnly = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz9876543210"];
        NSCharacterSet *characterSetFromTextField = [NSCharacterSet characterSetWithCharactersInString:string];
        
        BOOL stringIsValid = [numbersOnly isSupersetOfSet:characterSetFromTextField];
        return stringIsValid;
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:NO];
}

@end
