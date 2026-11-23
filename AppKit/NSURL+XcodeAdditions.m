#import <AppKit/NSURL+XcodeAdditions.h>
#import <AppKit/NSPasteboard.h>
#import <Foundation/NSFileManager.h>
#import <CoreFoundation/CoreFoundation.h>
#import <objc/runtime.h>

static const char NSURLXcodePropertiesKey;
static const char NSURLXcodeTemporaryValuesKey;

@interface NSURL (XcodeAdditionsInternal)
- (CFURLRef) _cfurl;
@end

@implementation NSURL (XcodeAdditions)

+ (instancetype) fileURLWithPath: (NSString *) path
                     isDirectory: (BOOL) isDir
                   relativeToURL: (NSURL *) baseURL {
    return [[[self alloc] initFileURLWithPath: path
                                  isDirectory: isDir
                                relativeToURL: baseURL] autorelease];
}

+ (instancetype) URLByResolvingAliasFileAtURL: (NSURL *) url
                                      options: (NSURLBookmarkResolutionOptions) options
                                        error: (NSError **) error {
    id isAlias = nil;
    if (![url getResourceValue: &isAlias forKey: NSURLIsAliasFileKey error: error])
        return nil;
    if (![isAlias boolValue])
        return url;

    NSData *bookmark = [NSURL bookmarkDataWithContentsOfURL: url error: NULL];
    if (bookmark != nil) {
        NSURL *resolved = [NSURL URLByResolvingBookmarkData: bookmark
                                                    options: options
                                              relativeToURL: nil
                                        bookmarkDataIsStale: NULL
                                                      error: error];
        if (resolved != nil)
            return resolved;
    }

    // Symbolic links are reported as alias files too.
    NSURL *target = [url URLByResolvingSymlinksInPath];
    if (target != nil && ![target isEqual: url] &&
        [target checkResourceIsReachableAndReturnError: error])
        return target;
    return nil;
}

- (instancetype) initFileURLWithPath: (NSString *) path
                         isDirectory: (BOOL) isDir
                       relativeToURL: (NSURL *) baseURL {
    if (path == nil) {
        [self release];
        [NSException raise: NSInvalidArgumentException
                    format: @"path cannot be nil"];
        return nil;
    }

    CFURLRef created = CFURLCreateWithFileSystemPathRelativeToBase(
            kCFAllocatorDefault, (CFStringRef) path, kCFURLPOSIXPathStyle,
            isDir, [baseURL _cfurl]);

    if ([self class] == [NSURL class]) {
        [self release];
        return (NSURL *) created;
    }

    self = [super init];
    if (self != nil)
        _reserved = (void *) created;
    else if (created != NULL)
        CFRelease(created);
    return self;
}

- (instancetype) initFileURLWithPath: (NSString *) path
                       relativeToURL: (NSURL *) baseURL {
    if (path == nil) {
        [self release];
        [NSException raise: NSInvalidArgumentException
                    format: @"path cannot be nil"];
        return nil;
    }

    NSString *fullPath = path;
    if (![path isAbsolutePath] && baseURL != nil) {
        NSString *basePath = [baseURL path];
        if (basePath != nil)
            fullPath = [basePath stringByAppendingPathComponent: path];
    }
    BOOL isDir = NO;
    [[NSFileManager defaultManager] fileExistsAtPath: fullPath
                                         isDirectory: &isDir];
    return [self initFileURLWithPath: path
                         isDirectory: isDir
                       relativeToURL: baseURL];
}

- (instancetype) initWithDataRepresentation: (NSData *) data
                              relativeToURL: (NSURL *) baseURL {
    CFURLRef created = NULL;
    if (data != nil)
        created = CFURLCreateWithBytes(kCFAllocatorDefault, [data bytes],
                                       [data length], kCFStringEncodingUTF8,
                                       [baseURL _cfurl]);
    if ([self class] == [NSURL class]) {
        [self release];
        return (NSURL *) created;
    }

    self = [super init];
    if (self != nil)
        _reserved = (void *) created;
    else if (created != NULL)
        CFRelease(created);
    return self;
}

