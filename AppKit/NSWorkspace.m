/* Copyright (c) 2006-2007 Christopher J. W. Lloyd <cjwl@objc.net>

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <AppKit/NSRaise.h>
#import <AppKit/NSWorkspace.h>
#import <Foundation/Foundation.h>
#import <AppKit/NSRunningApplication.h>
#include <LaunchServices/LaunchServices.h>

/* NSWorkspaceLaunchOptions bits used below (see the SDK's NSWorkspace.h). */
enum {
    DarlingWorkspaceLaunchAndPrint = 0x00000002,
    DarlingWorkspaceLaunchNewInstance = 0x00080000
};

NSString *const NSWorkspaceApplicationKey = @"NSWorkspaceApplicationKey";

NSString *const NSWorkspaceWillPowerOffNotification =
        @"NSWorkspaceWillPowerOffNotification";

NSString *const NSWorkspaceRecycleOperation = @"NSWorkspaceRecycleOperation";

NSString *const NSWorkspaceLaunchConfigurationAppleEvent =
        @"NSWorkspaceLaunchConfigurationAppleEvent";
NSString *const NSWorkspaceLaunchConfigurationArguments =
        @"NSWorkspaceLaunchConfigurationArguments";
NSString *const NSWorkspaceLaunchConfigurationEnvironment =
        @"NSWorkspaceLaunchConfigurationEnvironment";
NSString *const NSWorkspaceLaunchConfigurationArchitecture =
        @"NSWorkspaceLaunchConfigurationArchitecture";

NSString *const NSWorkspaceActiveSpaceDidChangeNotification =
        @"NSWorkspaceActiveSpaceDidChangeNotification";
const NSNotificationName NSWorkspaceDidDeactivateApplicationNotification =
        @"NSWorkspaceDidDeactivateApplicationNotification";
const NSNotificationName NSWorkspaceDidWakeNotification = 
        @"NSWorkspaceDidWakeNotification";
NSString *const NSWorkspaceDidLaunchApplicationNotification =
        @"NSWorkspaceDidLaunchApplicationNotification";
NSString *const NSWorkspaceDidTerminateApplicationNotification =
        @"NSWorkspaceDidTerminateApplicationNotification";
const NSNotificationName NSWorkspaceScreensDidSleepNotification =
        @"NSWorkspaceScreensDidSleepNotification";
const NSNotificationName NSWorkspaceScreensDidWakeNotification =
        @"NSWorkspaceScreensDidWakeNotification";
const NSNotificationName NSWorkspaceWillSleepNotification =
        @"NSWorkspaceWillSleepNotification";
const NSNotificationName NSWorkspaceSessionDidBecomeActiveNotification =
        @"NSWorkspaceSessionDidBecomeActiveNotification";
const NSNotificationName NSWorkspaceSessionDidResignActiveNotification =
        @"NSWorkspaceSessionDidResignActiveNotification";
NSNotificationName const NSWorkspaceDidActivateApplicationNotification = @"NSWorkspaceDidActivateApplicationNotification";

const NSNotificationName
        NSWorkspaceAccessibilityDisplayOptionsDidChangeNotification =
                @"NSWorkspaceAccessibilityDisplayOptionsDidChangeNotification";

NSNotificationName NSWorkspaceDidMountNotification = @"NSWorkspaceDidMountNotification";
NSNotificationName NSWorkspaceDidUnmountNotification = @"NSWorkspaceDidUnmountNotification";
NSNotificationName NSWorkspaceWillUnmountNotification = @"NSWorkspaceWillUnmountNotification";

@implementation NSWorkspace

+ (NSWorkspace *) sharedWorkspace {
    return NSThreadSharedInstance(@"NSWorkspace");
}

- init {
    _notificationCenter = [[NSNotificationCenter alloc] init];
    return self;
}

- (NSNotificationCenter *) notificationCenter {
    return _notificationCenter;
}

- (NSImage *) iconForFile: (NSString *) path {
    NSInvalidAbstractInvocation();
    return 0;
}

- (NSImage *) iconForFiles: (NSArray *) array {
    NSInvalidAbstractInvocation();
    return 0;
}

- (NSImage *) iconForFileType: (NSString *) type {
    NSInvalidAbstractInvocation();
    return 0;
}

- (NSString *) localizedDescriptionForType: (NSString *) type {
    NSInvalidAbstractInvocation();
    return 0;
}

- (BOOL) filenameExtension: (NSString *) extension
            isValidForType: (NSString *) type
{
    NSInvalidAbstractInvocation();
    return 0;
}

- (NSString *) preferredFilenameExtensionForType: (NSString *) type {
    NSInvalidAbstractInvocation();
    return 0;
}

