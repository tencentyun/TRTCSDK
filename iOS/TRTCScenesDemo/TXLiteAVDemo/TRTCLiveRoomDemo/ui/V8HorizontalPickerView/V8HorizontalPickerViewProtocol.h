//
//  V8HorizontalPickerViewProtocol.h
//
//  Created by Shawn Veader on 9/17/10.
//  Copyright 2010 V8 Labs, LLC. All rights reserved.
//

@class V8HorizontalPickerView;

// ------------------------------------------------------------------
// V8HorizontalPickerView DataSource Protocol
@protocol V8HorizontalPickerViewDataSource <NSObject>
@required
// data source is responsible for reporting how many elements there are
- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker;
@end


// ------------------------------------------------------------------
// V8HorizontalPickerView Delegate Protocol
@protocol V8HorizontalPickerViewDelegate <NSObject>

@optional
// delegate callback to notify delegate selected element has changed
- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index;

// one of these two methods must be defined
- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index;
- (UIView *)horizontalPickerView:(V8HorizontalPickerView *)picker viewForElementAtIndex:(NSInteger)index;
// any view returned from this must confirm to the V8HorizontalPickerElementState protocol

@required
// delegate is responsible for reporting the size of each element
- (NSInteger)horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index;

@end

// ------------------------------------------------------------------
// V8HorizontalPickerElementState Protocol
@protocol V8HorizontalPickerElementState <NSObject>
@required
// element views should know how display themselves based on selected status
- (void)setSelectedElement:(BOOL)selected;
@end
