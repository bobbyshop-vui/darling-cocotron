#import <AppKit/NSView.h>
#import <Foundation/Foundation.h>

const CGFloat NSGridViewSizeForContent = 0;

enum {
    NSGridCellPlacementInherited = 0,
    NSGridCellPlacementNone,
    NSGridCellPlacementLeading,
    NSGridCellPlacementTop = NSGridCellPlacementLeading,
    NSGridCellPlacementTrailing,
    NSGridCellPlacementBottom = NSGridCellPlacementTrailing,
    NSGridCellPlacementCenter,
    NSGridCellPlacementFill
};
typedef NSInteger NSGridCellPlacement;

enum {
    NSGridRowAlignmentInherited = 0,
    NSGridRowAlignmentNone,
    NSGridRowAlignmentFirstBaseline,
    NSGridRowAlignmentLastBaseline
};
typedef NSInteger NSGridRowAlignment;

@class NSGridView, NSGridCell, NSGridColumn, NSGridRow;

@interface NSGridView : NSView {
    NSGridCellPlacement _xPlacement;
    NSGridCellPlacement _yPlacement;
    NSGridRowAlignment _rowAlignment;
    CGFloat _rowSpacing;
    CGFloat _colSpacing;
    NSMutableArray *_columns;
    NSMutableArray *_rows;
    BOOL _isDecoding;
}
+ (instancetype)gridViewWithNumberOfColumns:(NSInteger)columnCount rows:(NSInteger)rowCount;
+ (instancetype)gridViewWithViews:(NSArray *)rows;
@property (readonly) NSInteger numberOfRows;
@property (readonly) NSInteger numberOfColumns;
- (NSGridRow *)rowAtIndex:(NSInteger)index;
- (NSInteger)indexOfRow:(NSGridRow *)row;
- (NSGridColumn *)columnAtIndex:(NSInteger)index;
- (NSInteger)indexOfColumn:(NSGridColumn *)column;
- (NSGridCell *)cellAtColumnIndex:(NSInteger)columnIndex rowIndex:(NSInteger)rowIndex;
- (NSGridCell *)cellForView:(NSView *)view;
- (NSGridRow *)addRowWithViews:(NSArray *)views;
- (NSGridRow *)insertRowAtIndex:(NSInteger)index withViews:(NSArray *)views;
- (void)moveRowAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
- (void)removeRowAtIndex:(NSInteger)index;
- (NSGridColumn *)addColumnWithViews:(NSArray *)views;
- (NSGridColumn *)insertColumnAtIndex:(NSInteger)index withViews:(NSArray *)views;
- (void)moveColumnAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
- (void)removeColumnAtIndex:(NSInteger)index;
@property NSGridCellPlacement xPlacement;
@property NSGridCellPlacement yPlacement;
@property NSGridRowAlignment rowAlignment;
@property CGFloat rowSpacing;
@property CGFloat columnSpacing;
- (void)mergeCellsInHorizontalRange:(NSRange)hRange verticalRange:(NSRange)vRange;
- (void)_relayoutGrid;
@end

@interface NSGridRow : NSObject <NSCoding> {
    NSGridView *_owningGridView;
    NSMutableArray *_cells;
    NSGridCellPlacement _yPlacement;
    NSGridRowAlignment _rowAlignment;
    CGFloat _height;
    CGFloat _topPadding;
    CGFloat _bottomPadding;
    BOOL _hidden;
}
@property (readonly, assign) NSGridView *gridView;
@property (readonly) NSInteger numberOfCells;
- (NSGridCell *)cellAtIndex:(NSInteger)index;
@property NSGridCellPlacement yPlacement;
@property NSGridRowAlignment rowAlignment;
@property CGFloat height;
@property CGFloat topPadding;
@property CGFloat bottomPadding;
@property (getter=isHidden) BOOL hidden;
- (void)mergeCellsInRange:(NSRange)range;
@end

@interface NSGridColumn : NSObject <NSCoding> {
    NSGridView *_owningGridView;
    NSGridCellPlacement _xPlacement;
    CGFloat _width;
    CGFloat _trailingPadding;
    CGFloat _leadingPadding;
    BOOL _hidden;
}
@property (readonly, assign) NSGridView *gridView;
@property (readonly) NSInteger numberOfCells;
- (NSGridCell *)cellAtIndex:(NSInteger)index;
@property NSGridCellPlacement xPlacement;
@property CGFloat width;
@property CGFloat leadingPadding;
@property CGFloat trailingPadding;
@property (getter=isHidden) BOOL hidden;
- (void)mergeCellsInRange:(NSRange)range;
@end

