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

#import <AppKit/AppKitExport.h>
#import <AppKit/NSCollectionView.h>
#import <Foundation/NSString.h>
#import <AppKit/NSCollectionViewLayoutAttributes.h>

typedef NSString *NSCollectionViewDecorationElementKind;

APPKIT_EXPORT NSCollectionViewSupplementaryElementKind const
        NSCollectionElementKindInterItemGapIndicator;

@interface NSCollectionViewLayout : NSObject <NSCoding> {
    NSCollectionView *_collectionView;
}

- (NSCollectionView *) collectionView;
- (void) _setCollectionView: (NSCollectionView *) value;

- (void) invalidateLayout;
- (void) prepareLayout;
- (NSArray<NSCollectionViewLayoutAttributes *> *) layoutAttributesForElementsInRect: (NSRect) rect;
- (NSCollectionViewLayoutAttributes *) layoutAttributesForItemAtIndexPath: (NSIndexPath *) indexPath;
- (BOOL) shouldInvalidateLayoutForBoundsChange: (NSRect) newBounds;
- (NSSize) collectionViewContentSize;

@end

@interface NSCollectionViewGridLayout : NSCollectionViewLayout {
    NSEdgeInsets _margins;
    CGFloat _minimumInteritemSpacing;
    CGFloat _minimumLineSpacing;
    NSUInteger _maximumNumberOfRows;
    NSUInteger _maximumNumberOfColumns;
    NSSize _minimumItemSize;
    NSSize _maximumItemSize;
    NSArray *_backgroundColors;
}

- (NSEdgeInsets) margins;
- (void) setMargins: (NSEdgeInsets) value;
- (CGFloat) minimumInteritemSpacing;
- (void) setMinimumInteritemSpacing: (CGFloat) value;
- (CGFloat) minimumLineSpacing;
- (void) setMinimumLineSpacing: (CGFloat) value;
- (NSUInteger) maximumNumberOfRows;
- (void) setMaximumNumberOfRows: (NSUInteger) value;
- (NSUInteger) maximumNumberOfColumns;
- (void) setMaximumNumberOfColumns: (NSUInteger) value;
- (NSSize) minimumItemSize;
- (void) setMinimumItemSize: (NSSize) value;
- (NSSize) maximumItemSize;
- (void) setMaximumItemSize: (NSSize) value;
- (NSArray *) backgroundColors;
- (void) setBackgroundColors: (NSArray *) value;

@end
