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

#import <AppKit/NSBitmapImageRep-Private.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSGraphicsContextFunctions.h>
#import <AppKit/NSPasteboard.h>
#import <AppKit/NSRaise.h>
#import <AppKit/NSView.h>
#import <objc/message.h>
#import <objc/runtime.h>

NSBitmapImageRepPropertyKey NSImageCompressionFactor =
        @"NSImageCompressionFactor";
NSBitmapImageRepPropertyKey NSImageCompressionMethod =
        @"NSImageCompressionMethod";
NSBitmapImageRepPropertyKey NSImageDitherTransparency =
        @"NSImageDitherTransparency";
NSBitmapImageRepPropertyKey NSImageInterlaced = @"NSImageInterlaced";
NSBitmapImageRepPropertyKey NSImageRGBColorTable = @"NSImageRGBColorTable";
NSBitmapImageRepPropertyKey NSImageFrameCount = @"NSImageFrameCount";
NSBitmapImageRepPropertyKey NSImageColorSyncProfileData =
        @"NSImageColorSyncProfileData";
NSBitmapImageRepPropertyKey NSImageFallbackBackgroundColor =
        @"NSImageFallbackBackgroundColor";
NSBitmapImageRepPropertyKey NSImageEXIFData = @"NSImageEXIFData";
NSBitmapImageRepPropertyKey NSImageProgressive = @"NSImageProgressive";
NSBitmapImageRepPropertyKey NSImageGamma = @"NSImageGamma";
NSBitmapImageRepPropertyKey NSImageLoopCount = @"NSImageLoopCount";
NSBitmapImageRepPropertyKey NSImageCurrentFrameDuration =
        @"NSImageCurrentFrameDuration";
NSBitmapImageRepPropertyKey NSImageCurrentFrame = @"NSImageCurrentFrame";

static char NSBitmapImageRepIncrementalDataKey;
static char NSBitmapImageRepCompressionPropertiesKey;

@implementation NSBitmapImageRep

+ (NSArray *) imageUnfilteredFileTypes {
    return [NSArray arrayWithObjects:
                            // Try to order them so the most used ones are at
                            // the top of the list
                            @"png", @"tiff", @"tif", @"jpg", @"jpeg", @"icns",
                            @"gif", @"bmp", @"PNG", @"TIFF", @"TIF", @"JPG",
                            @"JPEG", @"ICNS", @"jpe", @"JPE", @"GIF", @"BMP",
                            nil];
}

+ (NSArray *) imageRepsWithContentsOfFile: (NSString *) path {
    NSData *data = [NSData dataWithContentsOfFile: path];

    if (data == nil)
        return nil;

    if ([self canInitWithData: data])
        return [self imageRepsWithData: data];

    return nil;
}

+ (void) getTIFFCompressionTypes: (const NSTIFFCompression **) types
                           count: (int *) count
{
    static const NSTIFFCompression compressionTypes[] = {
        NSTIFFCompressionNone, NSTIFFCompressionCCITTFAX3,
        NSTIFFCompressionCCITTFAX4, NSTIFFCompressionLZW,
        NSTIFFCompressionPackBits
    };

    if (types != NULL)
        *types = compressionTypes;
    if (count != NULL)
        *count = sizeof(compressionTypes) / sizeof(compressionTypes[0]);
}

+ (NSString *) localizedNameForTIFFCompressionType: (NSTIFFCompression) type {
    switch (type) {
    case NSTIFFCompressionNone:
        return NSLocalizedString(@"None", nil);
    case NSTIFFCompressionCCITTFAX3:
        return NSLocalizedString(@"CCITT Fax 3", nil);
    case NSTIFFCompressionCCITTFAX4:
        return NSLocalizedString(@"CCITT Fax 4", nil);
    case NSTIFFCompressionLZW:
        return NSLocalizedString(@"LZW", nil);
    case NSTIFFCompressionJPEG:
        return NSLocalizedString(@"JPEG", nil);
    case NSTIFFCompressionNEXT:
        return NSLocalizedString(@"NeXT", nil);
    case NSTIFFCompressionPackBits:
        return NSLocalizedString(@"PackBits", nil);
    case NSTIFFCompressionOldJPEG:
        return NSLocalizedString(@"Old JPEG", nil);
    default:
        return nil;
    }
}

+ (NSData *) TIFFRepresentationOfImageRepsInArray: (NSArray *) array {
    return [self TIFFRepresentationOfImageRepsInArray: array
                                     usingCompression: NSTIFFCompressionNone
                                               factor: 0.0];
}

+ (NSData *) TIFFRepresentationOfImageRepsInArray: (NSArray *) array
                                 usingCompression:
                                         (NSTIFFCompression) compression
                                           factor: (float) factor
{
    NSMutableData *result = [NSMutableData data];
    CGImageDestinationRef dest = CGImageDestinationCreateWithData(
            (CFMutableDataRef) result, (CFStringRef) @"public.tiff",
            [array count], NULL);

    for (NSBitmapImageRep *bitmap in array) {
        CGImageDestinationAddImage(dest, [bitmap CGImage], NULL);
    }

    CGImageDestinationFinalize(dest);
    CFRelease(dest);

    return result;
}

