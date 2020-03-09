/*
 * Module:   TRTCNewWindowController
 *
 * Function: 该界面可以让用户输入一个【房间号】和一个【用户名】
 *
 * Notice:
 *
 *  （1）房间号为数字类型，用户名为字符串类型
 *
 *  （2）在真实的使用场景中，房间号大多不是用户手动输入的，而是系统分配的，
 *       比如视频会议中的会议号是会控系统提前预定好的，客服系统中的房间号也是根据客服员工的工号决定的。
 */

#import "TRTCNewWindowController.h"
#import "SDKHeader.h"
#import "GenerateTestUserSig.h"
#import "TRTCSettingWindowController.h"

@interface TRTCNewWindowController()
{
    NSArray *_users;
    TRTCAppScene _scene;
}
@end

@implementation TRTCNewWindowController

- (void)windowDidLoad {
    [super windowDidLoad];

    NSMutableString *alertMessage = [[NSMutableString alloc] init];
    if (_SDKAppID == 0) {
        [alertMessage appendString:@"请在 GenerateTestUserSig.h 中填写 _SDKAppID。"];
    }
    if (_SECRETKEY.length == 0) {
        [alertMessage appendString:@"请在 GenerateTestUserSig.h 中填写 _SECRETKEY。"];
    }
    if (alertMessage.length > 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = alertMessage;
        [alert runModal];
    }

    [TRTCCloud setLogCompressEnabled:NO];
    [TRTCCloud setConsoleEnabled:YES];
}

- (void)alert:(NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:message];
    [alert setAlertStyle:NSAlertStyleInformational];
    [alert runModal];
}

- (IBAction)onSelectRoomScene:(NSButton *)sender {
    if (sender.tag == 0) {
        _scene = TRTCAppSceneLIVE;
    } else {
        _scene = TRTCAppSceneVideoCall;
    }
}

- (void)controlTextDidChange:(NSNotification *)notification {
    if (notification.object == self.roomidField) {
        NSInteger roomID = self.roomidField.integerValue;
        if (roomID > 0) {
            self.roomidField.stringValue = @(self.roomidField.integerValue).stringValue;
        } else {
            self.roomidField.stringValue = @"";
        }
        [[NSUserDefaults standardUserDefaults] setObject:self.roomidField.stringValue
                                                  forKey:@"login_roomID"];
    }
}

/**
 *  Function: 读取用户输入，并创建（或加入）音视频房间
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
- (IBAction)enter:(id)sender {
    if (self.roomidField.stringValue.length == 0) {
        [self alert: @"请输入正确的房间号"];
        return;
    }
    NSInteger roomID = self.roomidField.integerValue;
    if (roomID < 0) {
        [self alert: @"房间号必须是正整数"];
        return;
    }

    if (self.useridField.stringValue.length == 0) {
        [self alert: @"请输入正确的房间号和用户名"];
        return;
    }
    [self loginWithAppID:_SDKAppID roomID:self.roomidField.stringValue userID:self.useridField.stringValue];
}

- (void)enterRoomWithParam:(TRTCParams *)params {
    if (self.onLogin) {
        self.onLogin(params);
    }
}

- (void)loginWithAppID:(UInt32)sdkAppID roomID:(NSString *)roomID userID:(NSString *)userID {
    TRTCParams *param = [[TRTCParams alloc] init];
    param.sdkAppId = sdkAppID;
    param.userId = userID;
    param.userSig = [GenerateTestUserSig genTestUserSig:userID];
    param.roomId = (UInt32)roomID.integerValue;
    param.role = TRTCSettingWindowController.isAudience ? TRTCRoleAudience : TRTCRoleAnchor;
    [self enterRoomWithParam:param];
}

@end
