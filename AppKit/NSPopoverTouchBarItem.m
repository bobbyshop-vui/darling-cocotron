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

#import <AppKit/NSPopoverTouchBarItem.h>
#import <AppKit/NSButton.h>
#import <AppKit/NSGestureRecognizer.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSTouchBar.h>
#import <AppKit/NSView.h>

@implementation NSPopoverTouchBarItem

- (void) dealloc {
    [_popoverTouchBar release];
    [_pressAndHoldTouchBar release];
    [_popoverCustomizationLabel release];
    [_collapsedRepresentation release];
    [_collapsedRepresentationImage release];
    [_collapsedRepresentationLabel release];
    [super dealloc];
}

- (NSTouchBar *) popoverTouchBar {
    if (_popoverTouchBar == nil) {
        // The default is an empty bar
        _popoverTouchBar = [[NSTouchBar alloc] init];
    }
    return _popoverTouchBar;
}

- (void) setPopoverTouchBar: (NSTouchBar *) touchBar {
    [touchBar retain];
    [_popoverTouchBar release];
    _popoverTouchBar = touchBar;
}

- (NSTouchBar *) pressAndHoldTouchBar {
    return _pressAndHoldTouchBar;
}

- (void) setPressAndHoldTouchBar: (NSTouchBar *) touchBar {
    [touchBar retain];
    [_pressAndHoldTouchBar release];
    _pressAndHoldTouchBar = touchBar;
}

- (NSString *) customizationLabel {
    return _popoverCustomizationLabel != nil ? _popoverCustomizationLabel : @"";
}

- (void) setCustomizationLabel: (NSString *) label {
    NSString *copy = [label copy];
    [_popoverCustomizationLabel release];
    _popoverCustomizationLabel = copy;
}

- (NSView *) collapsedRepresentation {
    if (_collapsedRepresentation == nil) {
        NSButton *button = [[NSButton alloc] initWithFrame: NSMakeRect(0, 0, 64, 30)];
        [button setTarget: self];
        [button setAction: @selector(showPopover:)];
        [button setTitle: [self collapsedRepresentationLabel]];
        [button setImage: _collapsedRepresentationImage];
        _collapsedRepresentation = button;
    }
    return _collapsedRepresentation;
}

- (void) setCollapsedRepresentation: (NSView *) view {
    [view retain];
    [_collapsedRepresentation release];
    _collapsedRepresentation = view;
}

- (NSView *) view {
    return [self collapsedRepresentation];
}

- (NSImage *) collapsedRepresentationImage {
    return _collapsedRepresentationImage;
}

- (void) setCollapsedRepresentationImage: (NSImage *) image {
    [image retain];
    [_collapsedRepresentationImage release];
    _collapsedRepresentationImage = image;
    if ([_collapsedRepresentation isKindOfClass: [NSButton class]]) {
        [(NSButton *) _collapsedRepresentation setImage: image];
    }
}

- (NSString *) collapsedRepresentationLabel {
    return _collapsedRepresentationLabel != nil ? _collapsedRepresentationLabel : @"";
}

- (void) setCollapsedRepresentationLabel: (NSString *) label {
    NSString *copy = [label copy];
    [_collapsedRepresentationLabel release];
    _collapsedRepresentationLabel = copy;
    if ([_collapsedRepresentation isKindOfClass: [NSButton class]]) {
        [(NSButton *) _collapsedRepresentation
                setTitle: [self collapsedRepresentationLabel]];
    }
}

- (BOOL) showsCloseButton {
    return _showsCloseButton;
}

- (void) setShowsCloseButton: (BOOL) flag {
    _showsCloseButton = flag;
}

- (void) showPopover: (id) sender {
    _popoverShown = YES;
}

- (void) dismissPopover: (id) sender {
    _popoverShown = NO;
}

- (NSGestureRecognizer *) makeStandardActivatePopoverGestureRecognizer {
    NSGestureRecognizer *recognizer =
            [[NSGestureRecognizer alloc] initWithTarget: self
                                                 action: @selector(showPopover:)];
    return [recognizer autorelease];
}

@end