- (BOOL) type: (NSString *) type conformsToType: (NSString *) conformsToType {
    NSInvalidAbstractInvocation();
    return 0;
}

- (NSString *) typeOfFile: (NSString *) path error: (NSError **) error {
    NSInvalidAbstractInvocation();
    return 0;
}

- (BOOL) openFile: (NSString *) path {
    NSInvalidAbstractInvocation();
    return 0;
}

- (BOOL) openFile: (NSString *) path withApplication: (NSString *) application {
    NSInvalidAbstractInvocation();
    return 0;
}

- (BOOL) openTempFile: (NSString *) path {
    NSInvalidAbstractInvocation();
    return 0;
}

- (BOOL) openFile: (NSString *) path
        fromImage: (NSImage *) image
               at: (NSPoint) point
           inView: (NSView *) view
{
    NSInvalidAbstractInvocation();
    return 0;
}

- (BOOL) openFile: (NSString *) path
        withApplication: (NSString *) application
          andDeactivate: (BOOL) deactivate
{
    NSInvalidAbstractInvocation();
    return 0;
}

- (BOOL) openURL: (NSURL *) url {
    NSInvalidAbstractInvocation();
    return 0;
}

- (BOOL) selectFile: (NSString *) path
        inFileViewerRootedAtPath: (NSString *) rootedAtPath
{
    NSInvalidAbstractInvocation();
    return 0;
}

- (void) slideImage: (NSImage *) image from: (NSPoint) from to: (NSPoint) to {
    NSInvalidAbstractInvocation();
}

- (BOOL) performFileOperation: (NSString *) operation
                       source: (NSString *) source
                  destination: (NSString *) destination
                        files: (NSArray *) files
                          tag: (NSInteger *) tag
{
    NSInvalidAbstractInvocation();
    return 0;
}

- (BOOL) getFileSystemInfoForPath: (NSString *) path
                      isRemovable: (BOOL *) isRemovable
                       isWritable: (BOOL *) isWritable
                    isUnmountable: (BOOL *) isUnmountable
                      description: (NSString **) description
                             type: (NSString **) type
{
    NSInvalidAbstractInvocation();
    return 0;
}

- (BOOL) getInfoForFile: (NSString *) path
            application: (NSString **) application
                   type: (NSString **) type
{
    NSInvalidAbstractInvocation();
    return 0;
}

- (void) checkForRemovableMedia {
    NSInvalidAbstractInvocation();
}

- (NSArray *) mountNewRemovableMedia {
    NSInvalidAbstractInvocation();
    return 0;
}

- (NSArray *) mountedRemovableMedia {
    NSInvalidAbstractInvocation();
    return 0;
}

- (NSArray *) mountedLocalVolumePaths {
    NSInvalidAbstractInvocation();
    return 0;
}

- (BOOL) unmountAndEjectDeviceAtPath: (NSString *) path {
    NSInvalidAbstractInvocation();
    return 0;
}

- (BOOL) fileSystemChanged {
    NSInvalidAbstractInvocation();
    return 0;
}

- (BOOL) userDefaultsChanged {
    NSInvalidAbstractInvocation();
    return 0;
}

- (void) noteFileSystemChanged {
    NSInvalidAbstractInvocation();
}

- (void) noteFileSystemChanged: (NSString *) path {
    NSInvalidAbstractInvocation();
}

- (void) noteUserDefaultsChanged {
    NSInvalidAbstractInvocation();
}

- (BOOL) isFilePackageAtPath: (NSString *) path {
    NSInvalidAbstractInvocation();
    return 0;
}

- (NSString *) absolutePathForAppBundleWithIdentifier: (NSString *) identifier {
    NSInvalidAbstractInvocation();
    return 0;
}

- (NSString *) pathForApplication: (NSString *) application {
    NSInvalidAbstractInvocation();
    return 0;
}

- (NSArray *) launchedApplications {
    NSInvalidAbstractInvocation();
    return 0;
}

- (NSArray *) runningApplications {
    // NSInvalidAbstractInvocation();
    return @[];
}

- (BOOL) launchApplication: (NSString *) application {
    NSInvalidAbstractInvocation();
    return 0;
}

- (BOOL) launchApplication: (NSString *) application
                  showIcon: (BOOL) showIcon
                autolaunch: (BOOL) autolaunch
{
    NSInvalidAbstractInvocation();
    return 0;
}

- (void) findApplications {
    NSInvalidAbstractInvocation();
}

- (NSDictionary *) activeApplication {
    NSInvalidAbstractInvocation();
    return 0;
}

