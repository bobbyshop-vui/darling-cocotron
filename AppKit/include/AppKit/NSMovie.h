#import <Foundation/Foundation.h>

@class NSPasteboard;

@interface NSMovie : NSObject {
    NSURL *_URL;
}

+ (NSArray *) movieUnfilteredPasteboardTypes;
+ (BOOL) canInitWithPasteboard: (NSPasteboard *) pasteboard;

- (id) initWithURL: (NSURL *) url byReference: (BOOL) byRef;
- (id) initWithPasteboard: (NSPasteboard *) pasteboard;
- (NSURL *) URL;

@end
