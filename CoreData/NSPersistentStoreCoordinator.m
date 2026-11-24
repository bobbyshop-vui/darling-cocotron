/* Copyright (c)2008 Dan Knapp

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
#import "NSInMemoryPersistentStore.h"
#import "NSManagedObjectID-Private.h"
#import "NSXMLPersistentStore.h"
#import <CoreData/CoreDataErrors.h>
#import <CoreData/NSManagedObject.h>
#import <CoreData/NSManagedObjectModel.h>
#import <CoreData/NSAtomicStore.h>
#import <CoreData/NSPersistentStore.h>
#import <CoreData/NSPersistentStoreCoordinator.h>
#import <Foundation/NSData.h>
#import <Foundation/NSError.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSRaise.h>
#import <dispatch/dispatch.h>
#import <dlfcn.h>
#import <Foundation/NSXMLDocument.h>

NSString *const NSStoreTypeKey = @"NSStoreTypeKey";
NSString *const NSStoreUUIDKey = @"NSStoreUUIDKey";

NSString *const NSXMLStoreType = @"XML";
NSString *const NSInMemoryStoreType = @"Memory";
NSString *const NSSQLiteStoreType = @"SQLite";
NSString *const NSBinaryStoreType = @"Binary";
NSString *const NSMigratePersistentStoresAutomaticallyOption =
        @"NSMigratePersistentStoresAutomaticallyOption";

NSString *const NSPersistentStoreCoordinatorStoresDidChangeNotification =
        @"NSPersistentStoreCoordinatorStoresDidChangeNotification";
NSString *const NSAddedPersistentStoresKey = @"NSAddedPersistentStoresKey";
NSString *const NSRemovedPersistentStoresKey = @"NSRemovedPersistentStoresKey";
NSString *const NSUUIDChangedPersistentStoresKey =
        @"NSUUIDChangedPersistentStoresKey";

NSString *const NSPersistentStoreSaveConflictsErrorKey = @"conflictList";

NSString *const NSInferMappingModelAutomaticallyOption =
        @"NSInferMappingModelAutomaticallyOption";
NSString *const NSReadOnlyPersistentStoreOption =
        @"NSReadOnlyPersistentStoreOption";
NSString *const NSSQLiteManualVacuumOption = @"NSSQLiteManualVacuumOption";
NSString *const NSStoreModelVersionHashesKey =
        @"NSStoreModelVersionHashesKey";

/*
 * The Cocotron CoreData implementation has no SQLite store yet. Keep a
 * compact XML snapshot in a real SQLite database so the existing atomic-store
 * object graph implementation can be used for SQLite URLs as well.
 */
typedef struct sqlite3 _CoreDataSQLiteDB;
typedef struct sqlite3_stmt _CoreDataSQLiteStatement;

typedef struct {
    void *handle;
    int (*openV2)(const char *, _CoreDataSQLiteDB **, int, const char *);
    int (*close)(_CoreDataSQLiteDB *);
    const char *(*errorMessage)(_CoreDataSQLiteDB *);
    int (*execute)(_CoreDataSQLiteDB *, const char *, int (*)(void *, int, char **, char **), void *, char **);
    int (*prepare)(_CoreDataSQLiteDB *, const char *, int, _CoreDataSQLiteStatement **, const char **);
    int (*step)(_CoreDataSQLiteStatement *);
    const void *(*columnBlob)(_CoreDataSQLiteStatement *, int);
    int (*columnBytes)(_CoreDataSQLiteStatement *, int);
    int (*finalize)(_CoreDataSQLiteStatement *);
    int (*bindBlob)(_CoreDataSQLiteStatement *, int, const void *, int, void (*)(void *));
} _CoreDataSQLiteAPI;

static _CoreDataSQLiteAPI _coreDataSQLiteAPI;
static dispatch_once_t _coreDataSQLiteAPIToken;

