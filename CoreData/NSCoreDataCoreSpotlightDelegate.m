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

#import <CoreData/NSCoreDataCoreSpotlightDelegate.h>
#import <CoreData/NSPersistentStoreDescription.h>

@implementation NSCoreDataCoreSpotlightDelegate

- (instancetype) init {
    return [self initForStoreWithDescription: nil model: nil];
}

- (instancetype) initForStoreWithDescription: (NSPersistentStoreDescription *) description
                                       model: (NSManagedObjectModel *) model {
    if ((self = [super init])) {
        // The index name defaults to the store's identifier; the store URL
        // is the identifier available to us.
        _indexName = [[[description URL] absoluteString] copy];
        // _domainIdentifier stays nil by default.
    }
    return self;
}

- (void) dealloc {
    [_context release];
    [_domainIdentifier release];
    [_indexName release];
    [super dealloc];
}

- (NSString *) domainIdentifier {
    return _domainIdentifier;
}

- (NSString *) indexName {
    return _indexName;
}

- (CSSearchableItemAttributeSet *) attributeSetForObject: (NSManagedObject *) object {
    // No attributes by default: subclasses override to opt objects into the index.
    return nil;
}

- (void) searchableIndex: (CSSearchableIndex *) searchableIndex
    reindexAllSearchableItemsWithAcknowledgementHandler: (void (^)(void)) acknowledgementHandler {
    // There is no Spotlight service to repopulate; acknowledge the request.
    if (acknowledgementHandler != nil)
        acknowledgementHandler();
}

- (void) searchableIndex: (CSSearchableIndex *) searchableIndex
    reindexSearchableItemsWithIdentifiers: (NSArray *) identifiers
                   acknowledgementHandler: (void (^)(void)) acknowledgementHandler {
    if (acknowledgementHandler != nil)
        acknowledgementHandler();
}

@end
