//
//  ThemeConfigurator.m
//  TXLiteAVDemo
//
//  Created by cui on 2019/12/24.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "ThemeConfigurator.h"

@implementation ThemeConfigurator
+ (void)configBeautyPanelTheme:(TCBeautyPanel *)panel
{
    TCBeautyPanelTheme *theme = [[TCBeautyPanelTheme alloc] init];
    theme.beautyPanelSelectionColor = [UIColor colorWithRed:0
                                                      green:109/255.0
                                                       blue:1.0
                                                      alpha:1.0];
    theme.sliderValueColor = theme.beautyPanelSelectionColor;
    theme.beautyPanelMenuSelectionBackgroundImage = [UIImage imageNamed:@"beautyPanelMenuSelectionBackgroundImage"];
    theme.sliderThumbImage = [UIImage imageNamed:@"slider"];
    panel.theme = theme;
}
@end
