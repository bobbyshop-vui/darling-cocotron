/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

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

#import <AppKit/NSColor_CGColor.h>
#import <AppKit/NSColor_catalog.h>
#import <AppKit/NSDisplay.h>
#import <AppKit/NSGraphics.h>

@interface NSColor (NSAppKitPrivate)
- (CGColorRef) CGColorRef;
@end

void NSColorSetCatalogColor(NSColorListName catalogName, NSColorName colorName,
                            NSColor *color);
NSColor *NSColorGetCatalogColor(NSColorListName catalogName,
                                NSColorName colorName);

@implementation NSColor_catalog

- initWithCatalogName: (NSColorListName) catalogName
            colorName: (NSColorName) colorName
                color: (NSColor *) color
{
    _catalogName = [catalogName copy];
    _colorName = [colorName copy];
    _color = [color copy];
    return self;
}

- (void) dealloc {
    [_colorName release];
    [_catalogName release];
    [_color release];
    NSDeallocateObject(self);
    return;
    [super dealloc];
}

- (BOOL) isEqual: otherObject {
    if (self == otherObject)
        return YES;

    if ([otherObject isKindOfClass: [self class]]) {
        NSColor_catalog *other = otherObject;

        return ([_catalogName isEqualToString: other->_catalogName] &&
                [_colorName isEqualToString: other->_colorName]);
    }

    return NO;
}

- (NSString *) description {
    return [NSString stringWithFormat: @"<%@ catalogName: %@ colorName: %@>",
                                       [[self class] description], _catalogName,
                                       _colorName];
}

+ (NSColor *) colorWithCatalogName: (NSColorListName) catalogName
                         colorName: (NSColorName) colorName
{
    NSColor *color = NSColorGetCatalogColor(catalogName, colorName);

    if (color == nil)
        color = [[NSDisplay currentDisplay] colorWithName: colorName];

    return [[[self alloc] initWithCatalogName: catalogName
                                    colorName: colorName
                                        color: color] autorelease];
}

+ (NSColor *) colorWithCatalogName: (NSColorListName) catalogName
                         colorName: (NSColorName) colorName
                             color: (NSColor *) color
{
    if (NSColorGetCatalogColor(catalogName, colorName) == nil)
        NSColorSetCatalogColor(catalogName, colorName, color);

    return [[[self alloc] initWithCatalogName: catalogName
                                    colorName: colorName
                                        color: color] autorelease];
}

- (NSColorSpaceName) colorSpaceName {
    return NSNamedColorSpace;
}

- (NSColorListName) catalogNameComponent {
    return _catalogName;
}

- (NSColorName) colorNameComponent {
    return _colorName;
}

- (NSImage *) patternImage {
    return [_color patternImage];
}

- (CGColorRef) CGColor {
    if (_color != nil)
        return [_color CGColor];

    return nil;
}

- (NSColor *) colorUsingColorSpaceName: (NSColorSpaceName) colorSpace {
    return [self colorUsingColorSpaceName: colorSpace device: nil];
}

- (NSColor *) colorUsingColorSpaceName: (NSColorSpaceName) colorSpace
                                device: (NSDictionary *) device
{
    if (colorSpace == nil || [colorSpace isEqualToString: [self colorSpaceName]])
        return self;

    return [_color colorUsingColorSpaceName: colorSpace device: device];
}

- (NSInteger) numberOfComponents {
    return [_color numberOfComponents];
}

- (void) getComponents: (CGFloat *) components {
    [_color getComponents: components];
}

- (CGFloat) alphaComponent {
    return [_color alphaComponent];
}

- (NSColor *) colorWithAlphaComponent: (CGFloat) alpha {
    return [_color colorWithAlphaComponent: alpha];
}

- (void) getWhite: (CGFloat *) white alpha: (CGFloat *) alpha {
    [[_color colorUsingColorSpaceName: NSCalibratedWhiteColorSpace]
            getWhite: white
               alpha: alpha];
}

- (void) getRed: (CGFloat *) red
          green: (CGFloat *) green
           blue: (CGFloat *) blue
          alpha: (CGFloat *) alpha
{
    [[_color colorUsingColorSpaceName: NSCalibratedRGBColorSpace] getRed: red
                                                                   green: green
                                                                    blue: blue
                                                                   alpha: alpha];
}

- (void) getHue: (CGFloat *) hue
        saturation: (CGFloat *) saturation
        brightness: (CGFloat *) brightness
             alpha: (CGFloat *) alpha
{
    [[_color colorUsingColorSpaceName: NSCalibratedRGBColorSpace]
            getHue: hue
        saturation: saturation
        brightness: brightness
             alpha: alpha];
}

- (void) getCyan: (CGFloat *) cyan
         magenta: (CGFloat *) magenta
          yellow: (CGFloat *) yellow
           black: (CGFloat *) black
           alpha: (CGFloat *) alpha
{
    [[_color colorUsingColorSpaceName: NSDeviceCMYKColorSpace]
            getCyan: cyan
            magenta: magenta
             yellow: yellow
              black: black
              alpha: alpha];
}

- (NSColor *) blendedColorWithFraction: (CGFloat) fraction
                               ofColor: (NSColor *) color
{
    return [_color blendedColorWithFraction: fraction ofColor: color];
}

- (NSColor *) highlightWithLevel: (CGFloat) level {
    return [_color highlightWithLevel: level];
}

- (NSColor *) shadowWithLevel: (CGFloat) level {
    return [_color shadowWithLevel: level];
}

- (CGColorRef) CGColorRef {
    return [self CGColor];
}

- (void) setFill {
    [_color setFill];
}

- (void) setStroke {
    [_color setStroke];
}

@end
