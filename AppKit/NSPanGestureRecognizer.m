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

#import <AppKit/NSPanGestureRecognizer.h>

@implementation NSPanGestureRecognizer

- (instancetype) initWithTarget: (id) target action: (SEL) action
{
    if ((self = [super initWithTarget: target action: action]) != nil)
        _numberOfTouchesRequired = 1;
    return self;
}

- (instancetype) initWithCoder: (NSCoder *) coder
{
    if ((self = [super initWithCoder: coder]) != nil) {
        _numberOfTouchesRequired = 1;
        if ([coder allowsKeyedCoding] &&
            [coder containsValueForKey: @"NSPanGestureRecognizerNumberOfTouchesRequired"])
            _numberOfTouchesRequired = [coder decodeIntegerForKey: @"NSPanGestureRecognizerNumberOfTouchesRequired"];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder
{
    [super encodeWithCoder: coder];
    if ([coder allowsKeyedCoding])
        [coder encodeInteger: _numberOfTouchesRequired forKey: @"NSPanGestureRecognizerNumberOfTouchesRequired"];
}

- (NSInteger) numberOfTouchesRequired
{
    return _numberOfTouchesRequired;
}

- (void) setNumberOfTouchesRequired: (NSInteger) count
{
    _numberOfTouchesRequired = count;
}

- (NSPoint) translationInView: (NSView *) view
{
    return _translation;
}

- (void) setTranslation: (NSPoint) translation inView: (NSView *) view
{
    _translation = translation;
}

@end
