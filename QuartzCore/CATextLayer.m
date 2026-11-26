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

#import <QuartzCore/CATextLayer.h>

NSString *const kCAAlignmentNatural = @"natural";
NSString *const kCAAlignmentLeft = @"left";
NSString *const kCAAlignmentRight = @"right";
NSString *const kCAAlignmentCenter = @"center";
NSString *const kCAAlignmentJustified = @"justified";

NSString *const kCATruncationNone = @"none";
NSString *const kCATruncationStart = @"start";
NSString *const kCATruncationEnd = @"end";
NSString *const kCATruncationMiddle = @"middle";

@implementation CATextLayer

// Stored by CALayer's dynamic properties. (Darling does not draw the text
// of a CATextLayer yet.)
@dynamic string, font, fontSize, foregroundColor, wrapped, truncationMode,
        alignmentMode, allowsFontSubpixelQuantization;

+ (id) defaultValueForKey: (NSString *) key {
    static NSDictionary *defaults = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        CGColorRef white = CGColorCreateGenericRGB(1, 1, 1, 1);
        defaults = [[NSDictionary alloc] initWithObjectsAndKeys:
                [NSNumber numberWithDouble: 36.0], @"fontSize",
                (id) white, @"foregroundColor",
                kCATruncationNone, @"truncationMode",
                kCAAlignmentNatural, @"alignmentMode",
                nil];
        CGColorRelease(white);
    });
    id value = [defaults objectForKey: key];
    return value != nil ? value : [super defaultValueForKey: key];
}

- (NSMethodSignature *) methodSignatureForSelector: (SEL) aSelector {
    return [NSMethodSignature signatureWithObjCTypes: "v@:"];
}

- (void) forwardInvocation: (NSInvocation *) anInvocation {
    NSLog(@"Stub called: %@ in %@",
          NSStringFromSelector([anInvocation selector]), [self class]);
}

@end
