//
//  HomeTableViewCell.h
//  TRTCSimpleDemo-OC
//
//  Created by adams on 2021/4/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
static NSString *HomeTableViewCellReuseIdentify = @"HomeTableViewCell";
@interface HomeTableViewCell : UITableViewCell
- (void)setHomeDictionary:(NSDictionary *)homeDic;
@end

NS_ASSUME_NONNULL_END
