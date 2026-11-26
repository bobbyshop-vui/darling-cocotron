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

#import <QuartzCore/CAScrollLayer.h>

NSString *const kCAScrollNone = @"none";
NSString *const kCAScrollVertically = @"vertically";
NSString *const kCAScrollHorizontally = @"horizontally";
NSString *const kCAScrollBoth = @"both";

@implementation CAScrollLayer

@dynamic scrollMode;

+ (id) defaultValueForKey: (NSString *) key {
    if ([key isEqualToString: @"scrollMode"])
        return kCAScrollBoth;
    return [super defaultValueForKey: key];
}

// Scrolling moves the bounds origin along the axes scrollMode allows.
- (void) scrollToPoint: (CGPoint) point {
    NSString *mode = [self scrollMode];
    CGRect bounds = [self bounds];
    if ([mode isEqualToString: kCAScrollBoth] ||
        [mode isEqualToString: kCAScrollHorizontally])
        bounds.origin.x = point.x;
    if ([mode isEqualToString: kCAScrollBoth] ||
        [mode isEqualToString: kCAScrollVertically])
        bounds.origin.y = point.y;
    [self setBounds: bounds];
}

- (void) scrollToRect: (CGRect) rect {
    CGRect bounds = [self bounds];
    CGPoint origin = bounds.origin;
    if (CGRectGetMinX(rect) < CGRectGetMinX(bounds))
        origin.x = CGRectGetMinX(rect);
    else if (CGRectGetMaxX(rect) > CGRectGetMaxX(bounds))
        origin.x = CGRectGetMaxX(rect) - bounds.size.width;
    if (CGRectGetMinY(rect) < CGRectGetMinY(bounds))
        origin.y = CGRectGetMinY(rect);
    else if (CGRectGetMaxY(rect) > CGRectGetMaxY(bounds))
        origin.y = CGRectGetMaxY(rect) - bounds.size.height;
    [self scrollToPoint: origin];
}

@end
