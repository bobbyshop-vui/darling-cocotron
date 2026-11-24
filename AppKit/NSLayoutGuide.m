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

#import <AppKit/NSLayoutGuide.h>
#import <Foundation/NSLayoutConstraint.h>

@interface NSLayoutAnchor (NSLayoutGuideAnchorInternal)
- (instancetype) initWithItem: (id) item
                    attribute: (NSLayoutAttribute) attribute
                         name: (NSString *) name;
@end

// Anchors retain their item, so they are created on demand instead of being
// cached in ivars, which would make a retain cycle with the guide.
#define NSLAYOUTGUIDE_ANCHOR(getter, cls, attr)                                  \
    - (cls *) getter {                                                          \
        return [[[cls alloc] initWithItem: self                                \
                                attribute: attr                                \
                                     name: nil] autorelease];                  \
    }

@implementation NSLayoutGuide

- (instancetype) initWithCoder: (NSCoder *) coder {
    if ((self = [super init]) != nil) {
        if ([coder allowsKeyedCoding])
            _identifier = [[coder decodeObjectForKey: @"NSLayoutGuideIdentifier"]
                    copy];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder {
    if ([coder allowsKeyedCoding] && _identifier != nil)
        [coder encodeObject: _identifier forKey: @"NSLayoutGuideIdentifier"];
}

- (void) dealloc {
    [_identifier release];
    [super dealloc];
}

- (NSString *) identifier {
    return _identifier;
}

- (void) setIdentifier: (NSString *) identifier {
    identifier = [identifier copy];
    [_identifier release];
    _identifier = identifier;
}

NSLAYOUTGUIDE_ANCHOR(leadingAnchor, NSLayoutAnchor, NSLayoutAttributeLeading)
NSLAYOUTGUIDE_ANCHOR(trailingAnchor, NSLayoutAnchor, NSLayoutAttributeTrailing)
NSLAYOUTGUIDE_ANCHOR(leftAnchor, NSLayoutAnchor, NSLayoutAttributeLeft)
NSLAYOUTGUIDE_ANCHOR(rightAnchor, NSLayoutAnchor, NSLayoutAttributeRight)
NSLAYOUTGUIDE_ANCHOR(topAnchor, NSLayoutAnchor, NSLayoutAttributeTop)
NSLAYOUTGUIDE_ANCHOR(bottomAnchor, NSLayoutAnchor, NSLayoutAttributeBottom)
NSLAYOUTGUIDE_ANCHOR(centerXAnchor, NSLayoutAnchor, NSLayoutAttributeCenterX)
NSLAYOUTGUIDE_ANCHOR(centerYAnchor, NSLayoutAnchor, NSLayoutAttributeCenterY)
NSLAYOUTGUIDE_ANCHOR(widthAnchor, NSLayoutDimension, NSLayoutAttributeWidth)
NSLAYOUTGUIDE_ANCHOR(heightAnchor, NSLayoutDimension, NSLayoutAttributeHeight)

#undef NSLAYOUTGUIDE_ANCHOR

- (NSView *) owningView {
    return _owningView;
}

- (void) setOwningView: (NSView *) view {
    _owningView = view; // weak, like AppKit
}

- (NSRect) frame {
    return _frame;
}

- (void) _setFrame: (NSRect) frame {
    _frame = frame;
}

- (BOOL) hasAmbiguousLayout {
    // There is no constraint solver, so layout is never ambiguous.
    return NO;
}

- (NSArray *) constraintsAffectingLayoutForOrientation:
        (NSLayoutConstraintOrientation) orientation
{
    // No constraint is known to affect the layout without a solver.
    return [NSArray array];
}

@end
