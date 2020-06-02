//
//  V8HorizontalPickerView.m
//
//  Created by Shawn Veader on 9/17/10.
//  Copyright 2010 V8 Labs, LLC. All rights reserved.
//

#import "V8HorizontalPickerView.h"
#import "UIView+Additions.h"


#pragma mark - Internal Method Interface

@implementation V8LabelNode


@end

@interface V8HorizontalPickerView () {
	UIScrollView *_scrollView;
}

// collection of widths of each element.
@property (nonatomic, strong) NSMutableArray *elementWidths;

@property (nonatomic, assign) NSInteger elementPadding;

// state keepers
@property (nonatomic, assign) BOOL dataHasBeenLoaded;
@property (nonatomic, assign) BOOL scrollSizeHasBeenSet;
@property (nonatomic, assign) BOOL scrollingBasedOnUserInteraction;

// keep track of which elements are visible for tiling
@property (nonatomic, assign) NSInteger firstVisibleElement;
@property (nonatomic, assign) NSInteger lastVisibleElement;

@end


#pragma mark - Implementation
@implementation V8HorizontalPickerView : UIView

#pragma mark - Init/Dealloc
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self initSetup];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)theCoder {
	self = [super initWithCoder:theCoder];
	if (self) {
		[self initSetup];
	}
	return self;
}

- (void)dealloc {
	_scrollView.delegate = nil;
	self.delegate = nil;
	self.dataSource = nil;
}

- (void)initSetup {
	self.elementWidths = [NSMutableArray array];

	[self addScrollView];

	self.textColor   = [UIColor blackColor];
	self.elementFont = [UIFont systemFontOfSize:12.0f];

	_currentSelectedIndex     = -1; // nothing is selected yet
	_numberOfElements         = 0;

	self.elementPadding       = 0;
	self.dataHasBeenLoaded    = NO;
	self.scrollSizeHasBeenSet = NO;
	self.scrollingBasedOnUserInteraction = NO;

	self.selectionPoint = CGPointZero;
	self.indicatorPosition = V8HorizontalPickerIndicatorBottom;

	self.firstVisibleElement = -1;
	self.lastVisibleElement  = -1;

	self.scrollEdgeViewPadding = 0.0f;

	self.autoresizesSubviews = YES;
}


