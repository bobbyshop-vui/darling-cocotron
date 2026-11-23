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

#import <AppKit/NSLevelIndicatorCell.h>
#import <AppKit/NSRaise.h>

@implementation NSLevelIndicatorCell

- initWithLevelIndicatorStyle: (NSLevelIndicatorStyle) style {
    [super init];
    _style = style;
    _minValue = 0;
    _maxValue = (_style == NSContinuousCapacityLevelIndicatorStyle) ? 100 : 5;
    _warningValue = _maxValue;
    _criticalValue = _maxValue;
    _numberOfTickMarks = 0;
    _numberOfMajorTickMarks = 0;
    _tickMarkPosition = NSTickMarkBelow;
    return self;
}

- (NSLevelIndicatorStyle) levelIndicatorStyle {
    return _style;
}

- (double) minValue {
    return _minValue;
}

- (double) maxValue {
    return _maxValue;
}

- (double) warningValue {
    return _warningValue;
}

- (double) criticalValue {
    return _criticalValue;
}

- (int) numberOfTickMarks {
    return _numberOfTickMarks;
}

- (int) numberOfMajorTickMarks {
    return _numberOfMajorTickMarks;
}

- (NSTickMarkPosition) tickMarkPosition {
    return _tickMarkPosition;
}

- (void) setLevelIndicatorStyle: (NSLevelIndicatorStyle) style {
    _style = style;
}

- (void) setMinValue: (double) value {
    _minValue = value;
}

- (void) setMaxValue: (double) value {
    _maxValue = value;
}

- (void) setWarningValue: (double) value {
    _warningValue = value;
}

- (void) setCriticalValue: (double) value {
    _criticalValue = value;
}

- (void) setNumberOfTickMarks: (int) count {
    _numberOfTickMarks = count;
}

- (void) setNumberOfMajorTickMarks: (int) count {
    _numberOfMajorTickMarks = count;
}

- (void) setTickMarkPosition: (NSTickMarkPosition) position {
    _tickMarkPosition = position;
}

- (void) setImage: (NSImage *) image {
}

- (double) tickMarkValueAtIndex: (int) index {
    if (_numberOfTickMarks <= 0)
        return _minValue;
    if (index < 0 || index >= _numberOfTickMarks)
        [NSException raise: NSRangeException
                    format: @"tick mark index out of range in %@",
                            NSStringFromSelector(_cmd)];

    double scale = _numberOfTickMarks == 1
                           ? 0.5
                           : (double) index / (_numberOfTickMarks - 1);
    return _minValue + (_maxValue - _minValue) * scale;
}

- (NSRect) rectOfTickMarkAtIndex: (int) index {
    NSView *controlView = [self controlView];
    if (_numberOfTickMarks <= 0 || index < 0 ||
        index >= _numberOfTickMarks || controlView == nil)
        return NSZeroRect;

    NSRect bounds = [controlView bounds];
    BOOL vertical = NSHeight(bounds) > NSWidth(bounds);
    CGFloat inset = 2.0;
    CGFloat length = (vertical ? NSHeight(bounds) : NSWidth(bounds)) -
                     inset * 2;
    if (length < 0)
        length = 0;
    CGFloat offset = _numberOfTickMarks == 1
                             ? floor(length / 2.0)
                             : floor(index * length /
                                     (_numberOfTickMarks - 1));
    NSRect tick = NSZeroRect;

    if (vertical) {
        tick.size = NSMakeSize(3.0, 1.0);
        tick.origin.x = _tickMarkPosition == NSTickMarkAbove
                                ? NSMinX(bounds)
                                : NSMaxX(bounds) - tick.size.width;
        if ([controlView isFlipped])
            tick.origin.y = NSMaxY(bounds) - inset - offset - tick.size.height;
        else
            tick.origin.y = NSMinY(bounds) + inset + offset;
    } else {
        tick.size = NSMakeSize(1.0, 3.0);
        tick.origin.x = NSMinX(bounds) + inset + offset;
        BOOL above = _tickMarkPosition == NSTickMarkAbove;
        if ([controlView isFlipped])
            tick.origin.y = above ? NSMinY(bounds)
                                  : NSMaxY(bounds) - tick.size.height;
        else
            tick.origin.y = above ? NSMaxY(bounds) - tick.size.height
                                  : NSMinY(bounds);
    }

    return tick;
}

@end
