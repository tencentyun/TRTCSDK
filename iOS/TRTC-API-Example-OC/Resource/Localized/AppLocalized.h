//
//  AppLocalized.h
//  TXLiteAVDemo
//
//  Created by gg on 2021/3/17.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//MARK: Base
extern NSString *LocalizeFromTable(NSString *key, NSString *table);

//MARK: Replace String
extern NSString *LocalizeReplace(NSString *origin, NSString *xxx_replace);
extern NSString *LocalizeReplaceTwoCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace);

extern NSString *const Localize_TableName;
extern NSString *Localize(NSString *key);

NS_ASSUME_NONNULL_END
