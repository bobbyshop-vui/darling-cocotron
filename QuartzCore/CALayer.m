#import <objc/runtime.h>
#include <string.h>
#import <Foundation/NSDictionary.h>
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CALayer.h>
#import <QuartzCore/CALayerContext.h>
#import <QuartzCore/CAScrollLayer.h>
#import <QuartzCore/CATransaction.h>

NSString *const kCAFilterLinear = @"linear";
NSString *const kCAFilterNearest = @"nearest";
NSString *const kCAFilterTrilinear = @"trilinear";

NSString *const kCAGravityResizeAspect = @"resizeAspect";
NSString *const kCAGravityResizeAspectFill = @"resizeAspectFill";

NSString *const kCAGravityCenter = @"center";
NSString *const kCAGravityTop = @"top";
NSString *const kCAGravityBottom = @"bottom";
NSString *const kCAGravityLeft = @"left";
NSString *const kCAGravityRight = @"right";
NSString *const kCAGravityTopLeft = @"topLeft";
NSString *const kCAGravityTopRight = @"topRight";
NSString *const kCAGravityBottomLeft = @"bottomLeft";
NSString *const kCAGravityBottomRight = @"bottomRight";
NSString *const kCAGravityResize = @"resize";

NSString *const kCAOnOrderIn = @"onOrderIn";
NSString *const kCAOnOrderOut = @"onOrderOut";
NSString *const kCATransition = @"transition";

NSString *const kCAContentsFormatRGBA8Uint = @"RGBA8";
NSString *const kCAContentsFormatRGBA16Float = @"RGBAh";
NSString *const kCAContentsFormatGray8Uint = @"Gray8";

// Core Animation provides most CALayer properties dynamically: a property
// declared @dynamic (by CALayer here, or by a subclass such as Xcode's) gets
// accessors from +resolveInstanceMethod: that keep the value in the layer's
// _attributes dictionary and fall back to +defaultValueForKey:.

@interface CALayer (DynamicProperties)
- (id) _dynamicValueForSelector: (SEL) selector;
- (void) _setDynamicValue: (id) value forSelector: (SEL) selector;
@end

static NSMutableDictionary *CALayerDynamicKeys = nil; // selector name -> key

static NSString *CALayerKeyForSelector(SEL selector) {
    @synchronized ([CALayer class]) {
        return [CALayerDynamicKeys
                objectForKey: [NSString stringWithUTF8String: sel_getName(selector)]];
    }
}

static id CALayerGetObject(CALayer *self, SEL _cmd) {
    return [[[self _dynamicValueForSelector: _cmd] retain] autorelease];
}

static void CALayerSetObject(CALayer *self, SEL _cmd, id value) {
    [self _setDynamicValue: value forSelector: _cmd];
}

static void CALayerSetCopiedObject(CALayer *self, SEL _cmd, id value) {
    id copy = [value copy];
    [self _setDynamicValue: copy forSelector: _cmd];
    [copy release];
}

static void *CALayerGetPointer(CALayer *self, SEL _cmd) {
    return [[self _dynamicValueForSelector: _cmd] pointerValue];
}

static void CALayerSetPointer(CALayer *self, SEL _cmd, void *value) {
    [self _setDynamicValue: value ? [NSValue valueWithPointer: value] : nil
               forSelector: _cmd];
}

#define CALAYER_SCALAR_ACCESSORS(NAME, TYPE, GETTER, BOXER)                   \
    static TYPE CALayerGet##NAME(CALayer *self, SEL _cmd) {                  \
        id value = [self _dynamicValueForSelector: _cmd];                    \
        return value != nil ? (TYPE)[value GETTER] : (TYPE) 0;               \
    }                                                                        \
    static void CALayerSet##NAME(CALayer *self, SEL _cmd, TYPE value) {      \
        [self _setDynamicValue: [NSNumber BOXER value] forSelector: _cmd];   \
    }

