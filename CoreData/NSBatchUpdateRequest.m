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

#import <CoreData/NSBatchUpdateRequest.h>
#import <CoreData/NSEntityDescription.h>

@implementation NSBatchUpdateRequest

+ (instancetype) batchUpdateRequestWithEntityName: (NSString *) entityName {
    return [[[self alloc] initWithEntityName: entityName] autorelease];
}

- (instancetype) initWithEntityName: (NSString *) entityName {
    if ((self = [super init])) {
        _entity = [entityName copy];
        _entityIsName = YES;
        _includesSubentities = YES;
        _resultType = NSStatusOnlyResultType;
    }
    return self;
}

- (instancetype) initWithEntity: (NSEntityDescription *) entity {
    if ((self = [super init])) {
        _entity = [entity retain];
        _entityIsName = NO;
        _includesSubentities = YES;
        _resultType = NSStatusOnlyResultType;
    }
    return self;
}

- (instancetype) init {
    return [self initWithEntityName: nil];
}

- (void) dealloc {
    [_entity release];
    [_predicate release];
    [_propertiesToUpdate release];
    [super dealloc];
}

- (NSPersistentStoreRequestType) requestType {
    return NSBatchUpdateRequestType;
}

- (id) copyWithZone: (NSZone *) zone {
    NSBatchUpdateRequest *copy = [super copyWithZone: zone];
    copy->_entity = [_entity copy];
    copy->_entityIsName = _entityIsName;
    copy->_predicate = [_predicate copy];
    copy->_includesSubentities = _includesSubentities;
    copy->_resultType = _resultType;
    copy->_propertiesToUpdate = [_propertiesToUpdate copy];
    return copy;
}

- (NSString *) entityName {
    if (_entityIsName) {
        return _entity;
    }
    return [(NSEntityDescription *) _entity name];
}

- (NSEntityDescription *) entity {
    if (_entityIsName) {
        return nil;
    }
    return _entity;
}

- (NSPredicate *) predicate {
    return _predicate;
}

- (void) setPredicate: (NSPredicate *) predicate {
    if (_predicate != predicate) {
        [_predicate release];
        _predicate = [predicate retain];
    }
}

- (BOOL) includesSubentities {
    return _includesSubentities;
}

- (void) setIncludesSubentities: (BOOL) includesSubentities {
    _includesSubentities = includesSubentities;
}

- (NSBatchUpdateRequestResultType) resultType {
    return _resultType;
}

- (void) setResultType: (NSBatchUpdateRequestResultType) resultType {
    _resultType = resultType;
}

- (NSDictionary *) propertiesToUpdate {
    return _propertiesToUpdate;
}

- (void) setPropertiesToUpdate: (NSDictionary *) propertiesToUpdate {
    if (_propertiesToUpdate != propertiesToUpdate) {
        [_propertiesToUpdate release];
        _propertiesToUpdate = [propertiesToUpdate copy];
    }
}

@end