#pragma mark - LayoutSubViews
- (void)layoutSubviews {
	[super layoutSubviews];
	BOOL adjustWhenFinished = NO;

	if (CGPointEqualToPoint(self.selectionPoint, CGPointZero)) {
		// default to the center
		self.selectionPoint = CGPointMake(self.frame.size.width / 2, 0.0f);
	}

	if (!self.dataHasBeenLoaded) {
		[self collectData];
	}
	if (!self.scrollSizeHasBeenSet) {
		adjustWhenFinished = YES;
		[self updateScrollContentInset];
		[self setTotalWidthOfScrollContent];
	}

	SEL titleForElementSelector = @selector(horizontalPickerView:titleForElementAtIndex:);
	SEL viewForElementSelector  = @selector(horizontalPickerView:viewForElementAtIndex:);
	SEL setSelectedSelector     = @selector(setSelectedElement:);

	CGRect visibleBounds   = [self bounds];
	CGRect scaledViewFrame = CGRectZero;

	// remove any subviews that are no longer visible
	for (UIView *view in [_scrollView subviews]) {
		scaledViewFrame = [_scrollView convertRect:[view frame] toView:self];

		// if the view doesn't intersect, it's not visible, so we can recycle it
		if (!CGRectIntersectsRect(scaledViewFrame, visibleBounds)) {
			[view removeFromSuperview];
		} else { // if it is still visible, update it's selected state
            // view's tag is it's index
            BOOL isSelected = (self.currentSelectedIndex == [self indexForElement:view]);
            if (isSelected) {
                // if this view is set to be selected, make sure it is over the selection point
//                NSInteger currentIndex = [self nearestElementToCenter];
//                isSelected = (currentIndex == self.currentSelectedIndex);
                if (_selectedMaskView != nil) {
                	[view addSubview:_selectedMaskView];
                    _selectedMaskView.center = CGPointMake(view.width/2, view.height/2);
                }
            } else {
                [view removeAllSubViews];
            }
            
			if ([view respondsToSelector:setSelectedSelector]) {
				// casting to V8HorizontalPickerLabel so we can call this without all the NSInvocation jazz
				[(V8HorizontalPickerLabel *)view setSelectedElement:isSelected];
                
			}
		}
	}

	// find needed elements by looking at left and right edges of frame
	CGPoint offset = _scrollView.contentOffset;
	NSInteger firstNeededElement = [self nearestElementToPoint:CGPointMake(offset.x, 0.0f)];
	NSInteger lastNeededElement  = [self nearestElementToPoint:CGPointMake(offset.x + visibleBounds.size.width, 0.0f)];

	// add any views that have become visible
	UIView *view = nil;
	CGRect tmpViewFrame = CGRectZero;
	CGPoint itemViewCenter = CGPointZero;
	for (NSInteger i = firstNeededElement; i <= lastNeededElement; i++) {
		view = nil; // paranoia
		view = [_scrollView viewWithTag:[self tagForElementAtIndex:i]];
		if (!view) {
			if (i < self.numberOfElements) { // make sure we are not requesting data out of range
				if (self.delegate && [self.delegate respondsToSelector:titleForElementSelector]) {
					NSString *title = [self.delegate horizontalPickerView:self titleForElementAtIndex:i];
					view = [self labelForForElementAtIndex:i withTitle:title];
				} else if (self.delegate && [self.delegate respondsToSelector:viewForElementSelector]) {
					view = [self.delegate horizontalPickerView:self viewForElementAtIndex:i];
					// move view's center to the center of item's ideal frame
					tmpViewFrame = [self frameForElementAtIndex:i];
					itemViewCenter = CGPointMake((tmpViewFrame.size.width / 2.0f) + tmpViewFrame.origin.x, (tmpViewFrame.size.height / 2.0f));
					view.center = itemViewCenter;
				}

				if (view) {
					// use the index as the tag so we can find it later
					view.tag = [self tagForElementAtIndex:i];
					[_scrollView addSubview:view];
				}
			}
		}
	}

	// add the left or right edge views if visible
	CGRect viewFrame = CGRectZero;
	if (self.leftScrollEdgeView) {
		viewFrame = [self frameForLeftScrollEdgeView];
		scaledViewFrame = [_scrollView convertRect:viewFrame toView:self];
		if (CGRectIntersectsRect(scaledViewFrame, visibleBounds) && ![self.leftScrollEdgeView isDescendantOfView:_scrollView]) {
			self.leftScrollEdgeView.frame = viewFrame;
			[_scrollView addSubview:self.leftScrollEdgeView];
		}
	}
	if (self.rightScrollEdgeView) {
		viewFrame = [self frameForRightScrollEdgeView];
		scaledViewFrame = [_scrollView convertRect:viewFrame toView:self];
		if (CGRectIntersectsRect(scaledViewFrame, visibleBounds) && ![self.rightScrollEdgeView isDescendantOfView:_scrollView]) {
			self.rightScrollEdgeView.frame = viewFrame;
			[_scrollView addSubview:self.rightScrollEdgeView];
		}
	}

	// save off what's visible now
	self.firstVisibleElement = firstNeededElement;
	self.lastVisibleElement  = lastNeededElement;

	// determine if scroll view needs to shift in response to resizing?
	if (self.currentSelectedIndex > -1 && [self centerOfElementAtIndex:self.currentSelectedIndex] != [self currentCenter].x) {
		if (adjustWhenFinished) {
			[self scrollToElement:self.currentSelectedIndex animated:NO];
		} else if (self.numberOfElements <= self.currentSelectedIndex) {
			// if currentSelectedIndex no longer exists, select what is currently centered
			_currentSelectedIndex = [self nearestElementToCenter];
			[self scrollToElement:self.currentSelectedIndex animated:NO];
		}
	}
}


#pragma mark - Getters and Setters
- (void)setDelegate:(id)newDelegate {
	if (self.delegate != newDelegate) {
		_delegate = newDelegate;
		[self collectData];
	}
}

- (void)setDataSource:(id)newDataSource {
	if (self.dataSource != newDataSource) {
		_dataSource = newDataSource;
		[self collectData];
	}
}

- (void)setSelectionPoint:(CGPoint)point {
	if (!CGPointEqualToPoint(point, self.selectionPoint)) {
		_selectionPoint = point;
		[self updateScrollContentInset];
	}
}