- (void) hideOtherApplications {
    NSInvalidAbstractInvocation();
}

- (NSInteger) extendPowerOffBy: (NSInteger) milliseconds {
    NSInvalidAbstractInvocation();
    return 0;
}

- (NSString *) fullPathForApplication: (NSString *) appName {
    NSInvalidAbstractInvocation();
    return nil;
}

- (NSURL *) URLForApplicationWithBundleIdentifier: (NSString *) bundleIdentifier
{
    if (bundleIdentifier == nil)
        return nil;

    CFURLRef url = NULL;
    OSStatus status = LSFindApplicationForInfo(
            kLSUnknownCreator, (CFStringRef) bundleIdentifier, NULL, NULL, &url);

    if (status != noErr || url == NULL)
        return nil;

    return [(NSURL *) url autorelease];
}

- (NSURL *) URLForApplicationToOpenURL: (NSURL *) url {
    if (url == nil)
        return nil;

    CFURLRef appURL = LSCopyDefaultApplicationURLForURL(
            (CFURLRef) url, kLSRolesAll, NULL);

    if (appURL == NULL)
        return nil;

    return [(NSURL *) appURL autorelease];
}

- (void) activateFileViewerSelectingURLs: (NSArray<NSURL *> *) fileURLs {
    // Without a Finder, show each selected item's enclosing folder.
    NSMutableSet *folders = [NSMutableSet set];

    for (NSURL *fileURL in fileURLs) {
        NSURL *folder = [fileURL URLByDeletingLastPathComponent];
        if (folder != nil && ![folders containsObject: folder]) {
            [folders addObject: folder];
            [self openURL: folder];
        }
    }
}

- (BOOL) accessibilityDisplayShouldIncreaseContrast {
    return NO;
}

- (BOOL) accessibilityDisplayShouldReduceMotion {
    return NO;
}

- (BOOL) isVoiceOverEnabled {
    return NO;
}

- (NSRunningApplication *) _darlingLaunchBundleAtURL: (NSURL *) applicationURL
                                           arguments: (NSArray *) extraArguments
                                             options: (NSWorkspaceLaunchOptions) options
                                       configuration: (NSDictionary *) configuration
                                               error: (NSError **) error
{
    NSBundle *bundle = [NSBundle bundleWithURL: applicationURL];
    NSString *executable = [bundle executablePath];

    if (executable == nil) {
        if (error != NULL)
            *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                         code: NSFileNoSuchFileError
                                     userInfo: nil];
        return nil;
    }

    if (!(options & DarlingWorkspaceLaunchNewInstance)) {
        NSString *identifier = [bundle bundleIdentifier];
        if (identifier != nil) {
            NSArray *running = [NSRunningApplication
                    runningApplicationsWithBundleIdentifier: identifier];
            if ([running count] > 0)
                return [running objectAtIndex: 0];
        }
    }

    NSMutableArray *arguments = [NSMutableArray array];
    NSArray *configArguments =
            [configuration objectForKey: NSWorkspaceLaunchConfigurationArguments];
    if ([configArguments isKindOfClass: [NSArray class]])
        [arguments addObjectsFromArray: configArguments];
    if (extraArguments != nil)
        [arguments addObjectsFromArray: extraArguments];

    NSTask *task = [[[NSTask alloc] init] autorelease];
    [task setLaunchPath: executable];
    [task setArguments: arguments];

    NSDictionary *configEnvironment =
            [configuration objectForKey: NSWorkspaceLaunchConfigurationEnvironment];
    if ([configEnvironment isKindOfClass: [NSDictionary class]]) {
        NSMutableDictionary *environment = [[[[NSProcessInfo processInfo]
                environment] mutableCopy] autorelease];
        [environment addEntriesFromDictionary: configEnvironment];
        [task setEnvironment: environment];
    }

    @try {
        [task launch];
    } @catch (NSException *exception) {
        if (error != NULL)
            *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                         code: NSFileReadUnknownError
                                     userInfo: nil];
        return nil;
    }

    return [NSRunningApplication
            runningApplicationWithProcessIdentifier: [task processIdentifier]];
}

- (NSRunningApplication *) launchApplicationAtURL: (NSURL *) url
                                          options: (NSWorkspaceLaunchOptions) options
                                    configuration: (NSDictionary *) configuration
                                            error: (NSError **) error
{
    return [self _darlingLaunchBundleAtURL: url
                                 arguments: nil
                                   options: options
                             configuration: configuration
                                     error: error];
}

