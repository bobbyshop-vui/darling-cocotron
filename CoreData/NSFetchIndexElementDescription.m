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

#import <CoreData/NSFetchIndexElementDescription.h>
#import <CoreData/NSPropertyDescription.h>

@implementation NSFetchIndexElementDescription

- (instancetype) initWithProperty: (NSPropertyDescription *) property
                    collationType: (NSFetchIndexElementType) collationType {
    if ((self = [super init])) {
        _property = [property retain];
        _propertyName = [[property name] copy];
        _collationType = collationType;
        _ascending = YES;
    }
    return self;
}

- (instancetype) init {
    return [self initWithProperty: nil collationType: NSFetchIndexElementTypeBinary];
}

- (void) dealloc {
    [_property release];
    [_propertyName release];
    [super dealloc];
}

- (instancetype) initWithCoder: (NSCoder *) coder {
    if ((self = [super init])) {
        _property = [[coder decodeObjectForKey: @"NSProperty"] retain];
        _propertyName = [[coder decodeObjectForKey: @"NSPropertyName"] copy];
        if (_propertyName == nil) {
            _propertyName = [[_property name] copy];
        }
        _collationType = (NSFetchIndexElementType) [coder decodeIntegerForKey: @"NSCollationType"];
        _ascending = [coder containsValueForKey: @"NSAscending"]
                             ? [coder decodeBoolForKey: @"NSAscending"]
                             : YES;
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder {
    if (_property != nil) {
        [coder encodeObject: _property forKey: @"NSProperty"];
    }
    if (_propertyName != nil) {
        [coder encodeObject: _propertyName forKey: @"NSPropertyName"];
    }
    [coder encodeInteger: (NSInteger) _collationType forKey: @"NSCollationType"];
    [coder encodeBool: _ascending forKey: @"NSAscending"];
}

- (NSPropertyDescription *) property {
    return _property;
}

- (NSString *) propertyName {
    return _propertyName;
}

- (NSFetchIndexElementType) collationType {
    return _collationType;
}

- (void) setCollationType: (NSFetchIndexElementType) value {
    _collationType = value;
}

- (BOOL) isAscending {
    return _ascending;
}

- (void) setAscending: (BOOL) value {
    _ascending = value;
}

- (NSFetchIndexDescription *) indexDescription {
    return _indexDescription;
}

@end
