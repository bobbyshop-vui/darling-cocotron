#import <AppKit/NSObject+XcodeAdditions.h>
#import <AppKit/NSAccessibilityConstants.h>
#import <AppKit/NSMenuItem.h>
#import <AppKit/NSToolbarItem.h>
#import <AppKit/NSResponder.h>
#import <Foundation/NSScriptObjectSpecifiers.h>

static NSMutableDictionary *XcodeDefaultPlaceholders(void) {
    static NSMutableDictionary *table = nil;
    if (table == nil)
        table = [[NSMutableDictionary alloc] init];
    return table;
}

static NSString *XcodePlaceholderKey(Class cls, id marker, NSString *binding) {
    return [NSString stringWithFormat: @"%@\n%@\n%p", NSStringFromClass(cls),
                                       binding, marker];
}

static BOOL XcodeValidateUIItem(id target, id item) {
    SEL sel = NSSelectorFromString(@"validateUserInterfaceItem:");
    BOOL (*send)(id, SEL, id) = (BOOL(*)(id, SEL, id))[target methodForSelector: sel];
    return send(target, sel, item);
}

@implementation NSObject (XcodeAdditions)

#pragma mark Bindings

+ (void) setDefaultPlaceholder: (id) placeholder
                     forMarker: (id) marker
                   withBinding: (NSString *) binding
{
    NSString *key = XcodePlaceholderKey(self, marker, binding);
    @synchronized(XcodeDefaultPlaceholders()) {
        if (placeholder == nil)
            [XcodeDefaultPlaceholders() removeObjectForKey: key];
        else
            [XcodeDefaultPlaceholders() setObject: placeholder forKey: key];
    }
}

+ (id) defaultPlaceholderForMarker: (id) marker
                       withBinding: (NSString *) binding
{
    Class cls = self;
    while (cls != Nil) {
        NSString *key = XcodePlaceholderKey(cls, marker, binding);
        id result;
        @synchronized(XcodeDefaultPlaceholders()) {
            result = [[[XcodeDefaultPlaceholders() objectForKey: key] retain]
                    autorelease];
        }
        if (result != nil)
            return result;
        cls = class_getSuperclass(cls);
    }
    return nil;
}

- (Class) valueClassForBinding: (NSString *) binding {
    return Nil;
}

#pragma mark Legacy accessibility

- (NSArray *) accessibilityActionNames {
    return [NSArray array];
}

- (NSString *) accessibilityActionDescription: (NSString *) action {
    return nil;
}

- (void) accessibilityPerformAction: (NSString *) action {
}

- (NSArray *) accessibilityAttributeNames {
    return [NSArray array];
}

- (id) accessibilityAttributeValue: (NSString *) attribute {
    return nil;
}

- (BOOL) accessibilityIsAttributeSettable: (NSString *) attribute {
    return NO;
}

- (void) accessibilitySetValue: (id) value forAttribute: (NSString *) attribute {
}

- (BOOL) accessibilitySetOverrideValue: (id) value
                          forAttribute: (NSString *) attribute
{
    return NO;
}

- (id) accessibilityFocusedUIElement {
    return self;
}

- (id) accessibilityHitTest: (NSPoint) point {
    return self;
}

- (NSUInteger) accessibilityIndexOfChild: (id) child {
    id children = [self accessibilityAttributeValue:
                                NSAccessibilityChildrenAttribute];
    if (![children isKindOfClass: [NSArray class]])
        return NSNotFound;
    return [(NSArray *) children indexOfObject: child];
}

- (BOOL) accessibilityIsIgnored {
    return NO;
}

- (BOOL) accessibilityNotifiesWhenDestroyed {
    return NO;
}

#pragma mark Scripting

- (BOOL) application: (NSApplication *) sender
        delegateHandlesKey: (NSString *) key
{
    return NO;
}

- (id) newScriptingObjectOfClass: (Class) objectClass
                  forValueForKey: (NSString *) key
               withContentsValue: (id) contentsValue
                      properties: (NSDictionary *) properties
{
    id object = [[objectClass alloc] init];
    if (object == nil)
        return nil;
    if ([properties count] > 0) {
        if ([object respondsToSelector: @selector(setScriptingProperties:)])
            [object performSelector: @selector(setScriptingProperties:)
                         withObject: properties];
        else
            [object setValuesForKeysWithDictionary: properties];
    }
    if (contentsValue != nil &&
        [object respondsToSelector: @selector(setScriptingContents:)])
        [object performSelector: @selector(setScriptingContents:)
                     withObject: contentsValue];
    return object;
}

- (NSScriptObjectSpecifier *) objectSpecifier {
    return nil;
}

#pragma mark Errors and KVC

- (BOOL) attemptRecoveryFromError: (NSError *) error
                      optionIndex: (NSUInteger) recoveryOptionIndex
{
    return NO;
}

- (void) attemptRecoveryFromError: (NSError *) error
                      optionIndex: (NSUInteger) recoveryOptionIndex
                         delegate: (id) delegate
               didRecoverSelector: (SEL) didRecoverSelector
                      contextInfo: (void *) contextInfo
{
    BOOL recovered = [self attemptRecoveryFromError: error
                                        optionIndex: recoveryOptionIndex];
    if (delegate != nil && didRecoverSelector != NULL) {
        void (*send)(id, SEL, BOOL, void *) =
                (void (*)(id, SEL, BOOL, void *))
                        [delegate methodForSelector: didRecoverSelector];
        send(delegate, didRecoverSelector, recovered, contextInfo);
    }
}

