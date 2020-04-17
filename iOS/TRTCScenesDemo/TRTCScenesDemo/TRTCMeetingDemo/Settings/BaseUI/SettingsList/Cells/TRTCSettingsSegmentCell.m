/*
* Module:   TRTCSettingsSegmentCell
*
* Function: 配置列表Cell，右侧是SegmentedControl
*
*/

#import "TRTCSettingsSegmentCell.h"
#import "UISegmentedControl+TRTC.h"
#import "Masonry.h"
#import "ColorMacro.h"

@interface TRTCSettingsSegmentCell ()

@property (strong, nonatomic) UISegmentedControl *segment;

@end

@implementation TRTCSettingsSegmentCell

- (void)setupUI {
    [super setupUI];
    
    self.segment = [UISegmentedControl trtc_segment];
    [self.segment addTarget:self action:@selector(onSegmentChange:) forControlEvents:UIControlEventValueChanged];
    
    [self.contentView addSubview:self.segment];
    [self.segment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-18);
    }];
}

- (void)didUpdateItem:(TRTCSettingsBaseItem *)item {
    if ([item isKindOfClass:[TRTCSettingsSegmentItem class]]) {
        TRTCSettingsSegmentItem *segmentItem = (TRTCSettingsSegmentItem *)item;
        [self.segment removeAllSegments];
        [segmentItem.items enumerateObjectsUsingBlock:^(NSString * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.segment insertSegmentWithTitle:item atIndex:idx animated:NO];
        }];
        self.segment.selectedSegmentIndex = segmentItem.selectedIndex;
    }
}

- (void)onSegmentChange:(id)sender {
    TRTCSettingsSegmentItem *segmentItem = (TRTCSettingsSegmentItem *)self.item;
    segmentItem.selectedIndex = self.segment.selectedSegmentIndex;
    if (segmentItem.action) {
        segmentItem.action(self.segment.selectedSegmentIndex);
    }
}

@end


@implementation TRTCSettingsSegmentItem

- (instancetype)initWithTitle:(NSString *)title
                        items:(NSArray<NSString *> *)items
                selectedIndex:(NSInteger)index
                       action:(void(^ _Nullable)(NSInteger index))action {
    if (self = [super init]) {
        self.title = title;
        _items = items;
        _selectedIndex = index;
        _action = action;
    }
    return self;
}

+ (Class)bindedCellClass {
    return [TRTCSettingsSegmentCell class];
}

- (NSString *)bindedCellId {
    return [TRTCSettingsSegmentItem bindedCellId];
}

@end