- (NSRunningApplication *) openURLs: (NSArray<NSURL *> *) urls
               withApplicationAtURL: (NSURL *) applicationURL
                            options: (NSWorkspaceLaunchOptions) options
                      configuration: (NSDictionary *) configuration
                              error: (NSError **) error
{
    NSMutableArray *arguments = [NSMutableArray array];

    for (NSURL *url in urls)
        [arguments addObject: [url isFileURL] ? [url path] : [url absoluteString]];

    return [self _darlingLaunchBundleAtURL: applicationURL
                                 arguments: arguments
                                   options: options
                             configuration: configuration
                                     error: error];
}

- (BOOL) launchAppWithBundleIdentifier: (NSString *) bundleIdentifier
                               options: (NSWorkspaceLaunchOptions) options
        additionalEventParamDescriptor: (NSAppleEventDescriptor *) descriptor
                      launchIdentifier: (NSNumber **) identifier
{
    NSURL *applicationURL = [self URLForApplicationWithBundleIdentifier: bundleIdentifier];

    if (identifier != NULL)
        *identifier = nil;
    if (applicationURL == nil)
        return NO;

    NSRunningApplication *app = [self launchApplicationAtURL: applicationURL
                                                     options: options
                                               configuration: nil
                                                       error: NULL];
    if (app == nil)
        return NO;

    if (identifier != NULL)
        *identifier = [NSNumber numberWithInt: [app processIdentifier]];
    return YES;
}

- (BOOL) openURLs: (NSArray<NSURL *> *) urls
        withAppBundleIdentifier: (NSString *) bundleIdentifier
                        options: (NSWorkspaceLaunchOptions) options
        additionalEventParamDescriptor: (NSAppleEventDescriptor *) descriptor
              launchIdentifiers: (NSArray<NSNumber *> **) identifiers
{
    NSURL *applicationURL = nil;

    if (identifiers != NULL)
        *identifiers = nil;

    if (bundleIdentifier != nil)
        applicationURL = [self URLForApplicationWithBundleIdentifier: bundleIdentifier];
    else if ([urls count] > 0)
        applicationURL = [self URLForApplicationToOpenURL: [urls objectAtIndex: 0]];

    if (applicationURL == nil)
        return NO;

    NSRunningApplication *app = [self openURLs: urls
                          withApplicationAtURL: applicationURL
                                       options: options
                                 configuration: nil
                                         error: NULL];
    if (app == nil)
        return NO;

    if (identifiers != NULL)
        *identifiers = [NSArray
                arrayWithObject: [NSNumber numberWithInt: [app processIdentifier]]];
    return YES;
}

- (void) recycleURLs: (NSArray<NSURL *> *) URLs
        completionHandler: (void (^)(NSDictionary<NSURL *, NSURL *> *newURLs,
                                     NSError *error)) handler
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *trashPath = [NSHomeDirectory()
            stringByAppendingPathComponent: @".local/share/Trash/files"];
    NSMutableDictionary *newURLs = [NSMutableDictionary dictionary];
    NSError *firstError = nil;

    [fileManager createDirectoryAtPath: trashPath
           withIntermediateDirectories: YES
                            attributes: nil
                                 error: NULL];

    for (NSURL *url in URLs) {
        NSString *name = [[url path] lastPathComponent];
        NSString *destination = [trashPath stringByAppendingPathComponent: name];
        unsigned suffix = 1;

        while ([fileManager fileExistsAtPath: destination])
            destination = [trashPath
                    stringByAppendingPathComponent:
                            [NSString stringWithFormat: @"%@ %u.%@",
                                      [name stringByDeletingPathExtension],
                                      ++suffix, [name pathExtension]]];

        NSError *moveError = nil;
        NSURL *destinationURL = [NSURL fileURLWithPath: destination];

        if ([fileManager moveItemAtURL: url
                                 toURL: destinationURL
                                 error: &moveError])
            [newURLs setObject: destinationURL forKey: url];
        else if (firstError == nil)
            firstError = moveError;
    }

    if (handler != NULL)
        handler(newURLs, firstError);
}

@end

@implementation NSWorkspace (CocotronAdditions)

- (BOOL) isFileHiddenAtPath: (NSString *) path {
    return NO;
}

@end

static dispatch_once_t _initOnceNsWorkspaceOpenConfig;
static NSWorkspaceOpenConfiguration* _singletonNsWorkspaceOpenConfig;

@implementation NSWorkspaceOpenConfiguration
+ (instancetype)configuration {
    dispatch_once(&_initOnceNsWorkspaceOpenConfig, ^{
        _singletonNsWorkspaceOpenConfig = [[NSWorkspaceOpenConfiguration alloc] init];
    });
    return _singletonNsWorkspaceOpenConfig;
}

@end