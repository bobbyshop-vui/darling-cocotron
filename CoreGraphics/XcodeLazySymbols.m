/*
 * Additional CoreGraphics exports used by lazily-bound Xcode clients.
 * Keep unsupported backend operations benign: Darling has no ColorSync,
 * IOSurface, or window-server implementation in this layer.
 */

#import <CoreFoundation/CoreFoundation.h>
#import <CoreGraphics/CGAffineTransform.h>
#import <CoreGraphics/CGColor.h>
#import <CoreGraphics/CGColorSpace.h>
#import <CoreGraphics/CGContext.h>
#import <CoreGraphics/CGDataConsumer.h>
#import <CoreGraphics/CGDataProvider.h>
#import <CoreGraphics/CGEvent.h>
#import <CoreGraphics/CGEventSource.h>
#import <CoreGraphics/CGGeometry.h>
#import <CoreGraphics/CGImage.h>
#import <CoreGraphics/CGPDFContext.h>
#import <CoreGraphics/CGPDFPage.h>
#import <CoreGraphics/CGPath.h>
#import <Onyx2D/O2Color.h>
#import <Onyx2D/O2ColorSpace.h>
#import <Onyx2D/O2Context.h>
#import <Onyx2D/O2DataProvider.h>
#import <Onyx2D/O2Image.h>
#import <Onyx2D/O2MutablePath.h>
#import <Onyx2D/O2Path.h>
#import "CGConversions.h"

#include <math.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

/* The local header provides this as a static inline macro, but the Apple ABI
 * exports an out-of-line symbol which clients may bind lazily. */
#undef CGPointApplyAffineTransform

typedef const struct CGColorTransform *CGColorTransformRef;

@interface O2ColorSpace (XcodeLazySymbols)
- (CFStringRef)xcodeLazyColorSpaceName;
@end

@implementation O2ColorSpace (XcodeLazySymbols)
- (CFStringRef)xcodeLazyColorSpaceName {
    return _name;
}
@end

@interface O2LazySequentialProvider : O2DataProvider {
    void *_lazyInfo;
    CGDataProviderReleaseInfoCallback _lazyReleaseInfo;
    void *_lazyOwnedBytes;
}
- (id)initWithInfo:(void *)info
       releaseInfo:(CGDataProviderReleaseInfoCallback)releaseInfo
        ownedBytes:(void *)bytes
            length:(size_t)length;
@end

@implementation O2LazySequentialProvider
- (id)initWithInfo:(void *)info
       releaseInfo:(CGDataProviderReleaseInfoCallback)releaseInfo
        ownedBytes:(void *)bytes
            length:(size_t)length
{
    self = [super initWithBytes:bytes length:length];
    if (self != nil) {
        _lazyInfo = info;
        _lazyReleaseInfo = releaseInfo;
        _lazyOwnedBytes = bytes;
    }
    return self;
}

- (void)dealloc {
    if (_lazyReleaseInfo != NULL)
        _lazyReleaseInfo(_lazyInfo);
    free(_lazyOwnedBytes);
    [super dealloc];
}
@end

COREGRAPHICS_EXPORT bool
CGAffineTransformEqualToTransform(CGAffineTransform t1, CGAffineTransform t2)
{
    return t1.a == t2.a && t1.b == t2.b && t1.c == t2.c &&
           t1.d == t2.d && t1.tx == t2.tx && t1.ty == t2.ty;
}

COREGRAPHICS_EXPORT CGPoint
CGPointApplyAffineTransform(CGPoint point, CGAffineTransform transform)
{
    CGPoint result = {
        transform.a * point.x + transform.c * point.y + transform.tx,
        transform.b * point.x + transform.d * point.y + transform.ty
    };
    return result;
}

COREGRAPHICS_EXPORT CGRect CGRectStandardize(CGRect rect) {
    if (rect.size.width < 0) {
        rect.origin.x += rect.size.width;
        rect.size.width = -rect.size.width;
    }
    if (rect.size.height < 0) {
        rect.origin.y += rect.size.height;
        rect.size.height = -rect.size.height;
    }
    return rect;
}

