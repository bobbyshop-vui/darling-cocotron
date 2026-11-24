#import "MacWorkspace.h"
#import <AppKit/NSApplication.h>
#import <AppKit/NSRunningApplication.h>
#import <AppKit/NSRaise.h>
#include <LaunchServices/LaunchServices.h>
#include <sys/mount.h>
#include <stdlib.h>

static NSArray *MacWorkspaceMountedVolumePaths(unsigned long requiredFlags) {
    int count = getfsstat(NULL, 0, MNT_NOWAIT);
    if (count <= 0)
        return [NSArray array];

    struct statfs *filesystems = calloc((size_t) count, sizeof(struct statfs));
    if (filesystems == NULL)
        return [NSArray array];

    int mountedCount = getfsstat(filesystems,
                                 count * (int) sizeof(struct statfs),
                                 MNT_NOWAIT);
    if (mountedCount < 0)
        mountedCount = 0;
    if (mountedCount > count)
        mountedCount = count;

    NSMutableArray *paths = [NSMutableArray arrayWithCapacity: mountedCount];
    for (int index = 0; index < mountedCount; index++) {
        if ((filesystems[index].f_flags & requiredFlags) != requiredFlags)
            continue;

        NSString *path = [NSString stringWithUTF8String:
                                  filesystems[index].f_mntonname];
        if (path != nil)
            [paths addObject: path];
    }

    free(filesystems);
    return paths;
}

@implementation NSWorkspace (macos)

+ allocWithZone: (NSZone *) zone {
    return NSAllocateObject([MacWorkspace class], 0, NULL);
}

@end

@implementation MacWorkspace

- (NSImage *) iconForFile: (NSString *) path {
    // TODO: call GetIconRefFromFileInfo().  Returning nil is handled by the
    // callers (they simply show no icon); logging on every call just floods
    // Xcode's console while it builds its UI.
    return nil;
}

- (NSImage *) iconForFiles: (NSArray *) array {
    return nil;
}

- (NSImage *) iconForFileType: (NSString *) type {
    // TODO: call GetIconRefFromTypeInfo()
    return nil;
}

- (NSString *) localizedDescriptionForType: (NSString *) type {
    // TODO: call UTTypeCopyDescription()
    if (type != nil) {
        CFStringRef description = UTTypeCopyDescription((CFStringRef) type);
        if (description != NULL)
            return [(NSString *) description autorelease];
    }
    return NULL;
}

- (BOOL) filenameExtension: (NSString *) extension
            isValidForType: (NSString *) type
{
    // TODO: call UTTypeCreateAllIdentifiersForTag
    if (extension == nil || type == nil)
        return NO;

    CFArrayRef identifiers = UTTypeCreateAllIdentifiersForTag(
            kUTTagClassFilenameExtension, (CFStringRef) [extension lowercaseString],
            NULL);
    if (identifiers == NULL)
        return NO;

    BOOL valid = NO;
    CFIndex count = CFArrayGetCount(identifiers);
    for (CFIndex index = 0; index < count; index++) {
        CFStringRef identifier = CFArrayGetValueAtIndex(identifiers, index);
        if ([self type: (NSString *) identifier conformsToType: type]) {
            valid = YES;
            break;
        }
    }
    CFRelease(identifiers);
    if (valid)
        return YES;
    return NO;
}

- (NSString *) preferredFilenameExtensionForType: (NSString *) type {
    // TODO: call UTTypeCopyPreferredTagWithClass(kUTTagClassFilenameExtension)
    if (type != nil) {
        CFStringRef extension = UTTypeCopyPreferredTagWithClass(
                (CFStringRef) type, kUTTagClassFilenameExtension);
        if (extension != NULL)
            return [(NSString *) extension autorelease];
    }
    return NULL;
}

- (BOOL) type: (NSString *) type conformsToType: (NSString *) conformsToType {
    if (type == nil || conformsToType == nil)
        return NO;

    return [type isEqualToString: conformsToType] ||
           UTTypeConformsTo((CFStringRef) type,
                            (CFStringRef) conformsToType);
}