@interface NSGridCell : NSObject <NSCoding> {
    NSGridRow *_row;
    NSGridColumn *_column;
    NSView *_contentView;
    NSGridCell *_headOfMergedCell;
    NSArray *_customPlacementConstraints;
    NSGridCellPlacement _xPlacement;
    NSGridCellPlacement _yPlacement;
    NSGridRowAlignment _rowAlignment;
}
@property (retain) NSView *contentView;
+ (NSView *)emptyContentView;
@property (readonly, assign) NSGridRow *row;
@property (readonly, assign) NSGridColumn *column;
@property NSGridCellPlacement xPlacement;
@property NSGridCellPlacement yPlacement;
@property NSGridRowAlignment rowAlignment;
@property (copy) NSArray *customPlacementConstraints;
@end

// Private cross-class access
@interface NSGridRow ()
- (void)_setGridView:(NSGridView *)grid;
- (NSMutableArray *)_cells;
@end
@interface NSGridColumn ()
- (void)_setGridView:(NSGridView *)grid;
@end
@interface NSGridCell ()
- (void)_setRow:(NSGridRow *)row;
- (void)_setColumn:(NSGridColumn *)column;
- (NSGridCell *)_headOfMergedCell;
- (void)_setHeadOfMergedCell:(NSGridCell *)head;
- (void)_detach;
@end

static NSGridCellPlacement resolvePlacement(NSGridCellPlacement cell, NSGridCellPlacement line, NSGridCellPlacement grid, NSGridCellPlacement fallback)
{
    if (cell != NSGridCellPlacementInherited)
        return cell;
    if (line != NSGridCellPlacementInherited)
        return line;
    if (grid != NSGridCellPlacementInherited)
        return grid;
    return fallback;
}

static NSView *gridEmptyContentView = nil;

@implementation NSGridCell

@synthesize row = _row;
@synthesize column = _column;
@synthesize xPlacement = _xPlacement;
@synthesize yPlacement = _yPlacement;
@synthesize rowAlignment = _rowAlignment;

+ (NSView *)emptyContentView
{
    @synchronized(self) {
        if (gridEmptyContentView == nil)
            gridEmptyContentView = [[NSView alloc] initWithFrame:NSZeroRect];
    }
    return gridEmptyContentView;
}

- (id)init
{
    if ((self = [super init])) {
        _xPlacement = NSGridCellPlacementInherited;
        _yPlacement = NSGridCellPlacementInherited;
        _rowAlignment = NSGridRowAlignmentInherited;
    }
    return self;
}

- (void)dealloc
{
    [_contentView release];
    [_customPlacementConstraints release];
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if (_contentView != nil)
        [coder encodeObject:_contentView forKey:@"NSGridCellContentView"];
    if (_customPlacementConstraints != nil)
        [coder encodeObject:_customPlacementConstraints forKey:@"NSGridCellCustomPlacementConstraints"];
    [coder encodeInteger:_xPlacement forKey:@"NSGridCellXPlacement"];
    [coder encodeInteger:_yPlacement forKey:@"NSGridCellYPlacement"];
    [coder encodeInteger:_rowAlignment forKey:@"NSGridCellRowAlignment"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [self init])) {
        _contentView = [[coder decodeObjectForKey:@"NSGridCellContentView"] retain];
        _customPlacementConstraints = [[coder decodeObjectForKey:@"NSGridCellCustomPlacementConstraints"] copy];
        _xPlacement = [coder decodeIntegerForKey:@"NSGridCellXPlacement"];
        _yPlacement = [coder decodeIntegerForKey:@"NSGridCellYPlacement"];
        _rowAlignment = [coder decodeIntegerForKey:@"NSGridCellRowAlignment"];
    }
    return self;
}

- (void)_setRow:(NSGridRow *)row
{
    _row = row;
}

- (void)_setColumn:(NSGridColumn *)column
{
    _column = column;
}

- (NSGridCell *)_headOfMergedCell
{
    return _headOfMergedCell;
}

- (void)_setHeadOfMergedCell:(NSGridCell *)head
{
    _headOfMergedCell = (head == self) ? nil : head;
}

- (void)_detach
{
    if (_contentView != nil && [_contentView superview] == [_row gridView])
        [_contentView removeFromSuperview];
    _row = nil;
    _column = nil;
}

- (NSView *)contentView
{
    return _contentView;
}

- (void)setContentView:(NSView *)view
{
    if (view == gridEmptyContentView)
        view = nil;
    if (view == _contentView)
        return;
    NSGridView *grid = [_row gridView];
    if (_contentView != nil && grid != nil && [_contentView superview] == grid)
        [_contentView removeFromSuperview];
    [view retain];
    [_contentView release];
    _contentView = view;
    if (_contentView != nil && grid != nil && [_contentView superview] != grid)
        [grid addSubview:_contentView];
    [grid _relayoutGrid];
}

- (NSArray *)customPlacementConstraints
{
    return _customPlacementConstraints != nil ? _customPlacementConstraints : [NSArray array];
}

- (void)setCustomPlacementConstraints:(NSArray *)constraints
{
    if (constraints == _customPlacementConstraints)
        return;
    [_customPlacementConstraints release];
    _customPlacementConstraints = [constraints copy];
}

