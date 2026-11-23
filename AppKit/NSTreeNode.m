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

#import <AppKit/NSTreeNode.h>
#import <Foundation/NSIndexPath.h>
#import <Foundation/NSSortDescriptor.h>

@interface NSTreeNode ()
- (void) _setParentNode: (NSTreeNode *) parent;
- (NSMutableArray *) _storage;
@end

// Mutable proxy returned by -mutableChildNodes; keeps parentNode of inserted
// and removed children up to date.
@interface _NSTreeNodeChildProxy : NSMutableArray {
    NSTreeNode *_owner;
}
- (instancetype) initWithOwner: (NSTreeNode *) owner;
@end

@implementation _NSTreeNodeChildProxy

- (instancetype) initWithOwner: (NSTreeNode *) owner {
    _owner = owner;
    return self;
}

- (NSUInteger) count {
    return [[_owner _storage] count];
}

- (id) objectAtIndex: (NSUInteger) index {
    return [[_owner _storage] objectAtIndex: index];
}

- (void) insertObject: (id) object atIndex: (NSUInteger) index {
    [[_owner _storage] insertObject: object atIndex: index];
    [object _setParentNode: _owner];
}

- (void) removeObjectAtIndex: (NSUInteger) index {
    NSTreeNode *old = [[[_owner _storage] objectAtIndex: index] retain];
    [[_owner _storage] removeObjectAtIndex: index];
    [old _setParentNode: nil];
    [old release];
}

- (void) addObject: (id) object {
    [self insertObject: object atIndex: [self count]];
}

- (void) removeLastObject {
    [self removeObjectAtIndex: [self count] - 1];
}

- (void) replaceObjectAtIndex: (NSUInteger) index withObject: (id) object {
    NSTreeNode *old = [[[_owner _storage] objectAtIndex: index] retain];
    [[_owner _storage] replaceObjectAtIndex: index withObject: object];
    [old _setParentNode: nil];
    [object _setParentNode: _owner];
    [old release];
}

@end

@implementation NSTreeNode

+ (instancetype) treeNodeWithRepresentedObject: (id) modelObject {
    return [[[self alloc] initWithRepresentedObject: modelObject] autorelease];
}

- (instancetype) initWithRepresentedObject: (id) modelObject {
    self = [super init];
    if (self) {
        _tnRepresentedObject = [modelObject retain];
        _tnChildNodes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) dealloc {
    for (NSTreeNode *child in _tnChildNodes)
        child->_tnParentNode = nil;
    [_tnChildNodesProxy release];
    [_tnChildNodes release];
    [_tnRepresentedObject release];
    [super dealloc];
}

- (void) _setParentNode: (NSTreeNode *) parent {
    _tnParentNode = parent;
}

- (NSMutableArray *) _storage {
    return _tnChildNodes;
}

- (id) representedObject {
    return _tnRepresentedObject;
}

- (NSIndexPath *) indexPath {
    NSUInteger depth = 0, i;
    NSTreeNode *node;

    for (node = self; node->_tnParentNode != nil; node = node->_tnParentNode)
        depth++;

    NSUInteger indexes[depth + 1];

    for (node = self, i = depth; i > 0; i--, node = node->_tnParentNode)
        indexes[i - 1] = [node->_tnParentNode->_tnChildNodes
                indexOfObjectIdenticalTo: node];

    return [NSIndexPath indexPathWithIndexes: indexes length: depth];
}

- (BOOL) isLeaf {
    return [_tnChildNodes count] == 0;
}

- (NSArray *) childNodes {
    return [[_tnChildNodes copy] autorelease];
}

- (NSMutableArray *) mutableChildNodes {
    if (_tnChildNodesProxy == nil)
        _tnChildNodesProxy =
                [[_NSTreeNodeChildProxy alloc] initWithOwner: self];
    return _tnChildNodesProxy;
}

- (NSTreeNode *) descendantNodeAtIndexPath: (NSIndexPath *) indexPath {
    NSTreeNode *node = self;
    NSUInteger i, count = [indexPath length];

    for (i = 0; i < count; i++) {
        NSUInteger index = [indexPath indexAtPosition: i];
        if (index >= [node->_tnChildNodes count])
            return nil;
        node = [node->_tnChildNodes objectAtIndex: index];
    }
    return node;
}

- (NSTreeNode *) parentNode {
    return _tnParentNode;
}

- (void) sortWithSortDescriptors: (NSArray *) sortDescriptors
                     recursively: (BOOL) recursively {
    if ([sortDescriptors count] > 0)
        [_tnChildNodes sortUsingDescriptors: sortDescriptors];
    if (recursively) {
        for (NSTreeNode *child in _tnChildNodes)
            [child sortWithSortDescriptors: sortDescriptors recursively: YES];
    }
}

@end
