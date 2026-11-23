#import <AppKit/NSScrubber.h>
#import <AppKit/NSColor.h>

@interface NSScrubberLayout ()
- (void)_setScrubber:(NSScrubber *)scrubber;
@end

@implementation NSScrubberLayout

- (instancetype)init
{
    return [super init];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [super init];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
}

- (NSScrubber *)scrubber
{
    return _scrubber;
}

- (void)_setScrubber:(NSScrubber *)scrubber
{
    _scrubber = scrubber;
}

- (NSRect)visibleRect
{
    if (_scrubber == nil)
        return NSZeroRect;
    return [_scrubber bounds];
}

- (void)invalidateLayout
{
    [_scrubber setNeedsDisplay:YES];
}

@end

@implementation NSScrubberFlowLayout

- (instancetype)init
{
    if ((self = [super init])) {
        _itemSize = NSMakeSize(50, 30);
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        _itemSize = NSMakeSize(50, 30);
        if ([coder allowsKeyedCoding]) {
            if ([coder containsValueForKey:@"NSScrubberFlowLayoutItemSpacing"])
                _itemSpacing = [coder decodeDoubleForKey:@"NSScrubberFlowLayoutItemSpacing"];
            if ([coder containsValueForKey:@"NSScrubberFlowLayoutItemSize"])
                _itemSize = [coder decodeSizeForKey:@"NSScrubberFlowLayoutItemSize"];
        }
    }
    return self;
}

- (CGFloat)itemSpacing
{
    return _itemSpacing;
}

- (void)setItemSpacing:(CGFloat)spacing
{
    _itemSpacing = spacing;
    [self invalidateLayout];
}

- (NSSize)itemSize
{
    return _itemSize;
}

- (void)setItemSize:(NSSize)size
{
    _itemSize = size;
    [self invalidateLayout];
}

@end

@implementation NSScrubberProportionalLayout

- (instancetype)init
{
    if ((self = [super init])) {
        _numberOfVisibleItems = 5;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        _numberOfVisibleItems = 5;
        if ([coder allowsKeyedCoding] && [coder containsValueForKey:@"NSScrubberProportionalLayoutNumberOfVisibleItems"])
            _numberOfVisibleItems = [coder decodeIntegerForKey:@"NSScrubberProportionalLayoutNumberOfVisibleItems"];
    }
    return self;
}

- (NSInteger)numberOfVisibleItems
{
    return _numberOfVisibleItems;
}

- (void)setNumberOfVisibleItems:(NSInteger)count
{
    _numberOfVisibleItems = count;
    [self invalidateLayout];
}

@end

@implementation NSScrubberSelectionStyle

- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [super init];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
}

@end

@implementation NSScrubber

- (void)dealloc
{
    [_scrubberLayout _setScrubber:nil];
    [_scrubberLayout release];
    [_backgroundView release];
    [_backgroundColor release];
    [super dealloc];
}

- (id)dataSource
{
    return _dataSource;
}

- (void)setDataSource:(id)dataSource
{
    _dataSource = dataSource;
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)delegate
{
    _delegate = delegate;
}

- (NSScrubberLayout *)scrubberLayout
{
    return _scrubberLayout;
}

- (void)setScrubberLayout:(NSScrubberLayout *)layout
{
    if (layout == _scrubberLayout)
        return;
    [_scrubberLayout _setScrubber:nil];
    [layout retain];
    [_scrubberLayout release];
    _scrubberLayout = layout;
    [_scrubberLayout _setScrubber:self];
    [self setNeedsDisplay:YES];
}

- (NSInteger)numberOfItems
{
    if (_dataSource != nil && [_dataSource respondsToSelector:@selector(numberOfItemsForScrubber:)])
        _numberOfItems = [(id<NSScrubberDataSource>)_dataSource numberOfItemsForScrubber:self];
    return _numberOfItems;
}

- (NSInteger)selectedIndex
{
    return _selectedIndex;
}

- (void)setSelectedIndex:(NSInteger)index
{
    _selectedIndex = index;
    [self setNeedsDisplay:YES];
}

- (NSScrubberMode)mode
{
    return _mode;
}

- (void)setMode:(NSScrubberMode)mode
{
    _mode = mode;
}

- (NSScrubberAlignment)itemAlignment
{
    return _itemAlignment;
}

- (void)setItemAlignment:(NSScrubberAlignment)alignment
{
    _itemAlignment = alignment;
    [_scrubberLayout invalidateLayout];
}

- (BOOL)isContinuous
{
    return _continuous;
}

- (void)setContinuous:(BOOL)continuous
{
    _continuous = continuous;
}

- (BOOL)showsArrowButtons
{
    return _showsArrowButtons;
}

- (void)setShowsArrowButtons:(BOOL)flag
{
    _showsArrowButtons = flag;
    [self setNeedsDisplay:YES];
}

- (BOOL)showsAdditionalContentIndicators
{
    return _showsAdditionalContentIndicators;
}

- (void)setShowsAdditionalContentIndicators:(BOOL)flag
{
    _showsAdditionalContentIndicators = flag;
    [self setNeedsDisplay:YES];
}

- (NSColor *)backgroundColor
{
    return _backgroundColor;
}

- (void)setBackgroundColor:(NSColor *)color
{
    color = [color copy];
    [_backgroundColor release];
    _backgroundColor = color;
    [self setNeedsDisplay:YES];
}

- (NSView *)backgroundView
{
    return _backgroundView;
}

- (void)setBackgroundView:(NSView *)view
{
    if (view == _backgroundView)
        return;
    [_backgroundView removeFromSuperview];
    [view retain];
    [_backgroundView release];
    _backgroundView = view;
    if (view != nil) {
        [view setFrame:[self bounds]];
        [view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self addSubview:view positioned:NSWindowBelow relativeTo:nil];
    }
}

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes
{
    NSInteger count = [self numberOfItems];
    NSInteger removed = (NSInteger)[indexes count];
    if (_dataSource == nil || ![_dataSource respondsToSelector:@selector(numberOfItemsForScrubber:)])
        _numberOfItems = count > removed ? count - removed : 0;
    if (_selectedIndex >= 0 && [indexes containsIndex:_selectedIndex])
        _selectedIndex = -1;
    else if (_selectedIndex >= 0)
        _selectedIndex -= (NSInteger)[indexes countOfIndexesInRange:NSMakeRange(0, _selectedIndex)];
    [_scrubberLayout invalidateLayout];
    [self setNeedsDisplay:YES];
}

- (void)moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex
{
    if (_selectedIndex == oldIndex)
        _selectedIndex = newIndex;
    else if (oldIndex < newIndex && _selectedIndex > oldIndex && _selectedIndex <= newIndex)
        _selectedIndex--;
    else if (newIndex < oldIndex && _selectedIndex >= newIndex && _selectedIndex < oldIndex)
        _selectedIndex++;
    [_scrubberLayout invalidateLayout];
    [self setNeedsDisplay:YES];
}

@end