- (void)setXPlacement:(NSGridCellPlacement)placement
{
    _xPlacement = placement;
    [[_row gridView] _relayoutGrid];
}

- (void)setYPlacement:(NSGridCellPlacement)placement
{
    _yPlacement = placement;
    [[_row gridView] _relayoutGrid];
}

- (void)setRowAlignment:(NSGridRowAlignment)alignment
{
    _rowAlignment = alignment;
    [[_row gridView] _relayoutGrid];
}

@end

@implementation NSGridRow

@synthesize gridView = _owningGridView;
@synthesize yPlacement = _yPlacement;
@synthesize rowAlignment = _rowAlignment;
@synthesize height = _height;
@synthesize topPadding = _topPadding;
@synthesize bottomPadding = _bottomPadding;
@synthesize hidden = _hidden;

- (id)init
{
    if ((self = [super init])) {
        _cells = [[NSMutableArray alloc] init];
        _yPlacement = NSGridCellPlacementInherited;
        _rowAlignment = NSGridRowAlignmentInherited;
        _height = NSGridViewSizeForContent;
    }
    return self;
}

- (void)dealloc
{
    [_cells release];
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_cells forKey:@"NSGridRowCells"];
    [coder encodeInteger:_yPlacement forKey:@"NSGridRowYPlacement"];
    [coder encodeInteger:_rowAlignment forKey:@"NSGridRowAlignment"];
    [coder encodeDouble:_height forKey:@"NSGridRowHeight"];
    [coder encodeDouble:_topPadding forKey:@"NSGridRowTopPadding"];
    [coder encodeDouble:_bottomPadding forKey:@"NSGridRowBottomPadding"];
    [coder encodeBool:_hidden forKey:@"NSGridRowHidden"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [self init])) {
        NSArray *cells = [coder decodeObjectForKey:@"NSGridRowCells"];
        if (cells != nil)
            [_cells addObjectsFromArray:cells];
        for (NSGridCell *cell in _cells)
            [cell _setRow:self];
        _yPlacement = [coder decodeIntegerForKey:@"NSGridRowYPlacement"];
        _rowAlignment = [coder decodeIntegerForKey:@"NSGridRowAlignment"];
        _height = [coder containsValueForKey:@"NSGridRowHeight"] ? [coder decodeDoubleForKey:@"NSGridRowHeight"] : NSGridViewSizeForContent;
        _topPadding = [coder decodeDoubleForKey:@"NSGridRowTopPadding"];
        _bottomPadding = [coder decodeDoubleForKey:@"NSGridRowBottomPadding"];
        _hidden = [coder decodeBoolForKey:@"NSGridRowHidden"];
    }
    return self;
}

- (void)_setGridView:(NSGridView *)grid
{
    _owningGridView = grid;
}

- (NSMutableArray *)_cells
{
    return _cells;
}

- (NSInteger)numberOfCells
{
    return [_cells count];
}

- (NSGridCell *)cellAtIndex:(NSInteger)index
{
    if (index < 0 || index >= (NSInteger)[_cells count])
        [NSException raise:NSRangeException format:@"NSGridRow: cell index %ld out of range", (long)index];
    return [_cells objectAtIndex:index];
}

- (void)setYPlacement:(NSGridCellPlacement)value
{
    _yPlacement = value;
    [_owningGridView _relayoutGrid];
}

- (void)setRowAlignment:(NSGridRowAlignment)value
{
    _rowAlignment = value;
    [_owningGridView _relayoutGrid];
}

- (void)setHeight:(CGFloat)value
{
    _height = value;
    [_owningGridView _relayoutGrid];
}

- (void)setTopPadding:(CGFloat)value
{
    _topPadding = value;
    [_owningGridView _relayoutGrid];
}

- (void)setBottomPadding:(CGFloat)value
{
    _bottomPadding = value;
    [_owningGridView _relayoutGrid];
}

- (void)setHidden:(BOOL)value
{
    _hidden = value;
    [_owningGridView _relayoutGrid];
}

- (void)mergeCellsInRange:(NSRange)range
{
    NSInteger columns = [_owningGridView numberOfColumns];
    if (NSMaxRange(range) > (NSUInteger)columns)
        [NSException raise:NSRangeException format:@"NSGridRow: merge range out of range"];
    NSInteger row = [_owningGridView indexOfRow:self];
    [_owningGridView mergeCellsInHorizontalRange:range verticalRange:NSMakeRange(row, 1)];
}

@end

@implementation NSGridColumn

@synthesize gridView = _owningGridView;
@synthesize xPlacement = _xPlacement;
@synthesize width = _width;
@synthesize leadingPadding = _leadingPadding;
@synthesize trailingPadding = _trailingPadding;
@synthesize hidden = _hidden;

