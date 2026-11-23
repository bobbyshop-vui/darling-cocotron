#import <AppKit/NSInputManager.h>
#import <AppKit/NSImage.h>
#import <Foundation/NSString.h>

@implementation NSInputManager

- (void) dealloc {
    [_server release];
    [_language release];
    [_image release];
    [super dealloc];
}

- (NSString *) language {
    return _language;
}

- (NSImage *) image {
    return _image;
}

- (id) server {
    return _server;
}

@end
