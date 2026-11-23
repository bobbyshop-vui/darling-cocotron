#import <CoreText/CTFontManager.h>
#import <Foundation/Foundation.h>
#import <Onyx2D/O2Font_freetype.h>

const CFStringRef kCTFontManagerRegisteredFontsChangedNotification = CFSTR("CTFontManagerFontChangedNotification");
const CFStringRef kCTFontManagerErrorDomain = CFSTR("com.apple.CoreText.CTFontManagerErrorDomain");
const CFStringRef kCTFontManagerErrorFontURLsKey = CFSTR("CTFontManagerErrorFontURLs");

/*
 * fontconfig cannot drop a single application font again, so registration is
 * tracked here: it is what makes a second registration of the same file fail
 * with kCTFontManagerErrorAlreadyRegistered, and what unregistration checks.
 * Every registration is process-wide, whatever scope the caller asked for.
 */
static NSMutableSet *registeredFontPaths(void)
{
    static NSMutableSet *paths = nil;
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        paths = [[NSMutableSet alloc] init];
    });
    return paths;
}

static void setFontManagerError(CFErrorRef *error, CFIndex code, CFURLRef url)
{
    if (error == NULL)
        return;

    NSDictionary *info = nil;
    if (url != NULL)
        info = @{ (NSString *) kCTFontManagerErrorFontURLsKey: @[ (NSURL *) url ] };

    *error = CFErrorCreate(kCFAllocatorDefault, kCTFontManagerErrorDomain, code,
                           (CFDictionaryRef) info);
}

static void postFontsChanged(void)
{
    CFNotificationCenterPostNotification(CFNotificationCenterGetLocalCenter(),
                                         kCTFontManagerRegisteredFontsChangedNotification,
                                         NULL, NULL, true);
}

static NSString *standardizedFontPath(CFURLRef fontURL)
{
    NSURL *url = (NSURL *) fontURL;

    if (url == nil || ![url isFileURL])
        return nil;
    return [[url path] stringByStandardizingPath];
}

bool CTFontManagerRegisterFontsForURL(CFURLRef fontURL, CTFontManagerScope scope, CFErrorRef *error)
{
    @autoreleasepool {
        NSString *path = standardizedFontPath(fontURL);
        BOOL isDirectory = NO;

        if (error != NULL)
            *error = NULL;

        if (scope == kCTFontManagerScopeNone) {
            setFontManagerError(error, kCTFontManagerErrorInvalidFontData, fontURL);
            return false;
        }

        if (path == nil ||
            ![[NSFileManager defaultManager] fileExistsAtPath: path isDirectory: &isDirectory] ||
            isDirectory)
        {
            setFontManagerError(error, kCTFontManagerErrorFileNotFound, fontURL);
            return false;
        }

        if (![[NSFileManager defaultManager] isReadableFileAtPath: path]) {
            setFontManagerError(error, kCTFontManagerErrorInsufficientPermissions, fontURL);
            return false;
        }

        NSMutableSet *paths = registeredFontPaths();
        @synchronized(paths) {
            if ([paths containsObject: path]) {
                setFontManagerError(error, kCTFontManagerErrorAlreadyRegistered, fontURL);
                return false;
            }

            if (!O2FontRegisterFontFile(path)) {
                setFontManagerError(error, kCTFontManagerErrorInvalidFontData, fontURL);
                return false;
            }

            [paths addObject: path];
        }

        postFontsChanged();
        return true;
    }
}

bool CTFontManagerUnregisterFontsForURL(CFURLRef fontURL, CTFontManagerScope scope, CFErrorRef *error)
{
    @autoreleasepool {
        NSString *path = standardizedFontPath(fontURL);
        NSMutableSet *paths = registeredFontPaths();

        if (error != NULL)
            *error = NULL;

        @synchronized(paths) {
            if (path == nil || ![paths containsObject: path]) {
                setFontManagerError(error, kCTFontManagerErrorNotRegistered, fontURL);
                return false;
            }
            /*
             * fontconfig keeps the face in its application font set; it stops
             * counting as registered, and registering it again succeeds.
             */
            [paths removeObject: path];
        }

        postFontsChanged();
        return true;
    }
}

static bool registerFontURLs(CFArrayRef fontURLs, CTFontManagerScope scope, CFArrayRef *errors,
                             bool (*op)(CFURLRef, CTFontManagerScope, CFErrorRef *))
{
    CFMutableArrayRef failures = NULL;
    bool allOK = true;
    CFIndex count = (fontURLs != NULL) ? CFArrayGetCount(fontURLs) : 0;

    if (errors != NULL)
        *errors = NULL;

    for (CFIndex i = 0; i < count; i++) {
        CFErrorRef error = NULL;

        if (!op((CFURLRef) CFArrayGetValueAtIndex(fontURLs, i), scope, &error)) {
            allOK = false;
            if (errors != NULL && error != NULL) {
                if (failures == NULL)
                    failures = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
                CFArrayAppendValue(failures, error);
            }
        }
        if (error != NULL)
            CFRelease(error);
    }

    if (errors != NULL)
        *errors = failures;
    else if (failures != NULL)
        CFRelease(failures);

    return allOK;
}

bool CTFontManagerRegisterFontsForURLs(CFArrayRef fontURLs, CTFontManagerScope scope, CFArrayRef *errors)
{
    return registerFontURLs(fontURLs, scope, errors, CTFontManagerRegisterFontsForURL);
}

bool CTFontManagerUnregisterFontsForURLs(CFArrayRef fontURLs, CTFontManagerScope scope, CFArrayRef *errors)
{
    return registerFontURLs(fontURLs, scope, errors, CTFontManagerUnregisterFontsForURL);
}

/*
 * A CGFont already lives in memory, and CoreText looks fonts up by name
 * through fontconfig, which only knows files.  Registering one is accepted so
 * callers can go on to use the CGFont they hold directly.
 */
bool CTFontManagerRegisterGraphicsFont(CGFontRef font, CFErrorRef *error)
{
    if (error != NULL)
        *error = NULL;

    if (font == NULL) {
        setFontManagerError(error, kCTFontManagerErrorInvalidFontData, NULL);
        return false;
    }
    postFontsChanged();
    return true;
}

bool CTFontManagerUnregisterGraphicsFont(CGFontRef font, CFErrorRef *error)
{
    if (error != NULL)
        *error = NULL;

    if (font == NULL) {
        setFontManagerError(error, kCTFontManagerErrorNotRegistered, NULL);
        return false;
    }
    postFontsChanged();
    return true;
}

CFArrayRef CTFontManagerCopyAvailableFontFamilyNames(void)
{
    @autoreleasepool {
        return (CFArrayRef) O2FontCopyAvailableFamilyNames();
    }
}
