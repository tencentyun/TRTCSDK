//
//  TRTCVideoCell.m
//  TXLiteAVMacDemo
//
//  Created by Xiaoya Liu on 2020/2/27.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TRTCVideoCell.h"
#import "TXRenderView.h"

@interface TRTCVideoCell()

@property (weak) IBOutlet NSView *userView;
@property (weak) IBOutlet NSImageView *avatarView;
@property (weak) IBOutlet NSTextField *userNameLabel;

@end

@implementation TRTCVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.wantsLayer = YES;
    self.layer.backgroundColor = [NSColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1.0].CGColor;

    self.avatarView.layer.borderWidth = 1.0;
    self.avatarView.layer.borderColor = [NSColor whiteColor].CGColor;
}

- (void)configWithUserId:(NSString *)userId renderView:(TXRenderView * _Nullable)renderView {
    self.userView.hidden = renderView != nil;
    
    [[self subRenderView] removeFromSuperview];
    
    if (renderView) {
        [self addSubview:renderView];
        renderView.frame = self.bounds;
        [renderView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    } else {
        self.userNameLabel.stringValue = userId;
        self.avatarView.image = [NSImage imageNamed:[NSString stringWithFormat:@"avatar%@", @(userId.hash % 10)]];
    }
}

- (TXRenderView *)subRenderView {
    for (NSView *view in self.subviews) {
        if ([view isKindOfClass:[TXRenderView class]]) {
            return (TXRenderView *)view;
        }
    }
    return nil;
}

@end
