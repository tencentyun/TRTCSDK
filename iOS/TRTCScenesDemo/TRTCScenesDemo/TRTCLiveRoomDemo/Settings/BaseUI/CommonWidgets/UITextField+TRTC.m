/*
* Module:   UITextField(TRTC)
*
* Function: 标准化UITextField控件，包括placeHolder标准化风格定义
*
*/

#import "UITextField+TRTC.h"
#import "ColorMacro.h"

@implementation UITextField(TRTC)

+ (instancetype)trtc_textFieldWithDelegate:(id<UITextFieldDelegate>)delegate {
    UITextField *textField = [[UITextField alloc] init];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.backgroundColor = UIColorFromRGB(0x4A4A4A);
    textField.textColor = UIColorFromRGB(0x939393);
    textField.font = [UIFont systemFontOfSize:15];
    textField.delegate = delegate;
    return textField;
}

+ (NSAttributedString *)trtc_textFieldPlaceHolderFor:(NSString *)placeHolder {
    NSDictionary *attributes = @{
        NSForegroundColorAttributeName : UIColorFromRGB(0x888888),
        NSFontAttributeName : [UIFont systemFontOfSize:15]
    };
    return [[NSAttributedString alloc] initWithString:placeHolder attributes:attributes];
}

@end
