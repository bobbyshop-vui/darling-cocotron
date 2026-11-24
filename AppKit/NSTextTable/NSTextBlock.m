/* Copyright (c) 2007 Christopher J. W. Lloyd

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

#import <AppKit/NSColor.h>
#import <AppKit/NSGraphics.h>
#import <AppKit/NSRaise.h>
#import <AppKit/NSTextBlock.h>
#import <Foundation/NSArray.h>

static CGFloat NSTextBlockValue(CGFloat value, NSTextBlockValueType type,
                                CGFloat basis)
{
    if (type == NSTextBlockPercentageValueType)
        return basis * value / 100.0;
    return value;
}

static CGFloat NSTextBlockLayerExtent(NSTextBlock *block,
                                     NSTextBlockLayer layer, NSRectEdge edge,
                                     CGFloat basis)
{
    return NSTextBlockValue([block widthForLayer: layer edge: edge],
                            [block widthValueTypeForLayer: layer edge: edge],
                            basis);
}

static CGFloat NSTextBlockTotalInset(NSTextBlock *block, NSRectEdge edge,
                                     CGFloat basis)
{
    return NSTextBlockLayerExtent(block, NSTextBlockMargin, edge, basis) +
           NSTextBlockLayerExtent(block, NSTextBlockBorder, edge, basis) +
           NSTextBlockLayerExtent(block, NSTextBlockPadding, edge, basis);
}

@implementation NSTextBlock

- init {
    self = [super init];
    if (self == nil)
        return nil;
    _verticalAlignment = NSTextBlockTopAlignment;
    _borderColors = [[NSMutableArray alloc] initWithCapacity: NSMaxYEdge + 1];
    for (NSInteger edge = 0; edge <= NSMaxYEdge; edge++)
        [_borderColors addObject: [NSColor clearColor]];
    return self;
}

- (void) dealloc {
    [_backgroundColor release];
    [_borderColors release];
    [super dealloc];
}

- (NSColor *) backgroundColor {
    return _backgroundColor;
}

- (NSColor *) borderColorForEdge: (NSRectEdge) edge {
    return [_borderColors objectAtIndex: edge];
}

- (NSTextBlockVerticalAlignment) verticalAlignment {
    return _verticalAlignment;
}

- (CGFloat) contentWidth {
    return _contentWidth;
}

- (NSTextBlockValueType) contentWidthValueType {
    return _contentWidthValueType;
}

- (CGFloat) valueForDimension: (NSTextBlockDimension) dimension {
    return _dimensionValues[dimension];
}

- (NSTextBlockValueType) valueTypeForDimension: (NSTextBlockDimension) dimension
{
    if (dimension < NSTextBlockWidth || dimension > NSTextBlockMaximumHeight)
        return NSTextBlockAbsoluteValueType;
    return (NSTextBlockValueType) _dimensionValueTypes[dimension];
}

- (CGFloat) widthForLayer: (NSTextBlockLayer) layer edge: (NSRectEdge) edge {
    return _layerWidths[layer][edge];
}

- (NSTextBlockValueType) widthValueTypeForLayer: (NSTextBlockLayer) layer
                                           edge: (NSRectEdge) edge
{
    return _layerValueTypes[layer][edge];
}

- (void) setBackgroundColor: (NSColor *) color {
    color = [color copy];
    [_backgroundColor release];
    _backgroundColor = color;
}

- (void) setBorderColor: (NSColor *) color {
    int i, count = [_borderColors count];

    for (i = 0; i < count; i++)
        [_borderColors replaceObjectAtIndex: i withObject: color];
}

- (void) setBorderColor: (NSColor *) color forEdge: (NSRectEdge) edge {
    [_borderColors replaceObjectAtIndex: edge withObject: color];
}

- (void) setVerticalAlignment: (NSTextBlockVerticalAlignment) alignment {
    _verticalAlignment = alignment;
}

- (void) setContentWidth: (CGFloat) width type: (NSTextBlockValueType) type {
    _contentWidth = width;
    _contentWidthValueType = type;
}

- (void) setValue: (CGFloat) value
                type: (NSTextBlockValueType) type
        forDimension: (NSTextBlockDimension) dimension
{
    _dimensionValues[dimension] = value;
    _dimensionValueTypes[dimension] = type;
}

- (void) setWidth: (CGFloat) value
             type: (NSTextBlockValueType) type
         forLayer: (NSTextBlockLayer) layer
{
    int i;

    for (i = 0; i <= NSMaxYEdge; i++) {
        _layerWidths[layer][i] = value;
        _layerValueTypes[layer][i] = type;
    }
}

- (void) setWidth: (CGFloat) value
             type: (NSTextBlockValueType) type
         forLayer: (NSTextBlockLayer) layer
             edge: (NSRectEdge) edge
{
    _layerWidths[layer][edge] = value;
    _layerValueTypes[layer][edge] = type;
}

- (NSRect) rectForLayoutAtPoint: (NSPoint) point
                         inRect: (NSRect) rect
                  textContainer: (NSTextContainer *) textContainer
                 characterRange: (NSRange) range
{
    CGFloat left = NSTextBlockTotalInset(self, NSMinXEdge, rect.size.width);
    CGFloat right = NSTextBlockTotalInset(self, NSMaxXEdge, rect.size.width);
    CGFloat top = NSTextBlockTotalInset(self, NSMaxYEdge, rect.size.height);
    CGFloat bottom = NSTextBlockTotalInset(self, NSMinYEdge, rect.size.height);
    CGFloat availableWidth = MAX(0.0, rect.size.width - left - right);
    CGFloat availableHeight = MAX(0.0, rect.size.height - top - bottom);
    CGFloat width = _dimensionValues[NSTextBlockWidth] > 0.0
            ? NSTextBlockValue(_dimensionValues[NSTextBlockWidth],
                               [self valueTypeForDimension: NSTextBlockWidth],
                               rect.size.width)
            : availableWidth;
    CGFloat height = _dimensionValues[NSTextBlockHeight] > 0.0
            ? NSTextBlockValue(_dimensionValues[NSTextBlockHeight],
                               [self valueTypeForDimension: NSTextBlockHeight],
                               rect.size.height)
            : availableHeight;
    CGFloat minimumWidth = NSTextBlockValue(
            _dimensionValues[NSTextBlockMinimumWidth],
            [self valueTypeForDimension: NSTextBlockMinimumWidth], rect.size.width);
    CGFloat maximumWidth = NSTextBlockValue(
            _dimensionValues[NSTextBlockMaximumWidth],
            [self valueTypeForDimension: NSTextBlockMaximumWidth], rect.size.width);
    CGFloat minimumHeight = NSTextBlockValue(
            _dimensionValues[NSTextBlockMinimumHeight],
            [self valueTypeForDimension: NSTextBlockMinimumHeight], rect.size.height);
    CGFloat maximumHeight = NSTextBlockValue(
            _dimensionValues[NSTextBlockMaximumHeight],
            [self valueTypeForDimension: NSTextBlockMaximumHeight], rect.size.height);

    width = MAX(width, minimumWidth);
    height = MAX(height, minimumHeight);
    if (maximumWidth > 0.0)
        width = MIN(width, maximumWidth);
    if (maximumHeight > 0.0)
        height = MIN(height, maximumHeight);

    return NSMakeRect(point.x + left, point.y + bottom, width, height);
}

- (NSRect) boundsRectForContentRect: (NSRect) contentRect
                             inRect: (NSRect) rect
                      textContainer: (NSTextContainer *) textContainer
                     characterRange: (NSRange) range
{
    CGFloat left = NSTextBlockTotalInset(self, NSMinXEdge, rect.size.width);
    CGFloat right = NSTextBlockTotalInset(self, NSMaxXEdge, rect.size.width);
    CGFloat top = NSTextBlockTotalInset(self, NSMaxYEdge, rect.size.height);
    CGFloat bottom = NSTextBlockTotalInset(self, NSMinYEdge, rect.size.height);
    CGFloat width = contentRect.size.width + left + right;
    CGFloat height = contentRect.size.height + top + bottom;
    CGFloat minimumWidth = NSTextBlockValue(
            _dimensionValues[NSTextBlockMinimumWidth],
            [self valueTypeForDimension: NSTextBlockMinimumWidth], rect.size.width);
    CGFloat maximumWidth = NSTextBlockValue(
            _dimensionValues[NSTextBlockMaximumWidth],
            [self valueTypeForDimension: NSTextBlockMaximumWidth], rect.size.width);
    CGFloat minimumHeight = NSTextBlockValue(
            _dimensionValues[NSTextBlockMinimumHeight],
            [self valueTypeForDimension: NSTextBlockMinimumHeight], rect.size.height);
    CGFloat maximumHeight = NSTextBlockValue(
            _dimensionValues[NSTextBlockMaximumHeight],
            [self valueTypeForDimension: NSTextBlockMaximumHeight], rect.size.height);

    width = MAX(width, minimumWidth);
    height = MAX(height, minimumHeight);
    if (maximumWidth > 0.0)
        width = MIN(width, maximumWidth);
    if (maximumHeight > 0.0)
        height = MIN(height, maximumHeight);

    return NSMakeRect(contentRect.origin.x - left, contentRect.origin.y - bottom,
                      width, height);
}

- (void) drawBackgroundWithFrame: (NSRect) frame
                          inView: (NSView *) view
                  characterRange: (NSRange) range
                   layoutManager: (NSLayoutManager *) layoutManager
{
    if (_backgroundColor != nil) {
        [_backgroundColor set];
        NSRectFill(frame);
    }

    for (NSInteger edge = 0; edge <= NSMaxYEdge; edge++) {
        NSColor *color = [_borderColors objectAtIndex: edge];
        CGFloat basis = (edge == NSMinXEdge || edge == NSMaxXEdge)
                ? frame.size.width : frame.size.height;
        CGFloat width = NSTextBlockLayerExtent(self, NSTextBlockBorder,
                                               (NSRectEdge) edge, basis);
        if (width <= 0.0 || color == [NSColor clearColor])
            continue;

        NSRect border = frame;
        if (edge == NSMinXEdge)
            border.size.width = width;
        else if (edge == NSMaxXEdge) {
            border.origin.x = NSMaxX(frame) - width;
            border.size.width = width;
        } else if (edge == NSMinYEdge)
            border.size.height = width;
        else {
            border.origin.y = NSMaxY(frame) - width;
            border.size.height = width;
        }
        [color set];
        NSRectFill(border);
    }
}

@end
