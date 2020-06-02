//
//  PlayCGIParserProtocol.h
//  SuperPlayer
//
//  Created by cui on 2019/12/25.
//  Copyright © 2019 annidy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPPlayCGIParseResult.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SPPlayCGIParserProtocol <NSObject>
+ (SPPlayCGIParseResult *)parseResponse:(NSDictionary *)jsonResp;
@end

NS_ASSUME_NONNULL_END
