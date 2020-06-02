//
//  PlayerSlider.h
//  Slider
//
//  Created by annidyfeng on 2018/8/27.
//  Copyright © 2018年 annidy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerPoint : NSObject
@property GLfloat where;
@property UIControl  *holder;
@property NSString *content;
@property NSInteger timeOffset;
@end

@protocol PlayerSliderDelegate <NSObject>
- (void)onPlayerPointSelected:(PlayerPoint *)point;
@end

@interface PlayerSlider : UISlider

@property NSMutableArray<PlayerPoint *> *pointArray;
@property UIProgressView *progressView;
@property (weak) id<PlayerSliderDelegate> delegate;
@property (nonatomic) BOOL hiddenPoints;

- (PlayerPoint *)addPoint:(GLfloat)where;

@end
