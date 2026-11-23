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

@class NSFetchRequest;
@class NSManagedObjectContext;
@class NSFetchedResultsController;

@protocol NSFetchedResultsSectionInfo
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *indexTitle;
@property (nonatomic, readonly) NSUInteger numberOfObjects;
@property (nonatomic, readonly) NSArray *objects;
@end

#ifndef DARLING_NSFetchedResultsChangeType_DEFINED
#define DARLING_NSFetchedResultsChangeType_DEFINED
typedef NS_ENUM(NSUInteger, NSFetchedResultsChangeType) {
    NSFetchedResultsChangeInsert = 1,
    NSFetchedResultsChangeDelete = 2,
    NSFetchedResultsChangeMove = 3,
    NSFetchedResultsChangeUpdate = 4
};
#endif

@protocol NSFetchedResultsControllerDelegate <NSObject>
@optional
- (void) controller: (NSFetchedResultsController *) controller
    didChangeObject: (id) anObject
        atIndexPath: (NSIndexPath *) indexPath
      forChangeType: (NSFetchedResultsChangeType) type
       newIndexPath: (NSIndexPath *) newIndexPath;
- (void) controller: (NSFetchedResultsController *) controller
   didChangeSection: (id<NSFetchedResultsSectionInfo>) sectionInfo
            atIndex: (NSUInteger) sectionIndex
      forChangeType: (NSFetchedResultsChangeType) type;
- (void) controllerWillChangeContent: (NSFetchedResultsController *) controller;
- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller;
- (NSString *) controller: (NSFetchedResultsController *) controller
        sectionIndexTitleForSectionName: (NSString *) sectionName;
@end

@interface NSFetchedResultsController : NSObject {
    NSFetchRequest *_fetchRequest;
    NSManagedObjectContext *_managedObjectContext;
    NSString *_sectionNameKeyPath;
    NSString *_cacheName;
    id _delegate;
    NSArray *_fetchedObjects;
    NSArray *_sections;
}

- (instancetype) initWithFetchRequest: (NSFetchRequest *) fetchRequest
                 managedObjectContext: (NSManagedObjectContext *) context
                   sectionNameKeyPath: (NSString *) sectionNameKeyPath
                            cacheName: (NSString *) name;

- (BOOL) performFetch: (NSError **) error;

@property (nonatomic, readonly) NSFetchRequest *fetchRequest;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSString *sectionNameKeyPath;
@property (nonatomic, readonly) NSString *cacheName;
@property (nonatomic, assign) id<NSFetchedResultsControllerDelegate> delegate;

+ (void) deleteCacheWithName: (NSString *) name;

@property (nonatomic, readonly) NSArray *fetchedObjects;
- (id) objectAtIndexPath: (NSIndexPath *) indexPath;
- (NSIndexPath *) indexPathForObject: (id) object;

- (NSString *) sectionIndexTitleForSectionName: (NSString *) sectionName;
@property (nonatomic, readonly) NSArray *sectionIndexTitles;

@property (nonatomic, readonly) NSArray *sections;
- (NSInteger) sectionForSectionIndexTitle: (NSString *) title atIndex: (NSInteger) sectionIndex;

@end
