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

#import <CoreData/NSAsynchronousFetchRequest.h>
#import <CoreData/NSPersistentStoreResult.h>

@implementation NSAsynchronousFetchRequest

- (instancetype) initWithFetchRequest: (NSFetchRequest *) request
                      completionBlock: (void (^)(NSAsynchronousFetchResult *)) blk {
    if ((self = [super init])) {
        _fetchRequest = [request retain];
        _requestCompletionBlock = [blk copy];
    }
    return self;
}

- (void) dealloc {
    [_fetchRequest release];
    [_requestCompletionBlock release];
    [super dealloc];
}

- (NSFetchRequest *) fetchRequest {
    return _fetchRequest;
}

- (NSPersistentStoreAsynchronousFetchResultCompletionBlock) completionBlock {
    return _requestCompletionBlock;
}

- (NSInteger) estimatedResultCount {
    return _estimatedResultCount;
}

- (void) setEstimatedResultCount: (NSInteger) count {
    _estimatedResultCount = count;
}

- (NSPersistentStoreRequestType) requestType {
    // NSAsynchronousFetchRequestType (private)
    return (NSPersistentStoreRequestType) 3;
}

- (id) copyWithZone: (NSZone *) zone {
    NSAsynchronousFetchRequest *copy = [super copyWithZone: zone];
    copy->_fetchRequest = [_fetchRequest copy];
    copy->_requestCompletionBlock = [_requestCompletionBlock copy];
    copy->_estimatedResultCount = _estimatedResultCount;
    return copy;
}

@end