+ (NSData *) representationOfImageRepsInArray: (NSArray *) array
                                    usingType: (NSBitmapImageFileType) type
                                   properties: (NSDictionary *) properties
{
    CFStringRef uti = NULL;
    switch (type) {
    case NSTIFFFileType:
        uti = (CFStringRef) @"public.tiff";
        break;
    case NSBMPFileType:
        uti = (CFStringRef) @"com.microsoft.bmp";
        break;
    case NSGIFFileType:
        uti = (CFStringRef) @"com.compuserve.gif";
        break;
    case NSJPEGFileType:
        uti = (CFStringRef) @"public.jpeg";
        break;
    case NSPNGFileType:
        uti = (CFStringRef) @"public.png";
        break;
    case NSJPEG2000FileType:
        uti = (CFStringRef) @"public.jpeg-2000";
        break;
    default:
        return nil;
    }

    if ([array count] == 0)
        return nil;

    NSMutableDictionary *imageProperties =
            [NSMutableDictionary dictionaryWithDictionary:
                                              (properties != nil
                                                       ? properties
                                                       : [NSDictionary dictionary])];
    id compressionFactor =
            [properties objectForKey: NSImageCompressionFactor];
    if (compressionFactor != nil) {
        [imageProperties setObject: compressionFactor
                            forKey: (id) kCGImageDestinationLossyCompressionQuality];
        [imageProperties removeObjectForKey: NSImageCompressionFactor];
    }

    NSMutableData *data = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData(
            (CFMutableDataRef) data, uti, [array count], NULL);
    if (destination == NULL)
        return nil;

    BOOL valid = YES;
    for (NSImageRep *imageRep in array) {
        NSRect proposedRect = NSMakeRect(0, 0, [imageRep size].width,
                                        [imageRep size].height);
        CGImageRef image = [imageRep CGImageForProposedRect: &proposedRect
                                                    context: nil
                                                      hints: nil];
        if (image == NULL) {
            valid = NO;
            break;
        }

        NSMutableDictionary *perImageProperties =
                [NSMutableDictionary dictionaryWithDictionary: imageProperties];
        NSSize size = [imageRep size];
        int dpi = size.width > 0
                          ? (int) ceilf(72 * [imageRep pixelsWide] / size.width)
                          : 72;
        [perImageProperties setObject: [NSNumber numberWithInt: dpi]
                               forKey: (id) kCGImageDestinationDPI];
        CGImageDestinationAddImage(destination, image,
                                  (CFDictionaryRef) perImageProperties);
    }

    BOOL finalized = valid && CGImageDestinationFinalize(destination);
    CFRelease(destination);
    return finalized ? data : nil;
}

+ (NSArray *) imageUnfilteredPasteboardTypes {
    return [NSArray arrayWithObjects: NSTIFFPboardType, nil];
}

+ (BOOL) canInitWithData: (NSData *) data {
    CGImageSourceRef imageSource =
            CGImageSourceCreateWithData((CFDataRef) data, nil);
    BOOL result = (imageSource != NULL) ? YES : NO;
    CFRelease(imageSource);
    return result;
}

+ (NSArray *) imageRepsWithData: (NSData *) data {
    NSMutableArray *result = [NSMutableArray array];
    CGImageSourceRef imageSource =
            CGImageSourceCreateWithData((CFDataRef) data, nil);

    if (imageSource == nil)
        return nil;

    size_t i, count = CGImageSourceGetCount(imageSource);

    for (i = 0; i < count; i++) {
        CGImageRef cgImage =
                CGImageSourceCreateImageAtIndex(imageSource, i, nil);

        if (cgImage == nil)
            break;

        CFDictionaryRef properties =
                CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil);
        NSNumber *xres = [[(id) CFDictionaryGetValue(
                properties, kCGImagePropertyDPIWidth) copy] autorelease];
        NSNumber *yres = [[(id) CFDictionaryGetValue(
                properties, kCGImagePropertyDPIHeight) copy] autorelease];

        CFRelease(properties);

        NSBitmapImageRep *imageRep = [[self alloc] initWithCGImage: cgImage];
        NSSize size = {CGImageGetWidth(cgImage), CGImageGetHeight(cgImage)};

        CGImageRelease(cgImage);

        if (xres != nil && [xres doubleValue] > 0)
            size.width *= 72.0 / [xres doubleValue];

        if (yres != nil && [yres doubleValue] > 0)
            size.height *= 72.0 / [yres doubleValue];

        [imageRep setSize: size];

        if (imageRep != nil)
            [result addObject: imageRep];

        [imageRep release];
    }

    CFRelease(imageSource);

    return result;
}

+ imageRepWithData: (NSData *) data {
    return [[[self alloc] initWithData: data] autorelease];
}

- initWithBitmapDataPlanes: (unsigned char **) planes
                pixelsWide: (int) width
                pixelsHigh: (int) height
             bitsPerSample: (int) bitsPerSample
           samplesPerPixel: (int) samplesPerPixel
                  hasAlpha: (BOOL) hasAlpha
                  isPlanar: (BOOL) isPlanar
            colorSpaceName: (NSString *) colorSpaceName
              bitmapFormat: (NSBitmapFormat) bitmapFormat
               bytesPerRow: (int) bytesPerRow
              bitsPerPixel: (int) bitsPerPixel
{
    int i, numberOfPlanes = isPlanar ? samplesPerPixel : 1;

    _size = NSMakeSize(width, height);
    _colorSpaceName = [colorSpaceName copy];
    _bitsPerSample = bitsPerSample;
    _pixelsWide = width;
    _pixelsHigh = height;
    _hasAlpha = hasAlpha;

    _samplesPerPixel = samplesPerPixel;
    _isPlanar = isPlanar;
    _bitmapFormat = bitmapFormat;

    if (bitsPerPixel != 0)
        _bitsPerPixel = bitsPerPixel;
    else
        _bitsPerPixel = _bitsPerSample * _samplesPerPixel;

    if (bytesPerRow != 0)
        _bytesPerRow = bytesPerRow;
    else
        _bytesPerRow = (_bitsPerPixel * _pixelsWide + 7) / 8;

    _freeWhenDone = NO;
    if (planes == NULL)
        _freeWhenDone = YES;
    else {
        int i;

        for (i = 0; i < numberOfPlanes; i++)
            if (planes[i] != NULL)
                break;

        if (i == numberOfPlanes)
            _freeWhenDone = YES;
    }

    _bitmapPlanes = NSZoneCalloc(NULL, numberOfPlanes, sizeof(unsigned char *));
    for (i = 0; i < numberOfPlanes; i++) {
        if (!_freeWhenDone)
            _bitmapPlanes[i] = planes[i];
        else
            _bitmapPlanes[i] =
                    NSZoneCalloc(NULL, _bytesPerRow * _pixelsHigh, 1);
    }

    return self;
}

