/*
 * Module:   TRTCVideoViewLayout
 * 
 * Function: 用于计算每个视频画面的位置排布和大小尺寸
 *
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TCLayoutType) {
    TC_Float,   // 前后堆叠模式
    TC_Gird,    // 九宫格模式
};

@interface TRTCVideoViewLayout : NSObject

@property UIView *view;           // 主view

@property (nonatomic) TCLayoutType type;

@property NSArray<UIView *> *subViews;

- (void)relayout:(NSArray<UIView *> *)players;


@end

NS_ASSUME_NONNULL_END
