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

#import <CoreData/NSPersistentContainer.h>
#import <CoreData/NSManagedObjectContext.h>
#import <CoreData/NSManagedObjectModel.h>
#import <CoreData/NSPersistentStoreCoordinator.h>
#import <CoreData/NSPersistentStoreDescription.h>

@implementation NSPersistentContainer

+ (instancetype) persistentContainerWithName: (NSString *) name {
    return [[[self alloc] initWithName: name] autorelease];
}

+ (instancetype) persistentContainerWithName: (NSString *) name
                          managedObjectModel: (NSManagedObjectModel *) model {
    return [[[self alloc] initWithName: name managedObjectModel: model] autorelease];
}

+ (NSURL *) defaultDirectoryURL {
    NSArray *urls = [[NSFileManager defaultManager]
            URLsForDirectory: NSApplicationSupportDirectory
                   inDomains: NSUserDomainMask];
    NSURL *url = [urls firstObject];
    if (url == nil) {
        url = [NSURL fileURLWithPath: NSHomeDirectory()];
    }
    return url;
}

- (instancetype) initWithName: (NSString *) name {
    NSManagedObjectModel *model = nil;
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource: name ofType: @"momd"];
    if (path == nil) {
        path = [bundle pathForResource: name ofType: @"mom"];
    }
    if (path != nil) {
        model = [[[NSManagedObjectModel alloc]
                initWithContentsOfURL: [NSURL fileURLWithPath: path]] autorelease];
    }
    if (model == nil) {
        model = [NSManagedObjectModel mergedModelFromBundles: nil];
    }
    if (model == nil) {
        [self release];
        [NSException raise: NSInvalidArgumentException
                    format: @"Can't find model for source store"];
    }
    return [self initWithName: name managedObjectModel: model];
}

- (instancetype) initWithName: (NSString *) name
           managedObjectModel: (NSManagedObjectModel *) model {
    if ((self = [super init])) {
        _name = [name copy];
        _model = [model retain];
        _storeCoordinator = [[NSPersistentStoreCoordinator alloc]
                initWithManagedObjectModel: _model];

        NSURL *dir = [[self class] defaultDirectoryURL];
        NSURL *url = [dir URLByAppendingPathComponent:
                [_name stringByAppendingPathExtension: @"sqlite"]];
        NSPersistentStoreDescription *description =
                [NSPersistentStoreDescription persistentStoreDescriptionWithURL: url];
        _storeDescriptions = [[NSArray alloc] initWithObjects: description, nil];

        _viewContext = [[NSManagedObjectContext alloc]
                initWithConcurrencyType: 2 /* NSMainQueueConcurrencyType */];
        [_viewContext setPersistentStoreCoordinator: _storeCoordinator];
    }
    return self;
}

- (instancetype) init {
    [self release];
    [NSException raise: NSInvalidArgumentException
                format: @"-[NSPersistentContainer init] is not supported; use -initWithName:"];
    return nil;
}

- (void) dealloc {
    [_name release];
    [_viewContext release];
    [_model release];
    [_storeCoordinator release];
    [_storeDescriptions release];
    [super dealloc];
}

- (NSString *) name {
    return _name;
}

- (NSManagedObjectContext *) viewContext {
    return _viewContext;
}

- (NSManagedObjectModel *) managedObjectModel {
    return _model;
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
    return _storeCoordinator;
}

- (NSArray *) persistentStoreDescriptions {
    return _storeDescriptions;
}

- (void) setPersistentStoreDescriptions: (NSArray *) value {
    if (value != _storeDescriptions) {
        [_storeDescriptions release];
        _storeDescriptions = [value copy];
    }
}

- (void) loadPersistentStoresWithCompletionHandler: (void (^)(NSPersistentStoreDescription *, NSError *)) block {
    for (NSPersistentStoreDescription *description in _storeDescriptions) {
        NSError *error = nil;
        NSString *type = [description type];
        if (type == nil) {
            type = NSSQLiteStoreType;
        }
        NSURL *url = [description URL];
        if (url != nil && [url isFileURL]) {
            [[NSFileManager defaultManager]
                    createDirectoryAtPath: [[url path] stringByDeletingLastPathComponent]
              withIntermediateDirectories: YES
                               attributes: nil
                                    error: NULL];
        }
        id store = [_storeCoordinator addPersistentStoreWithType: type
                                                   configuration: [description configuration]
                                                             URL: url
                                                         options: [description options]
                                                           error: &error];
        if (store == nil && error == nil) {
            error = [NSError errorWithDomain: NSCocoaErrorDomain code: 134060 userInfo: nil];
        }
        if (block != nil) {
            block(description, store == nil ? error : nil);
        }
    }
}

- (NSManagedObjectContext *) newBackgroundContext {
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc]
            initWithConcurrencyType: 1 /* NSPrivateQueueConcurrencyType */];
    [context setPersistentStoreCoordinator: _storeCoordinator];
    return context;
}

- (void) performBackgroundTask: (void (^)(NSManagedObjectContext *)) block {
    NSManagedObjectContext *context = [self newBackgroundContext];
    [context performBlock: ^{
        block(context);
        [context release];
    }];
}

@end
