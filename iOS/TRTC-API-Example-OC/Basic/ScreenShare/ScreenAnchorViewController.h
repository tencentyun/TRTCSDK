//
//  ScreenAnchorViewController.h
//  TRTC-API-Example-OC
//
//  Created by bluedang on 2021/4/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//MARK: 屏幕录制直播示例 - 主播界面
@interface ScreenAnchorViewController : UIViewController
@property (assign, nonatomic) UInt32 roomId;
@property (strong, nonatomic) NSString* userId;
@end

NS_ASSUME_NONNULL_END
