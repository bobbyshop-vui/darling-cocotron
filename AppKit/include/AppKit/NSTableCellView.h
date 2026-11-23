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

@class NSTextField, NSImageView;

@interface NSTableCellView : NSView {
    id _cellObjectValue;
    NSTextField *_cellTextField;
    NSImageView *_cellImageView;
    NSBackgroundStyle _cellBackgroundStyle;
    NSTableViewRowSizeStyle _cellRowSizeStyle;
}
- (id) objectValue;
- (void) setObjectValue: (id) value;
- (NSTextField *) textField;
- (void) setTextField: (NSTextField *) textField;
- (NSImageView *) imageView;
- (void) setImageView: (NSImageView *) imageView;
- (NSBackgroundStyle) backgroundStyle;
- (void) setBackgroundStyle: (NSBackgroundStyle) style;
- (NSTableViewRowSizeStyle) rowSizeStyle;
- (void) setRowSizeStyle: (NSTableViewRowSizeStyle) style;
@end
