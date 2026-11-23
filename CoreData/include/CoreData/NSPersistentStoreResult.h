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

@class NSError;
@class NSProgress;
@class NSManagedObjectContext;
@class NSFetchRequest;
@class NSAsynchronousFetchRequest;

typedef NS_ENUM(NSUInteger, NSBatchUpdateRequestResultType) {
    NSStatusOnlyResultType = 0x0,
    NSUpdatedObjectIDsResultType = 0x1,
    NSUpdatedObjectsCountResultType = 0x2
};

typedef NS_ENUM(NSUInteger, NSBatchDeleteRequestResultType) {
    NSBatchDeleteResultTypeStatusOnly = 0x0,
    NSBatchDeleteResultTypeObjectIDs = 0x1,
    NSBatchDeleteResultTypeCount = 0x2
};

typedef NS_ENUM(NSInteger, NSPersistentHistoryResultType) {
    NSPersistentHistoryResultTypeStatusOnly = 0x0,
    NSPersistentHistoryResultTypeObjectIDs = 0x1,
    NSPersistentHistoryResultTypeCount = 0x2,
    NSPersistentHistoryResultTypeTransactionsOnly = 0x3,
    NSPersistentHistoryResultTypeChangesOnly = 0x4,
    NSPersistentHistoryResultTypeTransactionsAndChanges = 0x5
};

@interface NSPersistentStoreResult : NSObject
@end

@interface NSPersistentStoreAsynchronousResult : NSPersistentStoreResult {
    NSProgress *_requestProgress;
    NSError *_requestError;
    NSManagedObjectContext *_requestContext;
    id _requestCompletionBlock;
    int32_t _flags;
}

@property (strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nullable, strong, readonly) NSError *operationError;
@property (nullable, strong, readonly) NSProgress *progress;

- (instancetype) initWithContext: (NSManagedObjectContext *) context
                        progress: (NSProgress *) progress;
- (void) setOperationError: (NSError *) error;
- (void) cancel;

@end

@interface NSAsynchronousFetchResult : NSPersistentStoreAsynchronousResult {
    NSAsynchronousFetchRequest *_fetchRequest;
    NSArray *_finalResult;
    id _intermediateResultCallback;
}

@property (strong, readonly) NSAsynchronousFetchRequest *fetchRequest;
@property (nullable, strong, readonly) NSArray *finalResult;

- (instancetype) initWithFetchRequest: (NSAsynchronousFetchRequest *) request
                              context: (NSManagedObjectContext *) context
                             progress: (NSProgress *) progress;
- (void) setFinalResult: (NSArray *) result;

@end

@interface NSBatchUpdateResult : NSPersistentStoreResult {
    id _aggregatedResult;
    NSBatchUpdateRequestResultType _resultType;
}

@property (nullable, strong, readonly) id result;
@property (readonly) NSBatchUpdateRequestResultType resultType;

- (instancetype) initWithResult: (id) result
                     resultType: (NSBatchUpdateRequestResultType) resultType;

@end

@interface NSBatchDeleteResult : NSPersistentStoreResult {
    id _aggregatedResult;
    NSBatchDeleteRequestResultType _resultType;
}

@property (nullable, strong, readonly) id result;
@property (readonly) NSBatchDeleteRequestResultType resultType;

- (instancetype) initWithResult: (id) result
                     resultType: (NSBatchDeleteRequestResultType) resultType;

@end

@interface NSPersistentHistoryResult : NSPersistentStoreResult {
    id _aggregatedResult;
    NSPersistentHistoryResultType _resultType;
}

@property (nullable, strong, readonly) id result;
@property (readonly) NSPersistentHistoryResultType resultType;

- (instancetype) initWithResult: (id) result
                     resultType: (NSPersistentHistoryResultType) resultType;

@end
