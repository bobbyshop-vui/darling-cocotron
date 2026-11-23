/*
 This file is part of Darling.

 Copyright (C) 2026 Darling Developers

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

/*
 * AppKit classes that Xcode 10.0 requires but that Cocotron's AppKit does not
 * implement yet.
 *
 * These are not merely "nice to have": a client binary refers to every
 * `_OBJC_CLASS_$_<Name>` symbol through a non-lazy bind, so if AppKit does not
 * export the class then dyld refuses to load the client image at all with
 *
 *     Symbol not found: _OBJC_CLASS_$_<Name>
 *     Expected in: /System/Library/Frameworks/AppKit.framework/.../AppKit
 *
 * That is exactly what stopped Xcode's IDESourceEditor plug-in from loading
 * (NSImmediateActionGestureRecognizer) and what would block SourceEditor,
 * SceneKit and IDEModelEditor next (the remaining classes below).
 *
 * The classes are deliberately minimal stubs: the goal is to let the client
 * image bind and run, with unimplemented selectors being forwarded and logged
 * rather than causing an unrecognized-selector crash.
 */

#import <AppKit/AppKitExport.h>
#import <AppKit/NSBitmapImageRep.h>
#import <AppKit/NSDraggingItem.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSPanel.h>
#import <AppKit/NSPasteboard.h>
#import <Foundation/Foundation.h>

#define DARLING_APPKIT_STUB_BODIES(className)                                  \
	- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector           \
	{                                                                          \
		return [NSMethodSignature signatureWithObjCTypes: "v@:"];              \
	}                                                                          \
	- (void)forwardInvocation:(NSInvocation *)anInvocation                     \
	{                                                                          \
		NSLog(@"Stub called: %@ in %@",                                        \
			NSStringFromSelector([anInvocation selector]), [self class]);      \
	}

/* An image representation backed by a CGImage. */
@interface NSCGImageRep : NSBitmapImageRep
@end

@implementation NSCGImageRep
DARLING_APPKIT_STUB_BODIES(NSCGImageRep)
@end

/* Owns a drag operation's lifecycle. */
@interface NSDraggingSession : NSObject {
    NSInteger _darlingDraggingFormation;
    BOOL _darlingAnimatesToStartingPositionsOnCancelOrFail;
    NSPasteboard *_darlingDraggingPasteboard;
    NSInteger _darlingDraggingSequenceNumber;
    NSPoint _darlingDraggingLocation;
    NSArray *_darlingDraggingItems;
}
- (NSInteger) draggingFormation;
- (void) setDraggingFormation: (NSInteger) formation;
- (BOOL) animatesToStartingPositionsOnCancelOrFail;
- (void) setAnimatesToStartingPositionsOnCancelOrFail: (BOOL) flag;
- (NSPasteboard *) draggingPasteboard;
- (NSInteger) draggingSequenceNumber;
- (NSPoint) draggingLocation;
- (void) enumerateDraggingItemsWithOptions: (NSUInteger) options
                                   forView: (NSView *) view
                                   classes: (NSArray *) classArray
                             searchOptions: (NSDictionary *) searchOptions
                                usingBlock: (void (^)(NSDraggingItem *draggingItem,
                                                      NSInteger idx,
                                                      BOOL *stop)) block;
@end

@implementation NSDraggingSession
DARLING_APPKIT_STUB_BODIES(NSDraggingSession)

- (void) dealloc {
    [_darlingDraggingPasteboard release];
    [_darlingDraggingItems release];
    [super dealloc];
}

- (NSInteger) draggingFormation {
    return _darlingDraggingFormation;
}

- (void) setDraggingFormation: (NSInteger) formation {
    _darlingDraggingFormation = formation;
}

- (BOOL) animatesToStartingPositionsOnCancelOrFail {
    return _darlingAnimatesToStartingPositionsOnCancelOrFail;
}

- (void) setAnimatesToStartingPositionsOnCancelOrFail: (BOOL) flag {
    _darlingAnimatesToStartingPositionsOnCancelOrFail = flag;
}

- (NSPasteboard *) draggingPasteboard {
    if (_darlingDraggingPasteboard == nil)
        _darlingDraggingPasteboard =
                [[NSPasteboard pasteboardWithName: NSDragPboard] retain];
    return _darlingDraggingPasteboard;
}

- (NSInteger) draggingSequenceNumber {
    return _darlingDraggingSequenceNumber;
}

- (NSPoint) draggingLocation {
    return _darlingDraggingLocation;
}

