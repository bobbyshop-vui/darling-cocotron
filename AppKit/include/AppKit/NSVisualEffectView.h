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

#import <AppKit/NSView.h>
#import <AppKit/NSCell.h>

@class NSImage;

typedef NS_ENUM(NSInteger, NSVisualEffectMaterial) {
    NSVisualEffectMaterialTitlebar = 3,
    NSVisualEffectMaterialSelection = 4,
    NSVisualEffectMaterialMenu = 5,
    NSVisualEffectMaterialPopover = 6,
    NSVisualEffectMaterialSidebar = 7,
    NSVisualEffectMaterialHeaderView = 10,
    NSVisualEffectMaterialSheet = 11,
    NSVisualEffectMaterialWindowBackground = 12,
    NSVisualEffectMaterialHUDWindow = 13,
    NSVisualEffectMaterialFullScreenUI = 15,
    NSVisualEffectMaterialToolTip = 17,
    NSVisualEffectMaterialContentBackground = 18,
    NSVisualEffectMaterialUnderWindowBackground = 21,
    NSVisualEffectMaterialUnderPageBackground = 22,
    NSVisualEffectMaterialAppearanceBased = 0,
    NSVisualEffectMaterialLight = 1,
    NSVisualEffectMaterialDark = 2,
    NSVisualEffectMaterialMediumLight = 8,
    NSVisualEffectMaterialUltraDark = 9,
};

typedef NS_ENUM(NSInteger, NSVisualEffectBlendingMode) {
    NSVisualEffectBlendingModeBehindWindow,
    NSVisualEffectBlendingModeWithinWindow,
};

typedef NS_ENUM(NSInteger, NSVisualEffectState) {
    NSVisualEffectStateFollowsWindowActiveState,
    NSVisualEffectStateActive,
    NSVisualEffectStateInactive,
};

@interface NSVisualEffectView : NSView {
    NSVisualEffectMaterial _vevMaterial;
    NSVisualEffectBlendingMode _vevBlendingMode;
    NSVisualEffectState _vevState;
    NSImage *_vevMaskImage;
    BOOL _vevEmphasized;
}

- (NSVisualEffectMaterial) material;
- (void) setMaterial: (NSVisualEffectMaterial) value;
- (NSBackgroundStyle) interiorBackgroundStyle;
- (NSVisualEffectBlendingMode) blendingMode;
- (void) setBlendingMode: (NSVisualEffectBlendingMode) value;
- (NSVisualEffectState) state;
- (void) setState: (NSVisualEffectState) value;
- (NSImage *) maskImage;
- (void) setMaskImage: (NSImage *) value;
- (BOOL) isEmphasized;
- (void) setEmphasized: (BOOL) value;

@end
