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

#import <AppKit/AppKitExport.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NSCollectionElementCategory) {
    NSCollectionElementCategoryItem,
    NSCollectionElementCategorySupplementaryView,
    NSCollectionElementCategoryDecorationView,
    NSCollectionElementCategoryInterItemGap,
};

@interface NSCollectionViewLayoutAttributes : NSObject <NSCopying> {
    NSRect _frame;
    CGFloat _alpha;
    NSInteger _zIndex;
    BOOL _hidden;
    NSIndexPath *_indexPath;
    NSCollectionElementCategory _representedElementCategory;
    NSString *_representedElementKind;
}

+ (instancetype) layoutAttributesForItemWithIndexPath: (NSIndexPath *) indexPath;
+ (instancetype) layoutAttributesForInterItemGapBeforeIndexPath: (NSIndexPath *) indexPath;
+ (instancetype) layoutAttributesForSupplementaryViewOfKind: (NSString *) elementKind
                                              withIndexPath: (NSIndexPath *) indexPath;
+ (instancetype) layoutAttributesForDecorationViewOfKind: (NSString *) decorationViewKind
                                            withIndexPath: (NSIndexPath *) indexPath;

- (NSRect) frame;
- (void) setFrame: (NSRect) value;
- (NSSize) size;
- (void) setSize: (NSSize) value;
- (CGFloat) alpha;
- (void) setAlpha: (CGFloat) value;
- (NSInteger) zIndex;
- (void) setZIndex: (NSInteger) value;
- (BOOL) isHidden;
- (void) setHidden: (BOOL) value;
- (NSIndexPath *) indexPath;
- (void) setIndexPath: (NSIndexPath *) value;
- (NSCollectionElementCategory) representedElementCategory;
- (NSString *) representedElementKind;

@end
