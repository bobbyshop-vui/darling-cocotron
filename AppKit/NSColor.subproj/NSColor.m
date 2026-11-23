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

#import <AppKit/NSBezierPath.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSColor_CGColor.h>
#import <AppKit/NSColor_catalog.h>
#import <AppKit/NSColorList.h>
#import <AppKit/NSColorSpace.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSRaise.h>

#import <AppKit/NSGraphics.h>
#import <AppKit/NSGraphicsContext.h>

#import <AppKit/NSPasteboard.h>
#import <Foundation/NSKeyedArchiver.h>

#import <objc/runtime.h>

static int NSColor_ignoresAlpha = -1;

NSNotificationName const NSSystemColorsDidChangeNotification = @"NSSystemColorsDidChangeNotification";

@protocol NSColorCIColorComponents
- (CGFloat) red;
- (CGFloat) green;
- (CGFloat) blue;
- (CGFloat) alpha;
@end

// Builds a catalog color in the "System" list with an explicit sRGB value.
static NSColor *NSColorSystemCatalogColor(NSString *name, CGFloat r, CGFloat g,
                                          CGFloat b, CGFloat a)
{
    NSColor *value = [NSColor colorWithSRGBRed: r green: g blue: b alpha: a];

    return [NSColor_catalog colorWithCatalogName: @"System"
                                       colorName: name
                                           color: value];
}

static NSColorSpaceName NSColorSpaceNameForComponentCount(NSInteger count) {
    switch (count) {
    case 2:
        return NSCalibratedWhiteColorSpace;
    case 5:
        return NSDeviceCMYKColorSpace;
    default:
        return NSCalibratedRGBColorSpace;
    }
}

@interface NSColor (private)
- (NSColorListName) catalogName;
- (NSColorName) colorName;
@end

@implementation NSColor

- (void) encodeWithCoder: (NSCoder *) coder {

    if ([coder allowsKeyedCoding]) {
        NSColorSpaceName spaceName = [self colorSpaceName];

        if ([spaceName isEqualToString: NSCalibratedRGBColorSpace]) {
            CGFloat r, g, b, a;

            [self getRed: &r green: &g blue: &b alpha: &a];
            [coder encodeInt: 1 forKey: @"NSColorSpace"];
            NSString *string =
                    [NSString stringWithFormat: @"%f %f %f %f", r, g, b, a];
            NSData *data = [string dataUsingEncoding: NSASCIIStringEncoding];
            [coder encodeBytes: [data bytes]
                        length: [data length]
                        forKey: @"NSRGB"];
        } else if ([spaceName isEqualToString: NSDeviceRGBColorSpace]) {
            CGFloat r, g, b, a;

            [self getRed: &r green: &g blue: &b alpha: &a];
            [coder encodeInt: 2 forKey: @"NSColorSpace"];
            NSString *string =
                    [NSString stringWithFormat: @"%f %f %f %f", r, g, b, a];
            NSData *data = [string dataUsingEncoding: NSASCIIStringEncoding];
            [coder encodeBytes: [data bytes]
                        length: [data length]
                        forKey: @"NSRGB"];
        } else if ([spaceName isEqualToString: NSCalibratedWhiteColorSpace]) {
            CGFloat g, a;

            [self getWhite: &g alpha: &a];
            [coder encodeInt: 3 forKey: @"NSColorSpace"];
            NSString *string = [NSString stringWithFormat: @"%f %f", g, a];
            NSData *data = [string dataUsingEncoding: NSASCIIStringEncoding];
            [coder encodeBytes: [data bytes]
                        length: [data length]
                        forKey: @"NSWhite"];
        } else if ([spaceName isEqualToString: NSDeviceWhiteColorSpace]) {
            CGFloat g, a;

            [self getWhite: &g alpha: &a];
            [coder encodeInt: 4 forKey: @"NSColorSpace"];
            NSString *string = [NSString stringWithFormat: @"%f %f", g, a];
            NSData *data = [string dataUsingEncoding: NSASCIIStringEncoding];
            [coder encodeBytes: [data bytes]
                        length: [data length]
                        forKey: @"NSWhite"];
        } else if ([spaceName isEqualToString: NSDeviceCMYKColorSpace]) {
            CGFloat c, m, y, k, a;

            [self getCyan: &c magenta: &m yellow: &y black: &k alpha: &a];
            [coder encodeInt: 5 forKey: @"NSColorSpace"];
            NSString *string = [NSString
                    stringWithFormat: @"%f %f %f %f %f", c, m, y, k, a];
            NSData *data = [string dataUsingEncoding: NSASCIIStringEncoding];
            [coder encodeBytes: [data bytes]
                        length: [data length]
                        forKey: @"NSCMYK"];
        } else if ([spaceName isEqualToString: NSNamedColorSpace]) {
            [coder encodeInt: 6 forKey: @"NSColorSpace"];
            [coder encodeObject: [self catalogNameComponent]
                         forKey: @"NSCatalogName"];
            [coder encodeObject: [self colorNameComponent]
                         forKey: @"NSColorName"];
            // FIXME: encode @"NSColor"
        }

    } else {
        [NSException raise: NSInvalidArgumentException
                    format: @"%@ can not encodeWithCoder:%@", [self class],
                            [coder class]];
    }
}

