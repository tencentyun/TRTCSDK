//
//  VideoCallingViewController.h
//  TRTC-API-Example-OC
//
//  Created by bluedang on 2021/4/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//MARK: 视频通话示例 - 通话界面
@interface VideoCallingViewController : UIViewController
- (instancetype)initWithRoomId:(UInt32)roomId userId:(NSString *)userId;
@end

NS_ASSUME_NONNULL_END
