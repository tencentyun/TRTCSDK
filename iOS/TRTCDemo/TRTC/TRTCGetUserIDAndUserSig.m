/*
 * Module:   TRTCGetUserIDAndUserSig
 * 
 * Function: 用于获取组装 TRTCParam 所必须的 UserSig，腾讯云使用 UserSig 进行安全校验，保护您的 TRTC 流量不被盗用
 */

#import "TRTCGetUserIDAndUserSig.h"
#import "AFNetworking.h"

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

- (void)getUserSigFromServer:(NSString *)userID pwd:(NSString *)pwd roomID:(uint32_t)roomID sdkappid:(uint32_t)sdkappid withCompletion:(void (^)(NSString *userSig, NSString *error))completion {
    NSDictionary *reqParam = @{@"identifier": userID, @"pwd": pwd, @"appid": @(sdkappid), @"roomnum": @(roomID), @"privMap": @(255)};
    NSString *reqUrl = @"https://www.qcloudtrtc.com/sxb_dev/?svc=account&cmd=authPrivMap";
    
    [self POST:reqUrl parameters:reqParam retryCount:0 retryLimit:5 progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            id data = responseObject[@"data"];
            id userSig = data[@"userSig"];
            NSLog(@"getUserSigFromServer:[%@]", responseObject);
            NSString *error;
            if (userSig == nil ) {
                error = [NSString stringWithFormat:@"getUserSigFromServer:[%@]", [responseObject description]];
            }
            
            if (completion) {
                completion(userSig, error);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(nil, @"网络错误");
            }
        });
    }];
}

// 网络请求包装，每次请求重试若干次
- (void)POST:(NSString *)URLString
  parameters:(id)parameters
  retryCount:(NSInteger)retryCount
  retryLimit:(NSInteger)retryLimit
    progress:(void (^)(NSProgress * _Nonnull))uploadProgress
     success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
     failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    
    AFHTTPSessionManager *_httpSession;
    _httpSession = [AFHTTPSessionManager manager];
    [_httpSession setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [_httpSession setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [_httpSession.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    _httpSession.requestSerializer.timeoutInterval = 5.0;
    [_httpSession.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    _httpSession.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml", @"text/plain", nil];
    __weak AFHTTPSessionManager *w_session = _httpSession;
    
    [_httpSession POST:URLString parameters:parameters progress:uploadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(task,responseObject);
        [w_session invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (retryCount < retryLimit) {
            // 1秒后重试
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self POST:URLString parameters:parameters retryCount:retryCount+1 retryLimit:retryLimit progress:uploadProgress success:success failure:failure];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    failure(task, error);
                }
            });
        }
        [w_session invalidateSessionCancelingTasks:YES];
    }];
}
@end
