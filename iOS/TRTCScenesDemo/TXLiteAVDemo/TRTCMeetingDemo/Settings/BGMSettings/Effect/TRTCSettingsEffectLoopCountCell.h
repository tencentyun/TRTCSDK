/*
* Module:   TRTCSettingsEffectLoopCountCell
*
* Function: 全局设置音效循环次数，以及停止所有音效播放
*
*/

#import "TRTCSettingsBaseCell.h"
#import "TRTCCustomAudioEffectManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCSettingsEffectLoopCountCell : TRTCSettingsBaseCell

@end


@interface TRTCSettingsEffectLoopCountItem : TRTCSettingsBaseItem

@property (strong, nonatomic, readonly) TRTCCustomAudioEffectManager *manager;

- (instancetype)initWithManager:(TRTCCustomAudioEffectManager *)manager NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
