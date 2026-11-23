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

#import <AppKit/NSTouchBarItem.h>
#import <AppKit/NSApplication.h>

@class NSTouchBar;

@interface NSGroupTouchBarItem : NSTouchBarItem {
    NSArray *_groupItems;
    NSTouchBar *_groupTouchBar;
    NSString *_customizationLabel;
    NSUserInterfaceLayoutDirection _groupUserInterfaceLayoutDirection;
}
+ (instancetype)groupItemWithIdentifier:(NSTouchBarItemIdentifier)identifier items:(NSArray *)items;
- (NSTouchBar *)groupTouchBar;
- (void)setGroupTouchBar:(NSTouchBar *)groupTouchBar;
- (NSString *)customizationLabel;
- (void)setCustomizationLabel:(NSString *)label;
- (NSUserInterfaceLayoutDirection)groupUserInterfaceLayoutDirection;
- (void)setGroupUserInterfaceLayoutDirection:(NSUserInterfaceLayoutDirection)direction;
@end
