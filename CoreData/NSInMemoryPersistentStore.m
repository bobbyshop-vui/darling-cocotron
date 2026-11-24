#import "NSInMemoryPersistentStore.h"
#import <CoreData/CoreDataErrors.h>
#import <CoreData/NSPersistentStoreCoordinator.h>

@implementation NSInMemoryPersistentStore

- initWithPersistentStoreCoordinator: (NSPersistentStoreCoordinator *)coordinator
                   configurationName: (NSString *)configurationName
                                 URL: (NSURL *)url
                             options: (NSDictionary *)options {
    if ((self = [super initWithPersistentStoreCoordinator: coordinator
                                       configurationName: configurationName
                                                     URL: nil
                                                 options: options]) == nil)
        return nil;

    [self setMetadata: [NSDictionary dictionaryWithObjectsAndKeys:
            [self identifier], NSStoreUUIDKey, NSInMemoryStoreType, NSStoreTypeKey, nil]];
    return self;
}

+ (NSDictionary *) metadataForPersistentStoreWithURL: (NSURL *) url
                                               error: (NSError **) error
{
    if (error != NULL)
        *error = nil;
    return nil;
}

+ (BOOL) setMetadata: (NSDictionary *)metadata
        forPersistentStoreWithURL: (NSURL *)url
                            error: (NSError **)error {
    if (error != NULL) {
        *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                     code: NSPersistentStoreOperationError
                                 userInfo: [NSDictionary dictionaryWithObject:
                                         @"An in-memory store has no persistent metadata URL."
                                                                   forKey: NSLocalizedDescriptionKey]];
    }
    return NO;
}

- (NSString *) type {
    return NSInMemoryStoreType;
}

- (BOOL) load: (NSError **) errorp {
    if (errorp != NULL)
        *errorp = nil;
    return YES;
}

- (BOOL) save: (NSError **) error {
    if (error != NULL)
        *error = nil;
    return YES;
}

@end