static BOOL _loadCoreDataSQLiteAPI(void) {
    dispatch_once(&_coreDataSQLiteAPIToken, ^{
        const char *libraries[] = {
            "libsqlite3.so.0", "libsqlite3.so", "libsqlite3.dylib",
            "/usr/lib/libsqlite3.dylib", NULL
        };
        for (int i = 0; libraries[i] != NULL; i++) {
            _coreDataSQLiteAPI.handle = dlopen(libraries[i], RTLD_NOW | RTLD_LOCAL);
            if (_coreDataSQLiteAPI.handle != NULL)
                break;
        }
        if (_coreDataSQLiteAPI.handle == NULL)
            return;

#define LOAD_SQLITE_SYMBOL(field, symbol) \
        _coreDataSQLiteAPI.field = (__typeof__(_coreDataSQLiteAPI.field)) \
                dlsym(_coreDataSQLiteAPI.handle, symbol)
        LOAD_SQLITE_SYMBOL(openV2, "sqlite3_open_v2");
        LOAD_SQLITE_SYMBOL(close, "sqlite3_close");
        LOAD_SQLITE_SYMBOL(errorMessage, "sqlite3_errmsg");
        LOAD_SQLITE_SYMBOL(execute, "sqlite3_exec");
        LOAD_SQLITE_SYMBOL(prepare, "sqlite3_prepare_v2");
        LOAD_SQLITE_SYMBOL(step, "sqlite3_step");
        LOAD_SQLITE_SYMBOL(columnBlob, "sqlite3_column_blob");
        LOAD_SQLITE_SYMBOL(columnBytes, "sqlite3_column_bytes");
        LOAD_SQLITE_SYMBOL(finalize, "sqlite3_finalize");
        LOAD_SQLITE_SYMBOL(bindBlob, "sqlite3_bind_blob");
#undef LOAD_SQLITE_SYMBOL

        if (_coreDataSQLiteAPI.openV2 == NULL ||
            _coreDataSQLiteAPI.close == NULL ||
            _coreDataSQLiteAPI.errorMessage == NULL ||
            _coreDataSQLiteAPI.execute == NULL ||
            _coreDataSQLiteAPI.prepare == NULL ||
            _coreDataSQLiteAPI.step == NULL ||
            _coreDataSQLiteAPI.columnBlob == NULL ||
            _coreDataSQLiteAPI.columnBytes == NULL ||
            _coreDataSQLiteAPI.finalize == NULL ||
            _coreDataSQLiteAPI.bindBlob == NULL) {
            dlclose(_coreDataSQLiteAPI.handle);
            _coreDataSQLiteAPI.handle = NULL;
        }
    });
    return _coreDataSQLiteAPI.handle != NULL;
}

static void _setSQLiteStoreError(NSError **error, _CoreDataSQLiteDB *db,
                                 NSInteger code, NSString *context) {
    if (error == NULL)
        return;

    const char *detail = db == NULL ? NULL : _coreDataSQLiteAPI.errorMessage(db);
    NSString *message = detail == NULL ? nil : [NSString stringWithUTF8String: detail];
    if (message == nil || [message length] == 0)
        message = @"The SQLite library could not open the persistent store.";
    *error = [NSError errorWithDomain: @"NSSQLiteErrorDomain"
                                 code: code
                             userInfo: [NSDictionary dictionaryWithObject:
                                     [NSString stringWithFormat: @"%@ %@", context, message]
                                                               forKey: NSLocalizedDescriptionKey]];
}

static BOOL _openSQLiteStore(NSURL *url, BOOL readOnly,
                             _CoreDataSQLiteDB **database, NSError **error) {
    if (url == nil || ![url isFileURL] || [[url path] length] == 0) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                         code: NSPersistentStoreOperationError
                                     userInfo: [NSDictionary dictionaryWithObject:
                                             @"A SQLite persistent store requires a file URL."
                                                                       forKey: NSLocalizedDescriptionKey]];
        }
        return NO;
    }
    if (!_loadCoreDataSQLiteAPI()) {
        _setSQLiteStoreError(error, NULL, 1,
                @"Unable to load the SQLite runtime:");
        return NO;
    }

    int flags = readOnly ? 0x00000001 : (0x00000002 | 0x00000004);
    int result = _coreDataSQLiteAPI.openV2([[url path] fileSystemRepresentation],
                                           database, flags, NULL);
    if (result != 0) {
        _setSQLiteStoreError(error, *database, result,
                @"Unable to open SQLite persistent store:");
        if (*database != NULL) {
            _coreDataSQLiteAPI.close(*database);
            *database = NULL;
        }
        return NO;
    }
    return YES;
}

