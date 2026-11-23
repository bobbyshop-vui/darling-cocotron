#import <AppKit/NSMovie.h>
#import <AppKit/NSPasteboard.h>

@implementation NSMovie

+ (NSArray *) movieUnfilteredPasteboardTypes {
    return [NSArray arrayWithObjects: NSFilenamesPboardType, NSURLPboardType,
                                      nil];
}

static NSURL *URLFromPasteboard(NSPasteboard *pasteboard) {
    NSArray *types = [pasteboard types];

    if ([types containsObject: NSFilenamesPboardType]) {
        NSArray *files =
                [pasteboard propertyListForType: NSFilenamesPboardType];

        if ([files isKindOfClass: [NSArray class]] && [files count] > 0)
            return [NSURL fileURLWithPath: [files objectAtIndex: 0]];
    }

    if ([types containsObject: NSURLPboardType]) {
        NSString *string = [pasteboard stringForType: NSURLPboardType];

        if ([string length] > 0)
            return [NSURL URLWithString: string];
    }

    return nil;
}

+ (BOOL) canInitWithPasteboard: (NSPasteboard *) pasteboard {
    return URLFromPasteboard(pasteboard) != nil;
}

- (id) initWithURL: (NSURL *) url byReference: (BOOL) byRef {
    _URL = [url copy];
    return self;
}

- (id) initWithPasteboard: (NSPasteboard *) pasteboard {
    NSURL *url = URLFromPasteboard(pasteboard);

    if (url == nil) {
        [self release];
        return nil;
    }

    return [self initWithURL: url byReference: YES];
}

- (NSURL *) URL {
    return _URL;
}

- (void) dealloc {
    [_URL release];
    [super dealloc];
}

@end