- (Class) classForCoder {
    return objc_lookUpClass("NSColor");
}

- initWithCoder: (NSCoder *) coder {
    NSColor *result = nil;
    NSKeyedUnarchiver *keyed = nil;
    int colorSpace;

    if ([coder allowsKeyedCoding]) {
        keyed = (NSKeyedUnarchiver *) coder;
        colorSpace = [keyed decodeIntForKey: @"NSColorSpace"];
    } else {
        uint8_t space;
        [coder decodeValuesOfObjCTypes: "c", &space];
        colorSpace = space;
    }

    switch (colorSpace) {
    case 1: // NSCalibratedRGBColor
    case 2: // NSDeviceRGBColor
    {
        CGFloat values[4] = {0, 0, 0, 1};

        if (keyed != nil) {
            NSUInteger length;
            const uint8_t *rgb = [keyed decodeBytesForKey: @"NSRGB"
                                           returnedLength: &length];
            NSString *string = [[[NSString alloc]
                    initWithBytes: rgb
                           length: length
                         encoding: NSUTF8StringEncoding] autorelease];
            NSArray *components = [string componentsSeparatedByString: @" "];
            int count = [components count];

            for (int i = 0; i < count && i < 4; i++)
                values[i] = [[components objectAtIndex: i] doubleValue];
        } else {
            float fvalues[4];
            [coder decodeValuesOfObjCTypes: "ffff", &fvalues[0], &fvalues[1],
                                            &fvalues[2], &fvalues[3]];

            for (int i = 0; i < 4; i++)
                values[i] = fvalues[i];
        }

        if (colorSpace == 1)
            result = [NSColor colorWithCalibratedRed: values[0]
                                               green: values[1]
                                                blue: values[2]
                                               alpha: values[3]];
        else
            result = [NSColor colorWithDeviceRed: values[0]
                                           green: values[1]
                                            blue: values[2]
                                           alpha: values[3]];
    } break;

    case 3: // NSCalibratedWhiteColor
    case 4: // NSDeviceWhiteColor
    {
        CGFloat values[2] = {0, 1};

        if (keyed != nil) {
            NSUInteger length;
            const uint8_t *white = [keyed decodeBytesForKey: @"NSWhite"
                                             returnedLength: &length];
            NSString *string = [[[NSString alloc]
                    initWithBytes: white
                           length: length
                         encoding: NSUTF8StringEncoding] autorelease];
            NSArray *components = [string componentsSeparatedByString: @" "];
            int count = [components count];

            for (int i = 0; i < count && i < 2; i++)
                values[i] = [[components objectAtIndex: i] doubleValue];
        } else {
            float fvalues[2];
            [coder decodeValuesOfObjCTypes: "ff", &fvalues[0], &fvalues[1]];

            for (int i = 0; i < 2; i++)
                values[i] = fvalues[i];
        }

        if (colorSpace == 3)
            result = [NSColor colorWithCalibratedWhite: values[0]
                                                 alpha: values[1]];
        else
            result = [NSColor colorWithDeviceWhite: values[0] alpha: values[1]];
    } break;

    case 5: // NSDeviceCMYKColor
    {
        // NSComponents data
        // NSCustomColorSpace NSColorSpace
        CGFloat values[5] = {0, 0, 0, 0, 1};

        if (keyed != nil) {
            NSUInteger length;
            const uint8_t *cmyk = [keyed decodeBytesForKey: @"NSCMYK"
                                            returnedLength: &length];
            NSString *string = [[[NSString alloc]
                    initWithBytes: cmyk
                           length: length - 1
                         encoding: NSUTF8StringEncoding] autorelease];
            NSArray *components = [string componentsSeparatedByString: @" "];
            int count = [components count];

            for (int i = 0; i < count && i < 5; i++)
                values[i] = [[components objectAtIndex: i] doubleValue];
        } else {
            float fvalues[5];
            [coder decodeValuesOfObjCTypes: "fffff", &fvalues[0], &fvalues[1],
                                            &fvalues[2], &fvalues[3],
                                            &fvalues[4]];

            for (int i = 0; i < 5; i++)
                values[i] = fvalues[i];
        }

        result = [NSColor colorWithDeviceCyan: values[0]
                                      magenta: values[1]
                                       yellow: values[2]
                                        black: values[3]
                                        alpha: values[4]];
    } break;

    case 6: // NSCatalogColor
    {
        NSColorListName catalogName;
        NSColorName colorName;
        NSColor *color;

        if (keyed != nil) {
            catalogName = [keyed decodeObjectForKey: @"NSCatalogName"];
            colorName = [keyed decodeObjectForKey: @"NSColorName"];
            color = [keyed decodeObjectForKey: @"NSColor"];
        } else {
            [coder decodeValuesOfObjCTypes: "@@@", &catalogName, &colorName,
                                            &color];
        }

        result = [NSColor_catalog colorWithCatalogName: catalogName
                                             colorName: colorName
                                                 color: color];
    } break;
    case 9: // oldSystemColor
    {
    }
    case 10: // NSPatternColor
    {
    }
    case 11: // NSColorSpaceColor
    {
    }

    default:
        NSLog(@"-[%@ %s] unknown color space %d", [self class],
              sel_getName(_cmd), colorSpace);
        result = [NSColor blackColor];
        break;
    }

    return [result retain];
}