CALAYER_SCALAR_ACCESSORS(Char, char, charValue, numberWithChar:)
CALAYER_SCALAR_ACCESSORS(UChar, unsigned char, unsignedCharValue, numberWithUnsignedChar:)
CALAYER_SCALAR_ACCESSORS(Bool, bool, boolValue, numberWithBool:)
CALAYER_SCALAR_ACCESSORS(Short, short, shortValue, numberWithShort:)
CALAYER_SCALAR_ACCESSORS(UShort, unsigned short, unsignedShortValue, numberWithUnsignedShort:)
CALAYER_SCALAR_ACCESSORS(Int, int, intValue, numberWithInt:)
CALAYER_SCALAR_ACCESSORS(UInt, unsigned int, unsignedIntValue, numberWithUnsignedInt:)
CALAYER_SCALAR_ACCESSORS(Long, long, longValue, numberWithLong:)
CALAYER_SCALAR_ACCESSORS(ULong, unsigned long, unsignedLongValue, numberWithUnsignedLong:)
CALAYER_SCALAR_ACCESSORS(LongLong, long long, longLongValue, numberWithLongLong:)
CALAYER_SCALAR_ACCESSORS(ULongLong, unsigned long long, unsignedLongLongValue, numberWithUnsignedLongLong:)
CALAYER_SCALAR_ACCESSORS(Float, float, floatValue, numberWithFloat:)
CALAYER_SCALAR_ACCESSORS(Double, double, doubleValue, numberWithDouble:)

#define CALAYER_STRUCT_ACCESSORS(NAME, TYPE)                                 \
    static TYPE CALayerGet##NAME(CALayer *self, SEL _cmd) {                  \
        TYPE result;                                                         \
        memset(&result, 0, sizeof(result));                                  \
        id value = [self _dynamicValueForSelector: _cmd];                    \
        if ([value isKindOfClass: [NSValue class]])                          \
            [value getValue: &result];                                       \
        return result;                                                       \
    }                                                                        \
    static void CALayerSet##NAME(CALayer *self, SEL _cmd, TYPE value) {      \
        [self _setDynamicValue: [NSValue valueWithBytes: &value              \
                                               objCType: @encode(TYPE)]      \
                   forSelector: _cmd];                                       \
    }

CALAYER_STRUCT_ACCESSORS(Point, CGPoint)
CALAYER_STRUCT_ACCESSORS(Size, CGSize)
CALAYER_STRUCT_ACCESSORS(Rect, CGRect)
CALAYER_STRUCT_ACCESSORS(Transform3D, CATransform3D)
CALAYER_STRUCT_ACCESSORS(AffineTransform, CGAffineTransform)

static BOOL CALayerStructIs(const char *type, const char *name) {
    size_t length = strlen(name);
    return type[0] == '{' && strncmp(type + 1, name, length) == 0 &&
           (type[length + 1] == '=' || type[length + 1] == '}');
}

// Picks the accessor implementations for a property's type encoding.
static BOOL CALayerAccessorsForType(const char *type, BOOL copies,
                                    IMP *getter, IMP *setter) {
    while (*type && strchr("rnNoORV", *type))
        type++;
    switch (*type) {
    case '@':
    case '#':
        *getter = (IMP) CALayerGetObject;
        *setter = copies ? (IMP) CALayerSetCopiedObject : (IMP) CALayerSetObject;
        return YES;
    case '^':
        // CGColorRef, CGPathRef, CGImageRef... are Objective-C objects in
        // Darling; anything else is kept as a plain pointer.
        if (strncmp(type, "^{O2", 4) == 0 || strncmp(type, "^{CG", 4) == 0 ||
            strncmp(type, "^{__CF", 6) == 0) {
            *getter = (IMP) CALayerGetObject;
            *setter = (IMP) CALayerSetObject;
        } else {
            *getter = (IMP) CALayerGetPointer;
            *setter = (IMP) CALayerSetPointer;
        }
        return YES;
#define CALAYER_CASE(CHARACTER, NAME)                                        \
    case CHARACTER:                                                          \
        *getter = (IMP) CALayerGet##NAME;                                    \
        *setter = (IMP) CALayerSet##NAME;                                    \
        return YES;
    CALAYER_CASE('c', Char)
    CALAYER_CASE('C', UChar)
    CALAYER_CASE('B', Bool)
    CALAYER_CASE('s', Short)
    CALAYER_CASE('S', UShort)
    CALAYER_CASE('i', Int)
    CALAYER_CASE('I', UInt)
    CALAYER_CASE('l', Long)
    CALAYER_CASE('L', ULong)
    CALAYER_CASE('q', LongLong)
    CALAYER_CASE('Q', ULongLong)
    CALAYER_CASE('f', Float)
    CALAYER_CASE('d', Double)
#undef CALAYER_CASE
    case '{':
        if (CALayerStructIs(type, "CGPoint") || CALayerStructIs(type, "_NSPoint")) {
            *getter = (IMP) CALayerGetPoint;
            *setter = (IMP) CALayerSetPoint;
        } else if (CALayerStructIs(type, "CGSize") || CALayerStructIs(type, "_NSSize")) {
            *getter = (IMP) CALayerGetSize;
            *setter = (IMP) CALayerSetSize;
        } else if (CALayerStructIs(type, "CGRect") || CALayerStructIs(type, "_NSRect")) {
            *getter = (IMP) CALayerGetRect;
            *setter = (IMP) CALayerSetRect;
        } else if (CALayerStructIs(type, "CATransform3D")) {
            *getter = (IMP) CALayerGetTransform3D;
            *setter = (IMP) CALayerSetTransform3D;
        } else if (CALayerStructIs(type, "CGAffineTransform")) {
            *getter = (IMP) CALayerGetAffineTransform;
            *setter = (IMP) CALayerSetAffineTransform;
        } else
            return NO;
        return YES;
    }
    return NO;
}

