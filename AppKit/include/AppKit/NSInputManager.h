#import <Foundation/NSObject.h>

@class NSImage, NSString;

@interface NSInputManager : NSObject {
    id _server;
    NSString *_language;
    NSImage *_image;
}

- (NSString *) language;
- (NSImage *) image;
- (id) server;

@end
