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

@class NSManagedObjectID;
@class NSPropertyDescription;

@interface NSIncrementalStoreNode : NSObject {
    NSManagedObjectID *_objectID;
    uint64_t _versionNumber;
    id _propertyCache;
    void *_reserved1;
}

- (instancetype) initWithObjectID: (NSManagedObjectID *) objectID
                       withValues: (NSDictionary<NSString *, id> *) values
                          version: (uint64_t) version;

- (void) updateWithValues: (NSDictionary<NSString *, id> *) values
                  version: (uint64_t) version;

@property (nonatomic, readonly, strong) NSManagedObjectID *objectID;
@property (nonatomic, readonly) uint64_t version;

- (nullable id) valueForPropertyDescription: (NSPropertyDescription *) prop;

@end
