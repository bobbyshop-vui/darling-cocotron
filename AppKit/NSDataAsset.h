#import <Foundation/Foundation.h>

@interface NSDataAsset : NSObject <NSCopying> {
    NSString *_name;
    NSData *_data;
    NSString *_typeIdentifier;
}

- (instancetype) initWithName: (NSString *) name;
- (instancetype) initWithName: (NSString *) name bundle: (NSBundle *) bundle;

- (NSString *) name;
- (NSData *) data;
- (NSString *) typeIdentifier;

@end
