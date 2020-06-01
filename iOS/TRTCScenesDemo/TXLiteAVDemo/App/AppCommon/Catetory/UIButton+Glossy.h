#import <UIKit/UIKit.h>


@interface UIButton (Glossy)

+ (void)setPathToRoundedRect:(CGRect)rect forInset:(NSUInteger)inset inContext:(CGContextRef)context;
+ (void)drawGlossyRect:(CGRect)rect withColor:(UIColor*)color inContext:(CGContextRef)context;
+ (void)setBackgroundToGlossyButton:(UIButton*)button forColor:(UIColor*)color withBorder:(BOOL)border forState:(UIControlState)state;

@end

