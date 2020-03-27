/**
 * Module: TCMsgBarrageView
 *
 * Function: 弹幕
 */

#import <UIKit/UIKit.h>
#import "TCMsgModel.h"

/**
 *  TCMsgBulletView 类说明：
 *  当前类主要是展示用户发送的弹幕消息，里面可以自定义弹幕的效果
 */

@interface TCMsgBarrageView : UIView
/**
 *  记录当前TCMsgBulletView最后一个弹幕View，通过弹幕View frame 判断下一个弹幕消息显示在哪个TCMsgBulletView
 */
@property(nonatomic,retain) UIView *lastAnimateView;

/**
 *  给弹幕view 发送msgModel消息
 *
 *  @param msgModel 弹幕消息
 */
- (void)bulletNewMsg:(TCMsgModel *)msgModel;

/**
 *  停止动画，移除动画view
 */
- (void)stopAnimation;

@end
