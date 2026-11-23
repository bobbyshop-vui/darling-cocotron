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

#import <AppKit/NSVisualEffectView.h>
#import <AppKit/NSImage.h>

@implementation NSVisualEffectView

- (void) dealloc {
    [_vevMaskImage release];
    [super dealloc];
}

- (NSVisualEffectMaterial) material {
    return _vevMaterial;
}

- (void) setMaterial: (NSVisualEffectMaterial) value {
    if (_vevMaterial != value) {
        _vevMaterial = value;
        [self setNeedsDisplay: YES];
    }
}

- (NSBackgroundStyle) interiorBackgroundStyle {
    switch (_vevMaterial) {
    case NSVisualEffectMaterialDark:
    case NSVisualEffectMaterialUltraDark:
    case NSVisualEffectMaterialHUDWindow:
    case NSVisualEffectMaterialFullScreenUI:
    case NSVisualEffectMaterialToolTip:
        return NSBackgroundStyleDark;
    default:
        return NSBackgroundStyleLight;
    }
}

- (NSVisualEffectBlendingMode) blendingMode {
    return _vevBlendingMode;
}

- (void) setBlendingMode: (NSVisualEffectBlendingMode) value {
    if (_vevBlendingMode != value) {
        _vevBlendingMode = value;
        [self setNeedsDisplay: YES];
    }
}

- (NSVisualEffectState) state {
    return _vevState;
}

- (void) setState: (NSVisualEffectState) value {
    if (_vevState != value) {
        _vevState = value;
        [self setNeedsDisplay: YES];
    }
}

- (NSImage *) maskImage {
    return _vevMaskImage;
}

- (void) setMaskImage: (NSImage *) value {
    value = [value retain];
    [_vevMaskImage release];
    _vevMaskImage = value;
    [self setNeedsDisplay: YES];
}

- (BOOL) isEmphasized {
    return _vevEmphasized;
}

- (void) setEmphasized: (BOOL) value {
    if (_vevEmphasized != value) {
        _vevEmphasized = value;
        [self setNeedsDisplay: YES];
    }
}

@end
