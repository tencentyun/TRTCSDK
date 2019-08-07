/*
 * Module:   TRTCNewWindowController
 *
 * Function: 该界面可以让用户输入一个【房间号】和一个【用户名】
 *
 * Notice:
 *
 *  （1）房间号为数字类型，用户名为字符串类型
 *
 *  （2）在真实的使用场景中，房间号大多不是用户手动输入的，而是由后台业务服务器直接分配的，
 *       比如视频会议中的会议号是会控系统提前预定好的，客服系统中的房间号也是根据客服员工的工号决定的。
 */

#import <Cocoa/Cocoa.h>
#import "TRTCMainWindowController.h"
#import "SDKHeader.h"
// 登录
@interface TRTCNewWindowController : NSWindowController
{
    TRTCMainWindowController *_wc;
}
// 房间号输入框
@property (strong) IBOutlet NSTextField *roomidField;
@property (strong) IBOutlet NSTextField *useridField;
@property BOOL audioOnly;
- (IBAction)onSelectRoomScene:(id)sender;
@property (copy, nonatomic) void(^onLogin)(TRTCParams *param);
@end

