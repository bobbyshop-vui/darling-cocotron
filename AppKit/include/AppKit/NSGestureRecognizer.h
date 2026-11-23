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

#import <AppKit/AppKitExport.h>
#import <Foundation/Foundation.h>

@class NSView, NSEvent;
@protocol NSGestureRecognizerDelegate;

typedef NS_ENUM(NSInteger, NSGestureRecognizerState) {
    NSGestureRecognizerStatePossible,
    NSGestureRecognizerStateBegan,
    NSGestureRecognizerStateChanged,
    NSGestureRecognizerStateEnded,
    NSGestureRecognizerStateCancelled,
    NSGestureRecognizerStateFailed,
    NSGestureRecognizerStateRecognized = NSGestureRecognizerStateEnded
};

@interface NSGestureRecognizer : NSObject <NSCoding> {
    id _target;
    SEL _action;
    NSView *_view;
    NSEvent *_lastEvent;
    id<NSGestureRecognizerDelegate> _delegate;
    NSGestureRecognizerState _state;
    BOOL _enabled;
    BOOL _delaysPrimaryMouseButtonEvents;
    BOOL _delaysSecondaryMouseButtonEvents;
    BOOL _delaysOtherMouseButtonEvents;
    BOOL _delaysKeyEvents;
    BOOL _delaysMagnificationEvents;
    BOOL _delaysRotationEvents;
    NSUInteger _allowedTouchTypes;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action;
- (instancetype)initWithCoder:(NSCoder *)coder;

@property (weak) id target;
@property SEL action;
@property (readonly) NSGestureRecognizerState state;
@property (weak) id<NSGestureRecognizerDelegate> delegate;
@property (getter=isEnabled) BOOL enabled;
@property (readonly) NSView *view;
@property BOOL delaysPrimaryMouseButtonEvents;
@property BOOL delaysSecondaryMouseButtonEvents;
@property BOOL delaysOtherMouseButtonEvents;
@property BOOL delaysKeyEvents;
@property BOOL delaysMagnificationEvents;
@property BOOL delaysRotationEvents;
@property NSUInteger allowedTouchTypes; // NSTouchTypeMask

- (NSPoint)locationInView:(NSView *)view;

@end

@protocol NSGestureRecognizerDelegate <NSObject>
@optional
- (BOOL)gestureRecognizerShouldBegin:(NSGestureRecognizer *)gestureRecognizer;
- (BOOL)gestureRecognizer:(NSGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(NSGestureRecognizer *)otherGestureRecognizer;
@end

@interface NSGestureRecognizer (NSSubclassUse)

@property NSGestureRecognizerState state;

- (void)reset;

- (void)mouseDown:(NSEvent *)event;
- (void)rightMouseDown:(NSEvent *)event;
- (void)otherMouseDown:(NSEvent *)event;
- (void)mouseUp:(NSEvent *)event;
- (void)rightMouseUp:(NSEvent *)event;
- (void)otherMouseUp:(NSEvent *)event;
- (void)mouseDragged:(NSEvent *)event;
- (void)rightMouseDragged:(NSEvent *)event;
- (void)otherMouseDragged:(NSEvent *)event;
- (void)keyDown:(NSEvent *)event;
- (void)keyUp:(NSEvent *)event;
- (void)flagsChanged:(NSEvent *)event;
- (void)tabletPoint:(NSEvent *)event;
- (void)magnifyWithEvent:(NSEvent *)event;
- (void)rotateWithEvent:(NSEvent *)event;
- (void)pressureChangeWithEvent:(NSEvent *)event;
- (void)touchesBeganWithEvent:(NSEvent *)event;
- (void)touchesMovedWithEvent:(NSEvent *)event;
- (void)touchesEndedWithEvent:(NSEvent *)event;
- (void)touchesCancelledWithEvent:(NSEvent *)event;

/* Used by NSView when a recognizer is added to / removed from it. */
- (void)_setView:(NSView *)view;

@end

@interface NSMagnificationGestureRecognizer : NSGestureRecognizer {
    CGFloat _magnification;
}
@property CGFloat magnification;
@end

@interface NSRotationGestureRecognizer : NSGestureRecognizer {
    CGFloat _rotation;
}
@property CGFloat rotation;
@property CGFloat rotationInDegrees;
@end
