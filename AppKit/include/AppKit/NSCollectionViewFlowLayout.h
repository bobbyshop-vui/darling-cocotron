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
#import <Foundation/NSString.h>
#import <AppKit/NSCollectionViewLayout.h>

APPKIT_EXPORT NSString *const NSCollectionElementKindSectionHeader;
APPKIT_EXPORT NSString *const NSCollectionElementKindSectionFooter;

typedef NS_ENUM(NSInteger, NSCollectionViewScrollDirection) {
    NSCollectionViewScrollDirectionVertical,
    NSCollectionViewScrollDirectionHorizontal
};

@interface NSCollectionViewFlowLayout : NSCollectionViewLayout {
    CGFloat _minimumLineSpacing;
    CGFloat _minimumInteritemSpacing;
    NSSize _itemSize;
    NSCollectionViewScrollDirection _scrollDirection;
    NSSize _headerReferenceSize;
    NSSize _footerReferenceSize;
    NSEdgeInsets _sectionInset;
    BOOL _sectionHeadersPinToVisibleBounds;
    BOOL _sectionFootersPinToVisibleBounds;
}

- (CGFloat) minimumLineSpacing;
- (void) setMinimumLineSpacing: (CGFloat) value;
- (CGFloat) minimumInteritemSpacing;
- (void) setMinimumInteritemSpacing: (CGFloat) value;
- (NSSize) itemSize;
- (void) setItemSize: (NSSize) value;
- (NSCollectionViewScrollDirection) scrollDirection;
- (void) setScrollDirection: (NSCollectionViewScrollDirection) value;
- (NSSize) headerReferenceSize;
- (void) setHeaderReferenceSize: (NSSize) value;
- (NSSize) footerReferenceSize;
- (void) setFooterReferenceSize: (NSSize) value;
- (NSEdgeInsets) sectionInset;
- (void) setSectionInset: (NSEdgeInsets) value;
- (BOOL) sectionHeadersPinToVisibleBounds;
- (void) setSectionHeadersPinToVisibleBounds: (BOOL) value;
- (BOOL) sectionFootersPinToVisibleBounds;
- (void) setSectionFootersPinToVisibleBounds: (BOOL) value;

@end
