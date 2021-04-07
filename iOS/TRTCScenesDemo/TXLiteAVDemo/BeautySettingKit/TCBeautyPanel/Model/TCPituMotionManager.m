// Copyright (c) 2019 Tencent. All rights reserved.

#import "TCPituMotionManager.h"
#import <UIKit/UIKit.h>

#define L(x) [self localizedString:x]

@implementation TCPituMotionManager
{
    NSMutableDictionary<NSString *, TCPituMotion *> *_map;
    NSBundle *_resourceBundle;
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
        [self setupBundle];
        NSArray *initList = @[
            @[@"video_boom", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_boom.zip", L(@"Boom")],
        ];
        NSArray *gestureMotionArray = @[
            @[@"video_pikachu", @"http://dldir1.qq.com/hudongzhibo/AISpecial/Android/181/video_pikachu.zip", L(@"TC.BeautySettingPanel.PikaQiu")],
        ];
        NSArray *cosmeticMotionArray = @[
            @[@"video_qingchunzannan_iOS", @"http://res.tu.qq.com/materials/video_qingchunzannan_iOS.zip", L(@"TC.BeautySettingPanel.Fu Gu")],
        ];
        NSArray *backgroundRemovalArray = @[
            @[@"video_xiaofu", @"http://dldir1.qq.com/hudongzhibo/AISpecial/ios/160/video_xiaofu.zip", L(@"TC.BeautyPanel.Menu.BlendPic")],
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

- (void)setupBundle {
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"UGCKitResources" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:resourcePath];
    if (nil == bundle) {
        bundle = [NSBundle mainBundle];
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TCBeautyPanelResources" ofType:@"bundle"];
    if (!path) {
        path = [bundle pathForResource:@"TCBeautyPanelResources" ofType:@"bundle"];
    }
    NSBundle *panelResBundle = [NSBundle bundleWithPath:path];
    if (panelResBundle) {
        bundle = panelResBundle;
    }
    _resourceBundle = bundle ?: [NSBundle mainBundle];
}

- (NSString *)localizedString:(nonnull NSString *)key {
    NSString *string = [_resourceBundle localizedStringForKey:key value:@"" table:nil];
    return string ?: @"";
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