// allow the setting of this views background color to change the scroll view
- (void)setBackgroundColor:(UIColor *)newColor {
	[super setBackgroundColor:newColor];
	_scrollView.backgroundColor = newColor;
	
    for (UIView *view in [_scrollView subviews]) {
        view.backgroundColor = newColor;
    }
}

- (void)setIndicatorPosition:(V8HorizontalPickerIndicatorPosition)position {
	if (self.indicatorPosition != position) {
		_indicatorPosition = position;
		[self drawPositionIndicator];
	}
}

- (void)setSelectionIndicatorView:(UIView *)indicatorView {
	if (self.selectionIndicatorView != indicatorView) {
		if (self.selectionIndicatorView) {
			[self.selectionIndicatorView removeFromSuperview];
		}
		_selectionIndicatorView = indicatorView;

		[self drawPositionIndicator];
	}
}

- (void)setLeftEdgeView:(UIView *)leftView {
	if (self.leftEdgeView != leftView) {
		if (self.leftEdgeView) {
			[self.leftEdgeView removeFromSuperview];
		}
		_leftEdgeView = leftView;

		CGRect tmpFrame = self.leftEdgeView.frame;
		tmpFrame.origin.x = 0.0f;
		tmpFrame.origin.y = 0.0f;
		self.leftEdgeView.frame = tmpFrame;
		[self addSubview:self.leftEdgeView];
	}
}

- (void)setRightEdgeView:(UIView *)rightView {
	if (self.rightEdgeView != rightView) {
		if (self.rightEdgeView) {
			[self.rightEdgeView removeFromSuperview];
		}
		_rightEdgeView = rightView;

		CGRect tmpFrame = self.rightEdgeView.frame;
		tmpFrame.origin.x = self.frame.size.width - tmpFrame.size.width;
		tmpFrame.origin.y = 0.0f;
		self.rightEdgeView.frame = tmpFrame;
		[self addSubview:self.rightEdgeView];
	}
}

- (void)setLeftScrollEdgeView:(UIView *)leftView {
	if (self.leftScrollEdgeView != leftView) {
		if (self.leftScrollEdgeView) {
			[self.leftScrollEdgeView removeFromSuperview];
		}
		_leftScrollEdgeView = leftView;

		self.scrollSizeHasBeenSet = NO;
		[self setNeedsLayout];
	}
}

- (void)setRightScrollEdgeView:(UIView *)rightView {
	if (self.rightScrollEdgeView != rightView) {
		if (self.rightScrollEdgeView) {
			[self.rightScrollEdgeView removeFromSuperview];
		}
		_rightScrollEdgeView = rightView;

		self.scrollSizeHasBeenSet = NO;
		[self setNeedsLayout];
	}
}

- (void)setFrame:(CGRect)newFrame {
	if (!CGRectEqualToRect(self.frame, newFrame)) {
		// causes recalulation of offsets, etc based on new size
		self.scrollSizeHasBeenSet = NO;
	}
	[super setFrame:newFrame];
}

#pragma mark - Data Fetching Methods
- (void)reloadData {
	// remove all scrollview subviews and "recycle" them
	for (UIView *view in [_scrollView subviews]) {
		[view removeFromSuperview];
	}

	self.firstVisibleElement = NSIntegerMax;
	self.lastVisibleElement  = NSIntegerMin;

	[self collectData];
}

- (void)collectData {
	self.scrollSizeHasBeenSet = NO;
	self.dataHasBeenLoaded    = NO;

	[self getNumberOfElementsFromDataSource];
	[self getElementWidthsFromDelegate];
	[self setTotalWidthOfScrollContent];
	[self updateScrollContentInset];

	self.dataHasBeenLoaded = YES;
	[self setNeedsLayout];
}


#pragma mark - Scroll To Element Method
- (void)scrollToElement:(NSInteger)index animated:(BOOL)animate {
	_currentSelectedIndex = index;
//	int x = [self centerOfElementAtIndex:index] - self.selectionPoint.x;
    if (index == 0) {
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:animate];
    }
	// notify delegate of the selected index
	SEL delegateCall = @selector(horizontalPickerView:didSelectElementAtIndex:);
	if (self.delegate && [self.delegate respondsToSelector:delegateCall]) {
		[self.delegate horizontalPickerView:self didSelectElementAtIndex:index];
	}

#if (__IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_4_3)
	[self setNeedsLayout];