- copyWithZone: (NSZone *) zone {
    return [self retain];
}

+ (NSColor *) alternateSelectedControlColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"alternateSelectedControlColor"];
}

+ (NSColor *) alternateSelectedControlTextColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"alternateSelectedControlTextColor"];
}

+ (NSColor *) keyboardFocusIndicatorColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"keyboardFocusIndicatorColor"];
}

+ (NSColor *) highlightColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"highlightColor"];
}

+ (NSColor *) shadowColor {
    return [NSColor colorWithCatalogName: @"System" colorName: @"shadowColor"];
}

+ (NSColor *) gridColor {
    return [NSColor colorWithCatalogName: @"System" colorName: @"gridColor"];
}

+ (NSColor *) controlColor {
    return [NSColor colorWithCatalogName: @"System" colorName: @"controlColor"];
}

+ (NSColor *) selectedControlColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"selectedControlColor"];
}

+ (NSColor *) secondarySelectedControlColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"secondarySelectedControlColor"];
}

+ (NSColor *) controlTextColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"controlTextColor"];
}

+ (NSColor *) selectedControlTextColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"selectedControlTextColor"];
}

+ (NSColor *) disabledControlTextColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"disabledControlTextColor"];
}

+ (NSColor *) controlBackgroundColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"controlBackgroundColor"];
}

+ (NSColor *) controlDarkShadowColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"controlDarkShadowColor"];
}

+ (NSColor *) controlHighlightColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"controlHighlightColor"];
}

+ (NSColor *) controlLightHighlightColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"controlLightHighlightColor"];
}

+ (NSColor *) controlShadowColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"controlShadowColor"];
}

// overwrite this, if you need a different set of alternating background colors
// NOTE: the list may contain more then two colors
+ (NSArray *) controlAlternatingRowBackgroundColors {
    return [NSArray arrayWithObjects: [NSColor whiteColor],
                                      [NSColor colorWithCalibratedRed: 0.90
                                                                green: 0.95
                                                                 blue: 1.0
                                                                alpha: 1.0],
                                      nil];
}

+ (NSColor *) textColor {
    return [NSColor colorWithCatalogName: @"System" colorName: @"textColor"];
}

+ (NSColor *) textBackgroundColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"textBackgroundColor"];
}

+ (NSColor *) selectedTextColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"selectedTextColor"];
}

+ (NSColor *) selectedTextBackgroundColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"selectedTextBackgroundColor"];
}

+ (NSColor *) headerColor {
    return [NSColor colorWithCatalogName: @"System" colorName: @"headerColor"];
}

+ (NSColor *) headerTextColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"headerTextColor"];
}

+ (NSColor *) scrollBarColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"scrollBarColor"];
}

+ (NSColor *) knobColor {
    return [NSColor colorWithCatalogName: @"System" colorName: @"knobColor"];
}

+ (NSColor *) selectedKnobColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"selectedKnobColor"];
}

+ (NSColor *) windowBackgroundColor {
    return [NSColor controlColor];
}

+ (NSColor *) windowFrameColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"windowFrameColor"];
}

+ (NSColor *) selectedMenuItemColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"selectedMenuItemColor"];
}

+ (NSColor *) selectedMenuItemTextColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"selectedMenuItemTextColor"];
}

+ (NSColor *) menuBackgroundColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"menuBackgroundColor"];
}

+ (NSColor *) mainMenuBarColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"mainMenuBarColor"];
}

+ (NSColor *) menuItemTextColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"menuItemTextColor"];
}

+ (NSColor *) labelColor {
    return [NSColor colorWithCatalogName: @"System" colorName: @"labelColor"];
}

+ (NSColor *) unemphasizedSelectedTextColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"unemphasizedSelectedTextColor"];
}

+ (NSColor *) unemphasizedSelectedTextBackgroundColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"unemphasizedSelectedTextBackgroundColor"];
}

+ (NSColor *) linkColor {
    return [NSColor colorWithCatalogName: @"System" colorName: @"linkColor"];
}

+ (NSColor *) selectedContentBackgroundColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"selectedContentBackgroundColor"];
}

+ (NSColor *) unemphasizedSelectedContentBackgroundColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"unemphasizedSelectedContentBackgroundColor"];
}

+ (NSColor *) alternatingContentBackgroundColor {
    return [NSColor colorWithCatalogName: @"System"
                               colorName: @"alternatingContentBackgroundColor"];
}

+ (NSArray<NSColor *> *) alternatingContentBackgroundColors {
    return [NSArray arrayWithObjects: [self controlBackgroundColor],
                                      [self alternatingContentBackgroundColor],
                                      nil];
}

#pragma mark - Catalog and semantic colors

