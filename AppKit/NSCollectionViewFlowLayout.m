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

// The delegate (NSCollectionViewDelegateFlowLayout) can override the layout
// properties per section / per item.
- (id) _flowDelegate {
    return [_collectionView delegate];
}

- (NSSize) _itemSizeAtIndexPath: (NSIndexPath *) indexPath {
    id delegate = [self _flowDelegate];
    if ([delegate respondsToSelector: @selector(collectionView:layout:sizeForItemAtIndexPath:)])
        return [delegate collectionView: _collectionView layout: self sizeForItemAtIndexPath: indexPath];
    return _itemSize;
}

// Slot size of a section: sections are laid out on a uniform grid sized by
// their first item.
- (NSSize) _itemSizeForSection: (NSInteger) section {
    if ([_collectionView numberOfItemsInSection: section] > 0)
        return [self _itemSizeAtIndexPath: [NSIndexPath indexPathForItem: 0 inSection: section]];
    return _itemSize;
}

- (NSEdgeInsets) _insetForSection: (NSInteger) section {
    id delegate = [self _flowDelegate];
    if ([delegate respondsToSelector: @selector(collectionView:layout:insetForSectionAtIndex:)])
        return [delegate collectionView: _collectionView layout: self insetForSectionAtIndex: section];
    return _sectionInset;
}

- (CGFloat) _lineSpacingForSection: (NSInteger) section {
    id delegate = [self _flowDelegate];
    if ([delegate respondsToSelector: @selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)])
        return [delegate collectionView: _collectionView layout: self minimumLineSpacingForSectionAtIndex: section];
    return _minimumLineSpacing;
}

- (CGFloat) _interitemSpacingForSection: (NSInteger) section {
    id delegate = [self _flowDelegate];
    if ([delegate respondsToSelector: @selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)])
        return [delegate collectionView: _collectionView layout: self minimumInteritemSpacingForSectionAtIndex: section];
    return _minimumInteritemSpacing;
}

- (NSSize) _headerSizeForSection: (NSInteger) section {
    id delegate = [self _flowDelegate];
    if ([delegate respondsToSelector: @selector(collectionView:layout:referenceSizeForHeaderInSection:)])
        return [delegate collectionView: _collectionView layout: self referenceSizeForHeaderInSection: section];
    return _headerReferenceSize;
}

- (NSSize) _footerSizeForSection: (NSInteger) section {
    id delegate = [self _flowDelegate];
    if ([delegate respondsToSelector: @selector(collectionView:layout:referenceSizeForFooterInSection:)])
        return [delegate collectionView: _collectionView layout: self referenceSizeForFooterInSection: section];
    return _footerReferenceSize;
}

- (BOOL) _isVertical {
    return _scrollDirection == NSCollectionViewScrollDirectionVertical;
}

- (NSInteger) _itemsPerLineForSection: (NSInteger) section {
    BOOL vertical = [self _isVertical];
    NSRect bounds = [_collectionView bounds];
    NSEdgeInsets inset = [self _insetForSection: section];
    NSSize itemSize = [self _itemSizeForSection: section];
    CGFloat spacing = [self _interitemSpacingForSection: section];
    CGFloat cross = vertical ? bounds.size.width - inset.left - inset.right
                             : bounds.size.height - inset.top - inset.bottom;
    CGFloat itemCross = vertical ? itemSize.width : itemSize.height;
    NSInteger perLine = (NSInteger) ((cross + spacing) / (itemCross + spacing));
    return perLine < 1 ? 1 : perLine;
}

- (NSInteger) _linesForSection: (NSInteger) section {
    NSInteger count = [_collectionView numberOfItemsInSection: section];
    NSInteger perLine = [self _itemsPerLineForSection: section];
    return (count + perLine - 1) / perLine;
}

// Extent of a section along the scroll axis (header + rows + footer + insets).
- (CGFloat) _sectionExtent: (NSInteger) section {
    BOOL vertical = [self _isVertical];
    NSInteger lines = [self _linesForSection: section];
    NSSize itemSize = [self _itemSizeForSection: section];
    NSEdgeInsets inset = [self _insetForSection: section];
    NSSize header = [self _headerSizeForSection: section];
    NSSize footer = [self _footerSizeForSection: section];
    CGFloat itemMain = vertical ? itemSize.height : itemSize.width;
    CGFloat extent = vertical ? inset.top + inset.bottom + header.height + footer.height
                              : inset.left + inset.right + header.width + footer.width;
    if (lines > 0)
        extent += lines * itemMain + (lines - 1) * [self _lineSpacingForSection: section];
    return extent;
}

