/*
 This file is part of Darling.

 Copyright (C) 2025 Darling Developers

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

#import <CoreData/NSMappingModel.h>
#import <CoreData/NSEntityMapping.h>
#import <Foundation/Foundation.h>

@implementation NSMappingModel

- (instancetype) init {
    if ((self = [super init]) != nil)
        _entityMappings = [[NSArray alloc] init];
    return self;
}

- (instancetype) initWithContentsOfURL: (NSURL *) url {
    if (url == nil) {
        [self release];
        return nil;
    }

    NSData *data = [[NSData alloc] initWithContentsOfURL: url];

    if (data == nil) {
        [self release];
        return nil;
    }

    NSKeyedUnarchiver *unarchiver =
            [[NSKeyedUnarchiver alloc] initForReadingWithData: data];
    id root = [unarchiver decodeObjectForKey: @"root"];
    NSArray *mappings = nil;

    if ([root isKindOfClass: [NSMappingModel class]])
        mappings = [(NSMappingModel *) root entityMappings];
    else
        mappings = [unarchiver decodeObjectForKey: @"NSEntityMappings"];

    [unarchiver release];
    [data release];

    if (root == nil && mappings == nil) {
        [self release];
        return nil;
    }

    if ((self = [self init]) != nil)
        [self setEntityMappings: mappings];
    return self;
}

- (instancetype) initWithCoder: (NSCoder *) coder {
    if ((self = [self init]) != nil) {
        if ([coder allowsKeyedCoding])
            [self setEntityMappings:
                          [coder decodeObjectForKey: @"NSEntityMappings"]];
    }
    return self;
}

- (void) dealloc {
    [_entityMappings release];
    [super dealloc];
}

- (NSArray *) entityMappings {
    return _entityMappings;
}

- (void) setEntityMappings: (NSArray *) value {
    value = value != nil ? [value copy] : [[NSArray alloc] init];
    [_entityMappings release];
    _entityMappings = value;
}

- (NSDictionary *) entityMappingsByName {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];

    for (NSEntityMapping *mapping in _entityMappings) {
        NSString *name = [mapping name];

        if (name != nil)
            [result setObject: mapping forKey: name];
    }
    return result;
}

@end
