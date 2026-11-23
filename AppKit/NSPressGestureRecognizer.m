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

#import <AppKit/NSPressGestureRecognizer.h>

@implementation NSPressGestureRecognizer

- (instancetype) initWithTarget: (id) target action: (SEL) action {
    if ((self = [super initWithTarget: target action: action]) != nil) {
        _minimumPressDuration = 0.5;
        _allowableMovement = 10.0;
        _numberOfTouchesRequired = 0;
    }
    return self;
}

- (instancetype) initWithCoder: (NSCoder *) coder {
    if ((self = [super initWithCoder: coder]) != nil) {
        if ([coder allowsKeyedCoding]) {
            if ([coder containsValueForKey: @"NSPressGestureRecognizerMinimumPressDuration"])
                _minimumPressDuration = [coder decodeDoubleForKey: @"NSPressGestureRecognizerMinimumPressDuration"];
            if ([coder containsValueForKey: @"NSPressGestureRecognizerAllowableMovement"])
                _allowableMovement = [coder decodeDoubleForKey: @"NSPressGestureRecognizerAllowableMovement"];
            if ([coder containsValueForKey: @"NSPressGestureRecognizerNumberOfTouchesRequired"])
                _numberOfTouchesRequired = [coder decodeIntegerForKey: @"NSPressGestureRecognizerNumberOfTouchesRequired"];
        }
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder {
    [super encodeWithCoder: coder];
    if ([coder allowsKeyedCoding]) {
        [coder encodeDouble: _minimumPressDuration forKey: @"NSPressGestureRecognizerMinimumPressDuration"];
        [coder encodeDouble: _allowableMovement forKey: @"NSPressGestureRecognizerAllowableMovement"];
        [coder encodeInteger: _numberOfTouchesRequired forKey: @"NSPressGestureRecognizerNumberOfTouchesRequired"];
    }
}

- (NSTimeInterval) minimumPressDuration { return _minimumPressDuration; }
- (void) setMinimumPressDuration: (NSTimeInterval) value { _minimumPressDuration = value; }
- (CGFloat) allowableMovement { return _allowableMovement; }
- (void) setAllowableMovement: (CGFloat) value { _allowableMovement = value; }
- (NSInteger) numberOfTouchesRequired { return _numberOfTouchesRequired; }
- (void) setNumberOfTouchesRequired: (NSInteger) value { _numberOfTouchesRequired = value; }

@end
