/**
 * Module: TCLog
 *
 * Function: 日志模块
 */

#import <Foundation/Foundation.h>
#import "TXLiveBase.h"

/**
 * 获取RTMP SDK内部log，并保存到文件
 * 1.实现ITXLiveBaseListener回调接口获取RTMPSDK的log
 * 2.log保存到沙箱路径：Library/Caches/rtmpsdk_日期.log
 *   其中日期以天为单位，每天保存一个文件，如rtmpsdk_20160901.log
 * 3.app的log使用TXLog和RTMPSDK的log一起保存
 */
@interface TCLog : NSObject<TXLiveBaseDelegate>

+ (instancetype)shareInstance;

- (void)log:(NSString *)formatStr, ...;

- (void)onLog:(NSString*)log LogLevel:(int)level WhichModule:(NSString *)module;

@end
