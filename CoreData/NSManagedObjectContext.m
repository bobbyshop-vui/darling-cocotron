/* Copyright(c)2008 Dan Knapp

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files(the "Software"), to deal in the
Software without restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import "NSEntityDescription-Private.h"
#import "NSManagedObject-Private.h"
#import "NSManagedObjectID-Private.h"
#import "NSPersistentStoreCoordinator-Private.h"
#import <CoreData/CoreDataErrors.h>
#import <CoreData/NSAtomicStore.h>
#import <CoreData/NSEntityDescription.h>
#import <CoreData/NSFetchRequest.h>
#import <CoreData/NSManagedObject.h>
#import <CoreData/NSManagedObjectContext.h>
#import <CoreData/NSManagedObjectModel.h>
#import <CoreData/NSPersistentStore.h>
#import <CoreData/NSRelationshipDescription.h>
#import <Foundation/NSRaise.h>
#import <Foundation/NSUndoManager.h>

NSString *const NSManagedObjectContextWillSaveNotification =
        @"NSManagedObjectContextWillSaveNotification";
NSString *const NSManagedObjectContextDidSaveNotification =
        @"NSManagedObjectContextDidSaveNotification";

NSString *const NSInsertedObjectsKey = @"NSInsertedObjectsKey";
NSString *const NSUpdatedObjectsKey = @"NSUpdatedObjectsKey";
NSString *const NSDeletedObjectsKey = @"NSDeletedObjectsKey";
NSString *const NSRefreshedObjectsKey = @"NSRefreshedObjectsKey";
NSString *const NSInvalidatedObjectsKey = @"NSInvalidatedObjectsKey";
NSString *const NSInvalidatedAllObjectsKey = @"NSInvalidatedAllObjectsKey";
NSString *const NSAffectedObjectsErrorKey = @"NSAffectedObjectsErrorKey";

@interface NSAtomicStore (private)
- (void) _uniqueObjectID: (NSManagedObjectID *) objectID;
@end

/*
 * Key under which the most recently used context of a thread is remembered, so
 * +[NSManagedObject entity], +[NSManagedObject fetchRequest] and
 * -[NSFetchRequest execute:] can find the context they implicitly operate on.
 */
static NSString *const NSManagedObjectContextThreadKey =
        @"NSManagedObjectContextCurrentContext";

static void NSManagedObjectContextSetCurrent(NSManagedObjectContext *context) {
    NSMutableDictionary *dict = [[NSThread currentThread] threadDictionary];

    if (context == nil)
        [dict removeObjectForKey: NSManagedObjectContextThreadKey];
    else
        [dict setObject: [NSValue valueWithNonretainedObject: context]
                 forKey: NSManagedObjectContextThreadKey];
}

@interface NSManagedObject (NSManagedObjectContextState)
- (void) _mocClearPendingChanges;
- (void) _mocInvalidate;
- (void) _mocRefault;
@end

@implementation NSManagedObject (NSManagedObjectContextState)

- (void) _mocClearPendingChanges {
    [_changedValues removeAllObjects];
    _isInserted = NO;
    _isUpdated = NO;
    _isDeleted = NO;
    _isFault = NO;
}

- (void) _mocInvalidate {
    if (!_isFault)
        [self willTurnIntoFault];
    [_changedValues removeAllObjects];
    [_committedValues release];
    _committedValues = nil;
    _context = nil;
    _isInserted = NO;
    _isUpdated = NO;
    _isDeleted = NO;
    _isFault = YES;
    [self didTurnIntoFault];
}

- (void) _mocRefault {
    if (!_isFault)
        [self willTurnIntoFault];
    [_changedValues removeAllObjects];
    [_committedValues release];
    _committedValues = nil;
    _isInserted = NO;
    _isUpdated = NO;
    _isDeleted = NO;
    _isFault = YES;
    [self didTurnIntoFault];
}

@end

static void NSManagedObjectContextRemoveObservers(NSManagedObject *object,
                                                  NSManagedObjectContext *context) {
    NSArray *keys = [[[object entity] propertiesByName] allKeys];
    for (NSString *key in keys)
        [object removeObserver: context forKeyPath: key];
}

