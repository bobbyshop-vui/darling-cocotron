#import <Foundation/Foundation.h>
#import <QuartzCore/CAConstraintLayoutManager.h>

@implementation CAConstraint

+ (BOOL) supportsSecureCoding {
    return YES;
}

+ (instancetype) constraintWithAttribute: (CAConstraintAttribute) attribute
                              relativeTo: (NSString *) sourceName
                               attribute: (CAConstraintAttribute) sourceAttribute
                                   scale: (CGFloat) scale
                                  offset: (CGFloat) offset
{
    return [[[self alloc] initWithAttribute: attribute
                                 relativeTo: sourceName
                                  attribute: sourceAttribute
                                      scale: scale
                                     offset: offset] autorelease];
}

+ (instancetype) constraintWithAttribute: (CAConstraintAttribute) attribute
                              relativeTo: (NSString *) sourceName
                               attribute: (CAConstraintAttribute) sourceAttribute
                                  offset: (CGFloat) offset
{
    return [self constraintWithAttribute: attribute
                              relativeTo: sourceName
                               attribute: sourceAttribute
                                   scale: 1.0
                                  offset: offset];
}

+ (instancetype) constraintWithAttribute: (CAConstraintAttribute) attribute
                              relativeTo: (NSString *) sourceName
                               attribute: (CAConstraintAttribute) sourceAttribute
{
    return [self constraintWithAttribute: attribute
                              relativeTo: sourceName
                               attribute: sourceAttribute
                                   scale: 1.0
                                  offset: 0.0];
}

- (instancetype) initWithAttribute: (CAConstraintAttribute) attribute
                        relativeTo: (NSString *) sourceName
                         attribute: (CAConstraintAttribute) sourceAttribute
                             scale: (CGFloat) scale
                            offset: (CGFloat) offset
{
    self = [super init];
    if (self != nil) {
        _attribute = attribute;
        _sourceName = [sourceName copy];
        _sourceAttribute = sourceAttribute;
        _scale = scale;
        _offset = offset;
    }
    return self;
}

- (instancetype) initWithCoder: (NSCoder *) coder {
    return [self initWithAttribute: [coder decodeIntForKey: @"CAConstraintAttribute"]
                        relativeTo: [coder decodeObjectForKey: @"CAConstraintSourceName"]
                         attribute: [coder decodeIntForKey: @"CAConstraintSourceAttribute"]
                             scale: [coder decodeDoubleForKey: @"CAConstraintScale"]
                            offset: [coder decodeDoubleForKey: @"CAConstraintOffset"]];
}

- (void) encodeWithCoder: (NSCoder *) coder {
    [coder encodeInt: _attribute forKey: @"CAConstraintAttribute"];
    [coder encodeObject: _sourceName forKey: @"CAConstraintSourceName"];
    [coder encodeInt: _sourceAttribute forKey: @"CAConstraintSourceAttribute"];
    [coder encodeDouble: _scale forKey: @"CAConstraintScale"];
    [coder encodeDouble: _offset forKey: @"CAConstraintOffset"];
}

- (void) dealloc {
    [_sourceName release];
    [super dealloc];
}

- (CAConstraintAttribute) attribute {
    return _attribute;
}

- (NSString *) sourceName {
    return _sourceName;
}

- (CAConstraintAttribute) sourceAttribute {
    return _sourceAttribute;
}

- (CGFloat) scale {
    return _scale;
}

- (CGFloat) offset {
    return _offset;
}

@end

@implementation CALayer (CAConstraintLayoutManager)

// Stored by CALayer's dynamic properties.
@dynamic constraints;

- (void) addConstraint: (CAConstraint *) constraint {
    if (constraint == nil)
        return;
    NSArray *constraints = [self constraints];
    [self setConstraints: constraints != nil
                                  ? [constraints arrayByAddingObject: constraint]
                                  : [NSArray arrayWithObject: constraint]];
}

@end

static CGFloat CAConstraintValueOfAttribute(CGRect frame,
                                            CAConstraintAttribute attribute)
{
    switch (attribute) {
    case kCAConstraintMinX:
        return CGRectGetMinX(frame);
    case kCAConstraintMidX:
        return CGRectGetMidX(frame);
    case kCAConstraintMaxX:
        return CGRectGetMaxX(frame);
    case kCAConstraintWidth:
        return frame.size.width;
    case kCAConstraintMinY:
        return CGRectGetMinY(frame);
    case kCAConstraintMidY:
        return CGRectGetMidY(frame);
    case kCAConstraintMaxY:
        return CGRectGetMaxY(frame);
    case kCAConstraintHeight:
        return frame.size.height;
    }
    return 0;
}

