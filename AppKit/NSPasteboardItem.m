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

#import <AppKit/NSPasteboardItem.h>

@implementation NSPasteboardItem

- (instancetype) init {
    self = [super init];
    if (self) {
        _types = [[NSMutableArray alloc] init];
        _data = [[NSMutableDictionary alloc] init];
        _providers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) dealloc {
    [_types release];
    [_data release];
    [_providers release];
    [super dealloc];
}

- (void) _setPasteboard: (NSPasteboard *) pasteboard index: (NSUInteger) index {
    _pasteboard = pasteboard;
    _index = index;
}

- (NSPasteboard *) _pasteboard {
    return _pasteboard;
}

- (NSUInteger) _index {
    return _index;
}

- (NSArray<NSPasteboardType> *) types {
    if (_pasteboard != nil) {
        NSMutableArray *all = [NSMutableArray arrayWithArray: [_pasteboard types]];
        for (NSPasteboardType type in _types) {
            if (![all containsObject: type]) {
                [all addObject: type];
            }
        }
        return all;
    }
    return [[_types copy] autorelease];
}

- (NSPasteboardType) availableTypeFromArray: (NSArray<NSPasteboardType> *) types {
    NSArray *available = [self types];
    for (NSPasteboardType type in types) {
        if ([available containsObject: type]) {
            return type;
        }
    }
    return nil;
}

- (BOOL) setDataProvider: (id<NSPasteboardItemDataProvider>) dataProvider
                forTypes: (NSArray<NSPasteboardType> *) types {
    if (dataProvider == nil) {
        return NO;
    }
    for (NSPasteboardType type in types) {
        if (![_types containsObject: type]) {
            [_types addObject: type];
        }
        [_data removeObjectForKey: type];
        [_providers setObject: dataProvider forKey: type];
    }
    return YES;
}

- (BOOL) setData: (NSData *) data forType: (NSPasteboardType) type {
    if (data == nil || type == nil) {
        return NO;
    }
    if (![_types containsObject: type]) {
        [_types addObject: type];
    }
    [_providers removeObjectForKey: type];
    [_data setObject: [[data copy] autorelease] forKey: type];
    return YES;
}

- (BOOL) setString: (NSString *) string forType: (NSPasteboardType) type {
    if (string == nil) {
        return NO;
    }
    return [self setData: [string dataUsingEncoding: NSUnicodeStringEncoding]
                 forType: type];
}

- (BOOL) setPropertyList: (id) propertyList forType: (NSPasteboardType) type {
    NSString *errorDesc = nil;
    NSData *data = [NSPropertyListSerialization
            dataFromPropertyList: propertyList
                          format: NSPropertyListXMLFormat_v1_0
                errorDescription: &errorDesc];
    if (data == nil || errorDesc != nil) {
        return NO;
    }
    return [self setData: data forType: type];
}

- (NSData *) dataForType: (NSPasteboardType) type {
    NSData *data = [_data objectForKey: type];
    if (data != nil) {
        return data;
    }

    id<NSPasteboardItemDataProvider> provider = [_providers objectForKey: type];
    if (provider != nil) {
        // Retain so the provider can't go away while it fulfils the promise.
        [[provider retain] autorelease];
        [provider pasteboard: _pasteboard item: self provideDataForType: type];
        [_providers removeObjectForKey: type];
        return [_data objectForKey: type];
    }

    if (_pasteboard != nil && [[_pasteboard types] containsObject: type]) {
        return [_pasteboard dataForType: type];
    }
    return nil;
}

- (NSString *) stringForType: (NSPasteboardType) type {
    NSData *data = [self dataForType: type];
    if (data == nil) {
        return nil;
    }
    return [[[NSString alloc] initWithData: data
                                  encoding: NSUnicodeStringEncoding]
            autorelease];
}

- (id) propertyListForType: (NSPasteboardType) type {
    NSData *data = [self dataForType: type];
    if (data == nil) {
        return nil;
    }
    NSString *errorDesc = nil;
    id plist = [NSPropertyListSerialization
            propertyListFromData: data
                mutabilityOption: NSPropertyListImmutable
                          format: NULL
                errorDescription: &errorDesc];
    if (plist != nil && errorDesc == nil) {
        return plist;
    }
    return nil;
}

#pragma mark NSPasteboardWriting

- (NSArray<NSPasteboardType> *) writableTypesForPasteboard:
        (NSPasteboard *) pasteboard {
    return [self types];
}

- (NSPasteboardWritingOptions) writingOptionsForType: (NSPasteboardType) type
                                          pasteboard: (NSPasteboard *) pasteboard {
    return 0;
}

- (id) pasteboardPropertyListForType: (NSPasteboardType) type {
    return [self dataForType: type];
}

#pragma mark NSPasteboardReading

+ (NSArray<NSPasteboardType> *) readableTypesForPasteboard:
        (NSPasteboard *) pasteboard {
    return [pasteboard types];
}

+ (NSPasteboardReadingOptions) readingOptionsForType: (NSPasteboardType) type
                                          pasteboard: (NSPasteboard *) pasteboard {
    return 0;
}

- (id) initWithPasteboardPropertyList: (id) propertyList
                               ofType: (NSPasteboardType) type {
    self = [self init];
    if (self) {
        if ([propertyList isKindOfClass: [NSData class]]) {
            [self setData: propertyList forType: type];
        } else if ([propertyList isKindOfClass: [NSString class]]) {
            [self setString: propertyList forType: type];
        } else if (propertyList != nil) {
            [self setPropertyList: propertyList forType: type];
        }
    }
    return self;
}

@end
