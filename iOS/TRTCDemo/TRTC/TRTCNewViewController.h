
/*
 * Module:   TRTCNewViewController
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

#import <UIKit/UIKit.h>

@interface TRTCNewViewController : UIViewController

@property (nonatomic, assign) NSInteger appScene;  // 应用场景：视频通话、在线直播
@property (nonatomic, strong) NSString *menuTitle; // 标题

@end
