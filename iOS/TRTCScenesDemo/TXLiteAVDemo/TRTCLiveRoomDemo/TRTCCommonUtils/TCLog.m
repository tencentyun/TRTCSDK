/**
 * Module: TCLog
 *
 * Function: 日志模块
 */


#import "TCLog.h"

@implementation TCLog
{
    NSString*   _logFilePath;
    FILE*       _pFileHandle;
}

static TCLog *_shareInstance = nil;

+ (instancetype)shareInstance {
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        _shareInstance = [[TCLog alloc] init];
    });
    return _shareInstance;
}

- (instancetype)init {
    if (self = [super init])
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES);
        NSString *path = [paths objectAtIndex:0];
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMdd";
        NSString *res = [formatter stringFromDate:date];
        _logFilePath = [NSString stringWithFormat:@"%@/Caches/rtmpsdk_%@.log",path,res];
    }
    return self;
}

- (void)dealloc {
    if (_pFileHandle)
    {
        fclose(_pFileHandle);
    }
    _pFileHandle = NULL;
}

- (void)onLog:(NSString*)log LogLevel:(int)level WhichModule:(NSString*)module {
    NSLog(@"rtmpsdk:%@",log);
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    NSString *formatDate = [formatter stringFromDate:date];
    NSString *logMsg = [NSString stringWithFormat:@"%@|level:%d|module:%@|%@\n",formatDate,level,module,log];
    [self writeLogFile:logMsg];
}

- (void)writeLogFile:(NSString*)log {
    if (_pFileHandle == NULL) {
        _pFileHandle = fopen((char*)_logFilePath.UTF8String, "aw+");
    }
    
    if (_pFileHandle) {
        fwrite(log.UTF8String, 1, strlen(log.UTF8String), _pFileHandle);
    }
}

- (void)log:(NSString *)formatStr, ... {
    if (!formatStr) {
        return;
    }
    
    va_list arglist;
    va_start(arglist, formatStr);
    NSString *outStr = [[NSString alloc] initWithFormat:formatStr arguments:arglist];
    va_end(arglist);
    NSLog(@"applog:%@", outStr);
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    NSString *formatDate = [formatter stringFromDate:date];
    NSString *logMsg = [NSString stringWithFormat:@"%@|applog|%@\n",formatDate,outStr];
    [self writeLogFile:logMsg];
}

@end
