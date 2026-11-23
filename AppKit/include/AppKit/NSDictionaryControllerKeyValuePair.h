#import <Foundation/NSObject.h>

@class NSString;

@interface NSDictionaryControllerKeyValuePair : NSObject {
    NSString *_key;
    id _value;
    NSString *_localizedKey;
    BOOL _explicitlyIncluded;
}

- (NSString *)key;
- (void)setKey:(NSString *)key;
- (id)value;
- (void)setValue:(id)value;
- (NSString *)localizedKey;
- (void)setLocalizedKey:(NSString *)localizedKey;
- (BOOL)isExplicitlyIncluded;
- (void)setExplicitlyIncluded:(BOOL)flag;

@end
