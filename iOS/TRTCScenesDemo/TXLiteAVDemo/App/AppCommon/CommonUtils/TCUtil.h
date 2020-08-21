/**
 * Module: TCUtil
 *
 * Function: 实用函数
 */

#import <UIKit/UIKit.h>
#import "TCLog.h"


#define IPHONE_X \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

typedef void(^videoIsReadyBlock)(void);

@interface TCUtil : NSObject

+ (NSData *)dictionary2JsonData:(NSDictionary *)dict;

+ (NSDictionary *)jsonData2Dictionary:(NSString *)jsonData;

+ (NSString *)getFileCachePath:(NSString *)fileName;

+ (NSUInteger)getContentLength:(NSString*)string;

+ (void)asyncSendHttpRequest:(NSDictionary*)param handler:(void (^)(int resultCode, NSDictionary* resultDict))handler;
+ (void)asyncSendHttpRequest:(NSString*)command params:(NSDictionary*)params handler:(void (^)(int resultCode, NSString* message, NSDictionary* resultDict))handler;
+ (void)asyncSendHttpRequest:(NSString*)command token:(NSString*)token params:(NSDictionary*)params handler:(void (^)(int resultCode, NSString* message, NSDictionary* resultDict))handler;


+ (NSString *)transImageURL2HttpsURL:(NSString *)httpURL;

+ (NSString*)getStreamIDByStreamUrl:(NSString*) strStreamUrl;

+ (UIImage *)gsImage:(UIImage *)image withGsNumber:(CGFloat)blur;

+ (UIImage*)scaleImage:(UIImage *)image scaleToSize:(CGSize)size;

+ (UIImage *)clipImage:(UIImage *)image inRect:(CGRect)rect;

+ (void)toastTip:(NSString*)toastInfo parentView:(UIView *)parentView;

+ (float)heightForString:(UITextView *)textView andWidth:(float)width;

+ (BOOL)isSuitableMachine:(int)targetPlatNum;

// - Remove From Github
#pragma mark - 分享相关
+ (void)initializeShare;

+ (void)dismissShareDialog;

@end


// 频率控制类，如果频率没有超过 nCounts次/nSeconds秒，canTrigger将返回true
@interface TCFrequeControl : NSObject

- (instancetype)initWithCounts:(NSInteger)counts andSeconds:(NSTimeInterval)seconds;
- (BOOL)canTrigger;

@end


// 日志
#ifdef DEBUG

#ifndef DebugLog
//#define DebugLog(fmt, ...) NSLog((@"[%s Line %d]" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define DebugLog(fmt, ...) [[TCLog shareInstance] log:fmt, ##__VA_ARGS__]
#endif

#else

#ifndef DebugLog
#define DebugLog(fmt, ...)  [[TCLog shareInstance] log:fmt, ##__VA_ARGS__]
#endif
#endif

#ifndef TC_PROTECT_STR
#define TC_PROTECT_STR(x) (x == nil ? @"" : x)
#endif

