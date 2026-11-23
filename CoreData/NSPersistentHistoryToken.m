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

#import <CoreData/NSPersistentHistoryToken.h>

@implementation NSPersistentHistoryToken

+ (BOOL) supportsSecureCoding {
    return YES;
}

- (instancetype) initWithTransactionNumber: (int64_t) number {
    if ((self = [super init])) {
        _transactionNumber = number;
    }
    return self;
}

- (instancetype) init {
    return [self initWithTransactionNumber: 0];
}

- (instancetype) initWithCoder: (NSCoder *) coder {
    if (![coder allowsKeyedCoding]) {
        [self release];
        return nil;
    }
    return [self initWithTransactionNumber: [coder decodeInt64ForKey: @"NSTransactionNumber"]];
}

- (void) encodeWithCoder: (NSCoder *) coder {
    if ([coder allowsKeyedCoding]) {
        [coder encodeInt64: _transactionNumber forKey: @"NSTransactionNumber"];
    }
}

- (id) copyWithZone: (NSZone *) zone {
    return [[[self class] allocWithZone: zone] initWithTransactionNumber: _transactionNumber];
}

- (int64_t) transactionNumber {
    return _transactionNumber;
}

- (NSComparisonResult) compare: (NSPersistentHistoryToken *) other {
    if (_transactionNumber < other->_transactionNumber)
        return NSOrderedAscending;
    if (_transactionNumber > other->_transactionNumber)
        return NSOrderedDescending;
    return NSOrderedSame;
}

- (BOOL) isEqual: (id) other {
    if (other == self)
        return YES;
    if (![other isKindOfClass: [NSPersistentHistoryToken class]])
        return NO;
    return _transactionNumber == ((NSPersistentHistoryToken *) other)->_transactionNumber;
}

- (NSUInteger) hash {
    return (NSUInteger) _transactionNumber;
}

- (NSString *) description {
    return [NSString stringWithFormat: @"<%@: %p> transaction %lld",
            [self class], self, (long long) _transactionNumber];
}

@end
