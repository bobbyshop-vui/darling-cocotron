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

#import <CoreData/NSBatchDeleteRequest.h>
#import <CoreData/NSManagedObjectContext.h>
#import <CoreData/NSFetchRequest.h>
#import <CoreData/NSManagedObjectID.h>
#import <CoreData/NSEntityDescription.h>
#import <CoreData/NSManagedObject.h>

@implementation NSBatchDeleteRequest

- (instancetype) initWithFetchRequest: (NSFetchRequest *) fetch {
    if ((self = [super init])) {
        _deleteTarget = [fetch copy];
        _resultType = NSBatchDeleteResultTypeStatusOnly;
    }
    return self;
}

- (instancetype) initWithObjectIDs: (NSArray *) objects {
    NSFetchRequest *fetch = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = nil;
    if ([objects count] > 0) {
        entity = [(NSManagedObjectID *) [objects objectAtIndex: 0] entity];
    }
    [fetch setEntity: entity];
    [fetch setPredicate: [NSPredicate predicateWithFormat: @"self IN %@", objects]];
    return [self initWithFetchRequest: fetch];
}

- (void) dealloc {
    [_deleteTarget release];
    [super dealloc];
}

- (NSPersistentStoreRequestType) requestType {
    return NSBatchDeleteRequestType;
}

- (id) copyWithZone: (NSZone *) zone {
    NSBatchDeleteRequest *copy = [super copyWithZone: zone];
    copy->_resultType = _resultType;
    copy->_deleteTarget = [_deleteTarget copy];
    return copy;
}

- (NSBatchDeleteRequestResultType) resultType {
    return _resultType;
}

- (void) setResultType: (NSBatchDeleteRequestResultType) value {
    _resultType = value;
}

- (NSFetchRequest *) fetchRequest {
    return [[_deleteTarget copy] autorelease];
}

@end
