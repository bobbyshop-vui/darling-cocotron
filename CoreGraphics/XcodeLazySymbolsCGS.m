/*
 * Safe CoreGraphics Services exports used by lazily-bound Xcode clients.
 * Darling's CoreGraphics implementation has no WindowServer or display
 * capture backend, so these calls return initialized empty state rather than
 * attempting to contact an unavailable service.
 */

#import <CoreFoundation/CoreFoundation.h>
#import <CoreGraphics/CGAffineTransform.h>
#import <CoreGraphics/CGColorSpace.h>
#import <CoreGraphics/CGDirectDisplay.h>
#import <CoreGraphics/CGError.h>
#import <CoreGraphics/CGImage.h>
#import <CoreGraphics/CoreGraphicsExport.h>
#import <CoreGraphics/CoreGraphicsPrivate.h>

#include <stdint.h>

typedef struct CGDisplayStream *CGDisplayStreamRef;

/* Public declarations found in the macOS SDK's CGDirectDisplay.h and
 * CGDisplayStream.h. */
COREGRAPHICS_EXPORT CGImageRef CGDisplayCreateImage(CGDirectDisplayID displayID);
COREGRAPHICS_EXPORT CGError CGDisplayStreamStart(CGDisplayStreamRef displayStream);
COREGRAPHICS_EXPORT CGError CGDisplayStreamStop(CGDisplayStreamRef displayStream);

/* CGS private interfaces are not declared in the SDK headers. */
COREGRAPHICS_EXPORT CGColorSpaceRef
CGSCopyDisplayColorSpace(CGDirectDisplayID displayID)
{
    (void)displayID;
    return NULL;
}

COREGRAPHICS_EXPORT CGError
CGSFindWindowAndOwner(CGSConnectionID connection,
                      CGWindowID startWindow,
                      int orderingOperation,
                      bool isDragging,
                      const CGPoint *screenPoint,
                      CGPoint *windowPoint,
                      CGWindowID *foundWindow,
                      CGSConnectionID *foundConnection)
{
    (void)connection;
    (void)startWindow;
    (void)orderingOperation;
    (void)isDragging;
    (void)screenPoint;
    if (windowPoint != NULL)
        *windowPoint = CGPointZero;
    if (foundWindow != NULL)
        *foundWindow = 0;
    if (foundConnection != NULL)
        *foundConnection = 0;
    return kCGErrorFailure;
}

COREGRAPHICS_EXPORT CGError
CGSGetCurrentCursorLocation(CGSConnectionID connection, CGPoint *location)
{
    (void)connection;
    if (location != NULL)
        *location = CGPointZero;
    return location != NULL ? kCGErrorSuccess : kCGErrorIllegalArgument;
}

COREGRAPHICS_EXPORT CGError
CGSGetGlobalHotKeyOperatingMode(CGSConnectionID connection, int *mode)
{
    (void)connection;
    if (mode == NULL)
        return kCGErrorIllegalArgument;
    *mode = 0; /* kCGSGlobalHotKeyEnable */
    return kCGErrorSuccess;
}

COREGRAPHICS_EXPORT CGError
CGSGetSurfaceBounds(CGSConnectionID connection,
                    CGWindowID window,
                    CGSSurfaceID surface,
                    CGRect *bounds)
{
    (void)connection;
    (void)window;
    (void)surface;
    if (bounds == NULL)
        return kCGErrorIllegalArgument;
    *bounds = CGRectZero;
    return kCGErrorSuccess;
}

COREGRAPHICS_EXPORT CGError
CGSGetSymbolicHotKeyValue(int hotKey,
                          uint16_t *keyEquivalent,
                          uint16_t *virtualKeyCode,
                          uint32_t *modifiers)
{
    (void)hotKey;
    if (keyEquivalent != NULL)
        *keyEquivalent = 0;
    if (virtualKeyCode != NULL)
        *virtualKeyCode = 0;
    if (modifiers != NULL)
        *modifiers = 0;
    return kCGErrorSuccess;
}

COREGRAPHICS_EXPORT CGError
CGSGetWindowTransformAtPlacement(CGSConnectionID connection,
                                 CGWindowID window,
                                 CGAffineTransform *transform)
{
    (void)connection;
    (void)window;
    if (transform == NULL)
        return kCGErrorIllegalArgument;
    *transform = CGAffineTransformIdentity;
    return kCGErrorSuccess;
}

COREGRAPHICS_EXPORT int CGSInputButtonState(int button)
{
    (void)button;
    return 0;
}

COREGRAPHICS_EXPORT bool CGSIsSymbolicHotKeyEnabled(int hotKey)
{
    (void)hotKey;
    return false;
}

COREGRAPHICS_EXPORT bool CGSServerOperationState(int operation)
{
    (void)operation;
    return false;
}

COREGRAPHICS_EXPORT CFArrayRef CGSSessionCopyAllSessionProperties(void)
{
    return CFArrayCreate(kCFAllocatorDefault, NULL, 0, &kCFTypeArrayCallBacks);
}

COREGRAPHICS_EXPORT CGError CGSSessionReleaseSessionID(int sessionID)
{
    (void)sessionID;
    return kCGErrorSuccess;
}

COREGRAPHICS_EXPORT CGError
CGSSetGlobalHotKeyOperatingMode(CGSConnectionID connection, int mode)
{
    (void)connection;
    (void)mode;
    return kCGErrorSuccess;
}

COREGRAPHICS_EXPORT CGError
CGSSetWindowBackgroundBlurRadius(CGSConnectionID connection,
                                 CGWindowID window,
                                 int radius)
{
    (void)connection;
    (void)window;
    (void)radius;
    return kCGErrorSuccess;
}

COREGRAPHICS_EXPORT CGError
CGSSetWindowTransformAtPlacement(CGSConnectionID connection,
                                 CGWindowID window,
                                 CGAffineTransform transform)
{
    (void)connection;
    (void)window;
    (void)transform;
    return kCGErrorSuccess;
}

COREGRAPHICS_EXPORT CGImageRef CGDisplayCreateImage(CGDirectDisplayID displayID)
{
    (void)displayID;
    return NULL;
}

COREGRAPHICS_EXPORT CGError CGDisplayStreamStart(CGDisplayStreamRef displayStream)
{
    (void)displayStream;
    return kCGErrorSuccess;
}

COREGRAPHICS_EXPORT CGError CGDisplayStreamStop(CGDisplayStreamRef displayStream)
{
    (void)displayStream;
    return kCGErrorSuccess;
}