COREGRAPHICS_EXPORT void CGRectDivide(CGRect rect, CGRect *slice,
                                      CGRect *remainder, CGFloat amount,
                                      CGRectEdge edge)
{
    CGRect part = CGRectZero;
    CGRect rest = CGRectStandardize(rect);
    CGFloat extent;
    rect = rest;

    switch (edge) {
    case CGRectMinXEdge:
        extent = rect.size.width;
        amount = fmax(0, fmin(amount, extent));
        part = CGRectMake(rect.origin.x, rect.origin.y, amount, rect.size.height);
        rest.origin.x += amount;
        rest.size.width -= amount;
        break;
    case CGRectMaxXEdge:
        extent = rect.size.width;
        amount = fmax(0, fmin(amount, extent));
        part = CGRectMake(rect.origin.x + extent - amount, rect.origin.y,
                          amount, rect.size.height);
        rest.size.width -= amount;
        break;
    case CGRectMinYEdge:
        extent = rect.size.height;
        amount = fmax(0, fmin(amount, extent));
        part = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, amount);
        rest.origin.y += amount;
        rest.size.height -= amount;
        break;
    case CGRectMaxYEdge:
        extent = rect.size.height;
        amount = fmax(0, fmin(amount, extent));
        part = CGRectMake(rect.origin.x, rect.origin.y + extent - amount,
                          rect.size.width, amount);
        rest.size.height -= amount;
        break;
    default:
        rest = CGRectZero;
        break;
    }
    if (slice != NULL)
        *slice = part;
    if (remainder != NULL)
        *remainder = rest;
}

COREGRAPHICS_EXPORT bool CGFloatIsValid(CGFloat value) {
    return isfinite(value);
}

COREGRAPHICS_EXPORT CGColorRef
CGColorCreateCopyByMatchingToColorSpace(CGColorSpaceRef destinationSpace,
                                        CGColorRenderingIntent intent,
                                        CGColorRef color,
                                        CFDictionaryRef options)
{
    O2ColorSpaceRef sourceSpace;
    O2ColorSpaceModel destinationModel;
    O2Float rgb[4];
    O2Float converted[5];
    const O2Float *sourceComponents;
    size_t sourceCount;
    O2Float alpha;
    (void)intent;
    (void)options;

    if (destinationSpace == NULL || color == NULL)
        return NULL;
    sourceSpace = (O2ColorSpaceRef)CGColorGetColorSpace(color);
    if (sourceSpace == (O2ColorSpaceRef)destinationSpace)
        return CGColorCreateCopy(color);
    if (sourceSpace == NULL)
        return NULL;

    sourceComponents = O2ColorGetComponents((O2ColorRef)color);
    sourceCount = O2ColorGetNumberOfComponents((O2ColorRef)color);
    if (sourceComponents == NULL || sourceCount == 0)
        return NULL;
    switch (O2ColorSpaceGetModel(sourceSpace)) {
    case kO2ColorSpaceModelMonochrome:
    case kO2ColorSpaceModelRGB:
    case kO2ColorSpaceModelCMYK:
        break;
    default:
        return NULL;
    }
    if (!O2ColorConvertComponentsToDeviceRGB(sourceSpace, sourceComponents,
                                             rgb))
        return NULL;

    alpha = rgb[3];
    destinationModel = O2ColorSpaceGetModel((O2ColorSpaceRef)destinationSpace);
    switch (destinationModel) {
    case kO2ColorSpaceModelMonochrome:
        converted[0] = (O2Float)(0.2126 * rgb[0] + 0.7152 * rgb[1] +
                                 0.0722 * rgb[2]);
        converted[1] = alpha;
        break;
    case kO2ColorSpaceModelRGB:
        converted[0] = rgb[0];
        converted[1] = rgb[1];
        converted[2] = rgb[2];
        converted[3] = alpha;
        break;
    case kO2ColorSpaceModelCMYK: {
        O2Float black = 1 - fmax(rgb[0], fmax(rgb[1], rgb[2]));
        if (black >= 1) {
            converted[0] = converted[1] = converted[2] = 0;
        } else {
            O2Float scale = 1 - black;
            converted[0] = (1 - rgb[0] - black) / scale;
            converted[1] = (1 - rgb[1] - black) / scale;
            converted[2] = (1 - rgb[2] - black) / scale;
        }
        converted[3] = black;
        converted[4] = alpha;
        break;
    }
    default:
        return NULL;
    }
    return CGColorCreate(destinationSpace, converted);
}

COREGRAPHICS_EXPORT CFTypeID CGColorGetTypeID(void) {
    CGColorRef color = CGColorCreateGenericGray(0, 1);
    CFTypeID typeID = (color == NULL) ? 0 : CFGetTypeID((CFTypeRef)color);
    CGColorRelease(color);
    return typeID;
}