static BOOL _executeSQLite(_CoreDataSQLiteDB *database, const char *sql,
                           NSError **error, NSString *context) {
    int result = _coreDataSQLiteAPI.execute(database, sql, NULL, NULL, NULL);
    if (result == 0)
        return YES;
    _setSQLiteStoreError(error, database, result, context);
    return NO;
}

@interface _NSCoreDataSQLitePersistentStore : NSXMLPersistentStore
- (id) identifierElement;
@end

@implementation _NSCoreDataSQLitePersistentStore

+ (NSDictionary *) metadataForPersistentStoreWithURL: (NSURL *)url
                                               error: (NSError **)error {
    if (error != NULL)
        *error = nil;
    _CoreDataSQLiteDB *database = NULL;
    if (!_openSQLiteStore(url, YES, &database, error))
        return nil;

    _CoreDataSQLiteStatement *statement = NULL;
    int result = _coreDataSQLiteAPI.prepare(database, "PRAGMA schema_version",
                                             -1, &statement, NULL);
    if (result == 0)
        result = _coreDataSQLiteAPI.step(statement);
    BOOL valid = result == 100;
    if (!valid)
        _setSQLiteStoreError(error, database, result,
                @"The file is not a readable SQLite database:");
    if (statement != NULL)
        _coreDataSQLiteAPI.finalize(statement);
    int closeResult = _coreDataSQLiteAPI.close(database);
    if (!valid) {
        return nil;
    }
    if (closeResult != 0) {
        _setSQLiteStoreError(error, NULL, closeResult,
                @"Unable to close SQLite persistent store:");
        return nil;
    }
    return [NSDictionary dictionaryWithObject: NSSQLiteStoreType
                                       forKey: NSStoreTypeKey];
}

+ (BOOL) setMetadata: (NSDictionary *)metadata
        forPersistentStoreWithURL: (NSURL *)url
                            error: (NSError **)error {
    if (error != NULL) {
        *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                     code: NSPersistentStoreOperationError
                                 userInfo: [NSDictionary dictionaryWithObject:
                                         @"Direct metadata updates are not supported by this SQLite store."
                                                                   forKey: NSLocalizedDescriptionKey]];
    }
    return NO;
}

- initWithPersistentStoreCoordinator: (NSPersistentStoreCoordinator *)coordinator
                   configurationName: (NSString *)configurationName
                                 URL: (NSURL *)url
                             options: (NSDictionary *)options {
    if ((self = [super initWithPersistentStoreCoordinator: coordinator
                                       configurationName: configurationName
                                                     URL: nil
                                                 options: options]) == nil)
        return nil;

    [self setURL: url];
    id readOnly = [options objectForKey: NSReadOnlyPersistentStoreOption];
    [self setReadOnly: [readOnly respondsToSelector: @selector(boolValue)] &&
                       [readOnly boolValue]];
    [self setMetadata: [NSDictionary dictionaryWithObjectsAndKeys:
            [self identifier], NSStoreUUIDKey, NSSQLiteStoreType, NSStoreTypeKey, nil]];
    return self;
}

- (NSString *) type {
    return NSSQLiteStoreType;
}

