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
#import <AppKit/NSCollectionViewItem.h>
#import <AppKit/NSView.h>
#import <AppKit/NSUserInterfaceItemIdentification.h>

@class NSCollectionViewLayout, NSCollectionViewLayoutAttributes, NSNib, NSCollectionView;

typedef NSString *NSCollectionViewSupplementaryElementKind;

@protocol NSCollectionViewDataSource <NSObject>
@required
- (NSInteger) collectionView: (NSCollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section;
- (NSCollectionViewItem *) collectionView: (NSCollectionView *) collectionView
        itemForRepresentedObjectAtIndexPath: (NSIndexPath *) indexPath;
@optional
- (NSInteger) numberOfSectionsInCollectionView: (NSCollectionView *) collectionView;
- (NSView *) collectionView: (NSCollectionView *) collectionView
        viewForSupplementaryElementOfKind: (NSCollectionViewSupplementaryElementKind) kind
                              atIndexPath: (NSIndexPath *) indexPath;
@end

@protocol NSCollectionViewPrefetching <NSObject>
@required
- (void) collectionView: (NSCollectionView *) collectionView
    prefetchItemsAtIndexPaths: (NSArray<NSIndexPath *> *) indexPaths;
@optional
- (void) collectionView: (NSCollectionView *) collectionView
    cancelPrefetchingForItemsAtIndexPaths: (NSArray<NSIndexPath *> *) indexPaths;
@end

@interface NSIndexPath (NSCollectionViewAdditions)
+ (NSIndexPath *) indexPathForItem: (NSInteger) item inSection: (NSInteger) section;
- (NSInteger) item;
- (NSInteger) section;
@end

@interface NSCollectionView : NSView {
    NSArray *_content;
    NSCollectionViewItem *_itemPrototype;
    BOOL _isSelectable;
    NSSize _minItemSize;
    NSSize _maxItemSize;
    NSUInteger _maxNumberOfRows;
    NSUInteger _maxNumberOfColumns;
    NSArray *_backgroundColors;
    BOOL _allowsMultipleSelection;
    NSIndexSet *_selectionIndexes;
    BOOL _disallowsEmptySelection;
    NSSet *_selectionIndexPaths;
    id<NSCollectionViewPrefetching> _prefetchDataSource;
    id<NSCollectionViewDataSource> _dataSource;
    NSCollectionViewLayout *_collectionViewLayout;
    NSMutableDictionary *_registeredItemClasses;
    NSMutableDictionary *_registeredItemNibs;
    NSMutableDictionary *_registeredSupplementaryClasses;
    NSMutableDictionary *_registeredSupplementaryNibs;
    NSMutableDictionary *_itemsByIndexPath;
}

- (NSArray *) content;
- (NSCollectionViewItem *) itemPrototype;

- (BOOL) isSelectable;

- (NSSize) minItemSize;
- (NSSize) maxItemSize;

- (NSUInteger) maxNumberOfRows;
- (NSUInteger) maxNumberOfColumns;

- (NSArray *) backgroundColors;
- (BOOL) allowsMultipleSelection;
- (NSIndexSet *) selectionIndexes;

- (void) setContent: (NSArray *) value;
- (void) setItemPrototype: (NSCollectionViewItem *) value;
- (void) setSelectable: (BOOL) value;

- (void) setMinItemSize: (NSSize) value;
- (void) setMaxItemSize: (NSSize) value;
- (void) setMaxNumberOfRows: (NSUInteger) value;
- (void) setMaxNumberOfColumns: (NSUInteger) value;

- (void) setBackgroundColors: (NSArray *) value;
- (void) setAllowsMultipleSelection: (BOOL) value;
- (void) setSelectionIndexes: (NSIndexSet *) value;

- (BOOL) isFirstResponder;
- (NSCollectionViewItem *) newItemForRepresentedObject: object;

- (id<NSCollectionViewDataSource>) dataSource;
- (void) setDataSource: (id<NSCollectionViewDataSource>) value;
- (NSCollectionViewLayout *) collectionViewLayout;
- (void) setCollectionViewLayout: (NSCollectionViewLayout *) value;
- (id<NSCollectionViewPrefetching>) prefetchDataSource;
- (void) setPrefetchDataSource: (id<NSCollectionViewPrefetching>) value;

- (BOOL) allowsEmptySelection;
- (void) setAllowsEmptySelection: (BOOL) value;
- (NSSet<NSIndexPath *> *) selectionIndexPaths;
- (void) setSelectionIndexPaths: (NSSet<NSIndexPath *> *) value;
- (IBAction) selectAll: (id) sender;
- (IBAction) deselectAll: (id) sender;

- (void) reloadData;
- (NSInteger) numberOfSections;
- (NSInteger) numberOfItemsInSection: (NSInteger) section;
- (NSCollectionViewLayoutAttributes *) layoutAttributesForItemAtIndexPath: (NSIndexPath *) indexPath;

- (void) registerClass: (Class) itemClass forItemWithIdentifier: (NSUserInterfaceItemIdentifier) identifier;
- (void) registerNib: (NSNib *) nib forItemWithIdentifier: (NSUserInterfaceItemIdentifier) identifier;
- (void) registerClass: (Class) viewClass
    forSupplementaryViewOfKind: (NSCollectionViewSupplementaryElementKind) kind
                withIdentifier: (NSUserInterfaceItemIdentifier) identifier;
- (void) registerNib: (NSNib *) nib
    forSupplementaryViewOfKind: (NSCollectionViewSupplementaryElementKind) kind
                withIdentifier: (NSUserInterfaceItemIdentifier) identifier;
- (NSCollectionViewItem *) makeItemWithIdentifier: (NSUserInterfaceItemIdentifier) identifier
                                     forIndexPath: (NSIndexPath *) indexPath;
- (NSView *) makeSupplementaryViewOfKind: (NSCollectionViewSupplementaryElementKind) elementKind
                          withIdentifier: (NSUserInterfaceItemIdentifier) identifier
                            forIndexPath: (NSIndexPath *) indexPath;
- (NSCollectionViewItem *) itemAtIndexPath: (NSIndexPath *) indexPath;
- (NSArray<NSCollectionViewItem *> *) visibleItems;

@end

@protocol NSCollectionViewDelegate <NSObject>
// TODO
@end
