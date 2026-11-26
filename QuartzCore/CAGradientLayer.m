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

#import <QuartzCore/CAGradientLayer.h>

NSString *const kCAGradientLayerAxial = @"axial";
NSString *const kCAGradientLayerRadial = @"radial";
NSString *const kCAGradientLayerConic = @"conic";

@implementation CAGradientLayer

// Stored by CALayer's dynamic properties.
@dynamic colors, locations, startPoint, endPoint, type;

+ (id) defaultValueForKey: (NSString *) key {
    if ([key isEqualToString: @"startPoint"]) {
        CGPoint point = CGPointMake(0.5, 0.0);
        return [NSValue valueWithBytes: &point objCType: @encode(CGPoint)];
    }
    if ([key isEqualToString: @"endPoint"]) {
        CGPoint point = CGPointMake(0.5, 1.0);
        return [NSValue valueWithBytes: &point objCType: @encode(CGPoint)];
    }
    if ([key isEqualToString: @"type"])
        return kCAGradientLayerAxial;
    return [super defaultValueForKey: key];
}

+ (BOOL) needsDisplayForKey: (NSString *) key {
    return [key isEqualToString: @"colors"] ||
           [key isEqualToString: @"locations"] ||
           [key isEqualToString: @"startPoint"] ||
           [key isEqualToString: @"endPoint"] ||
           [key isEqualToString: @"type"] || [super needsDisplayForKey: key];
}

// Axial gradients only; start and end points are in the unit square.
- (void) drawInContext: (CGContextRef) context {
    NSArray *colors = [self colors];

    if ([colors count] > 0) {
        NSArray *locations = [self locations];
        NSUInteger count = [colors count];
        CGFloat stops[count];
        BOOL useLocations = [locations count] == count;
        for (NSUInteger i = 0; i < count; i++)
            stops[i] = useLocations ? [[locations objectAtIndex: i] doubleValue]
                                    : (count > 1 ? (CGFloat) i / (count - 1) : 0);

        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColors(
                space, (CFArrayRef) colors, stops);
        if (gradient != NULL) {
            CGRect bounds = [self bounds];
            CGPoint start = [self startPoint], end = [self endPoint];
            start = CGPointMake(bounds.origin.x + start.x * bounds.size.width,
                                bounds.origin.y + start.y * bounds.size.height);
            end = CGPointMake(bounds.origin.x + end.x * bounds.size.width,
                              bounds.origin.y + end.y * bounds.size.height);
            CGContextSaveGState(context);
            CGContextClipToRect(context, bounds);
            CGContextDrawLinearGradient(context, gradient, start, end,
                    kCGGradientDrawsBeforeStartLocation |
                            kCGGradientDrawsAfterEndLocation);
            CGContextRestoreGState(context);
            CGGradientRelease(gradient);
        }
        CGColorSpaceRelease(space);
    }
    [super drawInContext: context];
}

@end
