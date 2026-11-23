#import <AppKit/NSApplication.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSRunningApplication.h>
#import <signal.h>
#import <unistd.h>
#import <errno.h>

// DUMMY

// Implementation notes:
// _LSCopyApplicationInformationItem(-2, ...) is used to fetch properties, such
// as _kLSExecutablePathKey Applications (processes) are referred to by an
// opaque void* asn (application serial number). ASNs can be compared with
// _LSCompareASNs().
//
// lsd provides notifications when processes change. This is registered via:
// _LSScheduleNotificationFunction(-2, callback, eventMask, context,
// CFRunLoopRef, kCFRunLoopCommonModes) and _LSModifyNotification(). The
// properties are updated via KVO.
//
// Current application is also observed via LS - _LSGetCurrentApplicationASN().
// All apps: _LSCopyRunningApplicationArray() - returns an array of ASNs.
// Running apps: _LSCopyRunningApplicationArray() - ditto.

@implementation NSRunningApplication

- (instancetype) _initWithProcessIdentifier: (pid_t) pid {
    _processIdentifier = pid;
    _isCurrent = (pid == getpid());
    return self;
}

+ (NSArray<NSRunningApplication *> *) runningApplicationsWithBundleIdentifier: (NSString *) bundleIdentifier {
    NSRunningApplication *current = [self currentApplication];
    if (bundleIdentifier != nil &&
        [[current bundleIdentifier] isEqualToString: bundleIdentifier])
        return [NSArray arrayWithObject: current];
    return [NSArray array];
}

+ (NSRunningApplication *) runningApplicationWithProcessIdentifier: (pid_t) pid {
    if (pid == getpid())
        return [self currentApplication];
    if (pid <= 0)
        return nil;
    if (kill(pid, 0) != 0 && errno != EPERM)
        return nil;
    return [[[self alloc] _initWithProcessIdentifier: pid] autorelease];
}

+ (NSRunningApplication *) currentApplication {
    static NSRunningApplication *current = nil;
    @synchronized(self) {
        if (current == nil)
            current = [[self alloc] _initWithProcessIdentifier: getpid()];
    }
    return current;
}

- (BOOL) isTerminated {
    if (_isCurrent)
        return NO;
    return kill(_processIdentifier, 0) != 0 && errno != EPERM;
}

- (BOOL) isFinishedLaunching {
    return !_isCurrent || NSApp != nil;
}

- (BOOL) isHidden {
    return _isCurrent ? [NSApp isHidden] : NO;
}

- (BOOL) isActive {
    return _isCurrent ? [NSApp isActive] : NO;
}

- (NSString *) localizedName {
    if (_isCurrent) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *name = [[bundle localizedInfoDictionary] objectForKey: @"CFBundleDisplayName"];
        if (name == nil)
            name = [[bundle infoDictionary] objectForKey: @"CFBundleName"];
        if (name == nil)
            name = [[NSProcessInfo processInfo] processName];
        return name;
    }
    NSString *comm = [NSString stringWithContentsOfFile:
                                       [NSString stringWithFormat: @"/proc/%d/comm", (int) _processIdentifier]
                                               encoding: NSUTF8StringEncoding
                                                  error: NULL];
    return [comm stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *) bundleIdentifier {
    return _isCurrent ? [[NSBundle mainBundle] bundleIdentifier] : nil;
}

- (NSURL *) bundleURL {
    return _isCurrent ? [[NSBundle mainBundle] bundleURL] : nil;
}

- (NSURL *) executableURL {
    if (_isCurrent)
        return [[NSBundle mainBundle] executableURL];
    NSString *path = [[NSFileManager defaultManager]
            destinationOfSymbolicLinkAtPath: [NSString stringWithFormat: @"/proc/%d/exe",
                                                                         (int) _processIdentifier]
                                      error: NULL];
    return path != nil ? [NSURL fileURLWithPath: path] : nil;
}

- (pid_t) processIdentifier {
    return _processIdentifier;
}

- (NSImage *) icon {
    return _isCurrent ? [NSApp applicationIconImage] : nil;
}

- (BOOL) hide {
    if (!_isCurrent)
        return NO;
    [NSApp hide: nil];
    return YES;
}

- (BOOL) unhide {
    if (!_isCurrent)
        return NO;
    [NSApp unhide: nil];
    return YES;
}

- (BOOL) activateWithOptions: (NSApplicationActivationOptions) options {
    if (!_isCurrent)
        return NO;
    [NSApp activateIgnoringOtherApps: (options & NSApplicationActivateIgnoringOtherApps) != 0];
    return YES;
}

- (BOOL) terminate {
    if (_isCurrent) {
        [NSApp terminate: nil];
        return YES;
    }
    return kill(_processIdentifier, SIGTERM) == 0;
}

- (BOOL) forceTerminate {
    return kill(_processIdentifier, SIGKILL) == 0;
}

@end