// Offset along the scroll axis at which a section starts.
- (CGFloat) _sectionOffset: (NSInteger) section {
    CGFloat offset = 0;
    for (NSInteger i = 0; i < section; i++)
        offset += [self _sectionExtent: i];
    return offset;
}

- (NSCollectionViewLayoutAttributes *) layoutAttributesForItemAtIndexPath: (NSIndexPath *) indexPath {
    BOOL vertical = [self _isVertical];
    NSInteger section = [indexPath section];
    NSInteger perLine = [self _itemsPerLineForSection: section];
    NSInteger item = [indexPath item];
    NSInteger line = item / perLine;
    NSInteger slot = item % perLine;
    CGFloat offset = [self _sectionOffset: section];
    NSSize slotSize = [self _itemSizeForSection: section];
    NSEdgeInsets inset = [self _insetForSection: section];
    NSSize header = [self _headerSizeForSection: section];
    CGFloat lineSpacing = [self _lineSpacingForSection: section];
    CGFloat interitem = [self _interitemSpacingForSection: section];

    CGFloat x, y;
    if (vertical) {
        x = inset.left + slot * (slotSize.width + interitem);
        y = offset + inset.top + header.height + line * (slotSize.height + lineSpacing);
    } else {
        x = offset + inset.left + header.width + line * (slotSize.width + lineSpacing);
        y = inset.top + slot * (slotSize.height + interitem);
    }

    NSCollectionViewLayoutAttributes *attributes =
        [NSCollectionViewLayoutAttributes layoutAttributesForItemWithIndexPath: indexPath];
    NSSize size = [self _itemSizeAtIndexPath: indexPath];
    [attributes setFrame: NSMakeRect(x, y, size.width, size.height)];
    return attributes;
}

- (NSCollectionViewLayoutAttributes *) layoutAttributesForSupplementaryViewOfKind: (NSString *) kind
                                                                      atIndexPath: (NSIndexPath *) indexPath {
    BOOL header = [kind isEqualToString: NSCollectionElementKindSectionHeader];
    BOOL footer = [kind isEqualToString: NSCollectionElementKindSectionFooter];
    if (!header && !footer)
        return nil;

    BOOL vertical = [self _isVertical];
    NSInteger section = [indexPath section];
    NSSize size = header ? [self _headerSizeForSection: section] : [self _footerSizeForSection: section];
    if (size.width <= 0 && size.height <= 0)
        return nil;

    NSRect bounds = [_collectionView bounds];
    CGFloat offset = [self _sectionOffset: section];
    CGFloat extent = [self _sectionExtent: section];
    NSRect frame;
    if (vertical) {
        frame = NSMakeRect(0, header ? offset : offset + extent - size.height, bounds.size.width, size.height);
    } else {
        frame = NSMakeRect(header ? offset : offset + extent - size.width, 0, size.width, bounds.size.height);
    }

    NSCollectionViewLayoutAttributes *attributes =
        [NSCollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind: kind
                                                                       withIndexPath: indexPath];
    [attributes setFrame: frame];
    return attributes;
}

- (NSArray *) layoutAttributesForElementsInRect: (NSRect) rect {
    NSMutableArray *result = [NSMutableArray array];
    NSInteger sections = [_collectionView numberOfSections];
    for (NSInteger section = 0; section < sections; section++) {
        NSIndexPath *sectionPath = [NSIndexPath indexPathForItem: 0 inSection: section];
        NSString *kinds[2] = { NSCollectionElementKindSectionHeader, NSCollectionElementKindSectionFooter };
        for (int k = 0; k < 2; k++) {
            NSCollectionViewLayoutAttributes *attributes =
                [self layoutAttributesForSupplementaryViewOfKind: kinds[k] atIndexPath: sectionPath];
            if (attributes != nil && NSIntersectsRect(rect, [attributes frame]))
                [result addObject: attributes];
        }
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
