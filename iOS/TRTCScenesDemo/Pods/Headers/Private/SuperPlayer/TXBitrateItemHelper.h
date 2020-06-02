//
//  TXBitrateItemHelper.h
//  SuperPlayer
//
//  Created by annidyfeng on 2018/9/28.
//

#import <Foundation/Foundation.h>
#import "SuperPlayerModel.h"
#import "SuperPlayer.h"

@class TXBitrateItem;
@interface TXBitrateItemHelper : NSObject
@property NSInteger bitrate;
@property NSString *title;
@property int index;

+ (NSArray<SuperPlayerUrl *> *)sortWithBitrate:(NSArray<TXBitrateItem *> *)bitrates;


@end
