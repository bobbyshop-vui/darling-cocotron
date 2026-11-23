/*
 This file is part of Darling.

 Copyright (C) 2025 Darling Developers

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

#import <AppKit/NSPICTImageRep.h>

/* A PICT file has an optional 512 byte header, then: picSize (2 bytes), picFrame (top, left,
   bottom, right as big endian SInt16) and the version opcode (0x0011 0x01 for version 1,
   0x0011 0x02FF for version 2). */
static BOOL PICTParse(NSData *data, NSRect *frame)
{
    const uint8_t *bytes = [data bytes];
    NSUInteger length = [data length];
    NSUInteger offsets[2] = { 512, 0 };

    for (int i = 0; i < 2; i++) {
        NSUInteger o = offsets[i];
        if (length < o + 16)
            continue;
        const uint8_t *p = bytes + o;
        BOOL v2 = p[10] == 0x00 && p[11] == 0x11 && p[12] == 0x02 && p[13] == 0xFF;
        BOOL v1 = p[10] == 0x11 && p[11] == 0x01;
        if (!v2 && !v1)
            continue;
        int16_t top = (int16_t)((p[2] << 8) | p[3]);
        int16_t left = (int16_t)((p[4] << 8) | p[5]);
        int16_t bottom = (int16_t)((p[6] << 8) | p[7]);
        int16_t right = (int16_t)((p[8] << 8) | p[9]);
        if (right < left || bottom < top)
            continue;
        if (frame != NULL)
            *frame = NSMakeRect(left, top, right - left, bottom - top);
        return YES;
    }
    return NO;
}

@implementation NSPICTImageRep

+ (BOOL)canInitWithData:(NSData *)data
{
    return data != nil && PICTParse(data, NULL);
}

+ (NSArray *)imageUnfilteredFileTypes
{
    return [NSArray arrayWithObjects:@"pict", @"pct", @"pic", nil];
}

+ (NSArray *)imageUnfilteredPasteboardTypes
{
    return [NSArray arrayWithObject:@"com.apple.pict"];
}

+ (instancetype)imageRepWithData:(NSData *)pictData
{
    return [[[self alloc] initWithData:pictData] autorelease];
}

- (instancetype)initWithData:(NSData *)pictData
{
    NSRect frame;
    if (pictData == nil || !PICTParse(pictData, &frame)) {
        [self release];
        return nil;
    }
    if ((self = [super init]) != nil) {
        _pictData = [pictData copy];
        _boundingBox = frame;
        _pictOrigin = frame.origin;
        [self setSize:frame.size];
        [self setPixelsWide:(int)frame.size.width];
        [self setPixelsHigh:(int)frame.size.height];
        [self setOpaque:NO];
        [self setAlpha:NO];
        [self setBitsPerSample:8];
        [self setColorSpaceName:@"NSCalibratedRGBColorSpace"];
    }
    return self;
}

- (void)dealloc
{
    [_pictData release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    NSPICTImageRep *copy = [super copyWithZone:zone];
    copy->_pictData = [_pictData copy];
    copy->_boundingBox = _boundingBox;
    copy->_pictOrigin = _pictOrigin;
    return copy;
}

- (NSData *)PICTRepresentation
{
    return _pictData;
}

- (NSRect)boundingBox
{
    return _boundingBox;
}

- (BOOL)draw
{
    /* No QuickDraw picture interpreter is available, so the picture cannot be rendered. */
    return NO;
}

@end
