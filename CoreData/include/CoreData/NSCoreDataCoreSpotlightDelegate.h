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

@class NSManagedObjectContext;
@class NSPersistentStoreDescription;
@class NSManagedObjectModel;
@class NSManagedObject;
@class CSSearchableIndex;
@class CSSearchableItemAttributeSet;

@interface NSCoreDataCoreSpotlightDelegate : NSObject {
    NSManagedObjectContext *_context;
    NSString *_domainIdentifier;
    NSString *_indexName;
}

- (NSString *) domainIdentifier;
- (nullable NSString *) indexName;

- (instancetype) initForStoreWithDescription: (NSPersistentStoreDescription *) description
                                       model: (NSManagedObjectModel *) model NS_DESIGNATED_INITIALIZER;

- (nullable CSSearchableItemAttributeSet *) attributeSetForObject: (NSManagedObject *) object;

- (void) searchableIndex: (CSSearchableIndex *) searchableIndex
    reindexAllSearchableItemsWithAcknowledgementHandler: (void (^)(void)) acknowledgementHandler;
- (void) searchableIndex: (CSSearchableIndex *) searchableIndex
    reindexSearchableItemsWithIdentifiers: (NSArray<NSString *> *) identifiers
                   acknowledgementHandler: (void (^)(void)) acknowledgementHandler;

@end
