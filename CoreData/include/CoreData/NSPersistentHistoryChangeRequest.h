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
#import <CoreData/NSPersistentStoreRequest.h>
#import <CoreData/NSPersistentStoreResult.h>

@class NSPersistentHistoryTransaction;
#import <CoreData/NSPersistentHistoryToken.h>

@interface NSPersistentHistoryChangeRequest : NSPersistentStoreRequest {
    NSPersistentHistoryToken *_token;
    NSPersistentHistoryResultType _resultType;
    NSDate *_date;
    BOOL _deleteHistoryRequest;
}

+ (instancetype) fetchHistoryAfterDate: (NSDate *) date;
+ (instancetype) fetchHistoryAfterToken: (NSPersistentHistoryToken *) token;
+ (instancetype) fetchHistoryAfterTransaction: (NSPersistentHistoryTransaction *) transaction;

+ (instancetype) deleteHistoryBeforeDate: (NSDate *) date;
+ (instancetype) deleteHistoryBeforeToken: (NSPersistentHistoryToken *) token;
+ (instancetype) deleteHistoryBeforeTransaction: (NSPersistentHistoryTransaction *) transaction;

@property NSPersistentHistoryResultType resultType;
@property (nullable, readonly, strong) NSPersistentHistoryToken *token;

@end