- (id)init
{
    if ((self = [super init])) {
        _xPlacement = NSGridCellPlacementInherited;
        _width = NSGridViewSizeForContent;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:_xPlacement forKey:@"NSGridColumnXPlacement"];
    [coder encodeDouble:_width forKey:@"NSGridColumnWidth"];
    [coder encodeDouble:_leadingPadding forKey:@"NSGridColumnLeadingPadding"];
    [coder encodeDouble:_trailingPadding forKey:@"NSGridColumnTrailingPadding"];
    [coder encodeBool:_hidden forKey:@"NSGridColumnHidden"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [self init])) {
        _xPlacement = [coder decodeIntegerForKey:@"NSGridColumnXPlacement"];
        _width = [coder containsValueForKey:@"NSGridColumnWidth"] ? [coder decodeDoubleForKey:@"NSGridColumnWidth"] : NSGridViewSizeForContent;
        _leadingPadding = [coder decodeDoubleForKey:@"NSGridColumnLeadingPadding"];
        _trailingPadding = [coder decodeDoubleForKey:@"NSGridColumnTrailingPadding"];
        _hidden = [coder decodeBoolForKey:@"NSGridColumnHidden"];
    }
    return self;
}

- (void)_setGridView:(NSGridView *)grid
{
    _owningGridView = grid;
}

- (NSInteger)numberOfCells
{
    return [_owningGridView numberOfRows];
}

- (NSGridCell *)cellAtIndex:(NSInteger)index
{
    NSInteger column = [_owningGridView indexOfColumn:self];
    return [_owningGridView cellAtColumnIndex:column rowIndex:index];
}

- (void)setXPlacement:(NSGridCellPlacement)value
{
    _xPlacement = value;
    [_owningGridView _relayoutGrid];
}

- (void)setWidth:(CGFloat)value
{
    _width = value;
    [_owningGridView _relayoutGrid];
}

- (void)setLeadingPadding:(CGFloat)value
{
    _leadingPadding = value;
    [_owningGridView _relayoutGrid];
}

- (void)setTrailingPadding:(CGFloat)value
{
    _trailingPadding = value;
    [_owningGridView _relayoutGrid];
}

- (void)setHidden:(BOOL)value
{
    _hidden = value;
    [_owningGridView _relayoutGrid];
}

- (void)mergeCellsInRange:(NSRange)range
{
    NSInteger rows = [_owningGridView numberOfRows];
    if (NSMaxRange(range) > (NSUInteger)rows)
        [NSException raise:NSRangeException format:@"NSGridColumn: merge range out of range"];
    NSInteger column = [_owningGridView indexOfColumn:self];
    [_owningGridView mergeCellsInHorizontalRange:NSMakeRange(column, 1) verticalRange:range];
}

@end

@implementation NSGridView

@synthesize xPlacement = _xPlacement;
@synthesize yPlacement = _yPlacement;
@synthesize rowAlignment = _rowAlignment;
@synthesize rowSpacing = _rowSpacing;
@synthesize columnSpacing = _colSpacing;

- (void)_gridCommonInit
{
    _columns = [[NSMutableArray alloc] init];
    _rows = [[NSMutableArray alloc] init];
    _xPlacement = NSGridCellPlacementLeading;
    _yPlacement = NSGridCellPlacementCenter;
    _rowAlignment = NSGridRowAlignmentInherited;
    _rowSpacing = 6.0;
    _colSpacing = 6.0;
}

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame]))
        [self _gridCommonInit];
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        [self _gridCommonInit];
        _isDecoding = YES;
        NSArray *columns = [coder decodeObjectForKey:@"NSGridViewColumns"];
        NSArray *rows = [coder decodeObjectForKey:@"NSGridViewRows"];
        if (columns != nil)
            [_columns addObjectsFromArray:columns];
        if (rows != nil)
            [_rows addObjectsFromArray:rows];
        for (NSGridColumn *column in _columns)
            [column _setGridView:self];
        for (NSGridRow *row in _rows) {
            [row _setGridView:self];
            NSMutableArray *cells = [row _cells];
            for (NSUInteger i = 0; i < [cells count]; i++) {
                NSGridCell *cell = [cells objectAtIndex:i];
                [cell _setRow:row];
                if (i < [_columns count])
                    [cell _setColumn:[_columns objectAtIndex:i]];
                NSView *content = [cell contentView];
                if (content != nil && [content superview] != self)
                    [self addSubview:content];
            }
        }
        if ([coder containsValueForKey:@"NSGridViewXPlacement"])
            _xPlacement = [coder decodeIntegerForKey:@"NSGridViewXPlacement"];
        if ([coder containsValueForKey:@"NSGridViewYPlacement"])
            _yPlacement = [coder decodeIntegerForKey:@"NSGridViewYPlacement"];
        _rowAlignment = [coder decodeIntegerForKey:@"NSGridViewRowAlignment"];
        if ([coder containsValueForKey:@"NSGridViewRowSpacing"])
            _rowSpacing = [coder decodeDoubleForKey:@"NSGridViewRowSpacing"];
        if ([coder containsValueForKey:@"NSGridViewColumnSpacing"])
            _colSpacing = [coder decodeDoubleForKey:@"NSGridViewColumnSpacing"];
        _isDecoding = NO;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:_columns forKey:@"NSGridViewColumns"];
    [coder encodeObject:_rows forKey:@"NSGridViewRows"];
    [coder encodeInteger:_xPlacement forKey:@"NSGridViewXPlacement"];
    [coder encodeInteger:_yPlacement forKey:@"NSGridViewYPlacement"];
    [coder encodeInteger:_rowAlignment forKey:@"NSGridViewRowAlignment"];
    [coder encodeDouble:_rowSpacing forKey:@"NSGridViewRowSpacing"];
    [coder encodeDouble:_colSpacing forKey:@"NSGridViewColumnSpacing"];
}

