/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

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
#import <AppKit/NSObjectController.h>

@class NSIndexPath, NSSortDescriptor, NSTreeNode;

@interface NSTreeController : NSObjectController <NSCoding, NSCopying> {
    NSString *_childrenKeyPath;
    NSString *_countKeyPath;
    NSString *_leafKeyPath;
    NSArray *_sortDescriptors;
    NSArray *_arrangedObjects;
    NSArray *_selectionIndexPaths;
    BOOL _avoidsEmptySelection;
}

- (NSString *) childrenKeyPath;
- (void) setChildrenKeyPath: (NSString *) path;
- (NSString *) countKeyPath;
- (NSString *) leafKeyPath;
- (NSArray *) sortDescriptors;
- (void) setSortDescriptors: (NSArray *) descriptors;
- (BOOL) avoidsEmptySelection;
- (void) setAvoidsEmptySelection: (BOOL) flag;

- (id) arrangedObjects;
- (void) rearrangeObjects;

- (void) insertObject: (id) object
        atArrangedObjectIndexPath: (NSIndexPath *) indexPath;

- (NSIndexPath *) selectionIndexPath;
- (NSArray *) selectionIndexPaths;
- (BOOL) setSelectionIndexPath: (NSIndexPath *) indexPath;
- (BOOL) setSelectionIndexPaths: (NSArray *) indexPaths;
- (NSArray *) selectedNodes;

- (BOOL) canInsert;
- (void) add: (id) sender;
- (void) addChild: (id) sender;
- (void) insert: (id) sender;
- (void) remove: (id) sender;

@end
