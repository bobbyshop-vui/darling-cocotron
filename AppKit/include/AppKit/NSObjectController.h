/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <AppKit/NSController.h>
#import <AppKit/NSUserInterfaceValidation.h>
@class NSString, NSPredicate, NSFetchRequest, NSManagedObjectContext,
        NSMenuItem, NSError, NSArray, NSCountedSet;

@interface NSObjectController : NSController {
    NSString *_objectClassName;
    id _content;
    id _selection;
    BOOL _editable;
    BOOL _automaticallyPreparesContent;
    NSCountedSet *_observedKeys;
    NSManagedObjectContext *_managedObjectContext;
    NSString *_entityName;
    NSPredicate *_fetchPredicate;
    BOOL _usesLazyFetching;
}
- (void) setContent: (id) content;
- (id) content;

- (id) selection;
- (NSArray *) selectedObjects;

- initWithContent: (id) content;

- (Class) objectClass;
- (NSString *) entityName;
- (NSPredicate *) fetchPredicate;
- (NSManagedObjectContext *) managedObjectContext;
- (BOOL) isEditable;
- (BOOL) automaticallyPreparesContent;

- (void) setObjectClass: (Class) aClass;
- (void) setEntityName: (NSString *) name;
- (void) setFetchPredicate: (NSPredicate *) predicate;
- (void) setManagedObjectContext: (NSManagedObjectContext *) context;
- (BOOL) usesLazyFetching;
- (void) setUsesLazyFetching: (BOOL) flag;
- (void) setEditable: (BOOL) flag;
- (void) setAutomaticallyPreparesContent: (BOOL) flag;

- (void) addObject: (id) object;

- newObject;

- (BOOL) canAdd;
- (BOOL) canRemove;
- (void) add: (id) sender;
- (void) fetch: (id) sender;
- (void) remove: (id) sender;
- (void) removeObject: (id) object;

- (void) prepareContent;

- (BOOL) fetchWithRequest: (NSFetchRequest *) fetchRequest
                    merge: (BOOL) merge
                    error: (NSError **) error;
- (NSFetchRequest *) defaultFetchRequest;

- (BOOL) validateUserInterfaceItem: (id<NSValidatedUserInterfaceItem>) item;

@end
