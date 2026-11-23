#import <AppKit/NSBitmapImageRep.h>
#import <AppKit/NSCIImageRep.h>
#import <AppKit/NSImageRep.h>
#import <AppKit/NSRaise.h>

@implementation CIImage (CIImageRepAdditions)

- initWithBitmapImageRep: (NSBitmapImageRep *) bitmapImageRep {
    return [self initWithCGImage: [bitmapImageRep CGImage]];
}

@end

@interface NSCIImageRep : NSImageRep {
    CIImage *_ciImage;
}
+ (instancetype) imageRepWithCIImage: (CIImage *) image;
- (instancetype) initWithCIImage: (CIImage *) image;
- (CIImage *) CIImage;
@end

@implementation NSCIImageRep

+ (instancetype) imageRepWithCIImage: (CIImage *) image {
    return [[[self alloc] initWithCIImage: image] autorelease];
}

- (instancetype) initWithCIImage: (CIImage *) image {
    if ((self = [super init]) != nil) {
        _ciImage = [image retain];
        CGRect extent = [image extent];
        if (!CGRectIsInfinite(extent) && !CGRectIsNull(extent)) {
            [self setSize: NSMakeSize(extent.size.width, extent.size.height)];
            [self setPixelsWide: (NSInteger) extent.size.width];
            [self setPixelsHigh: (NSInteger) extent.size.height];
        }
        [self setOpaque: NO];
    }
    return self;
}

- (void) dealloc {
    [_ciImage release];
    [super dealloc];
}

- (CIImage *) CIImage {
    return _ciImage;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [NSMethodSignature signatureWithObjCTypes: "v@:"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"Stub called: %@ in %@", NSStringFromSelector([anInvocation selector]), [self class]);
}

@end
