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

- (NSWindow *)_windowAtIndex:(NSUInteger)index
{
    return [[_windows objectAtIndex:index] nonretainedObjectValue];
}

- (NSUInteger)_indexOfWindow:(NSWindow *)window
{
    NSUInteger i, count = [_windows count];
    for (i = 0; i < count; i++) {
        if ([self _windowAtIndex:i] == window)
            return i;
    }
    return NSNotFound;
}

- (NSArray *)windows
{
    NSMutableArray *result = [NSMutableArray array];
    NSUInteger i, count = [_windows count];
    for (i = 0; i < count; i++)
        [result addObject:[self _windowAtIndex:i]];
    return result;
}

- (NSWindow *)selectedWindow
{
    return _selectedWindow;
}

- (void)setSelectedWindow:(NSWindow *)window
{
    if (window != nil && [self _indexOfWindow:window] == NSNotFound) {
        [NSException raise:NSInvalidArgumentException
                    format:@"-[NSWindowTabGroup setSelectedWindow:]: window is not in the tab group"];
    }
    if (window == _selectedWindow)
        return;
    NSWindow *old = _selectedWindow;
    [self willChangeValueForKey:@"selectedWindow"];
    _selectedWindow = window;
    [self didChangeValueForKey:@"selectedWindow"];

    // Without a tab bar, tabs are shown by sharing one frame and ordering
    // only the selected window in.
    if (old != nil && window != nil && [old isVisible]) {
        [window setFrame:[old frame] display:NO];
        [window makeKeyAndOrderFront:nil];
        [old orderOut:nil];
    }
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
    NSWindowTabGroup *oldGroup = [window tabGroup];
    if (oldGroup != nil && oldGroup != self)
        [oldGroup removeWindow:window];

    [self willChangeValueForKey:@"windows"];
    NSUInteger existing = [self _indexOfWindow:window];
    if (existing != NSNotFound) {
        [_windows removeObjectAtIndex:existing];
        if ((NSUInteger)index > existing && index > 0)
            index--;
    }
    if (index < 0 || (NSUInteger)index > [_windows count])
        index = [_windows count];
    [_windows insertObject:[NSValue valueWithNonretainedObject:window] atIndex:index];
    [self didChangeValueForKey:@"windows"];
    [window _setTabGroup:self];

    if (_selectedWindow == nil)
        [self setSelectedWindow:window];
}

- (void)removeWindow:(NSWindow *)window
{
    NSUInteger index = [self _indexOfWindow:window];
    if (index == NSNotFound)
        return;
    [self willChangeValueForKey:@"windows"];
    [_windows removeObjectAtIndex:index];
    [self didChangeValueForKey:@"windows"];
    if (_selectedWindow == window) {
        NSWindow *next = nil;
        if ([_windows count] > 0)
            next = [self _windowAtIndex:MIN(index, [_windows count] - 1)];
        if (next != nil && [window isVisible])
            [self setSelectedWindow:next];
        else {
            [self willChangeValueForKey:@"selectedWindow"];
            _selectedWindow = next;
            [self didChangeValueForKey:@"selectedWindow"];
        }
    }
    [window _setTabGroup:nil];
}

@end
