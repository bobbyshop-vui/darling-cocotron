#import <AppKit/NSAccessibility.h>
#import <AppKit/NSAccessibilityConstants.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSGraphics.h>
#import <AppKit/NSGraphicsContextFunctions.h>
#import <AppKit/NSMenuItem.h>
#import <AppKit/NSView.h>
#import <AppKit/NSWindow.h>
#import <Foundation/Foundation.h>
#import <OpenGL/gl.h>

@interface NSObject (XcodeLazyAccessibility)
- (NSString *)accessibilityRole;
- (NSString *)accessibilitySubrole;
- (NSString *)accessibilityRoleDescription;
@end

@interface NSMenuItem (XcodeLazyKeyNames)
+ (NSDictionary *)keyNames;
@end

NSPoint NSAccessibilityPointInView(NSView *parentView, NSPoint point)
{
    if (parentView == nil)
        return point;

    NSWindow *window = [parentView window];
    if (window == nil)
        return point;

    point = [parentView convertPoint:point toView:nil];
    return [window convertPointToScreen:point];
}

static NSString *XcodeLazyRoleLabel(NSString *role)
{
    static NSDictionary *labels;
    if (labels == nil) {
        labels = [[NSDictionary alloc] initWithObjectsAndKeys:
            @"application", @"NSAccessibilityApplicationRole",
            @"browser", @"NSAccessibilityBrowserRole",
            @"busy indicator", @"NSAccessibilityBusyIndicatorRole",
            @"button", @"NSAccessibilityButtonRole",
            @"cell", @"NSAccessibilityCellRole",
            @"checkbox", @"NSAccessibilityCheckBoxRole",
            @"color well", @"NSAccessibilityColorWellRole",
            @"column", @"NSAccessibilityColumnRole",
            @"combo box", @"NSAccessibilityComboBoxRole",
            @"disclosure triangle", @"NSAccessibilityDisclosureTriangleRole",
            @"drawer", @"NSAccessibilityDrawerRole",
            @"grid", @"NSAccessibilityGridRole",
            @"group", @"NSAccessibilityGroupRole",
            @"grow area", @"NSAccessibilityGrowAreaRole",
            @"handle", @"NSAccessibilityHandleRole",
            @"help tag", @"NSAccessibilityHelpTagRole",
            @"image", @"NSAccessibilityImageRole",
            @"incrementor", @"NSAccessibilityIncrementorRole",
            @"layout area", @"NSAccessibilityLayoutAreaRole",
            @"layout item", @"NSAccessibilityLayoutItemRole",
            @"level indicator", @"NSAccessibilityLevelIndicatorRole",
            @"link", @"NSAccessibilityLinkRole",
            @"list", @"NSAccessibilityListRole",
            @"matte", @"NSAccessibilityMatteRole",
            @"menu bar", @"NSAccessibilityMenuBarRole",
            @"menu button", @"NSAccessibilityMenuButtonRole",
            @"menu item", @"NSAccessibilityMenuItemRole",
            @"menu", @"NSAccessibilityMenuRole",
            @"outline", @"NSAccessibilityOutlineRole",
            @"pop up button", @"NSAccessibilityPopUpButtonRole",
            @"progress indicator", @"NSAccessibilityProgressIndicatorRole",
            @"radio button", @"NSAccessibilityRadioButtonRole",
            @"radio group", @"NSAccessibilityRadioGroupRole",
            @"relevance indicator", @"NSAccessibilityRelevanceIndicatorRole",
            @"row", @"NSAccessibilityRowRole",
            @"ruler marker", @"NSAccessibilityRulerMarkerRole",
            @"ruler", @"NSAccessibilityRulerRole",
            @"scroll area", @"NSAccessibilityScrollAreaRole",
            @"scroll bar", @"NSAccessibilityScrollBarRole",
            @"sheet", @"NSAccessibilitySheetRole",
            @"slider", @"NSAccessibilitySliderRole",
            @"sort button", @"NSAccessibilitySortButtonRole",
            @"split group", @"NSAccessibilitySplitGroupRole",
            @"splitter", @"NSAccessibilitySplitterRole",
            @"text", @"NSAccessibilityStaticTextRole",
            @"system-wide element", @"NSAccessibilitySystemWideRole",
            @"tab group", @"NSAccessibilityTabGroupRole",
            @"table", @"NSAccessibilityTableRole",
            @"text entry area", @"NSAccessibilityTextAreaRole",
            @"text field", @"NSAccessibilityTextFieldRole",
            @"toolbar", @"NSAccessibilityToolbarRole",
            @"unknown", @"NSAccessibilityUnknownRole",
            @"value indicator", @"NSAccessibilityValueIndicatorRole",
            @"window", @"NSAccessibilityWindowRole",
            nil];
    }

    return [labels objectForKey:role];
}

