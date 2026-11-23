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

#import <AppKit/NSGestureRecognizer.h>
#import <AppKit/NSView.h>
#import <AppKit/NSEvent.h>

/*
 * Not part of the public API on macOS 10.10 but present in every later AppKit.
 * Xcode 10 links against it unconditionally, and a missing class symbol is a hard
 * dlopen() failure (it's a non-lazy reference), so it has to exist here as well.
 */
@interface NSImmediateActionGestureRecognizer : NSGestureRecognizer
@end

@implementation NSGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action
{
    if ((self = [super init]) != nil) {
        _target = target;
        _action = action;
        _enabled = YES;
        _state = NSGestureRecognizerStatePossible;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithTarget:nil action:NULL];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if ((self = [self initWithTarget:nil action:NULL]) != nil) {
        if ([coder allowsKeyedCoding]) {
            if ([coder containsValueForKey:@"NSGestureRecognizerEnabled"])
                _enabled = [coder decodeBoolForKey:@"NSGestureRecognizerEnabled"];
            _delaysPrimaryMouseButtonEvents = [coder decodeBoolForKey:@"NSGestureRecognizerDelaysPrimaryMouseButtonEvents"];
            _delaysSecondaryMouseButtonEvents = [coder decodeBoolForKey:@"NSGestureRecognizerDelaysSecondaryMouseButtonEvents"];
            _delaysOtherMouseButtonEvents = [coder decodeBoolForKey:@"NSGestureRecognizerDelaysOtherMouseButtonEvents"];
            _delaysKeyEvents = [coder decodeBoolForKey:@"NSGestureRecognizerDelaysKeyEvents"];
            _delaysMagnificationEvents = [coder decodeBoolForKey:@"NSGestureRecognizerDelaysMagnificationEvents"];
            _delaysRotationEvents = [coder decodeBoolForKey:@"NSGestureRecognizerDelaysRotationEvents"];
            _allowedTouchTypes = [coder decodeIntegerForKey:@"NSGestureRecognizerAllowedTouchTypes"];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if ([coder allowsKeyedCoding]) {
        [coder encodeBool:_enabled forKey:@"NSGestureRecognizerEnabled"];
        [coder encodeBool:_delaysPrimaryMouseButtonEvents forKey:@"NSGestureRecognizerDelaysPrimaryMouseButtonEvents"];
        [coder encodeBool:_delaysSecondaryMouseButtonEvents forKey:@"NSGestureRecognizerDelaysSecondaryMouseButtonEvents"];
        [coder encodeBool:_delaysOtherMouseButtonEvents forKey:@"NSGestureRecognizerDelaysOtherMouseButtonEvents"];
        [coder encodeBool:_delaysKeyEvents forKey:@"NSGestureRecognizerDelaysKeyEvents"];
        [coder encodeBool:_delaysMagnificationEvents forKey:@"NSGestureRecognizerDelaysMagnificationEvents"];
        [coder encodeBool:_delaysRotationEvents forKey:@"NSGestureRecognizerDelaysRotationEvents"];
        [coder encodeInteger:_allowedTouchTypes forKey:@"NSGestureRecognizerAllowedTouchTypes"];
    }
}

- (void)dealloc
{
    [_lastEvent release];
    [super dealloc];
}

- (id)target { return _target; }
- (void)setTarget:(id)target { _target = target; }
- (SEL)action { return _action; }
- (void)setAction:(SEL)action { _action = action; }
- (NSGestureRecognizerState)state { return _state; }
- (void)setState:(NSGestureRecognizerState)state { _state = state; }
- (id<NSGestureRecognizerDelegate>)delegate { return _delegate; }
- (void)setDelegate:(id<NSGestureRecognizerDelegate>)delegate { _delegate = delegate; }
- (BOOL)isEnabled { return _enabled; }

- (void)setEnabled:(BOOL)enabled
{
    if (_enabled == enabled)
        return;
    _enabled = enabled;
    if (!enabled) {
        // A disabled recognizer is cancelled if it is in the middle of a gesture.
        if (_state == NSGestureRecognizerStateBegan || _state == NSGestureRecognizerStateChanged)
            _state = NSGestureRecognizerStateCancelled;
        [self reset];
    }
}

- (NSView *)view { return _view; }
- (void)_setView:(NSView *)view { _view = view; }

- (BOOL)delaysPrimaryMouseButtonEvents { return _delaysPrimaryMouseButtonEvents; }
- (void)setDelaysPrimaryMouseButtonEvents:(BOOL)value { _delaysPrimaryMouseButtonEvents = value; }
- (BOOL)delaysSecondaryMouseButtonEvents { return _delaysSecondaryMouseButtonEvents; }
- (void)setDelaysSecondaryMouseButtonEvents:(BOOL)value { _delaysSecondaryMouseButtonEvents = value; }
- (BOOL)delaysOtherMouseButtonEvents { return _delaysOtherMouseButtonEvents; }
- (void)setDelaysOtherMouseButtonEvents:(BOOL)value { _delaysOtherMouseButtonEvents = value; }
- (BOOL)delaysKeyEvents { return _delaysKeyEvents; }
- (void)setDelaysKeyEvents:(BOOL)value { _delaysKeyEvents = value; }
- (BOOL)delaysMagnificationEvents { return _delaysMagnificationEvents; }
- (void)setDelaysMagnificationEvents:(BOOL)value { _delaysMagnificationEvents = value; }
- (BOOL)delaysRotationEvents { return _delaysRotationEvents; }
- (void)setDelaysRotationEvents:(BOOL)value { _delaysRotationEvents = value; }
- (NSUInteger)allowedTouchTypes { return _allowedTouchTypes; }
- (void)setAllowedTouchTypes:(NSUInteger)value { _allowedTouchTypes = value; }

- (void)_noteEvent:(NSEvent *)event
{
    if (event != _lastEvent) {
        [_lastEvent release];
        _lastEvent = [event retain];
    }
}

- (NSPoint)locationInView:(NSView *)view
{
    NSPoint location = _lastEvent ? [_lastEvent locationInWindow] : NSZeroPoint;
    if (view != nil)
        return [view convertPoint:location fromView:nil];
    return location;
}

- (void)reset
{
    _state = NSGestureRecognizerStatePossible;
    [_lastEvent release];
    _lastEvent = nil;
}

- (void)mouseDown:(NSEvent *)event { [self _noteEvent:event]; }
- (void)rightMouseDown:(NSEvent *)event { [self _noteEvent:event]; }
- (void)otherMouseDown:(NSEvent *)event { [self _noteEvent:event]; }
- (void)mouseUp:(NSEvent *)event { [self _noteEvent:event]; }
- (void)rightMouseUp:(NSEvent *)event { [self _noteEvent:event]; }
- (void)otherMouseUp:(NSEvent *)event { [self _noteEvent:event]; }
- (void)mouseDragged:(NSEvent *)event { [self _noteEvent:event]; }
- (void)rightMouseDragged:(NSEvent *)event { [self _noteEvent:event]; }
- (void)otherMouseDragged:(NSEvent *)event { [self _noteEvent:event]; }
- (void)keyDown:(NSEvent *)event { }
- (void)keyUp:(NSEvent *)event { }
- (void)flagsChanged:(NSEvent *)event { }
- (void)tabletPoint:(NSEvent *)event { }
- (void)magnifyWithEvent:(NSEvent *)event { }
- (void)rotateWithEvent:(NSEvent *)event { }
- (void)pressureChangeWithEvent:(NSEvent *)event { }
- (void)touchesBeganWithEvent:(NSEvent *)event { }
- (void)touchesMovedWithEvent:(NSEvent *)event { }
- (void)touchesEndedWithEvent:(NSEvent *)event { }
- (void)touchesCancelledWithEvent:(NSEvent *)event { }

@end

@implementation NSRotationGestureRecognizer

- (CGFloat)rotation { return _rotation; }
- (void)setRotation:(CGFloat)rotation { _rotation = rotation; }
- (CGFloat)rotationInDegrees { return _rotation * 180.0 / M_PI; }
- (void)setRotationInDegrees:(CGFloat)degrees { _rotation = degrees * M_PI / 180.0; }

- (void)reset
{
    _rotation = 0;
    [super reset];
}

- (void)rotateWithEvent:(NSEvent *)event
{
    // NSEvent.rotation is in degrees; accumulate it while the gesture is in progress.
    if ([event respondsToSelector:@selector(rotation)])
        _rotation += [(id)event rotation] * M_PI / 180.0;
}

@end

@implementation NSMagnificationGestureRecognizer

- (CGFloat)magnification { return _magnification; }
- (void)setMagnification:(CGFloat)magnification { _magnification = magnification; }

- (void)reset
{
    _magnification = 0;
    [super reset];
}

- (void)magnifyWithEvent:(NSEvent *)event
{
    if ([event respondsToSelector:@selector(magnification)])
        _magnification += [(id)event magnification];
}

@end

@implementation NSImmediateActionGestureRecognizer
@end
