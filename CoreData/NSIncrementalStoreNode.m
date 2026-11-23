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

#import <CoreData/NSIncrementalStoreNode.h>
#import <CoreData/NSManagedObjectID.h>
#import <CoreData/NSPropertyDescription.h>

@implementation NSIncrementalStoreNode

- (instancetype) initWithObjectID: (NSManagedObjectID *) objectID
                       withValues: (NSDictionary *) values
                          version: (uint64_t) version {
    if ((self = [super init])) {
        _objectID = [objectID retain];
        _versionNumber = version;
        _propertyCache = [values copy];
    }
    return self;
}

- (void) dealloc {
    [_objectID release];
    [_propertyCache release];
    [super dealloc];
}

- (void) updateWithValues: (NSDictionary *) values version: (uint64_t) version {
    if (_propertyCache != values) {
        [_propertyCache release];
        _propertyCache = [values copy];
    }
    _versionNumber = version;
}

- (NSManagedObjectID *) objectID {
    return _objectID;
}

- (uint64_t) version {
    return _versionNumber;
}

- (id) valueForPropertyDescription: (NSPropertyDescription *) prop {
    return [(NSDictionary *) _propertyCache objectForKey: [prop name]];
}

@end