// Adds the accessor named by selector if a @dynamic property of cls (or of
// one of its superclasses) declares it.
static BOOL CALayerResolveDynamicAccessor(Class cls, SEL selector) {
    const char *name = sel_getName(selector);

    for (Class owner = cls; owner != Nil; owner = class_getSuperclass(owner)) {
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList(owner, &count);
        BOOL resolved = NO;

        for (unsigned int i = 0; i < count && !resolved; i++) {
            char *dynamic = property_copyAttributeValue(properties[i], "D");
            if (dynamic == NULL)
                continue;
            free(dynamic);

            const char *key = property_getName(properties[i]);
            char *customGetter = property_copyAttributeValue(properties[i], "G");
            char *customSetter = property_copyAttributeValue(properties[i], "S");
            char *readonly = property_copyAttributeValue(properties[i], "R");
            char *copies = property_copyAttributeValue(properties[i], "C");
            char *type = property_copyAttributeValue(properties[i], "T");

            char setterName[256];
            if (customSetter != NULL)
                snprintf(setterName, sizeof(setterName), "%s", customSetter);
            else
                snprintf(setterName, sizeof(setterName), "set%c%s:",
                         (key[0] >= 'a' && key[0] <= 'z') ? key[0] - 'a' + 'A' : key[0],
                         key + 1);
            const char *getterName = customGetter != NULL ? customGetter : key;
            BOOL isGetter = strcmp(name, getterName) == 0;
            BOOL isSetter = readonly == NULL && strcmp(name, setterName) == 0;
            IMP getter = NULL, setter = NULL;

            if ((isGetter || isSetter) && type != NULL &&
                CALayerAccessorsForType(type, copies != NULL, &getter, &setter)) {
                NSString *keyString = [NSString stringWithUTF8String: key];
                @synchronized ([CALayer class]) {
                    if (CALayerDynamicKeys == nil)
                        CALayerDynamicKeys = [[NSMutableDictionary alloc] init];
                    [CALayerDynamicKeys setObject: keyString
                            forKey: [NSString stringWithUTF8String: getterName]];
                    if (readonly == NULL)
                        [CALayerDynamicKeys setObject: keyString
                                forKey: [NSString stringWithUTF8String: setterName]];
                }
                char types[512];
                if (isGetter) {
                    snprintf(types, sizeof(types), "%s@:", type);
                    class_addMethod(owner, selector, getter, types);
                } else {
                    snprintf(types, sizeof(types), "v@:%s", type);
                    class_addMethod(owner, selector, setter, types);
                }
                resolved = YES;
            }

            free(customGetter);
            free(customSetter);
            free(readonly);
            free(copies);
            free(type);
        }
        free(properties);
        if (resolved)
            return YES;
    }
    return NO;
}

static CGPoint CALayerPointToSuperlayer(CALayer *layer, CGPoint point) {
    CGRect bounds = [layer bounds];
    CGPoint anchor = [layer anchorPoint];
    CGPoint position = [layer position];
    point.x += position.x - bounds.origin.x - bounds.size.width * anchor.x;
    point.y += position.y - bounds.origin.y - bounds.size.height * anchor.y;
    return point;
}

static CGPoint CALayerPointFromSuperlayer(CALayer *layer, CGPoint point) {
    CGRect bounds = [layer bounds];
    CGPoint anchor = [layer anchorPoint];
    CGPoint position = [layer position];
    point.x -= position.x - bounds.origin.x - bounds.size.width * anchor.x;
    point.y -= position.y - bounds.origin.y - bounds.size.height * anchor.y;
    return point;
}

