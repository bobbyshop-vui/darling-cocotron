#import <Foundation/NSObjCRuntime.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSGeometry.h>
#import <Foundation/NSDate.h>

@class NSView;

enum {
    NSTouchPhaseBegan = 1U << 0,
    NSTouchPhaseMoved = 1U << 1,
    NSTouchPhaseStationary = 1U << 2,
    NSTouchPhaseEnded = 1U << 3,
    NSTouchPhaseCancelled = 1U << 4,
    NSTouchPhaseTouching = NSTouchPhaseBegan | NSTouchPhaseMoved | NSTouchPhaseStationary,
    NSTouchPhaseAny = NSUIntegerMax
};
typedef NSUInteger NSTouchPhase;

enum {
    NSTouchTypeDirect,
    NSTouchTypeIndirect,
};
typedef NSInteger NSTouchType;

enum {
    NSTouchTypeMaskDirect = (1 << NSTouchTypeDirect),
    NSTouchTypeMaskIndirect = (1 << NSTouchTypeIndirect),
};
typedef NSUInteger NSTouchTypeMask;

static inline NSTouchTypeMask NSTouchTypeMaskFromType(NSTouchType type) {
    return (1 << type);
}

@interface NSTouch : NSObject <NSCopying> {
    id _identity;
    NSTouchPhase _phase;
    NSPoint _normalizedPosition;
    NSPoint _locationInWindow;
    NSPoint _previousLocationInWindow;
    BOOL _resting;
    NSTouchType _type;
    NSView *_view;
    id _device;
    NSSize _deviceSize;
}

@property(readonly, retain) id identity;
@property(readonly) NSTouchPhase phase;
@property(readonly) NSPoint normalizedPosition;
@property(readonly, getter=isResting) BOOL resting;
@property(readonly, retain) id device;
@property(readonly) NSSize deviceSize;
@property(readonly) NSTouchType type;

- (instancetype)initWithIdentity:(id)identity
                           phase:(NSTouchPhase)phase
              normalizedPosition:(NSPoint)normalizedPosition
                         resting:(BOOL)resting
                          device:(id)device
                      deviceSize:(NSSize)deviceSize
                            type:(NSTouchType)type
                  locationInView:(NSPoint)locationInWindow
          previousLocationInView:(NSPoint)previousLocationInWindow
                            view:(NSView *)view;

- (NSPoint)locationInView:(NSView *)view;
- (NSPoint)previousLocationInView:(NSView *)view;

@end
