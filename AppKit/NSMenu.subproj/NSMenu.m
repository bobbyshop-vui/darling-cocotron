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

#import <AppKit/NSApplication.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSMenu.h>
#import <AppKit/NSMenuItem.h>
#import <AppKit/NSMenuView.h>
#import <AppKit/NSMenuWindow.h>
#import <AppKit/NSFont.h>
#import <AppKit/NSScreen.h>
#import <AppKit/NSMainMenuView.h>
#import <AppKit/NSSubmenuView.h>
#import <AppKit/NSWindow.h>
#import <Foundation/NSKeyedArchiver.h>

const NSNotificationName NSMenuWillSendActionNotification = @"NSMenuWillSendActionNotification";
const NSNotificationName NSMenuDidSendActionNotification = @"NSMenuDidSendActionNotification";
const NSNotificationName NSMenuDidBeginTrackingNotification = @"NSMenuDidBeginTrackingNotification";
const NSNotificationName NSMenuDidEndTrackingNotification = @"NSMenuDidEndTrackingNotification";
NSString *const _NSFontMenuName = @"Font";
NSString *const _NSHelpMenuName = @"Help";
NSString *const _NSMainMenuName = @"Application";
NSString *const _NSRecentDocumentsMenuName = @"Recents";
NSString *const _NSServicesMenuName = @"Services";
NSString *const _NSWindowsMenuName = @"Window";

@interface NSMenu (NSMenu_private)
- (BOOL) _popUpWithEvent: (NSEvent *) event
           atScreenPoint: (NSPoint) screenPoint
           alignedToItem: (NSMenuItem *) alignItem;
- (void) _setHighlightedItem: (NSMenuItem *) item;
@end

#define NSMenuAllProperties                                                    \
    (NSMenuPropertyItemTitle | NSMenuPropertyItemAttributedTitle |             \
     NSMenuPropertyItemKeyEquivalent | NSMenuPropertyItemImage |               \
     NSMenuPropertyItemEnabled | NSMenuPropertyItemAccessibilityDescription)

@implementation NSMenu

@synthesize showsStateColumn = _showsStateColumn;
@synthesize identifier = _identifier;

+ (void) popUpContextMenu: (NSMenu *) menu
                withEvent: (NSEvent *) event
                  forView: (NSView *) view
{
    [self popUpContextMenu: menu withEvent: event forView: view withFont: nil];
}

+ (void) popUpContextMenu: (NSMenu *) menu
                withEvent: (NSEvent *) event
                  forView: (NSView *) view
                 withFont: (NSFont *) font
{
    NSFont *savedFont = [[menu->_font retain] autorelease];

    if (font != nil)
        [menu setFont: font];

    NSPoint point = [event locationInWindow];
    NSWindow *window = [event window];

    [menu _popUpWithEvent: event
                 atScreenPoint: [window convertBaseToScreen: point]
                  alignedToItem: nil];

    if (font != nil)
        [menu setFont: savedFont];
}

- (BOOL) _popUpWithEvent: (NSEvent *) event
           atScreenPoint: (NSPoint) screenPoint
           alignedToItem: (NSMenuItem *) alignItem
{
    BOOL result = NO;

    [self update];
    if ([[self itemArray] count] == 0 || event == nil)
        return NO;

    NSMenuWindow *menuWindow = [[NSMenuWindow alloc] initWithMenu: self];
    NSMenuView *menuView = [menuWindow menuView];
    NSMenuItem *item;

    if (alignItem != nil) {
        NSInteger index = [[menuView visibleItemArray] indexOfObjectIdenticalTo: alignItem];

        if (index != NSNotFound) {
            NSRect itemRect = [menuView rectOfItemAtIndex: index];
            screenPoint.y -= NSMinY(itemRect);
        }
    }

    [menuWindow setReleasedWhenClosed: YES];
    [menuWindow setFrameTopLeftPoint: screenPoint];
    [menuWindow orderFront: nil];

    _cancelTrackingRequested = NO;
    _trackingView = menuView;
    [[NSNotificationCenter defaultCenter]
            postNotificationName: NSMenuDidBeginTrackingNotification
                          object: self];

    item = [menuView trackForEvent: event];

    _trackingView = nil;
    _cancelTrackingRequested = NO;
    [self _setHighlightedItem: nil];
    [[NSNotificationCenter defaultCenter]
            postNotificationName: NSMenuDidEndTrackingNotification
                          object: self];

    [menuWindow close];

    if (item != nil) {
        [NSApp sendAction: [item action] to: [item target] from: item];
        result = YES;
    }

    return result;
}

