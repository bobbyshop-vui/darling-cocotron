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

#import <CoreData/NSFetchedResultsController.h>
#import <CoreData/NSFetchRequest.h>
#import <CoreData/NSManagedObjectContext.h>

/* Section descriptor handed out by -sections. */
@interface _NSFetchedResultsSection : NSObject <NSFetchedResultsSectionInfo> {
    NSString *_name;
    NSString *_indexTitle;
    NSMutableArray *_objects;
}
- (instancetype) initWithName: (NSString *) name indexTitle: (NSString *) indexTitle;
- (void) addObject: (id) object;
@end

@implementation _NSFetchedResultsSection

- (instancetype) initWithName: (NSString *) name indexTitle: (NSString *) indexTitle {
    if ((self = [super init])) {
        _name = [name copy];
        _indexTitle = [indexTitle copy];
        _objects = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) dealloc {
    [_name release];
    [_indexTitle release];
    [_objects release];
    [super dealloc];
}

- (void) addObject: (id) object {
    [_objects addObject: object];
}

- (NSString *) name {
    return _name;
}

- (NSString *) indexTitle {
    return _indexTitle;
}

- (NSUInteger) numberOfObjects {
    return [_objects count];
}

- (NSArray *) objects {
    return _objects;
}

@end

@implementation NSFetchedResultsController

- (instancetype) initWithFetchRequest: (NSFetchRequest *) fetchRequest
                 managedObjectContext: (NSManagedObjectContext *) context
                   sectionNameKeyPath: (NSString *) sectionNameKeyPath
                            cacheName: (NSString *) name {
    if ((self = [super init])) {
        _fetchRequest = [fetchRequest retain];
        _managedObjectContext = [context retain];
        _sectionNameKeyPath = [sectionNameKeyPath copy];
        _cacheName = [name copy];
    }
    return self;
}

- (void) dealloc {
    [_fetchRequest release];
    [_managedObjectContext release];
    [_sectionNameKeyPath release];
    [_cacheName release];
    [_fetchedObjects release];
    [_sections release];
    [super dealloc];
}

- (BOOL) performFetch: (NSError **) error {
    NSArray *results = [_managedObjectContext executeFetchRequest: _fetchRequest error: error];
    if (results == nil) {
        return NO;
    }

    NSMutableArray *sections = [[NSMutableArray alloc] init];
    _NSFetchedResultsSection *current = nil;
    for (id object in results) {
        NSString *name = @"";
        if (_sectionNameKeyPath != nil) {
            id value = [object valueForKeyPath: _sectionNameKeyPath];
            name = value ? [value description] : @"";
        }
        if (current == nil || ![[current name] isEqualToString: name]) {
            current = [[_NSFetchedResultsSection alloc]
                    initWithName: name
                      indexTitle: [self sectionIndexTitleForSectionName: name]];
            [sections addObject: current];
            [current release];
        }
        [current addObject: object];
    }

    [_fetchedObjects release];
    _fetchedObjects = [results copy];
    [_sections release];
    _sections = sections;
    return YES;
}

- (NSFetchRequest *) fetchRequest {
    return _fetchRequest;
}

- (NSManagedObjectContext *) managedObjectContext {
    return _managedObjectContext;
}

- (NSString *) sectionNameKeyPath {
    return _sectionNameKeyPath;
}

- (NSString *) cacheName {
    return _cacheName;
}

- (id) delegate {
    return _delegate;
}

- (void) setDelegate: (id) delegate {
    _delegate = delegate;
}

+ (void) deleteCacheWithName: (NSString *) name {
    /* Section information is never persisted, so there is no cache to delete. */
}

- (NSArray *) fetchedObjects {
    return _fetchedObjects;
}

- (id) objectAtIndexPath: (NSIndexPath *) indexPath {
    NSUInteger section = [indexPath indexAtPosition: 0];
    NSUInteger row = [indexPath indexAtPosition: 1];
    if (section >= [_sections count]) {
        [NSException raise: NSRangeException
                    format: @"Section %lu out of range", (unsigned long) section];
    }
    return [[(id<NSFetchedResultsSectionInfo>) [_sections objectAtIndex: section] objects]
            objectAtIndex: row];
}

- (NSIndexPath *) indexPathForObject: (id) object {
    NSUInteger section = 0;
    for (id<NSFetchedResultsSectionInfo> info in _sections) {
        NSUInteger row = [[info objects] indexOfObjectIdenticalTo: object];
        if (row != NSNotFound) {
            NSUInteger indexes[2] = {section, row};
            return [NSIndexPath indexPathWithIndexes: indexes length: 2];
        }
        section++;
    }
    return nil;
}

- (NSString *) sectionIndexTitleForSectionName: (NSString *) sectionName {
    if ([_delegate respondsToSelector: @selector(controller:sectionIndexTitleForSectionName:)]) {
        return [_delegate controller: self sectionIndexTitleForSectionName: sectionName];
    }
    if ([sectionName length] == 0) {
        return @"";
    }
    return [[sectionName substringToIndex: 1] uppercaseString];
}

- (NSArray *) sectionIndexTitles {
    NSMutableArray *titles = [NSMutableArray array];
    for (id<NSFetchedResultsSectionInfo> info in _sections) {
        NSString *title = [info indexTitle];
        if (title != nil) {
            [titles addObject: title];
        }
    }
    return titles;
}

- (NSArray *) sections {
    return _sections;
}

- (NSInteger) sectionForSectionIndexTitle: (NSString *) title atIndex: (NSInteger) sectionIndex {
    NSUInteger i = 0;
    for (id<NSFetchedResultsSectionInfo> info in _sections) {
        if ([[info indexTitle] isEqualToString: title]) {
            return (NSInteger) i;
        }
        i++;
    }
    return sectionIndex;
}

@end
