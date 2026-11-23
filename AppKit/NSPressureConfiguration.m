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

#import <AppKit/NSPressureConfiguration.h>

@implementation NSPressureConfiguration

- (instancetype) init {
    return [self initWithPressureBehavior: 0];
}

- (instancetype) initWithPressureBehavior: (NSInteger) pressureBehavior {
    if ((self = [super init]) != nil)
        _pressureBehavior = pressureBehavior;
    return self;
}

- (NSInteger) pressureBehavior {
    return _pressureBehavior;
}

- (void) set {
    // No pressure-sensitive hardware: the configuration has nothing to apply.
}

@end
