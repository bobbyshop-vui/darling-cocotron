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

#import <CoreData/NSFetchIndexDescription.h>
#import <CoreData/NSEntityDescription.h>

@implementation NSFetchIndexDescription

- (instancetype) initWithName: (NSString *) name elements: (NSArray *) elements {
    if ((self = [super init])) {
        _name = [name copy];
        _elements = elements ? [elements copy] : [[NSArray alloc] init];
    }
    return self;
}

- (instancetype) init {
    return [self initWithName: nil elements: nil];
}

- (void) dealloc {
    [_name release];
    [_elements release];
    [_partialIndexPredicate release];
    [super dealloc];
}

- (instancetype) initWithCoder: (NSCoder *) coder {
    if ((self = [super init])) {
        _name = [[coder decodeObjectForKey: @"NSName"] copy];
        _elements = [[coder decodeObjectForKey: @"NSElements"] copy];
        if (_elements == nil) {
            _elements = [[NSArray alloc] init];
        }
        _partialIndexPredicate = [[coder decodeObjectForKey: @"NSPartialIndexPredicate"] copy];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder {
    [coder encodeObject: _name forKey: @"NSName"];
    [coder encodeObject: _elements forKey: @"NSElements"];
    [coder encodeObject: _partialIndexPredicate forKey: @"NSPartialIndexPredicate"];
}

- (NSString *) name {
    return _name;
}

- (void) setName: (NSString *) name {
    if (_name != name) {
        [_name release];
        _name = [name copy];
    }
}

- (NSArray *) elements {
    return _elements;
}

- (void) setElements: (NSArray *) elements {
    if (_elements != elements) {
        [_elements release];
        _elements = elements ? [elements copy] : [[NSArray alloc] init];
    }
}

- (NSEntityDescription *) entity {
    return _entity;
}

- (NSPredicate *) partialIndexPredicate {
    return _partialIndexPredicate;
}

- (void) setPartialIndexPredicate: (NSPredicate *) predicate {
    if (_partialIndexPredicate != predicate) {
        [_partialIndexPredicate release];
        _partialIndexPredicate = [predicate copy];
    }
}

@end
