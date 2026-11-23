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

#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSSet.h>
#import <AppKit/NSTouchBarItem.h>

typedef NSString *NSTouchBarCustomizationIdentifier;

@class NSTouchBar;
@protocol NSTouchBarDelegate;

@interface NSTouchBar : NSObject <NSCoding> {
    NSTouchBarCustomizationIdentifier _tbCustomizationIdentifier;
    NSArray *_tbCustomizationAllowedItemIdentifiers;
    NSArray *_tbCustomizationRequiredItemIdentifiers;
    NSArray *_tbDefaultItemIdentifiers;
    NSTouchBarItemIdentifier _tbPrincipalItemIdentifier;
    NSTouchBarItemIdentifier _tbEscapeKeyReplacementItemIdentifier;
    NSSet *_tbTemplateItems;
    id _tbDelegate;
    NSMutableDictionary *_tbItemCache;
}

- (instancetype) init;
- (instancetype) initWithCoder: (NSCoder *) coder;

- (NSTouchBarCustomizationIdentifier) customizationIdentifier;
- (void) setCustomizationIdentifier: (NSTouchBarCustomizationIdentifier) value;
- (NSArray *) customizationAllowedItemIdentifiers;
- (void) setCustomizationAllowedItemIdentifiers: (NSArray *) value;
- (NSArray *) customizationRequiredItemIdentifiers;
- (void) setCustomizationRequiredItemIdentifiers: (NSArray *) value;
- (NSArray *) defaultItemIdentifiers;
- (void) setDefaultItemIdentifiers: (NSArray *) value;
- (NSArray *) itemIdentifiers;
- (NSTouchBarItemIdentifier) principalItemIdentifier;
- (void) setPrincipalItemIdentifier: (NSTouchBarItemIdentifier) value;
- (NSTouchBarItemIdentifier) escapeKeyReplacementItemIdentifier;
- (void) setEscapeKeyReplacementItemIdentifier: (NSTouchBarItemIdentifier) value;
- (NSSet *) templateItems;
- (void) setTemplateItems: (NSSet *) value;
- (id<NSTouchBarDelegate>) delegate;
- (void) setDelegate: (id<NSTouchBarDelegate>) value;
- (NSTouchBarItem *) itemForIdentifier: (NSTouchBarItemIdentifier) identifier;
- (BOOL) isVisible;

@end

@protocol NSTouchBarDelegate <NSObject>
@optional
- (NSTouchBarItem *) touchBar: (NSTouchBar *) touchBar
        makeItemForIdentifier: (NSTouchBarItemIdentifier) identifier;
@end
