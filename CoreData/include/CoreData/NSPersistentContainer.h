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

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;
@class NSManagedObjectModel;
@class NSPersistentStoreCoordinator;
@class NSPersistentStoreDescription;

@interface NSPersistentContainer : NSObject {
    NSString *_name;
    NSManagedObjectContext *_viewContext;
    NSManagedObjectModel *_model;
    NSPersistentStoreCoordinator *_storeCoordinator;
    NSArray *_storeDescriptions;
}

+ (instancetype) persistentContainerWithName: (NSString *) name;
+ (instancetype) persistentContainerWithName: (NSString *) name
                          managedObjectModel: (NSManagedObjectModel *) model;
+ (NSURL *) defaultDirectoryURL;

@property (copy, readonly) NSString *name;
@property (strong, readonly) NSManagedObjectContext *viewContext;
@property (strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (copy) NSArray *persistentStoreDescriptions;

- (instancetype) initWithName: (NSString *) name;
- (instancetype) initWithName: (NSString *) name
           managedObjectModel: (NSManagedObjectModel *) model;
- (void) loadPersistentStoresWithCompletionHandler: (void (^)(NSPersistentStoreDescription *, NSError *)) block;
- (NSManagedObjectContext *) newBackgroundContext NS_RETURNS_RETAINED;
- (void) performBackgroundTask: (void (^)(NSManagedObjectContext *)) block;

@end