static CGPoint CALayerPointToRoot(CALayer *layer, CGPoint point) {
    for (; layer != nil; layer = [layer superlayer])
        point = CALayerPointToSuperlayer(layer, point);
    return point;
}

static CGPoint CALayerPointFromRoot(CALayer *layer, CGPoint point) {
    if (layer == nil)
        return point;
    return CALayerPointFromSuperlayer(
            layer, CALayerPointFromRoot([layer superlayer], point));
}

@implementation CALayer

@dynamic zPosition, anchorPointZ, hidden, doubleSided, geometryFlipped, mask,
        masksToBounds, contentsRect, contentsGravity, contentsScale,
        contentsCenter, contentsFormat, minificationFilterBias,
        needsDisplayOnBoundsChange, drawsAsynchronously, edgeAntialiasingMask,
        allowsEdgeAntialiasing, backgroundColor, cornerRadius, maskedCorners,
        borderWidth, borderColor, allowsGroupOpacity, compositingFilter,
        filters, backgroundFilters, shouldRasterize, rasterizationScale,
        shadowColor, shadowOpacity, shadowOffset, shadowRadius, shadowPath,
        autoresizingMask, layoutManager, actions, name, style;
@dynamic autoreverses, beginTime, duration, fillMode, repeatCount,
        repeatDuration, speed, timeOffset;

+ (BOOL) resolveInstanceMethod: (SEL) selector {
    if (CALayerResolveDynamicAccessor(self, selector))
        return YES;
    return [super resolveInstanceMethod: selector];
}

+ (id) defaultValueForKey: (NSString *) key {
    static NSDictionary *defaults = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        CGSize shadowOffset = CGSizeMake(0, -3);
        CGRect unitRect = CGRectMake(0, 0, 1, 1);
        CGColorRef black = CGColorCreateGenericRGB(0, 0, 0, 1);
        defaults = [[NSDictionary alloc] initWithObjectsAndKeys:
                [NSNumber numberWithDouble: 1.0], @"contentsScale",
                [NSNumber numberWithDouble: 1.0], @"rasterizationScale",
                [NSNumber numberWithFloat: 1.0f], @"speed",
                [NSNumber numberWithDouble: 3.0], @"shadowRadius",
                [NSValue valueWithBytes: &shadowOffset objCType: @encode(CGSize)], @"shadowOffset",
                (id) black, @"shadowColor",
                [NSNumber numberWithBool: YES], @"doubleSided",
                [NSNumber numberWithBool: YES], @"allowsGroupOpacity",
                [NSNumber numberWithUnsignedInt: 15], @"edgeAntialiasingMask",
                [NSNumber numberWithUnsignedInteger: 15], @"maskedCorners",
                [NSValue valueWithBytes: &unitRect objCType: @encode(CGRect)], @"contentsRect",
                [NSValue valueWithBytes: &unitRect objCType: @encode(CGRect)], @"contentsCenter",
                kCAGravityResize, @"contentsGravity",
                kCAContentsFormatRGBA8Uint, @"contentsFormat",
                kCAFillModeRemoved, @"fillMode",
                nil];
        CGColorRelease(black);
    });
    return [defaults objectForKey: key];
}

+ (BOOL) needsDisplayForKey: (NSString *) key {
    return NO;
}

+ (id<CAAction>) defaultActionForKey: (NSString *) event {
    return nil;
}

- (id) _dynamicValueForSelector: (SEL) selector {
    NSString *key = CALayerKeyForSelector(selector);
    if (key == nil)
        return nil;
    id value = [_attributes objectForKey: key];
    return value != nil ? value : [[self class] defaultValueForKey: key];
}

- (void) _setDynamicValue: (id) value forSelector: (SEL) selector {
    NSString *key = CALayerKeyForSelector(selector);
    if (key == nil)
        return;
    if (value != nil)
        [_attributes setObject: value forKey: key];
    else
        [_attributes removeObjectForKey: key];
    if ([[self class] needsDisplayForKey: key])
        [self setNeedsDisplay];
}

// Like Core Animation, a layer accepts any key-value coding key.
- (id) valueForUndefinedKey: (NSString *) key {
    id value = [_attributes objectForKey: key];
    return value != nil ? value : [[self class] defaultValueForKey: key];
}

