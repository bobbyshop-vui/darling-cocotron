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

#import <AppKit/AppKitExport.h>
#import <Foundation/Foundation.h>

typedef NSString *NSTouchBarItemIdentifier;

APPKIT_EXPORT NSTouchBarItemIdentifier const
        NSTouchBarItemIdentifierFixedSpaceLarge;
APPKIT_EXPORT NSTouchBarItemIdentifier const
        NSTouchBarItemIdentifierFixedSpaceSmall;
APPKIT_EXPORT NSTouchBarItemIdentifier const
        NSTouchBarItemIdentifierFlexibleSpace;
APPKIT_EXPORT NSTouchBarItemIdentifier const
        NSTouchBarItemIdentifierOtherItemsProxy;

typedef float NSTouchBarItemPriority;
static const NSTouchBarItemPriority NSTouchBarItemPriorityHigh = 1000;
static const NSTouchBarItemPriority NSTouchBarItemPriorityNormal = 0;
static const NSTouchBarItemPriority NSTouchBarItemPriorityLow = -1000;

@class NSView, NSViewController, NSImage, NSColor, NSColorList, NSColorSpace;
@class NSSlider, NSSliderAccessory;
@protocol NSSharingServicePickerTouchBarItemDelegate;

@interface NSTouchBarItem : NSObject <NSCoding> {
    NSTouchBarItemIdentifier _identifier;
    NSTouchBarItemPriority _visibilityPriority;
    NSInteger _visibilityCount;
}

- (instancetype)initWithIdentifier:(NSTouchBarItemIdentifier)identifier;
- (instancetype)initWithCoder:(NSCoder *)coder;
- (NSTouchBarItemIdentifier)identifier;
- (NSTouchBarItemPriority)visibilityPriority;
- (void)setVisibilityPriority:(NSTouchBarItemPriority)priority;
- (NSView *)view;
- (NSViewController *)viewController;
- (NSString *)customizationLabel;
- (BOOL)isVisible;
@end

@interface NSColorPickerTouchBarItem : NSTouchBarItem {
    NSString *_customizationLabel;
    NSColor *_color;
    id _target;
    SEL _action;
    NSImage *_buttonImage;
    NSColorList *_colorList;
    NSArray *_allowedColorSpaces;
    BOOL _showsAlpha;
    BOOL _enabled;
}
+ (instancetype)colorPickerWithIdentifier:(NSTouchBarItemIdentifier)identifier;
+ (instancetype)textColorPickerWithIdentifier:(NSTouchBarItemIdentifier)identifier;
+ (instancetype)strokeColorPickerWithIdentifier:(NSTouchBarItemIdentifier)identifier;
+ (instancetype)colorPickerWithIdentifier:(NSTouchBarItemIdentifier)identifier buttonImage:(NSImage *)image;
- (NSColor *)color;
- (void)setColor:(NSColor *)color;
- (BOOL)showsAlpha;
- (void)setShowsAlpha:(BOOL)showsAlpha;
- (NSArray *)allowedColorSpaces;
- (void)setAllowedColorSpaces:(NSArray *)spaces;
- (NSColorList *)colorList;
- (void)setColorList:(NSColorList *)colorList;
- (NSString *)customizationLabel;
- (void)setCustomizationLabel:(NSString *)label;
- (id)target;
- (void)setTarget:(id)target;
- (SEL)action;
- (void)setAction:(SEL)action;
- (BOOL)isEnabled;
- (void)setEnabled:(BOOL)enabled;
@end

@interface NSSharingServicePickerTouchBarItem : NSTouchBarItem {
    NSString *_customizationLabel;
    id<NSSharingServicePickerTouchBarItemDelegate> _delegate;
    BOOL _enabled;
    NSString *_buttonTitle;
    NSImage *_buttonImage;
}
- (id<NSSharingServicePickerTouchBarItemDelegate>)delegate;
- (void)setDelegate:(id<NSSharingServicePickerTouchBarItemDelegate>)delegate;
- (BOOL)isEnabled;
- (void)setEnabled:(BOOL)enabled;
- (NSString *)buttonTitle;
- (void)setButtonTitle:(NSString *)title;
- (NSImage *)buttonImage;
- (void)setButtonImage:(NSImage *)image;
@end

@interface NSSliderTouchBarItem : NSTouchBarItem {
    NSSlider *_slider;
    NSString *_label;
    NSSliderAccessory *_minimumValueAccessory;
    NSSliderAccessory *_maximumValueAccessory;
    CGFloat _valueAccessoryWidth;
    id _target;
    SEL _action;
    NSString *_customizationLabel;
}
- (NSView *)view;
- (NSSlider *)slider;
- (void)setSlider:(NSSlider *)slider;
- (NSString *)label;
- (void)setLabel:(NSString *)label;
- (NSSliderAccessory *)minimumValueAccessory;
- (void)setMinimumValueAccessory:(NSSliderAccessory *)accessory;
- (NSSliderAccessory *)maximumValueAccessory;
- (void)setMaximumValueAccessory:(NSSliderAccessory *)accessory;
- (CGFloat)valueAccessoryWidth;
- (void)setValueAccessoryWidth:(CGFloat)width;
- (id)target;
- (void)setTarget:(id)target;
- (SEL)action;
- (void)setAction:(SEL)action;
- (NSString *)customizationLabel;
- (void)setCustomizationLabel:(NSString *)label;
@end
