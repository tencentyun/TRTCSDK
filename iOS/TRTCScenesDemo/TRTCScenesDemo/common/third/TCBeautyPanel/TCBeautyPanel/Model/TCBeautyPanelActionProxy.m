//
//  TCBeautyPanelActionProxy.m
//  TCBeautyPanel
//
//  Created by cui on 2019/12/23.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TCBeautyPanelActionProxy.h"

@interface NSObject (BeautyManager)
- (id)getBeautyManager;
- (void)setFilterConcentration:(float)level;
- (void)setSpecialRatio:(float)level;
@end

@implementation TCBeautyPanelActionProxy
{
    __weak id _object;
    __weak id _beautyManager;
}

+ (instancetype)proxyWithSDKObject:(id)object {
    return [[TCBeautyPanelActionProxy alloc] initWithObject:object];
}

+ (instancetype)proxyWithSDKObject:(id)object filterConcentrationSetter:(SEL)setter {
    return [[TCBeautyPanelActionProxy alloc] initWithObject:object];
}

- (instancetype)initWithObject:(id)object {
    if (![object respondsToSelector:@selector(getBeautyManager)]) {
        NSLog(@"%s failed, %@ doesn't has getBeautyManager method", __PRETTY_FUNCTION__, object);
        return nil;
    }
    id beautyManager = [object getBeautyManager];
    if (![beautyManager isKindOfClass:NSClassFromString(@"TXBeautyManager")]) {
        NSLog(@"%s failed, type mismatch of object.getBeautyManager(%@)", __PRETTY_FUNCTION__, object);
        return nil;
    }
    _object = object;
    _beautyManager = beautyManager;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    if ([_beautyManager respondsToSelector:sel]) {
        return [_beautyManager methodSignatureForSelector:sel];
    } else if ([_object respondsToSelector:sel])  {
        return [_object methodSignatureForSelector:sel];
    }

    return [super methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    SEL selector = invocation.selector;
    if ([_beautyManager respondsToSelector: selector]) {
        [invocation invokeWithTarget:_beautyManager];
    } else if ([_object respondsToSelector: selector]) {
        [invocation invokeWithTarget:_object];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([_beautyManager respondsToSelector:aSelector]) {
        return YES;
    }
    if ([_object respondsToSelector:aSelector]) {
        return YES;
    }
    return NO;
}

@end
