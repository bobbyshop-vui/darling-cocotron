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
#import <AppKit/NSEvent.h>

@implementation NSPressGestureRecognizer

- (instancetype) initWithTarget: (id) target action: (SEL) action {
    if ((self = [super initWithTarget: target action: action]) != nil) {
        _minimumPressDuration = 0.5;
        _allowableMovement = 10.0;
        _numberOfTouchesRequired = 0;
        _buttonMask = 0x1;
    }
    return self;
}

- (instancetype) initWithCoder: (NSCoder *) coder {
    if ((self = [super initWithCoder: coder]) != nil) {
        _minimumPressDuration = 0.5;
        _allowableMovement = 10.0;
        _buttonMask = 0x1;
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

- (NSUInteger) buttonMask { return _buttonMask; }
- (void) setButtonMask: (NSUInteger) mask { _buttonMask = mask; }

- (BOOL) delaysPrimaryMouseButtonEvents { return (_buttonMask & 0x1) != 0; }
- (BOOL) delaysSecondaryMouseButtonEvents { return (_buttonMask & 0x2) != 0; }
- (BOOL) delaysOtherMouseButtonEvents { return (_buttonMask & ~(NSUInteger)0x3) != 0; }

- (void) _cancelTimer {
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(_pressTimerFired) object: nil];
}

- (void) _setView: (NSView *) view {
    if (view == nil)
        [self _cancelTimer];
    [super _setView: view];
}

- (void) reset {
    [self _cancelTimer];
    _tracking = NO;
    [super reset];
}

- (void) _pressTimerFired {
    if (_tracking && _state == NSGestureRecognizerStatePossible)
        [self setState: NSGestureRecognizerStateBegan];
}

- (void) _pressDown: (NSEvent *) event button: (NSInteger) button {
    [self _noteEvent: event];
    if (_state != NSGestureRecognizerStatePossible)
        return;
    if (!(_buttonMask & (1 << button))) {
        [self setState: NSGestureRecognizerStateFailed];
        return;
    }
    _tracking = YES;
    _downLocation = [event locationInWindow];
    [self _cancelTimer];
    [self performSelector: @selector(_pressTimerFired) withObject: nil afterDelay: _minimumPressDuration];
}

- (void) _pressDragged: (NSEvent *) event {
    [self _noteEvent: event];
    if (!_tracking)
        return;
    if (_state == NSGestureRecognizerStatePossible) {
        NSPoint p = [event locationInWindow];
        if (hypot(p.x - _downLocation.x, p.y - _downLocation.y) > _allowableMovement) {
            [self _cancelTimer];
            _tracking = NO;
            [self setState: NSGestureRecognizerStateFailed];
        }
    } else if (_state == NSGestureRecognizerStateBegan || _state == NSGestureRecognizerStateChanged)
        [self setState: NSGestureRecognizerStateChanged];
}

- (void) _pressUp: (NSEvent *) event {
    [self _noteEvent: event];
    if (!_tracking)
        return;
    [self _cancelTimer];
    _tracking = NO;
    if (_state == NSGestureRecognizerStateBegan || _state == NSGestureRecognizerStateChanged)
        [self setState: NSGestureRecognizerStateEnded];
    else if (_state == NSGestureRecognizerStatePossible)
        [self setState: NSGestureRecognizerStateFailed];
}

- (void) mouseDown: (NSEvent *) event { [self _pressDown: event button: 0]; }
- (void) rightMouseDown: (NSEvent *) event { [self _pressDown: event button: 1]; }
- (void) otherMouseDown: (NSEvent *) event { [self _pressDown: event button: MAX(2, [event buttonNumber])]; }
- (void) mouseDragged: (NSEvent *) event { [self _pressDragged: event]; }
- (void) rightMouseDragged: (NSEvent *) event { [self _pressDragged: event]; }
- (void) otherMouseDragged: (NSEvent *) event { [self _pressDragged: event]; }
- (void) mouseUp: (NSEvent *) event { [self _pressUp: event]; }
- (void) rightMouseUp: (NSEvent *) event { [self _pressUp: event]; }
- (void) otherMouseUp: (NSEvent *) event { [self _pressUp: event]; }

@end