COREGRAPHICS_EXPORT CFStringRef
CGColorSpaceCopyName(CGColorSpaceRef space)
{
    CFStringRef name;
    if (space == NULL)
        return NULL;
    name = [(O2ColorSpace *)space xcodeLazyColorSpaceName];
    return (name == NULL) ? NULL : CFStringCreateCopy(kCFAllocatorDefault, name);
}

COREGRAPHICS_EXPORT CGColorSpaceRef
CGColorSpaceCreateWithICCData(CFTypeRef data)
{
    (void)data;
    return NULL;
}

COREGRAPHICS_EXPORT CGColorSpaceRef
CGColorSpaceGetBaseColorSpace(CGColorSpaceRef space)
{
    if (space == NULL || O2ColorSpaceGetModel((O2ColorSpaceRef)space) !=
                              kO2ColorSpaceModelIndexed)
        return NULL;
    return (CGColorSpaceRef)[(O2ColorSpace_indexed *)space baseColorSpace];
}

COREGRAPHICS_EXPORT size_t
CGColorSpaceGetColorTableCount(CGColorSpaceRef space)
{
    if (space == NULL || O2ColorSpaceGetModel((O2ColorSpaceRef)space) !=
                              kO2ColorSpaceModelIndexed)
        return 0;
    return [(O2ColorSpace_indexed *)space hival] + 1;
}

COREGRAPHICS_EXPORT void
CGColorSpaceGetColorTable(CGColorSpaceRef space, uint8_t *table)
{
    size_t byteCount;
    const unsigned char *palette;
    if (space == NULL || table == NULL ||
        O2ColorSpaceGetModel((O2ColorSpaceRef)space) !=
            kO2ColorSpaceModelIndexed)
        return;
    O2ColorSpaceRef base = [(O2ColorSpace_indexed *)space baseColorSpace];
    if (base == NULL)
        return;
    palette = [(O2ColorSpace_indexed *)space paletteBytes];
    byteCount = O2ColorSpaceGetNumberOfComponents(base) *
                ([(O2ColorSpace_indexed *)space hival] + 1);
    if (palette != NULL && byteCount != 0)
        memcpy(table, palette, byteCount);
}

COREGRAPHICS_EXPORT CGColorSpaceModel
CGColorSpaceGetProcessColorModel(CGColorSpaceRef space)
{
    return (space == NULL) ? kCGColorSpaceModelUnknown :
           (CGColorSpaceModel)O2ColorSpaceGetModel((O2ColorSpaceRef)space);
}

COREGRAPHICS_EXPORT bool CGColorSpaceIsWideGamutRGB(CGColorSpaceRef space) {
    CFStringRef name;
    if (space == NULL || O2ColorSpaceGetModel((O2ColorSpaceRef)space) !=
                              kO2ColorSpaceModelRGB)
        return false;
    name = [(O2ColorSpace *)space xcodeLazyColorSpaceName];
    if (name == NULL)
        return false;
    return CFEqual(name, kCGColorSpaceDisplayP3) ||
           CFEqual(name, kCGColorSpaceAdobeRGB1998) ||
           CFEqual(name, kCGColorSpaceITUR_2020) ||
           CFEqual(name, kCGColorSpaceROMMRGB) ||
           CFEqual(name, kCGColorSpaceACESCGLinear) ||
           CFEqual(name, kCGColorSpaceDCIP3);
}

COREGRAPHICS_EXPORT bool CGColorSpaceUsesExtendedRange(CGColorSpaceRef space) {
    CFStringRef name;
    if (space == NULL)
        return false;
    name = [(O2ColorSpace *)space xcodeLazyColorSpaceName];
    if (name == NULL)
        return false;
    return CFEqual(name, kCGColorSpaceExtendedSRGB) ||
           CFEqual(name, kCGColorSpaceExtendedLinearSRGB) ||
           CFEqual(name, kCGColorSpaceExtendedGray) ||
           CFEqual(name, kCGColorSpaceExtendedLinearGray);
}

COREGRAPHICS_EXPORT CGColorRef
CGColorTransformConvertColor(CGColorTransformRef transform, CGColorRef color,
                             CGColorRenderingIntent intent)
{
    (void)transform;
    (void)color;
    (void)intent;
    return NULL;
}

