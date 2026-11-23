#import <AppKit/NSAccessibilityCustomAction.h>

@implementation NSAccessibilityCustomAction

@synthesize name = _name;
@synthesize target = _target;
@synthesize selector = _selector;

- (instancetype)initWithName:(NSString *)name handler:(BOOL (^)(void))handler {
    if ((self = [super init])) {
        _name = [name copy];
        _handler = [handler copy];
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name target:(id<NSObject>)target selector:(SEL)selector {
    if ((self = [super init])) {
        _name = [name copy];
        _target = target; /* weak */
        _selector = selector;
    }
    return self;
}

- (instancetype)init {
    return [self initWithName:@"" handler:nil];
}

- (void)dealloc {
    [_name release];
    [_handler release];
    _target = nil;
    [super dealloc];
}

- (void)setName:(NSString *)name {
    if (name == _name)
        return;
    [_name release];
    _name = [name copy];
}

- (BOOL (^)(void))handler {
    return _handler;
}

- (void)setHandler:(BOOL (^)(void))handler {
    if (handler == _handler)
        return;
    [_handler release];
    _handler = [handler copy];
}

@end
