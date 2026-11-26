#import <QuartzCore/CATransform3D.h>
#import <Foundation/NSValue.h>
#include <string.h>

const CATransform3D CATransform3DIdentity = {1, 0, 0, 0, 0, 1, 0, 0,
                                             0, 0, 1, 0, 0, 0, 0, 1};

@implementation NSValue (CATransform3DAdditions)

+ (NSValue *) valueWithCATransform3D: (CATransform3D) transform {
    return [NSValue valueWithBytes: &transform objCType: @encode(CATransform3D)];
}

- (CATransform3D) CATransform3DValue {
    CATransform3D transform = CATransform3DIdentity;
    if (strcmp([self objCType], @encode(CATransform3D)) == 0)
        [self getValue: &transform];
    return transform;
}

@end