- (BOOL) popUpMenuPositioningItem: (NSMenuItem *) item
                       atLocation: (NSPoint) location
                           inView: (NSView *) view
{
    NSEvent *event = [NSApp currentEvent];
    NSPoint screenPoint = location;

    if (view != nil) {
        NSPoint windowPoint = [view convertPoint: location toView: nil];
        screenPoint = [[view window] convertBaseToScreen: windowPoint];
    }

    if (event == nil)
        return NO;

    return [self _popUpWithEvent: event
                   atScreenPoint: screenPoint
                   alignedToItem: item];
}

+ (NSZone *) menuZone {
    return NSDefaultMallocZone();
}

- (void) encodeWithCoder: (NSCoder *) coder {
    [coder encodeObject: _title forKey: @"NSTitle"];
    [coder encodeObject: _name forKey: @"NSName"];
    [coder encodeObject: _itemArray forKey: @"NSMenuItems"];
    [coder encodeBool: !_autoenablesItems forKey: @"NSNoAutoenable"];
}

- (void) setMenuChangedMessagesEnabled: (BOOL) flag {
    NSLog(@"-[NSMenu setMenuChangedMessagesEnabled not implemented]");
}

- initWithCoder: (NSCoder *) coder {
    _showsStateColumn = YES; // TODO: figure out the right coding for this
    _propertiesToUpdate = NSMenuAllProperties;

    if ([coder allowsKeyedCoding]) {
        NSKeyedUnarchiver *keyed = (NSKeyedUnarchiver *) coder;

        _supermenu = [keyed decodeObjectForKey: @"NSMenu"];
        _title = [[keyed decodeObjectForKey: @"NSTitle"] copy];
        _name = [[keyed decodeObjectForKey: @"NSName"] copy];

        _itemArray = [[NSMutableArray alloc]
                initWithArray: [keyed decodeObjectForKey: @"NSMenuItems"]];
        _autoenablesItems = ![keyed decodeBoolForKey: @"NSNoAutoenable"];
    } else {
        NSInteger version;
        version = [coder versionForClassName: @"NSMenu"];

        if (version == NSNotFound)
            version = [coder versionForClassName: @"NSMenuPanel"];

        if (version <= 203) {
            NSString *title, *name;
            id matrix;
            if (version <= 16) {
                BOOL noAutoEnable;

                [coder decodePoint];
                [coder decodeValuesOfObjCTypes: "@@@s", &title, &matrix, &name,
                                                &noAutoEnable];

                _autoenablesItems = !noAutoEnable;
            } else if (version <= 40) {
                char bytes[6];

                [coder decodePoint];
                [coder decodeArrayOfObjCType: @encode(char) count: 6 at: bytes];
                _autoenablesItems = !bytes[0];

                [coder decodeValuesOfObjCTypes: "@@@", &title, &matrix, &name];
            } else {
                int flag;

                [coder decodePoint];
                [coder decodeValueOfObjCType: @encode(int) at: &flag];
                _autoenablesItems = !(flag & 0x40000000);
                [self setMenuChangedMessagesEnabled: flag & 0x200000];

                [coder decodeValuesOfObjCTypes: "@@@", &title, &matrix, &name];
            }

            if ([matrix isKindOfClass: [NSMatrix class]]) {
                NSInteger numRows, numColumns;
                [matrix getNumberOfRows: &numRows columns: &numColumns];

                if (numRows != 0) {
                    NSMenuItem *item = [matrix cellAtRow: 0 column: 0];
                    [self addItem: item];
                }
            }

            _title = title;
            _name = name;
        } else {
            int flags;

            [coder decodeValuesOfObjCTypes: "i@@@", &flags, &_title, &_itemArray,
                                            &_name];

            _autoenablesItems = !(flags & 0x80000000);
            // _excludeMarkColumn = flags & 0x80000;
            // _cmPluginMode = (flags >> 21) & 3;
            // _invertedCMPluginTypes = (flags >> 23) & 3;
        }
    }
    return self;
}

- initWithTitle: (NSString *) title {
    _title = [title copy];
    _itemArray = [NSMutableArray new];
    _autoenablesItems = YES;
    _showsStateColumn = YES;
    _propertiesToUpdate = NSMenuAllProperties;
    return self;
}

- init {
    return [self initWithTitle: @""];
}

