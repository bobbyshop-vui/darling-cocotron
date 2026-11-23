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

#import <AppKit/NSTouchBarItem.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSColorList.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSSlider.h>
#import <AppKit/NSView.h>
#import <AppKit/NSViewController.h>

NSTouchBarItemIdentifier const NSTouchBarItemIdentifierFixedSpaceLarge =
        @"NSTouchBarItemIdentifierFixedSpaceLarge";
NSTouchBarItemIdentifier const NSTouchBarItemIdentifierFixedSpaceSmall =
        @"NSTouchBarItemIdentifierFixedSpaceSmall";
NSTouchBarItemIdentifier const NSTouchBarItemIdentifierFlexibleSpace =
        @"NSTouchBarItemIdentifierFlexibleSpace";
NSTouchBarItemIdentifier const NSTouchBarItemIdentifierOtherItemsProxy =
        @"NSTouchBarItemIdentifierOtherItemsProxy";
NSTouchBarItemIdentifier const NSTouchBarItemIdentifierCharacterPicker =
        @"NSTouchBarItemIdentifierCharacterPicker";


@implementation NSTouchBarItem

- (instancetype)initWithIdentifier:(NSTouchBarItemIdentifier)identifier
{
    if ((self = [super init])) {
        _identifier = [identifier copy];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if ((self = [super init])) {
        if ([coder allowsKeyedCoding]) {
            _identifier = [[coder decodeObjectForKey:@"NSTouchBarItemIdentifier"] copy];
            if ([coder containsValueForKey:@"NSTouchBarItemVisibilityPriority"])
                _visibilityPriority = [coder decodeFloatForKey:@"NSTouchBarItemVisibilityPriority"];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if ([coder allowsKeyedCoding]) {
        [coder encodeObject:_identifier forKey:@"NSTouchBarItemIdentifier"];
        [coder encodeFloat:_visibilityPriority forKey:@"NSTouchBarItemVisibilityPriority"];
    }
}

- (void)dealloc
{
    [_identifier release];
    [super dealloc];
}

- (NSTouchBarItemIdentifier)identifier
{
    return _identifier;
}

- (NSTouchBarItemPriority)visibilityPriority
{
    return _visibilityPriority;
}

- (void)setVisibilityPriority:(NSTouchBarItemPriority)priority
{
    _visibilityPriority = priority;
}

- (NSViewController *)viewController
{
    return nil;
}

- (NSView *)view
{
    return [[self viewController] view];
}

- (NSString *)customizationLabel
{
    return @"";
}

- (BOOL)isVisible
{
    // There is no Touch Bar hardware, so an item is never displayed.
    return _visibilityCount > 0;
}

@end

@implementation NSColorPickerTouchBarItem

+ (instancetype)colorPickerWithIdentifier:(NSTouchBarItemIdentifier)identifier
{
    return [[[self alloc] initWithIdentifier:identifier] autorelease];
}

+ (instancetype)textColorPickerWithIdentifier:(NSTouchBarItemIdentifier)identifier
{
    NSColorPickerTouchBarItem *item = [self colorPickerWithIdentifier:identifier];
    [item setColor:[NSColor blackColor]];
    return item;
}

+ (instancetype)strokeColorPickerWithIdentifier:(NSTouchBarItemIdentifier)identifier
{
    NSColorPickerTouchBarItem *item = [self colorPickerWithIdentifier:identifier];
    [item setColor:[NSColor blackColor]];
    return item;
}

+ (instancetype)colorPickerWithIdentifier:(NSTouchBarItemIdentifier)identifier buttonImage:(NSImage *)image
{
    NSColorPickerTouchBarItem *item = [self colorPickerWithIdentifier:identifier];
    item->_buttonImage = [image retain];
    return item;
}

- (instancetype)initWithIdentifier:(NSTouchBarItemIdentifier)identifier
{
    if ((self = [super initWithIdentifier:identifier])) {
        _color = [[NSColor blackColor] retain];
        _showsAlpha = NO;
        _enabled = YES;
    }
    return self;
}

- (void)dealloc
{
    [_customizationLabel release];
    [_color release];
    [_buttonImage release];
    [_colorList release];
    [_allowedColorSpaces release];
    [super dealloc];
}

- (NSColor *)color
{
    return _color;
}

- (void)setColor:(NSColor *)color
{
    NSColor *copy = [color copy];
    [_color release];
    _color = copy;
}

- (BOOL)showsAlpha
{
    return _showsAlpha;
}

- (void)setShowsAlpha:(BOOL)showsAlpha
{
    _showsAlpha = showsAlpha;
}

- (NSArray *)allowedColorSpaces
{
    return _allowedColorSpaces;
}

- (void)setAllowedColorSpaces:(NSArray *)spaces
{
    NSArray *copy = [spaces copy];
    [_allowedColorSpaces release];
    _allowedColorSpaces = copy;
}

- (NSColorList *)colorList
{
    if (_colorList == nil) {
        // null_resettable: the default list is a fresh, empty one.
        _colorList = [[NSColorList alloc] initWithName:@"Touch Bar Colors"];
    }
    return _colorList;
}

- (void)setColorList:(NSColorList *)colorList
{
    [colorList retain];
    [_colorList release];
    _colorList = colorList;
}

- (NSString *)customizationLabel
{
    return _customizationLabel != nil ? _customizationLabel : @"";
}

- (void)setCustomizationLabel:(NSString *)label
{
    NSString *copy = [label copy];
    [_customizationLabel release];
    _customizationLabel = copy;
}

- (id)target
{
    return _target;
}

- (void)setTarget:(id)target
{
    _target = target;
}

- (SEL)action
{
    return _action;
}

- (void)setAction:(SEL)action
{
    _action = action;
}

- (BOOL)isEnabled
{
    return _enabled;
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
}

@end

@implementation NSSharingServicePickerTouchBarItem

- (instancetype)initWithIdentifier:(NSTouchBarItemIdentifier)identifier
{
    if ((self = [super initWithIdentifier:identifier])) {
        _enabled = YES;
        _buttonTitle = @"";
    }
    return self;
}

- (void)dealloc
{
    [_customizationLabel release];
    [_buttonTitle release];
    [_buttonImage release];
    [super dealloc];
}

- (id<NSSharingServicePickerTouchBarItemDelegate>)delegate
{
    return _delegate;
}

- (void)setDelegate:(id<NSSharingServicePickerTouchBarItemDelegate>)delegate
{
    _delegate = delegate;
}

- (BOOL)isEnabled
{
    return _enabled;
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
}

- (NSString *)buttonTitle
{
    return _buttonTitle;
}

- (void)setButtonTitle:(NSString *)title
{
    NSString *copy = [(title != nil ? title : @"") copy];
    [_buttonTitle release];
    _buttonTitle = copy;
}

- (NSImage *)buttonImage
{
    return _buttonImage;
}

- (void)setButtonImage:(NSImage *)image
{
    [image retain];
    [_buttonImage release];
    _buttonImage = image;
}

@end

@implementation NSSliderTouchBarItem

- (instancetype)initWithIdentifier:(NSTouchBarItemIdentifier)identifier
{
    if ((self = [super initWithIdentifier:identifier])) {
        _slider = [[NSSlider alloc] initWithFrame:NSMakeRect(0, 0, 150, 30)];
        _valueAccessoryWidth = 0;
    }
    return self;
}

- (void)dealloc
{
    [_slider release];
    [_label release];
    [_minimumValueAccessory release];
    [_maximumValueAccessory release];
    [_customizationLabel release];
    [super dealloc];
}

- (NSView *)view
{
    return _slider;
}

- (NSSlider *)slider
{
    return _slider;
}

- (void)setSlider:(NSSlider *)slider
{
    [slider retain];
    [_slider release];
    _slider = slider;
}

- (NSString *)label
{
    return _label;
}

- (void)setLabel:(NSString *)label
{
    NSString *copy = [label copy];
    [_label release];
    _label = copy;
}

- (NSSliderAccessory *)minimumValueAccessory
{
    return _minimumValueAccessory;
}

- (void)setMinimumValueAccessory:(NSSliderAccessory *)accessory
{
    [accessory retain];
    [_minimumValueAccessory release];
    _minimumValueAccessory = accessory;
}

- (NSSliderAccessory *)maximumValueAccessory
{
    return _maximumValueAccessory;
}

- (void)setMaximumValueAccessory:(NSSliderAccessory *)accessory
{
    [accessory retain];
    [_maximumValueAccessory release];
    _maximumValueAccessory = accessory;
}

- (CGFloat)valueAccessoryWidth
{
    return _valueAccessoryWidth;
}

- (void)setValueAccessoryWidth:(CGFloat)width
{
    _valueAccessoryWidth = width;
}

- (id)target
{
    return _target;
}

- (void)setTarget:(id)target
{
    _target = target;
    [_slider setTarget:target];
}

- (SEL)action
{
    return _action;
}

- (void)setAction:(SEL)action
{
    _action = action;
    [_slider setAction:action];
}

- (NSString *)customizationLabel
{
    return _customizationLabel != nil ? _customizationLabel : @"";
}

- (void)setCustomizationLabel:(NSString *)label
{
    NSString *copy = [label copy];
    [_customizationLabel release];
    _customizationLabel = copy;
}

@end
