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

#import <CoreData/NSPersistentHistoryChangeRequest.h>
#import <CoreData/NSPersistentHistoryTransaction.h>

@implementation NSPersistentHistoryChangeRequest

- (instancetype) init {
    if ((self = [super init])) {
        _resultType = NSPersistentHistoryResultTypeTransactionsAndChanges;
    }
    return self;
}

- (instancetype) _initWithDate: (NSDate *) date
                         token: (NSPersistentHistoryToken *) token
                        delete: (BOOL) isDelete {
    if ((self = [self init])) {
        _date = [date copy];
        _token = [token retain];
        _deleteHistoryRequest = isDelete;
        if (isDelete)
            _resultType = NSPersistentHistoryResultTypeStatusOnly;
    }
    return self;
}

+ (instancetype) fetchHistoryAfterDate: (NSDate *) date {
    return [[[self alloc] _initWithDate: date token: nil delete: NO] autorelease];
}

+ (instancetype) fetchHistoryAfterToken: (NSPersistentHistoryToken *) token {
    return [[[self alloc] _initWithDate: nil token: token delete: NO] autorelease];
}

+ (instancetype) fetchHistoryAfterTransaction: (NSPersistentHistoryTransaction *) transaction {
    return [self fetchHistoryAfterToken: [transaction token]];
}

+ (instancetype) deleteHistoryBeforeDate: (NSDate *) date {
    return [[[self alloc] _initWithDate: date token: nil delete: YES] autorelease];
}

+ (instancetype) deleteHistoryBeforeToken: (NSPersistentHistoryToken *) token {
    return [[[self alloc] _initWithDate: nil token: token delete: YES] autorelease];
}

+ (instancetype) deleteHistoryBeforeTransaction: (NSPersistentHistoryTransaction *) transaction {
    return [self deleteHistoryBeforeToken: [transaction token]];
}

- (void) dealloc {
    [_token release];
    [_date release];
    [super dealloc];
}

- (NSPersistentHistoryResultType) resultType {
    return _resultType;
}

- (void) setResultType: (NSPersistentHistoryResultType) resultType {
    _resultType = resultType;
}

- (NSPersistentHistoryToken *) token {
    return _token;
}

- (NSPersistentStoreRequestType) requestType {
    // NSPersistentHistoryChangeRequestType (private)
    return (NSPersistentStoreRequestType) 8;
}

- (id) copyWithZone: (NSZone *) zone {
    NSPersistentHistoryChangeRequest *copy = [super copyWithZone: zone];
    copy->_token = [_token retain];
    copy->_date = [_date copy];
    copy->_resultType = _resultType;
    copy->_deleteHistoryRequest = _deleteHistoryRequest;
    return copy;
}

@end
