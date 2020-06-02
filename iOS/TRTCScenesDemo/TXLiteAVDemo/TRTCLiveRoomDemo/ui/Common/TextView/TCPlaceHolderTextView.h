//
//  UIPlaceHolderTextView.h
//  TCLVBIMDemo
//
//  Created by annidyfeng on 16/8/3.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

IB_DESIGNABLE
@interface TCPlaceHolderTextView : UITextView

@property (nonatomic, retain) IBInspectable NSString *placeholder;
@property (nonatomic, retain) IBInspectable UIColor *placeholderColor;

- (void)textChanged:(NSNotification*)notification;

@end
