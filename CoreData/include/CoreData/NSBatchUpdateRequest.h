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
#import <CoreData/NSPersistentStoreRequest.h>
#import <CoreData/NSPersistentStoreResult.h>

@class NSEntityDescription;


@interface NSBatchUpdateRequest : NSPersistentStoreRequest {
    id _entity;
    BOOL _entityIsName;
    NSPredicate *_predicate;
    BOOL _includesSubentities;
    NSBatchUpdateRequestResultType _resultType;
    NSDictionary *_propertiesToUpdate;
}

+ (instancetype) batchUpdateRequestWithEntityName: (NSString *) entityName;
- (instancetype) initWithEntityName: (NSString *) entityName;
- (instancetype) initWithEntity: (NSEntityDescription *) entity;

@property (copy, readonly) NSString *entityName;
@property (strong, readonly) NSEntityDescription *entity;
@property (nullable, strong) NSPredicate *predicate;
@property BOOL includesSubentities;
@property NSBatchUpdateRequestResultType resultType;
@property (nullable, copy) NSDictionary *propertiesToUpdate;

@end
