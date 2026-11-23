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

#import <CoreData/NSMigrationManager.h>
#import <CoreData/NSManagedObjectContext.h>
#import <CoreData/NSManagedObjectModel.h>
#import <CoreData/NSManagedObject.h>
#import <CoreData/NSManagedObjectID.h>
#import <CoreData/NSMappingModel.h>
#import <CoreData/NSEntityMapping.h>
#import <CoreData/NSEntityDescription.h>
#import <CoreData/NSPersistentStoreCoordinator.h>

@implementation NSMigrationManager

- (instancetype) initWithSourceModel: (NSManagedObjectModel *) sourceModel
                    destinationModel: (NSManagedObjectModel *) destinationModel {
    if ((self = [super init])) {
        _sourceModel = [sourceModel retain];
        _destinationModel = [destinationModel retain];
        _destinationBySource = [[NSMutableDictionary alloc] init];
        _sourceByDestination = [[NSMutableDictionary alloc] init];
        _usesStoreSpecificMigrationManager = YES;
    }
    return self;
}

- (void) dealloc {
    [_sourceModel release];
    [_destinationModel release];
    [_mappingModel release];
    [_sourceContext release];
    [_destinationContext release];
    [_currentEntityMapping release];
    [_userInfo release];
    [_destinationBySource release];
    [_sourceByDestination release];
    [_cancellationError release];
    [super dealloc];
}

- (NSString *) _nameForMapping: (NSEntityMapping *) mapping {
    if ([mapping respondsToSelector: @selector(name)]) {
        return [mapping performSelector: @selector(name)];
    }
    return [NSString stringWithFormat: @"%p", mapping];
}

- (NSManagedObjectContext *) _newContextForModel: (NSManagedObjectModel *) model {
    NSPersistentStoreCoordinator *coordinator =
            [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: model];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator: coordinator];
    [coordinator release];
    return context;
}

- (BOOL) migrateStoreFromURL: (NSURL *) sourceURL
                        type: (NSString *) sStoreType
                     options: (NSDictionary *) sOptions
            withMappingModel: (NSMappingModel *) mappings
            toDestinationURL: (NSURL *) dURL
             destinationType: (NSString *) dStoreType
          destinationOptions: (NSDictionary *) dOptions
                       error: (NSError **) error {
    [self reset];
    [_mappingModel release];
    _mappingModel = [mappings retain];
    [_cancellationError release];
    _cancellationError = nil;
    _migrationProgress = 0.0f;

    NSError *failure = [NSError errorWithDomain: NSCocoaErrorDomain
                                           code: 134140 /* NSMigrationError */
                                       userInfo: nil];
    if (_sourceModel == nil || _destinationModel == nil || sourceURL == nil || dURL == nil) {
        failure = [NSError errorWithDomain: NSCocoaErrorDomain
                                      code: 134130 /* NSMigrationMissingSourceModelError */
                                  userInfo: nil];
    }
    if (error != NULL) {
        *error = _cancellationError ? _cancellationError : failure;
    }
    return NO;
}

- (BOOL) usesStoreSpecificMigrationManager {
    return _usesStoreSpecificMigrationManager;
}

- (void) setUsesStoreSpecificMigrationManager: (BOOL) value {
    _usesStoreSpecificMigrationManager = value;
}

- (void) reset {
    [_destinationBySource removeAllObjects];
    [_sourceByDestination removeAllObjects];
    [_currentEntityMapping release];
    _currentEntityMapping = nil;
    _migrationProgress = 0.0f;
}

- (NSMappingModel *) mappingModel {
    return _mappingModel;
}

- (NSManagedObjectModel *) sourceModel {
    return _sourceModel;
}

- (NSManagedObjectModel *) destinationModel {
    return _destinationModel;
}

- (NSManagedObjectContext *) sourceContext {
    if (_sourceContext == nil && _sourceModel != nil) {
        _sourceContext = [self _newContextForModel: _sourceModel];
    }
    return _sourceContext;
}

- (NSManagedObjectContext *) destinationContext {
    if (_destinationContext == nil && _destinationModel != nil) {
        _destinationContext = [self _newContextForModel: _destinationModel];
    }
    return _destinationContext;
}

- (NSEntityDescription *) sourceEntityForEntityMapping: (NSEntityMapping *) mEntity {
    NSString *name = [mEntity respondsToSelector: @selector(sourceEntityName)]
                             ? [mEntity performSelector: @selector(sourceEntityName)]
                             : nil;
    return name ? [[_sourceModel entitiesByName] objectForKey: name] : nil;
}

- (NSEntityDescription *) destinationEntityForEntityMapping: (NSEntityMapping *) mEntity {
    NSString *name = [mEntity respondsToSelector: @selector(destinationEntityName)]
                             ? [mEntity performSelector: @selector(destinationEntityName)]
                             : nil;
    return name ? [[_destinationModel entitiesByName] objectForKey: name] : nil;
}

- (void) associateSourceInstance: (NSManagedObject *) sourceInstance
         withDestinationInstance: (NSManagedObject *) destinationInstance
                forEntityMapping: (NSEntityMapping *) entityMapping {
    NSString *name = [self _nameForMapping: entityMapping];
    NSMutableDictionary *forward = [_destinationBySource objectForKey: name];
    if (forward == nil) {
        forward = [NSMutableDictionary dictionary];
        [_destinationBySource setObject: forward forKey: name];
    }
    NSMutableDictionary *backward = [_sourceByDestination objectForKey: name];
    if (backward == nil) {
        backward = [NSMutableDictionary dictionary];
        [_sourceByDestination setObject: backward forKey: name];
    }
    [forward setObject: destinationInstance forKey: [sourceInstance objectID]];
    [backward setObject: sourceInstance forKey: [destinationInstance objectID]];
}

- (NSArray *) _lookup: (NSDictionary *) table instances: (NSArray *) instances {
    NSMutableArray *result = [NSMutableArray array];
    if (instances == nil) {
        [result addObjectsFromArray: [table allValues]];
        return result;
    }
    for (NSManagedObject *instance in instances) {
        id match = [table objectForKey: [instance objectID]];
        if (match != nil) {
            [result addObject: match];
        }
    }
    return result;
}

- (NSArray *) destinationInstancesForEntityMappingNamed: (NSString *) mappingName
                                        sourceInstances: (NSArray *) sourceInstances {
    return [self _lookup: [_destinationBySource objectForKey: mappingName]
               instances: sourceInstances];
}

- (NSArray *) sourceInstancesForEntityMappingNamed: (NSString *) mappingName
                              destinationInstances: (NSArray *) destinationInstances {
    return [self _lookup: [_sourceByDestination objectForKey: mappingName]
               instances: destinationInstances];
}

- (NSEntityMapping *) currentEntityMapping {
    return _currentEntityMapping;
}

- (float) migrationProgress {
    return _migrationProgress;
}

- (NSDictionary *) userInfo {
    return _userInfo;
}

- (void) setUserInfo: (NSDictionary *) value {
    if (value != _userInfo) {
        [_userInfo release];
        _userInfo = [value retain];
    }
}

- (void) cancelMigrationWithError: (NSError *) error {
    if (error != _cancellationError) {
        [_cancellationError release];
        _cancellationError = [error retain];
    }
}

@end
