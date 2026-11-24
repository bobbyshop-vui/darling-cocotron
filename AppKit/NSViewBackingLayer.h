#import <QuartzCore/CALayer.h>

@interface NSViewBackingLayer : CALayer {
    CGFloat _cornerRadius;
    BOOL _masksToBounds;
    CGColorRef _backgroundColor;
    CGFloat _borderWidth;
    CGColorRef _borderColor;
}

- (CGFloat) cornerRadius;
- (void) setCornerRadius: (CGFloat) value;
- (BOOL) masksToBounds;
- (void) setMasksToBounds: (BOOL) value;
- (CGColorRef) backgroundColor;
- (void) setBackgroundColor: (CGColorRef) value;
- (CGFloat) borderWidth;
- (void) setBorderWidth: (CGFloat) value;
- (CGColorRef) borderColor;
- (void) setBorderColor: (CGColorRef) value;

@end
