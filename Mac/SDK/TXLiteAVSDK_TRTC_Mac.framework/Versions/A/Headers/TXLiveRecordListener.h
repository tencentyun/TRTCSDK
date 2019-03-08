#import "TXLiveRecordTypeDef.h"


/**********************************************
 **************  短视频录制回调定义  **************
 **********************************************/
@protocol TXLiveRecordListener <NSObject>

/**
 * 短视频录制进度
 */
@optional
-(void) onRecordProgress:(NSInteger)milliSecond;

/**
 * 短视频录制完成
 */
@optional
-(void) onRecordComplete:(TXRecordResult*)result;

/**
 * 短视频录制事件通知
 */
@optional
-(void) onRecordEvent:(NSDictionary*)evt;

@end


