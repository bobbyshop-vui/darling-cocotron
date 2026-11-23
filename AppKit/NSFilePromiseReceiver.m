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

#import <AppKit/NSFilePromiseReceiver.h>

static NSString *const PromisedFileURLType = @"com.apple.pasteboard.promised-file-url";
static NSString *const PromisedFileContentType = @"com.apple.pasteboard.promised-file-content-type";

@implementation NSFilePromiseReceiver

+ (NSArray *)readableDraggedTypes
{
    return [NSArray arrayWithObjects:PromisedFileURLType, PromisedFileContentType, NSFilesPromisePboardType, nil];
}

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return [self readableDraggedTypes];
}

+ (NSUInteger)readingOptionsForType:(NSPasteboardType)type pasteboard:(NSPasteboard *)pasteboard
{
    return 2; /* NSPasteboardReadingAsPropertyList */
}

- (instancetype)init
{
    if ((self = [super init]) != nil) {
        _fileTypes = [[NSArray alloc] init];
        _fileNames = [[NSArray alloc] init];
        _fileURLs = [[NSArray alloc] init];
    }
    return self;
}

- (id)initWithPasteboardPropertyList:(id)propertyList ofType:(NSPasteboardType)type
{
    if ((self = [self init]) == nil)
        return nil;

    _promiseType = [type copy];
    if ([type isEqualToString:PromisedFileContentType]) {
        if ([propertyList isKindOfClass:[NSString class]]) {
            [_fileTypes release];
            _fileTypes = [[NSArray alloc] initWithObjects:propertyList, nil];
        }
    } else if ([type isEqualToString:PromisedFileURLType]) {
        NSURL *url = nil;
        if ([propertyList isKindOfClass:[NSURL class]])
            url = propertyList;
        else if ([propertyList isKindOfClass:[NSString class]])
            url = [NSURL URLWithString:propertyList];
        if (url != nil) {
            [_fileURLs release];
            _fileURLs = [[NSArray alloc] initWithObjects:url, nil];
        }
    } else if ([type isEqualToString:NSFilesPromisePboardType]) {
        if ([propertyList isKindOfClass:[NSArray class]]) {
            [_fileTypes release];
            _fileTypes = [propertyList copy];
        }
    }
    return self;
}

- (void)dealloc
{
    [_fileTypes release];
    [_fileNames release];
    [_fileURLs release];
    [_promiseType release];
    [super dealloc];
}

- (NSArray *)fileTypes
{
    return _fileTypes;
}

- (NSArray *)fileNames
{
    return _fileNames;
}

- (void)receivePromisedFilesAtDestination:(NSURL *)destinationDir
                                  options:(NSDictionary *)options
                           operationQueue:(NSOperationQueue *)operationQueue
                                   reader:(void (^)(NSURL *fileURL, NSError *errorOrNil))reader
{
    NSMutableArray *names = [NSMutableArray array];
    NSMutableArray *results = [NSMutableArray array];
    NSFileManager *fm = [NSFileManager defaultManager];

    /* Without a live promise provider the only promises that can be fulfilled are those that
       already name an existing file; those are copied into the destination. */
    for (NSURL *source in _fileURLs) {
        NSString *name = [[source path] lastPathComponent];
        NSURL *target = [destinationDir URLByAppendingPathComponent:name];
        NSError *error = nil;
        if ([fm copyItemAtURL:source toURL:target error:&error]) {
            [names addObject:name];
            [results addObject:target];
        } else {
            [results addObject:error];
        }
    }
    if ([_fileURLs count] == 0) {
        NSUInteger count = [_fileTypes count] > 0 ? [_fileTypes count] : 1;
        for (NSUInteger i = 0; i < count; i++) {
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:nil];
            [results addObject:error];
        }
    }

    [_fileNames release];
    _fileNames = [names copy];

    NSArray *delivered = [results copy];
    void (^block)(void) = ^{
        for (id result in delivered) {
            if ([result isKindOfClass:[NSError class]])
                reader(nil, result);
            else
                reader(result, nil);
        }
    };
    if (operationQueue != nil)
        [operationQueue addOperationWithBlock:block];
    else
        block();
    [delivered release];
}

@end