- (void) setValue: (id) value forUndefinedKey: (NSString *) key {
    if (value != nil)
        [_attributes setObject: value forKey: key];
    else
        [_attributes removeObjectForKey: key];
}

+ layer {
    return [[[self alloc] init] autorelease];
}

- (instancetype) initWithLayer: (id) layer {
    self = [self init];
    if (self == nil || ![layer isKindOfClass: [CALayer class]])
        return self;
    CALayer *other = layer;
    _anchorPoint = other->_anchorPoint;
    _position = other->_position;
    _bounds = other->_bounds;
    _opacity = other->_opacity;
    _opaque = other->_opaque;
    _transform = other->_transform;
    _sublayerTransform = other->_sublayerTransform;
    _delegate = other->_delegate;
    [self setContents: other->_contents];
    [self setMinificationFilter: other->_minificationFilter];
    [self setMagnificationFilter: other->_magnificationFilter];
    [_attributes addEntriesFromDictionary: other->_attributes];
    return self;
}

// Darling applies changes immediately, so the model is what is presented.
- (id) presentationLayer {
    return self;
}

- (id) modelLayer {
    return self;
}

- (BOOL) shouldArchiveValueForKey: (NSString *) key {
    return YES;
}

- (CGAffineTransform) affineTransform {
    return CATransform3DGetAffineTransform(_transform);
}

- (void) setAffineTransform: (CGAffineTransform) transform {
    [self setTransform: CATransform3DMakeAffineTransform(transform)];
}

- (BOOL) contentsAreFlipped {
    return [self isGeometryFlipped];
}

- (CGRect) visibleRect {
    return _bounds;
}

- (CALayerContext *) _context {
    return _context;
}

- (void) _setContext: (CALayerContext *) context {
    if (_context != context) {
        [_context deleteTextureId: _textureId];
        [_textureId release];
        _textureId = nil;
    }

    _context = context;
    [_sublayers makeObjectsPerformSelector: @selector(_setContext:)
                                withObject: context];
}

- (CALayer *) superlayer {
    return _superlayer;
}

- (NSArray *) sublayers {
    return _sublayers;
}

- (void) setSublayers: (NSArray *) sublayers {
    sublayers = [sublayers copy];
    [_sublayers release];
    _sublayers = sublayers;
    [_sublayers makeObjectsPerformSelector: @selector(_setSuperLayer:)
                                withObject: self];
    [_sublayers makeObjectsPerformSelector: @selector(_setContext:)
                                withObject: _context];
}

- (id<CALayerDelegate>) delegate {
    return _delegate;
}

- (void) setDelegate: (id<CALayerDelegate>)value {
    _delegate = value;
}

- (CGPoint) anchorPoint {
    return _anchorPoint;
}

- (void) setAnchorPoint: (CGPoint) value {
    _anchorPoint = value;
}

- (CGPoint) position {
    return _position;
}

- (void) setPosition: (CGPoint) value {
    CAAnimation *animation = [self animationForKey: @"position"];

    if (animation == nil && ![CATransaction disableActions]) {
        id action = [self actionForKey: @"position"];

        if (action != nil)
            [self addAnimation: action forKey: @"position"];
    }

    _position = value;
}

- (CGRect) bounds {
    return _bounds;
}

- (void) setBounds: (CGRect) value {
    CAAnimation *animation = [self animationForKey: @"bounds"];

    if (animation == nil && ![CATransaction disableActions]) {
        id action = [self actionForKey: @"bounds"];

        if (action != nil)
            [self addAnimation: action forKey: @"bounds"];
    }

    CGSize oldSize = _bounds.size;
    _bounds = value;
    if (!CGSizeEqualToSize(oldSize, value.size)) {
        if ([self layoutManager] == nil)
            [self resizeSublayersWithOldSize: oldSize];
        else
            [self setNeedsLayout];
        if ([self needsDisplayOnBoundsChange])
            [self setNeedsDisplay];
    }
}

- (CGRect) frame {
    CGRect result;

    result.size = _bounds.size;
    result.origin.x = _position.x - result.size.width * _anchorPoint.x;
    result.origin.y = _position.y - result.size.height * _anchorPoint.y;

    return result;
}

- (void) setFrame: (CGRect) value {

    CGPoint position;

    position.x = value.origin.x + value.size.width * _anchorPoint.x;
    position.y = value.origin.y + value.size.height * _anchorPoint.y;

    [self setPosition: position];

    CGRect bounds = _bounds;

    bounds.size = value.size;

    [self setBounds: bounds];
}

