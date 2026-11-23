#import <AppKit/NSMediaLibraryBrowserController.h>

@implementation NSMediaLibraryBrowserController

+ (NSMediaLibraryBrowserController *)sharedMediaLibraryBrowserController
{
    static NSMediaLibraryBrowserController *shared = nil;
    @synchronized(self) {
        if (shared == nil) {
            shared = [[self alloc] init];
        }
    }
    return shared;
}

- (instancetype)init
{
    if ((self = [super init]) != nil) {
        _frame = NSMakeRect(0, 0, 400, 300);
        _mediaLibraries = NSMediaLibraryImage;
    }
    return self;
}

// No remote media browser exists: the panel state is kept so setters round-trip.
- (BOOL)isVisible
{
    return _visible;
}

- (void)setVisible:(BOOL)visible
{
    _visible = visible;
}

- (NSRect)frame
{
    return _frame;
}

- (void)setFrame:(NSRect)frame
{
    _frame = frame;
}

- (NSMediaLibrary)mediaLibraries
{
    return _mediaLibraries;
}

- (void)setMediaLibraries:(NSMediaLibrary)mediaLibraries
{
    _mediaLibraries = mediaLibraries;
}

- (IBAction)togglePanel:(id)sender
{
    [self setVisible:![self isVisible]];
}

@end
