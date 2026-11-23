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

#import <CoreData/NSConstraintConflict.h>
#import <CoreData/NSManagedObject.h>

@implementation NSConstraintConflict

- (instancetype) init {
    return [self initWithConstraint: @[]
                     databaseObject: nil
                   databaseSnapshot: nil
                 conflictingObjects: @[]
               conflictingSnapshots: @[]];
}

- (instancetype) initWithConstraint: (NSArray *) constraint
                     databaseObject: (NSManagedObject *) databaseObject
                   databaseSnapshot: (NSDictionary *) databaseSnapshot
                 conflictingObjects: (NSArray *) conflictingObjects
               conflictingSnapshots: (NSArray *) conflictingSnapshots {
    if ((self = [super init])) {
        _constraint = [constraint copy];
        _databaseObject = [databaseObject retain];
        _databaseSnapshot = [databaseSnapshot copy];
        _conflictingObjects = [conflictingObjects copy];
        _conflictingSnapshots = [conflictingSnapshots copy];

        // Constraint values: the values the conflicting object had for the
        // constrained properties when the conflict was created.
        NSMutableDictionary *values = [NSMutableDictionary dictionary];
        id source = [_conflictingObjects firstObject];
        for (NSString *key in _constraint) {
            id value = nil;
            if (source != nil)
                value = [source valueForKey: key];
            if (value == nil && _databaseSnapshot != nil)
                value = [_databaseSnapshot objectForKey: key];
            if (value != nil)
                [values setObject: value forKey: key];
        }
        _conflictedValues = [values copy];
    }
    return self;
}

- (void) dealloc {
    [_constraint release];
    [_databaseObject release];
    [_databaseSnapshot release];
    [_conflictedValues release];
    [_conflictingObjects release];
    [_conflictingSnapshots release];
    [super dealloc];
}

- (NSArray *) constraint {
    return _constraint;
}

- (NSDictionary *) constraintValues {
    return _conflictedValues;
}

- (NSManagedObject *) databaseObject {
    return _databaseObject;
}

- (NSDictionary *) databaseSnapshot {
    return _databaseSnapshot;
}

- (NSArray *) conflictingObjects {
    return _conflictingObjects;
}

- (NSArray *) conflictingSnapshots {
    return _conflictingSnapshots;
}

@end
