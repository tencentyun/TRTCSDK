/*
* Module:   UILabel(TRTC)
*
* Function: 标准化UILabel控件，用于title和content
*
*/

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel(TRTC)

+ (instancetype)trtc_titleLabel;

+ (instancetype)trtc_contentLabel;

@end

NS_ASSUME_NONNULL_END