static NSManagedObjectID *NSManagedObjectContextObjectIDForSaveValue(id value) {
    if ([value isKindOfClass: [NSManagedObject class]])
        return [value objectID];
    if ([value isKindOfClass: [NSManagedObjectID class]])
        return value;
    return nil;
}

static BOOL NSManagedObjectContextHasLocalChanges(
        NSManagedObjectContext *context, NSManagedObject *object) {
    return [object hasChanges] ||
           [[context insertedObjects] containsObject: object] ||
           [[context updatedObjects] containsObject: object] ||
           [[context deletedObjects] containsObject: object];
}

static id NSManagedObjectContextValueForCommittedProperty(
        NSManagedObjectContext *context, NSPropertyDescription *property,
        id value) {
    if (![property isKindOfClass: [NSRelationshipDescription class]] ||
        value == nil)
        return value;

    NSRelationshipDescription *relationship = (NSRelationshipDescription *) property;
    if ([relationship isToMany]) {
        NSMutableSet *objects = [NSMutableSet set];
        for (NSManagedObjectID *objectID in value)
            [objects addObject: [context objectWithID: objectID]];
        return objects;
    }
    return [context objectWithID: value];
}

@implementation NSManagedObjectContext

- init {
    _lock = [[NSLock alloc] init];
    _storeCoordinator = nil;
    _undoManager = [[NSUndoManager alloc] init];
    _registeredObjects = [[NSMutableSet alloc] init];
    _insertedObjects = [[NSMutableSet alloc] init];
    _updatedObjects = [[NSMutableSet alloc] init];
    _deletedObjects = [[NSMutableSet alloc] init];
    _editors = [[NSMutableArray alloc] init];

    _objectIdToObject = NSCreateMapTable(NSObjectMapKeyCallBacks,
                                         NSObjectMapValueCallBacks, 0);
    _requestedProcessPendingChanges = NO;
    _contextUserInfo = [[NSMutableDictionary alloc] init];
    NSManagedObjectContextSetCurrent(self);
    return self;
}

/*
 * The designated initialiser on macOS 10.7+.  Xcode's Core Data usage (and
 * many modern apps) call this instead of -init, so without it the runtime
 * raises "-[NSManagedObjectContext initWithConcurrencyType:]: unrecognized
 * selector" and startup aborts.  The concurrency type only affects how
 * performBlock:/performBlockAndWait: queue work; we accept it and fall back to
 * the plain initialiser.
 */
- (instancetype) initWithConcurrencyType: (NSUInteger) concurrencyType {
    (void) concurrencyType;
    return [self init];
}

/*
 * The block-based API.  Without any queue of our own there is no private queue
 * to hop to, so both variants simply run the block on the calling thread.
 * Running -performBlock: synchronously as well keeps ordering deterministic,
 * which is what callers depend on in practice.
 */
- (void) performBlock: (void (^)(void)) block {
    if (block == nil) {
        return;
    }
    NSManagedObjectContextSetCurrent(self);
    block();
}

- (void) performBlockAndWait: (void (^)(void)) block {
    if (block == nil) {
        return;
    }
    NSManagedObjectContextSetCurrent(self);
    block();
}

- (void) dealloc {
    NSValue *current = [[[NSThread currentThread] threadDictionary]
            objectForKey: NSManagedObjectContextThreadKey];

    if ([current nonretainedObjectValue] == self)
        NSManagedObjectContextSetCurrent(nil);
    [_contextName release];
    [_parentContext release];
    [_contextUserInfo release];
    [_storeCoordinator release];
    [_undoManager release];
    [_registeredObjects release];
    [_insertedObjects release];
    [_updatedObjects release];
    [_deletedObjects release];
    [_editors release];
    [_objectIdToObject release];
    [super dealloc];
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
    return _storeCoordinator;
}

- (NSUndoManager *) undoManager {
    return _undoManager;
}

- (BOOL) retainsRegisteredObjects {
    return _retainsRegisteredObjects;
}

- (BOOL) propagatesDeletesAtEndOfEvent {
    return _propagatesDeletesAtEndOfEvent;
}

- (NSTimeInterval) stalenessInterval {
    return _stalenessInterval;
}

- mergePolicy {
    return _mergePolicy;
}

