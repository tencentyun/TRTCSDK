/*
* Module:   TRTCSettingsMessageCell
*
* Function: 配置列表Cell，右侧是一个输入框和一个发送Button，用于消息发送
*
*/

#import "TRTCSettingsBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCSettingsMessageCell : TRTCSettingsBaseCell

@end


@interface TRTCSettingsMessageItem : TRTCSettingsBaseItem

@property (copy, nonatomic) NSString *placeHolder;
@property (copy, nonatomic, nullable) NSString *content;
@property (copy, nonatomic, nullable) NSString *actionTitle;
@property (copy, nonatomic, readonly, nullable) void (^action)(NSString * _Nullable content);

- (instancetype)initWithTitle:(NSString *)title
                  placeHolder:(NSString *)placeHolder
                      content:(NSString * _Nullable)content
                  actionTitle:(NSString *)actionTitle
                       action:(void (^)(NSString * _Nullable content))action NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithTitle:(NSString *)title
                  placeHolder:(NSString *)placeHolder
                       action:(void (^)(NSString * _Nullable content))action;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