- (NSString *) typeOfFile: (NSString *) path error: (NSError **) error {
    if (error != NULL)
        *error = nil;

    if (path == nil) {
        if (error != NULL)
            *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                         code: NSFileNoSuchFileError
                                     userInfo: nil];
        return nil;
    }

    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath: path
                                               isDirectory: &isDirectory]) {
        if (error != NULL)
            *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                         code: NSFileNoSuchFileError
                                     userInfo: nil];
        return nil;
    }

    NSString *extension = [path pathExtension];
    CFStringRef type = NULL;
    if ([extension length] > 0)
        type = UTTypeCreatePreferredIdentifierForTag(
                kUTTagClassFilenameExtension, (CFStringRef) extension, NULL);

    if (type == NULL)
        return isDirectory ? (NSString *) kUTTypeFolder
                           : (NSString *) kUTTypeData;

    return [(NSString *) type autorelease];
}

- (BOOL) openFile: (NSString *) path {
    return [self openFile: path withApplication: nil];
}

- (BOOL) openFile: (NSString *) path withApplication: (NSString *) application {
    return [self openFile: path
            withApplication: application
              andDeactivate: YES];
}

- (BOOL) openTempFile: (NSString *) path {
    return [self openFile: path withApplication: nil andDeactivate: YES];
}

- (BOOL) openFile: (NSString *) path
        fromImage: (NSImage *) image
               at: (NSPoint) point
           inView: (NSView *) view
{
    return [self openFile: path];
    return NO;
}

- (BOOL) openFile: (NSString *) path
        withApplication: (NSString *) application
          andDeactivate: (BOOL) deactivate
{
    // TODO: call LSOpenFromURLSpec()
    NSURL *applicationURL = nil;
    if (application != nil) {
        NSString *applicationPath = [self fullPathForApplication: application];
        if (applicationPath == nil)
            return NO;
        applicationURL = [NSURL fileURLWithPath: applicationPath
                                    isDirectory: YES];
    }

    NSUInteger launchOptions = deactivate ? 0 : 0x00000200;
    if (path == nil) {
        return applicationURL != nil &&
               [self launchApplicationAtURL: applicationURL
                                    options: launchOptions
                              configuration: nil
                                      error: NULL] != nil;
    }

    NSURL *fileURL = [NSURL fileURLWithPath: path];
    if (applicationURL == nil &&
        [[[path pathExtension] lowercaseString] isEqualToString: @"app"])
        return [self openURL: fileURL];
    if (applicationURL == nil)
        applicationURL = [self URLForApplicationToOpenURL: fileURL];
    if (applicationURL == nil)
        return NO;

    return [self openURLs: [NSArray arrayWithObject: fileURL]
       withApplicationAtURL: applicationURL
                    options: launchOptions
              configuration: nil
                      error: NULL] != nil;
    return NO;
}

- (BOOL) openURL: (NSURL *) url {
    if (url == nil)
        return NO;

    NSArray *urls = [NSArray arrayWithObject: url];
    return LSOpenURLsWithRole((CFArrayRef) urls, kLSRolesAll, NULL, NULL,
                              NULL, 0) == noErr;
}

- (BOOL) selectFile: (NSString *) path
        inFileViewerRootedAtPath: (NSString *) rootedAtPath
{
    if (path == nil || ![[NSFileManager defaultManager] fileExistsAtPath: path])
        return NO;

    NSString *directory = rootedAtPath;
    if (directory != nil && [directory length] > 0) {
        NSString *root = [directory stringByStandardizingPath];
        NSString *file = [path stringByStandardizingPath];
        NSString *prefix = [root hasSuffix: @"/"] ? root
                                                    : [root stringByAppendingString: @"/"];
        if (![file isEqualToString: root] &&
            ![file hasPrefix: prefix])
            return NO;
    } else {
        directory = [path stringByDeletingLastPathComponent];
    }

    if (directory == nil || [directory length] == 0)
        directory = @"/";
    return [self openURL: [NSURL fileURLWithPath: directory]];
}

- (void) slideImage: (NSImage *) image from: (NSPoint) from to: (NSPoint) to {
}

