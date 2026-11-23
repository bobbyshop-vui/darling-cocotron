/*
 This file is part of Darling.

 Copyright (C) 2021 Lubos Dolezel

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

#import <AppKit/NSCollectionViewLayoutAttributes.h>

@implementation NSCollectionViewLayoutAttributes

+ (instancetype) _attributesWithCategory: (NSCollectionElementCategory) category
                                    kind: (NSString *) kind
                               indexPath: (NSIndexPath *) indexPath {
    NSCollectionViewLayoutAttributes *attributes = [[[self alloc] init] autorelease];
    attributes->_representedElementCategory = category;
    attributes->_representedElementKind = [kind copy];
    attributes->_indexPath = [indexPath copy];
    return attributes;
}

+ (instancetype) layoutAttributesForItemWithIndexPath: (NSIndexPath *) indexPath {
    return [self _attributesWithCategory: NSCollectionElementCategoryItem
                                    kind: nil
                               indexPath: indexPath];
}

+ (instancetype) layoutAttributesForInterItemGapBeforeIndexPath: (NSIndexPath *) indexPath {
    return [self _attributesWithCategory: NSCollectionElementCategoryInterItemGap
                                    kind: @"NSCollectionElementKindInterItemGapIndicator"
                               indexPath: indexPath];
}

+ (instancetype) layoutAttributesForSupplementaryViewOfKind: (NSString *) elementKind
                                              withIndexPath: (NSIndexPath *) indexPath {
    return [self _attributesWithCategory: NSCollectionElementCategorySupplementaryView
                                    kind: elementKind
                               indexPath: indexPath];
}

+ (instancetype) layoutAttributesForDecorationViewOfKind: (NSString *) decorationViewKind
                                            withIndexPath: (NSIndexPath *) indexPath {
    return [self _attributesWithCategory: NSCollectionElementCategoryDecorationView
                                    kind: decorationViewKind
                               indexPath: indexPath];
}

- init {
    if ((self = [super init])) {
        _alpha = 1.0;
    }
    return self;
}

- (void) dealloc {
    [_indexPath release];
    [_representedElementKind release];
    [super dealloc];
}

- copyWithZone: (NSZone *) zone {
    NSCollectionViewLayoutAttributes *copy = [[[self class] allocWithZone: zone] init];
    copy->_frame = _frame;
    copy->_alpha = _alpha;
    copy->_zIndex = _zIndex;
    copy->_hidden = _hidden;
    copy->_indexPath = [_indexPath copy];
    copy->_representedElementCategory = _representedElementCategory;
    copy->_representedElementKind = [_representedElementKind copy];
    return copy;
}

- (NSRect) frame {
    return _frame;
}

- (void) setFrame: (NSRect) value {
    _frame = value;
}

- (NSSize) size {
    return _frame.size;
}

- (void) setSize: (NSSize) value {
    _frame.size = value;
}

- (CGFloat) alpha {
    return _alpha;
}

- (void) setAlpha: (CGFloat) value {
    _alpha = value;
}

- (NSInteger) zIndex {
    return _zIndex;
}

- (void) setZIndex: (NSInteger) value {
    _zIndex = value;
}

- (BOOL) isHidden {
    return _hidden;
}

- (void) setHidden: (BOOL) value {
    _hidden = value;
}

- (NSIndexPath *) indexPath {
    return _indexPath;
}

- (void) setIndexPath: (NSIndexPath *) value {
    value = [value copy];
    [_indexPath release];
    _indexPath = value;
}

- (NSCollectionElementCategory) representedElementCategory {
    return _representedElementCategory;
}

- (NSString *) representedElementKind {
    return _representedElementKind;
}

@end
