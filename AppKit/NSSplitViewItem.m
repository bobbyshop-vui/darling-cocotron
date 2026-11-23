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

#import <AppKit/NSSplitViewItem.h>

#import <AppKit/NSView.h>
#import <AppKit/NSViewController.h>

@implementation NSSplitViewItem

- (instancetype) init {
    if ((self = [super init])) {
        _holdingPriority = 250;
    }
    return self;
}

+ (instancetype) _itemWithViewController: (NSViewController *) viewController
                                behavior: (NSSplitViewItemBehavior) behavior
{
    NSSplitViewItem *item = [[[self alloc] init] autorelease];
    item->_behavior = behavior;
    item->_canCollapse = (behavior == NSSplitViewItemBehaviorSidebar);
    if (behavior == NSSplitViewItemBehaviorSidebar) {
        item->_holdingPriority = 260;
    }
    [item setViewController: viewController];
    return item;
}

+ (instancetype) splitViewItemWithViewController:
        (NSViewController *) viewController
{
    return [self _itemWithViewController: viewController
                                behavior: NSSplitViewItemBehaviorDefault];
}

+ (instancetype) sidebarWithViewController: (NSViewController *) viewController
{
    return [self _itemWithViewController: viewController
                                behavior: NSSplitViewItemBehaviorSidebar];
}

+ (instancetype) contentListWithViewController:
        (NSViewController *) viewController
{
    return [self _itemWithViewController: viewController
                                behavior: NSSplitViewItemBehaviorContentList];
}

- (void) dealloc {
    [_viewController release];
    [super dealloc];
}

- (NSSplitViewItemBehavior) behavior {
    return _behavior;
}

- (NSViewController *) viewController {
    return _viewController;
}

- (void) setViewController: (NSViewController *) viewController {
    if (viewController != _viewController) {
        [viewController retain];
        [_viewController release];
        _viewController = viewController;
    }
}

- (BOOL) canCollapse {
    return _canCollapse;
}

- (void) setCanCollapse: (BOOL) canCollapse {
    _canCollapse = canCollapse;
}

- (BOOL) isCollapsed {
    return _collapsed;
}

- (void) setCollapsed: (BOOL) collapsed {
    if (collapsed == _collapsed) {
        return;
    }
    _collapsed = collapsed;
    [[_viewController view] setHidden: collapsed];
}

- (NSLayoutPriority) holdingPriority {
    return _holdingPriority;
}

- (void) setHoldingPriority: (NSLayoutPriority) holdingPriority {
    _holdingPriority = holdingPriority;
}

- (BOOL) isSpringLoaded {
    return _springLoaded;
}

- (void) setSpringLoaded: (BOOL) springLoaded {
    _springLoaded = springLoaded;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [NSMethodSignature signatureWithObjCTypes: "v@:"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"Stub called: %@ in %@", NSStringFromSelector([anInvocation selector]), [self class]);
}

@end
