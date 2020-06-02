//
//  TCLog.m
//  TCLVBIMDemo
//
//  Created by kuenzhang on 16/9/5.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "AppLogMgr.h"

@implementation AppLogMgr
{
    NSString*   _logFilePath;
    FILE*       _pFileHandle;
}

static AppLogMgr *_shareInstance = nil;

+ (instancetype)shareInstance
{
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        _shareInstance = [[AppLogMgr alloc] init];
    });
    return _shareInstance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *path = [paths objectAtIndex:0];
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMdd";
        
        NSString *res = [formatter stringFromDate:date];
        _logFilePath = [NSString stringWithFormat:@"%@/appdemolog.log",path];
        //_logFilePath = [NSString stringWithFormat:@"%@/Caches/rtmpsdk_%@.log",path,res];
    }
    return self;
}

-(void) dealloc
{
    if (_pFileHandle)
    {
        fclose(_pFileHandle);
    }
    _pFileHandle = NULL;
}

-(void) onLog:(NSString*)log LogLevel:(int)level WhichModule:(NSString*)module
{
    NSLog(@"level:%d|module:%@| %@\n", level, module, log);
}

-(void) writeLogFile:(NSString*)log
{
    if (_pFileHandle == NULL)
    {
        _pFileHandle = fopen((char*)_logFilePath.UTF8String, "w");
    }
    
    if (_pFileHandle)
    {
        fwrite(log.UTF8String, 1, strlen(log.UTF8String), _pFileHandle);
        fflush(_pFileHandle);
    }
}

-(void) log:(Boolean)bOnlyFile format:(NSString *)formatStr, ...;
{
    if (!formatStr)
        return;
    
    va_list arglist;
    va_start(arglist, formatStr);
    NSString *outStr = [[NSString alloc] initWithFormat:formatStr arguments:arglist];
    va_end(arglist);
    
    if (!bOnlyFile) {
        NSLog(@"applog:%@", outStr);
    }
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    NSString *formatDate = [formatter stringFromDate:date];
    NSString *logMsg = [NSString stringWithFormat:@"%@|applog|%@\n",formatDate,outStr];
    [self writeLogFile:logMsg];
}
@end
