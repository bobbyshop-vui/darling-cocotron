#import <AppKit/NSControl.h>
#import <AppKit/NSDragging.h>
#import <AppKit/NSPathCell.h>

@class NSPathComponentCell;
@class NSPathControl;
@class NSOpenPanel;
@class NSPathControlItem;

@protocol NSPathControlDelegate

//@optional

- (BOOL) pathControl: (NSPathControl *) pathControl
          acceptDrop: (id<NSDraggingInfo>) info;
- (BOOL) pathControl: (NSPathControl *) pathControl
        shouldDragPathComponentCell: (NSPathComponentCell *) pathComponentCell
                     withPasteboard: (NSPasteboard *) pasteboard;
- (NSDragOperation) pathControl: (NSPathControl *) pathControl
                   validateDrop: (id<NSDraggingInfo>) info;

- (void) pathControl: (NSPathControl *) pathControl
        willDisplayOpenPanel: (NSOpenPanel *) openPanel;
- (void) pathControl: (NSPathControl *) pathControl
        willPopUpMenu: (NSMenu *) menu;

@end

@interface NSPathControl : NSControl {
    NSArray *_pathItems;
}

- (NSArray<NSString *> *) allowedTypes;
- (void) setAllowedTypes: (NSArray<NSString *> *) allowedTypes;
- (NSString *) placeholderString;
- (void) setPlaceholderString: (NSString *) string;
- (NSAttributedString *) placeholderAttributedString;
- (void) setPlaceholderAttributedString: (NSAttributedString *) string;
- (NSPathControlItem *) clickedPathItem;
- (NSArray<NSPathControlItem *> *) pathItems;
- (void) setPathItems: (NSArray<NSPathControlItem *> *) items;

- (NSPathStyle) pathStyle;
- (void) setPathStyle: (NSPathStyle) style;

- (NSColor *) backgroundColor;
- (void) setBackgroundColor: (NSColor *) color;

- (NSPathComponentCell *) clickedPathComponentCell;
- (NSArray *) pathComponentCells;
- (void) setPathComponentCells: (NSArray *) cells;

- (SEL) doubleAction;
- (void) setDoubleAction: (SEL) action;

- (NSURL *) URL;
- (void) setURL: (NSURL *) url;

- (id<NSPathControlDelegate>) delegate;
- (void) setDelegate: (id<NSPathControlDelegate>) delegate;

- (void) setDraggingSourceOperationMask: (NSDragOperation) mask
                               forLocal: (BOOL) isLocal;

- (NSMenu *) menu;
- (void) setMenu: (NSMenu *) menu;

@end