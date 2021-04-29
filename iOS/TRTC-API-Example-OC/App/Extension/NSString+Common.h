//
//  NSString+Common.h
//  TRTC-API-Example-OC
//
//  Created by adams on 2021/4/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Common)

+ (NSString *)convertToJsonData:(NSDictionary *)dict;

+ (NSString *)generateRandomRoomNumber;

+ (NSString *)generateRandomUserId;

+ (NSString *)generateRandomStreamId;

@end

NS_ASSUME_NONNULL_END
