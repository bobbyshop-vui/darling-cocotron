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
#import <AppKit/NSRaise.h>
#import <AppKit/NSTreeController.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSIndexPath.h>
#import <Foundation/NSKeyValueCoding.h>
#import <Foundation/NSKeyValueObserving.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSSortDescriptor.h>
#import <Foundation/NSString.h>

@implementation NSTreeController

- (void) _treeControllerDefaults {
    _avoidsEmptySelection = YES;
    if (_sortDescriptors == nil)
        _sortDescriptors = [[NSArray alloc] init];
    if (_selectionIndexPaths == nil)
        _selectionIndexPaths = [[NSArray alloc] init];
}

- init {
    if ((self = [super init])) {
        [self _treeControllerDefaults];
    }
    return self;
}

- (id) initWithContent: (id) content {
    if ((self = [super initWithContent: content])) {
        [self _treeControllerDefaults];
    }
    return self;
}

- initWithCoder: (NSCoder *) coder {
    if ((self = [super initWithCoder: coder])) {
        [self _treeControllerDefaults];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder {
    [super encodeWithCoder: coder];
}

- copyWithZone: (NSZone *) zone {
    return [self retain];
}

- (void) dealloc {
    [_childrenKeyPath release];
    [_countKeyPath release];
    [_leafKeyPath release];
    [_sortDescriptors release];
    [_arrangedObjects release];
    [_selectionIndexPaths release];
    [super dealloc];
}

#pragma mark Key paths

- (NSString *) childrenKeyPath {
    return _childrenKeyPath;
}

- (void) setChildrenKeyPath: (NSString *) path {
    path = [path copy];
    [_childrenKeyPath release];
    _childrenKeyPath = path;
    [self rearrangeObjects];
}

- (NSString *) countKeyPath {
    return _countKeyPath;
}

- (NSString *) leafKeyPath {
    return _leafKeyPath;
}

#pragma mark Sorting

- (NSArray *) sortDescriptors {
    return _sortDescriptors;
}

- (void) setSortDescriptors: (NSArray *) descriptors {
    descriptors = [descriptors copy];
    [self willChangeValueForKey: @"sortDescriptors"];
    [_sortDescriptors release];
    _sortDescriptors = descriptors != nil ? descriptors : [[NSArray alloc] init];
    [self didChangeValueForKey: @"sortDescriptors"];
    [self rearrangeObjects];
}

- (BOOL) avoidsEmptySelection {
    return _avoidsEmptySelection;
}

- (void) setAvoidsEmptySelection: (BOOL) flag {
    _avoidsEmptySelection = flag;
}

#pragma mark Tree access

- (NSArray *) _arrange: (NSArray *) objects {
    if (objects == nil)
        return [NSArray array];
    if ([_sortDescriptors count] > 0)
        return [objects sortedArrayUsingDescriptors: _sortDescriptors];
    return objects;
}

- (NSArray *) _rootObjects {
    id content = [self content];
    if (content == nil)
        return [NSArray array];
    if ([content isKindOfClass: [NSArray class]])
        return content;
    return [NSArray arrayWithObject: content];
}

- (NSArray *) _childrenOfObject: (id) object {
    if (_childrenKeyPath == nil || object == nil)
        return [NSArray array];
    id children = nil;
    @try {
        children = [object valueForKeyPath: _childrenKeyPath];
    } @catch (NSException *e) {
        children = nil;
    }
    if ([children isKindOfClass: [NSArray class]])
        return children;
    if ([children isKindOfClass: [NSSet class]])
        return [children allObjects];
    return [NSArray array];
}

- (id) _objectAtIndexPath: (NSIndexPath *) path {
    NSUInteger i, count = [path length];
    NSArray *level = [self _arrange: [self _rootObjects]];
    id object = nil;

    if (count == 0)
        return nil;
    for (i = 0; i < count; i++) {
        NSUInteger index = [path indexAtPosition: i];
        if (index >= [level count])
            return nil;
        object = [level objectAtIndex: index];
        level = [self _arrange: [self _childrenOfObject: object]];
    }
    return object;
}

- (NSMutableArray *) _mutableSiblingsForParentPath: (NSIndexPath *) parent {
    // Returns a mutable proxy to the array that holds the objects at the
    // level below parent (parent == nil or empty means the root level).
    if ([parent length] == 0) {
        id content = [self content];
        if ([content isKindOfClass: [NSMutableArray class]])
            return content;
        NSMutableArray *roots =
                [NSMutableArray arrayWithArray: [self _rootObjects]];
        [self setContent: roots];
        return roots;
    }
    id parentObject = [self _objectAtIndexPath: parent];
    if (parentObject == nil || _childrenKeyPath == nil)
        return nil;
    return [parentObject mutableArrayValueForKeyPath: _childrenKeyPath];
}

- (id) arrangedObjects {
    if (_arrangedObjects == nil)
        _arrangedObjects = [[self _arrange: [self _rootObjects]] copy];
    return _arrangedObjects;
}

- (void) rearrangeObjects {
    [self willChangeValueForKey: @"arrangedObjects"];
    [_arrangedObjects release];
    _arrangedObjects = nil;
    [self didChangeValueForKey: @"arrangedObjects"];
}

#pragma mark Selection

- (NSIndexPath *) selectionIndexPath {
    return [_selectionIndexPaths count] > 0
                   ? [_selectionIndexPaths objectAtIndex: 0]
                   : nil;
}

- (NSArray *) selectionIndexPaths {
    return _selectionIndexPaths != nil ? _selectionIndexPaths : [NSArray array];
}

- (BOOL) setSelectionIndexPaths: (NSArray *) indexPaths {
    if (indexPaths == nil)
        indexPaths = [NSArray array];
    if ([indexPaths count] == 0 && _avoidsEmptySelection &&
        [[self _rootObjects] count] > 0) {
        indexPaths = [NSArray arrayWithObject: [NSIndexPath indexPathWithIndex: 0]];
    }
    if ([indexPaths isEqual: _selectionIndexPaths])
        return NO;

    [self willChangeValueForKey: @"selectionIndexPaths"];
    [self willChangeValueForKey: @"selectionIndexPath"];
    [self willChangeValueForKey: @"selectedObjects"];
    [_selectionIndexPaths release];
    _selectionIndexPaths = [indexPaths copy];
    [self didChangeValueForKey: @"selectedObjects"];
    [self didChangeValueForKey: @"selectionIndexPath"];
    [self didChangeValueForKey: @"selectionIndexPaths"];
    return YES;
}

- (BOOL) setSelectionIndexPath: (NSIndexPath *) indexPath {
    return [self setSelectionIndexPaths: indexPath != nil
                                                ? [NSArray arrayWithObject: indexPath]
                                                : [NSArray array]];
}

- (NSArray *) selectedObjects {
    NSMutableArray *result = [NSMutableArray array];
    for (NSIndexPath *path in _selectionIndexPaths) {
        id object = [self _objectAtIndexPath: path];
        if (object != nil)
            [result addObject: object];
    }
    return result;
}

- (NSArray *) selectedNodes {
    // NSTreeNode proxies are not provided, so there are no node objects to
    // report.
    return [NSArray array];
}

#pragma mark Editing

- (BOOL) canInsert {
    return [self isEditable];
}

- (void) insertObject: (id) object
        atArrangedObjectIndexPath: (NSIndexPath *) indexPath
{
    if (object == nil || indexPath == nil || [indexPath length] == 0)
        return;

    NSMutableArray *siblings = [self _mutableSiblingsForParentPath:
                                             [indexPath indexPathByRemovingLastIndex]];
    if (siblings == nil)
        return;

    NSUInteger index = [indexPath indexAtPosition: [indexPath length] - 1];
    if (index > [siblings count])
        index = [siblings count];
    [siblings insertObject: object atIndex: index];
    [self rearrangeObjects];
    [self setSelectionIndexPath: indexPath];
}

- (void) add: (id) sender {
    if (![self canInsert])
        return;
    NSIndexPath *selected = [self selectionIndexPath];
    NSIndexPath *parent = selected != nil ? [selected indexPathByRemovingLastIndex]
                                          : nil;
    NSArray *siblings = parent != nil && [parent length] > 0
                                ? [self _childrenOfObject: [self _objectAtIndexPath: parent]]
                                : [self _rootObjects];
    id object = [self newObject];
    NSIndexPath *path = [parent length] > 0
                                ? [parent indexPathByAddingIndex: [siblings count]]
                                : [NSIndexPath indexPathWithIndex: [siblings count]];
    [self insertObject: object atArrangedObjectIndexPath: path];
    [object release];
}

- (void) addChild: (id) sender {
    NSIndexPath *selected = [self selectionIndexPath];
    if (![self canInsert] || selected == nil || _childrenKeyPath == nil)
        return;
    id parent = [self _objectAtIndexPath: selected];
    NSUInteger count = [[self _childrenOfObject: parent] count];
    id object = [self newObject];
    [self insertObject: object
            atArrangedObjectIndexPath: [selected indexPathByAddingIndex: count]];
    [object release];
}

- (void) insert: (id) sender {
    if (![self canInsert])
        return;
    NSIndexPath *selected = [self selectionIndexPath];
    id object = [self newObject];
    NSIndexPath *path = selected != nil ? selected
                                        : [NSIndexPath indexPathWithIndex: 0];
    [self insertObject: object atArrangedObjectIndexPath: path];
    [object release];
}

- (void) remove: (id) sender {
    if (![self isEditable])
        return;
    NSArray *paths = [[self selectionIndexPaths]
            sortedArrayUsingSelector: @selector(compare:)];
    NSInteger i;
    // Remove from the end so earlier index paths stay valid.
    for (i = (NSInteger) [paths count] - 1; i >= 0; i--) {
        NSIndexPath *path = [paths objectAtIndex: i];
        if ([path length] == 0)
            continue;
        NSMutableArray *siblings = [self _mutableSiblingsForParentPath:
                                                 [path indexPathByRemovingLastIndex]];
        NSUInteger index = [path indexAtPosition: [path length] - 1];
        if (siblings != nil && index < [siblings count])
            [siblings removeObjectAtIndex: index];
    }
    [_selectionIndexPaths release];
    _selectionIndexPaths = [[NSArray alloc] init];
    [self rearrangeObjects];
    [self setSelectionIndexPaths: [NSArray array]];
}

@end