- initWithBitmapDataPlanes: (unsigned char **) planes
                pixelsWide: (int) width
                pixelsHigh: (int) height
             bitsPerSample: (int) bitsPerSample
           samplesPerPixel: (int) samplesPerPixel
                  hasAlpha: (BOOL) hasAlpha
                  isPlanar: (BOOL) isPlanar
            colorSpaceName: (NSString *) colorSpaceName
               bytesPerRow: (int) bytesPerRow
              bitsPerPixel: (int) bitsPerPixel
{
    return [self initWithBitmapDataPlanes: planes
                               pixelsWide: width
                               pixelsHigh: height
                            bitsPerSample: bitsPerSample
                          samplesPerPixel: samplesPerPixel
                                 hasAlpha: hasAlpha
                                 isPlanar: isPlanar
                           colorSpaceName: colorSpaceName
                             bitmapFormat: 0
                              bytesPerRow: bytesPerRow
                             bitsPerPixel: bitsPerPixel];
}

- initForIncrementalLoad {
    NSMutableData *data = [[NSMutableData alloc] init];
    objc_setAssociatedObject(self, &NSBitmapImageRepIncrementalDataKey, data,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [data release];
    return self;
}

- initWithFocusedViewRect: (NSRect) rect {
    CGContextRef graphicsPort = NSCurrentGraphicsPort();

    if (graphicsPort == NULL) {
        [self dealloc];
        return nil;
    }

    [self initWithData: (NSData *) CGContextCaptureBitmap(graphicsPort, rect)];

    return self;
}

- initWithData: (NSData *) data {
    CGImageSourceRef imageSource =
            CGImageSourceCreateWithData((CFDataRef) data, nil);

    if (imageSource == nil) {
        [self dealloc];
        return nil;
    }

    CGImageRef cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil);

    if (cgImage == nil) {
        CFRelease(imageSource);
        [self dealloc];
        return nil;
    }

    CFDictionaryRef properties =
            CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil);
    NSNumber *xres =
            [[(id) CFDictionaryGetValue(properties, kCGImagePropertyDPIWidth)
                    copy] autorelease];
    NSNumber *yres =
            [[(id) CFDictionaryGetValue(properties, kCGImagePropertyDPIHeight)
                    copy] autorelease];

    CFRelease(properties);
    CFRelease(imageSource);

    if (cgImage == nil) {
        [self dealloc];
        return nil;
    }

    if ((self = [self initWithCGImage: cgImage]) == nil)
        return nil;

    CGImageRelease(cgImage);

    if (xres != nil && [xres doubleValue] > 0)
        _size.width *= 72.0 / [xres doubleValue];

    if (yres != nil && [yres doubleValue] > 0)
        _size.height *= 72.0 / [yres doubleValue];

    return self;
}

- initWithContentsOfFile: (NSString *) path {
    NSData *data = [NSData dataWithContentsOfFile: path];

    if (data == nil) {
        [self dealloc];
        return nil;
    }

    return [self initWithData: data];
}

- (instancetype) initWithCoder:(NSCoder *) coder {
    if ([coder allowsKeyedCoding]) {
        [NSException raise: NSInvalidArgumentException
                    format: @"-[%@ %s] is not implemented for coder %@",
                            [self class], sel_getName(_cmd), coder];
        return nil;
    } else {
        NSInteger version = [coder versionForClassName: @"NSImageRep"];

        if (version >= 17) {
            NSData *data = [coder decodeDataObject];
            return [self initWithData: data];
        } else {
            [NSException raise: NSInvalidArgumentException
                    format: @"-[%@ %s] is not implemented for coder %@",
                            [self class], sel_getName(_cmd), coder];
            return nil;
        }
    }
}

- (void) createBitmapIfNeeded {
    if (_bitmapPlanes == NULL) {
        _freeWhenDone = YES;
        _bitmapPlanes = NSZoneCalloc(NULL, 1, sizeof(unsigned char *));
        _bitmapPlanes[0] = NSZoneCalloc(NULL, _bytesPerRow * _pixelsHigh, 1);

        if (_cgImage != NULL) {
            CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(_cgImage);
            CGDataProviderRef provider = CGImageGetDataProvider(_cgImage);
            // FIXME: inefficient but there is no API to get mutable bytes out
            // of an image or image source
            CFDataRef bitmapData = CGDataProviderCopyData(provider);
            const unsigned char *bytes = CFDataGetBytePtr(bitmapData);
            int i, length = _bytesPerRow * _pixelsHigh;

            if (bitmapInfo ==
                (kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big)) {
                for (i = 0; i < length; i++)
                    _bitmapPlanes[0][i] = bytes[i];
            } else {
                for (i = 0; i < length; i += 4) {
                    unsigned char b = bytes[i + 0];
                    unsigned char g = bytes[i + 1];
                    unsigned char r = bytes[i + 2];
                    unsigned char a = bytes[i + 3];

                    _bitmapPlanes[0][i + 0] = r;
                    _bitmapPlanes[0][i + 1] = g;
                    _bitmapPlanes[0][i + 2] = b;
                    _bitmapPlanes[0][i + 3] = a;
                }
            }
            CFRelease(bitmapData);
        }
    }
}