#endif
}


#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (self.scrollingBasedOnUserInteraction) {
		// NOTE: sizing and/or changing orientation of control might cause scrolling
		//		 not initiated by user. do not update current selection in these
		//		 cases so that the view state is properly preserved.

		// set the current item under the center to "highlighted" or current
		//_currentSelectedIndex = [self nearestElementToCenter];
	}

#if (__IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_4_3)
	[self setNeedsLayout];
#endif
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	self.scrollingBasedOnUserInteraction = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	// only do this if we aren't decelerating
	if (!decelerate) {
		[self scrollToElementNearestToCenter];
	}
}

//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView { }

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self scrollToElementNearestToCenter];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	self.scrollingBasedOnUserInteraction = NO;
}


#pragma mark - View Creation Methods (Internal Methods)
- (void)addScrollView {
	if (_scrollView == nil) {
		_scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
		_scrollView.delegate = self;
		_scrollView.scrollEnabled = YES;
		_scrollView.scrollsToTop  = NO;
		_scrollView.showsVerticalScrollIndicator   = NO;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.bouncesZoom  = NO;
		_scrollView.alwaysBounceHorizontal = YES;
		_scrollView.alwaysBounceVertical   = NO;
		_scrollView.minimumZoomScale = 1.0; // setting min/max the same disables zooming
		_scrollView.maximumZoomScale = 1.0;
		_scrollView.contentInset = UIEdgeInsetsZero;
		_scrollView.decelerationRate = 0.1; //UIScrollViewDecelerationRateNormal;
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		_scrollView.autoresizesSubviews = YES;

		UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped:)];
		[_scrollView addGestureRecognizer:tapRecognizer];

		[self addSubview:_scrollView];
	}
}

- (void)drawPositionIndicator {
	CGRect indicatorFrame = self.selectionIndicatorView.frame;
	CGFloat x = self.selectionPoint.x - (indicatorFrame.size.width / 2);
	CGFloat y;

	switch (self.indicatorPosition) {
		case V8HorizontalPickerIndicatorTop: {
			y = 0.0f;
			break;
		}
		case V8HorizontalPickerIndicatorBottom: {
			y = self.frame.size.height - indicatorFrame.size.height;
			break;
		}
		default:
			break;
	}

	// properly place indicator image in view relative to selection point
	CGRect tmpFrame = CGRectMake(x, y, indicatorFrame.size.width, indicatorFrame.size.height);
	self.selectionIndicatorView.frame = tmpFrame;
	[self addSubview:self.selectionIndicatorView];
}

// create a UILabel for this element.
- (V8HorizontalPickerLabel *)labelForForElementAtIndex:(NSInteger)index withTitle:(NSString *)title {
	CGRect labelFrame     = [self frameForElementAtIndex:index];
	V8HorizontalPickerLabel *elementLabel = [[V8HorizontalPickerLabel alloc] initWithFrame:labelFrame];

	elementLabel.textAlignment   = NSTextAlignmentCenter;
	elementLabel.backgroundColor = self.backgroundColor;
	elementLabel.text            = title;
	elementLabel.font            = self.elementFont;

	elementLabel.normalStateColor   = self.textColor;
	elementLabel.selectedStateColor = self.selectedTextColor;

	// show selected status if this element is the selected one and is currently over selectionPoint
	NSInteger currentIndex = [self nearestElementToCenter];
	elementLabel.selectedElement = (self.currentSelectedIndex == index) && (currentIndex == self.currentSelectedIndex);

	return elementLabel;
}


#pragma mark - DataSource Calling Method (Internal Method)
- (void)getNumberOfElementsFromDataSource {
	SEL dataSourceCall = @selector(numberOfElementsInHorizontalPickerView:);
	if (self.dataSource && [self.dataSource respondsToSelector:dataSourceCall]) {
		_numberOfElements = [self.dataSource numberOfElementsInHorizontalPickerView:self];
	} else {
		_numberOfElements = 0;
	}
}


#pragma mark - Delegate Calling Method (Internal Method)
- (void)getElementWidthsFromDelegate {
	SEL delegateCall = @selector(horizontalPickerView:widthForElementAtIndex:);
	[self.elementWidths removeAllObjects];
	for (int i = 0; i < self.numberOfElements; i++) {
		if (self.delegate && [self.delegate respondsToSelector:delegateCall]) {
			NSInteger width = [self.delegate horizontalPickerView:self widthForElementAtIndex:i];
			[self.elementWidths addObject:[NSNumber numberWithInteger:width]];
		}
	}
}


