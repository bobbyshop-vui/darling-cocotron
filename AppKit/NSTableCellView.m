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

#import <AppKit/NSTableCellView.h>
#import <AppKit/NSTextField.h>
#import <AppKit/NSImageView.h>

@implementation NSTableCellView

- (void) dealloc {
    [_cellObjectValue release];
    [super dealloc];
}

- (id) objectValue {
    return _cellObjectValue;
}

- (void) setObjectValue: (id) value {
    value = [value retain];
    [_cellObjectValue release];
    _cellObjectValue = value;
}

// text field and image view are weak (assign) references
- (NSTextField *) textField {
    return _cellTextField;
}

- (void) setTextField: (NSTextField *) textField {
    _cellTextField = textField;
}

- (NSImageView *) imageView {
    return _cellImageView;
}

- (void) setImageView: (NSImageView *) imageView {
    _cellImageView = imageView;
}

- (NSBackgroundStyle) backgroundStyle {
    return _cellBackgroundStyle;
}

- (void) setBackgroundStyle: (NSBackgroundStyle) style {
    _cellBackgroundStyle = style;
    [[_cellTextField cell] setBackgroundStyle: style];
    [self setNeedsDisplay: YES];
}

- (NSTableViewRowSizeStyle) rowSizeStyle {
    return _cellRowSizeStyle;
}

- (void) setRowSizeStyle: (NSTableViewRowSizeStyle) style {
    _cellRowSizeStyle = style;
}

@end
