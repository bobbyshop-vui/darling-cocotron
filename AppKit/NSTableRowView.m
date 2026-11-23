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

#import <AppKit/NSTableRowView.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSGraphics.h>

@implementation NSTableRowView

- (void) dealloc {
    [_rowBackgroundColor release];
    [super dealloc];
}

- (NSColor *) backgroundColor {
    return _rowBackgroundColor;
}

- (void) setBackgroundColor: (NSColor *) color {
    color = [color copy];
    [_rowBackgroundColor release];
    _rowBackgroundColor = color;
    [self setNeedsDisplay: YES];
}

- (BOOL) isSelected {
    return _rowSelected;
}

- (void) setSelected: (BOOL) flag {
    _rowSelected = flag;
    [self setNeedsDisplay: YES];
}

- (BOOL) isEmphasized {
    return _rowEmphasized;
}

- (void) setEmphasized: (BOOL) flag {
    _rowEmphasized = flag;
    [self setNeedsDisplay: YES];
}

- (BOOL) isGroupRowStyle {
    return _rowGroupRowStyle;
}

- (void) setGroupRowStyle: (BOOL) flag {
    _rowGroupRowStyle = flag;
    [self setNeedsDisplay: YES];
}

- (BOOL) isFloating {
    return _rowFloating;
}

- (void) setFloating: (BOOL) flag {
    _rowFloating = flag;
    [self setNeedsDisplay: YES];
}

- (void) setDraggingDestinationFeedbackStyle:
        (NSTableViewDraggingDestinationFeedbackStyle) style {
    _rowDraggingFeedbackStyle = style;
    [self setNeedsDisplay: YES];
}

- (NSTableViewDraggingDestinationFeedbackStyle) draggingDestinationFeedbackStyle {
    return _rowDraggingFeedbackStyle;
}

- (NSBackgroundStyle) interiorBackgroundStyle {
    if (_rowSelected && _rowEmphasized)
        return NSBackgroundStyleDark;
    return NSBackgroundStyleLight;
}

// One subview per column.
- (NSInteger) numberOfColumns {
    return [[self subviews] count];
}

- (void) drawSelectionInRect: (NSRect) dirtyRect {
    if (!_rowSelected)
        return;
    if (_rowEmphasized)
        [[NSColor selectedControlColor] setFill];
    else
        [[NSColor secondarySelectedControlColor] setFill];
    NSRectFill(NSIntersectionRect(dirtyRect, [self bounds]));
}

- (void) drawSeparatorInRect: (NSRect) dirtyRect {
    NSRect bounds = [self bounds];
    NSRect line = bounds;

    line.size.height = 1;
    if ([self isFlipped])
        line.origin.y = NSMaxY(bounds) - 1;
    line = NSIntersectionRect(line, dirtyRect);
    if (NSIsEmptyRect(line))
        return;
    [[NSColor separatorColor] setFill];
    NSRectFill(line);
}

@end