NSString *NSAccessibilityRoleDescriptionForUIElement(id element)
{
    if (element == nil)
        return nil;

    if ([element respondsToSelector:@selector(accessibilityRoleDescription)]) {
        NSString *description = [element accessibilityRoleDescription];
        if ([description length] != 0)
            return description;
    }

    NSString *role = nil;
    NSString *subrole = nil;
    if ([element respondsToSelector:@selector(accessibilityRole)])
        role = [element accessibilityRole];
    if ([element respondsToSelector:@selector(accessibilitySubrole)])
        subrole = [element accessibilitySubrole];

    NSString *description = NSAccessibilityRoleDescription(role, subrole);
    if (description != nil)
        return description;

    if ([subrole isEqualToString:NSAccessibilityCloseButtonSubrole])
        return @"close button";
    if ([subrole isEqualToString:NSAccessibilityMinimizeButtonSubrole])
        return @"minimize button";
    if ([subrole isEqualToString:NSAccessibilityZoomButtonSubrole])
        return @"zoom button";
    if ([subrole isEqualToString:NSAccessibilityStandardWindowSubrole])
        return @"standard window";
    if ([subrole isEqualToString:NSAccessibilityDialogSubrole])
        return @"dialog";

    return XcodeLazyRoleLabel(role);
}

NSString *NSAccessibilityActionDescription(NSAccessibilityActionName action)
{
    if ([action isEqualToString:NSAccessibilityPressAction])
        return @"press";
    if ([action isEqualToString:NSAccessibilityIncrementAction])
        return @"increment";
    if ([action isEqualToString:NSAccessibilityDecrementAction])
        return @"decrement";
    if ([action isEqualToString:NSAccessibilityConfirmAction])
        return @"confirm";
    if ([action isEqualToString:NSAccessibilityPickAction])
        return @"pick";
    if ([action isEqualToString:NSAccessibilityCancelAction])
        return @"cancel";
    if ([action isEqualToString:NSAccessibilityRaiseAction])
        return @"raise";
    if ([action isEqualToString:NSAccessibilityShowMenuAction])
        return @"show menu";
    if ([action isEqualToString:NSAccessibilityDeleteAction])
        return @"delete";
    if ([action isEqualToString:NSAccessibilityShowAlternateUIAction])
        return @"show alternate UI";
    if ([action isEqualToString:NSAccessibilityShowDefaultUIAction])
        return @"show default UI";
    return nil;
}

/* Darling has no system-wide accessibility identifier registry to unregister. */
void NSAccessibilityUnregisterUniqueIdForUIElement(id element)
{
    (void)element;
}

BOOL NSApplicationLoad(void)
{
    return [NSApplication sharedApplication] != nil;
}

const NSWindowDepth *NSAvailableWindowDepths(void)
{
    static const NSWindowDepth depths[] = {
        NSWindowDepthTwentyfourBitRGB,
        0
    };
    return depths;
}

