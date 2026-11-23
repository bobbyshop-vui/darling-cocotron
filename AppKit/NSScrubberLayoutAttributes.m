/*
 This file is part of Darling.

 Copyright (C) 2025 Darling Developers

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

#import <AppKit/NSScrubberLayoutAttributes.h>

@implementation NSScrubberLayoutAttributes

@synthesize itemIndex = _itemIndex;
@synthesize frame = _frame;
@synthesize alpha = _alpha;

+ (instancetype)layoutAttributesForItemAtIndex:(NSInteger)index
{
    NSScrubberLayoutAttributes *attributes = [[[self alloc] init] autorelease];
    attributes->_itemIndex = index;
    return attributes;
}

- (instancetype)init
{
    if ((self = [super init]) != nil) {
        _itemIndex = 0;
        _frame = NSZeroRect;
        _alpha = 1.0;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    NSScrubberLayoutAttributes *copy = [[[self class] allocWithZone:zone] init];
    copy->_itemIndex = _itemIndex;
    copy->_frame = _frame;
    copy->_alpha = _alpha;
    return copy;
}

- (BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    if (![object isKindOfClass:[NSScrubberLayoutAttributes class]])
        return NO;
    NSScrubberLayoutAttributes *other = object;
    return _itemIndex == other->_itemIndex && NSEqualRects(_frame, other->_frame) && _alpha == other->_alpha;
}

- (NSUInteger)hash
{
    return (NSUInteger)_itemIndex ^ (NSUInteger)(_frame.origin.x + _frame.origin.y * 31.0) ^ (NSUInteger)(_frame.size.width + _frame.size.height * 17.0);
}

- (CGFloat)alpha
{
    return _alpha;
}

- (NSRect)frame
{
    return _frame;
}

- (void)setAlpha:(CGFloat)alpha
{
    _alpha = alpha;
}

- (void)setFrame:(NSRect)frame
{
    _frame = frame;
}

@end