+ (NSColor *) colorNamed: (NSColorName) name bundle: (NSBundle *) bundle {
    if (name == nil)
        return nil;

    // There is no asset catalog support: fall back to the system color list,
    // which is where macOS resolves un-prefixed system color names.
    NSColor *result = [[NSColorList colorListNamed: @"System"] colorWithKey: name];

    if (result == nil)
        return nil;

    return [NSColor colorWithCatalogName: @"System" colorName: name];
}

+ (NSColor *) colorNamed: (NSColorName) name {
    return [self colorNamed: name bundle: nil];
}

+ (NSColor *) controlAccentColor {
    return NSColorSystemCatalogColor(@"controlAccentColor", 0.0, 0.478431,
                                     1.0, 1.0);
}

// 1 == NSBlueControlTint, the default accent
+ (NSUInteger) currentControlTint {
    return 1;
}

+ (NSColor *) findHighlightColor {
    return NSColorSystemCatalogColor(@"findHighlightColor", 1.0, 1.0, 0.0,
                                     1.0);
}

+ (NSColor *) placeholderTextColor {
    return NSColorSystemCatalogColor(@"placeholderTextColor", 0.0, 0.0, 0.0,
                                     0.25);
}

+ (NSColor *) secondaryLabelColor {
    return NSColorSystemCatalogColor(@"secondaryLabelColor", 0.0, 0.0, 0.0,
                                     0.498039);
}

+ (NSColor *) tertiaryLabelColor {
    return NSColorSystemCatalogColor(@"tertiaryLabelColor", 0.0, 0.0, 0.0,
                                     0.259804);
}

+ (NSColor *) quaternaryLabelColor {
    return NSColorSystemCatalogColor(@"quaternaryLabelColor", 0.0, 0.0, 0.0,
                                     0.098039);
}

+ (NSColor *) separatorColor {
    return NSColorSystemCatalogColor(@"separatorColor", 0.0, 0.0, 0.0,
                                     0.098039);
}

// No Touch Bar textures are available, so use the flat Touch Bar black.
+ (NSColor *) scrubberTexturedBackgroundColor {
    return NSColorSystemCatalogColor(@"scrubberTexturedBackgroundColor", 0.1,
                                     0.1, 0.1, 1.0);
}

+ (NSColor *) underPageBackgroundColor {
    return NSColorSystemCatalogColor(@"underPageBackgroundColor", 0.588235,
                                     0.588235, 0.588235, 1.0);
}

+ (NSColor *) windowFrameTextColor {
    return NSColorSystemCatalogColor(@"windowFrameTextColor", 0.0, 0.0, 0.0,
                                     0.847059);
}

+ (NSColor *) systemRedColor {
    return NSColorSystemCatalogColor(@"systemRedColor", 1.0, 0.231373,
                                     0.188235, 1.0);
}

+ (NSColor *) systemOrangeColor {
    return NSColorSystemCatalogColor(@"systemOrangeColor", 1.0, 0.584314, 0.0,
                                     1.0);
}

+ (NSColor *) systemYellowColor {
    return NSColorSystemCatalogColor(@"systemYellowColor", 1.0, 0.8, 0.0, 1.0);
}

+ (NSColor *) systemGreenColor {
    return NSColorSystemCatalogColor(@"systemGreenColor", 0.203922, 0.780392,
                                     0.349020, 1.0);
}

+ (NSColor *) systemBlueColor {
    return NSColorSystemCatalogColor(@"systemBlueColor", 0.0, 0.478431, 1.0,
                                     1.0);
}

+ (NSColor *) systemPurpleColor {
    return NSColorSystemCatalogColor(@"systemPurpleColor", 0.686275, 0.321569,
                                     0.870588, 1.0);
}

+ (NSColor *) systemPinkColor {
    return NSColorSystemCatalogColor(@"systemPinkColor", 1.0, 0.176471,
                                     0.333333, 1.0);
}

+ (NSColor *) systemBrownColor {
    return NSColorSystemCatalogColor(@"systemBrownColor", 0.635294, 0.517647,
                                     0.368627, 1.0);
}

+ (NSColor *) systemGrayColor {
    return NSColorSystemCatalogColor(@"systemGrayColor", 0.556863, 0.556863,
                                     0.576471, 1.0);
}

#pragma mark - Construction from other representations

+ (NSColor *) colorWithCGColor: (CGColorRef) cgColor {
    if (cgColor == NULL)
        return nil;

    if (CGColorGetPattern(cgColor) != NULL)
        return [NSColor_CGColor colorWithColorRef: cgColor
                                        spaceName: NSPatternColorSpace];

    return [NSColor_CGColor
            colorWithColorRef: cgColor
                    spaceName: NSColorSpaceNameForComponentCount(
                                       CGColorGetNumberOfComponents(cgColor))];
}

+ (NSColor *) colorWithCIColor: (CIColor *) color {
    if (color == nil)
        return nil;

    id<NSColorCIColorComponents> ci = (id<NSColorCIColorComponents>) color;

    return [NSColor colorWithSRGBRed: [ci red]
                               green: [ci green]
                                blue: [ci blue]
                               alpha: [ci alpha]];
}

