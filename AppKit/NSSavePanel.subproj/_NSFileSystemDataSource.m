#import "_NSFileSystemDataSource.h"
#import <AppKit/NSAttributedString.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSOpenPanel.h>
#import <AppKit/NSOutlineView.h>
#import <AppKit/NSSavePanel.h>

static NSSet *_packageExtensions(void) {
    static NSSet *set = nil;
    if (set == nil)
        set = [[NSSet alloc] initWithObjects: @"app", @"bundle", @"framework",
                                              @"plugin", @"xpc", @"appex",
                                              @"kext", @"pkg", @"xcodeproj",
                                              @"xcworkspace", @"playground",
                                              @"xcarchive", @"dSYM", @"xctest",
                                              @"prefPane", @"saver",
                                              @"qlgenerator", @"mdimporter",
                                              @"rtfd", @"xcframework", nil];
    return set;
}

@implementation _NSFileSystemDataSource

- (id) init {
    self = [super init];
    _cachedPaths = [[NSMutableSet alloc] init];
    _childrenCache = [[NSMutableDictionary alloc] init];
    _fileManager = [[NSFileManager defaultManager] retain];
    return self;
}

- (void) dealloc {
    [_cachedPaths release];
    [_childrenCache release];
    [_fileManager release];
    [super dealloc];
}

- (void) setPanel: (NSSavePanel *) panel {
    _panel = panel;
}

- (void) reset {
    [_childrenCache removeAllObjects];
}

- (NSURL *) _canonicalURL: (NSURL *) url {
    NSURL *member = [_cachedPaths member: url];
    if (member == nil) {
        [_cachedPaths addObject: url];
        member = url;
    }
    return member;
}

- (NSURL *) itemForPath: (NSString *) path {
    return [self _canonicalURL: [NSURL fileURLWithPath: path]];
}

- (BOOL) isDirectoryItem: (NSURL *) url {
    BOOL isDirectory = NO;
    return [_fileManager fileExistsAtPath: [url path]
                              isDirectory: &isDirectory] &&
           isDirectory;
}

- (BOOL) _allowedTypesMatch: (NSURL *) url {
    NSArray *types = [_panel allowedFileTypes];
    if ([types count] == 0)
        return YES;

    NSString *extension = [[url path] pathExtension];
    for (NSString *type in types) {
        if (![type isKindOfClass: [NSString class]])
            continue;
        // Dotted identifiers are UTIs which cannot be resolved here, so they
        // do not restrict anything.
        if ([type rangeOfString: @"."].location != NSNotFound)
            return YES;
        if ([type caseInsensitiveCompare: extension] == NSOrderedSame ||
            [type isEqualToString: @"*"])
            return YES;
    }
    return NO;
}

- (BOOL) isPackageItem: (NSURL *) url {
    if (![self isDirectoryItem: url])
        return NO;
    NSString *extension = [[url path] pathExtension];
    if ([extension length] == 0)
        return NO;
    for (NSString *package in _packageExtensions())
        if ([package caseInsensitiveCompare: extension] == NSOrderedSame)
            return YES;
    for (NSString *type in [_panel allowedFileTypes])
        if ([type isKindOfClass: [NSString class]] &&
            [type caseInsensitiveCompare: extension] == NSOrderedSame)
            return YES;
    return NO;
}

- (BOOL) _isExpandable: (NSURL *) url {
    if (![self isDirectoryItem: url])
        return NO;
    if ([_panel treatsFilePackagesAsDirectories])
        return YES;
    return ![self isPackageItem: url];
}

- (BOOL) isEnabledItem: (NSURL *) url {
    if (![_panel isKindOfClass: [NSOpenPanel class]])
        return YES;

    NSOpenPanel *open = (NSOpenPanel *) _panel;
    BOOL enabled;

    if ([self isDirectoryItem: url]) {
        if ([self isPackageItem: url] &&
            ![_panel treatsFilePackagesAsDirectories])
            // A package is shown, and chosen, like a file.
            enabled = ([open canChooseFiles] || [open canChooseDirectories]) &&
                      [self _allowedTypesMatch: url];
        else
            enabled = [open canChooseDirectories] &&
                      ([[[url path] pathExtension] length] == 0 ||
                       [self _allowedTypesMatch: url]);
    } else {
        enabled = [open canChooseFiles] && [self _allowedTypesMatch: url];
    }

    id delegate = [_panel delegate];
    if (enabled && [delegate respondsToSelector: @selector(panel:
                                                      shouldEnableURL:)])
        enabled = [delegate panel: _panel shouldEnableURL: url];
    return enabled;
}

- (NSArray *) _childrenOfItem: (NSURL *) url {
    NSString *path = (url == nil) ? @"/" : [url path];
    NSArray *children = [_childrenCache objectForKey: path];
    if (children != nil)
        return children;

    NSArray *names = [_fileManager contentsOfDirectoryAtPath: path error: NULL];
    names = [names sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    BOOL showsHidden = [_panel showsHiddenFiles];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity: [names count]];

    for (NSString *name in names) {
        if (!showsHidden && [name hasPrefix: @"."])
            continue;
        NSString *child = [path stringByAppendingPathComponent: name];
        NSURL *childURL = [self _canonicalURL: [NSURL fileURLWithPath: child]];
        // Disabled items stay listed (greyed out); only items the delegate
        // refuses to show are dropped.
        id delegate = [_panel delegate];
        if ([delegate respondsToSelector: @selector(panel:shouldShowFilename:)] &&
            ![delegate panel: _panel shouldShowFilename: child])
            continue;
        [result addObject: childURL];
    }

    [_childrenCache setObject: result forKey: path];
    return result;
}

- (NSInteger) outlineView: (NSOutlineView *) outlineView
        numberOfChildrenOfItem: (NSURL *) url
{
    return [[self _childrenOfItem: url] count];
}

- (BOOL) outlineView: (NSOutlineView *) outlineView
        isItemExpandable: (NSURL *) url
{
    if (url == nil)
        return YES;
    return [self _isExpandable: url];
}

- (NSURL *) outlineView: (NSOutlineView *) outlineView
                  child: (NSInteger) index
                 ofItem: (NSURL *) url
{
    return [[self _childrenOfItem: url] objectAtIndex: index];
}

- (id) outlineView: (NSOutlineView *) outlineView
        objectValueForTableColumn: (NSTableColumn *) tableColumn
                           byItem: (NSURL *) url
{
    NSString *name = [[url path] lastPathComponent];
    if ([self isEnabledItem: url] || [self _isExpandable: url])
        return name;

    NSDictionary *attributes = [NSDictionary
            dictionaryWithObject: [NSColor disabledControlTextColor]
                          forKey: NSForegroundColorAttributeName];
    return [[[NSAttributedString alloc] initWithString: name
                                            attributes: attributes]
            autorelease];
}

@end
