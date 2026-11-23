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

#import <AppKit/NSView.h>
#import <AppKit/NSCell.h>
#import <AppKit/NSTableView.h>

@class NSColor;

@interface NSTableRowView : NSView {
    NSColor *_rowBackgroundColor;
    BOOL _rowSelected;
    BOOL _rowEmphasized;
    BOOL _rowGroupRowStyle;
    BOOL _rowFloating;
    NSTableViewDraggingDestinationFeedbackStyle _rowDraggingFeedbackStyle;
}
- (NSColor *) backgroundColor;
- (void) setBackgroundColor: (NSColor *) color;
- (BOOL) isSelected;
- (void) setSelected: (BOOL) flag;
- (BOOL) isEmphasized;
- (void) setEmphasized: (BOOL) flag;
- (BOOL) isGroupRowStyle;
- (void) setGroupRowStyle: (BOOL) flag;
- (BOOL) isFloating;
- (void) setFloating: (BOOL) flag;
- (void) setDraggingDestinationFeedbackStyle:
        (NSTableViewDraggingDestinationFeedbackStyle) style;
- (NSTableViewDraggingDestinationFeedbackStyle) draggingDestinationFeedbackStyle;
- (NSBackgroundStyle) interiorBackgroundStyle;
- (NSInteger) numberOfColumns;
- (void) drawSelectionInRect: (NSRect) dirtyRect;
- (void) drawSeparatorInRect: (NSRect) dirtyRect;
@end