- (instancetype) initAbsoluteURLWithDataRepresentation: (NSData *) data
                                         relativeToURL: (NSURL *) baseURL {
    CFURLRef created = NULL;
    if (data != nil)
        created = CFURLCreateAbsoluteURLWithBytes(
                kCFAllocatorDefault, [data bytes], [data length],
                kCFStringEncodingUTF8, [baseURL _cfurl], true);
    if ([self class] == [NSURL class]) {
        [self release];
        return (NSURL *) created;
    }

    self = [super init];
    if (self != nil)
        _reserved = (void *) created;
    else if (created != NULL)
        CFRelease(created);
    return self;
}

- (NSData *) dataRepresentation {
    return [(NSData *) CFURLCreateData(kCFAllocatorDefault, [self _cfurl],
                                       kCFStringEncodingUTF8, false) autorelease];
}

- (BOOL) hasDirectoryPath {
    return CFURLHasDirectoryPath([self _cfurl]) ? YES : NO;
}

- (BOOL) checkPromisedItemIsReachableAndReturnError: (NSError **) error {
    return [self checkResourceIsReachableAndReturnError: error];
}

- (NSDictionary *) promisedItemResourceValuesForKeys: (NSArray *) keys
                                               error: (NSError **) error {
    return [self resourceValuesForKeys: keys error: error];
}

- (id) propertyForKey: (NSString *) propertyKey {
    NSDictionary *properties =
            objc_getAssociatedObject(self, &NSURLXcodePropertiesKey);
    return [[[properties objectForKey: propertyKey] retain] autorelease];
}

- (BOOL) setProperty: (id) property forKey: (NSString *) propertyKey {
    if (propertyKey == nil)
        return NO;

    @synchronized(self) {
        NSMutableDictionary *properties =
                objc_getAssociatedObject(self, &NSURLXcodePropertiesKey);
        if (properties == nil) {
            properties = [NSMutableDictionary dictionary];
            objc_setAssociatedObject(self, &NSURLXcodePropertiesKey, properties,
                                     OBJC_ASSOCIATION_RETAIN);
        }
        if (property == nil)
            [properties removeObjectForKey: propertyKey];
        else
            [properties setObject: property forKey: propertyKey];
    }
    return YES;
}

// Darling's CoreFoundation has no resource-property cache or security-scoped resource
// support, so temporary values live in a per-URL dictionary and file access is never sandboxed.
- (void) removeCachedResourceValueForKey: (NSString *) key {
    if (key == nil)
        return;
    @synchronized(self) {
        NSMutableDictionary *values =
                objc_getAssociatedObject(self, &NSURLXcodeTemporaryValuesKey);
        [values removeObjectForKey: key];
    }
}

- (void) removeAllCachedResourceValues {
    @synchronized(self) {
        NSMutableDictionary *values =
                objc_getAssociatedObject(self, &NSURLXcodeTemporaryValuesKey);
        [values removeAllObjects];
    }
}

- (void) setTemporaryResourceValue: (id) value forKey: (NSString *) key {
    if (key == nil)
        return;
    if (value == nil) {
        [self removeCachedResourceValueForKey: key];
        return;
    }
    @synchronized(self) {
        NSMutableDictionary *values =
                objc_getAssociatedObject(self, &NSURLXcodeTemporaryValuesKey);
        if (values == nil) {
            values = [NSMutableDictionary dictionary];
            objc_setAssociatedObject(self, &NSURLXcodeTemporaryValuesKey, values,
                                     OBJC_ASSOCIATION_RETAIN);
        }
        [values setObject: value forKey: key];
    }
}

- (BOOL) startAccessingSecurityScopedResource {
    return YES;
}

- (void) stopAccessingSecurityScopedResource {
}

- (BOOL) writeToPasteboard: (NSPasteboard *) pasteboard {
    NSString *string = [self absoluteString];
    if (string == nil)
        return NO;

    if ([self isFileURL]) {
        [pasteboard addTypes: [NSArray arrayWithObjects:
                                               NSPasteboardTypeFileURL,
                                               NSPasteboardTypeURL, nil]
                       owner: nil];
        [pasteboard setString: string forType: NSPasteboardTypeFileURL];
    } else {
        [pasteboard addTypes: [NSArray arrayWithObject: NSPasteboardTypeURL]
                       owner: nil];
    }
    return [pasteboard setString: string forType: NSPasteboardTypeURL];
}

@end
