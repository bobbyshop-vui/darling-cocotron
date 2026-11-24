#import <AppKit/NSViewBackingLayer.h>
#import <AppKit/NSView.h>

@implementation NSViewBackingLayer

- (NSView *) _owningView {
    return _owningView;
}

- (void) _setOwningView: (NSView *) view {
    _owningView = view;
}

- (void) _setUpdatingFromView: (BOOL) flag {
    _updatingFromView = flag;
}

// The view draws this layer's background, border and contents into the window,
// so it has to redraw when they change.
- (void) _invalidateOwningView {
    if (_owningView != nil && !_updatingFromView)
        [_owningView setNeedsDisplay: YES];
}

- (CGFloat) cornerRadius {
    return _cornerRadius;
}

- (void) setCornerRadius: (CGFloat) value {
    if (value == _cornerRadius)
        return;
    _cornerRadius = value;
    [self _invalidateOwningView];
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
    BOOL changed = !(value != NULL && _backgroundColor != NULL &&
                     CGColorEqualToColor(value, _backgroundColor));
    CGColorRef old = _backgroundColor;
    _backgroundColor = value ? CGColorRetain(value) : NULL;
    if (old)
        CGColorRelease(old);
    if (changed)
        [self _invalidateOwningView];
}

- (CGFloat) borderWidth {
    return _borderWidth;
}

- (void) setBorderWidth: (CGFloat) value {
    if (value == _borderWidth)
        return;
    _borderWidth = value;
    [self _invalidateOwningView];
}

- (CGColorRef) borderColor {
    return _borderColor;
}

- (void) setBorderColor: (CGColorRef) value {
    if (value == _borderColor)
        return;
    BOOL changed = !(value != NULL && _borderColor != NULL &&
                     CGColorEqualToColor(value, _borderColor));
    CGColorRef old = _borderColor;
    _borderColor = value ? CGColorRetain(value) : NULL;
    if (old)
        CGColorRelease(old);
    if (changed)
        [self _invalidateOwningView];
}

- (void) setContents: (id) value {
    if (value == [self contents])
        return;
    [super setContents: value];
    [self _invalidateOwningView];
}

- (void) setNeedsDisplay {
    [super setNeedsDisplay];
    [self _invalidateOwningView];
}

- (void) setNeedsDisplayInRect: (CGRect) rect {
    [super setNeedsDisplayInRect: rect];
    [self _invalidateOwningView];
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
