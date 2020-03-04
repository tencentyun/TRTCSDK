/*
* Module:   UIButton(TRTC)
*
* Function: 标准化UIButton控件，用于text button和icon button
*           TRTCIconButton用于图片的contentMode
*
*/

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton(TRTC)

+ (instancetype)trtc_cellButtonWithTitle:(NSString *)title;

+ (instancetype)trtc_iconButtonWithImage:(UIImage *)image;

- (void)setupBackground;

@end


@interface TRTCIconButton : UIButton

@end

NS_ASSUME_NONNULL_END
