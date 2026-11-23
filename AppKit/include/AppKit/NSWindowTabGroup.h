/*
 This file is part of Darling.

 Copyright (C) 2025 Darling Developers

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

#import <Foundation/Foundation.h>
#import <AppKit/AppKitExport.h>

@class NSWindow;

@interface NSWindowTabGroup : NSObject {
    NSString *_identifier;
    NSMutableArray *_windows;
    NSWindow *_selectedWindow;
    BOOL _overviewVisible;
}

@property(readonly, copy) NSString *identifier;
@property(readonly, copy) NSArray *windows;
@property(getter = isOverviewVisible) BOOL overviewVisible;
@property(readonly, getter = isTabBarVisible) BOOL tabBarVisible;
@property(assign) NSWindow *selectedWindow;

- (instancetype)initWithIdentifier:(NSString *)identifier;

- (NSString *)identifier;
- (NSArray *)windows;
- (NSWindow *)selectedWindow;
- (void)setSelectedWindow:(NSWindow *)window;
- (void)addWindow:(NSWindow *)window;
- (void)insertWindow:(NSWindow *)window atIndex:(NSInteger)index;
- (void)removeWindow:(NSWindow *)window;

@end
