//
//  HoverView.m
//  TXLiteAVMacDemo
//
//  Created by cui on 2018/12/28.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "HoverView.h"

@interface HoverView : NSView
@end


@implementation HoverView
{
    NSColor *_originalColor;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupHover];
}

- (void)setupHover {
    self.wantsLayer = YES;
    self.layer.backgroundColor = CGColorGetConstantColor(kCGColorClear);
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                                options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                                                  owner:self
                                                               userInfo:nil];
    
    [self addTrackingArea:trackingArea];
    if (self.superview.layer.backgroundColor != NULL) {
        _originalColor = [NSColor colorWithCGColor:self.layer.backgroundColor];
    }
}

-(void)mouseEntered:(NSEvent *)theEvent {
    self.superview.layer.backgroundColor = [NSColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0].CGColor;
}

-(void)mouseExited:(NSEvent *)theEvent {
    self.superview.layer.backgroundColor =  _originalColor.CGColor;//[NSColor clearColor].CGColor;//
}

@end

@implementation NSView (Hover)
- (void)setHover {
    HoverView *view = [[HoverView alloc] initWithFrame:self.bounds];
    view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self addSubview:view positioned:NSWindowBelow relativeTo:nil];
    [view setupHover];
}
@end
