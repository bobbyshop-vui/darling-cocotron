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

#import <AppKit/NSLayoutConstraint.h>

@class NSViewController;

typedef NS_ENUM(NSInteger, NSSplitViewItemBehavior) {
    NSSplitViewItemBehaviorDefault,
    NSSplitViewItemBehaviorSidebar,
    NSSplitViewItemBehaviorContentList,
};

@interface NSSplitViewItem : NSObject <NSCoding> {
    NSViewController *_viewController;
    NSSplitViewItemBehavior _behavior;
    BOOL _canCollapse;
    BOOL _collapsed;
    BOOL _springLoaded;
    NSLayoutPriority _holdingPriority;
}

+ (instancetype) splitViewItemWithViewController:
        (NSViewController *) viewController;
+ (instancetype) sidebarWithViewController: (NSViewController *) viewController;
+ (instancetype) contentListWithViewController:
        (NSViewController *) viewController;

- (NSSplitViewItemBehavior) behavior;
- (NSViewController *) viewController;
- (void) setViewController: (NSViewController *) viewController;
- (BOOL) canCollapse;
- (void) setCanCollapse: (BOOL) canCollapse;
- (BOOL) isCollapsed;
- (void) setCollapsed: (BOOL) collapsed;
- (NSLayoutPriority) holdingPriority;
- (void) setHoldingPriority: (NSLayoutPriority) holdingPriority;
- (BOOL) isSpringLoaded;
- (void) setSpringLoaded: (BOOL) springLoaded;

@end
