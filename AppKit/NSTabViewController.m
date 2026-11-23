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


#import <AppKit/NSTabViewController.h>
#import <AppKit/NSTabViewItem.h>
#import <AppKit/NSToolbar.h>
#import <AppKit/NSToolbarItem.h>

@implementation NSTabViewController

- (void) dealloc {
    [_controllerTabView setDelegate: nil];
    [_controllerTabView release];
    [_controllerTabViewItems release];
    [super dealloc];
}

- (NSTabView *) tabView {
    if (_controllerTabView == nil) {
        NSTabView *tabView = [[NSTabView alloc] initWithFrame: NSMakeRect(0, 0, 100, 100)];
        [self setTabView: tabView];
        [tabView release];
    }
    return _controllerTabView;
}

- (void) setTabView: (NSTabView *) tabView {
    if (tabView == _controllerTabView)
        return;
    [_controllerTabView setDelegate: nil];
    [tabView retain];
    [_controllerTabView release];
    _controllerTabView = tabView;
    [_controllerTabView setDelegate: self];

    // Populate the new tab view from our items.
    for (NSTabViewItem *item in _controllerTabViewItems) {
        if ([_controllerTabView indexOfTabViewItem: item] == NSNotFound)
            [_controllerTabView addTabViewItem: item];
    }
}

- (NSUInteger) transitionOptions {
    return _controllerTransitionOptions;
}

- (void) setTransitionOptions: (NSUInteger) options {
    _controllerTransitionOptions = options;
}

- (BOOL) canPropagateSelectedChildViewControllerTitle {
    return _controllerCanPropagateTitle;
}

- (void) setCanPropagateSelectedChildViewControllerTitle: (BOOL) flag {
    _controllerCanPropagateTitle = flag;
}

- (NSArray *) tabViewItems {
    if (_controllerTabViewItems == nil)
        _controllerTabViewItems = [NSMutableArray new];
    return [[_controllerTabViewItems copy] autorelease];
}

- (void) setTabViewItems: (NSArray *) items {
    NSArray *old = [self tabViewItems];
    NSTabViewItem *item;

    for (item in old)
        [self removeTabViewItem: item];
    for (item in items)
        [self addTabViewItem: item];
}

- (NSInteger) selectedTabViewItemIndex {
    NSTabViewItem *selected = [_controllerTabView selectedTabViewItem];
    if (selected == nil)
        return -1;
    return [_controllerTabViewItems indexOfObject: selected];
}

- (void) setSelectedTabViewItemIndex: (NSInteger) index {
    if (index < 0 || index >= (NSInteger)[_controllerTabViewItems count])
        return;
    [[self tabView] selectTabViewItemAtIndex: index];
}

- (void) addTabViewItem: (NSTabViewItem *) tabViewItem {
    [self insertTabViewItem: tabViewItem
                    atIndex: [[self tabViewItems] count]];
}

- (void) insertTabViewItem: (NSTabViewItem *) tabViewItem atIndex: (NSInteger) index {
    if (tabViewItem == nil)
        return;
    [self tabViewItems];
    if (index < 0 || index > (NSInteger)[_controllerTabViewItems count])
        index = [_controllerTabViewItems count];
    [_controllerTabViewItems insertObject: tabViewItem atIndex: index];
    [[self tabView] insertTabViewItem: tabViewItem atIndex: index];
}

- (void) removeTabViewItem: (NSTabViewItem *) tabViewItem {
    if (tabViewItem == nil || ![_controllerTabViewItems containsObject: tabViewItem])
        return;
    [tabViewItem retain];
    [_controllerTabViewItems removeObject: tabViewItem];
    if ([_controllerTabView indexOfTabViewItem: tabViewItem] != NSNotFound)
        [_controllerTabView removeTabViewItem: tabViewItem];
    [tabViewItem release];
}

- (void) loadView {
    [self setView: [self tabView]];
}

- (void) viewDidLoad {
    // Make sure the tab view exists and is wired to us.
    [self tabView];
}

- (void) tabView: (NSTabView *) tabView willSelectTabViewItem: (NSTabViewItem *) tabViewItem {
}

- (void) tabView: (NSTabView *) tabView didSelectTabViewItem: (NSTabViewItem *) tabViewItem {
    if (_controllerCanPropagateTitle && [tabViewItem label] != nil)
        [self setTitle: [tabViewItem label]];
}

- (BOOL) tabView: (NSTabView *) tabView shouldSelectTabViewItem: (NSTabViewItem *) tabViewItem {
    return YES;
}

- (NSString *) _identifierStringForItem: (NSTabViewItem *) item {
    id identifier = [item identifier];
    if ([identifier isKindOfClass: [NSString class]])
        return identifier;
    return [NSString stringWithFormat: @"%p", item];
}

- (NSToolbarItem *) toolbar: (NSToolbar *) toolbar
        itemForItemIdentifier: (NSString *) itemIdentifier
    willBeInsertedIntoToolbar: (BOOL) flag {
    for (NSTabViewItem *item in [self tabViewItems]) {
        if ([[self _identifierStringForItem: item] isEqualToString: itemIdentifier]) {
            NSToolbarItem *result = [[[NSToolbarItem alloc]
                    initWithItemIdentifier: itemIdentifier] autorelease];
            [result setLabel: [item label]];
            [result setImage: [item image]];
            [result setToolTip: [item toolTip]];
            return result;
        }
    }
    return nil;
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar {
    NSMutableArray *result = [NSMutableArray array];
    for (NSTabViewItem *item in [self tabViewItems])
        [result addObject: [self _identifierStringForItem: item]];
    return result;
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar {
    return [self toolbarDefaultItemIdentifiers: toolbar];
}

- (NSArray *) toolbarSelectableItemIdentifiers: (NSToolbar *) toolbar {
    return [self toolbarDefaultItemIdentifiers: toolbar];
}

@end
