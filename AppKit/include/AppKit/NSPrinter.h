#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

@class NSDictionary;

@interface NSPrinter : NSObject {
    NSString *_name;
    NSString *_type;
}

- (NSString *) name;
- (NSString *) type;
- (NSDictionary *) deviceDescription;
- (NSString *) domain;
- (NSString *) host;
- (NSString *) note;
- (BOOL) isColor;

@end
