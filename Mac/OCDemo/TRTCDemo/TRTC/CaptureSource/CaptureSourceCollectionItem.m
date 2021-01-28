//
//  CaptureSourceCollectionItem.m
//  TXLiteAVMacDemo
//
//  Created by shengcui on 2018/10/24.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "CaptureSourceCollectionItem.h"

@interface CaptureSourceCollectionItem ()
@property (strong, nonatomic) NSImage *image;
@property (strong, nonatomic) NSImage *icon;
@end

@implementation CaptureSourceCollectionItem

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)setSource:(TRTCScreenCaptureSourceInfo *)source {
    if (_source == source) return;
    _source = source;
    self.image = source.thumbnail;
    self.title = source.sourceName;
    self.icon = source.icon;
}

@end
