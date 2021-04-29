//
//  UIViewController+AlertViewController.h
//  TRTC-API-Example-OC
//
//  Created by adams on 2021/4/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (AlertViewController)
- (void)showAlertViewController:(nullable NSString *)title message:(nullable NSString *)message handler:(void (^ __nullable)(UIAlertAction *action))handler;

- (void)requestPhotoAuthorization:(void(^)(void))handler;

@end

NS_ASSUME_NONNULL_END
