/*
* Module:   UITextField(TRTC)
*
* Function: 标准化UITextField控件，包括placeHolder标准化风格定义
*
*/

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextField(TRTC)

+ (instancetype)trtc_textFieldWithDelegate:(id<UITextFieldDelegate>)delegate;

+ (NSAttributedString *)trtc_textFieldPlaceHolderFor:(NSString *)placeHolder;

@end

NS_ASSUME_NONNULL_END
