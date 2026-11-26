
#import <ApplicationServices/ApplicationServices.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/CAAction.h>
#import <QuartzCore/CAMediaTiming.h>
#import <QuartzCore/CATransform3D.h>

@class CAAnimation, CALayerContext, CALayer;

typedef NS_OPTIONS(NSUInteger, CACornerMask) {
    kCALayerMinXMinYCorner = 1U << 0,
    kCALayerMaxXMinYCorner = 1U << 1,
    kCALayerMinXMaxYCorner = 1U << 2,
    kCALayerMaxXMaxYCorner = 1U << 3,
};

enum {
    kCALayerLeftEdge = 1U << 0,
    kCALayerRightEdge = 1U << 1,
    kCALayerBottomEdge = 1U << 2,
    kCALayerTopEdge = 1U << 3,
};

enum {
    kCALayerNotSizable = 0x00,
    kCALayerMinXMargin = 0x01,
    kCALayerWidthSizable = 0x02,
    kCALayerMaxXMargin = 0x04,
    kCALayerMinYMargin = 0x08,
    kCALayerHeightSizable = 0x10,
    kCALayerMaxYMargin = 0x20,
};

CA_EXPORT NSString *const kCAFilterLinear;
CA_EXPORT NSString *const kCAFilterNearest;
CA_EXPORT NSString *const kCAFilterTrilinear;

CA_EXPORT NSString *const kCAGravityResizeAspect;
CA_EXPORT NSString *const kCAGravityResizeAspectFill;

CA_EXPORT NSString *const kCAGravityCenter;
CA_EXPORT NSString *const kCAGravityTop;
CA_EXPORT NSString *const kCAGravityBottom;
CA_EXPORT NSString *const kCAGravityLeft;
CA_EXPORT NSString *const kCAGravityRight;
CA_EXPORT NSString *const kCAGravityTopLeft;
CA_EXPORT NSString *const kCAGravityTopRight;
CA_EXPORT NSString *const kCAGravityBottomLeft;
CA_EXPORT NSString *const kCAGravityBottomRight;
CA_EXPORT NSString *const kCAGravityResize;

CA_EXPORT NSString *const kCAOnOrderIn;
CA_EXPORT NSString *const kCAOnOrderOut;
CA_EXPORT NSString *const kCATransition;

CA_EXPORT NSString *const kCAContentsFormatRGBA8Uint;
CA_EXPORT NSString *const kCAContentsFormatRGBA16Float;
CA_EXPORT NSString *const kCAContentsFormatGray8Uint;

@protocol CALayerDelegate <NSObject>

@optional

- (void)displayLayer: (CALayer*)layer;

- (void)drawLayer: (CALayer*)layer
        inContext: (CGContextRef)ctx;

- (void)layerWillDraw: (CALayer*)layer;

- (void)layoutSublayersOfLayer: (CALayer*)layer;

- (id<CAAction>)actionForLayer: (CALayer*)layer
                        forKey: (NSString*)event;

@end

@interface CALayer : NSObject <CAMediaTiming> {
    CALayerContext *_context;
    CALayer *_superlayer;
    NSArray *_sublayers;
    id _delegate;
    CGPoint _anchorPoint;
    CGPoint _position;
    CGRect _bounds;
    CGFloat _opacity;
    BOOL _opaque;
    id _contents;
    CATransform3D _transform;
    CATransform3D _sublayerTransform;
    NSString *_minificationFilter;
    NSString *_magnificationFilter;
    BOOL _needsDisplay;
    NSMutableDictionary *_animations;
    NSNumber *_textureId;
    // Values of the properties CALayer provides dynamically (see
    // +resolveInstanceMethod:) and of other KVC keys set on the layer.
    NSMutableDictionary *_attributes;
}

+ layer;

@property(readonly) CALayer *superlayer;
@property(copy) NSArray *sublayers;
@property(assign) id<CALayerDelegate> delegate;
@property CGPoint anchorPoint;
@property CGPoint position;
@property CGRect bounds;
@property CGRect frame;
@property CGFloat opacity;
@property BOOL opaque;
@property(retain) id contents;
//@property CATransform3D transform;
@property CATransform3D sublayerTransform;

@property(copy) NSString *minificationFilter;
@property(copy) NSString *magnificationFilter;

