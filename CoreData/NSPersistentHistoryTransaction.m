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

#import <CoreData/NSPersistentHistoryTransaction.h>
#import <CoreData/NSManagedObjectContext.h>

/*
 * Darling has no persistent history tracking, so transactions are plain value
 * objects.  Defaults describe the current process, as macOS does for
 * transactions authored locally.
 */
@implementation NSPersistentHistoryTransaction

- (instancetype) init {
    if ((self = [super init])) {
        _timestamp = [[NSDate alloc] init];
        _changes = nil;
        _transactionNumber = 0;
        _storeID = [@"" copy];
        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
        _bundleID = [(bundleID ? bundleID : [[NSProcessInfo processInfo] processName]) copy];
        _processID = [[[NSProcessInfo processInfo] processName] copy];
    }
    return self;
}

- (void) dealloc {
    [_timestamp release];
    [_changes release];
    [_storeID release];
    [_bundleID release];
    [_processID release];
    [_contextName release];
    [_author release];
    [_token release];
    [super dealloc];
}

- (id) copyWithZone: (NSZone *) zone {
    NSPersistentHistoryTransaction *copy = [[[self class] allocWithZone: zone] init];
    [copy->_timestamp release];
    copy->_timestamp = [_timestamp copy];
    copy->_changes = [_changes copy];
    copy->_transactionNumber = _transactionNumber;
    [copy->_storeID release];
    copy->_storeID = [_storeID copy];
    [copy->_bundleID release];
    copy->_bundleID = [_bundleID copy];
    [copy->_processID release];
    copy->_processID = [_processID copy];
    copy->_contextName = [_contextName copy];
    copy->_author = [_author copy];
    copy->_token = [_token retain];
    return copy;
}

- (NSDate *) timestamp {
    return _timestamp;
}

- (NSArray *) changes {
    return _changes;
}

- (int64_t) transactionNumber {
    return _transactionNumber;
}

- (NSString *) storeID {
    return _storeID;
}

- (NSString *) bundleID {
    return _bundleID;
}

- (NSString *) processID {
    return _processID;
}

- (NSString *) contextName {
    return _contextName;
}

- (NSString *) author {
    return _author;
}

- (NSPersistentHistoryToken *) token {
    if (_token == nil) {
        _token = [[NSPersistentHistoryToken alloc] initWithTransactionNumber: _transactionNumber];
    }
    return _token;
}

- (NSNotification *) objectIDNotification {
    NSDictionary *userInfo = [NSDictionary dictionary];
    return [NSNotification notificationWithName: NSManagedObjectContextDidSaveNotification
                                         object: nil
                                       userInfo: userInfo];
}

@end
