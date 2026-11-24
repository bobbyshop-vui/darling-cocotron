#import <QuartzCore/CALayer.h>

@class NSView;

@interface NSViewBackingLayer : CALayer {
    CGFloat _cornerRadius;
    BOOL _masksToBounds;
    CGColorRef _backgroundColor;
    CGFloat _borderWidth;
    CGColorRef _borderColor;
    // The view this layer backs (not retained). Layer-backed views draw into
    // the window, so a change to the layer has to redisplay the view.
    NSView *_owningView;
    BOOL _updatingFromView;
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

- (NSView *) _owningView;
- (void) _setOwningView: (NSView *) view;
// While set, property changes don't redisplay the view (it is the view's own
// -updateLayer running as part of drawing).
- (void) _setUpdatingFromView: (BOOL) flag;

@end
