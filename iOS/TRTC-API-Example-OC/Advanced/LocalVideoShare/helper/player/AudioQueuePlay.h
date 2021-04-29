//
//  AudioQueuePlay.h
//  TRTC-API-Example-OC
//
//  Created by dangjiahe on 2021/4/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioQueuePlay : NSObject

- (void)playWithData: (NSData *)data;
- (void)start;
- (void)stop;

- (instancetype)init;
@end

NS_ASSUME_NONNULL_END
