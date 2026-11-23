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

@class NSNotification;
#import <CoreData/NSPersistentHistoryToken.h>
@class NSPersistentHistoryChange;

@interface NSPersistentHistoryTransaction : NSObject <NSCopying> {
    NSDate *_timestamp;
    NSArray *_changes;
    int64_t _transactionNumber;
    NSString *_storeID;
    NSString *_bundleID;
    NSString *_processID;
    NSString *_contextName;
    NSString *_author;
    NSPersistentHistoryToken *_token;
}

@property (readonly, copy) NSDate *timestamp;
@property (readonly, copy) NSArray<NSPersistentHistoryChange *> *changes;
@property (readonly) int64_t transactionNumber;
@property (readonly, copy) NSString *storeID;
@property (readonly, copy) NSString *bundleID;
@property (readonly, copy) NSString *processID;
@property (readonly, copy) NSString *contextName;
@property (readonly, copy) NSString *author;
@property (readonly, strong) NSPersistentHistoryToken *token;

- (NSNotification *) objectIDNotification;

@end
