#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/NSObject.h>
#import <AppKit/NSGraphics.h>

@class CIFilter;

@interface CIImage : NSObject {
    CGImageRef _cgImage;
    CIFilter *_filter;
}

+ (CIImage *) emptyImage;

- initWithCGImage: (CGImageRef) cgImage;
- (CGRect) extent;

- (void) drawAtPoint: (NSPoint) point
            fromRect: (NSRect) fromRect
           operation: (NSCompositingOperation) operation
            fraction: (CGFloat) delta;
- (void) drawInRect: (NSRect) rect
           fromRect: (NSRect) fromRect
          operation: (NSCompositingOperation) operation
           fraction: (CGFloat) delta;

@end
