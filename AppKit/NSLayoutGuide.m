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

#define NSLAYOUTGUIDE_LAZY_ANCHOR(name, ivar, cls)                             \
    - (cls *) name {                                                           \
        if (ivar == nil)                                                       \
            ivar = [[cls alloc] init];                                         \
        return ivar;                                                           \
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
    [_leadingAnchor release];
    [_trailingAnchor release];
    [_leftAnchor release];
    [_rightAnchor release];
    [_topAnchor release];
    [_bottomAnchor release];
    [_centerXAnchor release];
    [_centerYAnchor release];
    [_widthAnchor release];
    [_heightAnchor release];
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

NSLAYOUTGUIDE_LAZY_ANCHOR(leadingAnchor, _leadingAnchor, NSLayoutAnchor)
NSLAYOUTGUIDE_LAZY_ANCHOR(trailingAnchor, _trailingAnchor, NSLayoutAnchor)
NSLAYOUTGUIDE_LAZY_ANCHOR(leftAnchor, _leftAnchor, NSLayoutAnchor)
NSLAYOUTGUIDE_LAZY_ANCHOR(rightAnchor, _rightAnchor, NSLayoutAnchor)
NSLAYOUTGUIDE_LAZY_ANCHOR(topAnchor, _topAnchor, NSLayoutAnchor)
NSLAYOUTGUIDE_LAZY_ANCHOR(bottomAnchor, _bottomAnchor, NSLayoutAnchor)
NSLAYOUTGUIDE_LAZY_ANCHOR(centerXAnchor, _centerXAnchor, NSLayoutAnchor)
NSLAYOUTGUIDE_LAZY_ANCHOR(centerYAnchor, _centerYAnchor, NSLayoutAnchor)
NSLAYOUTGUIDE_LAZY_ANCHOR(widthAnchor, _widthAnchor, NSLayoutDimension)
NSLAYOUTGUIDE_LAZY_ANCHOR(heightAnchor, _heightAnchor, NSLayoutDimension)

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
