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

#import <CoreData/NSPersistentStoreResult.h>
#import <CoreData/NSAsynchronousFetchRequest.h>

@implementation NSPersistentStoreResult
@end

enum {
    _NSAsyncResultCancelled = 1 << 0
};

@implementation NSPersistentStoreAsynchronousResult

- (instancetype) initWithContext: (NSManagedObjectContext *) context
                        progress: (NSProgress *) progress {
    if ((self = [super init])) {
        _requestContext = [context retain];
        _requestProgress = [progress retain];
    }
    return self;
}

- (void) dealloc {
    [_requestProgress release];
    [_requestError release];
    [_requestContext release];
    [_requestCompletionBlock release];
    [super dealloc];
}

- (NSManagedObjectContext *) managedObjectContext {
    return _requestContext;
}

- (NSError *) operationError {
    return _requestError;
}

- (void) setOperationError: (NSError *) error {
    if (_requestError != error) {
        [_requestError release];
        _requestError = [error retain];
    }
}

- (NSProgress *) progress {
    return _requestProgress;
}

- (void) cancel {
    _flags |= _NSAsyncResultCancelled;
    [_requestProgress cancel];
}

@end

@implementation NSAsynchronousFetchResult

- (instancetype) initWithFetchRequest: (NSAsynchronousFetchRequest *) request
                              context: (NSManagedObjectContext *) context
                             progress: (NSProgress *) progress {
    if ((self = [super initWithContext: context progress: progress])) {
        _fetchRequest = [request retain];
    }
    return self;
}

- (void) dealloc {
    [_fetchRequest release];
    [_finalResult release];
    [_intermediateResultCallback release];
    [super dealloc];
}

- (NSAsynchronousFetchRequest *) fetchRequest {
    return _fetchRequest;
}

- (NSArray *) finalResult {
    return _finalResult;
}

- (void) setFinalResult: (NSArray *) result {
    if (_finalResult != result) {
        [_finalResult release];
        _finalResult = [result retain];
    }
}

@end

@implementation NSBatchUpdateResult

- (instancetype) initWithResult: (id) result
                     resultType: (NSBatchUpdateRequestResultType) resultType {
    if ((self = [super init])) {
        _aggregatedResult = [result retain];
        _resultType = resultType;
    }
    return self;
}

- (void) dealloc {
    [_aggregatedResult release];
    [super dealloc];
}

- (id) result {
    return _aggregatedResult;
}

- (NSBatchUpdateRequestResultType) resultType {
    return _resultType;
}

@end

@implementation NSBatchDeleteResult

- (instancetype) initWithResult: (id) result
                     resultType: (NSBatchDeleteRequestResultType) resultType {
    if ((self = [super init])) {
        _aggregatedResult = [result retain];
        _resultType = resultType;
    }
    return self;
}

- (void) dealloc {
    [_aggregatedResult release];
    [super dealloc];
}

- (id) result {
    return _aggregatedResult;
}

- (NSBatchDeleteRequestResultType) resultType {
    return _resultType;
}

@end

@implementation NSPersistentHistoryResult

- (instancetype) initWithResult: (id) result
                     resultType: (NSPersistentHistoryResultType) resultType {
    if ((self = [super init])) {
        _aggregatedResult = [result retain];
        _resultType = resultType;
    }
    return self;
}

- (void) dealloc {
    [_aggregatedResult release];
    [super dealloc];
}

- (id) result {
    return _aggregatedResult;
}

- (NSPersistentHistoryResultType) resultType {
    return _resultType;
}

@end
