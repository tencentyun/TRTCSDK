//
//  NSObject+CommonBlock.m
//  CommonLibrary
//
//  Created by Alexi on 3/11/14.
//  Copyright (c) 2014 CommonLibrary. All rights reserved.
//

#import "NSObject+CommonBlock.h"

@implementation NSObject (CommonBlock)

- (void)excuteBlock:(CommonBlock)block
{
    __weak id selfPtr = self;
    if (block) {
        block(selfPtr);
    }
}

- (void)performBlock:(CommonBlock)block
{
    if (block)
    {
        [self performSelector:@selector(excuteBlock:) withObject:block];
    }
}

- (void)performBlock:(CommonBlock)block afterDelay:(NSTimeInterval)delay
{
    if (block)
    {
        [self performSelector:@selector(excuteBlock:) withObject:block afterDelay:delay];
    }
}

- (void)cancelBlock:(CommonBlock)block
{
    [[NSRunLoop currentRunLoop] cancelPerformSelector:@selector(excuteBlock:) target:self argument:block];
}


- (void)excuteCompletion:(CommonCompletionBlock)block withFinished:(NSNumber *)finished
{
    __weak id selfPtr = self;
    if (block) {
        block(selfPtr, finished.boolValue);
    }
}

- (void)performCompletion:(CommonCompletionBlock)block withFinished:(BOOL)finished
{
    if (block)
    {
        [self performSelector:@selector(excuteCompletion:withFinished:) withObject:block withObject:[NSNumber numberWithBool:finished]];
    }
}

- (void)cancelCompletion:(CommonCompletionBlock)block
{
    [[NSRunLoop currentRunLoop] cancelPerformSelector:@selector(excuteCompletion:withFinished:) target:self argument:block];
}

//- (void)performCompletion:(CommonCompletionBlock)block withFinished:(BOOL)finished afterDelay:(NSTimeInterval)delay
//{
//    if (block)
//    {
//        self performSelector:<#(SEL)#> withObject:<#(id)#> afterDelay:<#(NSTimeInterval)#>
////        [self performSelector:@selector(excuteCompletion:withFinished:) withObject:block withObject:[NSNumber numberWithBool:finished] afterDelay:delay];
//    }
//}

- (void)asynExecuteCompletion:(CommonBlock)completion tasks:(CommonBlock)task, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list arguments;
    
    if (task)
    {
        if (task)
        {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                if (task)
                {
                    task(self);
                }
            });
            
            va_start(arguments, task);
            //DebugLog(@"%@ <<<<<<<<<=============", task);
            BOOL next = YES;
            do
            {
                CommonBlock eachObject = va_arg(arguments, CommonBlock);
                //DebugLog(@"%@ <<<<<<<<<=============", eachObject);
                if (eachObject)
                {
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        if (eachObject)
                        {
                            eachObject(self);
                        }
                    });
                }
                else
                {
                    next = NO;
                }
                
            }while (next);
            va_end(arguments);
        }
        
        
        
        
        dispatch_barrier_async(dispatch_get_global_queue(0, 0), ^{
            if (completion)
            {
                completion(self);
            }
        });
    }
}
@end
