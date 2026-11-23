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

#import <AppKit/NSSplitViewController.h>

#import <AppKit/NSSplitView.h>
#import <AppKit/NSSplitViewItem.h>
#import <AppKit/NSView.h>

@implementation NSSplitViewController

- (void) dealloc {
    [_splitViewItems release];
    [_splitView setDelegate: nil];
    [_splitView release];
    [super dealloc];
}

- (NSSplitView *) splitView {
    if (_splitView == nil) {
        NSSplitView *splitView = [[NSSplitView alloc] initWithFrame: NSMakeRect(0, 0, 400, 400)];
        [splitView setVertical: YES];
        [splitView setDelegate: self];
        _splitView = splitView;
    }
    return _splitView;
}

- (void) setSplitView: (NSSplitView *) splitView {
    if (splitView == _splitView) {
        return;
    }
    [_splitView setDelegate: nil];
    [splitView retain];
    [_splitView release];
    _splitView = splitView;
    [_splitView setDelegate: self];
}

- (NSArray *) splitViewItems {
    if (_splitViewItems == nil) {
        _splitViewItems = [[NSMutableArray alloc] init];
    }
    return [NSArray arrayWithArray: _splitViewItems];
}

- (void) setSplitViewItems: (NSArray *) splitViewItems {
    for (NSSplitViewItem *item in [self splitViewItems]) {
        [self removeSplitViewItem: item];
    }
    for (NSSplitViewItem *item in splitViewItems) {
        [self addSplitViewItem: item];
    }
}

- (void) addSplitViewItem: (NSSplitViewItem *) splitViewItem {
    [self insertSplitViewItem: splitViewItem
                      atIndex: [[self splitViewItems] count]];
}

- (void) insertSplitViewItem: (NSSplitViewItem *) splitViewItem
                     atIndex: (NSInteger) index
{
    if (splitViewItem == nil) {
        return;
    }
    [self splitViewItems]; // ensure the array exists
    if (index < 0 || index > (NSInteger)[_splitViewItems count]) {
        index = [_splitViewItems count];
    }
    [_splitViewItems insertObject: splitViewItem atIndex: index];
    NSView *view = [[splitViewItem viewController] view];
    if (view != nil) {
        [[self splitView] insertArrangedSubview: view atIndex: index];
        [view setHidden: [splitViewItem isCollapsed]];
    }
}

- (void) removeSplitViewItem: (NSSplitViewItem *) splitViewItem {
    if (splitViewItem == nil || ![_splitViewItems containsObject: splitViewItem])
    {
        return;
    }
    NSView *view = [[splitViewItem viewController] view];
    if (view != nil) {
        [[self splitView] removeArrangedSubview: view];
        [view removeFromSuperview];
    }
    [_splitViewItems removeObject: splitViewItem];
}

- (void) viewDidLoad {
    /* The split view is the controller's view; item views are added to it as
       items are inserted. */
}

- (void) loadView {
    if ([self nibName] != nil) {
        [super loadView];
    } else {
        [self setView: [self splitView]];
    }
}

- (NSSplitViewItem *) _itemForSubview: (NSView *) subview {
    for (NSSplitViewItem *item in _splitViewItems) {
        if ([[item viewController] view] == subview) {
            return item;
        }
    }
    return nil;
}

- (BOOL) splitView: (NSSplitView *) splitView
        canCollapseSubview: (NSView *) subview
{
    return [[self _itemForSubview: subview] canCollapse];
}

- (BOOL) splitView: (NSSplitView *) splitView
                 shouldCollapseSubview: (NSView *) subview
        forDoubleClickOnDividerAtIndex: (NSInteger) index
{
    NSSplitViewItem *item = [self _itemForSubview: subview];
    return [item canCollapse] &&
           [item behavior] == NSSplitViewItemBehaviorSidebar;
}

- (BOOL) splitView: (NSSplitView *) splitView
        shouldHideDividerAtIndex: (NSInteger) index
{
    return NO;
}

- (NSRect) splitView: (NSSplitView *) splitView
           effectiveRect: (NSRect) proposedEffectiveRect
            forDrawnRect: (NSRect) drawnRect
        ofDividerAtIndex: (NSInteger) index
{
    return proposedEffectiveRect;
}

- (NSRect) splitView: (NSSplitView *) splitView
        additionalEffectiveRectOfDividerAtIndex: (NSInteger) index
{
    return NSZeroRect;
}

- (BOOL) validateUserInterfaceItem: (id<NSValidatedUserInterfaceItem>) item {
    if ([item action] == @selector(toggleSidebar:)) {
        for (NSSplitViewItem *splitItem in _splitViewItems) {
            if ([splitItem behavior] == NSSplitViewItemBehaviorSidebar &&
                [splitItem canCollapse]) {
                return YES;
            }
        }
        return NO;
    }
    return [super respondsToSelector: [item action]];
}

- (void) toggleSidebar: (id) sender {
    for (NSSplitViewItem *splitItem in _splitViewItems) {
        if ([splitItem behavior] == NSSplitViewItemBehaviorSidebar &&
            [splitItem canCollapse]) {
            [splitItem setCollapsed: ![splitItem isCollapsed]];
            [[self splitView] adjustSubviews];
            return;
        }
    }
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
