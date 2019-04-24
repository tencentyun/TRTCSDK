//
//  TextCell.h
//  BeautyDemo
//
//  Created by kennethmiao on 17/5/9.
//  Copyright © 2017年 kennethmiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface  TextCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *label;
- (void)setSelected:(BOOL)selected;
+ (NSString *)reuseIdentifier;
@end
