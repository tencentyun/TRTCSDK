//
//  UIView+Fade.h
//  SuperPlayer
//
//  Created by annidyfeng on 2018/9/28.
//

#import <UIKit/UIKit.h>

@interface UIView (Fade)

- (UIView *)fadeShow;
- (void)fadeOut:(NSTimeInterval)delay;
- (void)cancelFadeOut;
@end