- (void) dealloc {
    [_title release];
    [_name release];
    [_itemArray makeObjectsPerformSelector: @selector(_setMenu:)
                                withObject: nil];
    [_itemArray release];
    [_identifier release];
    [_font release];
    [super dealloc];
}

- copyWithZone: (NSZone *) zone {
    NSMenu *copy = NSCopyObject(self, 0, zone);

    copy->_title = [_title copyWithZone: zone];
    copy->_name = [_name copyWithZone: zone];
    copy->_font = [_font retain];
    copy->_highlightedItem = nil;
    copy->_trackingView = nil;
    copy->_cancelTrackingRequested = NO;
    copy->_identifier = [_identifier copyWithZone: zone];
    copy->_itemArray = [[NSMutableArray alloc] init];
    for (NSMenuItem *item in _itemArray) {
        [copy addItem: [[item copyWithZone: zone] autorelease]];
    }

    return copy;
}

- (NSMenu *) supermenu {
    return _supermenu;
}

- (NSString *) title {
    return _title;
}

- (NSInteger) numberOfItems {
    return [_itemArray count];
}

- (NSArray *) itemArray {
    return _itemArray;
}

- (void) _setItemArray: itemArray {
    if (_itemArray != itemArray) {
        [_itemArray release];
        _itemArray = [itemArray retain];
    }
}

- (BOOL) autoenablesItems {
    return _autoenablesItems;
}

- (NSMenuItem *) itemAtIndex: (NSInteger) index {
    return [_itemArray objectAtIndex: index];
}

- (NSMenuItem *) itemWithTag: (NSInteger) tag {
    NSInteger i, count = [_itemArray count];

    for (i = 0; i < count; i++) {
        NSMenuItem *item = [_itemArray objectAtIndex: i];

        if ([item tag] == tag)
            return item;
    }

    return nil;
}

- (NSMenuItem *) itemWithTitle: (NSString *) title {
    NSInteger i, count = [_itemArray count];

    for (i = 0; i < count; i++) {
        NSMenuItem *item = [_itemArray objectAtIndex: i];

        if ([[item title] isEqualToString: title])
            return item;
    }

    return nil;
}

- (NSInteger) indexOfItem: (NSMenuItem *) item {
    return [_itemArray indexOfObjectIdenticalTo: item];
}

- (NSInteger) indexOfItemWithTag: (NSInteger) tag {
    NSInteger i, count = [_itemArray count];

    for (i = 0; i < count; ++i)
        if ([[_itemArray objectAtIndex: i] tag] == tag)
            return i;

    return -1;
}

- (NSInteger) indexOfItemWithTitle: (NSString *) title {
    NSInteger i, count = [_itemArray count];

    for (i = 0; i < count; i++)
        if ([[[_itemArray objectAtIndex: i] title] isEqualToString: title])
            return i;

    return -1;
}

- (NSInteger) indexOfItemWithRepresentedObject: object {
    NSInteger i, count = [_itemArray count];

    for (i = 0; i < count; i++)
        if ([[(NSMenuItem *) [_itemArray objectAtIndex: i] representedObject]
                    isEqual: object])
            return i;

    return -1;
}

// needed this for NSApplication windowsMenu stuff, so i did 'em all..
- (NSInteger) indexOfItemWithTarget: (id) target andAction: (SEL) action {
    NSInteger i, count = [_itemArray count];

    for (i = 0; i < count; ++i) {
        NSMenuItem *item = [_itemArray objectAtIndex: i];

        if ([item target] == target) {
            if (action == NULL)
                return i;
            else if ([item action] == action)
                return i;
        }
    }

    return -1;
}

- (NSInteger) indexOfItemWithSubmenu: (NSMenu *) submenu {
    NSInteger i, count = [_itemArray count];

    for (i = 0; i < count; ++i)
        if ([[_itemArray objectAtIndex: i] submenu] == submenu)
            return i;

    return -1;
}

- (void) setSupermenu: (NSMenu *) value {
    _supermenu = value;
}

- (void) setTitle: (NSString *) title {
    title = [title copy];
    [_title release];
    _title = title;
}

- (void) setAutoenablesItems: (BOOL) flag {
    _autoenablesItems = flag;
}

- (void) addItem: (NSMenuItem *) item {
    [item performSelector: @selector(_setMenu:) withObject: self];
    [_itemArray addObject: item];
}

- (NSMenuItem *) addItemWithTitle: (NSString *) title
                           action: (SEL) action
                    keyEquivalent: (NSString *) keyEquivalent
{
    NSMenuItem *item =
            [[[NSMenuItem alloc] initWithTitle: title
                                        action: action
                                 keyEquivalent: keyEquivalent] autorelease];

    [self addItem: item];

    return item;
}

