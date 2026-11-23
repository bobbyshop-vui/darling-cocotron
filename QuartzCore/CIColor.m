#import <AppKit/NSColor.h>
#import <AppKit/NSGraphics.h>
#import <QuartzCore/CIColor.h>

@implementation CIColor

+ (CIColor *) colorWithCGColor: (CGColorRef) cgColor {
    return [[[self alloc] initWithCGColor: cgColor] autorelease];
}

+ (CIColor *) colorWithRed: (CGFloat) red
                     green: (CGFloat) green
                      blue: (CGFloat) blue
{
    CGColorRef cgColor = CGColorCreateGenericRGB(red, green, blue, 1.0);
    CIColor *result = [self colorWithCGColor: cgColor];

    CGColorRelease(cgColor);

    return result;
}

+ (CIColor *) colorWithRed: (CGFloat) red
                     green: (CGFloat) green
                      blue: (CGFloat) blue
                     alpha: (CGFloat) alpha
{
    CGColorRef cgColor = CGColorCreateGenericRGB(red, green, blue, alpha);
    CIColor *result = [self colorWithCGColor: cgColor];

    CGColorRelease(cgColor);

    return result;
}

- initWithCGColor: (CGColorRef) cgColor {
    _cgColor = CGColorRetain(cgColor);
    return self;
}

- (instancetype) initWithColor: (NSColor *) color {
    NSColor *rgb = [color colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
    CGFloat red = 0, green = 0, blue = 0, alpha = 1;

    [rgb getRed: &red green: &green blue: &blue alpha: &alpha];

    CGColorRef cgColor = CGColorCreateGenericRGB(red, green, blue, alpha);

    self = [self initWithCGColor: cgColor];
    CGColorRelease(cgColor);
    return self;
}

- (void) dealloc {
    CGColorRelease(_cgColor);
    [super dealloc];
}

- (size_t) numberOfComponents {
    return CGColorGetNumberOfComponents(_cgColor);
}

- (CGColorSpaceRef) colorSpace {
    return CGColorGetColorSpace(_cgColor);
}

- (const CGFloat *) components {
    return CGColorGetComponents(_cgColor);
}

- (CGFloat) red {
    return CGColorGetComponents(_cgColor)[0];
}

- (CGFloat) green {
    return CGColorGetComponents(_cgColor)[1];
}

- (CGFloat) blue {
    return CGColorGetComponents(_cgColor)[2];
}

- (CGFloat) alpha {
    return CGColorGetComponents(_cgColor)[3];
}

@end