NSWindowDepth NSBestDepth(NSString *colorSpace, NSInteger bitsPerSample,
                          NSInteger bitsPerPixel, BOOL planar,
                          BOOL *exactMatch)
{
    BOOL rgbColorSpace = colorSpace == nil ||
        [colorSpace isEqualToString:NSDeviceRGBColorSpace] ||
        [colorSpace isEqualToString:NSCalibratedRGBColorSpace];
    BOOL exact = rgbColorSpace && !planar &&
        (bitsPerSample == 0 || bitsPerSample == 8) &&
        (bitsPerPixel == 0 || bitsPerPixel == 24);

    if (exactMatch != NULL)
        *exactMatch = exact;
    return NSWindowDepthTwentyfourBitRGB;
}

static CGFloat XcodeLazyMin(CGFloat lhs, CGFloat rhs)
{
    return lhs < rhs ? lhs : rhs;
}

NSRect NSDrawColorTiledRects(NSRect boundsRect, NSRect clipRect,
                             const NSRectEdge *sides,
                             NSColor * const *colors, NSInteger count)
{
    NSRect remaining = boundsRect;
    CGContextRef context = NSCurrentGraphicsPort();
    BOOL hasContext = context != NULL;
    BOOL clipped = hasContext && !NSIsEmptyRect(clipRect);
    if (hasContext)
        CGContextSaveGState(context);
    if (clipped)
        NSRectClip(clipRect);

    if (sides != NULL && colors != NULL && count > 0 &&
        hasContext) {
        for (NSInteger index = 0; index < count; ++index) {
            NSRect stripe;
            CGFloat thickness;

            switch (sides[index]) {
            case NSMinXEdge:
                thickness = XcodeLazyMin(1.0, remaining.size.width);
                stripe = NSMakeRect(remaining.origin.x, remaining.origin.y,
                                    thickness, remaining.size.height);
                remaining.origin.x += thickness;
                remaining.size.width -= thickness;
                break;
            case NSMinYEdge:
                thickness = XcodeLazyMin(1.0, remaining.size.height);
                stripe = NSMakeRect(remaining.origin.x, remaining.origin.y,
                                    remaining.size.width, thickness);
                remaining.origin.y += thickness;
                remaining.size.height -= thickness;
                break;
            case NSMaxXEdge:
                thickness = XcodeLazyMin(1.0, remaining.size.width);
                stripe = NSMakeRect(NSMaxX(remaining) - thickness,
                                    remaining.origin.y, thickness,
                                    remaining.size.height);
                remaining.size.width -= thickness;
                break;
            case NSMaxYEdge:
                thickness = XcodeLazyMin(1.0, remaining.size.height);
                stripe = NSMakeRect(remaining.origin.x,
                                    NSMaxY(remaining) - thickness,
                                    remaining.size.width, thickness);
                remaining.size.height -= thickness;
                break;
            default:
                continue;
            }

            if (colors[index] != nil && stripe.size.width > 0 &&
                stripe.size.height > 0) {
                [colors[index] setFill];
                NSRectFill(stripe);
            }
        }
    }

    if (hasContext)
        CGContextRestoreGState(context);
    return remaining;
}

void NSRectFillListWithColorsUsingOperation(
    const NSRect *rects, NSColor * const *colors, NSInteger count,
    NSCompositingOperation operation)
{
    CGContextRef context = NSCurrentGraphicsPort();
    if (rects == NULL || colors == NULL || count <= 0 || context == NULL)
        return;

    CGContextSaveGState(context);
    for (NSInteger index = 0; index < count; ++index) {
        if (colors[index] == nil)
            continue;
        [colors[index] setFill];
        NSRectFillUsingOperation(rects[index], operation);
    }
    CGContextRestoreGState(context);
}

