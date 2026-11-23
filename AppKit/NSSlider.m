/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <AppKit/NSSlider.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSFont.h>

@interface NSSliderAccessoryBehavior ()
- (instancetype) _initWithKind: (NSInteger) kind;
@end

@implementation NSSlider

+ (Class) cellClass {
    return [NSSliderCell class];
}

- (double) minValue {
    return [[self selectedCell] minValue];
}

- (double) maxValue {
    return [[self selectedCell] maxValue];
}

- (double) altIncrementValue {
    return [[self selectedCell] altIncrementValue];
}

- (NSInteger) numberOfTickMarks {
    return [[self selectedCell] numberOfTickMarks];
}

- (NSTickMarkPosition) tickMarkPosition {
    return [[self selectedCell] tickMarkPosition];
}

- (BOOL) allowsTickMarkValuesOnly {
    return [[self selectedCell] allowsTickMarkValuesOnly];
}

- (CGFloat) knobThickness {
    return [[self selectedCell] knobThickness];
}

- (void) setMinValue: (double) value {
    [[self selectedCell] setMinValue: value];
    [self setNeedsDisplay: YES];
}

- (void) setMaxValue: (double) value {
    [[self selectedCell] setMaxValue: value];
    [self setNeedsDisplay: YES];
}

- (void) setAltIncrementValue: (double) value {
    [[self selectedCell] setAltIncrementValue: value];
}

- (void) setNumberOfTickMarks: (NSInteger) value {
    [[self selectedCell] setNumberOfTickMarks: value];
    [self setNeedsDisplay: YES];
}

- (void) setTickMarkPosition: (NSTickMarkPosition) position {
    [[self selectedCell] setTickMarkPosition: position];
    [self setNeedsDisplay: YES];
}

- (void) setAllowsTickMarkValuesOnly: (BOOL) valuesOnly {
    [[self selectedCell] setAllowsTickMarkValuesOnly: valuesOnly];
}

- (void) setKnobThickness: (CGFloat) thickness {
    [[self selectedCell] setKnobThickness: thickness];
    [self setNeedsDisplay: YES];
}

- (NSInteger) isVertical {
    return [[self selectedCell] isVertical];
}

- (NSInteger) indexOfTickMarkAtPoint: (NSPoint) point {
    return [[self selectedCell] indexOfTickMarkAtPoint: point];
}

- (double) tickMarkValueAtIndex: (NSInteger) index {
    return [[self selectedCell] tickMarkValueAtIndex: index];
}

- (double) closestTickMarkValueToValue: (double) value {
    return [[self selectedCell] closestTickMarkValueToValue: value];
}

- (NSRect) rectOfTickMarkAtIndex: (NSInteger) index {
    return [[self selectedCell] rectOfTickMarkAtIndex: index];
}

- (BOOL) acceptsFirstMouse: (NSEvent *) event {
    return YES;
}

- (void) setVertical: (BOOL) vertical {
    [[self selectedCell] setVertical: vertical];
    [self setNeedsDisplay: YES];
}

- (id) titleCell {
    return [[self selectedCell] titleCell];
}

- (void) setTitle: (NSString *) title {
    [[self selectedCell] setTitle: title];
    [self setNeedsDisplay: YES];
}

- (NSString *) title {
    return [[self selectedCell] title];
}

- (void) setTitleColor: (NSColor *) color {
    [[self selectedCell] setTitleColor: color];
    [self setNeedsDisplay: YES];
}

- (NSColor *) titleColor {
    return [[self selectedCell] titleColor];
}

- (void) setTitleFont: (NSFont *) font {
    [[self selectedCell] setTitleFont: font];
    [self setNeedsDisplay: YES];
}

- (NSFont *) titleFont {
    return [[self selectedCell] titleFont];
}

- (void) setTrackFillColor: (NSColor *) color {
    if (_trackFillColor != color) {
        [_trackFillColor release];
        _trackFillColor = [color copy];
        [self setNeedsDisplay: YES];
    }
}

- (NSColor *) trackFillColor {
    return _trackFillColor;
}

- (void) dealloc {
    [_trackFillColor release];
    [super dealloc];
}

- (void) keyDown: (NSEvent *) event {
    [self interpretKeyEvents: [NSArray arrayWithObject: event]];
}

- (void) moveUp: (id) sender {
    [[self selectedCell] moveUp: sender];
    [self sendAction: [self action] to: [self target]];
    [self setNeedsDisplay: YES];
}

- (void) moveDown: (id) sender {
    [[self selectedCell] moveDown: sender];
    [self sendAction: [self action] to: [self target]];
    [self setNeedsDisplay: YES];
}

- (void) moveLeft: (id) sender {
    [[self selectedCell] moveLeft: sender];
    [self sendAction: [self action] to: [self target]];
    [self setNeedsDisplay: YES];
}

- (void) moveRight: (id) sender {
    [[self selectedCell] moveRight: sender];
    [self sendAction: [self action] to: [self target]];
    [self setNeedsDisplay: YES];
}

@end

@implementation NSSliderAccessory

- (instancetype) init {
    self = [super init];
    if (self)
        _enabled = YES;
    return self;
}

- (void) dealloc {
    [_behavior release];
    [super dealloc];
}

- (NSSliderAccessoryBehavior *) behavior {
    return _behavior;
}

- (void) setBehavior: (NSSliderAccessoryBehavior *) behavior {
    if (_behavior != behavior) {
        [_behavior release];
        _behavior = [behavior copy];
    }
}

- (BOOL) isEnabled {
    return _enabled;
}

- (void) setEnabled: (BOOL) enabled {
    _enabled = enabled;
}

@end

@implementation NSSliderAccessoryBehavior

- (instancetype) _initWithKind: (NSInteger) kind {
    self = [super init];
    if (self)
        _kind = kind;
    return self;
}

+ (NSSliderAccessoryBehavior *) valueStepBehavior {
    return [[[self alloc] _initWithKind: 1] autorelease];
}

+ (NSSliderAccessoryBehavior *) valueResetBehavior {
    return [[[self alloc] _initWithKind: 2] autorelease];
}

- (id) copyWithZone: (NSZone *) zone {
    return [[[self class] allocWithZone: zone] _initWithKind: _kind];
}

@end
