/*
 * Module:   TRTCVideoViewLayout
 * 
 * Function: 用于对视频通话的分辨率、帧率和流畅模式进行调整，并支持记录下这些设置项
 *
 */

#import <UIKit/UIKit.h>


@interface TRTCSettingsProperty : NSObject
@property(nonatomic, assign)int resolution;
@property(nonatomic, assign)int fps;
@property(nonatomic, assign)int bitRate;
@property(nonatomic, assign)int qosType;
@property(nonatomic, assign)int qosControl;
@property(nonatomic, assign)int resMode;
@property(nonatomic, assign)BOOL enableSmallStream;
@property(nonatomic, assign)BOOL priorSmallStream;
@end

@class TRTCSettingViewController;

/* 分辨率，帧率，码率 这三个值可以在推流过程中动态修改 */
@protocol TRTCSettingVCDelegate <NSObject>
- (void)settingVC:(TRTCSettingViewController *)settingVC Property:(TRTCSettingsProperty*)property;
@end

@interface TRTCSettingBitrateTable : NSObject
@property (nonatomic, assign) int resolution;
@property (nonatomic, assign) int defaultBitrate;
@property (nonatomic, assign) int minBitrate;
@property (nonatomic, assign) int maxBitrate;
@property (nonatomic, assign) int step;
@end

@interface TRTCSettingViewController : UIViewController
@property (nonatomic, weak) id<TRTCSettingVCDelegate> delegate;

//appScene由外部传入，针对不同的场景值的参数设置有区别
+ (void)setAppScene:(int)appScene;

/* 从文件中读取配置 */
+ (int)getResolution;
+ (int)getFPS;
+ (int)getBitrate;
+ (int)getQosType;
+ (int)getQosCtrlType;
+ (int)getResMode;
+ (BOOL)getEnableSmallStream;
+ (BOOL)getPriorSmallStream;
@end