+ (NSColor *) colorWithColorSpace: (NSColorSpace *) space
                       components: (const CGFloat *) components
                            count: (NSInteger) numberOfComponents
{
    if (space == nil || components == NULL || numberOfComponents < 1)
        return nil;

    CGColorSpaceRef cgSpace = [space CGColorSpace];

    if (cgSpace == NULL)
        return nil;

    CGColorRef cgColor = CGColorCreate(cgSpace, components);

    if (cgColor == NULL)
        return nil;

    NSColor *result = [NSColor_CGColor
            colorWithColorRef: cgColor
                    spaceName: NSColorSpaceNameForComponentCount(
                                       numberOfComponents)];

    CGColorRelease(cgColor);
    return result;
}

+ (NSColor *) colorWithHue: (CGFloat) hue
                saturation: (CGFloat) saturation
                brightness: (CGFloat) brightness
                     alpha: (CGFloat) alpha
{
    return [self colorWithCalibratedHue: hue
                             saturation: saturation
                             brightness: brightness
                                  alpha: alpha];
}

#pragma mark - Type, color space and derived colors

- (NSColorType) type {
    NSColorSpaceName name = [self colorSpaceName];

    if ([name isEqualToString: NSNamedColorSpace])
        return NSColorTypeCatalog;
    if ([name isEqualToString: NSPatternColorSpace])
        return NSColorTypePattern;
    return NSColorTypeComponentBased;
}

- (NSColorSpace *) colorSpace {
    CGColorRef cgColor = [self CGColor];

    if (cgColor == NULL)
        return nil;

    return [[[NSColorSpace alloc]
            initWithCGColorSpace: CGColorGetColorSpace(cgColor)] autorelease];
}

- (NSColor *) colorUsingType: (NSColorType) type {
    if ([self type] == type)
        return self;

    // Only catalog colors can be resolved to component based colors; patterns
    // and component based colors have no representation as another type.
    if (type == NSColorTypeComponentBased &&
        [self type] == NSColorTypeCatalog) {
        CGColorRef cgColor = [self CGColor];

        if (cgColor == NULL || CGColorGetPattern(cgColor) != NULL)
            return nil;

        return [NSColor_CGColor
                colorWithColorRef: cgColor
                        spaceName: NSColorSpaceNameForComponentCount(
                                           CGColorGetNumberOfComponents(
                                                   cgColor))];
    }

    return nil;
}

- (NSColor *) colorUsingColorSpace: (NSColorSpace *) space {
    NSColor *base = [self colorUsingType: NSColorTypeComponentBased];

    if (base == nil || space == nil)
        return nil;

    CGColorSpaceRef target = [space CGColorSpace];
    CGColorRef cgColor = [base CGColor];

    if (target == NULL || cgColor == NULL)
        return nil;

    if (CGColorGetColorSpace(cgColor) == target)
        return base;

    size_t targetCount = CGColorSpaceGetNumberOfComponents(target);
    NSColor *rgb = [base colorUsingColorSpaceName: NSCalibratedRGBColorSpace];

    if (rgb == nil)
        return nil;

    CGFloat r, g, b, a;
    [rgb getRed: &r green: &g blue: &b alpha: &a];

    CGFloat components[5];

    if (targetCount == 3) {
        components[0] = r;
        components[1] = g;
        components[2] = b;
        components[3] = a;
    } else if (targetCount == 1) {
        components[0] = 0.299 * r + 0.587 * g + 0.114 * b;
        components[1] = a;
    } else {
        return nil;
    }

    CGColorRef converted = CGColorCreate(target, components);

    if (converted == NULL)
        return nil;

    NSColor *result = [NSColor_CGColor
            colorWithColorRef: converted
                    spaceName: NSColorSpaceNameForComponentCount(
                                       targetCount + 1)];

    CGColorRelease(converted);
    return result;
}

- (NSColor *) blendedWithColor: (NSColor *) other level: (CGFloat) level {
    level = MIN(1.0, MAX(0.0, level));

    if (level == 0.0)
        return self;

    NSColor *base = [self colorUsingColorSpaceName: NSCalibratedRGBColorSpace];

    if (base == nil)
        return nil;

    NSColor *blended = [base blendedColorWithFraction: level ofColor: other];

    if (blended == nil)
        return nil;

    // The blend only changes color, the receiver's opacity is kept.
    return [blended colorWithAlphaComponent: [base alphaComponent]];
}

- (NSColor *) highlightWithLevel: (CGFloat) level {
    return [self blendedWithColor: [NSColor highlightColor] level: level];
}

- (NSColor *) shadowWithLevel: (CGFloat) level {
    return [self blendedWithColor: [NSColor shadowColor] level: level];
}

- (NSColor *) colorWithSystemEffect: (NSColorSystemEffect) systemEffect {
    NSColor *result = nil;

    switch (systemEffect) {
    case NSColorSystemEffectNone:
        return self;
    case NSColorSystemEffectPressed:
        result = [self shadowWithLevel: 0.2];
        break;
    case NSColorSystemEffectDeepPressed:
        result = [self shadowWithLevel: 0.4];
        break;
    case NSColorSystemEffectDisabled: {
        NSColor *rgb = [self colorUsingColorSpaceName: NSCalibratedRGBColorSpace];

        if (rgb != nil)
            result = [rgb colorWithAlphaComponent: [rgb alphaComponent] * 0.5];
        break;
    }
    case NSColorSystemEffectRollover:
        result = [self highlightWithLevel: 0.2];
        break;
    }

    return result != nil ? result : self;
}

