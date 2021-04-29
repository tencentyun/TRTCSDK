//
//  AppLocalized.m
//  TXLiteAVDemo
//
//  Created by gg on 2021/3/17.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "AppLocalized.h"

//MARK: Base
NSString *LocalizeFromTable(NSString *key, NSString *table) {
    return [NSBundle.mainBundle localizedStringForKey:key value:@"" table:table];
}

//MARK: Replace String
NSString *LocalizeReplace(NSString *origin, NSString *xxx_replace) {
    if (xxx_replace == nil) { xxx_replace = @"";}
    return [origin stringByReplacingOccurrencesOfString:@"xxx" withString:xxx_replace];
}

NSString *LocalizeReplaceTwoCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace) {
    if (yyy_replace == nil) { yyy_replace = @"";}
    return [LocalizeReplace(Localize(origin), xxx_replace) stringByReplacingOccurrencesOfString:@"yyy" withString:yyy_replace];
}

NSString *const Localize_TableName = @"Localized";
NSString *Localize(NSString *key) {
    return LocalizeFromTable(key, Localize_TableName);
}
