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

#import <AppKit/NSDraggingItem.h>
#import <Foundation/Foundation.h>

NSDraggingImageComponentKey const NSDraggingImageComponentIconKey = @"icon";
NSDraggingImageComponentKey const NSDraggingImageComponentLabelKey = @"label";

@implementation NSDraggingImageComponent


- (instancetype)initWithKey:(NSDraggingImageComponentKey)key
{
    if ((self = [super init])) {
        _key = [key copy];
    }
    return self;
}

- (void)dealloc
{
    [_key release];
    [_contents release];
    [super dealloc];
}

- (NSDraggingImageComponentKey)key
{
    return _key;
}

- (void)setKey:(NSDraggingImageComponentKey)key
{
    if (_key != key) {
        [_key release];
        _key = [key copy];
    }
}

- (id)contents
{
    return _contents;
}

- (void)setContents:(id)contents
{
    if (_contents != contents) {
        [_contents release];
        _contents = [contents retain];
    }
}

- (NSRect)frame
{
    return _frame;
}

- (void)setFrame:(NSRect)frame
{
    _frame = frame;
}


@end

@implementation NSDraggingItem


- (instancetype)initWithPasteboardWriter:(id<NSPasteboardWriting>)pasteboardWriter
{
    if ((self = [super init])) {
        _item = [(id)pasteboardWriter retain];
        _draggingFrame = NSZeroRect;
    }
    return self;
}

- (void)dealloc
{
    [_item release];
    [_imageComponents release];
    [_imageComponentsProvider release];
    [super dealloc];
}

- (id)item
{
    return _item;
}

- (NSRect)draggingFrame
{
    return _draggingFrame;
}

- (void)setDraggingFrame:(NSRect)frame
{
    _draggingFrame = frame;
}

- (void)setDraggingFrame:(NSRect)frame contents:(id)contents
{
    _draggingFrame = frame;

    NSDraggingImageComponent *component = [[NSDraggingImageComponent alloc]
        initWithKey:NSDraggingImageComponentIconKey];
    [component setContents:contents];
    [component setFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
    [_imageComponents release];
    _imageComponents = [[NSArray alloc] initWithObjects:component, nil];
    [component release];
}

- (NSArray *)imageComponents
{
    if (_imageComponents == nil && _imageComponentsProvider != nil)
        return _imageComponentsProvider();
    return _imageComponents;
}


@end
