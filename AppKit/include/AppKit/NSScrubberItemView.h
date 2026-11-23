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

#import <AppKit/NSView.h>

@class NSScrubberLayoutAttributes, NSTextField;

@interface NSScrubberArrangedView : NSView {
    BOOL _selected;
    BOOL _highlighted;
}

- (BOOL) isSelected;
- (void) setSelected: (BOOL) flag;
- (BOOL) isHighlighted;
- (void) setHighlighted: (BOOL) flag;
- (void) applyLayoutAttributes: (NSScrubberLayoutAttributes *) layoutAttributes;

@end

@interface NSScrubberItemView : NSScrubberArrangedView
@end

@interface NSScrubberTextItemView : NSScrubberItemView {
    NSTextField *_textField;
}

- (NSTextField *) textField;
- (NSString *) title;
- (void) setTitle: (NSString *) title;

@end
