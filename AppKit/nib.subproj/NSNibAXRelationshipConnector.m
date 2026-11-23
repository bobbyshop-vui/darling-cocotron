#import "NSNibAXRelationshipConnector.h"

@implementation NSNibAXRelationshipConnector

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [NSMethodSignature signatureWithObjCTypes: "v@:"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"Stub called: %@ in %@", NSStringFromSelector([anInvocation selector]), [self class]);
}

@end

@implementation NSNibAXAttributeConnector

static NSString *const NSNibAXDestinationKey = @"AXDestinationArchiveKey";
static NSString *const NSNibAXAttributeTypeKey = @"AXAttributeTypeArchiveKey";
static NSString *const NSNibAXAttributeValueKey = @"AXAttributeValueArchiveKey";

- (id) initWithCoder: (NSCoder *) coder {
    self = [super init];
    if (self == nil)
        return nil;

    if ([coder allowsKeyedCoding]) {
        _destination = [[coder decodeObjectForKey: NSNibAXDestinationKey] retain];
        _attributeType = [[coder decodeObjectForKey: NSNibAXAttributeTypeKey] copy];
        _attributeValue = [[coder decodeObjectForKey: NSNibAXAttributeValueKey] retain];
    } else {
        _destination = [[coder decodeObject] retain];
        _attributeType = [[coder decodeObject] copy];
        _attributeValue = [[coder decodeObject] retain];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder {
    if ([coder allowsKeyedCoding]) {
        [coder encodeObject: _destination forKey: NSNibAXDestinationKey];
        [coder encodeObject: _attributeType forKey: NSNibAXAttributeTypeKey];
        [coder encodeObject: _attributeValue forKey: NSNibAXAttributeValueKey];
    } else {
        [coder encodeObject: _destination];
        [coder encodeObject: _attributeType];
        [coder encodeObject: _attributeValue];
    }
}

- (void) dealloc {
    [_destination release];
    [_attributeType release];
    [_attributeValue release];
    [super dealloc];
}

- destination {
    return _destination;
}

- (void) setDestination: destination {
    destination = [destination retain];
    [_destination release];
    _destination = destination;
}

- (NSString *) attributeType {
    return _attributeType;
}

- (void) setAttributeType: (NSString *) type {
    type = [type copy];
    [_attributeType release];
    _attributeType = type;
}

- attributeValue {
    return _attributeValue;
}

- (void) setAttributeValue: value {
    value = [value retain];
    [_attributeValue release];
    _attributeValue = value;
}

/* NSIBObjectData sends this to every connection when it swaps File's Owner. */
- (void) replaceObject: original withObject: replacement {
    if (_destination == original)
        [self setDestination: replacement];
    if (_attributeValue == original)
        [self setAttributeValue: replacement];
}

- (void) establishConnection {
    SEL setter = @selector(accessibilitySetOverrideValue:forAttribute:);

    if (_destination == nil || _attributeType == nil)
        return;

    /*
     * There is no accessibility server to publish to, so an object that
     * cannot take an override simply keeps its default attributes.
     */
    if ([_destination respondsToSelector: setter])
        [_destination performSelector: setter
                           withObject: _attributeValue
                           withObject: _attributeType];
}

@end
