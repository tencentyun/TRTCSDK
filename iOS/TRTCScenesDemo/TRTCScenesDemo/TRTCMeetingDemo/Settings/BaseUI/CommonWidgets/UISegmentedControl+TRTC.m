/*
* Module:   UISegmentedControl(TRTC)
*
* Function: 标准化UISegmentedControl控件
*
*/

#import "UISegmentedControl+TRTC.h"
#import "ColorMacro.h"

@implementation UISegmentedControl(TRTC)

+ (instancetype)trtc_segment {
    UISegmentedControl *segment = [[UISegmentedControl alloc] init];
    // TODO: Uncomment this when RDM supports Xcode 11
//    if (@available(iOS 13.0, *)) {
//        segment.selectedSegmentTintColor = UIColorFromRGB(0x05a764);
//    } else {
//        segment.tintColor = UIColorFromRGB(0x05a764);
//    }
    
    if (@available(iOS 13.0, *)) {
        [segment setTitleTextAttributes:@{ NSForegroundColorAttributeName : UIColorFromRGB(0x05a764) }
                               forState:UIControlStateSelected];
    } else {
        segment.tintColor = UIColorFromRGB(0x05a764);
        [segment setTitleTextAttributes:@{ NSForegroundColorAttributeName : UIColor.whiteColor }
                               forState:UIControlStateSelected];
    }
    [segment setTitleTextAttributes:@{ NSForegroundColorAttributeName : UIColorFromRGB(0x939393) }
                           forState:UIControlStateNormal];
    
    return segment;
}

@end
