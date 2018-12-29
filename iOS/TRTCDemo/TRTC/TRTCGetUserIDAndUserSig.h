/*
 * Module:   TRTCGetUserIDAndUserSig
 * 
 * Function: 用于获取组装 TRTCParam 所必须的 UserSig，腾讯云使用 UserSig 进行安全校验，保护您的 TRTC 流量不被盗用
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TRTCGetUserIDAndUserSig : NSObject

@property (readonly) uint32_t   configSdkAppid;
@property (readonly) NSArray   *configUserIdArray;
@property (readonly) NSArray   *configUserSigArray;

/**
 * 从本地的测试用配置文件中读取一批userid 和 usersig
 * 配置文件可以通过访问腾讯云TRTC控制台（https://console.cloud.tencent.com/rav）中的【快速上手】页面来获取
 * 配置文件中的 userid 和 usersig 是由腾讯云预先计算生成的，每一组 usersig 的有效期为 180天
 *
 * 该方案仅适合本地跑通demo和功能调试，产品真正上线发布，要使用服务器获取方案，即 getUserSigFromServer
 *
 * 参考文档：https://cloud.tencent.com/document/product/647/17275#GetForDebug
 *
 */
- (void)loadFromConfig;

/**
 * 通过 http 请求到客户的业务服务器上获取 userid 和 usersig
 * 这种方式可以将签发 usersig 的计算工作放在您的业务服务器上进行，这样一来，usersig 的签发工作就可以安全可控
 *
 * 但本demo中的 getUserSigFromServer 函数仅作为示例代码，要跑通该逻辑，您需要参考：https://cloud.tencent.com/document/product/647/17275#GetFromServer
 */
- (void)getUserSigFromServer:(NSString *)userID pwd:(NSString *)pwd roomID:(uint32_t)roomID sdkappid:(uint32_t)sdkappid withCompletion:(void (^)(NSString *userSig, NSString *error))completion;

@end

NS_ASSUME_NONNULL_END