- (NSString *) localizedCatalogNameComponent {
    NSString *name = [self catalogNameComponent];

    return [[NSBundle bundleForClass: [NSColor class]]
            localizedStringForKey: name
                            value: name
                            table: @"Colors"];
}

- (NSString *) localizedColorNameComponent {
    NSString *name = [self colorNameComponent];

    return [[NSBundle bundleForClass: [NSColor class]]
            localizedStringForKey: name
                            value: name
                            table: @"Colors"];
}


+ (NSColor *) clearColor {
    return [NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha: 0];
}

+ (NSColor *) blackColor {
    return [NSColor colorWithCalibratedWhite: 0 alpha: 1.0];
}

+ (NSColor *) blueColor {
    return [NSColor colorWithCalibratedRed: 0.0
                                     green: 0.0
                                      blue: 1.0
                                     alpha: 1.0];
}

+ (NSColor *) brownColor {
    return [NSColor colorWithCalibratedRed: 0.6
                                     green: 0.4
                                      blue: 0.2
                                     alpha: 1.0];
}

+ (NSColor *) cyanColor {
    return [NSColor colorWithCalibratedRed: 0.0
                                     green: 1.0
                                      blue: 1.0
                                     alpha: 1.0];
}

+ (NSColor *) darkGrayColor {
    return [NSColor colorWithCalibratedWhite: 1.0 / 3.0 alpha: 1.0];
}

+ (NSColor *) grayColor {
    return [NSColor colorWithCalibratedWhite: 0.5 alpha: 1.0];
}

+ (NSColor *) greenColor {
    return [NSColor colorWithCalibratedRed: 0.0
                                     green: 1.0
                                      blue: 0.0
                                     alpha: 1.0];
}

+ (NSColor *) lightGrayColor {
    return [NSColor colorWithCalibratedWhite: 2.0 / 3.0 alpha: 1.0];
}

+ (NSColor *) magentaColor {
    return [NSColor colorWithCalibratedRed: 1.0
                                     green: 0.0
                                      blue: 1.0
                                     alpha: 1.0];
}

+ (NSColor *) orangeColor {
    return [NSColor colorWithCalibratedRed: 1.0
                                     green: 0.5
                                      blue: 0.0
                                     alpha: 1.0];
}

+ (NSColor *) purpleColor {
    return [NSColor colorWithCalibratedRed: 0.5
                                     green: 0.0
                                      blue: 0.5
                                     alpha: 1.0];
}

+ (NSColor *) redColor {
    return [NSColor colorWithCalibratedRed: 1.0
                                     green: 0.0
                                      blue: 0.0
                                     alpha: 1.0];
}

+ (NSColor *) whiteColor {
    return [NSColor colorWithCalibratedWhite: 1 alpha: 1.0];
}

+ (NSColor *) yellowColor {
    return [NSColor colorWithCalibratedRed: 1.0
                                     green: 1.0
                                      blue: 0.0
                                     alpha: 1.0];
}

+ (NSColor *) colorWithDeviceWhite: (CGFloat) white alpha: (CGFloat) alpha {
    return [NSColor_CGColor colorWithGray: white
                                    alpha: alpha
                                spaceName: NSDeviceWhiteColorSpace];
}

+ (NSColor *) colorWithWhite: (CGFloat) white alpha: (CGFloat) alpha {
    return [self colorWithDeviceWhite: white alpha: alpha];
}

+ (NSColor *) colorWithDeviceRed: (CGFloat) red
                           green: (CGFloat) green
                            blue: (CGFloat) blue
                           alpha: (CGFloat) alpha
{
    return [NSColor_CGColor colorWithRed: red
                                   green: green
                                    blue: blue
                                   alpha: alpha
                               spaceName: NSDeviceRGBColorSpace];
}

+ (NSColor *) colorWithRed: (CGFloat) red
                     green: (CGFloat) green
                      blue: (CGFloat) blue
                     alpha: (CGFloat) alpha
{
    return [NSColor colorWithDeviceRed: red
                                 green: green
                                  blue: blue
                                 alpha: alpha];
}

+ (NSColor *) colorWithSRGBRed: (CGFloat) red
                         green: (CGFloat) green
                          blue: (CGFloat) blue
                         alpha: (CGFloat) alpha
{
    return [NSColor_CGColor colorWithRed: red
                                   green: green
                                    blue: blue
                                   alpha: alpha
                               spaceName: NSNamedColorSpace];
}

+ (NSColor *) colorWithDeviceHue: (CGFloat) hue
                      saturation: (CGFloat) saturation
                      brightness: (CGFloat) brightness
                           alpha: (CGFloat) alpha
{
    return [NSColor_CGColor colorWithHue: hue
                              saturation: saturation
                              brightness: brightness
                                   alpha: alpha
                               spaceName: NSDeviceRGBColorSpace];
}

