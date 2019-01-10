//
//  TXRenderView.m
//  TXLiteAVMacDemo
//
//  Created by cui on 2018/12/3.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "TXRenderView.h"

static const CGFloat ItemSize = 22;

@interface TXRenderViewToolbarItemObject : NSObject
@property (copy, nonatomic) NSString *title;
@property (weak, nonatomic) id target;
@property (nonatomic) SEL action;
@property (strong, nonatomic) id context;
@end

@interface TXRenderViewToolbarItem : NSCollectionViewItem
@end

@interface TXRenderView () <NSCollectionViewDelegate, NSCollectionViewDataSource>
@end

@implementation TXRenderView
{
    NSMutableArray<TXRenderViewToolbarItemObject*> *_items;
    NSCollectionView *_collectionView;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)addSubview:(NSView *)view positioned:(NSWindowOrderingMode)place relativeTo:(NSView *)otherView
{
    [super addSubview:view positioned:place relativeTo:otherView];
    if (view != _collectionView) {
        [self addSubview:_collectionView];
    }
}

- (void)setup {
    _items = [[NSMutableArray alloc] init];
    _collectionView = [[NSCollectionView alloc] initWithFrame:NSMakeRect(NSWidth(self.bounds) - ItemSize, 0, 24, NSHeight(self.bounds))];
    _collectionView.autoresizingMask = NSViewMinXMargin | NSViewMinYMargin;
    _collectionView.maxItemSize = NSMakeSize(ItemSize, ItemSize);
    _collectionView.minItemSize = NSMakeSize(ItemSize, ItemSize);

    [_collectionView setItemPrototype:[[TXRenderViewToolbarItem alloc] init]];
    _collectionView.delegate = self;
    _collectionView.backgroundColors = @[[NSColor colorWithWhite:1 alpha:0.5]];


    [self addSubview:_collectionView];
}

- (void)addToolbarItem:(NSString *)title target:(id)target action:(SEL)action context:(id)context
{
    TXRenderViewToolbarItemObject *item = [[TXRenderViewToolbarItemObject alloc] init];
    item.title = title;
    item.target = target;
    item.action = action;
    item.context = context;
    [_items addObject:item];
    CGFloat height = ItemSize * _items.count;
    NSRect frame = NSMakeRect(NSWidth(self.bounds) - ItemSize, NSHeight(self.bounds) - height, ItemSize, height);
    _collectionView.frame = frame;
    _collectionView.content = _items;
}

@end

@implementation TXRenderViewToolbarItem
- (void)loadView {
    NSButton *button = [[NSButton alloc] initWithFrame:NSZeroRect];
    button.bezelStyle = NSBezelStyleRoundRect;
    [self setView:button];
}
- (void)setRepresentedObject:(TXRenderViewToolbarItemObject *)representedObject {
    [super setRepresentedObject:representedObject];
    NSButton *button = (NSButton *)[self view];
    button.font = [NSFont systemFontOfSize:10];
    [button setTitle:representedObject.title ?: @""];
    button.target = self;
    button.action = @selector(onButtonClick:);
}

- (void)onButtonClick:(id)_ {
    TXRenderViewToolbarItemObject *object = self.representedObject;

    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [object.target performSelector:object.action withObject:object.context];
#pragma clang diagnostic pop
}
@end

@implementation TXRenderViewToolbarItemObject
- (id)representedObject {
    return self;
}
@end
