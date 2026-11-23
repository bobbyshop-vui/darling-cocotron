#import <Foundation/Foundation.h>
#import <AppKit/NSDragging.h>

@class NSPasteboard, NSImage, NSMenuItem, NSToolbarItem, NSView, NSWindow,
        NSApplication, NSScriptObjectSpecifier;

@interface NSObject (XcodeAdditions)

// Bindings
+ (void) setDefaultPlaceholder: (id) placeholder
                     forMarker: (id) marker
                   withBinding: (NSString *) binding;
+ (id) defaultPlaceholderForMarker: (id) marker
                       withBinding: (NSString *) binding;
- (Class) valueClassForBinding: (NSString *) binding;

// Legacy accessibility informal protocol
- (NSArray *) accessibilityActionNames;
- (NSString *) accessibilityActionDescription: (NSString *) action;
- (void) accessibilityPerformAction: (NSString *) action;
- (NSArray *) accessibilityAttributeNames;
- (id) accessibilityAttributeValue: (NSString *) attribute;
- (BOOL) accessibilityIsAttributeSettable: (NSString *) attribute;
- (void) accessibilitySetValue: (id) value forAttribute: (NSString *) attribute;
- (BOOL) accessibilitySetOverrideValue: (id) value
                          forAttribute: (NSString *) attribute;
- (id) accessibilityFocusedUIElement;
- (id) accessibilityHitTest: (NSPoint) point;
- (NSUInteger) accessibilityIndexOfChild: (id) child;
- (BOOL) accessibilityIsIgnored;
- (BOOL) accessibilityNotifiesWhenDestroyed;

// Scripting
- (BOOL) application: (NSApplication *) sender
        delegateHandlesKey: (NSString *) key;
- (id) newScriptingObjectOfClass: (Class) objectClass
                  forValueForKey: (NSString *) key
               withContentsValue: (id) contentsValue
                      properties: (NSDictionary *) properties;
- (NSScriptObjectSpecifier *) objectSpecifier;

// Errors / KVC
- (BOOL) attemptRecoveryFromError: (NSError *) error
                      optionIndex: (NSUInteger) recoveryOptionIndex;
- (void) attemptRecoveryFromError: (NSError *) error
                      optionIndex: (NSUInteger) recoveryOptionIndex
                         delegate: (id) delegate
               didRecoverSelector: (SEL) didRecoverSelector
                      contextInfo: (void *) contextInfo;
- (BOOL) validateValue: (id *) ioValue
                forKey: (NSString *) key
                 error: (NSError **) outError;
- (BOOL) validateValue: (id *) ioValue
            forKeyPath: (NSString *) keyPath
                 error: (NSError **) outError;
- (void) setNilValueForKey: (NSString *) key;
- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *) context;

// NSEditor / NSEditorRegistration
- (BOOL) commitEditing;
- (void) commitEditingWithDelegate: (id) delegate
                 didCommitSelector: (SEL) didCommitSelector
                       contextInfo: (void *) contextInfo;
- (BOOL) commitEditingAndReturnError: (NSError **) error;
- (void) discardEditing;
- (void) objectDidBeginEditing: (id) editor;
- (void) objectDidEndEditing: (id) editor;

// Responder / delegate informal protocols
- (void) changeColor: (id) sender;
- (void) changeFont: (id) sender;
- (void) controlTextDidBeginEditing: (NSNotification *) note;
- (void) controlTextDidChange: (NSNotification *) note;
- (void) controlTextDidEndEditing: (NSNotification *) note;
- (void) textStorageDidProcessEditing: (NSNotification *) note;
- (BOOL) validateMenuItem: (NSMenuItem *) item;
- (BOOL) validateToolbarItem: (NSToolbarItem *) item;
- (void) prepareForInterfaceBuilder;

// Dragging source informal protocol
- (NSDragOperation) draggingSourceOperationMaskForLocal: (BOOL) flag;
- (BOOL) ignoreModifierKeysWhileDragging;
- (void) draggedImage: (NSImage *) image beganAt: (NSPoint) point;
- (void) draggedImage: (NSImage *) image movedTo: (NSPoint) point;
- (void) draggedImage: (NSImage *) image
              endedAt: (NSPoint) point
            operation: (NSDragOperation) operation;
- (void) draggedImage: (NSImage *) image
              endedAt: (NSPoint) point
            deposited: (BOOL) flag;
- (NSArray *) namesOfPromisedFilesDroppedAtDestination: (NSURL *) destination;

// Pasteboard owner / layer / tooltip
- (void) pasteboard: (NSPasteboard *) sender
        provideDataForType: (NSString *) type;
- (void) pasteboardChangedOwner: (NSPasteboard *) sender;
- (BOOL) layer: (id) layer
        shouldInheritContentsScale: (CGFloat) newScale
                        fromWindow: (NSWindow *) window;
- (NSString *) view: (NSView *) view
        stringForToolTip: (NSInteger) tag
                   point: (NSPoint) point
                userData: (void *) data;

@end