+ (NSColor *) colorWithDeviceCyan: (CGFloat) cyan
                          magenta: (CGFloat) magenta
                           yellow: (CGFloat) yellow
                            black: (CGFloat) black
                            alpha: (CGFloat) alpha
{
    return [NSColor_CGColor colorWithCyan: cyan
                                  magenta: magenta
                                   yellow: yellow
                                    black: black
                                    alpha: alpha
                                spaceName: NSDeviceCMYKColorSpace];
}

+ (NSColor *) colorWithCalibratedWhite: (CGFloat) white alpha: (CGFloat) alpha {
    return [NSColor_CGColor colorWithGray: white
                                    alpha: alpha
                                spaceName: NSCalibratedWhiteColorSpace];
}

+ (NSColor *) colorWithCalibratedRed: (CGFloat) red
                               green: (CGFloat) green
                                blue: (CGFloat) blue
                               alpha: (CGFloat) alpha
{
    return [NSColor_CGColor colorWithRed: red
                                   green: green
                                    blue: blue
                                   alpha: alpha
                               spaceName: NSCalibratedRGBColorSpace];
}

+ (NSColor *) colorWithCalibratedHue: (CGFloat) hue
                          saturation: (CGFloat) saturation
                          brightness: (CGFloat) brightness
                               alpha: (CGFloat) alpha
{
    return [NSColor_CGColor colorWithHue: hue
                              saturation: saturation
                              brightness: brightness
                                   alpha: alpha
                               spaceName: NSCalibratedRGBColorSpace];
}

+ (NSColor *) colorWithCatalogName: (NSColorListName) catalogName
                         colorName: (NSColorName) colorName
{
    return [NSColor_catalog colorWithCatalogName: catalogName
                                       colorName: colorName];
}

+ (NSColor *) colorWithGenericGamma22White: (CGFloat) white
                                     alpha: (CGFloat) alpha
{
    return [NSColor_CGColor colorWithGray: white
                                    alpha: alpha
                                spaceName: NSCustomColorSpace];
}

+ (NSColor *) colorFromPasteboard: (NSPasteboard *) pasteboard {
    NSData *data = [pasteboard dataForType: NSColorPboardType];

    return [NSKeyedUnarchiver unarchiveObjectWithData: data];
}

static void drawPattern(void *info, CGContextRef cgContext) {
    NSImage *image = (NSImage *) info;
    NSSize size = [image size];
    NSGraphicsContext *context =
            [NSGraphicsContext graphicsContextWithGraphicsPort: cgContext
                                                       flipped: NO];

    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext: context];
    [image drawInRect: NSMakeRect(0, 0, size.width, size.height)
             fromRect: NSZeroRect
            operation: NSCompositeCopy
             fraction: 1.0];
    [NSGraphicsContext restoreGraphicsState];
}

static void releasePatternInfo(void *info) {
    [(NSImage *) info release];
}

+ (NSColor *) colorWithPatternImage: (NSImage *) image {
    NSSize size = [image size];
    CGPatternCallbacks callbacks = {0, drawPattern, releasePatternInfo};
    [image retain];
    CGPatternRef pattern =
            CGPatternCreate(image, CGRectMake(0, 0, size.width, size.height),
                            CGAffineTransformIdentity, size.width, size.height,
                            kCGPatternTilingNoDistortion, YES, &callbacks);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[4] = {1, 1, 1, 1};
    CGColorRef cgColor =
            CGColorCreateWithPattern(colorSpace, pattern, components);

    NSColor *result = [[[NSColor_CGColor alloc]
            initWithColorRef: cgColor
                   spaceName: NSPatternColorSpace] autorelease];

    CGColorRelease(cgColor);
    CGColorSpaceRelease(colorSpace);
    CGPatternRelease(pattern);

    return result;
}

- (NSImage *) patternImage {
    NSInvalidAbstractInvocation();
    return nil;
}

- (NSColorSpaceName) colorSpaceName {
    NSInvalidAbstractInvocation();
    return nil;
}

- (NSInteger) numberOfComponents {
    NSInvalidAbstractInvocation();
    return 0;
}

- (void) getComponents: (CGFloat *) components {
    NSInvalidAbstractInvocation();
}

- (void) getWhite: (CGFloat *) white alpha: (CGFloat *) alpha {
    NSInvalidAbstractInvocation();
}

- (void) getRed: (CGFloat *) red
          green: (CGFloat *) green
           blue: (CGFloat *) blue
          alpha: (CGFloat *) alpha
{
    NSInvalidAbstractInvocation();
}

- (void) getHue: (CGFloat *) hue
        saturation: (CGFloat *) saturation
        brightness: (CGFloat *) brightness
             alpha: (CGFloat *) alpha
{
    NSInvalidAbstractInvocation();
}

- (void) getCyan: (CGFloat *) cyan
         magenta: (CGFloat *) magenta
          yellow: (CGFloat *) yellow
           black: (CGFloat *) black
           alpha: (CGFloat *) alpha
{
    NSInvalidAbstractInvocation();
}

- (CGFloat) whiteComponent {
    CGFloat white;

    [self getWhite: &white alpha: NULL];
    return white;
}

- (CGFloat) redComponent {
    CGFloat red;

    [self getRed: &red green: NULL blue: NULL alpha: NULL];

    return red;
}

