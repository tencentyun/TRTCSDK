/*
* Module:   TRTCAudioRecordManager
*
* Function: TRTC SDK的录音功能调用
*
*    1. 音频的文件名生成方式定义在generateFilePath中，app可更改生成方式和保存的目录
*
*/

#import <Foundation/Foundation.h>
#import "TRTCCloud.h"
#import "TRTCCloudDef.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCAudioRecordManager : NSObject

@property (nonatomic, readonly) BOOL isRecording;
@property (strong, nonatomic, nullable, readonly) NSString *audioFilePath;

- (instancetype)initWithTrtc:(TRTCCloud *)trtc NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/// 开启音频录制
/// @note 音频会保存到Documents目录中，文件名是录制时时间戳，扩展名是acc
- (void)startRecord;

/// 结束录制
- (void)stopRecord;

@end

NS_ASSUME_NONNULL_END
