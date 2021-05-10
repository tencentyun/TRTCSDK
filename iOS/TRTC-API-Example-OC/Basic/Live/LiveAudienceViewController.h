//
//  LiveAudienceViewController.h
//  TRTC-API-Example-OC
//
//  Created by adams on 2021/4/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveAudienceViewController : UIViewController

- (instancetype)initWithRoomId:(UInt32)roomId userId:(NSString *)userId;

@end

NS_ASSUME_NONNULL_END
