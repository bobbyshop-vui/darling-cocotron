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

#import <CoreData/NSMergeConflict.h>
#import <CoreData/NSManagedObject.h>

@implementation NSMergeConflict

- (instancetype) initWithSource: (NSManagedObject *) srcObject
                     newVersion: (NSUInteger) newvers
                     oldVersion: (NSUInteger) oldvers
                 cachedSnapshot: (NSDictionary *) cachesnap
              persistedSnapshot: (NSDictionary *) persnap {
    if ((self = [super init])) {
        _source = [srcObject retain];
        _newVersion = newvers;
        _oldVersion = oldvers;
        _cachedSnapshot = [cachesnap copy];
        _persistedSnapshot = [persnap copy];
    }
    return self;
}

- (instancetype) init {
    [self release];
    [NSException raise: NSInvalidArgumentException
                format: @"-[NSMergeConflict init] is not available; use initWithSource:newVersion:oldVersion:cachedSnapshot:persistedSnapshot:"];
    return nil;
}

- (void) dealloc {
    [_source release];
    [_objectSnapshot release];
    [_cachedSnapshot release];
    [_persistedSnapshot release];
    [super dealloc];
}

- (NSManagedObject *) sourceObject {
    return _source;
}

- (NSDictionary *) objectSnapshot {
    return _objectSnapshot;
}

- (NSDictionary *) cachedSnapshot {
    return _cachedSnapshot;
}

- (NSDictionary *) persistedSnapshot {
    return _persistedSnapshot;
}

- (NSUInteger) newVersionNumber {
    return _newVersion;
}

- (NSUInteger) oldVersionNumber {
    return _oldVersion;
}

@end