- (void) enumerateDraggingItemsWithOptions: (NSUInteger) options
                                   forView: (NSView *) view
                                   classes: (NSArray *) classArray
                             searchOptions: (NSDictionary *) searchOptions
                                usingBlock: (void (^)(NSDraggingItem *draggingItem,
                                                      NSInteger idx,
                                                      BOOL *stop)) block
{
    NSInteger index = 0;
    BOOL stop = NO;

    if (block == NULL)
        return;

    for (NSDraggingItem *draggingItem in _darlingDraggingItems) {
        BOOL matches = ([classArray count] == 0);

        for (Class cls in classArray) {
            if ([[draggingItem item] isKindOfClass: cls]) {
                matches = YES;
                break;
            }
        }

        if (!matches)
            continue;

        block(draggingItem, index++, &stop);
        if (stop)
            break;
    }
}

@end

/* The object model behind NSPathControl. */
@interface NSPathControlItem : NSObject {
    NSAttributedString *_darlingAttributedTitle;
    NSImage *_darlingImage;
    NSURL *_darlingURL;
}
- (NSString *) title;
- (void) setTitle: (NSString *) title;
- (NSAttributedString *) attributedTitle;
- (void) setAttributedTitle: (NSAttributedString *) attributedTitle;
- (NSImage *) image;
- (void) setImage: (NSImage *) image;
- (NSURL *) URL;
@end

@implementation NSPathControlItem
DARLING_APPKIT_STUB_BODIES(NSPathControlItem)

- (void) dealloc {
    [_darlingAttributedTitle release];
    [_darlingImage release];
    [_darlingURL release];
    [super dealloc];
}

- (NSString *) title {
    NSString *string = [_darlingAttributedTitle string];
    return string != nil ? string : @"";
}

- (void) setTitle: (NSString *) title {
    NSAttributedString *attributed = [[NSAttributedString alloc]
            initWithString: title != nil ? title : @""];
    [_darlingAttributedTitle release];
    _darlingAttributedTitle = attributed;
}

- (NSAttributedString *) attributedTitle {
    return _darlingAttributedTitle != nil
            ? _darlingAttributedTitle
            : [[[NSAttributedString alloc] initWithString: @""] autorelease];
}

- (void) setAttributedTitle: (NSAttributedString *) attributedTitle {
    NSAttributedString *copy = [attributedTitle copy];
    [_darlingAttributedTitle release];
    _darlingAttributedTitle = copy;
}

- (NSImage *) image {
    return _darlingImage;
}

- (void) setImage: (NSImage *) image {
    [image retain];
    [_darlingImage release];
    _darlingImage = image;
}

- (NSURL *) URL {
    return _darlingURL;
}

@end

/* The floating window used to host tooltips. */
@interface NSToolTipPanel : NSPanel
@end

@implementation NSToolTipPanel
DARLING_APPKIT_STUB_BODIES(NSToolTipPanel)
@end

/* TextKit 2 typesetter (originally from UIFoundation). */
@interface NSCoreTypesetter : NSObject
@end

@implementation NSCoreTypesetter
DARLING_APPKIT_STUB_BODIES(NSCoreTypesetter)
@end

/* A single laid-out line of text produced by NSCoreTypesetter. */
@interface NSTextLineFragment : NSObject
@end

@implementation NSTextLineFragment
DARLING_APPKIT_STUB_BODIES(NSTextLineFragment)
@end
/*
 * Constants that Xcode 10 binds non-lazily out of AppKit.  Note that
 * NSSliderAccessoryWidthWide is a CGFloat on real macOS, not an NSString, so it
 * must not be lumped in with the binding-option strings above.
 */

NSString *const NSAllowsNullArgumentBindingOption = @"NSAllowsNullArgument";
NSString *const NSContentArrayForMultipleSelectionBinding = @"NSContentArrayForMultipleSelection";
NSString *const NSGlyphInfoAttributeName = @"NSGlyphInfo";
NSString *const NSImageNameAudioOutputVolumeHighTemplate = @"NSAudioOutputVolumeHighTemplate";
NSString *const NSMaxValueBinding = @"NSMaxValue";
NSString *const NSMinValueBinding = @"NSMinValue";
NSString *const NSSelectionIndexPathsBinding = @"NSSelectionIndexPaths";
NSString *const NSSortDescriptorsBinding = @"NSSortDescriptors";
NSString *const NSTextColorBinding = @"NSTextColor";

/* A width, not a string: on real macOS this is `const CGFloat`. */
const CGFloat NSSliderAccessoryWidthWide = 24.0;
