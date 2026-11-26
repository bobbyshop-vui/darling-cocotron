#import <Foundation/Foundation.h>
#import <QuartzCore/CALayer.h>

typedef enum CAConstraintAttribute : int {
    kCAConstraintMinX,
    kCAConstraintMidX,
    kCAConstraintMaxX,
    kCAConstraintWidth,
    kCAConstraintMinY,
    kCAConstraintMidY,
    kCAConstraintMaxY,
    kCAConstraintHeight,
} CAConstraintAttribute;

// The value of attribute is sourceAttribute of the layer named sourceName
// (a sibling, or @"superlayer") times scale plus offset.
@interface CAConstraint : NSObject <NSSecureCoding> {
    CAConstraintAttribute _attribute;
    NSString *_sourceName;
    CAConstraintAttribute _sourceAttribute;
    CGFloat _scale;
    CGFloat _offset;
}

+ (instancetype) constraintWithAttribute: (CAConstraintAttribute) attribute
                              relativeTo: (NSString *) sourceName
                               attribute: (CAConstraintAttribute) sourceAttribute
                                   scale: (CGFloat) scale
                                  offset: (CGFloat) offset;
+ (instancetype) constraintWithAttribute: (CAConstraintAttribute) attribute
                              relativeTo: (NSString *) sourceName
                               attribute: (CAConstraintAttribute) sourceAttribute
                                  offset: (CGFloat) offset;
+ (instancetype) constraintWithAttribute: (CAConstraintAttribute) attribute
                              relativeTo: (NSString *) sourceName
                               attribute: (CAConstraintAttribute) sourceAttribute;
- (instancetype) initWithAttribute: (CAConstraintAttribute) attribute
                        relativeTo: (NSString *) sourceName
                         attribute: (CAConstraintAttribute) sourceAttribute
                             scale: (CGFloat) scale
                            offset: (CGFloat) offset;

@property(readonly) CAConstraintAttribute attribute;
@property(readonly) NSString *sourceName;
@property(readonly) CAConstraintAttribute sourceAttribute;
@property(readonly) CGFloat scale;
@property(readonly) CGFloat offset;

@end

@interface CALayer (CAConstraintLayoutManager)
@property(copy) NSArray *constraints;
- (void) addConstraint: (CAConstraint *) constraint;
@end

@interface CAConstraintLayoutManager : NSObject <CALayoutManager>
+ (instancetype) layoutManager;
@end