- (CGFloat) greenComponent {
    CGFloat green;

    [self getRed: NULL green: &green blue: NULL alpha: NULL];

    return green;
}

- (CGFloat) blueComponent {
    CGFloat blue;

    [self getRed: NULL green: NULL blue: &blue alpha: NULL];

    return blue;
}

- (CGFloat) hueComponent {
    CGFloat hue;

    [self getHue: &hue saturation: NULL brightness: NULL alpha: NULL];

    return hue;
}

- (CGFloat) saturationComponent {
    CGFloat saturation;

    [self getHue: NULL saturation: &saturation brightness: NULL alpha: NULL];

    return saturation;
}

- (CGFloat) brightnessComponent {
    CGFloat brightness;

    [self getHue: NULL saturation: NULL brightness: &brightness alpha: NULL];

    return brightness;
}

- (CGFloat) cyanComponent {
    CGFloat cyan;

    [self getCyan: &cyan magenta: NULL yellow: NULL black: NULL alpha: NULL];
    return cyan;
}

- (CGFloat) magentaComponent {
    CGFloat magenta;

    [self getCyan: NULL magenta: &magenta yellow: NULL black: NULL alpha: NULL];
    return magenta;
}

- (CGFloat) yellowComponent {
    CGFloat yellow;

    [self getCyan: NULL magenta: NULL yellow: &yellow black: NULL alpha: NULL];
    return yellow;
}

- (CGFloat) blackComponent {
    CGFloat black;

    [self getCyan: NULL magenta: NULL yellow: NULL black: &black alpha: NULL];
    return black;
}

- (CGFloat) alphaComponent {
    return 1.0;
}

- (NSColorListName) catalogNameComponent {
    NSInvalidAbstractInvocation();
    return nil;
}

- (NSColorName) colorNameComponent {
    NSInvalidAbstractInvocation();
    return nil;
}

- (CGColorRef) CGColor {
    NSInvalidAbstractInvocation();
    return nil;
}

- (NSColor *) colorWithAlphaComponent: (CGFloat) alpha {
    if (alpha >= 1.0)
        return self;
    return nil;
}

- (NSColor *) colorUsingColorSpaceName: (NSColorSpaceName) colorSpace {
    NSInvalidAbstractInvocation();
    return nil;
}

- (NSColor *) colorUsingColorSpaceName: (NSColorSpaceName) colorSpace
                                device: (NSDictionary<NSString *,id> *) device
{
    NSInvalidAbstractInvocation();
    return nil;
}

- (NSColor *) blendedColorWithFraction: (CGFloat) fraction
                               ofColor: (NSColor *) color
{
    NSColor *primary =
            [color colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
    NSColor *secondary =
            [self colorUsingColorSpaceName: NSCalibratedRGBColorSpace];

    if (primary == nil || secondary == nil)
        return nil;
    else {
        CGFloat pr, pg, pb, pa;
        CGFloat sr, sg, sb, sa;
        CGFloat rr, rg, rb, ra;

        [primary getRed: &pr green: &pg blue: &pb alpha: &pa];
        [secondary getRed: &sr green: &sg blue: &sb alpha: &sa];

        rr = pr * fraction + sr * (1 - fraction);
        rg = pg * fraction + sg * (1 - fraction);
        rb = pb * fraction + sb * (1 - fraction);
        ra = pa * fraction + sa * (1 - fraction);

        return [NSColor colorWithCalibratedRed: rr
                                         green: rg
                                          blue: rb
                                         alpha: ra];
    }
}

- (void) set {
    [self setStroke];
    [self setFill];
}

- (void) setFill {
    NSInvalidAbstractInvocation();
}

- (void) setStroke {
    NSInvalidAbstractInvocation();
}

- (void) drawSwatchInRect: (NSRect) rect {
    // Draw some B&W triangle background so we can see the color alpha component
    [[NSColor whiteColor] setFill];
    NSRectFill(rect);
    [[NSColor blackColor] setFill];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint: NSMakePoint(NSMinX(rect), NSMaxY(rect))];
    [path lineToPoint: NSMakePoint(NSMaxX(rect), NSMaxY(rect))];
    [path lineToPoint: NSMakePoint(NSMinX(rect), NSMinY(rect))];
    [path closePath];
    [path fill];

    [self setFill];
    NSRectFillUsingOperation(rect, NSCompositeSourceOver);
}

- (void) writeToPasteboard: (NSPasteboard *) pasteboard {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: self];

    [pasteboard setData: data forType: NSColorPboardType];
}

+ (void) setIgnoresAlpha: (BOOL) ignores {
    NSColor_ignoresAlpha = ignores;
}

// TODO: Affects NSColorPanel, NSColorSwatch and NSColorPickerTouchBarItem
+ (BOOL) ignoresAlpha {
    if (NSColor_ignoresAlpha == -1) {
        @synchronized(self) {
            if (NSColor_ignoresAlpha == -1)
                NSColor_ignoresAlpha =
                        [[[NSUserDefaults standardUserDefaults]
                                objectForKey: @"NSIgnoreAlpha"]
                                compare: @"NO"
                                options: NSCaseInsensitiveSearch] !=
                        NSOrderedSame;
        }
    }

    return NSColor_ignoresAlpha;
}

@end