COREGRAPHICS_EXPORT bool
CGColorTransformConvertColorComponents(CGColorTransformRef transform,
                                        CGColorSpaceRef sourceSpace,
                                        CGColorRenderingIntent intent,
                                        const CGFloat *sourceComponents,
                                        CGFloat *destinationComponents)
{
    (void)transform;
    (void)sourceSpace;
    (void)intent;
    (void)sourceComponents;
    (void)destinationComponents;
    return false;
}

COREGRAPHICS_EXPORT bool CGColorTransformConvertData(CGColorTransformRef transform, ...) {
    (void)transform;
    return false;
}

COREGRAPHICS_EXPORT CGColorTransformRef
CGColorTransformCreate(CGColorSpaceRef destinationSpace,
                       CFDictionaryRef attributes)
{
    (void)destinationSpace;
    (void)attributes;
    return NULL;
}

COREGRAPHICS_EXPORT void CGColorTransformRelease(CGColorTransformRef transform) {
    (void)transform;
}

COREGRAPHICS_EXPORT void
CGContextBeginTransparencyLayerWithRect(CGContextRef context, CGRect rect,
                                        CFDictionaryRef auxiliaryInfo)
{
    (void)rect;
    CGContextBeginTransparencyLayer(context, auxiliaryInfo);
}

COREGRAPHICS_EXPORT int CGContextGetFontRenderingStyle(CGContextRef context) {
    (void)context;
    return 0;
}

COREGRAPHICS_EXPORT CGColorRef
CGContextGetFontSmoothingBackgroundColor(CGContextRef context)
{
    (void)context;
    return NULL;
}

COREGRAPHICS_EXPORT int CGContextGetFontSmoothingStyle(CGContextRef context) {
    (void)context;
    return 0;
}

COREGRAPHICS_EXPORT void
CGContextSetBaseCTM(CGContextRef context, CGAffineTransform transform)
{
    CGContextSetCTM(context, transform);
}

COREGRAPHICS_EXPORT void CGContextSetFontRenderingStyle(CGContextRef context, ...) {
    (void)context;
}

COREGRAPHICS_EXPORT void
CGContextSetFontSmoothingBackgroundColor(CGContextRef context, CGColorRef color)
{
    (void)context;
    (void)color;
}

COREGRAPHICS_EXPORT void
CGContextSetFontSmoothingStyle(CGContextRef context, int style)
{
    (void)context;
    (void)style;
}

COREGRAPHICS_EXPORT CGDataProviderRef
CGDataProviderCreateSequential(void *info,
                               const CGDataProviderSequentialCallbacks *callbacks)
{
    unsigned char *bytes = NULL;
    size_t length = 0;
    size_t capacity = 0;
    const size_t chunkSize = 4096;
    unsigned char chunk[4096];
    O2LazySequentialProvider *provider;

    if (callbacks == NULL || callbacks->getBytes == NULL ||
        callbacks->version != 0) {
        if (callbacks != NULL && callbacks->releaseInfo != NULL)
            callbacks->releaseInfo(info);
        return NULL;
    }
    for (;;) {
        size_t received = callbacks->getBytes(info, chunk, chunkSize);
        size_t needed;
        if (received == 0)
            break;
        if (received > chunkSize || received > SIZE_MAX - length) {
            free(bytes);
            if (callbacks->releaseInfo != NULL)
                callbacks->releaseInfo(info);
            return NULL;
        }
        needed = length + received;
        if (needed > capacity) {
            size_t nextCapacity = capacity == 0 ? chunkSize : capacity;
            unsigned char *nextBytes;
            while (nextCapacity < needed) {
                if (nextCapacity > SIZE_MAX / 2) {
                    nextCapacity = needed;
                    break;
                }
                nextCapacity *= 2;
            }
            nextBytes = realloc(bytes, nextCapacity);
            if (nextBytes == NULL) {
                free(bytes);
                if (callbacks->releaseInfo != NULL)
                    callbacks->releaseInfo(info);
                return NULL;
            }
            bytes = nextBytes;
            capacity = nextCapacity;
        }
        memcpy(bytes + length, chunk, received);
        length = needed;
    }
    provider = [[O2LazySequentialProvider alloc]
            initWithInfo:info
            releaseInfo:callbacks->releaseInfo
            ownedBytes:bytes
            length:length];
    if (provider == nil) {
        if (callbacks->releaseInfo != NULL)
            callbacks->releaseInfo(info);
        free(bytes);
        return NULL;
    }
    return (CGDataProviderRef)provider;
}

