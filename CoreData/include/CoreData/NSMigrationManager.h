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

@class NSEntityDescription;
@class NSEntityMapping;
@class NSManagedObjectContext;
@class NSManagedObject;
@class NSManagedObjectModel;
@class NSMappingModel;

@interface NSMigrationManager : NSObject {
    NSManagedObjectModel *_sourceModel;
    NSManagedObjectModel *_destinationModel;
    NSMappingModel *_mappingModel;
    NSManagedObjectContext *_sourceContext;
    NSManagedObjectContext *_destinationContext;
    NSEntityMapping *_currentEntityMapping;
    NSDictionary *_userInfo;
    NSMutableDictionary *_destinationBySource;
    NSMutableDictionary *_sourceByDestination;
    NSError *_cancellationError;
    float _migrationProgress;
    BOOL _usesStoreSpecificMigrationManager;
}

- (instancetype) initWithSourceModel: (NSManagedObjectModel *) sourceModel
                    destinationModel: (NSManagedObjectModel *) destinationModel;

- (BOOL) migrateStoreFromURL: (NSURL *) sourceURL
                        type: (NSString *) sStoreType
                     options: (NSDictionary *) sOptions
            withMappingModel: (NSMappingModel *) mappings
            toDestinationURL: (NSURL *) dURL
             destinationType: (NSString *) dStoreType
          destinationOptions: (NSDictionary *) dOptions
                       error: (NSError **) error;

@property BOOL usesStoreSpecificMigrationManager;

- (void) reset;

@property (readonly, strong) NSMappingModel *mappingModel;
@property (readonly, strong) NSManagedObjectModel *sourceModel;
@property (readonly, strong) NSManagedObjectModel *destinationModel;
@property (readonly, strong) NSManagedObjectContext *sourceContext;
@property (readonly, strong) NSManagedObjectContext *destinationContext;

- (NSEntityDescription *) sourceEntityForEntityMapping: (NSEntityMapping *) mEntity;
- (NSEntityDescription *) destinationEntityForEntityMapping: (NSEntityMapping *) mEntity;

- (void) associateSourceInstance: (NSManagedObject *) sourceInstance
         withDestinationInstance: (NSManagedObject *) destinationInstance
                forEntityMapping: (NSEntityMapping *) entityMapping;

- (NSArray *) destinationInstancesForEntityMappingNamed: (NSString *) mappingName
                                        sourceInstances: (NSArray *) sourceInstances;
- (NSArray *) sourceInstancesForEntityMappingNamed: (NSString *) mappingName
                              destinationInstances: (NSArray *) destinationInstances;

@property (readonly, strong) NSEntityMapping *currentEntityMapping;
@property (readonly) float migrationProgress;
@property (nonatomic, strong) NSDictionary *userInfo;

- (void) cancelMigrationWithError: (NSError *) error;

@end
