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

#import <AppKit/NSOpenGLLayer.h>
#import <AppKit/NSView.h>

@implementation NSOpenGLLayer

- (void) dealloc
{
    [_openGLPixelFormat release];
    [_openGLContext release];
    [super dealloc];
}

- (NSView *) view
{
    return _view;
}

- (void) setView: (NSView *) view
{
    _view = view;
}

- (NSOpenGLPixelFormat *) openGLPixelFormat
{
    return _openGLPixelFormat;
}

- (void) setOpenGLPixelFormat: (NSOpenGLPixelFormat *) pixelFormat
{
    if (_openGLPixelFormat != pixelFormat) {
        [_openGLPixelFormat release];
        _openGLPixelFormat = [pixelFormat retain];
    }
}

- (NSOpenGLContext *) openGLContext
{
    return _openGLContext;
}

- (void) setOpenGLContext: (NSOpenGLContext *) context
{
    if (_openGLContext != context) {
        [_openGLContext release];
        _openGLContext = [context retain];
    }
}

- (NSOpenGLPixelFormat *) openGLPixelFormatForDisplayMask: (uint32_t) mask
{
    NSOpenGLPixelFormatAttribute attributes[] = {
        NSOpenGLPFAScreenMask, mask,
        NSOpenGLPFAAccelerated,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAColorSize, 24,
        NSOpenGLPFAAlphaSize, 8,
        0
    };

    return [[[NSOpenGLPixelFormat alloc] initWithAttributes: attributes]
            autorelease];
}

- (NSOpenGLContext *) openGLContextForPixelFormat: (NSOpenGLPixelFormat *) pixelFormat
{
    return [[[NSOpenGLContext alloc] initWithFormat: pixelFormat
                                       shareContext: nil] autorelease];
}

- (BOOL) canDrawInOpenGLContext: (NSOpenGLContext *) context
                    pixelFormat: (NSOpenGLPixelFormat *) pixelFormat
                   forLayerTime: (CFTimeInterval) t
                    displayTime: (const CVTimeStamp *) ts
{
    return YES;
}

- (void) drawInOpenGLContext: (NSOpenGLContext *) context
                 pixelFormat: (NSOpenGLPixelFormat *) pixelFormat
                forLayerTime: (CFTimeInterval) t
                 displayTime: (const CVTimeStamp *) ts
{
    // The default implementation draws nothing; subclasses issue GL commands.
}

@end
