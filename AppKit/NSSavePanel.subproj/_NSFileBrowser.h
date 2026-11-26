/* Finder-style browser shown inside NSSavePanel / NSOpenPanel on platforms
   without a native file dialog (Darling's X11 backend): a sidebar of places,
   a path field with back/up buttons, a list of the current folder, a name
   field for save panels, New Folder, and the accessory view. */

#import <Foundation/NSObject.h>
#import <AppKit/NSTableView.h>

@class NSSavePanel, NSTextField, NSButton, NSView, NSURL, NSArray,
        NSMutableArray, NSString, NSDateFormatter;

@interface _NSFileBrowser : NSObject <NSTableViewDataSource, NSTableViewDelegate> {
    NSSavePanel *_panel; // not retained, the panel owns the browser
    NSTableView *_sidebar;
    NSTableView *_files;
    NSTextField *_pathField;
    NSTextField *_nameLabel;
    NSTextField *_nameField;
    NSTextField *_messageField;
    NSButton *_backButton;
    NSButton *_upButton;
    NSButton *_newFolderButton;
    NSButton *_hiddenButton;
    NSButton *_okButton;
    NSButton *_cancelButton;
    NSView *_accessoryHost;
    NSView *_mainArea;
    NSMutableArray *_places;
    NSMutableArray *_items;
    NSMutableArray *_history;
    NSString *_directory;
    NSDateFormatter *_dateFormatter;
}

- (instancetype) initWithPanel: (NSSavePanel *) panel;

// Builds the controls into the panel's content view.
- (void) install;

// Reads the panel's configuration (directory, name, prompt, message,
// accessory view, selection mode) before it is shown.
- (void) prepareForRun;

- (NSString *) directory;
- (void) goToDirectory: (NSString *) path;

// The URLs the panel should return, or nil if nothing acceptable is chosen
// (the panel then stays up).
- (NSArray *) chosenURLs;

@end