- (void) persistentStoresDidChange: (NSNotification *) note {
    NSArray *stores =
            [[note userInfo] objectForKey: NSRemovedPersistentStoresKey];

    for (NSPersistentStore *store in stores) {
        NSArray *allObjects = NSAllMapTableValues(_objectIdToObject);

        for (NSManagedObject *check in allObjects) {
            NSManagedObjectID *objectID = [check objectID];

            if ([objectID persistentStore] == store) {

                NSEntityDescription *entity = [check entity];
                NSArray *properties = [[entity propertiesByName] allKeys];

                for (NSString *key in properties)
                    [check removeObserver: self forKeyPath: key];

                [_registeredObjects removeObject: check];
                [_insertedObjects removeObject: check];
                [_updatedObjects removeObject: check];
                [_deletedObjects removeObject: check];
                NSMapRemove(_objectIdToObject, objectID);
            }
        }
    }
}

- (void) setPersistentStoreCoordinator: (NSPersistentStoreCoordinator *) value {
    if (_storeCoordinator != nil)
        [[NSNotificationCenter defaultCenter]
                removeObserver: self
                          name: NSPersistentStoreCoordinatorStoresDidChangeNotification
                        object: _storeCoordinator];

    value = [value retain];
    [_storeCoordinator release];
    _storeCoordinator = value;

    if (_storeCoordinator != nil)
        [[NSNotificationCenter defaultCenter]
                addObserver: self
                   selector: @selector(persistentStoresDidChange:)
                       name: NSPersistentStoreCoordinatorStoresDidChangeNotification
                     object: _storeCoordinator];
}

- (void) setUndoManager: (NSUndoManager *) value {
    value = [value retain];
    [_undoManager release];
    _undoManager = value;
}

- (void) setRetainsRegisteredObjects: (BOOL) value {
    _retainsRegisteredObjects = value;
    // FIXME: actually release/retain if needed
    NSUnimplementedMethod();
}

- (void) setPropagatesDeletesAtEndOfEvent: (BOOL) value {
    _propagatesDeletesAtEndOfEvent = value;
}

- (void) setStalenessInterval: (NSTimeInterval) value {
    _stalenessInterval = value;
}

- (void) setMergePolicy: value {
    value = [value retain];
    [_mergePolicy release];
    _mergePolicy = value;
}

- (NSSet *) registeredObjects {
    return _registeredObjects;
}

- (NSSet *) insertedObjects {
    return _insertedObjects;
}

- (NSSet *) updatedObjects {
    return _updatedObjects;
}

- (NSSet *) deletedObjects {
    return _deletedObjects;
}

- (void) _setHasChanges: (BOOL) value {
    _hasChanges = value;
}

- (BOOL) hasChanges {
    return _hasChanges;
}

- (void) lock {
    [_lock lock];
}

- (void) unlock {
    [_lock unlock];
}

- (BOOL) tryLock {
    return [_lock tryLock];
}

- (void) undo {
    [_undoManager undo];
}

- (void) redo {
    [_undoManager redo];
}

- (void) reset {
    [self processPendingChanges];

    NSArray *objects = [[_registeredObjects allObjects] retain];
    for (NSManagedObject *object in objects) {
        NSManagedObjectContextRemoveObservers(object, self);
        NSMapRemove(_objectIdToObject, [object objectID]);
        [object _mocInvalidate];
    }
    [objects release];

    [_registeredObjects removeAllObjects];
    [_insertedObjects removeAllObjects];
    [_updatedObjects removeAllObjects];
    [_deletedObjects removeAllObjects];
    [_undoManager removeAllActions];
    _hasChanges = NO;
}