- (CGFloat) opacity {
    return _opacity;
}

- (void) setOpacity: (CGFloat) value {
    CAAnimation *animation = [self animationForKey: @"opacity"];

    if (animation == nil && ![CATransaction disableActions]) {
        id action = [self actionForKey: @"opacity"];

        if (action != nil)
            [self addAnimation: action forKey: @"opacity"];
    }

    _opacity = value;
}

- (BOOL) opaque {
    return _opaque;
}

- (void) setOpaque: (BOOL) value {
    _opaque = value;
}

- (id) contents {
    return _contents;
}

- (void) setContents: (id) value {
    value = [value retain];
    [_contents release];
    _contents = value;
}

- (CATransform3D) transform {
    return _transform;
}

- (void) setTransform: (CATransform3D) value {
    _transform = value;
}

- (CATransform3D) sublayerTransform {
    return _sublayerTransform;
}

- (void) setSublayerTransform: (CATransform3D) value {
    _sublayerTransform = value;
}

- (NSString *) minificationFilter {
    return _minificationFilter;
}

- (void) setMinificationFilter: (NSString *) value {
    value = [value copy];
    [_minificationFilter release];
    _minificationFilter = value;
}

- (NSString *) magnificationFilter {
    return _magnificationFilter;
}

- (void) setMagnificationFilter: (NSString *) value {
    value = [value copy];
    [_magnificationFilter release];
    _magnificationFilter = value;
}

- init {
    _superlayer = nil;
    _sublayers = [NSArray new];
    _delegate = nil;
    _anchorPoint = CGPointMake(0.5, 0.5);
    _position = CGPointZero;
    _bounds = CGRectZero;
    _opacity = 1.0;
    _opaque = YES;
    _contents = nil;
    _transform = CATransform3DIdentity;
    _sublayerTransform = CATransform3DIdentity;
    _minificationFilter = kCAFilterLinear;
    _magnificationFilter = kCAFilterLinear;
    _animations = [[NSMutableDictionary alloc] init];
    _attributes = [[NSMutableDictionary alloc] init];
    return self;
}

- (void) dealloc {
    [_sublayers release];
    [_animations release];
    [_attributes release];
    [_minificationFilter release];
    [_magnificationFilter release];
    [super dealloc];
}

- (void) _setSuperLayer: (CALayer *) parent {
    _superlayer = parent;
}

- (void) _removeSublayer: (CALayer *) child {
    NSMutableArray *layers = [_sublayers mutableCopy];
    [layers removeObjectIdenticalTo: child];
    [self setSublayers: layers];
    [layers release];
}

- (void) insertSublayer: (CALayer *) layer atIndex: (unsigned) index {
    if (layer == nil)
        return;
    [[layer retain] autorelease];
    if (layer->_superlayer != nil) {
        [layer->_superlayer _removeSublayer: layer];
        layer->_superlayer = nil;
    }

    NSMutableArray *layers = [_sublayers mutableCopy];
    if (index > [layers count])
        index = (unsigned) [layers count];
    [layers insertObject: layer atIndex: index];
    [self setSublayers: layers];
    [layers release];
}

- (void) addSublayer: (CALayer *) layer {
    if (layer == nil)
        return;
    if (layer->_superlayer == self) {
        // Moves it to the front.
        [[layer retain] autorelease];
        [self _removeSublayer: layer];
        layer->_superlayer = nil;
    }
    [self insertSublayer: layer atIndex: (unsigned) [_sublayers count]];
}

- (void) insertSublayer: (CALayer *) layer below: (CALayer *) sibling {
    NSUInteger index = [_sublayers indexOfObjectIdenticalTo: sibling];
    if (layer == nil || layer == sibling)
        return;
    if (layer->_superlayer == self) {
        [[layer retain] autorelease];
        [self _removeSublayer: layer];
        layer->_superlayer = nil;
        index = [_sublayers indexOfObjectIdenticalTo: sibling];
    }
    [self insertSublayer: layer
                 atIndex: index == NSNotFound ? 0 : (unsigned) index];
}

- (void) insertSublayer: (CALayer *) layer above: (CALayer *) sibling {
    NSUInteger index = [_sublayers indexOfObjectIdenticalTo: sibling];
    if (layer == nil || layer == sibling)
        return;
    if (layer->_superlayer == self) {
        [[layer retain] autorelease];
        [self _removeSublayer: layer];
        layer->_superlayer = nil;
        index = [_sublayers indexOfObjectIdenticalTo: sibling];
    }
    [self insertSublayer: layer
                 atIndex: index == NSNotFound ? (unsigned) [_sublayers count]
                                              : (unsigned) index + 1];
}

