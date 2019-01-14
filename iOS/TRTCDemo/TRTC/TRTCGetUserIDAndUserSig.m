/*
 * Module:   TRTCGetUserIDAndUserSig
 * 
 * Function: 用于获取组装 TRTCParam 所必须的 UserSig，腾讯云使用 UserSig 进行安全校验，保护您的 TRTC 流量不被盗用
 */

#import "TRTCGetUserIDAndUserSig.h"

@implementation TRTCGetUserIDAndUserSig
- (instancetype)init {
    if (self = [super init]) {
        [self loadFromConfig];
    }
    
    return self;
}

- (void)loadFromConfig
{
    @try {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"json"];
        NSData *json = [NSData dataWithContentsOfFile:filePath];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingAllowFragments error:nil];
        _configSdkAppid = (uint32_t)[[dict objectForKey:@"sdkappid"] integerValue];
        NSMutableArray *userId = @[].mutableCopy;
        NSMutableArray *userToken = @[].mutableCopy;
        for (NSDictionary *user in [dict objectForKey:@"users"]) {
            [userId addObject:user[@"userId"]];
            [userToken addObject:user[@"userToken"]];
        }
        _configUserIdArray = userId;
        _configUserSigArray = userToken;
    } @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
}
@end