- (void)dealloc
{
    for (NSGridRow *row in _rows)
        [row _setGridView:nil];
    for (NSGridColumn *column in _columns)
        [column _setGridView:nil];
    [_columns release];
    [_rows release];
    [super dealloc];
}

+ (instancetype)gridViewWithNumberOfColumns:(NSInteger)columnCount rows:(NSInteger)rowCount
{
    NSGridView *grid = [[[self alloc] initWithFrame:NSZeroRect] autorelease];
    for (NSInteger i = 0; i < columnCount; i++)
        [grid addColumnWithViews:[NSArray array]];
    for (NSInteger i = 0; i < rowCount; i++)
        [grid addRowWithViews:[NSArray array]];
    return grid;
}

+ (instancetype)gridViewWithViews:(NSArray *)rows
{
    NSGridView *grid = [[[self alloc] initWithFrame:NSZeroRect] autorelease];
    for (NSArray *views in rows)
        [grid addRowWithViews:views];
    return grid;
}

- (NSInteger)numberOfRows
{
    return [_rows count];
}

- (NSInteger)numberOfColumns
{
    return [_columns count];
}

- (NSGridRow *)rowAtIndex:(NSInteger)index
{
    if (index < 0 || index >= (NSInteger)[_rows count])
        [NSException raise:NSRangeException format:@"NSGridView: row index %ld out of range", (long)index];
    return [_rows objectAtIndex:index];
}

- (NSInteger)indexOfRow:(NSGridRow *)row
{
    NSUInteger index = [_rows indexOfObjectIdenticalTo:row];
    return index == NSNotFound ? NSNotFound : (NSInteger)index;
}

- (NSGridColumn *)columnAtIndex:(NSInteger)index
{
    if (index < 0 || index >= (NSInteger)[_columns count])
        [NSException raise:NSRangeException format:@"NSGridView: column index %ld out of range", (long)index];
    return [_columns objectAtIndex:index];
}

- (NSInteger)indexOfColumn:(NSGridColumn *)column
{
    NSUInteger index = [_columns indexOfObjectIdenticalTo:column];
    return index == NSNotFound ? NSNotFound : (NSInteger)index;
}

- (NSGridCell *)cellAtColumnIndex:(NSInteger)columnIndex rowIndex:(NSInteger)rowIndex
{
    if (columnIndex < 0 || columnIndex >= (NSInteger)[_columns count])
        [NSException raise:NSRangeException format:@"NSGridView: column index %ld out of range", (long)columnIndex];
    return [[self rowAtIndex:rowIndex] cellAtIndex:columnIndex];
}

- (NSGridCell *)cellForView:(NSView *)view
{
    while (view != nil && view != self) {
        for (NSGridRow *row in _rows)
            for (NSGridCell *cell in [row _cells])
                if ([cell contentView] == view)
                    return cell;
        view = [view superview];
    }
    return nil;
}

- (NSGridCell *)_newCellForRow:(NSGridRow *)row column:(NSGridColumn *)column view:(NSView *)view
{
    NSGridCell *cell = [[[NSGridCell alloc] init] autorelease];
    [cell _setRow:row];
    [cell _setColumn:column];
    if (view != nil && view != [NSGridCell emptyContentView]) {
        [cell setContentView:view];
    }
    return cell;
}

- (void)_addColumnToEnd
{
    NSGridColumn *column = [[[NSGridColumn alloc] init] autorelease];
    [column _setGridView:self];
    [_columns addObject:column];
    for (NSGridRow *row in _rows)
        [[row _cells] addObject:[self _newCellForRow:row column:column view:nil]];
}

