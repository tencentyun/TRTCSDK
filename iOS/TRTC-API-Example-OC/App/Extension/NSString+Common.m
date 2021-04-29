//
//  NSString+Common.m
//  TRTC-API-Example-OC
//
//  Created by adams on 2021/4/22.
//

#import "NSString+Common.h"

@implementation NSString (Common)

+ (NSString *)generateRandomRoomNumber {
    return  [NSString stringWithFormat:@"%d",arc4random() % (99999999 - 10000000 + 1) + 10000000];
}

+ (NSString *)generateRandomUserId {
    return  [NSString stringWithFormat:@"%d",arc4random() % (999999 - 100000 + 1) + 100000];
}

+ (NSString *)generateRandomStreamId {
    return [NSString stringWithFormat:@"%d", arc4random() % (999999 - 100000 + 1) + 100000];
}

/// NSDictionary convertTo json
/// @param dict NSDictionary
+ (NSString *)convertToJsonData:(NSDictionary *)dict {

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
        
    }else{
    
    jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
    
}

@end
