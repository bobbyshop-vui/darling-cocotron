#import <AppKit/NSPDFPanel.h>
#import <AppKit/NSViewController.h>
#import <Foundation/Foundation.h>

@implementation NSPDFPanel

+ (NSPDFPanel *)panel
{
    return [[[self alloc] init] autorelease];
}

- (instancetype)init
{
    if ((self = [super init]) != nil) {
        _defaultFileName = [@"Untitled" copy];
    }
    return self;
}

- (void)dealloc
{
    [_accessoryController release];
    [_defaultFileName release];
    [super dealloc];
}

- (NSViewController *)accessoryController
{
    return _accessoryController;
}

- (void)setAccessoryController:(NSViewController *)controller
{
    if (_accessoryController != controller) {
        [_accessoryController release];
        _accessoryController = [controller retain];
    }
}

- (NSPDFPanelOptions)options
{
    return _options;
}

- (void)setOptions:(NSPDFPanelOptions)options
{
    _options = options;
}

- (NSString *)defaultFileName
{
    return _defaultFileName;
}

- (void)setDefaultFileName:(NSString *)name
{
    if (_defaultFileName != name) {
        [_defaultFileName release];
        _defaultFileName = [name copy];
    }
}

// There is no PDF save panel UI, so the request is reported as cancelled (NSModalResponseCancel)
// and the NSPDFInfo is left unmodified.
- (void)beginSheetWithPDFInfo:(NSPDFInfo *)pdfInfo modalForWindow:(NSWindow *)docWindow completionHandler:(void (^)(NSInteger))completionHandler
{
    if (completionHandler != NULL) {
        completionHandler(0);
    }
}

@end
