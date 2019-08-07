//
//  ControlView.h
//  BeautyDemo
//
//  Created by kennethmiao on 17/5/9.
//  Copyright © 2017年 kennethmiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ControlViewDelegate <NSObject>
- (void)switchCamera;
- (void)hiddenBeauty;
@end
@interface ControlView : UIView
@property (nonatomic, weak) id<ControlViewDelegate> delegate;
+ (CGSize)getSize;
@end