- (BOOL) performFileOperation: (NSString *) operation
                       source: (NSString *) source
                  destination: (NSString *) destination
                        files: (NSArray *) files
                          tag: (NSInteger *) tag
{
    if (tag != NULL)
        *tag = 0;
    if (operation == nil || source == nil || files == nil)
        return NO;

    BOOL copy = [operation isEqualToString: @"NSWorkspaceCopyOperation"];
    BOOL move = [operation isEqualToString: @"NSWorkspaceMoveOperation"];
    BOOL link = [operation isEqualToString: @"NSWorkspaceLinkOperation"];
    BOOL destroy = [operation isEqualToString: @"NSWorkspaceDestroyOperation"];
    BOOL recycle = [operation isEqualToString: NSWorkspaceRecycleOperation];
    if ((!copy && !move && !link && !destroy && !recycle) ||
        ((!destroy && !recycle) && destination == nil))
        return NO;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *file in files) {
        if (![file isKindOfClass: [NSString class]])
            return NO;

        NSString *sourcePath = [source stringByAppendingPathComponent: file];
        NSString *destinationPath =
                [destination stringByAppendingPathComponent: file];
        NSError *error = nil;
        BOOL succeeded;
        if (copy)
            succeeded = [fileManager copyItemAtPath: sourcePath
                                             toPath: destinationPath
                                              error: &error];
        else if (move)
            succeeded = [fileManager moveItemAtPath: sourcePath
                                             toPath: destinationPath
                                              error: &error];
        else if (link)
            succeeded = [fileManager linkItemAtPath: sourcePath
                                             toPath: destinationPath
                                              error: &error];
        else if (destroy)
            succeeded = [fileManager removeItemAtPath: sourcePath error: &error];
        else
            succeeded = [fileManager trashItemAtURL:
                                         [NSURL fileURLWithPath: sourcePath]
                                    resultingItemURL: NULL
                                                error: &error];

        if (!succeeded)
            return NO;
    }
    return YES;
}

- (BOOL) getFileSystemInfoForPath: (NSString *) path
                      isRemovable: (BOOL *) isRemovable
                       isWritable: (BOOL *) isWritable
                    isUnmountable: (BOOL *) isUnmountable
                      description: (NSString **) description
                             type: (NSString **) type
{
    // TODO: call statfs() to get filesystem information
    // Use DiskArbitration for the rest.
    if (isRemovable != NULL)
        *isRemovable = NO;
    if (isWritable != NULL)
        *isWritable = NO;
    if (isUnmountable != NULL)
        *isUnmountable = NO;
    if (description != NULL)
        *description = nil;
    if (type != NULL)
        *type = nil;
    if (!path)
        return NO;

    struct statfs filesystem;
    if (statfs([path fileSystemRepresentation], &filesystem) != 0)
        return NO;

    if (isRemovable != NULL)
        *isRemovable = (filesystem.f_flags & MNT_REMOVABLE) != 0;
    if (isWritable != NULL)
        *isWritable = (filesystem.f_flags & MNT_RDONLY) == 0;
    NSString *filesystemType = [NSString stringWithUTF8String:
                                        filesystem.f_fstypename];
    if (description != NULL)
        *description = filesystemType;
    if (type != NULL)
        *type = filesystemType;
    return YES;
}

- (BOOL) getInfoForFile: (NSString *) path
            application: (NSString **) application
                   type: (NSString **) type
{
    if (application != NULL)
        *application = nil;
    if (type != NULL)
        *type = nil;

    NSError *error = nil;
    NSString *fileType = [self typeOfFile: path error: &error];
    if (fileType == nil)
        return NO;

    NSURL *url = [NSURL fileURLWithPath: path];
    NSURL *applicationURL = [self URLForApplicationToOpenURL: url];
    if (application != NULL && applicationURL != nil)
        *application = [applicationURL path];
    if (type != NULL)
        *type = fileType;

    return applicationURL != nil;
}

- (void) checkForRemovableMedia {
}

- (NSArray *) mountNewRemovableMedia {
    return [self mountedRemovableMedia];
}

- (NSArray *) mountedRemovableMedia {
    // TODO: call [[NSFileManager defaultManager]
    // mountedVolumeURLsIncludingResourceValuesForKeys:@[NSURLVolumeIsRemovableKey]
    // options:NSVolumeEnumerationSkipHiddenVolumes]
    return MacWorkspaceMountedVolumePaths(MNT_REMOVABLE);
    return @[];
}

- (NSArray *) mountedLocalVolumePaths {
    // TODO: call [[NSFileManager defaultManager]
    // mountedVolumeURLsIncludingResourceValuesForKeys:@[]
    // options:NSVolumeEnumerationSkipHiddenVolumes]
    return MacWorkspaceMountedVolumePaths(MNT_LOCAL);
    return @[];
}

- (BOOL) unmountAndEjectDeviceAtPath: (NSString *) path {
    // TODO: call FSEjectVolumeSync()
    return NO;
}

- (BOOL) fileSystemChanged {
    return NO;
}

- (BOOL) userDefaultsChanged {
    return NO;
}