COREGRAPHICS_EXPORT CGDataProviderRef CGDataProviderCreateWithURL(CFURLRef url) {
    if (url == NULL)
        return NULL;
    return (CGDataProviderRef)O2DataProviderCreateWithURL((NSURL *)url);
}

COREGRAPHICS_EXPORT CGEventFlags CGEventGetFlags(CGEventRef event) {
    (void)event;
    return 0;
}

COREGRAPHICS_EXPORT bool CGEventSourceButtonState(CGEventSourceStateID stateID,
                                                  CGMouseButton button)
{
    (void)stateID;
    (void)button;
    return false;
}

COREGRAPHICS_EXPORT CFTypeID CGImageGetTypeID(void) {
    O2ImageRef image = [[O2Image alloc] init];
    CFTypeID typeID = (image == NULL) ? 0 : CFGetTypeID((CFTypeRef)image);
    [image release];
    return typeID;
}

COREGRAPHICS_EXPORT bool CGImageIsSubimage(CGImageRef image) {
    (void)image;
    return false;
}

COREGRAPHICS_EXPORT void *CGImageGetImageProvider(CGImageRef image) {
    (void)image;
    return NULL;
}

COREGRAPHICS_EXPORT void *CGImageProviderCopyIOSurface(void *provider) {
    (void)provider;
    return NULL;
}

COREGRAPHICS_EXPORT void
CGPDFContextAddDestinationAtPoint(CGContextRef context, CFStringRef name,
                                  CGPoint point)
{
    (void)context;
    (void)name;
    (void)point;
}

COREGRAPHICS_EXPORT void
CGPDFContextBeginPage(CGContextRef context, CFDictionaryRef pageInfo)
{
    CFTypeRef boxValue = (pageInfo == NULL)
                             ? NULL
                             : (CFTypeRef)CFDictionaryGetValue(
                                       pageInfo, kCGPDFContextMediaBox);
    if (boxValue != NULL && CFGetTypeID(boxValue) == CFDataGetTypeID() &&
        CFDataGetLength((CFDataRef)boxValue) >= (CFIndex)sizeof(CGRect)) {
        CGRect mediaBox;
        memcpy(&mediaBox, CFDataGetBytePtr((CFDataRef)boxValue),
               sizeof(mediaBox));
        CGContextBeginPage(context, &mediaBox);
    } else {
        CGContextBeginPage(context, NULL);
    }
}

COREGRAPHICS_EXPORT CGContextRef
CGPDFContextCreateWithURL(CFURLRef url, const CGRect *mediaBox,
                          CFDictionaryRef auxiliaryInfo)
{
    CGDataConsumerRef consumer;
    CGContextRef context;
    if (url == NULL)
        return NULL;
    consumer = CGDataConsumerCreateWithURL(url);
    if (consumer == NULL)
        return NULL;
    context = CGPDFContextCreate(consumer, mediaBox, auxiliaryInfo);
    CGDataConsumerRelease(consumer);
    return context;
}

COREGRAPHICS_EXPORT void CGPDFContextEndPage(CGContextRef context) {
    CGContextEndPage(context);
}

COREGRAPHICS_EXPORT void
CGPDFContextSetDestinationForRect(CGContextRef context, CFStringRef name,
                                  CGRect rect)
{
    (void)context;
    (void)name;
    (void)rect;
}

COREGRAPHICS_EXPORT void
CGPDFContextSetURLForRect(CGContextRef context, CFURLRef url, CGRect rect)
{
    (void)context;
    (void)url;
    (void)rect;
}

COREGRAPHICS_EXPORT bool CGPDFPageContainsWideGamutContent(CGPDFPageRef page) {
    (void)page;
    return false;
}

COREGRAPHICS_EXPORT CGColorSpaceRef CGPDFPageGetColorSpace(CGPDFPageRef page) {
    (void)page;
    return NULL;
}

COREGRAPHICS_EXPORT void
CGPathAddRelativeArc(CGMutablePathRef path, const CGAffineTransform *transform,
                     CGFloat x, CGFloat y, CGFloat radius, CGFloat startAngle,
                     CGFloat delta)
{
    if (path == NULL)
        return;
    CGPathAddArc(path, transform, x, y, radius, startAngle,
                 startAngle + delta, delta < 0);
}