/* This build has no AppKit menu-theme backend; draw the available flat colors. */
void NSDrawMenuBackground(NSRect rect, NSRect clipRect, NSInteger backgroundType)
{
    (void)backgroundType;
    CGContextRef context = NSCurrentGraphicsPort();
    if (context == NULL)
        return;

    CGContextSaveGState(context);
    if (!NSIsEmptyRect(clipRect))
        NSRectClip(clipRect);
    [[NSColor menuBackgroundColor] setFill];
    NSRectFill(rect);
    CGContextRestoreGState(context);
}

void NSDrawMenuItemBackground(NSRect rect, BOOL highlighted)
{
    CGContextRef context = NSCurrentGraphicsPort();
    if (!highlighted || context == NULL)
        return;

    CGContextSaveGState(context);
    [[NSColor selectedMenuItemColor] setFill];
    NSRectFill(rect);
    CGContextRestoreGState(context);
}

/* Scope-bar appearance is supplied by the unavailable system theme service. */
void NSDrawScopeBar(NSRect rect, BOOL drawTopBorder, BOOL drawBottomBorder)
{
    (void)rect;
    (void)drawTopBorder;
    (void)drawBottomBorder;
}

enum {
    XcodeLazyOpenGLFormatCacheSize = 501,
    XcodeLazyOpenGLClearFormatCache = 502,
    XcodeLazyOpenGLRetainRenderers = 503,
    XcodeLazyOpenGLResetLibrary = 504,
    XcodeLazyOpenGLUseBuildCache = 506
};

static GLint xcodeLazyOpenGLFormatCacheSize;
static GLint xcodeLazyOpenGLRetainRenderers;
static GLint xcodeLazyOpenGLUseBuildCache;

void NSOpenGLSetOption(uint32_t option, GLint value)
{
    switch (option) {
    case XcodeLazyOpenGLFormatCacheSize:
        xcodeLazyOpenGLFormatCacheSize = value > 0 ? value : 0;
        break;
    case XcodeLazyOpenGLClearFormatCache:
        /* There is no pixel-format cache to clear in this build. */
        break;
    case XcodeLazyOpenGLRetainRenderers:
        xcodeLazyOpenGLRetainRenderers = value != 0;
        break;
    case XcodeLazyOpenGLUseBuildCache:
        xcodeLazyOpenGLUseBuildCache = value != 0;
        break;
    case XcodeLazyOpenGLResetLibrary:
        xcodeLazyOpenGLFormatCacheSize = 0;
        xcodeLazyOpenGLRetainRenderers = 0;
        xcodeLazyOpenGLUseBuildCache = 0;
        break;
    }
}

void NSOpenGLGetOption(uint32_t option, GLint *value)
{
    if (value == NULL)
        return;

    switch (option) {
    case XcodeLazyOpenGLFormatCacheSize:
        *value = xcodeLazyOpenGLFormatCacheSize;
        break;
    case XcodeLazyOpenGLRetainRenderers:
        *value = xcodeLazyOpenGLRetainRenderers;
        break;
    case XcodeLazyOpenGLUseBuildCache:
        *value = xcodeLazyOpenGLUseBuildCache;
        break;
    case XcodeLazyOpenGLClearFormatCache:
    case XcodeLazyOpenGLResetLibrary:
    default:
        *value = 0;
        break;
    }
}

void NSOpenGLGetVersion(GLint *major, GLint *minor)
{
    if (major != NULL)
        *major = 0;
    if (minor != NULL)
        *minor = 0;
}

NSString *_NSNameFromKeyEquivalentString(NSString *keyEquivalent)
{
    if (keyEquivalent == nil)
        return nil;

    NSDictionary *keyNames = [NSMenuItem keyNames];
    NSString *name = [keyNames objectForKey:keyEquivalent];
    return name != nil ? name : [keyEquivalent uppercaseString];
}

NSColor *_NSNewCatalogColor(NSString *catalogName, NSString *colorName)
{
    if (catalogName == nil || colorName == nil)
        return nil;
    return [NSColor colorWithCatalogName:catalogName colorName:colorName];
}
