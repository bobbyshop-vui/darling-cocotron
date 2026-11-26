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

#import <QuartzCore/CAReplicatorLayer.h>

@implementation CAReplicatorLayer

// Stored by CALayer's dynamic properties. (Darling draws the sublayers once;
// it does not replicate them.)
@dynamic instanceCount, preservesDepth, instanceDelay, instanceTransform,
        instanceColor, instanceRedOffset, instanceGreenOffset,
        instanceBlueOffset, instanceAlphaOffset;

+ (id) defaultValueForKey: (NSString *) key {
    if ([key isEqualToString: @"instanceCount"])
        return [NSNumber numberWithInteger: 1];
    if ([key isEqualToString: @"instanceTransform"])
        return [NSValue valueWithBytes: &CATransform3DIdentity
                              objCType: @encode(CATransform3D)];
    return [super defaultValueForKey: key];
}

@end
