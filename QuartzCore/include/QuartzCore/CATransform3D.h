
#import <QuartzCore/CABase.h>
#import <CoreGraphics/CGAffineTransform.h>

typedef struct {
    CGFloat m11, m12, m13, m14;
    CGFloat m21, m22, m23, m24;
    CGFloat m31, m32, m33, m34;
    CGFloat m41, m42, m43, m44;
} CATransform3D;

CA_EXPORT const CATransform3D CATransform3DIdentity;

CA_EXPORT bool CATransform3DIsAffine(CATransform3D transform);
CA_EXPORT CATransform3D CATransform3DMakeAffineTransform(CGAffineTransform transform);
CA_EXPORT CGAffineTransform CATransform3DGetAffineTransform(CATransform3D transform);

#ifdef __OBJC__
#import <Foundation/NSValue.h>

@interface NSValue (CATransform3DAdditions)
+ (NSValue *) valueWithCATransform3D: (CATransform3D) transform;
- (CATransform3D) CATransform3DValue;
@end
#endif
