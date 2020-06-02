//
//  MainMenuCell.m
//  TRTCDemo
//
//  Created by LiuXiaoya on 2020/1/13.
//  Copyright © 2020 rushanting. All rights reserved.
//

#import "MainMenuCell.h"

@interface MainMenuCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation MainMenuCell

- (void)setItem:(MainMenuItem *)item {
    self.iconView.image = item.icon;
    self.titleLabel.text = item.title;
}

@end


@interface MainMenuItem()

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) UIImage *icon;
@property (copy, nonatomic) void (^selectBlock)(void);

@end

@implementation MainMenuItem

- (instancetype)initWithIcon:(UIImage *)image
                       title:(NSString *)title
                     content:(NSString *)content
                    onSelect:(void(^)(void))selectBlock {
    if (self = [super init]) {
        self.icon = image;
        self.title = title;
        self.content = content;
        self.selectBlock = selectBlock;
    }
    return self;
}

@end
