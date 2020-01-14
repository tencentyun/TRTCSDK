// Copyright (c) 2019 Tencent. All rights reserved.

#import "TCPituMotionManager.h"
#import <UIKit/UIKit.h>

#define L(x) NSLocalizedString(x, nil)

@implementation TCPituMotionManager
{
    NSMutableDictionary<NSString *, TCPituMotion *> *_map;
}

+ (instancetype)sharedInstance
{
    static TCPituMotionManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TCPituMotionManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSArray *initList = @[
            @[@"video_boom", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_boom.zip", L(@"Boom")],
            @[@"video_nihongshu", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_nihongshu.zip", L(@"霓虹鼠")],
            @[@"video_fengkuangdacall", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_fengkuangdacall.zip", L(@"疯狂打call")],
            @[@"video_Qxingzuo_iOS", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_Qxingzuo_iOS.zip", L(@"Q星座")],
            @[@"video_caidai_iOS", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_caidai_iOS.zip", L(@"彩色丝带")],
            @[@"video_liuhaifadai", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_liuhaifadai.zip", L(@"刘海发带")],
            @[@"video_purplecat", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_purplecat.zip", L(@"紫色小猫")],
            @[@"video_huaxianzi", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_huaxianzi.zip", L(@"花仙子")],
            @[@"video_baby_agetest", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_baby_agetest.zip", L(@"小公举")],
            // 星耳，变脸
            @[@"video_3DFace_dogglasses2", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_3DFace_dogglasses2.zip", L(@"眼镜狗")],
            @[@"video_rainbow", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_rainbow.zip", L(@"彩虹云")],
        ];
        NSArray *gestureMotionArray = @[
            @[@"video_pikachu", @"http://dldir1.qq.com/hudongzhibo/AISpecial/Android/181/video_pikachu.zip", L(@"皮卡丘")],
        ];
        NSArray *cosmeticMotionArray = @[
            @[@"video_qingchunzannan_iOS", @"http://res.tu.qq.com/materials/video_qingchunzannan_iOS.zip", L(@"原宿复古")],
        ];
        NSArray *backgroundRemovalArray = @[
            @[@"video_xiaofu", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_xiaofu.zip", L(@"AI抠背")],
        ];
        NSArray *(^generate)(NSArray *) = ^(NSArray *inputArray){
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:inputArray.count];
            self->_map = [[NSMutableDictionary alloc] initWithCapacity:inputArray.count];
            for (NSArray *item in inputArray) {
                TCPituMotion *address = [[TCPituMotion alloc] initWithId:item[0] name:item[2] url:item[1]];
                [array addObject:address];
                self->_map[item[0]] = address;
            }
            return array;
        };

        _motionPasters = generate(initList);
        _cosmeticPasters = generate(cosmeticMotionArray);
        _gesturePasters = generate(gestureMotionArray);
        _backgroundRemovalPasters = generate(backgroundRemovalArray);
    }
    return self;
}

- (TCPituMotion *)motionWithIdentifier:(NSString *)identifier
{
    return _map[identifier];
}

@end

@implementation TCPituMotion
- (instancetype)initWithId:(NSString *)identifier name:(NSString *)name url:(NSString *)address
{
    if (self = [super init]) {
        _identifier = identifier;
        _name = name;
        _url = [NSURL URLWithString: address];
    }
    return self;
}
@end