- initWithCGImage: (CGImageRef) cgImage {
    _cgImage = CGImageRetain(cgImage);
    _size.width = CGImageGetWidth(_cgImage);
    _size.height = CGImageGetHeight(_cgImage);

    CGColorSpaceRef colorSpace = CGImageGetColorSpace(_cgImage);

    // FIXME:
    _colorSpaceName = NSDeviceRGBColorSpace;
    _bitsPerSample = CGImageGetBitsPerComponent(_cgImage);
    _pixelsWide = CGImageGetWidth(_cgImage);
    _pixelsHigh = CGImageGetHeight(_cgImage);

    switch (CGImageGetAlphaInfo(_cgImage)) {
    case kCGImageAlphaPremultipliedLast:
    case kCGImageAlphaPremultipliedFirst:
    case kCGImageAlphaLast:
    case kCGImageAlphaFirst:
        _hasAlpha = YES;
        break;
    default:
        _hasAlpha = NO;
        break;
    }

    _samplesPerPixel = CGColorSpaceGetNumberOfComponents(colorSpace);
    if (_hasAlpha)
        _samplesPerPixel++;
    _isPlanar = NO;
    _bitmapFormat = 0;
    if (CGImageGetBitmapInfo(_cgImage) & kCGBitmapFloatComponents) {
        _bitmapFormat |= NSFloatingPointSamplesBitmapFormat;
    }
    switch (CGImageGetAlphaInfo(_cgImage)) {
    case kCGImageAlphaNone:
        break;
    case kCGImageAlphaPremultipliedLast:
        break;
    case kCGImageAlphaPremultipliedFirst:
        _bitmapFormat |= NSAlphaFirstBitmapFormat;
        break;
    case kCGImageAlphaLast:
        _bitmapFormat |= NSAlphaNonpremultipliedBitmapFormat;
        break;
    case kCGImageAlphaFirst:
        _bitmapFormat |= NSAlphaFirstBitmapFormat;
        _bitmapFormat |= NSAlphaNonpremultipliedBitmapFormat;
        break;
    case kCGImageAlphaNoneSkipLast:
    case kCGImageAlphaNoneSkipFirst:
        break;
    case kCGImageAlphaOnly:
        break;
    }

    _bitsPerPixel = CGImageGetBitsPerPixel(_cgImage);
    _bytesPerRow = CGImageGetBytesPerRow(_cgImage);
    _freeWhenDone = NO;

    //   [self createBitmapIfNeeded];

    return self;
}

- (void) dealloc {
    if (_freeWhenDone) {
        if (_bitmapPlanes != NULL) {
            int i, numberOfPlanes = [self numberOfPlanes];

            for (i = 0; i < numberOfPlanes; i++)
                if (_bitmapPlanes[i] != NULL)
                    NSZoneFree(NULL, _bitmapPlanes[i]);
        }
    }
    if (_bitmapPlanes != NULL) {
        NSZoneFree(NULL, _bitmapPlanes);
    }
    CGImageRelease(_cgImage);
    [super dealloc];
}

