#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/NSObject.h>

@class NSColor;

@interface CIColor : NSObject {
    CGColorRef _cgColor;
}

+ (CIColor *) colorWithCGColor: (CGColorRef) cgColor;

+ (CIColor *) colorWithRed: (CGFloat) red
                     green: (CGFloat) green
                      blue: (CGFloat) blue;
+ (CIColor *) colorWithRed: (CGFloat) red
                     green: (CGFloat) green
                      blue: (CGFloat) blue
                     alpha: (CGFloat) alpha;

- initWithCGColor: (CGColorRef) cgColor;
- (instancetype) initWithColor: (NSColor *) color;

- (size_t) numberOfComponents;
- (CGColorSpaceRef) colorSpace;
- (const CGFloat *) components;

- (CGFloat) red;
- (CGFloat) green;
- (CGFloat) blue;
- (CGFloat) alpha;

@end
