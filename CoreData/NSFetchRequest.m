/* Copyright (c) 2008 Dan Knapp

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <CoreData/NSEntityDescription.h>
#import <CoreData/NSFetchRequest.h>
#import <CoreData/NSManagedObject.h>
#import <CoreData/NSManagedObjectContext.h>
#import <Foundation/NSRaise.h>

@implementation NSFetchRequest

- init {
    if ((self = [super init]) == nil)
        return nil;
    _entity = nil;
    _predicate = nil;
    _sortDescriptors = nil;
    _fetchLimit = 0;
    return self;
}

+ (instancetype) fetchRequestWithEntityName: (NSString *) entityName {
    return [[[self alloc] initWithEntityName: entityName] autorelease];
}

- (instancetype) initWithEntityName: (NSString *) entityName {
    if ((self = [self init]) != nil)
        _fetchEntityName = [entityName copy];
    return self;
}

- (NSString *) entityName {
    return _entity != nil ? [_entity name] : _fetchEntityName;
}

- (void) setEntityName: (NSString *) value {
    value = [value copy];
    [_fetchEntityName release];
    _fetchEntityName = value;
}

- (NSArray *) execute: (NSError **) error {
    NSValue *current = [[[NSThread currentThread] threadDictionary]
            objectForKey: @"NSManagedObjectContextCurrentContext"];
    NSManagedObjectContext *context = [current nonretainedObjectValue];

    if (context == nil) {
        if (error != NULL)
            *error = [NSError
                    errorWithDomain: NSCocoaErrorDomain
                               code: 134060
                           userInfo: [NSDictionary
                                             dictionaryWithObject:
                                                     @"No managed object "
                                                     @"context to execute "
                                                     @"the fetch request in."
                                                           forKey:
                                                                   NSLocalizedDescriptionKey]];
        return nil;
    }

    return [context executeFetchRequest: self error: error];
}

- initWithCoder: (NSCoder *) coder {
    NSUnimplementedMethod();
    return nil;
}

- (void) encodeWithCoder: (NSCoder *) coder {
    NSUnimplementedMethod();
}

- copyWithZone: (NSZone *) zone {
    NSFetchRequest *result = NSCopyObject(self, 0, zone);

    result->_entity = [_entity retain];
    result->_fetchEntityName = [_fetchEntityName copy];
    result->_predicate = [_predicate copy];
    result->_sortDescriptors = [_sortDescriptors copy];
    result->_affectedStores = [_affectedStores copy];
    result->_propertiesToFetch = [_propertiesToFetch copy];
    result->_relationshipKeyPathsForPrefetching =
            [_relationshipKeyPathsForPrefetching copy];

    return result;
}

- (void) dealloc {
    [_entity release];
    [_fetchEntityName release];
    [_predicate release];
    [_sortDescriptors release];
    [super dealloc];
}

- (NSPersistentStoreRequestType) requestType {
    return NSFetchRequestType;
}

- (NSFetchRequestResultType) resultType {
    return _resultType;
}

- (NSEntityDescription *) entity {
    if (_entity == nil && _fetchEntityName != nil) {
        NSValue *current = [[[NSThread currentThread] threadDictionary]
                objectForKey: @"NSManagedObjectContextCurrentContext"];
        NSManagedObjectContext *context = [current nonretainedObjectValue];

        if (context != nil)
            return [NSEntityDescription entityForName: _fetchEntityName
                               inManagedObjectContext: context];
    }
    return _entity;
}

- (NSPredicate *) predicate {
    return _predicate;
}

- (NSArray *) sortDescriptors {
    return _sortDescriptors;
}

- (NSUInteger) fetchLimit {
    return _fetchLimit;
}

- (NSUInteger) fetchBatchSize {
    return _fetchBatchSize;
}

- (NSUInteger) fetchOffset {
    return _fetchOffset;
}

- (BOOL) includesPendingChanges {
    return _includesPendingChanges;
}

- (BOOL) includesPropertyValues {
    return _includesPropertyValues;
}

- (BOOL) includesSubentities {
    return _includesSubentities;
}

- (BOOL) returnsDistinctResults {
    return _returnsDistinctResults;
}

- (BOOL) returnsObjectsAsFaults {
    return _returnsObjectsAsFaults;
}

- (NSArray *) propertiesToFetch {
    return _propertiesToFetch;
}

- (NSArray *) relationshipKeyPathsForPrefetching {
    return _relationshipKeyPathsForPrefetching;
}

- (void) setResultType: (NSFetchRequestResultType) type {
    _resultType = type;
}

- (void) setEntity: (NSEntityDescription *) value {
    value = [value retain];
    [_entity release];
    _entity = value;
}

- (void) setPredicate: (NSPredicate *) value {
    value = [value retain];
    [_predicate release];
    _predicate = value;
}

- (void) setSortDescriptors: (NSArray *) value {
    value = [value copy];
    [_sortDescriptors release];
    _sortDescriptors = value;
}

- (void) setFetchLimit: (NSUInteger) value {
    _fetchLimit = value;
}

- (void) setFetchBatchSize: (NSUInteger) value {
    _fetchBatchSize = value;
}

- (void) setFetchOffset: (NSUInteger) value {
    _fetchOffset = value;
}

- (void) setIncludesPendingChanges: (BOOL) value {
    _includesPendingChanges = value;
}

- (void) setIncludesPropertyValues: (BOOL) value {
    _includesPropertyValues = value;
}

- (void) setIncludesSubentities: (BOOL) value {
    _includesSubentities = value;
}

- (void) setReturnsDistinctResults: (BOOL) value {
    _returnsDistinctResults = value;
}

- (void) setReturnsObjectsAsFaults: (BOOL) value {
    _returnsObjectsAsFaults = value;
}

- (void) setPropertiesToFetch: (NSArray *) value {
    value = [value copy];
    [_propertiesToFetch release];
    _propertiesToFetch = value;
}

- (void) setRelationshipKeyPathsForPrefetching: (NSArray *) value {
    value = [value copy];
    [_relationshipKeyPathsForPrefetching release];
    _relationshipKeyPathsForPrefetching = value;
}

- (NSUInteger) _countInContext: (NSManagedObjectContext *) _context {
    NSLog(@"Stub called: _countInContext in %@", [self class]);
    return 0;
}

@end
