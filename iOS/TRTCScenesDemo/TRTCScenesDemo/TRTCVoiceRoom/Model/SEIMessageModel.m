//
//  SEIMessageModel.m
//  TXLiteAVDemo_Professional
//
//  Created by Melody on 2019/11/28.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "SEIMessageModel.h"
#import "MJExtension.h"

@implementation SEIMessageModel

/* 实现该方法，说明数组中存储的模型数据类型 */
+ (NSDictionary *)mj_objectClassInArray {
    /*字典中的key是数组属性名，value是数组中存放模型的Class（Class类型或者NSString类型）*/
    return @{ @"regions" : @"UserModel"
    };
}

//    /*将属性名换为其他key去字典中取值*/
//+ (NSDictionary *)mj_replacedKeyFromPropertyName{
//    /* 字典中的key是属性名，value是从字典中取值用的key */
//    return @{
//               @"canvaModel" : @"canvas"
//           };
//}

@end
