//
//  HUDHelper.h
//  
//
//  Created by Alexi on 12-11-28.
//  Copyright (c) 2012年 . All rights reserved.
//

#import "MBProgressHUD.h"

typedef void (^CommonVoidBlock)(void);

@interface HUDHelper : NSObject
{
@private
    MBProgressHUD *_syncHUD;
}

+ (HUDHelper *)sharedInstance;

+ (void)alert:(NSString *)msg;
+ (void)alert:(NSString *)msg action:(CommonVoidBlock)action;
+ (void)alert:(NSString *)msg cancel:(NSString *)cancel;
+ (void)alert:(NSString *)msg cancel:(NSString *)cancel action:(CommonVoidBlock)action;
+ (void)alertTitle:(NSString *)title message:(NSString *)msg cancel:(NSString *)cancel;
+ (void)alertTitle:(NSString *)title message:(NSString *)msg cancel:(NSString *)cancel action:(CommonVoidBlock)action;

// 网络请求
- (MBProgressHUD *)loading;
- (MBProgressHUD *)loading:(NSString *)msg;
- (MBProgressHUD *)loading:(NSString *)msg inView:(UIView *)view;


- (void)loading:(NSString *)msg delay:(CGFloat)seconds execute:(void (^)(void))exec completion:(void (^)(void))completion;

- (void)stopLoading:(MBProgressHUD *)hud;
- (void)stopLoading:(MBProgressHUD *)hud message:(NSString *)msg;
- (void)stopLoading:(MBProgressHUD *)hud message:(NSString *)msg delay:(CGFloat)seconds completion:(void (^)(void))completion;

- (void)tipMessage:(NSString *)msg;
- (void)tipMessage:(NSString *)msg delay:(CGFloat)seconds;
- (void)tipMessage:(NSString *)msg delay:(CGFloat)seconds completion:(void (^)(void))completion;

// 网络请求
- (void)syncLoading;
- (void)syncLoading:(NSString *)msg;
- (void)syncLoading:(NSString *)msg inView:(UIView *)view;

- (void)syncStopLoading;
- (void)syncStopLoadingMessage:(NSString *)msg;
- (void)syncStopLoadingMessage:(NSString *)msg delay:(CGFloat)seconds completion:(void (^)(void))completion;

@end
