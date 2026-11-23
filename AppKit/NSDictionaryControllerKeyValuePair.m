#import <AppKit/NSDictionaryControllerKeyValuePair.h>
#import <Foundation/Foundation.h>

@implementation NSDictionaryControllerKeyValuePair

- (void)dealloc
{
    [_key release];
    [_value release];
    [_localizedKey release];
    [super dealloc];
}

- (NSString *)key
{
    return _key;
}

- (void)setKey:(NSString *)key
{
    if (_key != key) {
        [self willChangeValueForKey:@"key"];
        [_key release];
        _key = [key copy];
        [self didChangeValueForKey:@"key"];
    }
}

- (id)value
{
    return _value;
}

- (void)setValue:(id)value
{
    if (_value != value) {
        [self willChangeValueForKey:@"value"];
        [_value release];
        _value = [value retain];
        [self didChangeValueForKey:@"value"];
    }
}

// Falls back to the key when no localized key dictionary entry was supplied.
- (NSString *)localizedKey
{
    return _localizedKey != nil ? _localizedKey : _key;
}

- (void)setLocalizedKey:(NSString *)localizedKey
{
    if (_localizedKey != localizedKey) {
        [self willChangeValueForKey:@"localizedKey"];
        [_localizedKey release];
        _localizedKey = [localizedKey copy];
        [self didChangeValueForKey:@"localizedKey"];
    }
}

- (BOOL)isExplicitlyIncluded
{
    return _explicitlyIncluded;
}

- (void)setExplicitlyIncluded:(BOOL)flag
{
    _explicitlyIncluded = flag;
}

@end
