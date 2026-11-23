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

#import <AppKit/NSWindowTabGroup.h>
#import <AppKit/NSWindow.h>

@implementation NSWindowTabGroup

@synthesize overviewVisible = _overviewVisible;

- (instancetype)init
{
    return [self initWithIdentifier:@""];
}

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    if ((self = [super init]) != nil) {
        _identifier = [(identifier != nil ? identifier : @"") copy];
        _windows = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_identifier release];
    [_windows release];
    _selectedWindow = nil;
    [super dealloc];
}

- (NSString *)identifier
{
    return _identifier;
}

- (NSArray *)windows
{
    return [[_windows copy] autorelease];
}

- (NSWindow *)selectedWindow
{
    return _selectedWindow;
}

- (void)setSelectedWindow:(NSWindow *)window
{
    if (window != nil && ![_windows containsObject:window]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"-[NSWindowTabGroup setSelectedWindow:]: window is not in the tab group"];
    }
    if (window == _selectedWindow)
        return;
    [self willChangeValueForKey:@"selectedWindow"];
    _selectedWindow = window;
    [self didChangeValueForKey:@"selectedWindow"];
}

- (BOOL)isTabBarVisible
{
    return [_windows count] > 1;
}

- (void)addWindow:(NSWindow *)window
{
    [self insertWindow:window atIndex:[_windows count]];
}

- (void)insertWindow:(NSWindow *)window atIndex:(NSInteger)index
{
    if (window == nil)
        return;
    NSWindowTabGroup *oldGroup = [window respondsToSelector:@selector(tabGroup)] ? [window performSelector:@selector(tabGroup)] : nil;
    if (oldGroup != nil && oldGroup != self)
        [oldGroup removeWindow:window];

    [self willChangeValueForKey:@"windows"];
    NSUInteger existing = [_windows indexOfObjectIdenticalTo:window];
    if (existing != NSNotFound) {
        [window retain];
        [_windows removeObjectAtIndex:existing];
        if ((NSUInteger)index > existing && index > 0)
            index--;
    } else {
        [window retain];
    }
    if (index < 0 || (NSUInteger)index > [_windows count])
        index = [_windows count];
    [_windows insertObject:window atIndex:index];
    [window release];
    [self didChangeValueForKey:@"windows"];

    if (_selectedWindow == nil)
        [self setSelectedWindow:window];
}

- (void)removeWindow:(NSWindow *)window
{
    NSUInteger index = [_windows indexOfObjectIdenticalTo:window];
    if (index == NSNotFound)
        return;
    [self willChangeValueForKey:@"windows"];
    [_windows removeObjectAtIndex:index];
    [self didChangeValueForKey:@"windows"];
    if (_selectedWindow == window) {
        NSWindow *next = nil;
        if ([_windows count] > 0)
            next = [_windows objectAtIndex:MIN(index, [_windows count] - 1)];
        [self setSelectedWindow:next];
    }
}

@end
