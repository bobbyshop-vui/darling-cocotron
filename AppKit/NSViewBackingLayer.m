#import <AppKit/NSViewBackingLayer.h>

@implementation NSViewBackingLayer

- (CGFloat) cornerRadius {
    return _cornerRadius;
}

- (void) setCornerRadius: (CGFloat) value {
    _cornerRadius = value;
}

- (BOOL) masksToBounds {
    return _masksToBounds;
}

- (void) setMasksToBounds: (BOOL) value {
    _masksToBounds = value;
}

- (CGColorRef) backgroundColor {
    return _backgroundColor;
}

- (void) setBackgroundColor: (CGColorRef) value {
    if (value == _backgroundColor)
        return;
    CGColorRef old = _backgroundColor;
    _backgroundColor = value ? CGColorRetain(value) : NULL;
    if (old)
        CGColorRelease(old);
}

- (CGFloat) borderWidth {
    return _borderWidth;
}

- (void) setBorderWidth: (CGFloat) value {
    _borderWidth = value;
}

- (CGColorRef) borderColor {
    return _borderColor;
}

- (void) setBorderColor: (CGColorRef) value {
    if (value == _borderColor)
        return;
    CGColorRef old = _borderColor;
    _borderColor = value ? CGColorRetain(value) : NULL;
    if (old)
        CGColorRelease(old);
}

- (void) dealloc {
    if (_backgroundColor)
        CGColorRelease(_backgroundColor);
    if (_borderColor)
        CGColorRelease(_borderColor);
    [super dealloc];
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