#pragma mark - View Calculation and Manipulation Methods (Internal Methods)
// what is the total width of the content area?
- (void)setTotalWidthOfScrollContent {
	NSInteger totalWidth = 0;

	totalWidth += [self leftScrollEdgeWidth];
	totalWidth += [self rightScrollEdgeWidth];

	// sum the width of all elements
	for (NSNumber *width in self.elementWidths) {
		totalWidth += [width intValue];
		totalWidth += self.elementPadding;
	}
	// TODO: is this necessary?
	totalWidth -= self.elementPadding; // we add "one too many" in for loop

	if (_scrollView) {
		// create our scroll view as wide as all the elements to be included
		_scrollView.contentSize = CGSizeMake(totalWidth, self.bounds.size.height);
		self.scrollSizeHasBeenSet = YES;
	}
}

// reset the content inset of the scroll view based on centering first and last elements.
- (void)updateScrollContentInset {
	// update content inset if we have element widths
	if ([self.elementWidths count] != 0) {
		CGFloat scrollerWidth = _scrollView.frame.size.width;

		CGFloat halfFirstWidth = 0.0f;
		CGFloat halfLastWidth  = 0.0f;
		if ( [self.elementWidths count] > 0 ) {
			halfFirstWidth = [[self.elementWidths objectAtIndex:0] floatValue] / 2.0; 
			halfLastWidth  = [[self.elementWidths lastObject] floatValue]      / 2.0;
		}

		// calculating the inset so that the bouncing on the ends happens more smooothly
		// - first inset is the distance from the left edge to the left edge of the
		//     first element when that element is centered under the selection point.
		//     - represented below as the # area
		// - last inset is the distance from the right edge to the right edge of
		//     the last element when that element is centered under the selection point.
		//     - represented below as the * area
		//
		//        Selection
		//  +---------|---------------+
		//  |####| Element |**********| << UIScrollView
		//  +-------------------------+
		CGFloat firstInset = self.selectionPoint.x - halfFirstWidth;
		firstInset -= [self leftScrollEdgeWidth];
		CGFloat lastInset  = (scrollerWidth - self.selectionPoint.x) - halfLastWidth;
		lastInset -= [self rightScrollEdgeWidth];

		_scrollView.contentInset = UIEdgeInsetsMake(0, firstInset, 0, lastInset);
	}
}

// what is the left-most edge of the element at the given index?
- (NSInteger)offsetForElementAtIndex:(NSInteger)index {
	NSInteger offset = 0;
	if (index >= [self.elementWidths count]) {
		return 0;
	}

	offset += [self leftScrollEdgeWidth];

	for (int i = 0; i < index && i < [self.elementWidths count]; i++) {
		offset += [[self.elementWidths objectAtIndex:i] intValue];
		offset += self.elementPadding;
	}
	return offset;
}

// return the tag for an element at a given index
- (NSInteger)tagForElementAtIndex:(NSInteger)index {
	return (index + 1) * 10;
}

// return the index given an element's tag
- (NSInteger)indexForElement:(UIView *)element {
	return (element.tag / 10) - 1;
}

// what is the center of the element at the given index?
- (NSInteger)centerOfElementAtIndex:(NSInteger)index {
	if (index >= [self.elementWidths count]) {
		return 0;
	}

	NSInteger elementOffset = [self offsetForElementAtIndex:index];
	NSInteger elementWidth  = [[self.elementWidths objectAtIndex:index] intValue] / 2;
	return elementOffset + elementWidth;
}

// what is the frame for the element at the given index?
- (CGRect)frameForElementAtIndex:(NSInteger)index {
	CGFloat width = 0.0f;
	if ([self.elementWidths count] > index) {
		width = [[self.elementWidths objectAtIndex:index] intValue];
	}
	return CGRectMake([self offsetForElementAtIndex:index], 0.0f, width, self.frame.size.height);
}