- (BOOL) load: (NSError **)error {
    if (error != NULL)
        *error = nil;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [[self URL] path];
    BOOL existed = [fileManager fileExistsAtPath: path];
    BOOL emptyFile = NO;
    if (existed) {
        NSDictionary *attributes = [fileManager attributesOfItemAtPath: path error: NULL];
        emptyFile = [[attributes objectForKey: NSFileSize] unsignedLongLongValue] == 0;
    }

    _CoreDataSQLiteDB *database = NULL;
    if (!_openSQLiteStore([self URL], [self isReadOnly], &database, error))
        return NO;

    if (!existed || emptyFile) {
        if (![self isReadOnly] &&
            !_executeSQLite(database,
                    "CREATE TABLE IF NOT EXISTS Z_DARLING_CORE_DATA (Z_PK INTEGER PRIMARY KEY CHECK (Z_PK = 1), Z_CONTENT BLOB NOT NULL)",
                    error, @"Unable to initialize SQLite persistent store:")) {
            _coreDataSQLiteAPI.close(database);
            return NO;
        }
    }

    _CoreDataSQLiteStatement *statement = NULL;
    int result = _coreDataSQLiteAPI.prepare(database,
            "SELECT Z_CONTENT FROM Z_DARLING_CORE_DATA WHERE Z_PK = 1",
            -1, &statement, NULL);
    if (result != 0) {
        _setSQLiteStoreError(error, database, result,
                @"Unable to read CoreData records from SQLite store:");
        _coreDataSQLiteAPI.close(database);
        return NO;
    }

    result = _coreDataSQLiteAPI.step(statement);
    NSData *xmlData = nil;
    if (result == 100) {
        const void *bytes = _coreDataSQLiteAPI.columnBlob(statement, 0);
        int length = _coreDataSQLiteAPI.columnBytes(statement, 0);
        if (bytes != NULL && length > 0)
            xmlData = [NSData dataWithBytes: bytes length: (NSUInteger) length];
    } else if (result != 101) {
        _setSQLiteStoreError(error, database, result,
                @"Unable to read CoreData records from SQLite store:");
        _coreDataSQLiteAPI.finalize(statement);
        _coreDataSQLiteAPI.close(database);
        return NO;
    }
    _coreDataSQLiteAPI.finalize(statement);
    int closeResult = _coreDataSQLiteAPI.close(database);
    if (closeResult != 0) {
        _setSQLiteStoreError(error, NULL, closeResult,
                @"Unable to close SQLite persistent store:");
        return NO;
    }

    if (xmlData != nil) {
        NSError *xmlError = nil;
        NSXMLDocument *document = [[NSXMLDocument alloc]
                initWithData: xmlData
                     options: NSXMLNodePreserveCharacterReferences |
                              NSXMLNodePreserveWhitespace
                       error: &xmlError];
        if (document == nil) {
            if (error != NULL)
                *error = xmlError ?: [NSError errorWithDomain: NSCocoaErrorDomain
                        code: NSPersistentStoreIncompatibleSchemaError
                    userInfo: [NSDictionary dictionaryWithObject:
                            @"The SQLite store contains invalid CoreData records."
                                                      forKey: NSLocalizedDescriptionKey]];
            return NO;
        }
        [_document release];
        _document = document;
        NSString *identifier = [[self identifierElement] stringValue];
        if ([identifier length] == 0) {
            if (error != NULL)
                *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                             code: NSPersistentStoreIncompatibleSchemaError
                                         userInfo: [NSDictionary dictionaryWithObject:
                                                 @"The SQLite store is missing its CoreData identifier."
                                                                           forKey: NSLocalizedDescriptionKey]];
            return NO;
        }
        [self setIdentifier: identifier];
    }

    return [super load: error];
}

- (BOOL) save: (NSError **)error {
    if (error != NULL)
        *error = nil;
    if ([self isReadOnly]) {
        if (error != NULL)
            *error = [NSError errorWithDomain: @"NSSQLiteErrorDomain"
                                         code: 8
                                     userInfo: [NSDictionary dictionaryWithObject:
                                             @"The SQLite persistent store is read-only."
                                                                       forKey: NSLocalizedDescriptionKey]];
        return NO;
    }

    NSData *xmlData = [_document XMLData];
    if ([xmlData length] > 2147483647) {
        _setSQLiteStoreError(error, NULL, 18,
                @"The CoreData snapshot is too large for SQLite:");
        return NO;
    }

    _CoreDataSQLiteDB *database = NULL;
    if (!_openSQLiteStore([self URL], NO, &database, error))
        return NO;
    if (!_executeSQLite(database,
            "CREATE TABLE IF NOT EXISTS Z_DARLING_CORE_DATA (Z_PK INTEGER PRIMARY KEY CHECK (Z_PK = 1), Z_CONTENT BLOB NOT NULL)",
            error, @"Unable to initialize SQLite persistent store:")) {
        _coreDataSQLiteAPI.close(database);
        return NO;
    }

    _CoreDataSQLiteStatement *statement = NULL;
    int result = _coreDataSQLiteAPI.prepare(database,
            "INSERT OR REPLACE INTO Z_DARLING_CORE_DATA (Z_PK, Z_CONTENT) VALUES (1, ?1)",
            -1, &statement, NULL);
    if (result == 0) {
        result = _coreDataSQLiteAPI.bindBlob(statement, 1, [xmlData bytes],
                (int) [xmlData length], (void (*)(void *))-1);
        if (result == 0)
            result = _coreDataSQLiteAPI.step(statement);
    }
    if (statement != NULL)
        _coreDataSQLiteAPI.finalize(statement);
    if (result != 101) {
        _setSQLiteStoreError(error, database, result,
                @"Unable to save CoreData records to SQLite store:");
        _coreDataSQLiteAPI.close(database);
        return NO;
    }
    int closeResult = _coreDataSQLiteAPI.close(database);
    if (closeResult != 0) {
        _setSQLiteStoreError(error, NULL, closeResult,
                @"Unable to close SQLite persistent store:");
        return NO;
    }
    return YES;
}