// Provided through +resolveInstanceMethod: and stored per layer, like Core
// Animation's own dynamic properties.
@property CGFloat zPosition;
@property CGFloat anchorPointZ;
@property(getter=isHidden) BOOL hidden;
@property(getter=isDoubleSided) BOOL doubleSided;
@property(getter=isGeometryFlipped) BOOL geometryFlipped;
@property(retain) CALayer *mask;
@property BOOL masksToBounds;
@property CGRect contentsRect;
@property(copy) NSString *contentsGravity;
@property CGFloat contentsScale;
@property CGRect contentsCenter;
@property(copy) NSString *contentsFormat;
@property float minificationFilterBias;
@property BOOL needsDisplayOnBoundsChange;
@property BOOL drawsAsynchronously;
@property unsigned int edgeAntialiasingMask;
@property BOOL allowsEdgeAntialiasing;
@property CGColorRef backgroundColor;
@property CGFloat cornerRadius;
@property CACornerMask maskedCorners;
@property CGFloat borderWidth;
@property CGColorRef borderColor;
@property BOOL allowsGroupOpacity;
@property(retain) id compositingFilter;
@property(copy) NSArray *filters;
@property(copy) NSArray *backgroundFilters;
@property BOOL shouldRasterize;
@property CGFloat rasterizationScale;
@property CGColorRef shadowColor;
@property float shadowOpacity;
@property CGSize shadowOffset;
@property CGFloat shadowRadius;
@property CGPathRef shadowPath;
@property unsigned int autoresizingMask;
@property(retain) id layoutManager;
@property(copy) NSDictionary *actions;
@property(copy) NSString *name;
@property(copy) NSDictionary *style;
@property(readonly) CGRect visibleRect;
// CAMediaTiming
@property BOOL autoreverses;
@property CFTimeInterval beginTime;
@property CFTimeInterval duration;
@property(copy) NSString *fillMode;
@property float repeatCount;
@property CFTimeInterval repeatDuration;
@property float speed;
@property CFTimeInterval timeOffset;

+ (id) defaultValueForKey: (NSString *) key;
+ (BOOL) needsDisplayForKey: (NSString *) key;
+ (id<CAAction>) defaultActionForKey: (NSString *) event;
- (instancetype) initWithLayer: (id) layer;
- (id) presentationLayer;
- (id) modelLayer;
- (BOOL) shouldArchiveValueForKey: (NSString *) key;
- (CGAffineTransform) affineTransform;
- (void) setAffineTransform: (CGAffineTransform) transform;
- (BOOL) contentsAreFlipped;
- (void) insertSublayer: (CALayer *) layer atIndex: (unsigned) index;
- (void) insertSublayer: (CALayer *) layer below: (CALayer *) sibling;
- (void) insertSublayer: (CALayer *) layer above: (CALayer *) sibling;
- (CGPoint) convertPoint: (CGPoint) point fromLayer: (CALayer *) layer;
- (CGPoint) convertPoint: (CGPoint) point toLayer: (CALayer *) layer;
- (CGRect) convertRect: (CGRect) rect fromLayer: (CALayer *) layer;
- (CGRect) convertRect: (CGRect) rect toLayer: (CALayer *) layer;
- (CFTimeInterval) convertTime: (CFTimeInterval) time fromLayer: (CALayer *) layer;
- (CFTimeInterval) convertTime: (CFTimeInterval) time toLayer: (CALayer *) layer;
- (CALayer *) hitTest: (CGPoint) point;
- (BOOL) containsPoint: (CGPoint) point;
- (void) renderInContext: (CGContextRef) context;
- (CGSize) preferredFrameSize;
- (void) setNeedsLayout;
- (BOOL) needsLayout;
- (void) layoutIfNeeded;
- (void) layoutSublayers;
- (void) resizeSublayersWithOldSize: (CGSize) size;
- (void) resizeWithOldSuperlayerSize: (CGSize) size;
- (void) scrollPoint: (CGPoint) point;
- (void) scrollRectToVisible: (CGRect) rect;

- init;

- (void) addSublayer: (CALayer *) layer;
- (void) replaceSublayer: (CALayer *) layer with: (CALayer *) other;
- (void) display;
- (void) displayIfNeeded;
- (void) drawInContext: (CGContextRef) context;
- (BOOL) needsDisplay;
- (void) removeFromSuperlayer;
- (void) setNeedsDisplay;
- (void) setNeedsDisplayInRect: (CGRect) rect;

- (void) addAnimation: (CAAnimation *) animation forKey: (NSString *) key;
- (CAAnimation *) animationForKey: (NSString *) key;
- (void) removeAllAnimations;
- (void) removeAnimationForKey: (NSString *) key;
- (NSArray *) animationKeys;

- (id<CAAction>) actionForKey: (NSString *) key;

@end

@protocol CALayoutManager <NSObject>
@optional

- (CGSize) preferredSizeOfLayer: (CALayer *) layer;
- (void) invalidateLayoutOfLayer: (CALayer *) layer;
- (void) layoutSublayersOfLayer: (CALayer *) layer;

@end