- (void) rollback {
    [self processPendingChanges];

    NSArray *insertedObjects = [[_insertedObjects allObjects] retain];
    for (NSManagedObject *object in insertedObjects) {
        NSManagedObjectContextRemoveObservers(object, self);
        NSMapRemove(_objectIdToObject, [object objectID]);
        [_registeredObjects removeObject: object];
        [object _mocInvalidate];
    }
    [insertedObjects release];

    NSArray *objects = [[_registeredObjects allObjects] retain];
    for (NSManagedObject *object in objects) {
        BOOL wasDeleted = [_deletedObjects containsObject: object];
        NSArray *keys = wasDeleted
                                ? [[[object entity] propertiesByName] allKeys]
                                : [[object changedValues] allKeys];
        NSDictionary *committed = [object committedValuesForKeys: nil];

        for (NSString *key in keys) {
            NSPropertyDescription *property =
                    [[[object entity] propertiesByName] objectForKey: key];
            id value = [committed objectForKey: key];
            value = NSManagedObjectContextValueForCommittedProperty(
                    self, property, value);
            [object setValue: value forKey: key];
        }
        [object _mocClearPendingChanges];
    }
    [objects release];

    [_insertedObjects removeAllObjects];
    [_updatedObjects removeAllObjects];
    [_deletedObjects removeAllObjects];
    [_undoManager removeAllActions];
    _hasChanges = NO;
}

- (NSAtomicStoreCacheNode *) _cacheNodeForObjectID:
        (NSManagedObjectID *) objectID
{
    NSAtomicStore *store = (NSAtomicStore *) [_storeCoordinator
            _persistentStoreForObjectID: objectID];

    return [store cacheNodeForObjectID: objectID];
}

- (NSManagedObject *) objectRegisteredForID: (NSManagedObjectID *) objectID {
    return NSMapGet(_objectIdToObject, objectID);
}

- (void) _registerObject: (NSManagedObject *) object {
    [_registeredObjects addObject: object];
    NSMapInsert(_objectIdToObject, [object objectID], object);

    NSEntityDescription *entity = [object entity];
    NSArray *properties = [[entity propertiesByName] allKeys];

    for (NSString *key in properties) {
        [object addObserver: self
                 forKeyPath: key
                    options: NSKeyValueObservingOptionNew |
                             NSKeyValueObservingOptionOld
                    context: nil];
    }
}

- (NSManagedObject *) existingObjectWithID: (NSManagedObjectID *) objectID
                                     error: (NSError **) error
{
    NSManagedObject *result = nil;

    if (objectID != nil) {
        result = [self objectRegisteredForID: objectID];

        if (result != nil && [_deletedObjects containsObject: result])
            result = nil;

        if (result == nil && ![objectID isTemporaryID] &&
            [self _cacheNodeForObjectID: objectID] != nil)
            result = [self objectWithID: objectID];
    }

    if (result == nil && error != NULL)
        *error = [NSError
                errorWithDomain: NSCocoaErrorDomain
                           code: 133000
                       userInfo: [NSDictionary
                                         dictionaryWithObject: @"The object "
                                                               @"does not "
                                                               @"exist in the "
                                                               @"context or "
                                                               @"store."
                                                       forKey:
                                                               NSLocalizedDescriptionKey]];
    return result;
}

- (NSString *) name {
    return _contextName;
}

- (void) setName: (NSString *) value {
    value = [value copy];
    [_contextName release];
    _contextName = value;
}

- (NSManagedObjectContext *) parentContext {
    return _parentContext;
}

- (void) setParentContext: (NSManagedObjectContext *) value {
    value = [value retain];
    [_parentContext release];
    _parentContext = value;
}

- (NSMutableDictionary *) userInfo {
    return _contextUserInfo;
}

- (NSManagedObject *) objectWithID: (NSManagedObjectID *) objectID {
    NSManagedObject *result = NSMapGet(_objectIdToObject, objectID);

    if (result == nil) {
        result = [[NSManagedObject alloc] initWithObjectID: objectID
                                      managedObjectContext: self];
        NSMapInsert(_objectIdToObject, objectID, result);
        [result release];
        [self _registerObject: result];
    }

    return result;
}

