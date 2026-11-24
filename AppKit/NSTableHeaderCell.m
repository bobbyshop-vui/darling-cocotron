/* Copyright (c) 2006-2007 Christopher J. W. Lloyd <cjwl@objc.net>

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
#import <AppKit/AppKit.h>
#import <AppKit/NSGraphicsStyle.h>
#import <AppKit/NSRaise.h>
#import <AppKit/NSStringDrawer.h>

@implementation NSTableHeaderCell

- (NSRect) sortIndicatorRectForBounds: (NSRect) bounds {
    CGFloat width = MIN(8.0, MAX(0.0, bounds.size.width));
    CGFloat height = MIN(6.0, MAX(0.0, bounds.size.height));
    CGFloat x = MAX(bounds.origin.x, NSMaxX(bounds) - width - 3.0);
    CGFloat y = bounds.origin.y + (bounds.size.height - height) / 2.0;

    return NSMakeRect(x, y, width, height);
}

- (void) drawSortIndicatorWithFrame: (NSRect) frame
                             inView: (NSView *) controlView
                          ascending: (BOOL) ascending
                           priority: (NSInteger) priority
{
    NSRect indicator = [self sortIndicatorRectForBounds: frame];
    CGFloat midX = NSMidX(indicator);
    BOOL apexAtMaxY = ascending != [controlView isFlipped];
    NSBezierPath *path;

    (void) priority;
    if (NSIsEmptyRect(indicator))
        return;

    path = [NSBezierPath bezierPath];
    if (apexAtMaxY) {
        [path moveToPoint: NSMakePoint(NSMinX(indicator), NSMinY(indicator))];
        [path lineToPoint: NSMakePoint(midX, NSMaxY(indicator))];
        [path lineToPoint: NSMakePoint(NSMaxX(indicator), NSMinY(indicator))];
    } else {
        [path moveToPoint: NSMakePoint(NSMinX(indicator), NSMaxY(indicator))];
        [path lineToPoint: NSMakePoint(midX, NSMinY(indicator))];
        [path lineToPoint: NSMakePoint(NSMaxX(indicator), NSMaxY(indicator))];
    }
    [path closePath];
    [[NSColor controlTextColor] setFill];
    [path fill];
}

- (NSRect) titleRectForBounds: (NSRect) rect {
    rect.origin.x += 3.0;
    rect.origin.y += 2.5;
    rect.size.width -= 6.0;
    return rect;
}

- (void) drawWithFrame: (NSRect) cellFrame inView: (NSView *) controlView {
    _controlView = controlView;
    [[controlView graphicsStyle]
            drawTableViewHeaderInRect: cellFrame
                          highlighted: [self isHighlighted]];
    [[self attributedStringValue]
            _clipAndDrawInRect: [self titleRectForBounds: cellFrame]
                truncatingTail: (_lineBreakMode > NSLineBreakByClipping)];
}

@end
