//
//  UIViewController+APM.m
//  TXLiteAVDemo_Enterprise
//
//  Created by sherlock on 2018/7/4.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "UIViewController+APM.h"
#import <objc/runtime.h>
#import <QAPM/QAPM.h>

@implementation UIViewController (APM)


+(void)load{
    Method fromMethed = class_getInstanceMethod([self class], @selector(viewDidDisappear:));
    Method toMethed = class_getInstanceMethod([self class], @selector(swizzingViewDidDisappear:));
    if(!class_addMethod([UIViewController class], @selector(viewDidDisappear:), method_getImplementation(toMethed), method_getTypeEncoding(toMethed))){
        method_exchangeImplementations(fromMethed, toMethed);
    }
}

-(void)swizzingViewDidDisappear:(BOOL)animated{
    //[QAPMPerformanceProfile beginScene:nil withMode:QAPMMoniterTypeMemoryLeak];
    [self swizzingViewDidDisappear:animated];
}

@end
