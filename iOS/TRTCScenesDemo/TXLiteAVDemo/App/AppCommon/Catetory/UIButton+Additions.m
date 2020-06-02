//
//  UIButton+Additions.m
//  RacingUKiPad
//
//  Created by Neil Edwards on 26/09/2013.
//  Copyright (c) 2013 racinguk. All rights reserved.
//

#import "UIButton+Additions.h"
#import <objc/runtime.h>

@implementation UIButton (Additions)

static char dataProviderKey;

- (NSObject *)dataProvider {
    return objc_getAssociatedObject(self, &dataProviderKey);
}

- (void)setDataProvider:(NSObject *)dataProvider {
    objc_setAssociatedObject(self, &dataProviderKey, dataProvider, OBJC_ASSOCIATION_RETAIN);
}

@end
