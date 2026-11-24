/* Copyright (c) 2009 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <AppKit/NSCollectionView.h>
#import <AppKit/NSRaise.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSNib.h>
#import <AppKit/NSCollectionViewLayout.h>
#import <AppKit/NSCollectionViewLayoutAttributes.h>
#import <AppKit/NSCollectionViewFlowLayout.h>
#import <AppKit/NSClipView.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSColor.h>

@implementation NSIndexPath (NSCollectionViewAdditions)

+ (NSIndexPath *) indexPathForItem: (NSInteger) item inSection: (NSInteger) section {
    NSUInteger indexes[2] = { (NSUInteger) section, (NSUInteger) item };
    return [NSIndexPath indexPathWithIndexes: indexes length: 2];
}

- (NSInteger) item {
    NSUInteger length = [self length];
    return length > 0 ? (NSInteger) [self indexAtPosition: length - 1] : 0;
}

- (NSInteger) section {
    return [self length] > 0 ? (NSInteger) [self indexAtPosition: 0] : 0;
}

@end

static NSString *NSCollectionViewSupplementaryKey(NSString *kind, NSString *identifier) {
    return [NSString stringWithFormat: @"%@/%@", kind, identifier];
}

static id NSCollectionViewInstantiateNib(NSNib *nib, Class wanted) {
    NSArray *objects = nil;
    if (![nib instantiateNibWithOwner: nil topLevelObjects: &objects])
        return nil;
    for (id object in objects) {
        if ([object isKindOfClass: wanted])
            return object;
    }
    return nil;
}

@implementation NSCollectionView

- (void) dealloc {
    [_content release];
    [_itemPrototype release];
    [_backgroundColors release];
    [_selectionIndexes release];
    [_selectionIndexPaths release];
    [_collectionViewLayout release];
    [_registeredItemClasses release];
    [_registeredItemNibs release];
    [_registeredSupplementaryClasses release];
    [_registeredSupplementaryNibs release];
    [_itemsByIndexPath release];
    [_supplementaryViews release];
    [_backgroundView release];
    [super dealloc];
}

- initWithCoder: (NSCoder *) coder {
    [super initWithCoder: coder];

    if ([coder allowsKeyedCoding]) {
        NSKeyedUnarchiver *keyed = (NSKeyedUnarchiver *) coder;
        if ([keyed containsValueForKey: @"NSMaxNumberOfGridRows"])
            _maxNumberOfRows = [keyed decodeIntegerForKey: @"NSMaxNumberOfGridRows"];
        if ([keyed containsValueForKey: @"NSMaxNumberOfGridColumns"])
            _maxNumberOfColumns = [keyed decodeIntegerForKey: @"NSMaxNumberOfGridColumns"];
        if ([keyed containsValueForKey: @"NSMinGridSize"])
            _minItemSize = [keyed decodeSizeForKey: @"NSMinGridSize"];
        if ([keyed containsValueForKey: @"NSMaxGridSize"])
            _maxItemSize = [keyed decodeSizeForKey: @"NSMaxGridSize"];
        if ([keyed containsValueForKey: @"NSSelectable"])
            _isSelectable = [keyed decodeBoolForKey: @"NSSelectable"];
        if ([keyed containsValueForKey: @"NSAllowsMultipleSelection"])
            _allowsMultipleSelection = [keyed decodeBoolForKey: @"NSAllowsMultipleSelection"];
        if ([keyed containsValueForKey: @"NSBackgroundColors"])
            _backgroundColors = [[keyed decodeObjectForKey: @"NSBackgroundColors"] copy];
        _needsReload = YES;
    } else
        [NSException raise: NSInvalidArgumentException
                    format: @"-[%@ %s] is not implemented for coder %@",
                            [self class], sel_getName(_cmd), coder];

    return self;
}

- (NSArray *) content {
    return _content;
}

- (NSCollectionViewItem *) itemPrototype {
    return _itemPrototype;
}

- (BOOL) isSelectable {
    return _isSelectable;
}

- (NSSize) minItemSize {
    return _minItemSize;
}

- (NSSize) maxItemSize {
    return _maxItemSize;
}

- (NSUInteger) maxNumberOfRows {
    return _maxNumberOfRows;
}

- (NSUInteger) maxNumberOfColumns {
    return _maxNumberOfColumns;
}

- (NSArray *) backgroundColors {
    return _backgroundColors;
}

- (BOOL) allowsMultipleSelection {
    return _allowsMultipleSelection;
}

- (NSIndexSet *) selectionIndexes {
    return _selectionIndexes;
}

- (void) setContent: (NSArray *) value {
    value = [value retain];
    [_content release];
    _content = value;
    [self _scheduleReload];
}

- (void) setItemPrototype: (NSCollectionViewItem *) value {
    value = [value retain];
    [_itemPrototype release];
    _itemPrototype = value;
    [self _scheduleReload];
}

- (void) setSelectable: (BOOL) value {
    _isSelectable = value;
}

- (void) setMinItemSize: (NSSize) value {
    _minItemSize = value;
}

- (void) setMaxItemSize: (NSSize) value {
    _maxItemSize = value;
}

- (void) setMaxNumberOfRows: (NSUInteger) value {
    _maxNumberOfRows = value;
}

- (void) setMaxNumberOfColumns: (NSUInteger) value {
    _maxNumberOfColumns = value;
}

- (void) setBackgroundColors: (NSArray *) value {
    value = [value copy];
    [_backgroundColors release];
    _backgroundColors = value;
}

- (void) setAllowsMultipleSelection: (BOOL) value {
    _allowsMultipleSelection = value;
}

- (void) setSelectionIndexes: (NSIndexSet *) value {
    if (value == nil)
        value = [NSIndexSet indexSet];
    value = [value copy];
    [_selectionIndexes release];
    _selectionIndexes = value;

    NSMutableSet *paths = [NSMutableSet set];
    [_selectionIndexes enumerateIndexesUsingBlock: ^(NSUInteger index, BOOL *stop) {
      [paths addObject: [NSIndexPath indexPathForItem: index inSection: 0]];
    }];
    [_selectionIndexPaths release];
    _selectionIndexPaths = [paths copy];
    [self _refreshItemSelection];
}

- (BOOL) isFirstResponder {
    return ([[self window] firstResponder] == self) ? YES : NO;
}

- (NSCollectionViewItem *) newItemForRepresentedObject: object {
    NSCollectionViewItem *item = [_itemPrototype copy];
    [item setRepresentedObject: object];
    return item;
}

- (id<NSCollectionViewDataSource>) dataSource {
    return _dataSource;
}

- (void) setDataSource: (id<NSCollectionViewDataSource>) value {
    _dataSource = value;
    [self _scheduleReload];
}

- (NSCollectionViewLayout *) collectionViewLayout {
    return _collectionViewLayout;
}

- (void) setCollectionViewLayout: (NSCollectionViewLayout *) value {
    if (_collectionViewLayout == value)
        return;
    [_collectionViewLayout _setCollectionView: nil];
    value = [value retain];
    [_collectionViewLayout release];
    _collectionViewLayout = value;
    [_collectionViewLayout _setCollectionView: self];
    [_collectionViewLayout invalidateLayout];
    [self _scheduleRelayout];
}

- (id<NSCollectionViewPrefetching>) prefetchDataSource {
    return _prefetchDataSource;
}

- (void) setPrefetchDataSource: (id<NSCollectionViewPrefetching>) value {
    _prefetchDataSource = value;
}

- (BOOL) allowsEmptySelection {
    return !_disallowsEmptySelection;
}

- (void) setAllowsEmptySelection: (BOOL) value {
    _disallowsEmptySelection = !value;
}

- (NSSet *) selectionIndexPaths {
    if (_selectionIndexPaths == nil)
        return [NSSet set];
    return _selectionIndexPaths;
}

- (void) setSelectionIndexPaths: (NSSet *) value {
    value = [value copy];
    [_selectionIndexPaths release];
    _selectionIndexPaths = value;

    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    for (NSIndexPath *path in _selectionIndexPaths) {
        if ([path section] == 0)
            [indexes addIndex: [path item]];
    }
    [_selectionIndexes release];
    _selectionIndexes = [indexes copy];
    [self _refreshItemSelection];
}

- (IBAction) selectAll: (id) sender {
    if (!_isSelectable || !_allowsMultipleSelection)
        return;

    NSMutableSet *paths = [NSMutableSet set];
    NSInteger sections = [self numberOfSections];
    for (NSInteger section = 0; section < sections; section++) {
        NSInteger count = [self numberOfItemsInSection: section];
        for (NSInteger item = 0; item < count; item++)
            [paths addObject: [NSIndexPath indexPathForItem: item inSection: section]];
    }
    [self setSelectionIndexPaths: paths];
    for (NSIndexPath *path in paths)
        [[self itemAtIndexPath: path] setSelected: YES];
}

- (IBAction) deselectAll: (id) sender {
    for (NSIndexPath *path in [[_selectionIndexPaths copy] autorelease])
        [[self itemAtIndexPath: path] setSelected: NO];
    [self setSelectionIndexPaths: [NSSet set]];
}

- (void) reloadData {
    if (_inLayout)
        return;
    _needsReload = NO;
    _needsRelayout = NO;
    [self _removeAllItems];
    [self _populateItems];
    [self setNeedsDisplay: YES];
}

- (NSInteger) numberOfSections {
    if ([_dataSource respondsToSelector: @selector(numberOfSectionsInCollectionView:)])
        return [_dataSource numberOfSectionsInCollectionView: self];
    return 1;
}

- (NSInteger) numberOfItemsInSection: (NSInteger) section {
    if ([_dataSource respondsToSelector: @selector(collectionView:numberOfItemsInSection:)])
        return [_dataSource collectionView: self numberOfItemsInSection: section];
    if (section == 0)
        return [_content count];
    return 0;
}

- (NSCollectionViewLayoutAttributes *) layoutAttributesForItemAtIndexPath: (NSIndexPath *) indexPath {
    return [_collectionViewLayout layoutAttributesForItemAtIndexPath: indexPath];
}

- (void) registerClass: (Class) itemClass forItemWithIdentifier: (NSUserInterfaceItemIdentifier) identifier {
    if (_registeredItemClasses == nil)
        _registeredItemClasses = [[NSMutableDictionary alloc] init];
    if (itemClass != Nil)
        [_registeredItemClasses setObject: itemClass forKey: identifier];
    else
        [_registeredItemClasses removeObjectForKey: identifier];
    [_registeredItemNibs removeObjectForKey: identifier];
}

- (void) registerNib: (NSNib *) nib forItemWithIdentifier: (NSUserInterfaceItemIdentifier) identifier {
    if (_registeredItemNibs == nil)
        _registeredItemNibs = [[NSMutableDictionary alloc] init];
    if (nib != nil)
        [_registeredItemNibs setObject: nib forKey: identifier];
    else
        [_registeredItemNibs removeObjectForKey: identifier];
    [_registeredItemClasses removeObjectForKey: identifier];
}

- (void) registerClass: (Class) viewClass
    forSupplementaryViewOfKind: (NSCollectionViewSupplementaryElementKind) kind
                withIdentifier: (NSUserInterfaceItemIdentifier) identifier {
    NSString *key = NSCollectionViewSupplementaryKey(kind, identifier);
    if (_registeredSupplementaryClasses == nil)
        _registeredSupplementaryClasses = [[NSMutableDictionary alloc] init];
    if (viewClass != Nil)
        [_registeredSupplementaryClasses setObject: viewClass forKey: key];
    else
        [_registeredSupplementaryClasses removeObjectForKey: key];
    [_registeredSupplementaryNibs removeObjectForKey: key];
}

- (void) registerNib: (NSNib *) nib
    forSupplementaryViewOfKind: (NSCollectionViewSupplementaryElementKind) kind
                withIdentifier: (NSUserInterfaceItemIdentifier) identifier {
    NSString *key = NSCollectionViewSupplementaryKey(kind, identifier);
    if (_registeredSupplementaryNibs == nil)
        _registeredSupplementaryNibs = [[NSMutableDictionary alloc] init];
    if (nib != nil)
        [_registeredSupplementaryNibs setObject: nib forKey: key];
    else
        [_registeredSupplementaryNibs removeObjectForKey: key];
    [_registeredSupplementaryClasses removeObjectForKey: key];
}

- (NSCollectionViewItem *) makeItemWithIdentifier: (NSUserInterfaceItemIdentifier) identifier
                                     forIndexPath: (NSIndexPath *) indexPath {
    NSCollectionViewItem *item = nil;
    Class itemClass = [_registeredItemClasses objectForKey: identifier];
    NSNib *nib = [_registeredItemNibs objectForKey: identifier];

    if (itemClass != Nil)
        item = [[[itemClass alloc] init] autorelease];
    else if (nib != nil)
        item = NSCollectionViewInstantiateNib(nib, [NSCollectionViewItem class]);
    if (item == nil)
        [NSException raise: NSInternalInconsistencyException
                    format: @"could not dequeue an item with identifier %@ - must register a nib or a class for the identifier",
                            identifier];

    [item _setCollectionView: self];
    if (indexPath != nil) {
        if (_itemsByIndexPath == nil)
            _itemsByIndexPath = [[NSMutableDictionary alloc] init];
        [_itemsByIndexPath setObject: item forKey: indexPath];
        [item setSelected: [[self selectionIndexPaths] containsObject: indexPath]];
    }
    return item;
}

- (NSView *) makeSupplementaryViewOfKind: (NSCollectionViewSupplementaryElementKind) elementKind
                          withIdentifier: (NSUserInterfaceItemIdentifier) identifier
                            forIndexPath: (NSIndexPath *) indexPath {
    NSString *key = NSCollectionViewSupplementaryKey(elementKind, identifier);
    NSView *view = nil;
    Class viewClass = [_registeredSupplementaryClasses objectForKey: key];
    NSNib *nib = [_registeredSupplementaryNibs objectForKey: key];

    if (viewClass != Nil)
        view = [[[viewClass alloc] initWithFrame: NSZeroRect] autorelease];
    else if (nib != nil)
        view = NSCollectionViewInstantiateNib(nib, [NSView class]);
    if (view == nil)
        [NSException raise: NSInternalInconsistencyException
                    format: @"could not dequeue a view of kind %@ with identifier %@ - must register a nib or a class for the identifier",
                            elementKind, identifier];
    return view;
}

- (NSCollectionViewItem *) itemAtIndexPath: (NSIndexPath *) indexPath {
    [self _reloadIfNeeded];
    return [_itemsByIndexPath objectForKey: indexPath];
}

- (NSArray *) visibleItems {
    [self _reloadIfNeeded];
    NSArray *paths = [[_itemsByIndexPath allKeys]
        sortedArrayUsingSelector: @selector(compare:)];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity: [paths count]];
    for (NSIndexPath *path in paths)
        [result addObject: [_itemsByIndexPath objectForKey: path]];
    return result;
}

#pragma mark - Layout and population

- (BOOL) isFlipped {
    return YES;
}

- (BOOL) acceptsFirstResponder {
    return _isSelectable;
}

- (id) delegate {
    return _delegate;
}

- (void) setDelegate: (id) value {
    _delegate = value;
}

- (NSView *) backgroundView {
    return _backgroundView;
}

- (void) setBackgroundView: (NSView *) value {
    if (value == _backgroundView)
        return;
    [_backgroundView removeFromSuperview];
    value = [value retain];
    [_backgroundView release];
    _backgroundView = value;
    if (_backgroundView != nil) {
        [_backgroundView setFrame: [self bounds]];
        [_backgroundView setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
        [self addSubview: _backgroundView positioned: NSWindowBelow relativeTo: nil];
    }
}

// Reloading and relayout are deferred to the run loop so that setting up the
// data source, layout and registrations in any order works.
- (void) _schedulePending {
    if (_pendingScheduled)
        return;
    _pendingScheduled = YES;
    [self performSelector: @selector(_flushPending) withObject: nil afterDelay: 0.0];
}

- (void) _scheduleReload {
    _needsReload = YES;
    if (_batchUpdateDepth == 0)
        [self _schedulePending];
}

- (void) _scheduleRelayout {
    _needsRelayout = YES;
    if (_batchUpdateDepth == 0)
        [self _schedulePending];
}

- (void) _layoutDidInvalidate {
    if (!_inLayout)
        [self _scheduleRelayout];
}

- (void) _flushPending {
    _pendingScheduled = NO;
    if (_needsReload)
        [self reloadData];
    else if (_needsRelayout)
        [self _layoutItems];
}

- (void) _reloadIfNeeded {
    if (_needsReload && !_inLayout && _batchUpdateDepth == 0)
        [self reloadData];
}

// Without an explicit layout (legacy itemPrototype API) the collection view
// lays its items out on a grid sized from the prototype view.
- (NSCollectionViewLayout *) _effectiveLayout {
    if (_collectionViewLayout == nil) {
        NSCollectionViewGridLayout *grid = [[[NSCollectionViewGridLayout alloc] init] autorelease];
        NSSize minSize = _minItemSize;
        NSSize maxSize = _maxItemSize;
        if (maxSize.width <= 0 && maxSize.height <= 0 && minSize.width <= 0 && minSize.height <= 0 &&
            _itemPrototype != nil) {
            minSize = maxSize = [[_itemPrototype view] frame].size;
        }
        [grid setMinimumItemSize: minSize];
        [grid setMaximumItemSize: maxSize];
        [grid setMaximumNumberOfRows: _maxNumberOfRows];
        [grid setMaximumNumberOfColumns: _maxNumberOfColumns];
        _inLayout = YES;
        [self setCollectionViewLayout: grid];
        _inLayout = NO;
        _needsRelayout = NO;
    }
    return _collectionViewLayout;
}

- (void) _removeAllItems {
    NSDictionary *items = [[_itemsByIndexPath copy] autorelease];
    for (NSIndexPath *path in items) {
        NSCollectionViewItem *item = [items objectForKey: path];
        if ([_delegate respondsToSelector: @selector(collectionView:didEndDisplayingItem:forRepresentedObjectAtIndexPath:)])
            [_delegate collectionView: self didEndDisplayingItem: item forRepresentedObjectAtIndexPath: path];
        [[item view] removeFromSuperview];
    }
    [_itemsByIndexPath removeAllObjects];
    for (NSView *view in [_supplementaryViews allValues])
        [view removeFromSuperview];
    [_supplementaryViews removeAllObjects];
}

static NSString *NSCollectionViewSupplementaryDictKey(NSString *kind, NSIndexPath *path) {
    return [NSString stringWithFormat: @"%@:%ld:%ld", kind, (long) [path section], (long) [path item]];
}

- (void) _populateItems {
    if (_inLayout)
        return;
    BOOL legacy = ![_dataSource respondsToSelector: @selector(collectionView:itemForRepresentedObjectAtIndexPath:)];
    if (legacy && _itemPrototype == nil && _dataSource == nil)
        return;

    _inLayout = YES;
    @try {
        NSCollectionViewLayout *layout = [self _effectiveLayout];
        NSInteger sections = [self numberOfSections];
        for (NSInteger section = 0; section < sections; section++) {
            NSInteger count = [self numberOfItemsInSection: section];
            for (NSInteger index = 0; index < count; index++) {
                NSIndexPath *path = [NSIndexPath indexPathForItem: index inSection: section];
                NSCollectionViewItem *item = nil;
                if (!legacy) {
                    item = [_dataSource collectionView: self itemForRepresentedObjectAtIndexPath: path];
                } else if (_itemPrototype != nil && section == 0 && index < (NSInteger) [_content count]) {
                    item = [[self newItemForRepresentedObject: [_content objectAtIndex: index]] autorelease];
                }
                if (item == nil)
                    continue;

                [item _setCollectionView: self];
                if (_itemsByIndexPath == nil)
                    _itemsByIndexPath = [[NSMutableDictionary alloc] init];
                [_itemsByIndexPath setObject: item forKey: path];
                [item setSelected: [_selectionIndexPaths containsObject: path]];

                NSView *view = [item view];
                NSCollectionViewLayoutAttributes *attributes = [layout layoutAttributesForItemAtIndexPath: path];
                if (attributes != nil)
                    [view setFrame: [attributes frame]];
                [view setAutoresizingMask: NSViewNotSizable];
                [self addSubview: view];
                if ([_delegate respondsToSelector: @selector(collectionView:willDisplayItem:forRepresentedObjectAtIndexPath:)])
                    [_delegate collectionView: self willDisplayItem: item forRepresentedObjectAtIndexPath: path];
            }

            if ([_dataSource respondsToSelector: @selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]) {
                NSIndexPath *sectionPath = [NSIndexPath indexPathForItem: 0 inSection: section];
                NSString *kinds[2] = { NSCollectionElementKindSectionHeader, NSCollectionElementKindSectionFooter };
                for (int k = 0; k < 2; k++) {
                    NSCollectionViewLayoutAttributes *attributes =
                        [layout layoutAttributesForSupplementaryViewOfKind: kinds[k] atIndexPath: sectionPath];
                    if (attributes == nil)
                        continue;
                    NSView *view = [_dataSource collectionView: self
                                viewForSupplementaryElementOfKind: kinds[k]
                                                      atIndexPath: sectionPath];
                    if (view == nil)
                        continue;
                    if (_supplementaryViews == nil)
                        _supplementaryViews = [[NSMutableDictionary alloc] init];
                    [_supplementaryViews setObject: view
                                            forKey: NSCollectionViewSupplementaryDictKey(kinds[k], sectionPath)];
                    [view setFrame: [attributes frame]];
                    [self addSubview: view];
                    if ([_delegate respondsToSelector: @selector(collectionView:willDisplaySupplementaryView:forElementKind:atIndexPath:)])
                        [_delegate collectionView: self
                                willDisplaySupplementaryView: view
                                              forElementKind: kinds[k]
                                                 atIndexPath: sectionPath];
                }
            }
        }
        [self _updateFrameForContent];
    } @finally {
        _inLayout = NO;
    }
}

// Repositions the existing item views after a layout invalidation or resize.
- (void) _layoutItems {
    if (_inLayout || _collectionViewLayout == nil)
        return;
    _needsRelayout = NO;
    _inLayout = YES;
    for (NSIndexPath *path in _itemsByIndexPath) {
        NSCollectionViewItem *item = [_itemsByIndexPath objectForKey: path];
        NSCollectionViewLayoutAttributes *attributes = [_collectionViewLayout layoutAttributesForItemAtIndexPath: path];
        if (attributes != nil)
            [[item view] setFrame: [attributes frame]];
    }
    for (NSString *key in _supplementaryViews) {
        NSArray *parts = [key componentsSeparatedByString: @":"];
        if ([parts count] != 3)
            continue;
        NSIndexPath *path = [NSIndexPath indexPathForItem: [[parts objectAtIndex: 2] integerValue]
                                                inSection: [[parts objectAtIndex: 1] integerValue]];
        NSCollectionViewLayoutAttributes *attributes =
            [_collectionViewLayout layoutAttributesForSupplementaryViewOfKind: [parts objectAtIndex: 0]
                                                                  atIndexPath: path];
        if (attributes != nil)
            [[_supplementaryViews objectForKey: key] setFrame: [attributes frame]];
    }
    [self _updateFrameForContent];
    _inLayout = NO;
}

// Inside a scroll view the collection view grows to its content.
- (void) _updateFrameForContent {
    NSView *superview = [self superview];
    if (_collectionViewLayout == nil || ![superview isKindOfClass: [NSClipView class]])
        return;
    NSSize content = [_collectionViewLayout collectionViewContentSize];
    NSSize clip = [superview bounds].size;
    NSSize size = [self frame].size;
    BOOL horizontal = [_collectionViewLayout respondsToSelector: @selector(scrollDirection)] &&
                      [(NSCollectionViewFlowLayout *) _collectionViewLayout scrollDirection] ==
                          NSCollectionViewScrollDirectionHorizontal;
    if (horizontal)
        size.width = MAX(content.width, clip.width);
    else
        size.height = MAX(content.height, clip.height);
    if (!NSEqualSizes(size, [self frame].size))
        [super setFrameSize: size];
}

- (void) setFrameSize: (NSSize) size {
    NSSize old = [self frame].size;
    [super setFrameSize: size];
    if (!_inLayout && (old.width != size.width || old.height != size.height) && _collectionViewLayout != nil)
        [self _layoutItems];
}

- (void) viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    if ([self window] != nil && (_needsReload || _needsRelayout))
        [self _schedulePending];
}

- (void) viewDidMoveToSuperview {
    [super viewDidMoveToSuperview];
    if ([self superview] != nil && _collectionViewLayout != nil)
        [self _scheduleRelayout];
}

- (NSCollectionViewLayoutAttributes *) layoutAttributesForSupplementaryElementOfKind: (NSCollectionViewSupplementaryElementKind) kind
                                                                         atIndexPath: (NSIndexPath *) indexPath {
    return [_collectionViewLayout layoutAttributesForSupplementaryViewOfKind: kind atIndexPath: indexPath];
}

- (NSRect) frameForItemAtIndex: (NSUInteger) index {
    return [self frameForItemAtIndex: index withNumberOfItems: [self numberOfItemsInSection: 0]];
}

- (NSRect) frameForItemAtIndex: (NSUInteger) index withNumberOfItems: (NSUInteger) numberOfItems {
    NSCollectionViewLayoutAttributes *attributes = [[self _effectiveLayout]
        layoutAttributesForItemAtIndexPath: [NSIndexPath indexPathForItem: index inSection: 0]];
    return attributes != nil ? [attributes frame] : NSZeroRect;
}

#pragma mark - Item lookup

- (NSCollectionViewItem *) itemAtIndex: (NSUInteger) index {
    return [self itemAtIndexPath: [NSIndexPath indexPathForItem: index inSection: 0]];
}

- (NSSet *) indexPathsForVisibleItems {
    [self _reloadIfNeeded];
    return [NSSet setWithArray: [_itemsByIndexPath allKeys]];
}

- (NSIndexPath *) indexPathForItem: (NSCollectionViewItem *) item {
    for (NSIndexPath *path in _itemsByIndexPath) {
        if ([_itemsByIndexPath objectForKey: path] == item)
            return path;
    }
    return nil;
}

- (NSIndexPath *) indexPathForItemAtPoint: (NSPoint) point {
    [self _reloadIfNeeded];
    for (NSIndexPath *path in _itemsByIndexPath) {
        NSView *view = [[_itemsByIndexPath objectForKey: path] view];
        if (NSPointInRect(point, [view frame]))
            return path;
    }
    return nil;
}

- (NSView *) supplementaryViewForElementKind: (NSCollectionViewSupplementaryElementKind) elementKind
                                 atIndexPath: (NSIndexPath *) indexPath {
    return [_supplementaryViews objectForKey: NSCollectionViewSupplementaryDictKey(elementKind, indexPath)];
}

- (NSArray *) visibleSupplementaryViewsOfKind: (NSCollectionViewSupplementaryElementKind) elementKind {
    NSMutableArray *result = [NSMutableArray array];
    NSString *prefix = [elementKind stringByAppendingString: @":"];
    for (NSString *key in _supplementaryViews) {
        if ([key hasPrefix: prefix])
            [result addObject: [_supplementaryViews objectForKey: key]];
    }
    return result;
}

#pragma mark - Selection

- (void) _refreshItemSelection {
    for (NSIndexPath *path in _itemsByIndexPath)
        [[_itemsByIndexPath objectForKey: path] setSelected: [_selectionIndexPaths containsObject: path]];
}

- (void) selectItemsAtIndexPaths: (NSSet *) indexPaths
                  scrollPosition: (NSCollectionViewScrollPosition) scrollPosition {
    if (!_isSelectable)
        return;
    if ([_delegate respondsToSelector: @selector(collectionView:shouldSelectItemsAtIndexPaths:)])
        indexPaths = [_delegate collectionView: self shouldSelectItemsAtIndexPaths: indexPaths];
    if ([indexPaths count] == 0)
        return;

    NSMutableSet *selection = _allowsMultipleSelection ? [[_selectionIndexPaths mutableCopy] autorelease]
                                                       : [NSMutableSet set];
    if (selection == nil)
        selection = [NSMutableSet set];
    if (_allowsMultipleSelection)
        [selection unionSet: indexPaths];
    else
        [selection addObject: [indexPaths anyObject]];

    NSMutableSet *added = [[selection mutableCopy] autorelease];
    [added minusSet: _selectionIndexPaths];
    NSMutableSet *removed = [[_selectionIndexPaths mutableCopy] autorelease];
    [removed minusSet: selection];

    [self setSelectionIndexPaths: selection];
    if ([removed count] > 0 &&
        [_delegate respondsToSelector: @selector(collectionView:didDeselectItemsAtIndexPaths:)])
        [_delegate collectionView: self didDeselectItemsAtIndexPaths: removed];
    if ([added count] > 0 &&
        [_delegate respondsToSelector: @selector(collectionView:didSelectItemsAtIndexPaths:)])
        [_delegate collectionView: self didSelectItemsAtIndexPaths: added];
    if (scrollPosition != NSCollectionViewScrollPositionNone)
        [self scrollToItemsAtIndexPaths: indexPaths scrollPosition: scrollPosition];
}

- (void) deselectItemsAtIndexPaths: (NSSet *) indexPaths {
    if ([_delegate respondsToSelector: @selector(collectionView:shouldDeselectItemsAtIndexPaths:)])
        indexPaths = [_delegate collectionView: self shouldDeselectItemsAtIndexPaths: indexPaths];
    NSMutableSet *removed = [[indexPaths mutableCopy] autorelease];
    [removed intersectSet: _selectionIndexPaths];
    if ([removed count] == 0)
        return;

    NSMutableSet *selection = [[_selectionIndexPaths mutableCopy] autorelease];
    [selection minusSet: removed];
    [self setSelectionIndexPaths: selection];
    if ([_delegate respondsToSelector: @selector(collectionView:didDeselectItemsAtIndexPaths:)])
        [_delegate collectionView: self didDeselectItemsAtIndexPaths: removed];
}

- (void) scrollToItemsAtIndexPaths: (NSSet *) indexPaths
                    scrollPosition: (NSCollectionViewScrollPosition) scrollPosition {
    NSRect rect = NSZeroRect;
    BOOL first = YES;
    for (NSIndexPath *path in indexPaths) {
        NSCollectionViewLayoutAttributes *attributes = [_collectionViewLayout layoutAttributesForItemAtIndexPath: path];
        if (attributes == nil)
            continue;
        rect = first ? [attributes frame] : NSUnionRect(rect, [attributes frame]);
        first = NO;
    }
    if (!first)
        [self scrollRectToVisible: rect];
}

- (BOOL) becomeFirstResponder {
    return YES;
}

- (void) mouseDown: (NSEvent *) event {
    if (!_isSelectable) {
        [super mouseDown: event];
        return;
    }
    [[self window] makeFirstResponder: self];

    NSPoint point = [self convertPoint: [event locationInWindow] fromView: nil];
    NSIndexPath *path = [self indexPathForItemAtPoint: point];
    if (path == nil) {
        if (![self allowsEmptySelection])
            return;
        [self deselectItemsAtIndexPaths: [[_selectionIndexPaths copy] autorelease]];
        return;
    }

    BOOL extend = _allowsMultipleSelection && ([event modifierFlags] & (NSCommandKeyMask | NSShiftKeyMask));
    if (extend && [_selectionIndexPaths containsObject: path]) {
        if ([_selectionIndexPaths count] > 1 || [self allowsEmptySelection])
            [self deselectItemsAtIndexPaths: [NSSet setWithObject: path]];
    } else if (extend) {
        [self selectItemsAtIndexPaths: [NSSet setWithObject: path]
                       scrollPosition: NSCollectionViewScrollPositionNone];
    } else if (![_selectionIndexPaths containsObject: path] || [_selectionIndexPaths count] > 1) {
        // A plain click replaces the selection.
        BOOL multiple = _allowsMultipleSelection;
        _allowsMultipleSelection = NO;
        [self selectItemsAtIndexPaths: [NSSet setWithObject: path]
                       scrollPosition: NSCollectionViewScrollPositionNone];
        _allowsMultipleSelection = multiple;
    }
}

#pragma mark - Updates

- (void) insertSections: (NSIndexSet *) sections {
    [self _scheduleReload];
}

- (void) deleteSections: (NSIndexSet *) sections {
    [self _scheduleReload];
}

- (void) reloadSections: (NSIndexSet *) sections {
    [self _scheduleReload];
}

- (void) insertItemsAtIndexPaths: (NSSet *) indexPaths {
    [self _scheduleReload];
}

- (void) deleteItemsAtIndexPaths: (NSSet *) indexPaths {
    [self _scheduleReload];
}

- (void) reloadItemsAtIndexPaths: (NSSet *) indexPaths {
    [self _scheduleReload];
}

- (void) performBatchUpdates: (void (^)(void)) updates
           completionHandler: (void (^)(BOOL finished)) completionHandler {
    _batchUpdateDepth++;
    @try {
        if (updates != NULL)
            updates();
    } @finally {
        _batchUpdateDepth--;
    }
    if (_batchUpdateDepth == 0 && _needsReload)
        [self reloadData];
    if (completionHandler != NULL)
        completionHandler(YES);
}

- (void) setDraggingSourceOperationMask: (NSDragOperation) dragOperationMask forLocal: (BOOL) localDestination {
}

@end
