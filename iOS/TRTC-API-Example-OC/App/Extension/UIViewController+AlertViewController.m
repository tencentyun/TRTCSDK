//
//  UIViewController+AlertViewController.m
//  TRTC-API-Example-OC
//
//  Created by adams on 2021/4/15.
//

#import "UIViewController+AlertViewController.h"
#import <Photos/Photos.h>
@implementation UIViewController (AlertViewController)

- (void)showAlertViewController:(NSString *)title message:(NSString *)message handler:(void (^ __nullable)(UIAlertAction *action))handler {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:Localize(@"TRTC-API-Example.AlertViewController.determine") style:UIAlertActionStyleDefault handler:handler];
    [alertVC addAction:alertAction];
    [self presentViewController:alertVC animated:true completion:nil];
}

- (void)requestPhotoAuthorization:(void(^)(void))handler {
    if (@available(iOS 14, *)) {
        PHAccessLevel level = PHAccessLevelReadWrite;
        [PHPhotoLibrary requestAuthorizationForAccessLevel:level handler:^(PHAuthorizationStatus status) {
            switch (status) {
                case PHAuthorizationStatusLimited:
                    handler();
                    break;
                case PHAuthorizationStatusAuthorized:
                    handler();
                    break;
                default:
                    break;
            }
        }];
    } else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            switch (status) {
                case PHAuthorizationStatusAuthorized:
                    handler();
                    break;
                default:
                    break;
            }
        }];
    }
}

@end