- (NSArray *) executeFetchRequest: (NSFetchRequest *) fetchRequest
                            error: (NSError **) error
{
    NSManagedObjectContextSetCurrent(self);

    NSArray *affectedStores = [fetchRequest affectedStores];

    if (affectedStores == nil)
        affectedStores = [_storeCoordinator persistentStores];

    NSMutableSet *resultSet = [NSMutableSet set];

    for (NSManagedObject *check in _insertedObjects) {
        NSEntityDescription *entity = [check entity];

        if ([entity _isKindOfEntity: [fetchRequest entity]]) {
            if (![_deletedObjects containsObject: check]) {
                if ([affectedStores containsObject: [[check objectID]
                                                            persistentStore]]) {
                    [resultSet addObject: check];
                }
            }
        }
    }

    for (NSAtomicStore *store in affectedStores) {
        NSSet *nodes = [store cacheNodes];

        for (NSAtomicStoreCacheNode *node in nodes) {
            NSManagedObjectID *checkID = [node objectID];
            NSEntityDescription *entity = [checkID entity];

            if ([entity _isKindOfEntity: [fetchRequest entity]]) {
                NSManagedObject *check = [self objectWithID: checkID];

                if (![_deletedObjects containsObject: check]) {
                    [resultSet addObject: check];
                }
            }
        }
    }

    NSMutableArray *result =
            [NSMutableArray arrayWithArray: [resultSet allObjects]];

    NSPredicate *p = [fetchRequest predicate];

    if (p != nil)
        [result filterUsingPredicate: p];

    [result sortUsingDescriptors: [fetchRequest sortDescriptors]];

    return result;
}

- (NSUInteger) countForFetchRequest: (NSFetchRequest *) request
                              error: (NSError **) error
{
    return [[self executeFetchRequest: request error: error] count];
}

- (void) insertObject: (NSManagedObject *) object {
    NSPersistentStore *store =
            [_storeCoordinator _persistentStoreForObject: object];

    [[object objectID] setStoreIdentifier: [store identifier]];
    [[object objectID] setPersistentStore: store];

    [_insertedObjects addObject: object];
    [_updatedObjects addObject: object];
    [self _registerObject: object];
}

- (void) deleteObject: (NSManagedObject *) object {
    NSArray *properties = [[object entity] properties];

    for (NSPropertyDescription *property in properties)
        [object setValue: nil forKey: [property name]];

    [_deletedObjects addObject: object];
}

- (void) assignObject: object toPersistentStore: (NSPersistentStore *) store {
    [object retain];

    NSMapRemove(_objectIdToObject, [object objectID]);

    [[object objectID] setStoreIdentifier: [store identifier]];

    [[object objectID] setPersistentStore: store];

    NSMapInsert(_objectIdToObject, [object objectID], object);
    [object release];
}

- (void) detectConflictsForObject: (NSManagedObject *) object {
    // NOT NEEDED
    NSUnimplementedMethod();
}

- (void) refreshObject: (NSManagedObject *) object mergeChanges: (BOOL) flag {
    // NEEDED
    NSUnimplementedMethod();
}

- (void) _requestProcessPendingChanges {
    if (!_requestedProcessPendingChanges) {

        NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
        [runLoop performSelector: @selector(_processPendingChangesForRequest)
                          target: self
                        argument: nil
                           order: 0
                           modes: [NSArray arrayWithObject:
                                                   NSRunLoopCommonModes]];
        _requestedProcessPendingChanges = YES;
    }
}

- (void) _processPendingChanges {
    _requestedProcessPendingChanges = NO;
}

- (void) processPendingChanges {
    if (_requestedProcessPendingChanges) {
        [[NSRunLoop mainRunLoop] cancelPerformSelector: @selector
                                 (_processPendingChangesForRequest)
                                                target: self
                                              argument: nil];
    }

    [self _processPendingChanges];
}

- (void) _processPendingChangesForRequest {
    [self _processPendingChanges];
}

- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *) context
{
    if (NSMapGet(_objectIdToObject, [object objectID]) == object)
        [_updatedObjects addObject: object];
}

- (BOOL) obtainPermanentIDsForObjects: (NSArray *) objects
                                error: (NSError **) error
{

    for (NSManagedObject *check in objects) {
        NSManagedObjectID *checkID = [check objectID];

        if ([checkID isTemporaryID]) {
            NSAtomicStore *store = (NSAtomicStore *) [checkID persistentStore];

            NSMapRemove(_objectIdToObject, checkID);

#if 1
            if (store == nil)
                NSLog(@"internal inconsistency , object had no store %@",
                      check);
#else
            if (store == nil) {
                NSString *storeIdentifier = [checkID storeIdentifier];

                if (storeIdentifier != nil)
                    store = (NSAtomicStore *) [_storeCoordinator
                            _persistentStoreWithIdentifier: storeIdentifier];
                else {
                    store = (NSAtomicStore *) [_storeCoordinator
                            _persistentStoreForObject: check];
                    [checkID setStoreIdentifier: [store identifier]];
                }

                [checkID setPersistentStore: store];
            }
#endif

            id referenceObject =
                    [store newReferenceObjectForManagedObject: check];

            [checkID setReferenceObject: referenceObject];

            [store _uniqueObjectID: checkID];

            NSMapInsert(_objectIdToObject, checkID, check);
        }
    }

    return YES;
}

