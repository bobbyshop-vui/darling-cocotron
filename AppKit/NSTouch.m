#import <AppKit/NSTouch.h>
#import <AppKit/NSView.h>

@implementation NSTouch

@synthesize identity = _identity;
@synthesize phase = _phase;
@synthesize normalizedPosition = _normalizedPosition;
@synthesize resting = _resting;
@synthesize device = _device;
@synthesize deviceSize = _deviceSize;
@synthesize type = _type;

- (instancetype)init {
    return [self initWithIdentity:nil
                            phase:NSTouchPhaseBegan
               normalizedPosition:NSZeroPoint
                          resting:NO
                           device:nil
                       deviceSize:NSZeroSize
                             type:NSTouchTypeIndirect
                   locationInView:NSZeroPoint
           previousLocationInView:NSZeroPoint
                             view:nil];
}

- (instancetype)initWithIdentity:(id)identity
                           phase:(NSTouchPhase)phase
              normalizedPosition:(NSPoint)normalizedPosition
                         resting:(BOOL)resting
                          device:(id)device
                      deviceSize:(NSSize)deviceSize
                            type:(NSTouchType)type
                  locationInView:(NSPoint)locationInWindow
          previousLocationInView:(NSPoint)previousLocationInWindow
                            view:(NSView *)view {
    if ((self = [super init])) {
        /* Every touch needs a usable identity: it is used as a dictionary key. */
        _identity = identity != nil ? [identity retain] : [[NSObject alloc] init];
        _phase = phase;
        _normalizedPosition = normalizedPosition;
        _resting = resting;
        _device = [device retain];
        _deviceSize = deviceSize;
        _type = type;
        _locationInWindow = locationInWindow;
        _previousLocationInWindow = previousLocationInWindow;
        _view = [view retain];
    }
    return self;
}

- (void)dealloc {
    [_identity release];
    [_device release];
    [_view release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[NSTouch allocWithZone:zone] initWithIdentity:_identity
                                                    phase:_phase
                                       normalizedPosition:_normalizedPosition
                                                  resting:_resting
                                                   device:_device
                                               deviceSize:_deviceSize
                                                     type:_type
                                           locationInView:_locationInWindow
                                   previousLocationInView:_previousLocationInWindow
                                                     view:_view];
}

- (NSPoint)_convertWindowPoint:(NSPoint)point toView:(NSView *)view {
    if (_type != NSTouchTypeDirect)
        return NSZeroPoint; /* only valid for direct touches */
    if (view == nil)
        return point;
    return [view convertPoint:point fromView:nil];
}

- (NSPoint)locationInView:(NSView *)view {
    return [self _convertWindowPoint:_locationInWindow toView:view];
}

- (NSPoint)previousLocationInView:(NSView *)view {
    return [self _convertWindowPoint:_previousLocationInWindow toView:view];
}

@end
