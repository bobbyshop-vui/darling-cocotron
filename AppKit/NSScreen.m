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

// Original - Christopher Lloyd <cjwl@objc.net>
#import <AppKit/NSApplication.h>
#import <AppKit/NSColorSpace.h>
#import <AppKit/NSDisplay.h>
#import <AppKit/NSScreen.h>
#import <AppKit/NSWindow.h>

NSNotificationName const NSScreenColorSpaceDidChangeNotification = @"NSScreenColorSpaceDidChangeNotification";

@implementation NSScreen

- initWithFrame: (NSRect) frame visibleFrame: (NSRect) visibleFrame {
    _frame = frame;
    _visibleFrame = visibleFrame;
    return self;
}

- (void) dealloc {
    if (_edid)
        [_edid release];
    [super dealloc];
}

+ (NSScreen *) mainScreen {
    NSScreen *result = [[NSApp keyWindow] screen];

    if (result == nil)
        result = [[self screens] objectAtIndex: 0];

    return result;
}

+ (NSScreen *) deepestScreen {
    NSScreen *best = nil;
    for (NSScreen *screen in [self screens]) {
        if (best == nil || [screen depth] > [best depth])
            best = screen;
    }
    return best;
}

+ (NSArray *) screens {
    return [[NSDisplay currentDisplay] screens];
}

- (NSWindowDepth) depth {
    return _depth;
}

- (NSRect) frame {
    return _frame;
}

- (NSRect) visibleFrame {
    return _visibleFrame;
}

- (CGFloat) userSpaceScaleFactor {
    return 1.0;
}

- (CGFloat) backingScaleFactor {
    // No Retina backing stores are available.
    return 1.0;
}

- (NSColorSpace *) colorSpace {
    return [NSColorSpace genericRGBColorSpace];
}

- (BOOL) canRepresentDisplayGamut: (NSInteger) displayGamut {
    // Only sRGB (NSDisplayGamutSRGB == 1) is available; P3 is not.
    return displayGamut == 1;
}

- (NSRect) convertRectToBacking: (NSRect) rect {
    CGFloat scale = [self backingScaleFactor];

    return NSMakeRect(rect.origin.x * scale, rect.origin.y * scale,
                      rect.size.width * scale, rect.size.height * scale);
}

- (NSRect) convertRectFromBacking: (NSRect) rect {
    CGFloat scale = [self backingScaleFactor];

    return NSMakeRect(rect.origin.x / scale, rect.origin.y / scale,
                      rect.size.width / scale, rect.size.height / scale);
}

- (NSRect) backingAlignedRect: (NSRect) rect options: (NSAlignmentOptions) options {
    NSRect backing = [self convertRectToBacking: rect];
    backing = NSIntegralRectWithOptions(backing, options);
    return [self convertRectFromBacking: backing];
}

- (id) description {
    return [NSString stringWithFormat: @"< %@ - frame %@, visible %@ >",
                                       [super description],
                                       NSStringFromRect(_frame),
                                       NSStringFromRect(_visibleFrame)];
}

- (NSDictionary<NSDeviceDescriptionKey, id> *) deviceDescription {
    return @{};
}

@end

@implementation NSScreen (Darling)
- (NSData *) edid {
    return self->_edid;
}

- (void) setEdid: (NSData *) data {
    NSData *old = self->_edid;
    self->_edid = [data retain];
    [old release];
}

- (CGDirectDisplayID) cgDirectDisplayID {
    return self->_directDisplayID;
}

- (void) setCgDirectDisplayID: (CGDirectDisplayID) displayID {
    self->_directDisplayID = displayID;
}

@end