- (BOOL) validateValue: (id *) ioValue
                forKey: (NSString *) key
                 error: (NSError **) outError
{
    if ([key length] == 0)
        return YES;
    NSString *head = [[key substringToIndex: 1] uppercaseString];
    NSString *name = [NSString stringWithFormat: @"validate%@%@:error:", head,
                                                 [key substringFromIndex: 1]];
    SEL validator = NSSelectorFromString(name);
    if (![self respondsToSelector: validator])
        return YES;
    BOOL (*send)(id, SEL, id *, NSError **) =
            (BOOL(*)(id, SEL, id *, NSError **))[self methodForSelector:
                                                              validator];
    return send(self, validator, ioValue, outError);
}

- (BOOL) validateValue: (id *) ioValue
            forKeyPath: (NSString *) keyPath
                 error: (NSError **) outError
{
    NSRange dot = [keyPath rangeOfString: @"." options: NSBackwardsSearch];
    if (dot.location == NSNotFound)
        return [self validateValue: ioValue forKey: keyPath error: outError];
    id owner = [self valueForKeyPath: [keyPath substringToIndex: dot.location]];
    NSString *last = [keyPath substringFromIndex: NSMaxRange(dot)];
    if (owner == nil)
        return YES;
    return [owner validateValue: ioValue forKey: last error: outError];
}

- (void) setNilValueForKey: (NSString *) key {
    [NSException raise: NSInvalidArgumentException
                format: @"[<%@ %p> setNilValueForKey]: could not set nil as "
                        @"the value for the key %@.",
                        NSStringFromClass([self class]), self, key];
}

- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *) context
{
    [NSException raise: NSInternalInconsistencyException
                format: @"<%@: %p>: An -observeValueForKeyPath:ofObject:"
                        @"change:context: message was received but not "
                        @"handled.\nKey path: %@\nObserved object: %@\n"
                        @"Change: %@\nContext: %p",
                        NSStringFromClass([self class]), self, keyPath, object,
                        change, context];
}

#pragma mark Editing

- (BOOL) commitEditing {
    return YES;
}

- (void) commitEditingWithDelegate: (id) delegate
                 didCommitSelector: (SEL) didCommitSelector
                       contextInfo: (void *) contextInfo
{
    BOOL committed = [self commitEditing];
    if (delegate != nil && didCommitSelector != NULL) {
        void (*send)(id, SEL, id, BOOL, void *) =
                (void (*)(id, SEL, id, BOOL, void *))
                        [delegate methodForSelector: didCommitSelector];
        send(delegate, didCommitSelector, self, committed, contextInfo);
    }
}

- (BOOL) commitEditingAndReturnError: (NSError **) error {
    return [self commitEditing];
}

- (void) discardEditing {
}

- (void) objectDidBeginEditing: (id) editor {
}

- (void) objectDidEndEditing: (id) editor {
}

#pragma mark Responder and delegate informal protocols

// Responder-chain actions: forward along the chain so that adding them to
// NSObject does not stop -targetForAction: at the first responder.
- (void) changeColor: (id) sender {
    if ([self isKindOfClass: [NSResponder class]]) {
        NSResponder *next = [(NSResponder *) self nextResponder];
        if (next != nil)
            [next changeColor: sender];
    }
}

- (void) changeFont: (id) sender {
    if ([self isKindOfClass: [NSResponder class]]) {
        NSResponder *next = [(NSResponder *) self nextResponder];
        if (next != nil)
            [next changeFont: sender];
    }
}

- (void) controlTextDidBeginEditing: (NSNotification *) note {
}

- (void) controlTextDidChange: (NSNotification *) note {
}

- (void) controlTextDidEndEditing: (NSNotification *) note {
}

- (void) textStorageDidProcessEditing: (NSNotification *) note {
}

- (BOOL) validateMenuItem: (NSMenuItem *) item {
    if ([self respondsToSelector: @selector(validateUserInterfaceItem:)])
        return XcodeValidateUIItem(self, item);
    return YES;
}

- (BOOL) validateToolbarItem: (NSToolbarItem *) item {
    if ([self respondsToSelector: @selector(validateUserInterfaceItem:)])
        return XcodeValidateUIItem(self, item);
    return YES;
}

- (void) prepareForInterfaceBuilder {
}

#pragma mark Dragging source

- (NSDragOperation) draggingSourceOperationMaskForLocal: (BOOL) flag {
    return NSDragOperationCopy | NSDragOperationLink | NSDragOperationGeneric |
           NSDragOperationPrivate;
}

- (BOOL) ignoreModifierKeysWhileDragging {
    return NO;
}

- (void) draggedImage: (NSImage *) image beganAt: (NSPoint) point {
}

- (void) draggedImage: (NSImage *) image movedTo: (NSPoint) point {
}

- (void) draggedImage: (NSImage *) image
              endedAt: (NSPoint) point
            operation: (NSDragOperation) operation
{
    // The deprecated deposited: variant is the older form of this callback.
    [self draggedImage: image
               endedAt: point
             deposited: operation != NSDragOperationNone];
}

- (void) draggedImage: (NSImage *) image
              endedAt: (NSPoint) point
            deposited: (BOOL) flag
{
}

- (NSArray *) namesOfPromisedFilesDroppedAtDestination: (NSURL *) destination {
    return nil;
}

#pragma mark Pasteboard, layer, tooltip

- (void) pasteboard: (NSPasteboard *) sender
        provideDataForType: (NSString *) type
{
}

- (void) pasteboardChangedOwner: (NSPasteboard *) sender {
}

- (BOOL) layer: (id) layer
        shouldInheritContentsScale: (CGFloat) newScale
                        fromWindow: (NSWindow *) window
{
    return NO;
}

- (NSString *) view: (NSView *) view
        stringForToolTip: (NSInteger) tag
                   point: (NSPoint) point
                userData: (void *) data
{
    if ([self isKindOfClass: [NSString class]])
        return (NSString *) self;
    return @"";
}

@end
