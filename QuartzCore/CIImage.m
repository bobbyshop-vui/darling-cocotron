#import <AppKit/NSGraphicsContext.h>
#import <AppKit/NSRaise.h>
#import <QuartzCore/CIContext.h>
#import <QuartzCore/CIImage.h>

@implementation CIImage

+ (CIImage *) emptyImage {
    return [[self alloc] initWithCGImage: NULL];
}

- initWithCGImage: (CGImageRef) cgImage {
    _cgImage = CGImageRetain(cgImage);
    _filter = nil;
    return self;
}

- (void) dealloc {
    CGImageRelease(_cgImage);
    [_filter release];
    [super dealloc];
}

- (CGRect) extent {
    CGRect result;

    result.origin.x = 0;
    result.origin.y = 0;
    result.size.width = CGImageGetWidth(_cgImage);
    result.size.height = CGImageGetHeight(_cgImage);

    return result;
}

static CGBlendMode CIImageBlendMode(NSCompositingOperation operation) {
    static const CGBlendMode table[] = {
            kCGBlendModeClear,
            kCGBlendModeCopy,
            kCGBlendModeNormal,
            kCGBlendModeSourceIn,
            kCGBlendModeSourceOut,
            kCGBlendModeSourceAtop,
            kCGBlendModeDestinationOver,
            kCGBlendModeDestinationIn,
            kCGBlendModeDestinationOut,
            kCGBlendModeDestinationAtop,
            kCGBlendModeXOR,
            kCGBlendModePlusDarker,
            kCGBlendModeNormal,
            kCGBlendModePlusLighter,
    };

    if ((unsigned) operation >= sizeof(table) / sizeof(table[0]))
        return kCGBlendModeNormal;
    return table[operation];
}

- (void) drawAtPoint: (NSPoint) point
            fromRect: (NSRect) fromRect
           operation: (NSCompositingOperation) operation
            fraction: (CGFloat) delta
{
    CGRect extent = [self extent];

    if (NSIsEmptyRect(fromRect))
        fromRect = extent;

    [self drawInRect: NSMakeRect(point.x, point.y, fromRect.size.width,
                                 fromRect.size.height)
            fromRect: fromRect
           operation: operation
            fraction: delta];
}

- (void) drawInRect: (NSRect) rect
           fromRect: (NSRect) fromRect
          operation: (NSCompositingOperation) operation
           fraction: (CGFloat) delta
{
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];

    if (context == NULL)
        return;

    if (NSIsEmptyRect(fromRect))
        fromRect = [self extent];

    CGContextSaveGState(context);
    CGContextSetBlendMode(context, CIImageBlendMode(operation));
    CGContextSetAlpha(context, delta);

    if (_cgImage != NULL) {
        CGImageRef part = CGImageCreateWithImageInRect(_cgImage, fromRect);

        if (part != NULL) {
            CGContextDrawImage(context, rect, part);
            CGImageRelease(part);
        }
    } else if (_filter != nil) {
        CIContext *ciContext = [CIContext contextWithCGContext: context
                                                       options: nil];

        [ciContext drawImage: self inRect: rect fromRect: fromRect];
    }

    CGContextRestoreGState(context);
}

- (CGImageRef) CGImage {
    return _cgImage;
}

- (CIFilter *) filter {
    return _filter;
}

- (void) setFilter: (CIFilter *) filter {
    filter = [filter retain];
    [_filter release];
    _filter = filter;
}

@end
