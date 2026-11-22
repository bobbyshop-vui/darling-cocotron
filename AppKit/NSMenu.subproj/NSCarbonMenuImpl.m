#import <Foundation/NSObject.h>

// DUMMY

typedef struct OpaqueEventRef* NSCarbonEventRef;
typedef struct OpaqueEventHandlerCallRef* NSCarbonEventHandlerCallRef;

@interface NSCarbonMenuImpl : NSObject
@end

@implementation NSCarbonMenuImpl
- (int)_carbonTargetItemEvent: (NSCarbonEventRef) event
			handlerCallRef: (NSCarbonEventHandlerCallRef) handlerCallRef {
	(void) event;
	(void) handlerCallRef;
	return 0;
}

- (NSMethodSignature *) methodSignatureForSelector: (SEL) aSelector {
    return [NSMethodSignature signatureWithObjCTypes: "v@:"];
}

- (void) forwardInvocation: (NSInvocation *) anInvocation {
    NSLog(@"Stub called: %@ in %@",
          NSStringFromSelector([anInvocation selector]), [self class]);
}
@end