@end

@implementation NSPersistentStoreCoordinator

static NSMutableDictionary *_storeTypes = nil;

+ (void) initialize {
    if (self == [NSPersistentStoreCoordinator class]) {
        _storeTypes = [NSMutableDictionary new];
        [_storeTypes setObject: [NSInMemoryPersistentStore class]
                        forKey: NSInMemoryStoreType];
        [_storeTypes setObject: [NSXMLPersistentStore class]
                        forKey: NSXMLStoreType];
        [_storeTypes setObject: [_NSCoreDataSQLitePersistentStore class]
                        forKey: NSSQLiteStoreType];
    }
}

+ (NSDictionary *) registeredStoreTypes {
    return _storeTypes;
}

+ (void) registerStoreClass: (Class) storeClass
               forStoreType: (NSString *) storeType
{
    [_storeTypes setObject: storeClass forKey: storeType];
}

- initWithManagedObjectModel: (NSManagedObjectModel *) model {
    _lock = [[NSLock alloc] init];
    _model = [model retain];
    _stores = [[NSMutableArray alloc] init];
    return self;
}

- (void) dealloc {
    [_lock release];
    [_coordinatorName release];
    [_model release];
    [_stores release];
    [super dealloc];
}

- (NSManagedObjectModel *) managedObjectModel {
    return _model;
}

- (NSPersistentStore *) addPersistentStoreWithType: (NSString *) storeType
                                     configuration: (NSString *) configuration
                                               URL: (NSURL *) storeURL
                                           options: (NSDictionary *) options
                                             error: (NSError **) error
{
    if (error != NULL)
        *error = nil;

    /* It appears that this method will determine the store type if it is nil */
    if (storeType == nil) {

        for (Class class in [_storeTypes allValues]) {
            NSDictionary *metadata =
                    [class metadataForPersistentStoreWithURL: storeURL
                                                       error: nil];
            if ((storeType = [metadata objectForKey: NSStoreTypeKey]) != nil)
                break;
        }
    }

    Class class = [[[self class] registeredStoreTypes] objectForKey: storeType];
    if (class == Nil) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                         code: NSPersistentStoreInvalidTypeError
                                     userInfo: [NSDictionary dictionaryWithObject:
                                             [NSString stringWithFormat:
                                                     @"No persistent store is registered for type %@.",
                                                     storeType ?: @"(null)"]
                                                                       forKey: NSLocalizedDescriptionKey]];
        }
        return nil;
    }

    NSAtomicStore *store = [[[class alloc]
            initWithPersistentStoreCoordinator: self
                             configurationName: configuration
                                           URL: storeURL
                                       options: options] autorelease];
    if (store == nil) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                         code: NSPersistentStoreOpenError
                                     userInfo: [NSDictionary dictionaryWithObject:
                                             @"The persistent store could not be initialized."
                                                                       forKey: NSLocalizedDescriptionKey]];
        }
        return nil;
    }

    NSError *loadError = nil;
    if (![store load: &loadError]) {
        if (error != NULL)
            *error = loadError ?: [NSError errorWithDomain: NSCocoaErrorDomain
                    code: NSPersistentStoreOpenError
                userInfo: [NSDictionary dictionaryWithObject:
                        @"The persistent store failed to load without an error description."
                                                  forKey: NSLocalizedDescriptionKey]];
        return nil;
    }

    [_stores addObject: store];
    [store didAddToPersistentStoreCoordinator: self];

    return store;
}

- (BOOL) setURL: (NSURL *) url forPersistentStore: (NSPersistentStore *) store {
    [store setURL: url];
    return YES;
}

