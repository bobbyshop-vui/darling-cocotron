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
#import <QuartzCore/CAOpenGLLayer.h>
#import <CoreVideo/CVBase.h>
#import <AppKit/NSOpenGLContext.h>
#import <AppKit/NSOpenGLPixelFormat.h>

@class NSView;

@interface NSOpenGLLayer : CAOpenGLLayer {
    NSView *_view;
    NSOpenGLPixelFormat *_openGLPixelFormat;
    NSOpenGLContext *_openGLContext;
}

@property (nullable, weak) NSView *view;
@property (nullable, strong) NSOpenGLPixelFormat *openGLPixelFormat;
@property (nullable, strong) NSOpenGLContext *openGLContext;

- (NSOpenGLPixelFormat *) openGLPixelFormatForDisplayMask: (uint32_t) mask;
- (NSOpenGLContext *) openGLContextForPixelFormat: (NSOpenGLPixelFormat *) pixelFormat;
- (BOOL) canDrawInOpenGLContext: (NSOpenGLContext *) context
                    pixelFormat: (NSOpenGLPixelFormat *) pixelFormat
                   forLayerTime: (CFTimeInterval) t
                    displayTime: (const CVTimeStamp *) ts;
- (void) drawInOpenGLContext: (NSOpenGLContext *) context
                 pixelFormat: (NSOpenGLPixelFormat *) pixelFormat
                forLayerTime: (CFTimeInterval) t
                 displayTime: (const CVTimeStamp *) ts;

@end