- (void) removeAllItems {
    while ([_itemArray count] > 0)
        [self removeItem: [_itemArray lastObject]];
}

- (void) removeItem: (NSMenuItem *) item {
    [item performSelector: @selector(_setMenu:) withObject: nil];
    [_itemArray removeObjectIdenticalTo: item];
}

- (void) removeItemAtIndex: (NSInteger) index {
    [self removeItem: [_itemArray objectAtIndex: index]];
}

- (void) insertItem: (NSMenuItem *) item atIndex: (NSInteger) index {
    [item performSelector: @selector(_setMenu:) withObject: self];
    [_itemArray insertObject: item atIndex: index];
}

- (NSMenuItem *) insertItemWithTitle: (NSString *) title
                              action: (SEL) action
                       keyEquivalent: (NSString *) keyEquivalent
                             atIndex: (NSInteger) index
{
    NSMenuItem *item =
            [[[NSMenuItem alloc] initWithTitle: title
                                        action: action
                                 keyEquivalent: keyEquivalent] autorelease];

    [self insertItem: item atIndex: index];

    return item;
}

- (void) setSubmenu: (NSMenu *) submenu forItem: (NSMenuItem *) item {
    [item setSubmenu: submenu];
}

BOOL itemIsEnabled(NSMenuItem *item) {
    BOOL enabled = NO;

    if ([item action] != NULL) {
        id target = [item target];

        target = [NSApp targetForAction: [item action]
                                     to: [item target]
                                   from: nil];

        if ((target == nil) || ![target respondsToSelector: [item action]]) {
            enabled = NO;
        } else if ([target respondsToSelector: @selector(validateMenuItem:)]) {
            enabled = [target validateMenuItem: item];
        } else if ([target respondsToSelector: @selector
                           (validateUserInterfaceItem:)]) { // New validation
                                                            // scheme
            enabled = [target validateUserInterfaceItem: item];
        } else {
            enabled = YES;
        }
    }

    return enabled;
}

- (void) update {
    if ([_delegate respondsToSelector: @selector(menuNeedsUpdate:)]) {
        [_delegate menuNeedsUpdate: self];
    }

    NSInteger i, count = [_itemArray count];

    for (i = 0; i < count; i++) {
        NSMenuItem *item = [_itemArray objectAtIndex: i];

        if (_autoenablesItems) {
            BOOL enabled = itemIsEnabled(item) ? YES : NO;
            BOOL currentlyEnabled = [item isEnabled] ? YES : NO;

            if (enabled != currentlyEnabled &&
                ![item _binderForBinding: @"enabled" create: NO]) {
                [item setEnabled: enabled];
                [self itemChanged: item];
            }
        }

        [[item submenu] update];
    }
}

- (void) itemChanged: (NSMenuItem *) item {
}

- (BOOL) performKeyEquivalent: (NSEvent *) event {
    NSInteger i, count = [_itemArray count];
    NSString *characters = [event charactersIgnoringModifiers];
    unsigned modifiers = [event modifierFlags];

    if (_autoenablesItems) {
        // Only key equivalents and enabled state matter while matching keys
        _propertiesToUpdate =
                NSMenuPropertyItemKeyEquivalent | NSMenuPropertyItemEnabled;
        [self update];
        _propertiesToUpdate = NSMenuAllProperties;
    }

    for (i = 0; i < count; i++) {
        NSMenuItem *item = [_itemArray objectAtIndex: i];
        unsigned itemModifiers = [item keyEquivalentModifierMask] &
                                 (NSCommandKeyMask | NSAlternateKeyMask);
        NSString *key = [item keyEquivalent];

        if ((modifiers & (NSCommandKeyMask | NSAlternateKeyMask)) ==
            itemModifiers) {

            if ([key isEqualToString: characters]) {
                /* This *must* accurately reflect menu validation when ignoring
                   or processing key equivalents. Relying on update to keep
                   isEnabled in the proper state is unfortunately too tenuous.
                 */
                if (itemIsEnabled(item))
                    return [NSApp sendAction: [item action]
                                          to: [item target]
                                        from: item];
            }
        }

        if ([[item submenu] performKeyEquivalent: event])
            return YES;
    }

    return NO;
}

