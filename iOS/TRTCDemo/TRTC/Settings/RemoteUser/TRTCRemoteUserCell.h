/*
* Module:   TRTCRemoteUserCell
*
* Function: 远端用户列表页的用户Cell
*
*    1. TRTCRemoteUserItem中保存设置给Cell的用户数据
*
*/

#import "TRTCSettingsBaseCell.h"
#import "TRTCRemoteUserConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCRemoteUserCell : TRTCSettingsBaseCell

@end


@interface TRTCRemoteUserItem : TRTCSettingsBaseItem

@property (copy, nonatomic, readonly) NSString *userId;
@property (strong, nonatomic, readonly) TRTCRemoteUserConfig *memberSettings;

- (instancetype)initWithUser:(NSString *)userId settings:(TRTCRemoteUserConfig *)memberSettings NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