- (NSGridRow *)insertRowAtIndex:(NSInteger)index withViews:(NSArray *)views
{
    if (index < 0 || index > (NSInteger)[_rows count])
        [NSException raise:NSRangeException format:@"NSGridView: row index %ld out of range", (long)index];
    while ((NSInteger)[views count] > (NSInteger)[_columns count])
        [self _addColumnToEnd];
    NSGridRow *row = [[[NSGridRow alloc] init] autorelease];
    [row _setGridView:self];
    [_rows insertObject:row atIndex:index];
    for (NSUInteger i = 0; i < [_columns count]; i++) {
        NSView *view = i < [views count] ? [views objectAtIndex:i] : nil;
        [[row _cells] addObject:[self _newCellForRow:row column:[_columns objectAtIndex:i] view:view]];
    }
    [self _relayoutGrid];
    return row;
}

- (NSGridRow *)addRowWithViews:(NSArray *)views
{
    return [self insertRowAtIndex:[_rows count] withViews:views];
}

- (void)moveRowAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    NSGridRow *row = [self rowAtIndex:fromIndex];
    if (toIndex < 0 || toIndex >= (NSInteger)[_rows count])
        [NSException raise:NSRangeException format:@"NSGridView: row index %ld out of range", (long)toIndex];
    [row retain];
    [_rows removeObjectAtIndex:fromIndex];
    [_rows insertObject:row atIndex:toIndex];
    [row release];
    [self _relayoutGrid];
}

- (void)_clearMergesReferencing:(NSSet *)removed
{
    for (NSGridRow *row in _rows)
        for (NSGridCell *cell in [row _cells]) {
            NSGridCell *head = [cell _headOfMergedCell];
            if (head != nil && [removed containsObject:head])
                [cell _setHeadOfMergedCell:nil];
        }
}

- (void)removeRowAtIndex:(NSInteger)index
{
    NSGridRow *row = [self rowAtIndex:index];
    [row retain];
    [_rows removeObjectAtIndex:index];
    NSSet *removed = [NSSet setWithArray:[row _cells]];
    for (NSGridCell *cell in [row _cells])
        [cell _detach];
    [row _setGridView:nil];
    [row release];
    [self _clearMergesReferencing:removed];
    [self _relayoutGrid];
}

- (NSGridColumn *)insertColumnAtIndex:(NSInteger)index withViews:(NSArray *)views
{
    if (index < 0 || index > (NSInteger)[_columns count])
        [NSException raise:NSRangeException format:@"NSGridView: column index %ld out of range", (long)index];
    while ((NSInteger)[views count] > (NSInteger)[_rows count])
        [self addRowWithViews:[NSArray array]];
    NSGridColumn *column = [[[NSGridColumn alloc] init] autorelease];
    [column _setGridView:self];
    [_columns insertObject:column atIndex:index];
    for (NSUInteger i = 0; i < [_rows count]; i++) {
        NSGridRow *row = [_rows objectAtIndex:i];
        NSView *view = i < [views count] ? [views objectAtIndex:i] : nil;
        [[row _cells] insertObject:[self _newCellForRow:row column:column view:view] atIndex:index];
    }
    [self _relayoutGrid];
    return column;
}

- (NSGridColumn *)addColumnWithViews:(NSArray *)views
{
    return [self insertColumnAtIndex:[_columns count] withViews:views];
}

- (void)moveColumnAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    NSGridColumn *column = [self columnAtIndex:fromIndex];
    if (toIndex < 0 || toIndex >= (NSInteger)[_columns count])
        [NSException raise:NSRangeException format:@"NSGridView: column index %ld out of range", (long)toIndex];
    [column retain];
    [_columns removeObjectAtIndex:fromIndex];
    [_columns insertObject:column atIndex:toIndex];
    [column release];
    for (NSGridRow *row in _rows) {
        NSMutableArray *cells = [row _cells];
        NSGridCell *cell = [[cells objectAtIndex:fromIndex] retain];
        [cells removeObjectAtIndex:fromIndex];
        [cells insertObject:cell atIndex:toIndex];
        [cell release];
    }
    [self _relayoutGrid];
}

- (void)removeColumnAtIndex:(NSInteger)index
{
    NSGridColumn *column = [self columnAtIndex:index];
    [column retain];
    [_columns removeObjectAtIndex:index];
    NSMutableSet *removed = [NSMutableSet set];
    for (NSGridRow *row in _rows) {
        NSGridCell *cell = [[row _cells] objectAtIndex:index];
        [removed addObject:cell];
        [cell _detach];
        [[row _cells] removeObjectAtIndex:index];
    }
    [column _setGridView:nil];
    [column release];
    [self _clearMergesReferencing:removed];
    [self _relayoutGrid];
}

- (void)setXPlacement:(NSGridCellPlacement)value
{
    _xPlacement = value;
    [self _relayoutGrid];
}

- (void)setYPlacement:(NSGridCellPlacement)value
{
    _yPlacement = value;
    [self _relayoutGrid];
}

- (void)setRowAlignment:(NSGridRowAlignment)value
{
    _rowAlignment = value;
    [self _relayoutGrid];
}

- (void)setRowSpacing:(CGFloat)value
{
    _rowSpacing = value;
    [self _relayoutGrid];
}