// Solves one axis from the constrained values: position[0..2] are
// min/mid/max, size is width or height; has* say which are constrained.
static void CAConstraintSolveAxis(CGFloat *origin, CGFloat *length,
                                  const BOOL has[4], const CGFloat value[4])
{
    CGFloat size = has[3] ? value[3] : *length;

    if (has[0] && has[2])
        size = value[2] - value[0];
    else if (has[0] && has[1])
        size = 2 * (value[1] - value[0]);
    else if (has[1] && has[2])
        size = 2 * (value[2] - value[1]);
    if (size < 0)
        size = 0;

    if (has[0])
        *origin = value[0];
    else if (has[1])
        *origin = value[1] - size / 2;
    else if (has[2])
        *origin = value[2] - size;
    *length = size;
}

@implementation CAConstraintLayoutManager

+ (instancetype) layoutManager {
    return [[[self alloc] init] autorelease];
}

// Frames are in the superlayer's coordinates; "superlayer" means its bounds.
static CGRect CAConstraintFrameForLayer(CALayer *layer, CALayer *superlayer,
                                        NSMutableDictionary *solved,
                                        NSMutableSet *solving)
{
    NSValue *key = [NSValue valueWithNonretainedObject: layer];
    NSValue *known = [solved objectForKey: key];
    if (known != nil) {
        CGRect frame;
        [known getValue: &frame];
        return frame;
    }

    CGRect frame = [layer frame];
    NSArray *constraints = [layer constraints];
    if ([constraints count] == 0 || [solving containsObject: key])
        return frame;
    [solving addObject: key];

    BOOL hasX[4] = { NO, NO, NO, NO }, hasY[4] = { NO, NO, NO, NO };
    CGFloat valueX[4] = { 0, 0, 0, 0 }, valueY[4] = { 0, 0, 0, 0 };

    for (CAConstraint *constraint in constraints) {
        NSString *sourceName = [constraint sourceName];
        CGRect sourceFrame;
        if (sourceName == nil || [sourceName isEqualToString: @"superlayer"])
            sourceFrame = [superlayer bounds];
        else {
            CALayer *source = nil;
            for (CALayer *sibling in [superlayer sublayers])
                if (sibling != layer && [[sibling name] isEqualToString: sourceName]) {
                    source = sibling;
                    break;
                }
            if (source == nil)
                continue;
            sourceFrame = CAConstraintFrameForLayer(source, superlayer, solved,
                                                    solving);
        }

        CGFloat value = CAConstraintValueOfAttribute(
                                sourceFrame, [constraint sourceAttribute]) *
                                [constraint scale] +
                        [constraint offset];
        CAConstraintAttribute attribute = [constraint attribute];
        if (attribute <= kCAConstraintWidth) {
            hasX[attribute] = YES;
            valueX[attribute] = value;
        } else if (attribute <= kCAConstraintHeight) {
            hasY[attribute - kCAConstraintMinY] = YES;
            valueY[attribute - kCAConstraintMinY] = value;
        }
    }

    CAConstraintSolveAxis(&frame.origin.x, &frame.size.width, hasX, valueX);
    CAConstraintSolveAxis(&frame.origin.y, &frame.size.height, hasY, valueY);

    [solving removeObject: key];
    [solved setObject: [NSValue valueWithBytes: &frame objCType: @encode(CGRect)]
               forKey: key];
    return frame;
}

- (void) layoutSublayersOfLayer: (CALayer *) layer {
    NSMutableDictionary *solved = [NSMutableDictionary dictionary];
    NSMutableSet *solving = [NSMutableSet set];

    for (CALayer *sublayer in [layer sublayers]) {
        if ([[sublayer constraints] count] == 0)
            continue;
        [sublayer setFrame: CAConstraintFrameForLayer(sublayer, layer, solved,
                                                      solving)];
    }
}

- (CGSize) preferredSizeOfLayer: (CALayer *) layer {
    return [layer bounds].size;
}

- (void) invalidateLayoutOfLayer: (CALayer *) layer {
}

@end
