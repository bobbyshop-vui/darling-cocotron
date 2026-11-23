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

#import <AppKit/NSGroupTouchBarItem.h>
#import <AppKit/NSTouchBar.h>

@implementation NSGroupTouchBarItem


+ (instancetype)groupItemWithIdentifier:(NSTouchBarItemIdentifier)identifier items:(NSArray *)items
{
    NSGroupTouchBarItem *item = [[[self alloc] initWithIdentifier:identifier] autorelease];
    NSTouchBar *bar = [[[NSTouchBar alloc] init] autorelease];
    item->_groupItems = [items copy];
    [item setGroupTouchBar:bar];
    return item;
}

- (instancetype)initWithIdentifier:(NSTouchBarItemIdentifier)identifier
{
    if ((self = [super initWithIdentifier:identifier])) {
        _customizationLabel = [@"" copy];
        _groupUserInterfaceLayoutDirection = NSUserInterfaceLayoutDirectionLeftToRight;
        _groupTouchBar = [[NSTouchBar alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_groupItems release];
    [_groupTouchBar release];
    [_customizationLabel release];
    [super dealloc];
}

- (NSTouchBar *)groupTouchBar
{
    return _groupTouchBar;
}

- (void)setGroupTouchBar:(NSTouchBar *)groupTouchBar
{
    if (_groupTouchBar != groupTouchBar) {
        [_groupTouchBar release];
        _groupTouchBar = [groupTouchBar retain];
    }
}

- (NSString *)customizationLabel
{
    return _customizationLabel;
}

- (void)setCustomizationLabel:(NSString *)label
{
    NSString *newLabel = [(label ? label : @"") copy];
    [_customizationLabel release];
    _customizationLabel = newLabel;
}

- (NSUserInterfaceLayoutDirection)groupUserInterfaceLayoutDirection
{
    return _groupUserInterfaceLayoutDirection;
}

- (void)setGroupUserInterfaceLayoutDirection:(NSUserInterfaceLayoutDirection)direction
{
    _groupUserInterfaceLayoutDirection = direction;
}


@end
