//
//  ReplayKitLocalized.m
//  TXLiteAVDemo
//
//  Created by adams on 2021/3/22.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "ReplayKitLocalized.h"

#pragma mark - Base
NSString *ReplayKitLocalizeFromTable(NSString *key, NSString *table) {
    return [NSBundle.mainBundle localizedStringForKey:key value:@"" table:table];
}

NSString *ReplayKitLocalizeFromTableAndCommon(NSString *key, NSString *common, NSString *table) {
    return ReplayKitLocalizeFromTable(key, table);
}

#pragma mark - Replace String
NSString *ReplayKitLocalizeReplaceXX(NSString *origin, NSString *xxx_replace) {
    return [origin stringByReplacingOccurrencesOfString:@"xxx" withString:xxx_replace];
}

NSString *ReplayKitLocalizeReplace(NSString *origin, NSString *xxx_replace, NSString *yyy_replace) {
    return [[origin stringByReplacingOccurrencesOfString:@"xxx" withString:xxx_replace] stringByReplacingOccurrencesOfString:@"yyy" withString:yyy_replace];
}

NSString *ReplayKitLocalizeReplaceThreeCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace) {
    return [[[origin stringByReplacingOccurrencesOfString:@"xxx" withString:xxx_replace] stringByReplacingOccurrencesOfString:@"yyy" withString:yyy_replace]
        stringByReplacingOccurrencesOfString:@"zzz" withString:zzz_replace];
}

NSString *ReplayKitLocalizeReplaceFourCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace, NSString *mmm_replace) {
    return [[[[origin stringByReplacingOccurrencesOfString:@"xxx" withString:xxx_replace] stringByReplacingOccurrencesOfString:@"yyy" withString:yyy_replace]
        stringByReplacingOccurrencesOfString:@"zzz" withString:zzz_replace]
            stringByReplacingOccurrencesOfString:@"mmm" withString:mmm_replace];
}

NSString *ReplayKitLocalizeReplaceFiveCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace, NSString *mmm_replace, NSString *nnn_replace) {
    return [[[[[origin stringByReplacingOccurrencesOfString:@"xxx" withString:xxx_replace] stringByReplacingOccurrencesOfString:@"yyy" withString:yyy_replace]
        stringByReplacingOccurrencesOfString:@"zzz" withString:zzz_replace]
            stringByReplacingOccurrencesOfString:@"mmm" withString:mmm_replace]
            stringByReplacingOccurrencesOfString:@"nnn" withString:nnn_replace];
}

#pragma mark - ReplayKit
NSString *const ReplayKit_Localize_TableName = @"ReplayKitLocalized";
NSString *ReplayKitLocalize(NSString *key) {
    return ReplayKitLocalizeFromTable(key, ReplayKit_Localize_TableName);
}