COREGRAPHICS_EXPORT void
CGPathAddRoundedRect(CGMutablePathRef path, const CGAffineTransform *transform,
                     CGRect rect, CGFloat cornerWidth, CGFloat cornerHeight)
{
    CGFloat rx, ry, k = (CGFloat)0.5522847498307936;
    CGFloat minX, minY, maxX, maxY;
    if (path == NULL)
        return;
    rect = CGRectStandardize(rect);
    minX = rect.origin.x;
    minY = rect.origin.y;
    maxX = minX + rect.size.width;
    maxY = minY + rect.size.height;
    rx = fmax(0, fmin(cornerWidth, rect.size.width / 2));
    ry = fmax(0, fmin(cornerHeight, rect.size.height / 2));
    if (rx == 0 || ry == 0) {
        CGPathAddRect(path, transform, rect);
        return;
    }
    CGPathMoveToPoint(path, transform, minX + rx, minY);
    CGPathAddLineToPoint(path, transform, maxX - rx, minY);
    CGPathAddCurveToPoint(path, transform, maxX - rx + k * rx, minY,
                          maxX, minY + ry - k * ry, maxX, minY + ry);
    CGPathAddLineToPoint(path, transform, maxX, maxY - ry);
    CGPathAddCurveToPoint(path, transform, maxX, maxY - ry + k * ry,
                          maxX - rx + k * rx, maxY, maxX - rx, maxY);
    CGPathAddLineToPoint(path, transform, minX + rx, maxY);
    CGPathAddCurveToPoint(path, transform, minX + rx - k * rx, maxY,
                          minX, maxY - ry + k * ry, minX, maxY - ry);
    CGPathAddLineToPoint(path, transform, minX, minY + ry);
    CGPathAddCurveToPoint(path, transform, minX, minY + ry - k * ry,
                          minX + rx - k * rx, minY, minX + rx, minY);
    CGPathCloseSubpath(path);
}

COREGRAPHICS_EXPORT CGPathRef
CGPathCreateCopyByDashingPath(CGPathRef path,
                              const CGAffineTransform *transform,
                              CGFloat phase, const CGFloat *lengths,
                              size_t count)
{
    (void)path;
    (void)transform;
    (void)phase;
    (void)lengths;
    (void)count;
    return NULL;
}

COREGRAPHICS_EXPORT CGPathRef
CGPathCreateCopyByStrokingPath(CGPathRef path,
                               const CGAffineTransform *transform,
                               CGFloat lineWidth, CGLineCap lineCap,
                               CGLineJoin lineJoin, CGFloat miterLimit)
{
    (void)path;
    (void)transform;
    (void)lineWidth;
    (void)lineCap;
    (void)lineJoin;
    (void)miterLimit;
    return NULL;
}

COREGRAPHICS_EXPORT CGMutablePathRef
CGPathCreateMutableCopyByTransformingPath(CGPathRef path,
                                          const CGAffineTransform *transform)
{
    CGMutablePathRef copy;
    if (path == NULL)
        return NULL;
    copy = CGPathCreateMutableCopy(path);
    if (copy != NULL && transform != NULL)
        O2PathApplyTransform((O2MutablePathRef)copy,
                             O2AffineTransformFromCG(*transform));
    return copy;
}

COREGRAPHICS_EXPORT CGPathRef
CGPathCreateWithRoundedRect(CGRect rect, CGFloat cornerWidth,
                            CGFloat cornerHeight,
                            const CGAffineTransform *transform)
{
    CGMutablePathRef path = CGPathCreateMutable();
    if (path == NULL)
        return NULL;
    CGPathAddRoundedRect(path, transform, rect, cornerWidth, cornerHeight);
    return (CGPathRef)path;
}

COREGRAPHICS_EXPORT bool CGPathIsEllipse(CGPathRef path, CGRect *rect) {
    CGRect bounds;
    CGPathRef ellipse;
    bool matches;
    if (rect != NULL)
        *rect = CGRectZero;
    if (path == NULL)
        return false;
    bounds = CGPathGetBoundingBox(path);
    ellipse = CGPathCreateWithEllipseInRect(bounds, NULL);
    if (ellipse == NULL)
        return false;
    matches = CGPathEqualToPath(path, ellipse);
    CGPathRelease(ellipse);
    if (matches && rect != NULL)
        *rect = bounds;
    return matches;
}

