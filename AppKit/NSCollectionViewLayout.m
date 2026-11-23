/*
 This file is part of Darling.

 Copyright (C) 2019 Lubos Dolezel

 Darling is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 Darling is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Darling.  If not, see <http://www.gnu.org/licenses/>.
*/

#import <AppKit/NSCollectionViewLayout.h>
#import <AppKit/NSColor.h>

NSCollectionViewSupplementaryElementKind const
        NSCollectionElementKindInterItemGapIndicator =
                @"NSCollectionElementKindInterItemGapIndicator";

@implementation NSCollectionViewLayout

- initWithCoder: (NSCoder *) coder {
    return [self init];
}

- (void) encodeWithCoder: (NSCoder *) coder {
}

- (NSCollectionView *) collectionView {
    return _collectionView;
}

- (void) _setCollectionView: (NSCollectionView *) value {
    _collectionView = value;
}

- (void) invalidateLayout {
}

- (void) prepareLayout {
}

- (NSArray *) layoutAttributesForElementsInRect: (NSRect) rect {
    return [NSArray array];
}

- (NSCollectionViewLayoutAttributes *) layoutAttributesForItemAtIndexPath: (NSIndexPath *) indexPath {
    return nil;
}

- (BOOL) shouldInvalidateLayoutForBoundsChange: (NSRect) newBounds {
    return NO;
}

- (NSSize) collectionViewContentSize {
    return NSZeroSize;
}

@end

@implementation NSCollectionViewGridLayout

- (void) dealloc {
    [_backgroundColors release];
    [super dealloc];
}

- (NSEdgeInsets) margins {
    return _margins;
}

- (void) setMargins: (NSEdgeInsets) value {
    _margins = value;
    [self invalidateLayout];
}

- (CGFloat) minimumInteritemSpacing {
    return _minimumInteritemSpacing;
}

- (void) setMinimumInteritemSpacing: (CGFloat) value {
    _minimumInteritemSpacing = value;
    [self invalidateLayout];
}

- (CGFloat) minimumLineSpacing {
    return _minimumLineSpacing;
}

- (void) setMinimumLineSpacing: (CGFloat) value {
    _minimumLineSpacing = value;
    [self invalidateLayout];
}

- (NSUInteger) maximumNumberOfRows {
    return _maximumNumberOfRows;
}

- (void) setMaximumNumberOfRows: (NSUInteger) value {
    _maximumNumberOfRows = value;
    [self invalidateLayout];
}

- (NSUInteger) maximumNumberOfColumns {
    return _maximumNumberOfColumns;
}

- (void) setMaximumNumberOfColumns: (NSUInteger) value {
    _maximumNumberOfColumns = value;
    [self invalidateLayout];
}

- (NSSize) minimumItemSize {
    return _minimumItemSize;
}

- (void) setMinimumItemSize: (NSSize) value {
    _minimumItemSize = value;
    [self invalidateLayout];
}

- (NSSize) maximumItemSize {
    return _maximumItemSize;
}

- (void) setMaximumItemSize: (NSSize) value {
    _maximumItemSize = value;
    [self invalidateLayout];
}

- (NSArray *) backgroundColors {
    if (_backgroundColors == nil)
        return [NSArray arrayWithObject: [NSColor controlBackgroundColor]];
    return _backgroundColors;
}

- (void) setBackgroundColors: (NSArray *) value {
    value = [value copy];
    [_backgroundColors release];
    _backgroundColors = value;
}

// Geometry shared by the content size and per-item queries.
- (void) _getColumns: (NSInteger *) columns itemSize: (NSSize *) itemSize {
    NSSize size = _maximumItemSize;
    if (size.width <= 0)
        size.width = _minimumItemSize.width > 0 ? _minimumItemSize.width : 100;
    if (size.height <= 0)
        size.height = _minimumItemSize.height > 0 ? _minimumItemSize.height : 100;
    if (size.width < _minimumItemSize.width)
        size.width = _minimumItemSize.width;
    if (size.height < _minimumItemSize.height)
        size.height = _minimumItemSize.height;

    CGFloat available = [_collectionView bounds].size.width - _margins.left - _margins.right;
    NSInteger count = (NSInteger) ((available + _minimumInteritemSpacing) /
                                   (size.width + _minimumInteritemSpacing));
    if (_maximumNumberOfColumns > 0 && count > (NSInteger) _maximumNumberOfColumns)
        count = _maximumNumberOfColumns;
    if (count < 1)
        count = 1;
    *columns = count;
    *itemSize = size;
}

- (NSCollectionViewLayoutAttributes *) layoutAttributesForItemAtIndexPath: (NSIndexPath *) indexPath {
    NSInteger columns;
    NSSize itemSize;
    [self _getColumns: &columns itemSize: &itemSize];

    NSInteger index = 0;
    for (NSInteger section = 0; section < [indexPath section]; section++)
        index += [_collectionView numberOfItemsInSection: section];
    index += [indexPath item];

    NSCollectionViewLayoutAttributes *attributes =
        [NSCollectionViewLayoutAttributes layoutAttributesForItemWithIndexPath: indexPath];
    [attributes setFrame: NSMakeRect(_margins.left + (index % columns) * (itemSize.width + _minimumInteritemSpacing),
                                     _margins.top + (index / columns) * (itemSize.height + _minimumLineSpacing),
                                     itemSize.width, itemSize.height)];
    return attributes;
}

- (NSInteger) _totalItems {
    NSInteger total = 0;
    NSInteger sections = [_collectionView numberOfSections];
    for (NSInteger section = 0; section < sections; section++)
        total += [_collectionView numberOfItemsInSection: section];
    return total;
}

- (NSArray *) layoutAttributesForElementsInRect: (NSRect) rect {
    NSMutableArray *result = [NSMutableArray array];
    NSInteger sections = [_collectionView numberOfSections];
    for (NSInteger section = 0; section < sections; section++) {
        NSInteger count = [_collectionView numberOfItemsInSection: section];
        for (NSInteger item = 0; item < count; item++) {
            NSCollectionViewLayoutAttributes *attributes = [self
                layoutAttributesForItemAtIndexPath: [NSIndexPath indexPathForItem: item inSection: section]];
            if (NSIntersectsRect(rect, [attributes frame]))
                [result addObject: attributes];
        }
    }
    return result;
}

- (NSSize) collectionViewContentSize {
    NSInteger columns;
    NSSize itemSize;
    [self _getColumns: &columns itemSize: &itemSize];

    NSInteger total = [self _totalItems];
    NSInteger rows = (total + columns - 1) / columns;
    if (_maximumNumberOfRows > 0 && rows > (NSInteger) _maximumNumberOfRows)
        rows = _maximumNumberOfRows;

    CGFloat height = _margins.top + _margins.bottom;
    if (rows > 0)
        height += rows * itemSize.height + (rows - 1) * _minimumLineSpacing;
    return NSMakeSize([_collectionView bounds].size.width, height);
}

- (BOOL) shouldInvalidateLayoutForBoundsChange: (NSRect) newBounds {
    return newBounds.size.width != [_collectionView bounds].size.width;
}

@end
