#import "NSNibAuxiliaryActionConnector.h"

@implementation NSNibAuxiliaryActionConnector

- initWithCoder: (NSCoder *) coder {
    if ((self = [super initWithCoder: coder])) {
        if ([coder allowsKeyedCoding] && [coder containsValueForKey: @"NSTrigger"])
            _trigger = [[coder decodeObjectForKey: @"NSTrigger"] retain];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder {
    [super encodeWithCoder: coder];
    if ([coder allowsKeyedCoding] && _trigger != nil)
        [coder encodeObject: _trigger forKey: @"NSTrigger"];
}

- (void) dealloc {
    [_trigger release];
    [super dealloc];
}

- trigger {
    return _trigger;
}

- (void) setTrigger: trigger {
    trigger = [trigger retain];
    [_trigger release];
    _trigger = trigger;
}

// There is no gesture or key-trigger machinery to wire the action into.
- (void) establishConnection {
}

@end