- (BOOL) removePersistentStore: (NSPersistentStore *) store
                         error: (NSError **) error
{
    NSArray *remove = [NSArray arrayWithObject: store];
    NSDictionary *userInfo =
            [NSDictionary dictionaryWithObject: remove
                                        forKey: NSRemovedPersistentStoresKey];

    [store willRemoveFromPersistentStoreCoordinator: self];

    [[NSNotificationCenter defaultCenter]
            postNotificationName:
                    NSPersistentStoreCoordinatorStoresDidChangeNotification
                          object: self
                        userInfo: userInfo];

    [_stores removeObjectIdenticalTo: store];

    return YES;
}

- (NSPersistentStore *) migratePersistentStore: (NSPersistentStore *) store
                                         toURL: (NSURL *) URL
                                       options: (NSDictionary *) options
                                      withType: (NSString *) storeType
                                         error: (NSError **) error
{
    if (error != NULL)
        *error = nil;

    NSString *sourceType = [store type];
    if (store == nil || [_stores indexOfObjectIdenticalTo: store] == NSNotFound ||
        URL == nil || [store URL] == nil) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                         code: NSPersistentStoreOperationError
                                     userInfo: @{
                                         NSLocalizedDescriptionKey :
                                             @"The source store and destination URL must be valid."
                                     }];
        }
        return nil;
    }

    if (storeType == nil)
        storeType = sourceType;

    Class destinationStoreClass =
            [[[self class] registeredStoreTypes] objectForKey: storeType];
    if (destinationStoreClass == Nil) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                         code: NSPersistentStoreInvalidTypeError
                                     userInfo: @{
                                         NSLocalizedDescriptionKey :
                                             [NSString stringWithFormat:
                                                     @"No persistent store is registered for type %@.",
                                                     storeType ?: @"(null)"]
                                     }];
        }
        return nil;
    }

    // XML stores can be migrated without changing their record format by
    // copying the backing file. Other registered stores have no export/import
    // path in this implementation (the migration manager is also unavailable).
    if (![store isKindOfClass: [NSXMLPersistentStore class]] ||
        ![destinationStoreClass isSubclassOfClass: [NSXMLPersistentStore class]] ||
        ![sourceType isEqualToString: storeType] ||
        ![[store URL] isFileURL] || ![URL isFileURL] ||
        [[store URL] isEqual: URL]) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                         code: NSPersistentStoreOperationError
                                     userInfo: @{
                                         NSLocalizedDescriptionKey :
                                             @"This store migration cannot be represented by the available store backends."
                                     }];
        }
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *destinationPath = [URL path];
    if ([fileManager fileExistsAtPath: destinationPath]) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                         code: NSPersistentStoreOperationError
                                     userInfo: @{
                                         NSLocalizedDescriptionKey :
                                             @"The destination store already exists."
                                     }];
        }
        return nil;
    }

    NSError *migrationError = nil;
    if (![(NSAtomicStore *) store save: &migrationError]) {
        if (error != NULL)
            *error = migrationError;
        return nil;
    }

    if (![fileManager copyItemAtURL: [store URL]
                              toURL: URL
                              error: &migrationError]) {
        if (error != NULL)
            *error = migrationError;
        return nil;
    }

    NSPersistentStore *migratedStore =
            [self addPersistentStoreWithType: storeType
                               configuration: [store configurationName]
                                         URL: URL
                                     options: options
                                       error: &migrationError];
    if (migratedStore == nil) {
        [fileManager removeItemAtURL: URL error: NULL];
        if (error != NULL)
            *error = migrationError;
        return nil;
    }

    if (![self removePersistentStore: store error: &migrationError]) {
        [self removePersistentStore: migratedStore error: NULL];
        [fileManager removeItemAtURL: URL error: NULL];
        if (error != NULL)
            *error = migrationError;
        return nil;
    }

    return migratedStore;
}

- (NSArray *) persistentStores {
    return _stores;
}

- (NSPersistentStore *) persistentStoreForURL: (NSURL *) URL {
    /* This only returns a store if it exists in the coordinator */

    for (NSPersistentStore *check in _stores) {
        if ([[check URL] isEqual: URL])
            return check;
    }

    return nil;
}

- (NSURL *) URLForPersistentStore: (NSPersistentStore *) store {
    return [store URL];
}

- (void) lock {
    [_lock lock];
}