// what is the frame for the left scroll edge view?
- (CGRect)frameForLeftScrollEdgeView {
	if (self.leftScrollEdgeView) {
		CGFloat scrollHeight = _scrollView.contentSize.height;
		CGFloat viewHeight   = self.leftScrollEdgeView.frame.size.height;
		return CGRectMake(0.0f, ((scrollHeight / 2.0f) - (viewHeight / 2.0f)),
						  self.leftScrollEdgeView.frame.size.width, viewHeight);
	} else {
		return CGRectZero;
	}
}

// what is the width of the left edge of the scroll area?
- (CGFloat)leftScrollEdgeWidth {
	if (self.leftScrollEdgeView) {
		CGFloat width = self.leftScrollEdgeView.frame.size.width;
		width += self.scrollEdgeViewPadding;
		return width;
	}
	return 0.0f;
}

// what is the frame for the right scroll edge view?
- (CGRect)frameForRightScrollEdgeView {
	if (self.rightScrollEdgeView) {
		CGFloat scrollWidth  = _scrollView.contentSize.width;
		CGFloat scrollHeight = _scrollView.contentSize.height;
		CGFloat viewWidth  = self.rightScrollEdgeView.frame.size.width;
		CGFloat viewHeight = self.rightScrollEdgeView.frame.size.height;
		return CGRectMake(scrollWidth - viewWidth, ((scrollHeight / 2.0f) - (viewHeight / 2.0f)),
						  viewWidth, viewHeight);
	} else {
		return CGRectZero;
	}
}

// what is the width of the right edge of the scroll area?
- (CGFloat)rightScrollEdgeWidth {
	if (self.rightScrollEdgeView) {
		CGFloat width = self.rightScrollEdgeView.frame.size.width;
		width += self.scrollEdgeViewPadding;
		return width;
	}
	return 0.0f;
}

// what is the "center", relative to the content offset and adjusted to selection point?
- (CGPoint)currentCenter {
	CGFloat x = _scrollView.contentOffset.x + self.selectionPoint.x;
	return CGPointMake(x, 0.0f);
}

// what is the element nearest to the center of the view?
- (NSInteger)nearestElementToCenter {
	return [self nearestElementToPoint:[self currentCenter]];
}

// what is the element nearest to the given point?
- (NSInteger)nearestElementToPoint:(CGPoint)point {
	for (int i = 0; i < self.numberOfElements; i++) {
		CGRect frame = [self frameForElementAtIndex:i];
		if (CGRectContainsPoint(frame, point)) {
			return i;
		} else if (point.x < frame.origin.x) {
			// if the center is before this element, go back to last one,
			//     unless we're at the beginning
			if (i > 0) {
				return i - 1;
			} else {
				return 0;
			}
			break;
		} else if (point.x > frame.origin.y) {
			// if the center is past the last element, scroll to it
			if (i == self.numberOfElements - 1) {
				return i;
			}
		}
	}
	return 0;
}

// similar to nearestElementToPoint: however, this method does not look past beginning/end
- (NSInteger)elementContainingPoint:(CGPoint)point {
	for (int i = 0; i < self.numberOfElements; i++) {
		CGRect frame = [self frameForElementAtIndex:i];
		if (CGRectContainsPoint(frame, point)) {
			return i;
		}
	}
	return -1;
}

// move scroll view to position nearest element under the center
- (void)scrollToElementNearestToCenter {
//	[self scrollToElement:[self nearestElementToCenter] animated:YES];
}


#pragma mark - Tap Gesture Recognizer Handler Method
// use the gesture recognizer to slide to element under tap
- (void)scrollViewTapped:(UITapGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateRecognized) {
		CGPoint tapLocation    = [recognizer locationInView:_scrollView];
		NSInteger elementIndex = [self elementContainingPoint:tapLocation];
		if (elementIndex != -1) { // point not in element
			[self scrollToElement:elementIndex animated:YES];
		}
	}
}

@end


// ------------------------------------------------------------------------
#pragma mark - Picker Label Implementation
@implementation V8HorizontalPickerLabel : UILabel

- (void)setSelectedElement:(BOOL)selected {
	if (self.selectedElement != selected) {
		if (selected) {
			self.textColor = self.selectedStateColor;
		} else {
			self.textColor = self.normalStateColor;
		}
		_selectedElement = selected;
		[self setNeedsLayout];
	}
}

- (void)setNormalStateColor:(UIColor *)color {
	if (self.normalStateColor != color) {
		_normalStateColor = color;
		self.textColor = self.normalStateColor;
		[self setNeedsLayout];
	}
}

@end
