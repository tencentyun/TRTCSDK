//
//  TXRenderView.m
//  TXLiteAVMacDemo
//
//  Created by cui on 2018/12/3.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "TXRenderView.h"

static const CGFloat ItemSize = 22;
static const CGFloat TopMargin = 20;
static const CGFloat LeftMargin = 20;

@interface TXRenderViewToolbarItemObject : NSObject
@property (copy, nonatomic) NSArray<NSString *> *titles;
@property (strong, nonatomic) NSArray<NSImage *> *images;
@property (assign, nonatomic) NSUInteger index;
@property (weak, nonatomic) id target;
@property (nonatomic) SEL action;
@property (strong, nonatomic) id context;
@end

@interface TXRenderViewToolbarItem : NSCollectionViewItem
@end

@interface TXRenderView () <NSCollectionViewDelegate>
{
    NSMutableArray<TXRenderViewToolbarItemObject*> *_items;
    NSCollectionView *_collectionView;
    NSLevelIndicator *_volumeIndicator;
    NSImageView *_signalIndicator;
    NSLayoutConstraint *_textLabelTopConstrataint;
}
@end

@implementation TXRenderView

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

- (void)setup {
    _contentView = [[NSView alloc] initWithFrame:self.bounds];
    _contentView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self addSubview:_contentView];
    
   
    _items = [[NSMutableArray alloc] init];
    _collectionView = [[NSCollectionView alloc] initWithFrame:NSMakeRect(NSWidth(self.bounds) - ItemSize, 0, 24, NSHeight(self.bounds))];
    _collectionView.autoresizingMask = NSViewMinXMargin | NSViewMinYMargin;
    _collectionView.maxItemSize = NSMakeSize(ItemSize, ItemSize);
    _collectionView.minItemSize = NSMakeSize(ItemSize, ItemSize);

    [_collectionView setItemPrototype:[[TXRenderViewToolbarItem alloc] init]];
    _collectionView.delegate = self;
    _collectionView.backgroundColors = @[[NSColor colorWithWhite:1 alpha:0.5]];

    [self addSubview:_collectionView];
    
    _volumeIndicator = [[NSLevelIndicator alloc] initWithFrame:NSMakeRect(2.5, NSMaxY(self.bounds) - TopMargin - 12.5, 15, 10)];
    _volumeIndicator.levelIndicatorStyle = NSLevelIndicatorStyleContinuousCapacity;
    _volumeIndicator.autoresizingMask = NSViewMaxXMargin | NSViewMinYMargin;
    _volumeIndicator.minValue = 0.0;
    _volumeIndicator.maxValue = 1.0;
    [_volumeIndicator setFrameCenterRotation:90];
    [self addSubview:_volumeIndicator];
    
    _signalIndicator = [[NSImageView alloc] initWithFrame:NSMakeRect(20, NSMaxY(self.bounds) - TopMargin - 15, 26, 15)];
    _signalIndicator.autoresizingMask = NSViewMaxXMargin | NSViewMinYMargin;
    _signalIndicator.imageScaling = NSImageScaleProportionallyDown;
    [self addSubview:_signalIndicator];
    
    _textLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(LeftMargin, 100, NSHeight(self.bounds) - TopMargin - 15, 15)];
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_textLabel];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_textLabel
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:LeftMargin]];
    _textLabelTopConstrataint = [NSLayoutConstraint constraintWithItem:_textLabel
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:TopMargin];
    [self addConstraint: _textLabelTopConstrataint];
}

- (void)_updateCollectionView {
    CGFloat width = ItemSize * _items.count;
    NSRect frame = NSMakeRect(NSWidth(self.bounds) - width, NSHeight(self.bounds) - ItemSize, width, ItemSize);
    _collectionView.frame = frame;
    _collectionView.content = _items;
}