- (void) performActionForItemAtIndex: (NSInteger) index {
    NSMenuItem *item = [_itemArray objectAtIndex: index];

    if (![item isEnabled] || [item action] == NULL)
        return;

    NSDictionary *userInfo =
            [NSDictionary dictionaryWithObject: item forKey: @"MenuItem"];

    [[NSNotificationCenter defaultCenter]
            postNotificationName: NSMenuWillSendActionNotification
                          object: self
                        userInfo: userInfo];
    [NSApp sendAction: [item action] to: [item target] from: item];
    [[NSNotificationCenter defaultCenter]
            postNotificationName: NSMenuDidSendActionNotification
                          object: self
                        userInfo: userInfo];
}

- (CGFloat) menuBarHeight {
    // Only the application's main menu is presented as a menu bar
    if (_supermenu == nil && self == [NSApp mainMenu])
        return [NSMainMenuView menuHeight];

    return 0;
}

- (void) cancelTracking {
    if (_trackingView == nil)
        return;

    _cancelTrackingRequested = YES;

    // Wake the tracking loop so that it notices the request
    NSWindow *window = [(NSView *) _trackingView window];
    NSEvent *wake = [NSEvent otherEventWithType: NSAppKitDefined
                                       location: NSZeroPoint
                                  modifierFlags: 0
                                      timestamp: 0
                                   windowNumber: [window windowNumber]
                                        context: nil
                                        subtype: 0x4D43
                                          data1: 0
                                          data2: 0];
    [NSApp postEvent: wake atStart: YES];
}

- (BOOL) _cancelTrackingRequested {
    return _cancelTrackingRequested;
}

- (void) _setTrackingView: (id) view {
    _trackingView = view;
    if (view == nil)
        _cancelTrackingRequested = NO;
}

- (void) _setHighlightedItem: (NSMenuItem *) item {
    if (_highlightedItem == item)
        return;

    _highlightedItem = item;

    if ([_delegate respondsToSelector: @selector(menu:willHighlightItem:)])
        [_delegate menu: self willHighlightItem: item];
}

- (NSMenuItem *) highlightedItem {
    return _highlightedItem;
}

- (CGFloat) minimumWidth {
    return _minimumWidth;
}

- (void) setMinimumWidth: (CGFloat) width {
    _minimumWidth = width;
}

- (NSFont *) font {
    if (_font == nil)
        return [NSFont menuFontOfSize: 0];

    return _font;
}

- (void) setFont: (NSFont *) font {
    font = [font retain];
    [_font release];
    _font = font;
}

- (BOOL) allowsContextMenuPlugIns {
    return _allowsContextMenuPlugIns;
}

- (void) setAllowsContextMenuPlugIns: (BOOL) flag {
    _allowsContextMenuPlugIns = flag;
}

- (NSInteger) userInterfaceLayoutDirection {
    if (_hasLayoutDirection)
        return _userInterfaceLayoutDirection;

    // Defaults to the application's layout direction
    if ([NSApp respondsToSelector: @selector(userInterfaceLayoutDirection)])
        return [(NSView *) NSApp userInterfaceLayoutDirection];

    return 0; // NSUserInterfaceLayoutDirectionLeftToRight
}

- (void) setUserInterfaceLayoutDirection: (NSInteger) direction {
    _userInterfaceLayoutDirection = direction;
    _hasLayoutDirection = YES;
}

- (NSMenuProperties) propertiesToUpdate {
    return _propertiesToUpdate;
}

- (NSSize) size {
    NSSubmenuView *view = [[NSSubmenuView alloc] initWithMenu: self];
    NSSize size = [view frame].size;

    [view release];
    if (size.width < _minimumWidth)
        size.width = _minimumWidth;

    return size;
}

- (void) sizeToFit {
    // The size of a menu is always computed from its current items when it is
    // presented (see -size), so there is no cached layout to refresh.
}

- (void) setDelegate: (id<NSMenuDelegate>) object {
    _delegate = object;
}

- (id<NSMenuDelegate>) delegate {
    return _delegate;
}

- (NSString *) _name {
    return _name;
}

- (void) _setMenuName: (NSString *) name {
    NSString* copied = [name copy];
    [_name release];
    _name = copied;
}

- (NSMenu *) _menuWithName: (NSString *) name {
    if ([_name isEqual: name])
        return self;
    else {
        NSInteger i, count = [_itemArray count];

        for (i = 0; i < count; i++) {
            NSMenu *check = [[[_itemArray objectAtIndex: i] submenu]
                    _menuWithName: name];

            if (check != nil)
                return check;
        }
    }

    return nil;
}

@end