- (CGPoint) convertPoint: (CGPoint) point fromLayer: (CALayer *) layer {
    CGPoint root = layer != nil ? CALayerPointToRoot(layer, point) : point;
    return CALayerPointFromRoot(self, root);
}

- (CGPoint) convertPoint: (CGPoint) point toLayer: (CALayer *) layer {
    CGPoint root = CALayerPointToRoot(self, point);
    return layer != nil ? CALayerPointFromRoot(layer, root) : root;
}

// Darling's layers are not rotated or scaled, so only the origin moves.
- (CGRect) convertRect: (CGRect) rect fromLayer: (CALayer *) layer {
    rect.origin = [self convertPoint: rect.origin fromLayer: layer];
    return rect;
}

- (CGRect) convertRect: (CGRect) rect toLayer: (CALayer *) layer {
    rect.origin = [self convertPoint: rect.origin toLayer: layer];
    return rect;
}

- (CFTimeInterval) convertTime: (CFTimeInterval) time fromLayer: (CALayer *) layer {
    return time;
}

- (CFTimeInterval) convertTime: (CFTimeInterval) time toLayer: (CALayer *) layer {
    return time;
}

- (BOOL) containsPoint: (CGPoint) point {
    return CGRectContainsPoint(_bounds, point);
}

// point is in the superlayer's coordinates.
- (CALayer *) hitTest: (CGPoint) point {
    if ([self isHidden])
        return nil;
    CGPoint local = CALayerPointFromSuperlayer(self, point);
    if (![self containsPoint: local])
        return nil;
    for (CALayer *sublayer in [_sublayers reverseObjectEnumerator]) {
        CALayer *hit = [sublayer hitTest: local];
        if (hit != nil)
            return hit;
    }
    return self;
}

- (void) renderInContext: (CGContextRef) context {
    if ([self isHidden])
        return;
    CGColorRef background = [self backgroundColor];
    if (background != NULL) {
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, background);
        CGContextFillRect(context, _bounds);
        CGContextRestoreGState(context);
    }
    [self drawInContext: context];
    for (CALayer *sublayer in _sublayers) {
        CGRect frame = [sublayer frame];
        CGRect bounds = [sublayer bounds];
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, frame.origin.x - bounds.origin.x,
                              frame.origin.y - bounds.origin.y);
        [sublayer renderInContext: context];
        CGContextRestoreGState(context);
    }
}

- (CGSize) preferredFrameSize {
    id manager = [self layoutManager];
    if ([manager respondsToSelector: @selector(preferredSizeOfLayer:)])
        return [manager preferredSizeOfLayer: self];
    return _bounds.size;
}

static NSString *const CALayerNeedsLayoutKey = @"__darlingNeedsLayout";

- (void) setNeedsLayout {
    [_attributes setObject: [NSNumber numberWithBool: YES]
                    forKey: CALayerNeedsLayoutKey];
}

- (BOOL) needsLayout {
    return [[_attributes objectForKey: CALayerNeedsLayoutKey] boolValue];
}

- (void) layoutIfNeeded {
    if ([self needsLayout]) {
        [_attributes removeObjectForKey: CALayerNeedsLayoutKey];
        [self layoutSublayers];
    }
    [_sublayers makeObjectsPerformSelector: @selector(layoutIfNeeded)];
}

- (void) layoutSublayers {
    if ([_delegate respondsToSelector: @selector(layoutSublayersOfLayer:)])
        [_delegate layoutSublayersOfLayer: self];
    else {
        id manager = [self layoutManager];
        if ([manager respondsToSelector: @selector(layoutSublayersOfLayer:)])
            [manager layoutSublayersOfLayer: self];
    }
}

- (void) resizeSublayersWithOldSize: (CGSize) size {
    for (CALayer *sublayer in [[_sublayers copy] autorelease])
        [sublayer resizeWithOldSuperlayerSize: size];
}

