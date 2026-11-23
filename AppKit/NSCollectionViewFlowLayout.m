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

#import <AppKit/NSCollectionViewFlowLayout.h>
#import <AppKit/NSCollectionView.h>

NSString *const NSCollectionElementKindSectionHeader =
        @"UICollectionElementKindSectionHeader";
NSString *const NSCollectionElementKindSectionFooter =
        @"UICollectionElementKindSectionFooter";

@implementation NSCollectionViewFlowLayout

- init {
    if ((self = [super init])) {
        _minimumLineSpacing = 10.0;
        _minimumInteritemSpacing = 10.0;
        _itemSize = NSMakeSize(50.0, 50.0);
    }
    return self;
}

- (CGFloat) minimumLineSpacing {
    return _minimumLineSpacing;
}

- (void) setMinimumLineSpacing: (CGFloat) value {
    _minimumLineSpacing = value;
    [self invalidateLayout];
}

- (CGFloat) minimumInteritemSpacing {
    return _minimumInteritemSpacing;
}

- (void) setMinimumInteritemSpacing: (CGFloat) value {
    _minimumInteritemSpacing = value;
    [self invalidateLayout];
}

- (NSSize) itemSize {
    return _itemSize;
}

- (void) setItemSize: (NSSize) value {
    _itemSize = value;
    [self invalidateLayout];
}

- (NSCollectionViewScrollDirection) scrollDirection {
    return _scrollDirection;
}

- (void) setScrollDirection: (NSCollectionViewScrollDirection) value {
    _scrollDirection = value;
    [self invalidateLayout];
}

- (NSSize) headerReferenceSize {
    return _headerReferenceSize;
}

- (void) setHeaderReferenceSize: (NSSize) value {
    _headerReferenceSize = value;
    [self invalidateLayout];
}

- (NSSize) footerReferenceSize {
    return _footerReferenceSize;
}

- (void) setFooterReferenceSize: (NSSize) value {
    _footerReferenceSize = value;
    [self invalidateLayout];
}

- (NSEdgeInsets) sectionInset {
    return _sectionInset;
}

- (void) setSectionInset: (NSEdgeInsets) value {
    _sectionInset = value;
    [self invalidateLayout];
}

- (BOOL) sectionHeadersPinToVisibleBounds {
    return _sectionHeadersPinToVisibleBounds;
}

- (void) setSectionHeadersPinToVisibleBounds: (BOOL) value {
    _sectionHeadersPinToVisibleBounds = value;
}

- (BOOL) sectionFootersPinToVisibleBounds {
    return _sectionFootersPinToVisibleBounds;
}

- (void) setSectionFootersPinToVisibleBounds: (BOOL) value {
    _sectionFootersPinToVisibleBounds = value;
}

// Extent of a section along the scroll axis (header + rows + footer + insets)
// and the offset at which it starts.
- (BOOL) _isVertical {
    return _scrollDirection == NSCollectionViewScrollDirectionVertical;
}

- (NSInteger) _linesForItemCount: (NSInteger) count {
    BOOL vertical = [self _isVertical];
    NSRect bounds = [_collectionView bounds];
    CGFloat cross = vertical ? bounds.size.width - _sectionInset.left - _sectionInset.right
                             : bounds.size.height - _sectionInset.top - _sectionInset.bottom;
    CGFloat itemCross = vertical ? _itemSize.width : _itemSize.height;
    NSInteger perLine = (NSInteger) ((cross + _minimumInteritemSpacing) /
                                     (itemCross + _minimumInteritemSpacing));
    if (perLine < 1)
        perLine = 1;
    return (count + perLine - 1) / perLine;
}

- (NSInteger) _itemsPerLine {
    BOOL vertical = [self _isVertical];
    NSRect bounds = [_collectionView bounds];
    CGFloat cross = vertical ? bounds.size.width - _sectionInset.left - _sectionInset.right
                             : bounds.size.height - _sectionInset.top - _sectionInset.bottom;
    CGFloat itemCross = vertical ? _itemSize.width : _itemSize.height;
    NSInteger perLine = (NSInteger) ((cross + _minimumInteritemSpacing) /
                                     (itemCross + _minimumInteritemSpacing));
    return perLine < 1 ? 1 : perLine;
}

- (CGFloat) _sectionExtent: (NSInteger) section {
    BOOL vertical = [self _isVertical];
    NSInteger lines = [self _linesForItemCount: [_collectionView numberOfItemsInSection: section]];
    CGFloat itemMain = vertical ? _itemSize.height : _itemSize.width;
    CGFloat extent = vertical ? _sectionInset.top + _sectionInset.bottom + _headerReferenceSize.height + _footerReferenceSize.height
                              : _sectionInset.left + _sectionInset.right + _headerReferenceSize.width + _footerReferenceSize.width;
    if (lines > 0)
        extent += lines * itemMain + (lines - 1) * _minimumLineSpacing;
    return extent;
}

- (CGFloat) _sectionOffset: (NSInteger) section {
    CGFloat offset = 0;
    for (NSInteger i = 0; i < section; i++)
        offset += [self _sectionExtent: i];
    return offset;
}

- (NSCollectionViewLayoutAttributes *) layoutAttributesForItemAtIndexPath: (NSIndexPath *) indexPath {
    BOOL vertical = [self _isVertical];
    NSInteger perLine = [self _itemsPerLine];
    NSInteger item = [indexPath item];
    NSInteger line = item / perLine;
    NSInteger slot = item % perLine;
    CGFloat offset = [self _sectionOffset: [indexPath section]];

    CGFloat x, y;
    if (vertical) {
        x = _sectionInset.left + slot * (_itemSize.width + _minimumInteritemSpacing);
        y = offset + _sectionInset.top + _headerReferenceSize.height + line * (_itemSize.height + _minimumLineSpacing);
    } else {
        x = offset + _sectionInset.left + _headerReferenceSize.width + line * (_itemSize.width + _minimumLineSpacing);
        y = _sectionInset.top + slot * (_itemSize.height + _minimumInteritemSpacing);
    }

    NSCollectionViewLayoutAttributes *attributes =
        [NSCollectionViewLayoutAttributes layoutAttributesForItemWithIndexPath: indexPath];
    [attributes setFrame: NSMakeRect(x, y, _itemSize.width, _itemSize.height)];
    return attributes;
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
    BOOL vertical = [self _isVertical];
    NSRect bounds = [_collectionView bounds];
    CGFloat total = 0;
    NSInteger sections = [_collectionView numberOfSections];
    for (NSInteger section = 0; section < sections; section++)
        total += [self _sectionExtent: section];
    return vertical ? NSMakeSize(bounds.size.width, total) : NSMakeSize(total, bounds.size.height);
}

- (BOOL) shouldInvalidateLayoutForBoundsChange: (NSRect) newBounds {
    NSRect old = [_collectionView bounds];
    return [self _isVertical] ? newBounds.size.width != old.size.width
                              : newBounds.size.height != old.size.height;
}

@end
