//
//  TRTCFloatWindow.h
//  TXLiteAVDemo
//
//  Created by rushanting on 2019/5/15.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TRTCFloatWindow : NSObject

@property (nonatomic, retain) UIView* localView;    //本地预览view
@property (nonatomic, retain) NSMutableDictionary* remoteViewDic;   //远端画面

/// 点击小窗返回的controller
@property UIViewController *backController;

+ (instancetype)sharedInstance;

//浮窗显示
- (void)show;

//返回backController
- (void)back;

//关闭浮窗
- (void)close;

@end

NS_ASSUME_NONNULL_END
