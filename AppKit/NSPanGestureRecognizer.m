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
#import <AppKit/NSEvent.h>
#import <AppKit/NSView.h>

@implementation NSPanGestureRecognizer

- (instancetype) initWithTarget: (id) target action: (SEL) action
{
    if ((self = [super initWithTarget: target action: action]) != nil)
    {
        _numberOfTouchesRequired = 1;
        _buttonMask = 0x1;
    }
    return self;
}

- (instancetype) initWithCoder: (NSCoder *) coder
{
    if ((self = [super initWithCoder: coder]) != nil) {
        _numberOfTouchesRequired = 1;
        _buttonMask = 0x1;
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

- (NSUInteger) buttonMask { return _buttonMask; }
- (void) setButtonMask: (NSUInteger) mask { _buttonMask = mask; }

/* _translation and _velocity are kept in window coordinates. */
- (NSPoint) _convertVector: (NSPoint) v toView: (NSView *) view {
    if (view == nil)
        return v;
    NSPoint o = [view convertPoint: NSZeroPoint fromView: nil];
    NSPoint p = [view convertPoint: v fromView: nil];
    return NSMakePoint(p.x - o.x, p.y - o.y);
}

- (NSPoint) translationInView: (NSView *) view {
    return [self _convertVector: _translation toView: view];
}

- (void) setTranslation: (NSPoint) translation inView: (NSView *) view {
    if (view == nil) {
        _translation = translation;
        return;
    }
    NSPoint o = [view convertPoint: NSZeroPoint toView: nil];
    NSPoint p = [view convertPoint: translation toView: nil];
    _translation = NSMakePoint(p.x - o.x, p.y - o.y);
}

- (NSPoint) velocityInView: (NSView *) view {
    return [self _convertVector: _velocity toView: view];
}

- (void) reset {
    _tracking = NO;
    _translation = NSZeroPoint;
    _velocity = NSZeroPoint;
    [super reset];
}

- (void) _panDown: (NSEvent *) event button: (NSInteger) button {
    [self _noteEvent: event];
    if (_state != NSGestureRecognizerStatePossible)
        return;
    if (!(_buttonMask & (1 << button))) {
        [self setState: NSGestureRecognizerStateFailed];
        return;
    }
    _tracking = YES;
    _translation = NSZeroPoint;
    _velocity = NSZeroPoint;
    _lastLocation = [event locationInWindow];
    _lastTime = [event timestamp];
}

- (void) _panDragged: (NSEvent *) event {
    [self _noteEvent: event];
    if (!_tracking)
        return;
    NSPoint p = [event locationInWindow];
    NSPoint delta = NSMakePoint(p.x - _lastLocation.x, p.y - _lastLocation.y);
    NSTimeInterval dt = [event timestamp] - _lastTime;
    _translation.x += delta.x;
    _translation.y += delta.y;
    if (dt > 0)
        _velocity = NSMakePoint(delta.x / dt, delta.y / dt);
    _lastLocation = p;
    _lastTime = [event timestamp];
    if (_state == NSGestureRecognizerStatePossible) {
        if (hypot(_translation.x, _translation.y) >= 3.0)
            [self setState: NSGestureRecognizerStateBegan];
    } else if (_state == NSGestureRecognizerStateBegan || _state == NSGestureRecognizerStateChanged)
        [self setState: NSGestureRecognizerStateChanged];
}

- (void) _panUp: (NSEvent *) event {
    [self _noteEvent: event];
    if (!_tracking)
        return;
    _tracking = NO;
    if (_state == NSGestureRecognizerStateBegan || _state == NSGestureRecognizerStateChanged)
        [self setState: NSGestureRecognizerStateEnded];
    else if (_state == NSGestureRecognizerStatePossible)
        [self setState: NSGestureRecognizerStateFailed];
}

- (void) mouseDown: (NSEvent *) event { [self _panDown: event button: 0]; }
- (void) rightMouseDown: (NSEvent *) event { [self _panDown: event button: 1]; }
- (void) otherMouseDown: (NSEvent *) event { [self _panDown: event button: MAX(2, [event buttonNumber])]; }
- (void) mouseDragged: (NSEvent *) event { [self _panDragged: event]; }
- (void) rightMouseDragged: (NSEvent *) event { [self _panDragged: event]; }
- (void) otherMouseDragged: (NSEvent *) event { [self _panDragged: event]; }
- (void) mouseUp: (NSEvent *) event { [self _panUp: event]; }
- (void) rightMouseUp: (NSEvent *) event { [self _panUp: event]; }
- (void) otherMouseUp: (NSEvent *) event { [self _panUp: event]; }

@end