- (void)setColumnSpacing:(CGFloat)value
{
    _colSpacing = value;
    [self _relayoutGrid];
}

- (void)mergeCellsInHorizontalRange:(NSRange)hRange verticalRange:(NSRange)vRange
{
    if (NSMaxRange(hRange) > [_columns count] || NSMaxRange(vRange) > [_rows count])
        [NSException raise:NSRangeException format:@"NSGridView: merge range out of range"];
    if (hRange.length == 0 || vRange.length == 0)
        return;
    NSGridCell *head = [self cellAtColumnIndex:hRange.location rowIndex:vRange.location];
    for (NSUInteger r = vRange.location; r < NSMaxRange(vRange); r++)
        for (NSUInteger c = hRange.location; c < NSMaxRange(hRange); c++) {
            NSGridCell *cell = [self cellAtColumnIndex:c rowIndex:r];
            [cell _setHeadOfMergedCell:head];
            if (cell != head)
                [cell setContentView:nil];
        }
    [self _relayoutGrid];
}

#pragma mark Layout

- (NSSize)_contentSizeOfCell:(NSGridCell *)cell
{
    NSView *view = [cell contentView];
    return view != nil ? [view frame].size : NSZeroSize;
}

- (NSSize)_gridContentSize:(CGFloat **)outColumnWidths rows:(CGFloat **)outRowHeights
{
    NSUInteger nc = [_columns count], nr = [_rows count];
    CGFloat *widths = calloc(nc ? nc : 1, sizeof(CGFloat));
    CGFloat *heights = calloc(nr ? nr : 1, sizeof(CGFloat));

    for (NSUInteger r = 0; r < nr; r++) {
        NSGridRow *row = [_rows objectAtIndex:r];
        for (NSUInteger c = 0; c < nc; c++) {
            NSGridCell *cell = [[row _cells] objectAtIndex:c];
            if ([cell _headOfMergedCell] != nil)
                continue;
            NSSize size = [self _contentSizeOfCell:cell];
            if (size.width > widths[c])
                widths[c] = size.width;
            if (size.height > heights[r])
                heights[r] = size.height;
        }
    }
    for (NSUInteger c = 0; c < nc; c++) {
        NSGridColumn *column = [_columns objectAtIndex:c];
        if ([column isHidden])
            widths[c] = 0;
        else if ([column width] != NSGridViewSizeForContent)
            widths[c] = [column width];
    }
    for (NSUInteger r = 0; r < nr; r++) {
        NSGridRow *row = [_rows objectAtIndex:r];
        if ([row isHidden])
            heights[r] = 0;
        else if ([row height] != NSGridViewSizeForContent)
            heights[r] = [row height];
    }

    CGFloat total = 0;
    BOOL any = NO;
    for (NSUInteger c = 0; c < nc; c++) {
        NSGridColumn *column = [_columns objectAtIndex:c];
        if ([column isHidden])
            continue;
        if (any)
            total += _colSpacing;
        total += [column leadingPadding] + widths[c] + [column trailingPadding];
        any = YES;
    }
    CGFloat totalH = 0;
    any = NO;
    for (NSUInteger r = 0; r < nr; r++) {
        NSGridRow *row = [_rows objectAtIndex:r];
        if ([row isHidden])
            continue;
        if (any)
            totalH += _rowSpacing;
        totalH += [row topPadding] + heights[r] + [row bottomPadding];
        any = YES;
    }
    *outColumnWidths = widths;
    *outRowHeights = heights;
    return NSMakeSize(total, totalH);
}

