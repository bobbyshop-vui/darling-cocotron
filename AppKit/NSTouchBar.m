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

#import <AppKit/NSTouchBar.h>
#import <AppKit/NSView.h>

// i'm assuming this inherits from NSView (TODO: check this assumption)
@interface NSTouchBarView : NSView
@end

// again, i'm assuming this inherits from NSTouchBarView and this should be checked later
@interface NSTouchBarItemContainerView : NSTouchBarView
@end

@implementation NSTouchBar

- (instancetype) init {
    self = [super init];
    if (self) {
        _tbCustomizationAllowedItemIdentifiers = [[NSArray alloc] init];
        _tbCustomizationRequiredItemIdentifiers = [[NSArray alloc] init];
        _tbDefaultItemIdentifiers = [[NSArray alloc] init];
        _tbTemplateItems = [[NSSet alloc] init];
        _tbItemCache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype) initWithCoder: (NSCoder *) coder {
    self = [self init];
    if (self && [coder allowsKeyedCoding]) {
        id obj;
        if ((obj = [coder decodeObjectForKey: @"NSTouchBarCustomizationIdentifier"]) != nil)
            [self setCustomizationIdentifier: obj];
        if ((obj = [coder decodeObjectForKey: @"NSTouchBarCustomizationAllowedItemIdentifiers"]) != nil)
            [self setCustomizationAllowedItemIdentifiers: obj];
        if ((obj = [coder decodeObjectForKey: @"NSTouchBarCustomizationRequiredItemIdentifiers"]) != nil)
            [self setCustomizationRequiredItemIdentifiers: obj];
        if ((obj = [coder decodeObjectForKey: @"NSTouchBarDefaultItemIdentifiers"]) != nil)
            [self setDefaultItemIdentifiers: obj];
        if ((obj = [coder decodeObjectForKey: @"NSTouchBarPrincipalItemIdentifier"]) != nil)
            [self setPrincipalItemIdentifier: obj];
        if ((obj = [coder decodeObjectForKey: @"NSTouchBarTemplateItems"]) != nil)
            [self setTemplateItems: obj];
        _tbDelegate = [coder decodeObjectForKey: @"NSTouchBarDelegate"];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder {
    if (![coder allowsKeyedCoding])
        return;
    [coder encodeObject: _tbCustomizationIdentifier
                 forKey: @"NSTouchBarCustomizationIdentifier"];
    [coder encodeObject: _tbCustomizationAllowedItemIdentifiers
                 forKey: @"NSTouchBarCustomizationAllowedItemIdentifiers"];
    [coder encodeObject: _tbCustomizationRequiredItemIdentifiers
                 forKey: @"NSTouchBarCustomizationRequiredItemIdentifiers"];
    [coder encodeObject: _tbDefaultItemIdentifiers
                 forKey: @"NSTouchBarDefaultItemIdentifiers"];
    [coder encodeObject: _tbPrincipalItemIdentifier
                 forKey: @"NSTouchBarPrincipalItemIdentifier"];
    [coder encodeObject: _tbTemplateItems forKey: @"NSTouchBarTemplateItems"];
    [coder encodeConditionalObject: _tbDelegate forKey: @"NSTouchBarDelegate"];
}

- (void) dealloc {
    [_tbCustomizationIdentifier release];
    [_tbCustomizationAllowedItemIdentifiers release];
    [_tbCustomizationRequiredItemIdentifiers release];
    [_tbDefaultItemIdentifiers release];
    [_tbPrincipalItemIdentifier release];
    [_tbEscapeKeyReplacementItemIdentifier release];
    [_tbTemplateItems release];
    [_tbItemCache release];
    [super dealloc];
}

- (NSTouchBarCustomizationIdentifier) customizationIdentifier {
    return _tbCustomizationIdentifier;
}

- (void) setCustomizationIdentifier: (NSTouchBarCustomizationIdentifier) value {
    value = [value copy];
    [_tbCustomizationIdentifier release];
    _tbCustomizationIdentifier = value;
}

- (NSArray *) customizationAllowedItemIdentifiers {
    return _tbCustomizationAllowedItemIdentifiers;
}

- (void) setCustomizationAllowedItemIdentifiers: (NSArray *) value {
    value = value ? [value copy] : [[NSArray alloc] init];
    [_tbCustomizationAllowedItemIdentifiers release];
    _tbCustomizationAllowedItemIdentifiers = value;
}

- (NSArray *) customizationRequiredItemIdentifiers {
    return _tbCustomizationRequiredItemIdentifiers;
}

- (void) setCustomizationRequiredItemIdentifiers: (NSArray *) value {
    value = value ? [value copy] : [[NSArray alloc] init];
    [_tbCustomizationRequiredItemIdentifiers release];
    _tbCustomizationRequiredItemIdentifiers = value;
}

- (NSArray *) defaultItemIdentifiers {
    return _tbDefaultItemIdentifiers;
}

- (void) setDefaultItemIdentifiers: (NSArray *) value {
    value = value ? [value copy] : [[NSArray alloc] init];
    [_tbDefaultItemIdentifiers release];
    _tbDefaultItemIdentifiers = value;
}

// Without a customization palette the resolved list is the default list.
- (NSArray *) itemIdentifiers {
    return _tbDefaultItemIdentifiers;
}

- (NSTouchBarItemIdentifier) principalItemIdentifier {
    return _tbPrincipalItemIdentifier;
}

- (void) setPrincipalItemIdentifier: (NSTouchBarItemIdentifier) value {
    value = [value copy];
    [_tbPrincipalItemIdentifier release];
    _tbPrincipalItemIdentifier = value;
}

- (NSTouchBarItemIdentifier) escapeKeyReplacementItemIdentifier {
    return _tbEscapeKeyReplacementItemIdentifier;
}

- (void) setEscapeKeyReplacementItemIdentifier: (NSTouchBarItemIdentifier) value {
    value = [value copy];
    [_tbEscapeKeyReplacementItemIdentifier release];
    _tbEscapeKeyReplacementItemIdentifier = value;
}

- (NSSet *) templateItems {
    return _tbTemplateItems;
}

- (void) setTemplateItems: (NSSet *) value {
    value = value ? [value copy] : [[NSSet alloc] init];
    [_tbTemplateItems release];
    _tbTemplateItems = value;
    [_tbItemCache removeAllObjects];
}

- (id<NSTouchBarDelegate>) delegate {
    return _tbDelegate;
}

- (void) setDelegate: (id<NSTouchBarDelegate>) value {
    _tbDelegate = value;
}

- (NSTouchBarItem *) itemForIdentifier: (NSTouchBarItemIdentifier) identifier {
    if (identifier == nil)
        return nil;

    NSTouchBarItem *item = [_tbItemCache objectForKey: identifier];
    if (item != nil)
        return item;

    for (NSTouchBarItem *candidate in _tbTemplateItems) {
        if ([[candidate identifier] isEqual: identifier]) {
            item = candidate;
            break;
        }
    }

    if (item == nil && [_tbDelegate respondsToSelector:
                @selector(touchBar:makeItemForIdentifier:)])
        item = [_tbDelegate touchBar: self makeItemForIdentifier: identifier];

    if (item == nil &&
        ([identifier isEqual: NSTouchBarItemIdentifierFixedSpaceSmall] ||
         [identifier isEqual: NSTouchBarItemIdentifierFixedSpaceLarge] ||
         [identifier isEqual: NSTouchBarItemIdentifierFlexibleSpace] ||
         [identifier isEqual: NSTouchBarItemIdentifierOtherItemsProxy]))
        item = [[[NSTouchBarItem alloc] initWithIdentifier: identifier]
                autorelease];

    if (item != nil)
        [_tbItemCache setObject: item forKey: identifier];
    return item;
}

// There is no Touch Bar hardware or provider to attach to.
- (BOOL) isVisible {
    return NO;
}

@end

@implementation NSTouchBarView

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [NSMethodSignature signatureWithObjCTypes: "v@:"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"Stub called: %@ in %@", NSStringFromSelector([anInvocation selector]), [self class]);
}

@end

@implementation NSTouchBarItemContainerView

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [NSMethodSignature signatureWithObjCTypes: "v@:"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"Stub called: %@ in %@", NSStringFromSelector([anInvocation selector]), [self class]);
}

@end

// Xcode 10's Interface Builder DFR plug-in resolves this private AppKit class
// by name and swizzles -ibManagedContainerBehavior during start-up.
@interface NSTouchBarItemView : NSTouchBarView
@end

@implementation NSTouchBarItemView

- (NSInteger)ibManagedContainerBehavior
{
    return 0;
}

@end
