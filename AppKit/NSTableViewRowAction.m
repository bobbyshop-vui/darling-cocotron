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

#import <AppKit/NSTableViewRowAction.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSImage.h>

@implementation NSTableViewRowAction

+ (instancetype) rowActionWithStyle: (NSTableViewRowActionStyle) style
                              title: (NSString *) title
                            handler: (void (^)(NSTableViewRowAction *action,
                                      NSInteger row)) handler
{
    NSTableViewRowAction *action = [[[self alloc] init] autorelease];
    action->_darlingStyle = style;
    action->_darlingTitle = [title copy];
    action->_darlingHandler = [handler copy];
    return action;
}

- (void) dealloc {
    [_darlingTitle release];
    [_darlingHandler release];
    [_darlingBackgroundColor release];
    [_darlingImage release];
    [super dealloc];
}

- (id) copyWithZone: (NSZone *) zone {
    NSTableViewRowAction *copy = [[[self class] allocWithZone: zone] init];
    copy->_darlingStyle = _darlingStyle;
    copy->_darlingTitle = [_darlingTitle copy];
    copy->_darlingHandler = [_darlingHandler copy];
    copy->_darlingBackgroundColor = [_darlingBackgroundColor copy];
    copy->_darlingImage = [_darlingImage retain];
    return copy;
}

- (NSTableViewRowActionStyle) style {
    return _darlingStyle;
}

- (NSString *) title {
    return _darlingTitle;
}

- (void) setTitle: (NSString *) title {
    title = [title copy];
    [_darlingTitle release];
    _darlingTitle = title;
}

- (NSColor *) backgroundColor {
    if (_darlingBackgroundColor != nil)
        return _darlingBackgroundColor;
    // Documented defaults: red for destructive actions, blue otherwise.
    if (_darlingStyle == NSTableViewRowActionStyleDestructive)
        return [NSColor redColor];
    return [NSColor blueColor];
}

- (void) setBackgroundColor: (NSColor *) color {
    color = [color copy];
    [_darlingBackgroundColor release];
    _darlingBackgroundColor = color;
}

- (NSImage *) image {
    return _darlingImage;
}

- (void) setImage: (NSImage *) image {
    image = [image retain];
    [_darlingImage release];
    _darlingImage = image;
}

@end
