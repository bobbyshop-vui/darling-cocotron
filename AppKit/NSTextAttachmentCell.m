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
#import <AppKit/NSRaise.h>
#import <AppKit/NSTextAttachmentCell.h>
#import <AppKit/NSTextAttachment.h>
#import <AppKit/NSImage.h>

@implementation NSTextAttachmentCell

- (NSTextAttachment *) attachment {
    return _attachment;
}

- (void) setAttachment: (NSTextAttachment *) attachment {
    _attachment = attachment;
}

- (NSSize) cellSize {
    NSRect bounds = [_attachment bounds];
    if (bounds.size.width != 0 || bounds.size.height != 0)
        return bounds.size;

    NSImage *image = [self image];
    if (image == nil)
        image = [_attachment image];
    return (image != nil) ? [image size] : NSZeroSize;
}

- (NSPoint) cellBaselineOffset {
    return NSZeroPoint;
}

- (NSRect) cellFrameForTextContainer: (NSTextContainer *) textContainer
                proposedLineFragment: (NSRect) proposedRect
                       glyphPosition: (NSPoint) glyphPoint
                      characterIndex: (unsigned) characterIndex
{
    NSRect bounds = [_attachment bounds];
    NSSize size = [self cellSize];

    if (bounds.size.width == 0 && bounds.size.height == 0)
        bounds.size = size;

    bounds.origin.x += glyphPoint.x;
    bounds.origin.y += glyphPoint.y;
    return bounds;
}

- (BOOL) wantsToTrackMouse {
    return YES;
}

- (BOOL) wantsToTrackMouseForEvent: (NSEvent *) event
                            inRect: (NSRect) rect
                            ofView: (NSView *) view
                  atCharacterIndex: (unsigned) characterIndex
{
    return [self wantsToTrackMouse];
}

- (BOOL) trackMouse: (NSEvent *) event
                  inRect: (NSRect) rect
                  ofView: (NSView *) view
        atCharacterIndex: (unsigned) characterIndex
            untilMouseUp: (BOOL) untilMouseUp
{
    return [super trackMouse: event
                      inRect: rect
                      ofView: view
                untilMouseUp: untilMouseUp];
}

- (BOOL) trackMouse: (NSEvent *) event
              inRect: (NSRect) rect
              ofView: (NSView *) view
        untilMouseUp: (BOOL) untilMouseUp
{
    return [super trackMouse: event
                      inRect: rect
                      ofView: view
                untilMouseUp: untilMouseUp];
}

- (void) highlight: (BOOL) highlight
         withFrame: (NSRect) frame
            inView: (NSView *) view
{
    [super highlight: highlight withFrame: frame inView: view];
}

- (void) drawWithFrame: (NSRect) frame
                inView: (NSView *) view
        characterIndex: (unsigned) characterIndex
         layoutManager: (NSLayoutManager *) layoutManager
{
    [self drawWithFrame: frame inView: view characterIndex: characterIndex];
}

- (void) drawWithFrame: (NSRect) frame
                inView: (NSView *) view
        characterIndex: (unsigned) characterIndex
{
    [self drawWithFrame: frame inView: view];
}

- (void) drawWithFrame: (NSRect) frame inView: (NSView *) view {
    NSImage *image = [self image];
    if (image == nil)
        image = [_attachment image];

    if (image != nil)
        [image drawInRect: frame];
    else
        [super drawWithFrame: frame inView: view];
}

@end

@implementation NSViewTextAttachmentCell
@end