- (BOOL) save: (NSError **) errorp {
    NSMutableArray *errors = [NSMutableArray array];
    NSMutableArray *errorStores = [NSMutableArray array];
    NSError *idError = nil;
    NSMutableSet *affectedStores = [NSMutableSet set];

    [[NSNotificationCenter defaultCenter]
            postNotificationName: NSManagedObjectContextWillSaveNotification
                          object: self];

    // delete cache nodes
    for (NSManagedObject *deleted in _deletedObjects) {
        NSAtomicStore *store = (NSAtomicStore *) [_storeCoordinator
                _persistentStoreForObject: deleted];
        NSAtomicStoreCacheNode *node =
                [store cacheNodeForObjectID: [deleted objectID]];

        [store willRemoveCacheNodes: [NSSet setWithObject: node]];

        [affectedStores addObject: store];

        // Don't process deleted objects
        NSMapRemove(_objectIdToObject, [deleted objectID]);

        [_insertedObjects removeObject: deleted];
        [_updatedObjects removeObject: deleted];
    }

    if (![self obtainPermanentIDsForObjects: [_insertedObjects allObjects]
                                      error: &idError]) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];

        [userInfo setObject: @"obtainPermanentIDsForObjects failed"
                     forKey: NSLocalizedDescriptionKey];

        if (errorp != NULL)
            *errorp = [NSError
                    errorWithDomain: NSCocoaErrorDomain
                               code: NSPersistentStoreIncompleteSaveError
                           userInfo: userInfo];

        return NO;
    }

    for (NSManagedObject *inserted in _insertedObjects) {
        NSAtomicStore *store = (NSAtomicStore *) [_storeCoordinator
                _persistentStoreForObject: inserted];
        NSAtomicStoreCacheNode *node =
                [store newCacheNodeForManagedObject: inserted];

        [store addCacheNodes: [NSSet setWithObject: node]];

        [affectedStores addObject: store];
    }

    [_insertedObjects removeAllObjects];

    for (NSManagedObject *updated in _updatedObjects) {
        NSAtomicStore *store = (NSAtomicStore *) [_storeCoordinator
                _persistentStoreForObject: updated];
        NSAtomicStoreCacheNode *node =
                [store cacheNodeForObjectID: [updated objectID]];

        [store updateCacheNode: node fromManagedObject: updated];

        [affectedStores addObject: store];
    }

    for (NSPersistentStore *store in affectedStores) {
        NSError *saveError = nil;

        if ([store isKindOfClass: [NSAtomicStore class]]) {
            NSAtomicStore *atomicStore = (NSAtomicStore *) store;

            if (![atomicStore save: &saveError]) {
                [errorStores addObject: atomicStore];
                [errors addObject: saveError];
            }
        }
    }

    [[NSNotificationCenter defaultCenter]
            postNotificationName: NSManagedObjectContextDidSaveNotification
                          object: self];

    if ([errors count] == 0)
        return YES;

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];

    [userInfo setObject: @"Unable to save managed object context"
                 forKey: NSLocalizedDescriptionKey];
    [userInfo setObject: errorStores forKey: NSAffectedStoresErrorKey];
    [userInfo setObject: errors forKey: NSDetailedErrorsKey];

    if (errorp != NULL)
        *errorp = [NSError errorWithDomain: NSCocoaErrorDomain
                                      code: NSPersistentStoreIncompleteSaveError
                                  userInfo: userInfo];

    return NO;
}

