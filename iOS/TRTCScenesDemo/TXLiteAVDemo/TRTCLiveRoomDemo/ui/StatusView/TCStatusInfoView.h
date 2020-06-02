/**
 * Module: TCStatusInfoView
 *
 * Function: 覆盖在播放器上面，用于显示日志信息和加载画面
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface TCStatusInfoView: NSObject

- (void)emptyPlayInfo;
- (void)startLoading;
- (void)stopLoading;
- (void)startPlay:(NSString *)playUrl;
- (void)stopPlay;

@property (nonatomic, assign) BOOL                      pending;
@property (nonatomic, strong) NSString*                 userID;
@property (nonatomic, strong) NSString*                 playUrl;
@property (nonatomic, strong) UIView*                   videoView;
@property (nonatomic, strong) UIButton*                 btnKickout;
@property (nonatomic, assign) CGRect                    linkFrame;

@end