- (int) incrementalLoadFromData: (NSData *) data complete: (BOOL) complete {
    NSMutableData *incrementalData = objc_getAssociatedObject(
            self, &NSBitmapImageRepIncrementalDataKey);
    if (incrementalData == nil) {
        incrementalData = [NSMutableData data];
        objc_setAssociatedObject(self, &NSBitmapImageRepIncrementalDataKey,
                                 incrementalData,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    if (data != nil)
        [incrementalData appendData: data];
    if ([incrementalData length] == 0)
        return complete ? -4 : -1;

    CGImageSourceRef imageSource = CGImageSourceCreateWithData(
            (CFDataRef) incrementalData, NULL);
    if (imageSource == NULL)
        return complete ? -4 : -1;

    CGImageRef cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    CFRelease(imageSource);
    if (cgImage == NULL) {
        if (complete) {
            objc_setAssociatedObject(self, &NSBitmapImageRepIncrementalDataKey,
                                     nil, OBJC_ASSOCIATION_ASSIGN);
            return -5;
        }
        return -2;
    }

    if (!complete) {
        CGImageRelease(cgImage);
        return -3;
    }

    [self initWithCGImage: cgImage];
    CGImageRelease(cgImage);
    objc_setAssociatedObject(self, &NSBitmapImageRepIncrementalDataKey, nil,
                             OBJC_ASSOCIATION_ASSIGN);
    return -6;
}

- (int) bitsPerPixel {
    return _bitsPerPixel;
}

- (int) samplesPerPixel {
    return _samplesPerPixel;
}

- (int) bytesPerRow {
    return _bytesPerRow;
}

- (BOOL) isPlanar {
    return _isPlanar;
}

- (int) numberOfPlanes {
    return _isPlanar ? _samplesPerPixel : 1;
}

- (int) bytesPerPlane {
    return _bytesPerPlane;
}

- (NSBitmapFormat) bitmapFormat {
    return _bitmapFormat;
}

- (unsigned char *) bitmapData {
    [self createBitmapIfNeeded];

    return _bitmapPlanes[0];
}

- (void) getBitmapDataPlanes: (unsigned char **) planes {
    [self createBitmapIfNeeded];

    int i, numberOfPlanes = [self numberOfPlanes];

    for (i = 0; i < numberOfPlanes; i++)
        planes[i] = _bitmapPlanes[i];

    for (; i < 5; i++)
        planes[i] = NULL;
}

- (void) getPixel: (NSUInteger[]) pixel atX: (NSInteger) x y: (NSInteger) y {
    NSAssert(pixel != NULL, @"pixel must not be NULL");
    NSAssert(x >= 0 && x < [self pixelsWide], @"x out of bounds");
    NSAssert(y >= 0 && y < [self pixelsHigh], @"y out of bounds");
    if (pixel == NULL || x < 0 || x >= [self pixelsWide] || y < 0 ||
        y >= [self pixelsHigh])
        return;

    [self createBitmapIfNeeded];
    NSUInteger sampleBits = (NSUInteger) [self bitsPerSample];
    if (sampleBits == 0 || sampleBits > sizeof(NSUInteger) * 8)
        return;

    for (NSUInteger sample = 0; sample < (NSUInteger) _samplesPerPixel;
         sample++) {
        unsigned char *plane = _bitmapPlanes[_isPlanar ? sample : 0];
        NSUInteger startBit = _isPlanar
                                      ? (NSUInteger) x * sampleBits
                                      : (NSUInteger) x * _bitsPerPixel +
                                                sample * sampleBits;
        plane += (NSUInteger) y * _bytesPerRow;

        NSUInteger value = 0;
        for (NSUInteger bit = 0; bit < sampleBits; bit++) {
            NSUInteger bitOffset = startBit + bit;
            value = (value << 1) |
                    ((plane[bitOffset / 8] >> (7 - (bitOffset % 8))) & 1);
        }
        pixel[sample] = value;
    }
}

- (void) setPixel: (NSUInteger[]) pixel atX: (NSInteger) x y: (NSInteger) y {
    NSAssert(x >= 0 && x < [self pixelsWide], @"x out of bounds");
    NSAssert(y >= 0 && y < [self pixelsHigh], @"y out of bounds");

    if (pixel == NULL || x < 0 || x >= [self pixelsWide] || y < 0 ||
        y >= [self pixelsHigh])
        return;

    [self createBitmapIfNeeded];

    NSUInteger sampleBits = (NSUInteger) [self bitsPerSample];
    if (sampleBits == 0 || sampleBits > sizeof(NSUInteger) * 8)
        return;

    for (NSUInteger sample = 0; sample < (NSUInteger) _samplesPerPixel;
         sample++) {
        unsigned char *plane = _bitmapPlanes[_isPlanar ? sample : 0];
        NSUInteger startBit = _isPlanar
                                      ? (NSUInteger) x * sampleBits
                                      : (NSUInteger) x * _bitsPerPixel +
                                                sample * sampleBits;
        plane += (NSUInteger) y * _bytesPerRow;

        for (NSUInteger bit = 0; bit < sampleBits; bit++) {
            NSUInteger bitOffset = startBit + bit;
            unsigned char mask = (unsigned char) (1 << (7 - bitOffset % 8));
            NSUInteger value =
                    (pixel[sample] >> (sampleBits - bit - 1)) & 1;
            if (value != 0)
                plane[bitOffset / 8] |= mask;
            else
                plane[bitOffset / 8] &= (unsigned char) ~mask;
        }
    }
}

- (NSColor *) colorAtX: (NSInteger) x y: (NSInteger) y {
    if (x < 0 || x >= [self pixelsWide] || y < 0 || y >= [self pixelsHigh] ||
        _samplesPerPixel <= 0)
        return nil;

    NSUInteger pixels[_samplesPerPixel];
    [self getPixel: pixels atX: x y: y];

    NSColorSpace *space = [self colorSpace];
    NSInteger colorCount = [space numberOfColorComponents];
    if (colorCount <= 0 || _samplesPerPixel < colorCount + (_hasAlpha ? 1 : 0))
        return nil;

    NSUInteger sampleBits = (NSUInteger) [self bitsPerSample];
    if (sampleBits == 0 || sampleBits > sizeof(NSUInteger) * 8)
        return nil;

    NSUInteger maxValue = sampleBits == sizeof(NSUInteger) * 8
                                  ? (NSUInteger) -1
                                  : (((NSUInteger) 1 << sampleBits) - 1);
    CGFloat components[colorCount + 1];
    CGFloat alpha = 1.0;
    NSInteger alphaIndex = _hasAlpha
                                   ? ((_bitmapFormat & NSAlphaFirstBitmapFormat)
                                              ? 0
                                              : colorCount)
                                   : -1;
    if (alphaIndex >= 0) {
        CGFloat sampleValue = (CGFloat) pixels[alphaIndex] / maxValue;
        if (_bitmapFormat & NSFloatingPointSamplesBitmapFormat)
            sampleValue = *((float *) &pixels[alphaIndex]);
        alpha = MAX(0.0, MIN(1.0, sampleValue));
    }

    for (NSInteger component = 0; component < colorCount; component++) {
        NSInteger sample = component;
        if (_hasAlpha && (_bitmapFormat & NSAlphaFirstBitmapFormat))
            sample++;
        CGFloat value = (CGFloat) pixels[sample] / maxValue;
        if (_bitmapFormat & NSFloatingPointSamplesBitmapFormat)
            value = *((float *) &pixels[sample]);
        if (_hasAlpha && !(_bitmapFormat & NSAlphaNonpremultipliedBitmapFormat))
            value = alpha > 0 ? value / alpha : 0;
        components[component] = MAX(0.0, MIN(1.0, value));
    }
    components[colorCount] = alpha;

    return [NSColor colorWithColorSpace: space
                             components: components
                                  count: colorCount + 1];
}

- (void) setColor: (NSColor *) color atX: (NSInteger) x y: (NSInteger) y {
    // Convert the color to a compatible format
    color = [color colorUsingColorSpaceName: [self colorSpaceName]];

    NSInteger i, numberOfComponents = [color numberOfComponents];
    CGFloat components[numberOfComponents];
    NSUInteger pixels[numberOfComponents];

    // Extract the RGBA components
    [color getComponents: components];

    if (!_hasAlpha) {
        // No alpha - then drop the component count
        numberOfComponents--;
    } else {
        // Deal with the alpha component
        if ((_bitmapFormat & NSAlphaNonpremultipliedBitmapFormat) ==
            NO) { // premultiplied
            CGFloat alpha = components[numberOfComponents - 1];

            // Multiply through the alpha
            for (i = 0; i < numberOfComponents - 1; i++) {
                components[i] *= alpha;
            }
        }

        if (_bitmapFormat & NSAlphaFirstBitmapFormat) {
            // Swap the location of the alpha component
            CGFloat alpha = components[numberOfComponents - 1];

            for (i = numberOfComponents; --i >= 1;) {
                components[i] = components[i - 1];
            }
            components[0] = alpha;
        }
    }

    if (_bitmapFormat & NSFloatingPointSamplesBitmapFormat) {
        for (i = 0; i < numberOfComponents; i++) {
            ((CGFloat *) pixels)[i] =
                    MAX(0.0f, MIN(1.0f, components[i])); // clamp just in case
        }
    } else {
        int maxValue = (1 << [self bitsPerSample]) - 1;

        for (i = 0; i < numberOfComponents; i++) {
#ifdef __LITTLE_ENDIAN__
            pixels[i] =
                    MAX(0, MIN(maxValue,
                               (int) (components[(numberOfComponents - 1) - i] *
                                      maxValue))); // clamp just in case
#else
            pixels[i] = MAX(
                    0, MIN(maxValue, (int) (components[i] *
                                            maxValue))); // clamp just in case
#endif
        }
    }

    [self setPixel: pixels atX: x y: y];
}

- valueForProperty: (NSString *) property {
    return [_properties objectForKey: property];
}

- (void) setProperty: (NSString *) property withValue: value {
    [_properties setObject: value forKey: property];
}

- (void) colorizeByMappingGray: (CGFloat) gray
                       toColor: (NSColor *) color
                  blackMapping: (NSColor *) blackMapping
                  whiteMapping: (NSColor *) whiteMapping
{
    if ([self bitsPerSample] != 8 ||
        (_samplesPerPixel != 1 && _samplesPerPixel != 2 &&
         _samplesPerPixel != 3 && _samplesPerPixel != 4))
        return;
    if ((_hasAlpha && _samplesPerPixel != 2 && _samplesPerPixel != 4) ||
        (!_hasAlpha && _samplesPerPixel != 1 && _samplesPerPixel != 3))
        return;

    gray = MAX(0.0, MIN(1.0, gray));
    NSColor *middle = color != nil
                              ? [color colorUsingColorSpaceName:
                                                   NSCalibratedRGBColorSpace]
                              : [NSColor colorWithCalibratedWhite: gray alpha: 1];
    NSColor *shadow = blackMapping != nil
                              ? [blackMapping colorUsingColorSpaceName:
                                                       NSCalibratedRGBColorSpace]
                              : [NSColor blackColor];
    NSColor *light = whiteMapping != nil
                             ? [whiteMapping colorUsingColorSpaceName:
                                                      NSCalibratedRGBColorSpace]
                             : [NSColor whiteColor];
    if (middle == nil)
        middle = [NSColor colorWithCalibratedWhite: gray alpha: 1];
    if (shadow == nil)
        shadow = [NSColor blackColor];
    if (light == nil)
        light = [NSColor whiteColor];

    CGFloat middleComponents[4], shadowComponents[4], lightComponents[4];
    [middle getRed: &middleComponents[0]
              green: &middleComponents[1]
               blue: &middleComponents[2]
              alpha: &middleComponents[3]];
    [shadow getRed: &shadowComponents[0]
              green: &shadowComponents[1]
               blue: &shadowComponents[2]
              alpha: &shadowComponents[3]];
    [light getRed: &lightComponents[0]
             green: &lightComponents[1]
              blue: &lightComponents[2]
             alpha: &lightComponents[3]];

    [self createBitmapIfNeeded];
    NSInteger alphaIndex = -1;
    if (_hasAlpha)
        alphaIndex = (_bitmapFormat & NSAlphaFirstBitmapFormat)
                             ? 0
                             : _samplesPerPixel - 1;
    NSInteger firstColorIndex =
            (alphaIndex == 0) ? 1 : 0;
    NSInteger colorCount = _samplesPerPixel - (_hasAlpha ? 1 : 0);
    NSInteger storedColorCount = (colorCount == 1) ? 1 : 3;

    for (NSInteger y = 0; y < [self pixelsHigh]; y++) {
        for (NSInteger x = 0; x < [self pixelsWide]; x++) {
            unsigned char values[4] = {0, 0, 0, 0};
            for (NSInteger component = 0; component < colorCount; component++) {
                NSUInteger sample = (NSUInteger) (firstColorIndex + component);
                unsigned char *plane = _bitmapPlanes[_isPlanar ? sample : 0];
                NSUInteger offset = _isPlanar
                                            ? (NSUInteger) y * _bytesPerRow + x
                                            : (NSUInteger) y * _bytesPerRow +
                                                      (NSUInteger) x * _samplesPerPixel +
                                                      sample;
                values[component] = plane[offset];
            }

            for (NSInteger component = 0; component < storedColorCount;
                 component++) {
                CGFloat input = values[component] / 255.0;
                CGFloat black, midpoint, white;
                if (colorCount == 1) {
                    black = 0.2126 * shadowComponents[0] +
                            0.7152 * shadowComponents[1] +
                            0.0722 * shadowComponents[2];
                    midpoint = 0.2126 * middleComponents[0] +
                               0.7152 * middleComponents[1] +
                               0.0722 * middleComponents[2];
                    white = 0.2126 * lightComponents[0] +
                            0.7152 * lightComponents[1] +
                            0.0722 * lightComponents[2];
                } else {
                    black = shadowComponents[component];
                    midpoint = middleComponents[component];
                    white = lightComponents[component];
                }

                CGFloat mapped;
                if (input <= gray) {
                    CGFloat fraction = gray > 0 ? input / gray : 0;
                    mapped = black + (midpoint - black) * fraction;
                } else {
                    CGFloat fraction = gray < 1 ? (input - gray) / (1 - gray) : 0;
                    mapped = midpoint + (white - midpoint) * fraction;
                }
                values[component] = (unsigned char) floor(
                        MAX(0.0, MIN(1.0, mapped)) * 255.0 + 0.5);
            }

            for (NSInteger component = 0; component < colorCount; component++) {
                NSUInteger sample = (NSUInteger) (firstColorIndex + component);
                unsigned char *plane = _bitmapPlanes[_isPlanar ? sample : 0];
                NSUInteger offset = _isPlanar
                                            ? (NSUInteger) y * _bytesPerRow + x
                                            : (NSUInteger) y * _bytesPerRow +
                                                      (NSUInteger) x * _samplesPerPixel +
                                                      sample;
                plane[offset] = values[component];
            }
        }
    }
    if (_cgImage != NULL)
        CGImageRelease(_cgImage);
    _cgImage = NULL;
}

- (void) getCompression: (NSTIFFCompression *) compression
                 factor: (float *) factor
{
    NSDictionary *properties = objc_getAssociatedObject(
            self, &NSBitmapImageRepCompressionPropertiesKey);
    NSNumber *compressionValue =
            [properties objectForKey: NSImageCompressionMethod];
    NSNumber *factorValue = [properties objectForKey: NSImageCompressionFactor];

    if (compression != NULL)
        *compression = compressionValue != nil
                               ? (NSTIFFCompression) [compressionValue intValue]
                               : NSTIFFCompressionNone;
    if (factor != NULL)
        *factor = factorValue != nil ? [factorValue floatValue] : 0.0f;
}

- (void) setCompression: (NSTIFFCompression) compression
                 factor: (float) factor
{
    NSDictionary *properties = [NSDictionary
            dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithInt: compression],
                    NSImageCompressionMethod,
                    [NSNumber numberWithFloat: factor],
                    NSImageCompressionFactor, nil];
    objc_setAssociatedObject(self, &NSBitmapImageRepCompressionPropertiesKey,
                             properties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL) canBeCompressedUsing: (NSTIFFCompression) compression {
    switch (compression) {
    case NSTIFFCompressionNone:
    case NSTIFFCompressionLZW:
    case NSTIFFCompressionPackBits:
        return YES;
    case NSTIFFCompressionCCITTFAX3:
    case NSTIFFCompressionCCITTFAX4:
        return _bitsPerSample == 1 && _samplesPerPixel == 1 && !_hasAlpha;
    default:
        return NO;
    }
}

- (NSData *) representationUsingType: (NSBitmapImageFileType) type
                          properties: (NSDictionary *) properties
{
    CFStringRef uti;

    switch (type) {

    case NSTIFFFileType:
        uti = (CFStringRef) @"public.tiff";
        break;

    case NSBMPFileType:
        uti = (CFStringRef) @"com.microsoft.bmp";
        break;

    case NSGIFFileType:
        uti = (CFStringRef) @"com.compuserve.gif";
        break;

    case NSJPEGFileType:
        uti = (CFStringRef) @"public.jpeg";
        break;

    case NSPNGFileType:
        uti = (CFStringRef) @"public.png";
        break;

    case NSJPEG2000FileType:
        uti = (CFStringRef) @"public.jpeg-2000";
        break;

    default:
        return nil;
    }

    int dpi = 72;
    if (_size.width > 0) {
        dpi = ceilf(72 * _pixelsWide / _size.width);
    }
    NSMutableData *result = [NSMutableData data];
    // Convert the NS options to CG options - just NSImageCompressionFactor for
    // now
    NSDictionary *CGProperties = [NSMutableDictionary dictionary];

    [CGProperties setValue: [NSNumber numberWithInt: dpi]
                    forKey: (id) kCGImageDestinationDPI];

    if ([properties count]) {
        id compressionFactor =
                [properties valueForKey: NSImageCompressionFactor];
        if (compressionFactor) {
            [CGProperties
                    setValue: compressionFactor
                      forKey: (id) kCGImageDestinationLossyCompressionQuality];
        }
    }
    CGImageDestinationRef dest = CGImageDestinationCreateWithData(
            (CFMutableDataRef) result, uti, 1, (CFDictionaryRef) CGProperties);

    CGImageDestinationAddImage(dest, [self CGImage],
                               (CFDictionaryRef) CGProperties);

    CGImageDestinationFinalize(dest);
    CFRelease(dest);

    return result;
}

- (NSData *) TIFFRepresentation {
    return [self TIFFRepresentationUsingCompression: NSTIFFCompressionNone
                                             factor: 0.0];
}

- (NSData *) TIFFRepresentationUsingCompression: (NSTIFFCompression) compression
                                         factor: (float) factor
{
    return [[self class]
            TIFFRepresentationOfImageRepsInArray: [NSArray
                                                          arrayWithObject: self]
                                usingCompression: compression
                                          factor: factor];
}

- (CGImageRef) createCGImageIfNeeded {
    if (_cgImage != NULL)
        return CGImageRetain(_cgImage);

    [self createBitmapIfNeeded];

    CFDataRef planarData = NULL;
    const unsigned char *data = _bitmapPlanes[0];
    size_t bytesPerRow = _bytesPerRow;
    if (_isPlanar) {
        if (_samplesPerPixel <= 0 || _bitsPerSample <= 0 ||
            _bitsPerSample > sizeof(NSUInteger) * 8 ||
            _bitsPerPixel != _bitsPerSample * _samplesPerPixel)
            return NULL;

        bytesPerRow = ((size_t) _bitsPerPixel * _pixelsWide + 7) / 8;
        CFMutableDataRef mutableData = CFDataCreateMutable(
                kCFAllocatorDefault, bytesPerRow * _pixelsHigh);
        if (mutableData == NULL)
            return NULL;
        CFDataSetLength(mutableData, bytesPerRow * _pixelsHigh);
        unsigned char *interleaved = CFDataGetMutableBytePtr(mutableData);
        memset(interleaved, 0, bytesPerRow * _pixelsHigh);

        NSUInteger pixel[_samplesPerPixel];
        for (NSInteger y = 0; y < _pixelsHigh; y++) {
            for (NSInteger x = 0; x < _pixelsWide; x++) {
                [self getPixel: pixel atX: x y: y];
                for (NSInteger sample = 0; sample < _samplesPerPixel; sample++) {
                    NSUInteger startBit = (NSUInteger) x * _bitsPerPixel +
                                          (NSUInteger) sample * _bitsPerSample;
                    for (NSInteger bit = 0; bit < _bitsPerSample; bit++) {
                        if ((pixel[sample] >> (_bitsPerSample - bit - 1)) & 1) {
                            NSUInteger bitOffset = startBit + bit;
                            interleaved[(NSUInteger) y * bytesPerRow +
                                        bitOffset / 8] |=
                                    (unsigned char) (1 << (7 - bitOffset % 8));
                        }
                    }
                }
            }
        }
        planarData = mutableData;
        data = CFDataGetBytePtr(planarData);
    }

    CGDataProviderRef provider = planarData != NULL
                                         ? CGDataProviderCreateWithCFData(
                                                   planarData)
                                         : CGDataProviderCreateWithData(
                                                   NULL, data,
                                                   bytesPerRow * _pixelsHigh,
                                                   NULL);

    if (planarData != NULL)
        CFRelease(planarData);

    if (provider == NULL)
        return NULL;

    CGColorSpaceRef colorSpace = [self CGColorSpace];
    if (colorSpace == NULL) {
        CGDataProviderRelease(provider);
        return NULL;
    }

    CGImageRef image = CGImageCreate(
            _pixelsWide, _pixelsHigh, _bitsPerPixel / _samplesPerPixel,
            _bitsPerPixel, bytesPerRow, colorSpace,
            [self CGBitmapInfo], provider, NULL, NO, kCGRenderingIntentDefault);

    CGDataProviderRelease(provider);

    return image;
}

- (CGImageRef) CGImage {
    if (_cgImage != NULL)
        return _cgImage;

    return (CGImageRef)[(id)[self createCGImageIfNeeded] autorelease];
}

- (BOOL) draw {
    CGContextRef context = NSCurrentGraphicsPort();
    NSSize size = [self size];
    CGImageRef image = [self createCGImageIfNeeded];

    CGContextDrawImage(context, NSMakeRect(0, 0, size.width, size.height),
                       image);

    CGImageRelease(image);

    return YES;
}

- (CGColorSpaceRef) CGColorSpace {
    if ([_colorSpaceName isEqualToString: NSDeviceRGBColorSpace])
        return (CGColorSpaceRef)[(id) CGColorSpaceCreateDeviceRGB()
                                         autorelease];
    if ([_colorSpaceName isEqualToString: NSCalibratedRGBColorSpace])
        return (CGColorSpaceRef)[(id) CGColorSpaceCreateDeviceRGB()
                                         autorelease];

    return NULL;
}

- (CGBitmapInfo) CGBitmapInfo {
    CGBitmapInfo result = kCGBitmapByteOrderDefault;

    if (![self hasAlpha])
        result |= kCGImageAlphaNone;
    else {
        if (_bitmapFormat & NSAlphaFirstBitmapFormat) {
            if (_bitmapFormat & NSAlphaNonpremultipliedBitmapFormat)
                result |= kCGImageAlphaFirst;
            else
                result |= kCGImageAlphaPremultipliedFirst;
        } else {
            if (_bitmapFormat & NSAlphaNonpremultipliedBitmapFormat)
                result |= kCGImageAlphaLast;
            else
                result |= kCGImageAlphaPremultipliedLast;
        }
    }
    if (_bitmapFormat & NSFloatingPointSamplesBitmapFormat)
        result |= kCGBitmapFloatComponents;

    return result;
}

- (instancetype) initWithCIImage: (CIImage *) ciImage {
    // Render through a CIContext, looked up at runtime so AppKit does not
    // link against CoreImage.
    CGImageRef cgImage = NULL;
    Class contextClass = NSClassFromString(@"CIContext");

    if (ciImage != nil && contextClass != Nil) {
        id context = [contextClass performSelector: @selector(context)];
        NSValue *extentValue = [ciImage valueForKey: @"extent"];
        CGRect extent = [extentValue rectValue];

        if (context != nil && !CGRectIsInfinite(extent) &&
            !CGRectIsEmpty(extent)) {
            CGImageRef (*create)(id, SEL, id, CGRect) =
                    (CGImageRef(*)(id, SEL, id, CGRect))objc_msgSend;

            cgImage = create(context, @selector(createCGImage:fromRect:),
                             ciImage, extent);
        }
    }

    if (cgImage == NULL) {
        [self release];
        return nil;
    }

    self = [self initWithCGImage: cgImage];
    CGImageRelease(cgImage);
    return self;
}

- (NSColorSpace *) colorSpace {
    CGColorSpaceRef cgSpace = NULL;
    BOOL owned = NO;

    if (_cgImage != NULL)
        cgSpace = CGImageGetColorSpace(_cgImage);

    if (cgSpace == NULL) {
        if ([_colorSpaceName isEqualToString: NSDeviceWhiteColorSpace] ||
            [_colorSpaceName isEqualToString: NSCalibratedWhiteColorSpace] ||
            [_colorSpaceName isEqualToString: NSDeviceBlackColorSpace] ||
            [_colorSpaceName isEqualToString: NSCalibratedBlackColorSpace])
            cgSpace = CGColorSpaceCreateDeviceGray();
        else if ([_colorSpaceName isEqualToString: NSDeviceCMYKColorSpace])
            cgSpace = CGColorSpaceCreateDeviceCMYK();
        else
            cgSpace = CGColorSpaceCreateDeviceRGB();
        owned = YES;
    }

    NSColorSpace *result =
            [[[NSColorSpace alloc] initWithCGColorSpace: cgSpace] autorelease];

    if (owned)
        CGColorSpaceRelease(cgSpace);
    return result;
}

- (NSBitmapImageRep *) bitmapImageRepByRetaggingWithColorSpace: (NSColorSpace *) newSpace {
    printf("STUB %s\n", __PRETTY_FUNCTION__);
    return nil;
}

@end
