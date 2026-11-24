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

#import <AppKit/NSClickGestureRecognizer.h>
#import <AppKit/NSEvent.h>

@implementation NSClickGestureRecognizer

- (instancetype) initWithTarget: (id) target action: (SEL) action {
    if ((self = [super initWithTarget: target action: action]) != nil) {
        _numberOfClicksRequired = 1;
        _numberOfTouchesRequired = 1;
        _buttonMask = 0x1;
    }
    return self;
}

- (instancetype) initWithCoder: (NSCoder *) coder {
    if ((self = [super initWithCoder: coder]) != nil) {
        _numberOfClicksRequired = 1;
        _numberOfTouchesRequired = 1;
        _buttonMask = 0x1;
        if ([coder allowsKeyedCoding]) {
            if ([coder containsValueForKey: @"NSClickGestureRecognizerNumberOfClicksRequired"])
                _numberOfClicksRequired = [coder decodeIntegerForKey: @"NSClickGestureRecognizerNumberOfClicksRequired"];
            if ([coder containsValueForKey: @"NSClickGestureRecognizerButtonMask"])
                _buttonMask = [coder decodeIntegerForKey: @"NSClickGestureRecognizerButtonMask"];
        }
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder {
    [super encodeWithCoder: coder];
    if ([coder allowsKeyedCoding]) {
        [coder encodeInteger: _numberOfClicksRequired forKey: @"NSClickGestureRecognizerNumberOfClicksRequired"];
        [coder encodeInteger: _buttonMask forKey: @"NSClickGestureRecognizerButtonMask"];
    }
}

- (NSUInteger) buttonMask {
    return _buttonMask;
}

- (void) setButtonMask: (NSUInteger) mask {
    _buttonMask = mask;
}

- (BOOL) delaysPrimaryMouseButtonEvents {
    return (_buttonMask & 0x1) != 0;
}

- (BOOL) delaysSecondaryMouseButtonEvents {
    return (_buttonMask & 0x2) != 0;
}

- (BOOL) delaysOtherMouseButtonEvents {
    return (_buttonMask & ~(NSUInteger)0x3) != 0;
}

- (void) reset {
    _tracking = NO;
    [super reset];
}

- (void) _clickDown: (NSEvent *) event button: (NSInteger) button {
    [self _noteEvent: event];
    if (_state != NSGestureRecognizerStatePossible)
        return;
    if (!(_buttonMask & (1 << button)) || [event clickCount] > _numberOfClicksRequired) {
        [self setState: NSGestureRecognizerStateFailed];
        return;
    }
    _tracking = YES;
    _downLocation = [event locationInWindow];
}

- (void) _clickDragged: (NSEvent *) event {
    [self _noteEvent: event];
    if (!_tracking)
        return;
    NSPoint p = [event locationInWindow];
    if (fabs(p.x - _downLocation.x) > 10 || fabs(p.y - _downLocation.y) > 10) {
        _tracking = NO;
        [self setState: NSGestureRecognizerStateFailed];
    }
}

- (void) _clickUp: (NSEvent *) event {
    [self _noteEvent: event];
    if (!_tracking)
        return;
    _tracking = NO;
    if ([event clickCount] >= _numberOfClicksRequired)
        [self setState: NSGestureRecognizerStateEnded];
    // Otherwise keep waiting for the next click of a multi-click gesture.
}

- (void) mouseDown: (NSEvent *) event { [self _clickDown: event button: 0]; }
- (void) rightMouseDown: (NSEvent *) event { [self _clickDown: event button: 1]; }
- (void) otherMouseDown: (NSEvent *) event { [self _clickDown: event button: MAX(2, [event buttonNumber])]; }
- (void) mouseDragged: (NSEvent *) event { [self _clickDragged: event]; }
- (void) rightMouseDragged: (NSEvent *) event { [self _clickDragged: event]; }
- (void) otherMouseDragged: (NSEvent *) event { [self _clickDragged: event]; }
- (void) mouseUp: (NSEvent *) event { [self _clickUp: event]; }
- (void) rightMouseUp: (NSEvent *) event { [self _clickUp: event]; }
- (void) otherMouseUp: (NSEvent *) event { [self _clickUp: event]; }

- (NSInteger) numberOfClicksRequired {
    return _numberOfClicksRequired;
}

- (void) setNumberOfClicksRequired: (NSInteger) value {
    _numberOfClicksRequired = value;
}

- (NSInteger) numberOfTouchesRequired {
    return _numberOfTouchesRequired;
}

- (void) setNumberOfTouchesRequired: (NSInteger) value {
    _numberOfTouchesRequired = value;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [NSMethodSignature signatureWithObjCTypes: "v@:"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"Stub called: %@ in %@", NSStringFromSelector([anInvocation selector]), [self class]);
}

@end
