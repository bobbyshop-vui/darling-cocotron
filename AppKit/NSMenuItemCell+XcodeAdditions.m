#import <AppKit/NSMenuItemCell+XcodeAdditions.h>
#import <AppKit/NSMenuItem.h>
#import <AppKit/NSMenu.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSGraphics.h>
#import <AppKit/NSView.h>
#import <AppKit/NSFont.h>
#import <AppKit/NSAttributedString.h>
#import <objc/runtime.h>
#import <objc/message.h>

static const char NSMenuItemCellNeedsDisplayKey;
static const char NSMenuItemCellSizeKey;

#define MIC_PADDING 2.0

@implementation NSMenuItemCell (XcodeAdditions)

- (NSImage *) _xcodeStateImage {
    NSMenuItem *item = [self menuItem];
    switch ([item state]) {
    case NSOnState:
        return [item onStateImage];
    case NSMixedState:
        return [item mixedStateImage];
    default:
        return [item offStateImage];
    }
}

- (NSFont *) _xcodeMenuFont {
    NSFont *font = [self font];
    return font != nil ? font : [NSFont menuFontOfSize: 0];
}

- (NSSize) _xcodeKeyEquivalentSize {
    NSString *description = [[self menuItem] _keyEquivalentDescription];
    if ([description length] == 0)
        return NSZeroSize;
    NSDictionary *attrs = [NSDictionary
            dictionaryWithObject: [self _xcodeMenuFont]
                          forKey: NSFontAttributeName];
    return [description sizeWithAttributes: attrs];
}

- (NSMenuView *) menuView {
    NSView *view = [self controlView];
    Class menuViewClass = NSClassFromString(@"NSMenuView");
    if (menuViewClass != Nil && [view isKindOfClass: menuViewClass])
        return (NSMenuView *) view;
    return nil;
}

- (BOOL) needsDisplay {
    NSNumber *flag = objc_getAssociatedObject(self, &NSMenuItemCellNeedsDisplayKey);
    return [flag boolValue];
}

- (void) setNeedsDisplay: (BOOL) flag {
    objc_setAssociatedObject(self, &NSMenuItemCellNeedsDisplayKey,
                             [NSNumber numberWithBool: flag],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat) imageWidth {
    NSImage *image = [[self menuItem] image];
    return image != nil ? [image size].width : 0.0;
}

- (CGFloat) titleWidth {
    NSAttributedString *title = [self attributedTitle];
    if (title == nil)
        title = [[self menuItem] attributedTitle];
    if (title != nil)
        return [title size].width;

    NSString *plain = [[self menuItem] title];
    if ([plain length] == 0)
        return 0.0;
    NSDictionary *attrs = [NSDictionary
            dictionaryWithObject: [self _xcodeMenuFont]
                          forKey: NSFontAttributeName];
    return [plain sizeWithAttributes: attrs].width;
}

- (void) calcSize {
    NSSize stateSize = [[self _xcodeStateImage] size];
    NSSize imageSize = [[[self menuItem] image] size];
    NSSize keySize = [self _xcodeKeyEquivalentSize];
    CGFloat titleWidth = [self titleWidth];
    NSFont *font = [self _xcodeMenuFont];
    CGFloat titleHeight = [font ascender] - [font descender];

    NSSize size = NSZeroSize;
    size.width = MIC_PADDING + stateSize.width + MIC_PADDING +
                 imageSize.width + (imageSize.width > 0 ? MIC_PADDING : 0) +
                 titleWidth + MIC_PADDING + keySize.width + MIC_PADDING;
    size.height = MAX(MAX(stateSize.height, imageSize.height),
                      MAX(titleHeight, keySize.height));

    objc_setAssociatedObject(self, &NSMenuItemCellSizeKey,
                             [NSValue valueWithSize: size],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([self respondsToSelector: @selector(setNeedsSizing:)])
        ((void (*)(id, SEL, BOOL))objc_msgSend)(self, @selector(setNeedsSizing:), NO);
}

- (NSRect) stateImageRectForBounds: (NSRect) cellFrame {
    NSSize size = [[self _xcodeStateImage] size];
    NSRect rect;

    rect.origin.x = cellFrame.origin.x + MIC_PADDING;
    rect.origin.y = cellFrame.origin.y +
                    floor((cellFrame.size.height - size.height) / 2.0);
    rect.size = size;
    if (rect.size.width > cellFrame.size.width)
        rect.size.width = cellFrame.size.width;
    return rect;
}

- (NSRect) keyEquivalentRectForBounds: (NSRect) cellFrame {
    NSSize size = [self _xcodeKeyEquivalentSize];
    CGFloat trailing = MIC_PADDING;
    if ([[self menuItem] hasSubmenu])
        trailing += 12.0;

    NSRect rect;
    rect.size = size;
    rect.origin.x = NSMaxX(cellFrame) - trailing - size.width;
    rect.origin.y = cellFrame.origin.y +
                    floor((cellFrame.size.height - size.height) / 2.0);
    if (rect.origin.x < cellFrame.origin.x)
        rect.origin.x = cellFrame.origin.x;
    return rect;
}

- (void) drawBorderAndBackgroundWithFrame: (NSRect) cellFrame
                                   inView: (NSView *) controlView {
    if ([self isHighlighted] && [self isEnabled] &&
        ![[self menuItem] isSeparatorItem]) {
        [[NSColor selectedMenuItemColor] set];
    } else {
        [[NSColor menuBackgroundColor] set];
    }
    NSRectFill(cellFrame);

    if ([self isBordered])
        [self drawBezelWithFrame: cellFrame inView: controlView];
}

- (void) drawImageWithFrame: (NSRect) cellFrame inView: (NSView *) controlView {
    NSImage *image = [[self menuItem] image];
    if (image == nil)
        return;

    NSRect stateRect = [self stateImageRectForBounds: cellFrame];
    NSSize size = [image size];
    NSRect rect;
    rect.origin.x = NSMaxX(stateRect) + MIC_PADDING;
    rect.origin.y = cellFrame.origin.y +
                    floor((cellFrame.size.height - size.height) / 2.0);
    rect.size = size;

    CGFloat alpha = [self isEnabled] ? 1.0 : 0.5;
    [image drawInRect: rect
             fromRect: NSZeroRect
            operation: NSCompositeSourceOver
             fraction: alpha];
}

@end
