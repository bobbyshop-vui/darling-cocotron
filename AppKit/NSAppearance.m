/*
 This file is part of Darling.

 Copyright (C) 2019 Lubos Dolezel

 Darling is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 Darling is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Darling.  If not, see <http://www.gnu.org/licenses/>.
*/

#import <AppKit/NSAppearance.h>

NSString *const NSAppearanceNameAqua = @"NSAppearanceNameAqua";
NSString *const NSAppearanceNameDarkAqua = @"NSAppearanceNameDarkAqua";
NSString *const NSAppearanceNameSystem = @"NSAppearanceNameSystem";
NSString *const NSAppearanceNameTouchBar = @"NSAppearanceNameTouchBar";
NSString *const NSAppearanceNameLightContent = @"NSAppearanceNameLightContent";
NSString *const NSAppearanceNameVibrantDark = @"NSAppearanceNameVibrantDark";
NSString *const NSAppearanceNameVibrantLight = @"NSAppearanceNameVibrantLight";
NSString *const NSAppearanceNameAccessibilityHighContrastAqua =
        @"NSAppearanceNameAccessibilityAqua";
NSString *const NSAppearanceNameAccessibilityHighContrastDarkAqua =
        @"NSAppearanceNameAccessibilityDarkAqua";
NSString *const NSAppearanceNameAccessibilityHighContrastSystem =
        @"NSAppearanceNameAccessibilityHighContrastSystem";
NSString *const NSAppearanceNameAccessibilityHighContrastVibrantLight =
        @"NSAppearanceNameAccessibilityVibrantLight";
NSString *const NSAppearanceNameAccessibilityHighContrastVibrantDark =
        @"NSAppearanceNameAccessibilityVibrantDark";

NSString *const NSAppearanceNameControlStrip =
        @"NSAppearanceNameControlStrip"; // Undocumented

@implementation NSAppearance

static NSAppearance *_currentAppearance = nil;
static NSMutableDictionary *_namedAppearances = nil;

+ (NSAppearance *) currentAppearance {
    @synchronized(self) {
        if (_currentAppearance == nil)
            return [self appearanceNamed: NSAppearanceNameAqua];
        return _currentAppearance;
    }
}

+ (void) setCurrentAppearance: (NSAppearance *) appearance {
    @synchronized(self) {
        if (appearance != _currentAppearance) {
            [_currentAppearance release];
            _currentAppearance = [appearance retain];
        }
    }
}

+ (NSAppearance *) appearanceNamed: (NSAppearanceName) name {
    if (name == nil)
        return nil;

    @synchronized(self) {
        NSAppearance *result = [_namedAppearances objectForKey: name];

        if (result == nil) {
            result = [[[NSAppearance alloc] init] autorelease];
            result->_name = [name copy];

            if (_namedAppearances == nil)
                _namedAppearances = [[NSMutableDictionary alloc] init];
            [_namedAppearances setObject: result forKey: name];
        }
        return result;
    }
}

- (void) dealloc {
    [_name release];
    [super dealloc];
}

- (NSAppearanceName) name {
    return _name;
}

- (BOOL) allowsVibrancy {
    return [_name isEqualToString: NSAppearanceNameVibrantDark] ||
           [_name isEqualToString: NSAppearanceNameVibrantLight] ||
           [_name isEqualToString:
                          NSAppearanceNameAccessibilityHighContrastVibrantDark] ||
           [_name isEqualToString:
                          NSAppearanceNameAccessibilityHighContrastVibrantLight];
}

// The appearance an appearance falls back to when it is not offered.
static NSAppearanceName fallbackForAppearanceName(NSAppearanceName name) {
    if ([name isEqualToString: NSAppearanceNameAccessibilityHighContrastAqua] ||
        [name isEqualToString: NSAppearanceNameDarkAqua] ||
        [name isEqualToString: NSAppearanceNameVibrantLight] ||
        [name isEqualToString: NSAppearanceNameLightContent])
        return NSAppearanceNameAqua;
    if ([name isEqualToString:
                      NSAppearanceNameAccessibilityHighContrastDarkAqua] ||
        [name isEqualToString: NSAppearanceNameVibrantDark])
        return NSAppearanceNameDarkAqua;
    if ([name isEqualToString:
                      NSAppearanceNameAccessibilityHighContrastVibrantLight])
        return NSAppearanceNameVibrantLight;
    if ([name isEqualToString:
                      NSAppearanceNameAccessibilityHighContrastVibrantDark])
        return NSAppearanceNameVibrantDark;
    return nil;
}

- (NSAppearanceName) bestMatchFromAppearancesWithNames:
        (NSArray *) appearances
{
    NSAppearanceName name = _name;

    while (name != nil) {
        if ([appearances containsObject: name])
            return name;
        name = fallbackForAppearanceName(name);
    }
    return nil;
}

- (void) encodeWithCoder: (NSCoder *) aCoder {
    if ([aCoder allowsKeyedCoding])
        [aCoder encodeObject: _name forKey: @"NSName"];
}

- (id) initWithCoder: (NSCoder *) aDecoder {
    NSString *name = nil;

    if ([aDecoder allowsKeyedCoding])
        name = [aDecoder decodeObjectForKey: @"NSName"];

    [self release];
    return [[NSAppearance appearanceNamed: name ?: NSAppearanceNameAqua] retain];
}

+ (BOOL) supportsSecureCoding {
    return YES;
}

@end