- (void) noteFileSystemChanged {
    [self noteFileSystemChanged: @"/"];
}

- (void) noteFileSystemChanged: (NSString *) path {
    // TODO: call FNNotifyByPath()
}

- (void) noteUserDefaultsChanged {
}

- (BOOL) isFilePackageAtPath: (NSString *) path {
    BOOL isDirectory = NO;
    if (path == nil ||
        ![[NSFileManager defaultManager] fileExistsAtPath: path
                                               isDirectory: &isDirectory] ||
        !isDirectory)
        return NO;

    NSString *type = [self typeOfFile: path error: NULL];
    if (type != nil && UTTypeConformsTo((CFStringRef) type, kUTTypePackage))
        return YES;

    NSString *extension = [[path pathExtension] lowercaseString];
    NSSet *packageExtensions = [NSSet setWithObjects:
            @"app", @"bundle", @"framework", @"plugin", @"kext",
            @"xcodeproj", @"playground", @"rtfd", @"pages", @"numbers",
            @"key", nil];
    if ([packageExtensions containsObject: extension])
        return YES;

    NSString *infoPath = [path stringByAppendingPathComponent:
            @"Contents/Info.plist"];
    return [[NSFileManager defaultManager] fileExistsAtPath: infoPath];
}

- (NSString *) absolutePathForAppBundleWithIdentifier: (NSString *) identifier {
    // TODO: call LSFindApplicationForInfo() /
    // LSCopyApplicationURLsForBundleIdentifier()
    NSURL *applicationURL = [self URLForApplicationWithBundleIdentifier:
                                      identifier];
    if (applicationURL != nil)
        return [applicationURL path];
    return NULL;
}

- (NSString *) pathForApplication: (NSString *) application {
    // This method doesn't exist on macOS?!
    return NULL;
}

- (NSArray *) launchedApplications {
    // TODO: call _LSCopyRunningApplicationArray()
    return @[];
}

- (NSArray *) runningApplications {
    NSRunningApplication *current = [NSRunningApplication currentApplication];
    return current != nil ? [NSArray arrayWithObject: current] : [NSArray array];
}

- (BOOL) launchApplication: (NSString *) application {
    return [self openFile: nil withApplication: application andDeactivate: YES];
}

- (BOOL) launchApplication: (NSString *) application
                  showIcon: (BOOL) showIcon
                autolaunch: (BOOL) autolaunch
{
    return [self openFile: nil withApplication: application andDeactivate: YES];
}

- (void) findApplications {
}

- (NSDictionary *) activeApplication {
    // TODO: call _LSCopyFrontApplication() and _LSCopyApplicationInformation()
    return NULL;
}

- (void) hideOtherApplications {
    [NSApp hideOtherApplications: self];
}

- (NSInteger) extendPowerOffBy: (NSInteger) milliseconds {
    return 0;
}

- (BOOL) setIcon: (NSImage *) image
         forFile: (NSString *) fullPath
         options: (NSWorkspaceIconCreationOptions) options
{
    // For directories, we would call the NSFileManager to create a file named
    // "Icon\r" with icon data. For files, we would call
    // FSCreateResFile/FSOpenResFile, FSSetCatalogInfo and other historical
    // functions. But none of these would have effect when viewed from Linux
    // desktop environments...
    return NO;
}

- (void) activateFileViewerSelectingURLs: (NSArray<NSURL *> *) fileURLs {
    [super activateFileViewerSelectingURLs: fileURLs];
}

- (NSURL *) URLForApplicationWithBundleIdentifier: (NSString *) bundleIdentifier
{
    CFURLRef url;
    OSStatus status = LSFindApplicationForInfo(kLSUnknownCreator,
                                               (CFStringRef) bundleIdentifier,
                                               NULL, NULL, &url);

    if (status != noErr)
        return nil;

    return [(NSURL *) url autorelease];
}

- (NSString *) fullPathForApplication: (NSString *) appName {
    // If absolute, return as-is
    if ([appName isAbsolutePath])
        return appName;

    // If it doesn't have an suffix, add .app
    if ([[appName pathExtension] isEqualToString: @""])
        appName = [appName stringByAppendingPathExtension: @"app"];

    CFURLRef url;
    OSStatus status = LSFindApplicationForInfo(
            kLSUnknownCreator, NULL, (CFStringRef) appName, NULL, &url);

    if (status != noErr)
        return nil;

    NSString *path = [(NSURL *) url path];
    CFRelease(url);

    return path;
}

@end
