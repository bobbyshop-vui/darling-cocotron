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

#import <QuartzCore/CAShapeLayer.h>

NSString *const kCAFillRuleNonZero = @"non-zero";
NSString *const kCAFillRuleEvenOdd = @"even-odd";
NSString *const kCALineJoinMiter = @"miter";
NSString *const kCALineJoinRound = @"round";
NSString *const kCALineJoinBevel = @"bevel";
NSString *const kCALineCapButt = @"butt";
NSString *const kCALineCapRound = @"round";
NSString *const kCALineCapSquare = @"square";

@implementation CAShapeLayer

// Stored by CALayer's dynamic properties.
@dynamic path, fillColor, fillRule, strokeColor, strokeStart, strokeEnd,
        lineWidth, miterLimit, lineCap, lineJoin, lineDashPhase,
        lineDashPattern;

+ (id) defaultValueForKey: (NSString *) key {
    static NSDictionary *defaults = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        CGColorRef black = CGColorCreateGenericRGB(0, 0, 0, 1);
        defaults = [[NSDictionary alloc] initWithObjectsAndKeys:
                (id) black, @"fillColor",
                kCAFillRuleNonZero, @"fillRule",
                [NSNumber numberWithDouble: 1.0], @"strokeEnd",
                [NSNumber numberWithDouble: 1.0], @"lineWidth",
                [NSNumber numberWithDouble: 10.0], @"miterLimit",
                kCALineCapButt, @"lineCap",
                kCALineJoinMiter, @"lineJoin",
                nil];
        CGColorRelease(black);
    });
    id value = [defaults objectForKey: key];
    return value != nil ? value : [super defaultValueForKey: key];
}

+ (BOOL) needsDisplayForKey: (NSString *) key {
    static NSSet *keys = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        keys = [[NSSet alloc] initWithObjects: @"path", @"fillColor",
                @"fillRule", @"strokeColor", @"strokeStart", @"strokeEnd",
                @"lineWidth", @"miterLimit", @"lineCap", @"lineJoin",
                @"lineDashPhase", @"lineDashPattern", nil];
    });
    return [keys containsObject: key] || [super needsDisplayForKey: key];
}

- (void) drawInContext: (CGContextRef) context {
    CGPathRef path = [self path];

    if (path != NULL) {
        CGColorRef fill = [self fillColor];
        CGColorRef stroke = [self strokeColor];

        CGContextSaveGState(context);
        if (fill != NULL) {
            CGContextBeginPath(context);
            CGContextAddPath(context, path);
            CGContextSetFillColorWithColor(context, fill);
            if ([[self fillRule] isEqualToString: kCAFillRuleEvenOdd])
                CGContextEOFillPath(context);
            else
                CGContextFillPath(context);
        }
        // Partial strokes (strokeStart/strokeEnd) are drawn whole.
        if (stroke != NULL && [self lineWidth] > 0 &&
            [self strokeEnd] > [self strokeStart]) {
            NSString *cap = [self lineCap];
            NSString *join = [self lineJoin];
            NSArray *dashes = [self lineDashPattern];

            CGContextBeginPath(context);
            CGContextAddPath(context, path);
            CGContextSetStrokeColorWithColor(context, stroke);
            CGContextSetLineWidth(context, [self lineWidth]);
            CGContextSetMiterLimit(context, [self miterLimit]);
            CGContextSetLineCap(context,
                    [cap isEqualToString: kCALineCapRound] ? kCGLineCapRound
                    : [cap isEqualToString: kCALineCapSquare] ? kCGLineCapSquare
                                                              : kCGLineCapButt);
            CGContextSetLineJoin(context,
                    [join isEqualToString: kCALineJoinRound] ? kCGLineJoinRound
                    : [join isEqualToString: kCALineJoinBevel] ? kCGLineJoinBevel
                                                               : kCGLineJoinMiter);
            if ([dashes count] > 0) {
                CGFloat lengths[[dashes count]];
                for (NSUInteger i = 0; i < [dashes count]; i++)
                    lengths[i] = [[dashes objectAtIndex: i] doubleValue];
                CGContextSetLineDash(context, [self lineDashPhase], lengths,
                                     [dashes count]);
            }
            CGContextStrokePath(context);
        }
        CGContextRestoreGState(context);
    }
    [super drawInContext: context];
}

@end
