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
    [super dealloc];
}

- initWithCoder: (NSCoder *) coder {
    [super initWithCoder: coder];

    if ([coder allowsKeyedCoding]) {
        NSKeyedUnarchiver *keyed = (NSKeyedUnarchiver *) coder;
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
}

- (void) setItemPrototype: (NSCollectionViewItem *) value {
    value = [value retain];
    [_itemPrototype release];
    _itemPrototype = value;
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
    value = [value copy];
    [_selectionIndexes release];
    _selectionIndexes = value;

    NSMutableSet *paths = [NSMutableSet set];
    [_selectionIndexes enumerateIndexesUsingBlock: ^(NSUInteger index, BOOL *stop) {
      [paths addObject: [NSIndexPath indexPathForItem: index inSection: 0]];
    }];
    [_selectionIndexPaths release];
    _selectionIndexPaths = [paths copy];
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
    for (NSCollectionViewItem *item in [_itemsByIndexPath allValues])
        [[item view] removeFromSuperview];
    [_itemsByIndexPath removeAllObjects];
    [_collectionViewLayout invalidateLayout];
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
    return [_itemsByIndexPath objectForKey: indexPath];
}

- (NSArray *) visibleItems {
    NSArray *paths = [[_itemsByIndexPath allKeys]
        sortedArrayUsingSelector: @selector(compare:)];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity: [paths count]];
    for (NSIndexPath *path in paths)
        [result addObject: [_itemsByIndexPath objectForKey: path]];
    return result;
}

@end
