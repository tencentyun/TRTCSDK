//
//  TXCaptureSourceViewController.m
//  TXLiteAVMacDemo
//
//  Created by shengcui on 2018/10/24.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "TXCaptureSourceWindowController.h"
#import "CaptureSourceCollectionItem.h"
#import "TXCaptureSourceCollectionHeaderView.h"
#import "SDKHeader.h"

@interface TXCaptureSourceWindowController () <NSCollectionViewDelegate, NSCollectionViewDataSource>
{
    NSArray<TRTCScreenCaptureSourceInfo*> *windowList;
    NSArray<TRTCScreenCaptureSourceInfo*> *screenList;
    NSArray<NSArray*>* sections;
}
@property (weak) IBOutlet NSCollectionView *collectionView;
@property (weak) IBOutlet NSButton *streamTypeButton;

@end

@implementation TXCaptureSourceWindowController
- (instancetype)initWithTRTCCloud:(TRTCCloud *)engine
{
    if (self = [super initWithWindowNibName:NSStringFromClass([self class])]) {
        _engine = engine;
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    NSArray<TRTCScreenCaptureSourceInfo *> * capturable = [self.engine getScreenCaptureSourcesWithThumbnailSize:CGSizeMake(300, 300) iconSize:CGSizeMake(128, 128)];
    
    windowList = [capturable filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type = %d", TRTCScreenCaptureSourceTypeWindow]];
    screenList = [capturable filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type = %d", TRTCScreenCaptureSourceTypeScreen]];
    sections = @[screenList, windowList];
    [self configureCollectionView];
}

- (void)configureCollectionView {
    NSCollectionViewFlowLayout *layout = [[NSCollectionViewFlowLayout alloc] init];
    layout.itemSize = NSMakeSize(160, 160);
    layout.sectionInset = NSEdgeInsetsMake(8, 8, 8, 8);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    self.collectionView.collectionViewLayout = layout;
}

- (IBAction)onClose:(id)sender {
    [self.window.sheetParent endSheet:self.window];
    [self.window close];
}

- (IBAction)endScreenShare:(id)sender {
    if (self.onSelectSource) {
        self.onSelectSource(nil);
    }
}

- (BOOL)usesBigStream {
    return self.streamTypeButton.state == NSControlStateValueOn;
}

#pragma mark - NSCollectionViewDataSource
- (NSView *)collectionView:(NSCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSCollectionViewSupplementaryElementKind)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == NSCollectionElementKindSectionHeader) {
        TXCaptureSourceCollectionHeaderView *view = [collectionView makeSupplementaryViewOfKind:kind withIdentifier:@"TXCaptureSourceCollectionHeaderView" forIndexPath:indexPath];
        view.textField.stringValue = indexPath.section == 0 ? @"Screen" :@"Window";
    }
    return nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return sections.count;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return sections[section].count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    CaptureSourceCollectionItem *item = [collectionView makeItemWithIdentifier:@"CaptureSourceCollectionItem" forIndexPath:indexPath];
    item.source = sections[indexPath.section][indexPath.item];
    return item;
}

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
    if (self.onSelectSource != nil) {
        NSIndexPath *indexPath = indexPaths.anyObject;
        self.onSelectSource(sections[indexPath.section][indexPath.item]);
    }
}

#pragma mark - NSTableViewDelegate
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 150;
}

@end