#pragma mark - Public Methods
- (void)setVolumeHidden:(BOOL)volumeHidden {
    _volumeHidden = volumeHidden;
    _volumeIndicator.hidden = volumeHidden;
}
- (void)addTextToolbarItem:(NSString *)title target:(id)target action:(SEL)action context:(id)context
{
    [self addToolbarItemWithTitles:@[title] images:nil target:target action:action context:context];
}
- (void)addImageToolbarItem:(NSImage *)image target:(id)target action:(SEL)action context:(id)context {
    [self addToolbarItemWithTitles:nil images:@[image] target:target action:action context:context];
}

- (void)addToolbarItemWithTitles:(NSArray<NSString *> *)titles images:(NSArray<NSImage *> *)images target:(id)target action:(SEL)action context:(id)context
{
    TXRenderViewToolbarItemObject *item = [[TXRenderViewToolbarItemObject alloc] init];
    [images enumerateObjectsUsingBlock:^(NSImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
        [image setSize:NSMakeSize(ItemSize, ItemSize)];
    }];
    item.titles = titles;
    item.images = images;
    item.target = target;
    item.action = action;
    item.context = context;
    [_items addObject:item];
    [self _updateCollectionView];
}

- (void)addToggleImageToolbarItem:(NSArray<NSImage *> *)images target:(id)target action:(SEL)action context:(id)context
{
    [self addToolbarItemWithTitles:nil images:images target:target action:action context:context];
}

- (void)removeToolbarWithTitle:(NSString *)title {
    for (TXRenderViewToolbarItemObject *item in [_items reverseObjectEnumerator]) {
        if ([item.titles.firstObject isEqualToString:title]) {
            [_items removeObject:item];
            break;
        }
    }
    [self _updateCollectionView];
}

- (void)setVolume:(float)volume {
    _volumeIndicator.doubleValue = volume;
}

- (void)setSignal:(TRTCQuality)volume
{
    _signalIndicator.image = [NSImage imageNamed:[NSString stringWithFormat:@"signal%d", (int)volume]];
}

- (void)setTopIndicatorMargin:(CGFloat)topIndicatorMargin {
    _topIndicatorMargin = topIndicatorMargin;
    _volumeIndicator.frame = NSMakeRect(LeftMargin + 2.5, NSHeight(self.bounds) - TopMargin - topIndicatorMargin - 12.5, 15, 10);
    _signalIndicator.frame = NSMakeRect(LeftMargin,  NSHeight(self.bounds) - TopMargin - topIndicatorMargin - 15, 26, 15);
    _textLabelTopConstrataint.constant = topIndicatorMargin;
    [self layoutSubtreeIfNeeded];
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
    button.imageScaling = NSImageScaleProportionallyDown;
    [self _updateButtonWithObject];
    button.target = self;
    button.action = @selector(onButtonClick:);
}

- (void)_updateButtonWithObject {
    TXRenderViewToolbarItemObject *representedObject = self.representedObject;
    NSButton *button = (NSButton *)[self view];
    if (representedObject.titles) {
        [button setTitle:representedObject.titles[representedObject.index]];
        [button setImage:nil];
    } else {
        [button setTitle:@""];
        [button setImage:representedObject.images[representedObject.index]];
    }
}

- (void)onButtonClick:(id)_ {
    TXRenderViewToolbarItemObject *object = self.representedObject;
    if (object.titles) {
        object.index = (object.index + 1) % object.titles.count;
    } else {
        object.index = (object.index + 1) % object.images.count;
    }
    [self _updateButtonWithObject];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSMethodSignature *sig = [object.target methodSignatureForSelector:object.action];
    if (sig.numberOfArguments == 3) {
        [object.target performSelector:object.action withObject:object.context];
    } else {
        [object.target performSelector:object.action withObject:object.context withObject:@(object.index)];
    }
#pragma clang diagnostic pop
}
@end

@implementation TXRenderViewToolbarItemObject
- (id)representedObject {
    return self;
}
@end
