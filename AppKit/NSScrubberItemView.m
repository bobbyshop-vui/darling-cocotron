/*
 * This file is part of Darling.
 *
 * Copyright (C) 2024 Darling Developers
 *
 * Darling is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Darling is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Darling.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <AppKit/NSScrubberItemView.h>
#import <AppKit/NSScrubberLayoutAttributes.h>
#import <AppKit/NSText.h>
#import <AppKit/NSTextField.h>

@implementation NSScrubberArrangedView

- (BOOL) isSelected {
    return _selected;
}

- (void) setSelected: (BOOL) flag {
    if (_selected == flag)
        return;
    _selected = flag;
    [self setNeedsDisplay: YES];
}

- (BOOL) isHighlighted {
    return _highlighted;
}

- (void) setHighlighted: (BOOL) flag {
    if (_highlighted == flag)
        return;
    _highlighted = flag;
    [self setNeedsDisplay: YES];
}

- (void) applyLayoutAttributes: (NSScrubberLayoutAttributes *) layoutAttributes {
    if (layoutAttributes == nil)
        return;
    [self setFrame: [layoutAttributes frame]];
    [self setAlphaValue: [layoutAttributes alpha]];
}

@end

@implementation NSScrubberItemView
@end

@implementation NSScrubberTextItemView

- (void) dealloc {
    [_textField release];
    [super dealloc];
}

- (NSTextField *) textField {
    if (_textField == nil) {
        _textField = [[NSTextField alloc] initWithFrame: [self bounds]];
        [_textField setEditable: NO];
        [_textField setSelectable: NO];
        [_textField setBezeled: NO];
        [_textField setBordered: NO];
        [_textField setDrawsBackground: NO];
        [_textField setAlignment: NSCenterTextAlignment];
        [_textField setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
        [self addSubview: _textField];
    }
    return _textField;
}

- (NSString *) title {
    return [[self textField] stringValue];
}

- (void) setTitle: (NSString *) title {
    [[self textField] setStringValue: title ? title : @""];
}

@end
