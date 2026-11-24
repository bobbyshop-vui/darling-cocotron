/* Copyright (c) 2008 Dan Knapp

 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do
 so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE. */
#import "NSPersistentDocument.h"
#import <AppKit/NSDocument.h>
#import <AppKit/NSNib.h>
#import <CoreData/NSManagedObjectContext.h>
#import <CoreData/NSPersistentStoreCoordinator.h>
#import <Foundation/NSRaise.h>

// not sure where to put this
NSString *const NSDataBinding = @"NSDataBinding";
NSString *const NSDisplayNameBindingOption = @"NSDisplayNameBindingOption";

@implementation NSPersistentDocument

- (id) init {
    self = [super init];
    if (self) {
        _context = [[NSManagedObjectContext alloc] init];
        NSManagedObjectModel *model =
                [[NSManagedObjectModel alloc] initWithName: [self className]];
        NSPersistentStoreCoordinator *coordinator =
                [[NSPersistentStoreCoordinator alloc]
                        initWithManagedObjectModel: model];
        [_context setPersistentStoreCoordinator: coordinator];
    }
    return self;
}

- (void) dealloc {
    [_context release];
    [super dealloc];
}

- (NSManagedObjectContext *) managedObjectContext {
    return _context;
}

- (NSManagedObjectModel *) managedObjectModel {
    return [[_context persistentStoreCoordinator] managedObjectModel];
}

- (void) setManagedObjectContext:
        (NSManagedObjectContext *) managedObjectContext
{
    if (managedObjectContext == _context)
        return;

    [managedObjectContext retain];
    [_context release];
    _context = managedObjectContext;
}

- (BOOL) configurePersistentStoreCoordinatorForURL: (NSURL *) url
                                            ofType: (NSString *) fileType
                                modelConfiguration: (NSString *) configuration
                                      storeOptions:
                                              (NSDictionary *) storeOptions
                                             error: (NSError **) error
{
    NSPersistentStoreCoordinator *coordinator =
            [_context persistentStoreCoordinator];
    if (url == nil || coordinator == nil) {
        if (error != NULL)
            *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                          code: NSFeatureUnsupportedError
                                      userInfo: nil];
        return NO;
    }

    if ([coordinator persistentStoreForURL: url] != nil)
        return YES;

    NSString *storeType = [self persistentStoreTypeForFileType: fileType];
    return [coordinator addPersistentStoreWithType: storeType
                                     configuration: configuration
                                               URL: url
                                           options: storeOptions
                                             error: error] != nil;
}

- (NSString *) persistentStoreTypeForFileType: (NSString *) fileType {
    NSArray *documentTypes = [[[NSBundle mainBundle] infoDictionary]
            objectForKey: @"CFBundleDocumentTypes"];
    for (NSDictionary *documentType in documentTypes) {
        if ([[documentType objectForKey: @"CFBundleTypeName"]
                    isEqualToString: fileType]) {
            NSString *storeType =
                    [documentType objectForKey: @"NSPersistentStoreType"];
            if ([storeType isKindOfClass: [NSString class]] &&
                [storeType length] > 0)
                return storeType;
            break;
        }
    }
    return NSXMLStoreType;
}

- (BOOL) hasUndoManager {
    return YES;
}

- (void) setHasUndoManager: (BOOL) flag
{ /* Ignored.  Always has an undo manager. */
}

- (void) setUndoManager: (NSUndoManager *) undoManager
{ /* Ignored.  Always uses the undo manager of its persistent context. */
}

- (BOOL) isDocumentEdited {
    return [super isDocumentEdited] || [_context hasChanges];
}

- (BOOL) readFromURL: (NSURL *) absoluteURL
              ofType: (NSString *) typeName
               error: (NSError **) outError
{
    if (absoluteURL == nil || ![absoluteURL isFileURL] || _context == nil) {
        if (outError != NULL)
            *outError = [NSError errorWithDomain: NSCocoaErrorDomain
                                             code: 1
                                         userInfo: [NSDictionary
                                                 dictionaryWithObject:
                                                         @"A file URL and a managed object context are required to read a persistent document."
                                                     forKey:
                                                         NSLocalizedDescriptionKey]];
        return NO;
    }

    NSPersistentStoreCoordinator *coordinator =
            [_context persistentStoreCoordinator];
    if (coordinator == nil) {
        if (outError != NULL)
            *outError = [NSError errorWithDomain: NSCocoaErrorDomain
                                             code: 1
                                         userInfo: [NSDictionary
                                                 dictionaryWithObject:
                                                         @"The managed object context has no persistent store coordinator."
                                                     forKey:
                                                         NSLocalizedDescriptionKey]];
        return NO;
    }

    [_context reset];
    NSArray *oldStores = [[coordinator persistentStores] copy];
    for (id store in oldStores) {
        if (![coordinator removePersistentStore: store error: outError]) {
            [oldStores release];
            return NO;
        }
    }
    [oldStores release];

    if ([coordinator addPersistentStoreWithType: NSXMLStoreType
                                  configuration: nil
                                            URL: absoluteURL
                                        options: nil
                                          error: outError] == nil)
        return NO;
    return YES;
}

- (BOOL) revertToContentsOfURL: (NSURL *) inAbsoluteURL
                        ofType: (NSString *) inTypeName
                         error: (NSError **) outError
{
    if (![self readFromURL: inAbsoluteURL ofType: inTypeName error: outError])
        return NO;

    [self updateChangeCount: NSChangeCleared];
    return YES;
}

- (BOOL) writeToURL: (NSURL *) absoluteURL
                     ofType: (NSString *) typeName
           forSaveOperation: (NSSaveOperationType) saveOperation
        originalContentsURL: (NSURL *) absoluteOriginalContentsURL
                      error: (NSError **) error
{
    if (absoluteURL == nil || ![absoluteURL isFileURL] || _context == nil) {
        if (error != NULL)
            *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                          code: 1
                                      userInfo: [NSDictionary
                                              dictionaryWithObject:
                                                      @"A file URL and a managed object context are required to write a persistent document."
                                                  forKey:
                                                      NSLocalizedDescriptionKey]];
        return NO;
    }

    NSPersistentStoreCoordinator *coordinator =
            [_context persistentStoreCoordinator];
    if (coordinator == nil) {
        if (error != NULL)
            *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                          code: 1
                                      userInfo: [NSDictionary
                                              dictionaryWithObject:
                                                      @"The managed object context has no persistent store coordinator."
                                                  forKey:
                                                      NSLocalizedDescriptionKey]];
        return NO;
    }

    id store = absoluteOriginalContentsURL != nil
                       ? [coordinator persistentStoreForURL:
                                             absoluteOriginalContentsURL]
                       : nil;
    if (store == nil && [[coordinator persistentStores] count] == 1)
        store = [[coordinator persistentStores] objectAtIndex: 0];

    if (store == nil) {
        store = [coordinator addPersistentStoreWithType: NSXMLStoreType
                                          configuration: nil
                                                    URL: absoluteURL
                                                options: nil
                                                  error: error];
        if (store == nil)
            return NO;
    } else {
        NSURL *storeURL = [coordinator URLForPersistentStore: store];
        if (![storeURL isEqual: absoluteURL] &&
            ![coordinator setURL: absoluteURL forPersistentStore: store]) {
            if (error != NULL)
                *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                              code: 1
                                          userInfo: [NSDictionary
                                                  dictionaryWithObject:
                                                          @"The persistent store could not be moved to the requested URL."
                                                      forKey:
                                                          NSLocalizedDescriptionKey]];
            return NO;
        }
    }

    return [_context save: error];
}

@end
