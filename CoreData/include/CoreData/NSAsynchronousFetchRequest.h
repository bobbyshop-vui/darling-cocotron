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

#import <CoreData/NSPersistentStoreRequest.h>
@class NSManagedObjectContext;
#import <CoreData/NSFetchRequest.h>

@class NSAsynchronousFetchResult;

typedef void (^NSPersistentStoreAsynchronousFetchResultCompletionBlock)(NSAsynchronousFetchResult *result);

@interface NSAsynchronousFetchRequest : NSPersistentStoreRequest {
    NSFetchRequest *_fetchRequest;
    id _requestCompletionBlock;
    NSInteger _estimatedResultCount;
}

@property (strong, readonly) NSFetchRequest *fetchRequest;
@property (nullable, strong, readonly) NSPersistentStoreAsynchronousFetchResultCompletionBlock completionBlock;
@property (nonatomic) NSInteger estimatedResultCount;

- (instancetype) initWithFetchRequest: (NSFetchRequest *) request
                      completionBlock: (void (^)(NSAsynchronousFetchResult *)) blk;

@end
