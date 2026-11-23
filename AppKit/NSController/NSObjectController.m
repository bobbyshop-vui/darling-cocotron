/* Copyright (c) 2006-2007 Christopher J. W. Lloyd, 2007-2008 Johannes Fortmann

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
#import "NSControllerSelectionProxy.h"
#import "NSObservationProxy.h"
#import <AppKit/NSObjectController.h>
#import <Foundation/NSKeyValueObserving.h>
#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>

@interface NSObject (NSObjectControllerCoreDataForward)
+ (id) insertNewObjectForEntityForName: (NSString *) name
                inManagedObjectContext: (id) context;
- (NSArray *) executeFetchRequest: (id) request error: (NSError **) error;
@end

@interface NSObjectController (forward)
- (void) _selectionWillChange;
- (void) _selectionDidChange;

@end

@implementation NSObjectController
+ (void) initialize {
    [self setKeys: [NSArray arrayWithObjects: @"editable", nil]
            triggerChangeNotificationsForDependentKey: @"canAdd"];
    [self setKeys: [NSArray arrayWithObjects: @"editable", nil]
            triggerChangeNotificationsForDependentKey: @"canInsert"];
    [self setKeys: [NSArray arrayWithObjects: @"editable", @"selection", nil]
            triggerChangeNotificationsForDependentKey: @"canRemove"];
    [self setKeys: [NSArray arrayWithObjects: @"content", nil]
            triggerChangeNotificationsForDependentKey: @"contentObject"];
}

- (id) init {
    if ((self = [super init])) {
        _selection =
                [[NSControllerSelectionProxy alloc] initWithController: self];
    }
    return self;
}

- (id) initWithContent: (id) content {
    if ((self = [super init])) {
        _objectClassName = @"NSMutableDictionary";

        _editable = YES;
        _automaticallyPreparesContent = NO;

        _observedKeys = [[NSCountedSet alloc] init];
        _selection =
                [[NSControllerSelectionProxy alloc] initWithController: self];
    }

    return self;
}

- initWithCoder: (NSCoder *) coder {
    if ((self = [super init])) {

        _objectClassName =
                [[coder decodeObjectForKey: @"NSObjectClassName"] copy];
        if (_objectClassName == nil)
            _objectClassName = @"NSMutableDictionary";

        _editable = [coder decodeBoolForKey: @"NSEditable"];
        _automaticallyPreparesContent =
                [coder decodeBoolForKey: @"NSAutomaticallyPreparesContent"];

        _observedKeys = [[NSCountedSet alloc] init];
        _selection =
                [[NSControllerSelectionProxy alloc] initWithController: self];
    }
    return self;
}

- (void) prepareContent {
}

- (void) awakeFromNib {
    if ([self automaticallyPreparesContent]) {
        [self prepareContent];
    }
}

- (id) content {
    return [[_content retain] autorelease];
}

- (void) setContent: (id) value {
    if (value != _content) {
        [self _selectionWillChange];

        [_content release];
        _content = [value retain];

        [self _selectionDidChange];
    }
}

- (void) _setContentWithoutKVO: (id) value {
    if (_content != value) {
        [_content release];
        _content = [value retain];
    }
}

- (NSArray *) selectedObjects {
    if (_content == nil)
        return [NSArray array];
    return [NSArray arrayWithObject: _content];
}

- (id) selection {
    return _selection;
}

- (id) _defaultNewObject {
    if (_entityName != nil && _managedObjectContext != nil) {
        id description = NSClassFromString(@"NSEntityDescription");
        if (description != nil) {
            id object = [description
                    insertNewObjectForEntityForName: _entityName
                             inManagedObjectContext: _managedObjectContext];
            return [object retain];
        }
    }
    return [[[self objectClass] alloc] init];
}

- (id) newObject {
    return [self _defaultNewObject];
}

- (void) _selectionWillChange {
    [self willChangeValueForKey: @"selection"];
    [_selection controllerWillChange];
}

- (void) _selectionDidChange {
    [_selection controllerDidChange];
    [self didChangeValueForKey: @"selection"];
}

- (void) dealloc {
    [_selection release];
    [_objectClassName release];
    [_content release];
    [_observedKeys release];
    [_managedObjectContext release];
    [_entityName release];
    [_fetchPredicate release];
    [super dealloc];
}

- (BOOL) canAdd; {
    return [self isEditable];
}

- (BOOL) canRemove; {
    return [self isEditable] && [[self selectedObjects] count];
}

- (BOOL) isEditable {
    return _editable;
}

- (void) setEditable: (BOOL) value {
    _editable = value;
}

- (BOOL) automaticallyPreparesContent {
    return _automaticallyPreparesContent;
}

- (void) setAutomaticallyPreparesContent: (BOOL) value {
    _automaticallyPreparesContent = value;
}

- (Class) objectClass {
    Class result = _objectClassName ? NSClassFromString(_objectClassName) : Nil;
    return result ? result : [NSMutableDictionary class];
}

- (void) setObjectClass: (Class) aClass {
    NSString *name = aClass ? NSStringFromClass(aClass) : nil;
    if (name == nil)
        name = @"NSMutableDictionary";
    [_objectClassName release];
    _objectClassName = [name copy];
}

- (NSString *) entityName {
    return _entityName;
}

- (void) setEntityName: (NSString *) name {
    if (name != _entityName) {
        [_entityName release];
        _entityName = [name copy];
    }
}

- (NSPredicate *) fetchPredicate {
    return _fetchPredicate;
}

- (void) setFetchPredicate: (NSPredicate *) predicate {
    if (predicate != _fetchPredicate) {
        [_fetchPredicate release];
        _fetchPredicate = [predicate retain];
    }
}

- (NSManagedObjectContext *) managedObjectContext {
    return _managedObjectContext;
}

- (void) setManagedObjectContext: (NSManagedObjectContext *) context {
    if (context != _managedObjectContext) {
        [_managedObjectContext release];
        _managedObjectContext = [context retain];
    }
}

- (BOOL) usesLazyFetching {
    return _usesLazyFetching;
}

- (void) setUsesLazyFetching: (BOOL) flag {
    _usesLazyFetching = flag;
}

- (void) addObject: (id) object {
    [self setContent: object];
}

- (void) removeObject: (id) object {
    if (object != nil && object == _content)
        [self setContent: nil];
}

- (void) add: (id) sender {
    if (![self canAdd])
        return;
    if (![self commitEditing])
        return;

    id object = [self newObject];
    [self addObject: object];
    [object release];
}

- (void) remove: (id) sender {
    if (![self canRemove])
        return;
    if (![self commitEditing])
        return;

    NSArray *objects = [[[self selectedObjects] copy] autorelease];
    for (id object in objects)
        [self removeObject: object];
}

- (NSFetchRequest *) defaultFetchRequest {
    if (_entityName == nil)
        return nil;

    id requestClass = NSClassFromString(@"NSFetchRequest");
    if (requestClass == nil)
        return nil;

    id request = [[[requestClass alloc] init] autorelease];
    [request setEntityName: _entityName];
    if (_fetchPredicate != nil)
        [request setPredicate: _fetchPredicate];
    return request;
}

- (BOOL) fetchWithRequest: (NSFetchRequest *) fetchRequest
                    merge: (BOOL) merge
                    error: (NSError **) error
{
    if (fetchRequest == nil)
        fetchRequest = [self defaultFetchRequest];

    if (fetchRequest == nil || _managedObjectContext == nil) {
        if (error != NULL)
            *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                         code: 134060
                                     userInfo: nil];
        return NO;
    }

    id context = _managedObjectContext;
    NSArray *results = [context executeFetchRequest: fetchRequest error: error];
    if (results == nil)
        return NO;

    if ([self respondsToSelector: @selector(arrangedObjects)]) {
        NSMutableArray *newContent = [NSMutableArray array];
        if (merge && [_content isKindOfClass: [NSArray class]])
            [newContent addObjectsFromArray: _content];
        for (id object in results) {
            if (![newContent containsObject: object])
                [newContent addObject: object];
        }
        [self setContent: newContent];
    } else if (!(merge && _content != nil) && [results count] > 0) {
        [self setContent: [results objectAtIndex: 0]];
    }
    return YES;
}

- (void) fetch: (id) sender {
    NSError *error = nil;
    [self fetchWithRequest: nil merge: NO error: &error];
}

- (BOOL) validateUserInterfaceItem: (id<NSValidatedUserInterfaceItem>) item {
    SEL action = [item action];

    if (action == @selector(add:))
        return [self canAdd];
    if (action == @selector(remove:))
        return [self canRemove];
    if (action == @selector(fetch:))
        return _managedObjectContext != nil;
    return [self respondsToSelector: action];
}

- (void) addObserver: (NSObject *) observer
          forKeyPath: (NSString *) keyPath
             options: (NSKeyValueObservingOptions) options
             context: (void *) context
{
    [_observedKeys addObject: keyPath];
    [super addObserver: observer
            forKeyPath: keyPath
               options: options
               context: context];
}

- (void) removeObserver: (NSObject *) observer
             forKeyPath: (NSString *) keyPath
{
    [_observedKeys removeObject: keyPath];
    [super removeObserver: observer forKeyPath: keyPath];
}

- (id) _observedKeys {
    return _observedKeys;
}

- (id) _contentObject {
    return [self content];
}

- (void) _setContentObject: (id) val {
    [self setContent: val];
}
@end