- (void)_relayoutGrid
{
    if (_isDecoding || _rows == nil)
        return;
    NSUInteger nc = [_columns count], nr = [_rows count];
    CGFloat *widths = NULL, *heights = NULL;
    NSSize total = [self _gridContentSize:&widths rows:&heights];
    (void)total;

    CGFloat *xs = calloc(nc ? nc : 1, sizeof(CGFloat));
    CGFloat *ys = calloc(nr ? nr : 1, sizeof(CGFloat));
    CGFloat gridHeight = NSHeight([self bounds]);

    CGFloat x = 0;
    BOOL any = NO;
    for (NSUInteger c = 0; c < nc; c++) {
        NSGridColumn *column = [_columns objectAtIndex:c];
        if ([column isHidden])
            continue;
        if (any)
            x += _colSpacing;
        x += [column leadingPadding];
        xs[c] = x;
        x += widths[c] + [column trailingPadding];
        any = YES;
    }
    // Row 0 is at the top of the grid; ys holds the distance from the top edge.
    CGFloat y = 0;
    any = NO;
    for (NSUInteger r = 0; r < nr; r++) {
        NSGridRow *row = [_rows objectAtIndex:r];
        if ([row isHidden])
            continue;
        if (any)
            y += _rowSpacing;
        y += [row topPadding];
        ys[r] = y;
        y += heights[r] + [row bottomPadding];
        any = YES;
    }

    for (NSUInteger r = 0; r < nr; r++) {
        NSGridRow *row = [_rows objectAtIndex:r];
        for (NSUInteger c = 0; c < nc; c++) {
            NSGridColumn *column = [_columns objectAtIndex:c];
            NSGridCell *cell = [[row _cells] objectAtIndex:c];
            NSView *view = [cell contentView];
            if (view == nil)
                continue;
            // The cell rectangle spans every cell merged into this one.
            NSUInteger c0 = c, c1 = c, r0 = r, r1 = r;
            for (NSUInteger rr = 0; rr < nr; rr++)
                for (NSUInteger cc = 0; cc < nc; cc++) {
                    NSGridCell *other = [[[_rows objectAtIndex:rr] _cells] objectAtIndex:cc];
                    if (other == cell || [other _headOfMergedCell] == cell) {
                        if (cc < c0) c0 = cc;
                        if (cc > c1) c1 = cc;
                        if (rr < r0) r0 = rr;
                        if (rr > r1) r1 = rr;
                    }
                }
            BOOL hidden = NO;
            for (NSUInteger rr = r0; rr <= r1; rr++)
                for (NSUInteger cc = c0; cc <= c1; cc++)
                    if ([[_rows objectAtIndex:rr] isHidden] && [[_columns objectAtIndex:cc] isHidden])
                        hidden = YES;
            BOOL allRowsHidden = YES, allColsHidden = YES;
            for (NSUInteger rr = r0; rr <= r1; rr++)
                if (![[_rows objectAtIndex:rr] isHidden]) allRowsHidden = NO;
            for (NSUInteger cc = c0; cc <= c1; cc++)
                if (![[_columns objectAtIndex:cc] isHidden]) allColsHidden = NO;
            hidden = allRowsHidden || allColsHidden;
            [view setHidden:hidden];
            if (hidden)
                continue;

            CGFloat left = CGFLOAT_MAX, right = -CGFLOAT_MAX, top = CGFLOAT_MAX, bottom = -CGFLOAT_MAX;
            for (NSUInteger cc = c0; cc <= c1; cc++) {
                if ([[_columns objectAtIndex:cc] isHidden]) continue;
                if (xs[cc] < left) left = xs[cc];
                if (xs[cc] + widths[cc] > right) right = xs[cc] + widths[cc];
            }
            for (NSUInteger rr = r0; rr <= r1; rr++) {
                if ([[_rows objectAtIndex:rr] isHidden]) continue;
                if (ys[rr] < top) top = ys[rr];
                if (ys[rr] + heights[rr] > bottom) bottom = ys[rr] + heights[rr];
            }

            NSGridRow *headRow = [_rows objectAtIndex:r];
            NSGridCellPlacement xp = resolvePlacement([cell xPlacement], [column xPlacement], _xPlacement, NSGridCellPlacementLeading);
            NSGridCellPlacement yp = resolvePlacement([cell yPlacement], [headRow yPlacement], _yPlacement, NSGridCellPlacementCenter);

            NSRect frame = [view frame];
            CGFloat cellW = right - left, cellH = bottom - top;
            switch (xp) {
            case NSGridCellPlacementFill:
                frame.size.width = cellW;
                frame.origin.x = left;
                break;
            case NSGridCellPlacementTrailing:
                frame.origin.x = right - frame.size.width;
                break;
            case NSGridCellPlacementCenter:
                frame.origin.x = left + (cellW - frame.size.width) / 2.0;
                break;
            case NSGridCellPlacementNone:
                break;
            default:
                frame.origin.x = left;
                break;
            }
            CGFloat topOffset = top;
            switch (yp) {
            case NSGridCellPlacementFill:
                frame.size.height = cellH;
                topOffset = top;
                break;
            case NSGridCellPlacementBottom:
                topOffset = bottom - frame.size.height;
                break;
            case NSGridCellPlacementCenter:
                topOffset = top + (cellH - frame.size.height) / 2.0;
                break;
            case NSGridCellPlacementNone:
                topOffset = gridHeight - NSMaxY(frame);
                break;
            default:
                topOffset = top;
                break;
            }
            if (yp != NSGridCellPlacementNone || xp != NSGridCellPlacementNone) {
                if ([self isFlipped])
                    frame.origin.y = topOffset;
                else
                    frame.origin.y = gridHeight - topOffset - frame.size.height;
            }
            if (!NSEqualRects(frame, [view frame]))
                [view setFrame:frame];
        }
    }
    free(widths);
    free(heights);
    free(xs);
    free(ys);
}

- (NSSize)fittingSize
{
    CGFloat *widths = NULL, *heights = NULL;
    NSSize size = [self _gridContentSize:&widths rows:&heights];
    free(widths);
    free(heights);
    return size;
}

- (void)setFrameSize:(NSSize)size
{
    [super setFrameSize:size];
    [self _relayoutGrid];
}

@end