// The same rules as NSView autoresizing, with kCALayer*Margin/*Sizable.
- (void) resizeWithOldSuperlayerSize: (CGSize) oldSize {
    unsigned int mask = [self autoresizingMask];
    if (mask == kCALayerNotSizable || _superlayer == nil)
        return;
    CGSize newSize = [_superlayer bounds].size;
    CGRect frame = [self frame];
    CGFloat dx = newSize.width - oldSize.width;
    CGFloat dy = newSize.height - oldSize.height;
    int flexibleX = ((mask & kCALayerMinXMargin) != 0) +
                    ((mask & kCALayerWidthSizable) != 0) +
                    ((mask & kCALayerMaxXMargin) != 0);
    int flexibleY = ((mask & kCALayerMinYMargin) != 0) +
                    ((mask & kCALayerHeightSizable) != 0) +
                    ((mask & kCALayerMaxYMargin) != 0);

    if (flexibleX > 0) {
        CGFloat share = dx / flexibleX;
        if (mask & kCALayerMinXMargin)
            frame.origin.x += share;
        if (mask & kCALayerWidthSizable)
            frame.size.width = MAX(frame.size.width + share, 0);
    }
    if (flexibleY > 0) {
        CGFloat share = dy / flexibleY;
        if (mask & kCALayerMinYMargin)
            frame.origin.y += share;
        if (mask & kCALayerHeightSizable)
            frame.size.height = MAX(frame.size.height + share, 0);
    }
    [self setFrame: frame];
}

// Scrolling is done by an enclosing CAScrollLayer.
- (void) scrollPoint: (CGPoint) point {
    for (CALayer *layer = _superlayer; layer != nil; layer = layer->_superlayer) {
        if ([layer isKindOfClass: [CAScrollLayer class]]) {
            CGPoint target = [self convertPoint: point toLayer: layer];
            [(CAScrollLayer *) layer scrollToPoint: target];
            return;
        }
    }
}

- (void) scrollRectToVisible: (CGRect) rect {
    [self scrollPoint: rect.origin];
}

- (void) replaceSublayer: (CALayer *) layer with: (CALayer *) other {
    NSMutableArray *layers = [_sublayers mutableCopy];
    NSUInteger index = [_sublayers indexOfObjectIdenticalTo: layer];

    [layers replaceObjectAtIndex: index withObject: other];

    [self setSublayers: layers];
    [layers release];

    layer->_superlayer = nil;
}

- (void) display {
    if ([_delegate respondsToSelector: @selector(displayLayer:)])
        [_delegate displayLayer: self];
    else {
#if 0

#warning create bitmap context

    [self drawInContext:context];
    _contents=image;
    [self setContents:image];
#endif
    }
}

- (void) displayIfNeeded {
}

- (void) drawInContext: (CGContextRef) context {
    if ([_delegate respondsToSelector: @selector(drawLayer:inContext:)])
        [_delegate drawLayer: self inContext: context];
}

- (BOOL) needsDisplay {
    return _needsDisplay;
}

- (void) removeFromSuperlayer {
    [_superlayer _removeSublayer: self];
    _superlayer = nil;
    [self _setContext: nil];
}

- (void) setNeedsDisplay {
    _needsDisplay = YES;
}

- (void) setNeedsDisplayInRect: (CGRect) rect {
    _needsDisplay = YES;
}

- (void) addAnimation: (CAAnimation *) animation forKey: (NSString *) key {
    if (_context == nil)
        return;

    [_animations setObject: animation forKey: key];
    [_context startTimerIfNeeded];
}

- (CAAnimation *) animationForKey: (NSString *) key {
    return [_animations objectForKey: key];
}

- (void) removeAllAnimations {
    [_animations removeAllObjects];
}

- (void) removeAnimationForKey: (NSString *) key {
    [_animations removeObjectForKey: key];
}

- (NSArray *) animationKeys {
    return [_animations allKeys];
}

- valueForKey: (NSString *) key {
    // FIXME: KVC appears broken for structs

    if ([key isEqualToString: @"bounds"])
        return [NSValue valueWithRect: _bounds];
    if ([key isEqualToString: @"frame"])
        return [NSValue valueWithRect: [self frame]];

    return [super valueForKey: key];
}

- (id<CAAction>) actionForKey: (NSString *) key {
    CABasicAnimation *basic = [CABasicAnimation animationWithKeyPath: key];

    [basic setFromValue: [self valueForKey: key]];

    return basic;
}

- (NSNumber *) _textureId {
    return _textureId;
}

- (void) _setTextureId: (NSNumber *) value {
    value = [value copy];
    [_textureId release];
    _textureId = value;
}

@end