- (void) mergeChangesFromContextDidSaveNotification:
        (NSNotification *) notification
{
    if (notification == nil || [notification object] == self)
        return;

    NSDictionary *userInfo = [notification userInfo];
    if (userInfo == nil)
        return;

    NSArray *inserted = [userInfo objectForKey: NSInsertedObjectsKey];
    for (id value in inserted) {
        NSManagedObjectID *objectID =
                NSManagedObjectContextObjectIDForSaveValue(value);
        if (objectID == nil)
            continue;
        NSManagedObject *object = [self objectRegisteredForID: objectID];
        if (object == nil)
            object = [self objectWithID: objectID];
        if (!NSManagedObjectContextHasLocalChanges(self, object))
            [object _mocRefault];
    }

    NSArray *updated = [userInfo objectForKey: NSUpdatedObjectsKey];
    for (id value in updated) {
        NSManagedObjectID *objectID =
                NSManagedObjectContextObjectIDForSaveValue(value);
        if (objectID == nil)
            continue;
        NSManagedObject *object = [self objectRegisteredForID: objectID];
        if (object == nil)
            object = [self objectWithID: objectID];
        if (!NSManagedObjectContextHasLocalChanges(self, object))
            [object _mocRefault];
    }

    NSArray *deleted = [userInfo objectForKey: NSDeletedObjectsKey];
    for (id value in deleted) {
        NSManagedObjectID *objectID =
                NSManagedObjectContextObjectIDForSaveValue(value);
        if (objectID == nil)
            continue;
        NSManagedObject *object = [self objectRegisteredForID: objectID];
        if (object != nil && ![_insertedObjects containsObject: object])
            [self deleteObject: object];
    }

    BOOL invalidateAll =
            [[userInfo objectForKey: NSInvalidatedAllObjectsKey] boolValue];
    if (invalidateAll) {
        NSArray *registeredObjects = [[_registeredObjects allObjects] copy];
        for (NSManagedObject *object in registeredObjects) {
            if (!NSManagedObjectContextHasLocalChanges(self, object))
                [object _mocRefault];
        }
        [registeredObjects release];
    }

    NSArray *refreshed = [userInfo objectForKey: NSRefreshedObjectsKey];
    NSArray *invalidated = [userInfo objectForKey: NSInvalidatedObjectsKey];
    if (refreshed == nil)
        refreshed = [NSArray array];
    NSArray *refreshValues = [refreshed arrayByAddingObjectsFromArray:
                                       (invalidated != nil ? invalidated
                                                           : [NSArray array])];
    for (id value in refreshValues) {
        NSManagedObjectID *objectID =
                NSManagedObjectContextObjectIDForSaveValue(value);
        if (objectID == nil)
            continue;
        NSManagedObject *object = [self objectRegisteredForID: objectID];
        if (object != nil &&
            !NSManagedObjectContextHasLocalChanges(self, object))
            [object _mocRefault];
    }
}

- (BOOL) commitEditing {
    NSArray *editors = [[_editors copy] autorelease];
    for (id editor in editors) {
        if ([editor respondsToSelector: @selector(commitEditing)] &&
            ![editor commitEditing])
            return NO;
    }
    return YES;
}

- (void) commitEditingWithDelegate: (id) delegate
                 didCommitSelector: (SEL) didCommitSelector
                       contextInfo: (void *) contextInfo
{
    BOOL success = [self commitEditing];

    if (delegate != nil && didCommitSelector != NULL) {
        NSMethodSignature *signature =
                [delegate methodSignatureForSelector: didCommitSelector];
        if ([signature numberOfArguments] == 5) {
            NSInvocation *invocation =
                    [NSInvocation invocationWithMethodSignature: signature];
            id editor = self;
            [invocation setSelector: didCommitSelector];
            [invocation setArgument: &editor atIndex: 2];
            [invocation setArgument: &success atIndex: 3];
            [invocation setArgument: &contextInfo atIndex: 4];
            [invocation invokeWithTarget: delegate];
        }
    }
}

- (void) discardEditing {
    NSArray *editors = [[_editors copy] autorelease];
    for (id editor in editors) {
        if ([editor respondsToSelector: @selector(discardEditing)])
            [editor discardEditing];
    }
}

- (void) objectDidBeginEditing: (id) editor {
    if (editor != nil && ![_editors containsObject: editor])
        [_editors addObject: editor];
}

- (void) objectDidEndEditing: (id) editor {
    if (editor != nil)
        [_editors removeObject: editor];
}

@end
