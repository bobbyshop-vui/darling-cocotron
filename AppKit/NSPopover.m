#import <AppKit/NSAppearance.h>
#import <AppKit/NSPopover.h>
#import <AppKit/NSResponder.h>
#import <AppKit/NSView.h>
#import <AppKit/NSViewController.h>
#import <Foundation/Foundation.h>

NSNotificationName const NSPopoverDidCloseNotification = @"NSPopoverDidCloseNotification";
NSNotificationName const NSPopoverWillCloseNotification = @"NSPopoverWillCloseNotification";
NSNotificationName const NSPopoverWillShowNotification = @"NSPopoverWillShowNotification";
NSNotificationName const NSPopoverDidShowNotification = @"NSPopoverDidShowNotification";

typedef NS_ENUM(NSInteger, NSPopoverBehavior) {
    NSPopoverBehaviorApplicationDefined = 0,
    NSPopoverBehaviorTransient = 1,
    NSPopoverBehaviorSemitransient = 2
};

@class NSPopover;
@protocol NSPopoverDelegateShouldClose
- (BOOL) popoverShouldClose: (NSPopover *) popover;
@end

@interface NSPopover : NSResponder {
    id _delegate;
    NSAppearance *_appearance;
    NSPopoverBehavior _behavior;
    BOOL _animates;
    NSViewController *_contentViewController;
    NSSize _contentSize;
    NSRect _positioningRect;
    NSView *_positioningView;
    BOOL _shown;
    BOOL _detached;
}

- (instancetype) init;
- (instancetype) initWithCoder: (NSCoder *) coder;
- (id) delegate;
- (void) setDelegate: (id) delegate;
- (NSAppearance *) appearance;
- (void) setAppearance: (NSAppearance *) appearance;
- (NSAppearance *) effectiveAppearance;
- (NSPopoverBehavior) behavior;
- (void) setBehavior: (NSPopoverBehavior) behavior;
- (BOOL) animates;
- (void) setAnimates: (BOOL) animates;
- (NSViewController *) contentViewController;
- (void) setContentViewController: (NSViewController *) controller;
- (NSSize) contentSize;
- (void) setContentSize: (NSSize) size;
- (BOOL) isShown;
- (BOOL) isDetached;
- (NSRect) positioningRect;
- (void) setPositioningRect: (NSRect) rect;
- (void) showRelativeToRect: (NSRect) rect
                     ofView: (NSView *) view
              preferredEdge: (NSRectEdge) edge;
- (IBAction) performClose: (id) sender;
- (void) close;

@end

@implementation NSPopover

- (instancetype) init {
    self = [super init];
    if (self) {
        _animates = YES;
        _behavior = NSPopoverBehaviorApplicationDefined;
    }
    return self;
}

- (instancetype) initWithCoder: (NSCoder *) coder {
    self = [super init];
    if (self) {
        _animates = YES;
        if ([coder allowsKeyedCoding]) {
            if ([coder containsValueForKey: @"NSAnimates"]) {
                _animates = [coder decodeBoolForKey: @"NSAnimates"];
            }
            if ([coder containsValueForKey: @"NSBehavior"]) {
                _behavior = [coder decodeIntegerForKey: @"NSBehavior"];
            }
            if ([coder containsValueForKey: @"NSContentSize"]) {
                _contentSize = [coder decodeSizeForKey: @"NSContentSize"];
            }
            if ([coder containsValueForKey: @"NSContentViewController"]) {
                _contentViewController =
                        [[coder decodeObjectForKey: @"NSContentViewController"]
                                retain];
            }
            if ([coder containsValueForKey: @"NSDelegate"]) {
                _delegate = [coder decodeObjectForKey: @"NSDelegate"];
            }
        }
    }
    return self;
}

- (void) dealloc {
    [_appearance release];
    [_contentViewController release];
    [_positioningView release];
    [super dealloc];
}

- (id) delegate {
    return _delegate;
}

- (void) setDelegate: (id) delegate {
    _delegate = delegate;
}

- (NSAppearance *) appearance {
    return _appearance;
}

- (void) setAppearance: (NSAppearance *) appearance {
    [appearance retain];
    [_appearance release];
    _appearance = appearance;
}

- (NSAppearance *) effectiveAppearance {
    if (_appearance != nil) {
        return _appearance;
    }
    if ([_positioningView respondsToSelector: @selector(effectiveAppearance)]) {
        NSAppearance *inherited = [(id) _positioningView effectiveAppearance];
        if (inherited != nil) {
            return inherited;
        }
    }
    return [NSAppearance appearanceNamed: NSAppearanceNameAqua];
}

- (NSPopoverBehavior) behavior {
    return _behavior;
}

- (void) setBehavior: (NSPopoverBehavior) behavior {
    _behavior = behavior;
}

- (BOOL) animates {
    return _animates;
}

- (void) setAnimates: (BOOL) animates {
    _animates = animates;
}

- (NSViewController *) contentViewController {
    return _contentViewController;
}

- (void) setContentViewController: (NSViewController *) controller {
    [controller retain];
    [_contentViewController release];
    _contentViewController = controller;
}

- (NSSize) contentSize {
    return _contentSize;
}

- (void) setContentSize: (NSSize) size {
    _contentSize = size;
}

- (BOOL) isShown {
    return _shown;
}

- (BOOL) isDetached {
    return _detached;
}

- (NSRect) positioningRect {
    return _positioningRect;
}

- (void) setPositioningRect: (NSRect) rect {
    _positioningRect = rect;
}

- (void) showRelativeToRect: (NSRect) rect
                     ofView: (NSView *) view
              preferredEdge: (NSRectEdge) edge
{
    if (view == nil) {
        [NSException raise: NSInvalidArgumentException
                    format: @"-[NSPopover showRelativeToRect:ofView:preferredEdge:] "
                            @"requires a positioning view"];
    }
    if (_contentViewController == nil) {
        [NSException raise: NSInternalInconsistencyException
                    format: @"NSPopover has no contentViewController"];
    }

    _positioningRect = rect;
    [view retain];
    [_positioningView release];
    _positioningView = view;

    if (_shown) {
        return;
    }

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName: NSPopoverWillShowNotification object: self];
    _shown = YES;
    [center postNotificationName: NSPopoverDidShowNotification object: self];
}

- (IBAction) performClose: (id) sender {
    if (!_shown) {
        return;
    }
    if ([_delegate respondsToSelector: @selector(popoverShouldClose:)] &&
        ![(id<NSPopoverDelegateShouldClose>) _delegate popoverShouldClose: self]) {
        return;
    }
    [self close];
}

- (void) close {
    if (!_shown) {
        return;
    }
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName: NSPopoverWillCloseNotification object: self];
    _shown = NO;
    _detached = NO;
    [center postNotificationName: NSPopoverDidCloseNotification object: self];
}

@end
