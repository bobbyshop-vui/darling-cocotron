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
#import <AppKit/NSViewController.h>
#import <AppKit/NSTabView.h>

@class NSTabViewItem, NSToolbar, NSToolbarItem;

@interface NSTabViewController : NSViewController <NSTabViewDelegate> {
    NSTabView *_controllerTabView;
    NSMutableArray *_controllerTabViewItems;
    NSUInteger _controllerTransitionOptions;
    BOOL _controllerCanPropagateTitle;
}
- (NSTabView *) tabView;
- (void) setTabView: (NSTabView *) tabView;
- (NSUInteger) transitionOptions;
- (void) setTransitionOptions: (NSUInteger) options;
- (BOOL) canPropagateSelectedChildViewControllerTitle;
- (void) setCanPropagateSelectedChildViewControllerTitle: (BOOL) flag;
- (NSArray *) tabViewItems;
- (void) setTabViewItems: (NSArray *) items;
- (NSInteger) selectedTabViewItemIndex;
- (void) setSelectedTabViewItemIndex: (NSInteger) index;
- (void) addTabViewItem: (NSTabViewItem *) tabViewItem;
- (void) insertTabViewItem: (NSTabViewItem *) tabViewItem atIndex: (NSInteger) index;
- (void) removeTabViewItem: (NSTabViewItem *) tabViewItem;
- (void) viewDidLoad;
- (void) tabView: (NSTabView *) tabView willSelectTabViewItem: (NSTabViewItem *) tabViewItem;
- (void) tabView: (NSTabView *) tabView didSelectTabViewItem: (NSTabViewItem *) tabViewItem;
- (BOOL) tabView: (NSTabView *) tabView shouldSelectTabViewItem: (NSTabViewItem *) tabViewItem;
- (NSToolbarItem *) toolbar: (NSToolbar *) toolbar
        itemForItemIdentifier: (NSString *) itemIdentifier
    willBeInsertedIntoToolbar: (BOOL) flag;
- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar;
- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar;
- (NSArray *) toolbarSelectableItemIdentifiers: (NSToolbar *) toolbar;
@end
