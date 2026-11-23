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

#import <Foundation/Foundation.h>

@class NSManagedObject;

@interface NSMergeConflict : NSObject {
    NSManagedObject *_source;
    NSDictionary *_objectSnapshot;
    NSDictionary *_cachedSnapshot;
    NSDictionary *_persistedSnapshot;
    NSUInteger _newVersion;
    NSUInteger _oldVersion;
}

@property (readonly, retain) NSManagedObject *sourceObject;
@property (nullable, readonly, retain) NSDictionary<NSString *, id> *objectSnapshot;
@property (nullable, readonly, retain) NSDictionary<NSString *, id> *cachedSnapshot;
@property (nullable, readonly, retain) NSDictionary<NSString *, id> *persistedSnapshot;
@property (readonly) NSUInteger newVersionNumber;
@property (readonly) NSUInteger oldVersionNumber;

- (instancetype) initWithSource: (NSManagedObject *) srcObject
                     newVersion: (NSUInteger) newvers
                     oldVersion: (NSUInteger) oldvers
                 cachedSnapshot: (NSDictionary *) cachesnap
              persistedSnapshot: (NSDictionary *) persnap;
- (instancetype) init NS_UNAVAILABLE;

@end