- (BOOL) tryLock {
    return [_lock tryLock];
}

- (void) unlock {
    [_lock unlock];
}

- (NSDictionary *) metadataForPersistentStore: (NSPersistentStore *) store {
    return [store metadata];
}

- (void) setMetadata: (NSDictionary *) value
        forPersistentStore: (NSPersistentStore *) store
{
    [store setMetadata: value];
}

+ (BOOL) setMetadata: (NSDictionary *) metadata
        forPersistentStoreOfType: (NSString *) storeType
                             URL: (NSURL *) url
                           error: (NSError **) error
{
    Class check = [[self registeredStoreTypes] objectForKey: storeType];

    return [check setMetadata: metadata
            forPersistentStoreWithURL: url
                                error: error];
}

+ (NSDictionary *) metadataForPersistentStoreOfType: (NSString *) storeType
                                                URL: (NSURL *) url
                                              error: (NSError **) error
{
    Class check = [[self registeredStoreTypes] objectForKey: storeType];

    return [check metadataForPersistentStoreWithURL: url error: error];
}

+ (NSDictionary *) metadataForPersistentStoreOfType: (NSString *) storeType
                                                URL: (NSURL *) url
                                            options: (NSDictionary *) options
                                              error: (NSError **) error
{
    return [self metadataForPersistentStoreOfType: storeType
                                              URL: url
                                            error: error];
}

+ (BOOL) setMetadata: (NSDictionary *) metadata
        forPersistentStoreOfType: (NSString *) storeType
                             URL: (NSURL *) url
                         options: (NSDictionary *) options
                           error: (NSError **) error
{
    return [self setMetadata: metadata
            forPersistentStoreOfType: storeType
                                 URL: url
                               error: error];
}

- (NSString *) name {
    return _coordinatorName;
}

- (void) setName: (NSString *) name {
    name = [name copy];
    [_coordinatorName release];
    _coordinatorName = name;
}

- (void) performBlock: (void (^)(void)) block {
    void (^copied)(void) = [block copy];

    [self retain];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                     [self lock];
                     copied();
                     [self unlock];
                     [copied release];
                     [self release];
                   });
}

- (void) performBlockAndWait: (void (^)(void)) block {
    [self lock];
    @try {
        block();
    } @finally {
        [self unlock];
    }
}

- (NSPersistentStore *) _persistentStoreWithIdentifier: (NSString *) identifier
{
    for (NSPersistentStore *check in _stores)
        if ([[check identifier] isEqualToString: identifier])
            return check;

    return nil;
}

- (NSPersistentStore *) _persistentStoreForObjectID:
        (NSManagedObjectID *) objectID
{
    NSEntityDescription *entity = [objectID entity];
    NSString *storeIdentifier = [objectID storeIdentifier];
    NSPersistentStore *check =
            [self _persistentStoreWithIdentifier: storeIdentifier];

    if (check != nil)
        return check;

    NSManagedObjectModel *model = [self managedObjectModel];

    if ([_stores count] == 0) {
        [NSException
                 raise: NSInvalidArgumentException
                format: @"-[%@ %s] no persistent stores", [self class], _cmd];
        return nil;
    }

    for (check in _stores) {
        NSString *configurationName = [check configurationName];

        if (configurationName == nil) {
            NSArray *entities =
                    [model entitiesForConfiguration: configurationName];

            if ([entities containsObject: entity])
                return check;
        }
    }

    return [_stores objectAtIndex: 0];
}

- (NSPersistentStore *) _persistentStoreForObject: (NSManagedObject *) object {
    return [self _persistentStoreForObjectID: [object objectID]];
}

- (NSManagedObjectID *) managedObjectIDForURIRepresentation: (NSURL *) URL {
    NSString *scheme = [URL scheme];
    NSString *host = [URL host];
    NSString *path = [URL path];
    NSString *referenceObject = [path lastPathComponent];
    NSString *entityName =
            [[path stringByDeletingLastPathComponent] lastPathComponent];
    NSManagedObjectModel *model = [self managedObjectModel];
    NSEntityDescription *entity =
            [[model entitiesByName] objectForKey: entityName];

    return [(NSAtomicStore *) [self _persistentStoreWithIdentifier: host]
            objectIDForEntity: entity
              referenceObject: referenceObject];
}

@end
