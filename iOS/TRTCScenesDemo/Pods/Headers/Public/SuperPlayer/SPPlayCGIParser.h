//
//  SPPlayCGIParser.h
//  SuperPlayer
//
//  Created by cui on 2019/12/26.
//  Copyright © 2019 annidy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPPlayCGIParserProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPPlayCGIParser : NSObject
+ (Class<SPPlayCGIParserProtocol>)parserOfVersion:(NSInteger)version;
@end

NS_ASSUME_NONNULL_END
