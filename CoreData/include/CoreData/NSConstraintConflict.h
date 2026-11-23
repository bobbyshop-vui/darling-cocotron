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

#import <Foundation/Foundation.h>

@class NSManagedObject;

@interface NSConstraintConflict : NSObject {
    NSArray *_constraint;
    NSManagedObject *_databaseObject;
    NSDictionary *_databaseSnapshot;
    NSDictionary *_conflictedValues;
    NSArray *_conflictingObjects;
    NSArray *_conflictingSnapshots;
}

@property (readonly, copy) NSArray<NSString *> *constraint;
@property (readonly, copy) NSDictionary<NSString *, id> *constraintValues;
@property (nullable, readonly, retain) NSManagedObject *databaseObject;
@property (nullable, readonly, retain) NSDictionary<NSString *, id> *databaseSnapshot;
@property (readonly, copy) NSArray<NSManagedObject *> *conflictingObjects;
@property (readonly, copy) NSArray<NSDictionary *> *conflictingSnapshots;

- (instancetype) initWithConstraint: (NSArray<NSString *> *) contraint
                     databaseObject: (NSManagedObject *) databaseObject
                   databaseSnapshot: (NSDictionary *) databaseSnapshot
                 conflictingObjects: (NSArray<NSManagedObject *> *) conflictingObjects
               conflictingSnapshots: (NSArray *) conflictingSnapshots NS_DESIGNATED_INITIALIZER;

@end
