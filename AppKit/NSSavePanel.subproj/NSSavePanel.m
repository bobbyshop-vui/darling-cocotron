/* Copyright (c) 2006-2007 Christopher J. W. Lloyd <cjwl@objc.net>, 2008
Johannes Fortmann

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

#import <AppKit/NSApplication.h>
#import <AppKit/NSDisplay.h>
#import <AppKit/NSRaise.h>
#import <AppKit/NSButton.h>
#import <AppKit/NSOutlineView.h>
#import <AppKit/NSSavePanel.h>
#import <AppKit/NSView.h>
#import "_NSFileSystemDataSource.h"
#import "_NSFileBrowser.h"

@interface NSSavePanel ()
- (void) _completeWithResult: (NSModalResponse) result;
- (void) _setSelectedURLs: (NSArray *) urls;
- (void) _prepareOutline;
@end


@implementation NSSavePanel

@synthesize showsHiddenFiles=_showsHiddenFiles;

// Creates a panel of this class with the Finder-style browser (the nib's
// outline view only showed a tree from "/", had no name field to save with
// and couldn't create folders).
+ (id) _newPanelWithFileBrowser {
    NSSavePanel *panel = [[self alloc]
            initWithContentRect: NSMakeRect(0, 0, 820, 520)
                      styleMask: NSTitledWindowMask | NSClosableWindowMask |
                                 NSResizableWindowMask
                        backing: NSBackingStoreBuffered
                          defer: YES];
    [panel setReleasedWhenClosed: NO];
    panel->_browser = [[_NSFileBrowser alloc] initWithPanel: panel];
    [panel->_browser install];
    return panel;
}

- (id) resetToDefaultValues {
    if (_completionHandler != nil)
        [self _completeWithResult: (NSModalResponse) NSCancelButton];
    _dialogTitle = @"Save";
    _nameFieldStringValue = @"";
    _filename = @"";
    _directory = [NSHomeDirectory() copy];
    _requiredFileType = @"";
    _treatsFilePackagesAsDirectories = NO;
    _accessoryView = nil;
    _showsHiddenFiles = false;
    _canCreateDirectories = YES;
    _allowsOtherFileTypes = YES;
    _usesModalCompletionHandler = NO;
    [_completionHandler release];
    _completionHandler = nil;
    [_nameFieldLabel release];
    _nameFieldLabel = nil;
    _canSelectHiddenExtension = NO;
    _extensionHidden = NO;
    _showsTagField = YES;
    _expanded = NO;
    return self;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    id dataSource = [_outlineView dataSource];
    if ([dataSource isKindOfClass: [_NSFileSystemDataSource class]])
        [dataSource setPanel: self];
    [_outlineView setTarget: self];
    [_outlineView setDoubleAction: @selector(_doubleClick:)];
}

- (void) _doubleClick: (id) sender {
    NSInteger row = [_outlineView clickedRow];
    if (row < 0)
        return;
    id item = [_outlineView itemAtRow: row];
    _NSFileSystemDataSource *dataSource = [_outlineView dataSource];
    if (![dataSource isKindOfClass: [_NSFileSystemDataSource class]])
        return;
    // Folders expand/collapse on their own, everything else is chosen.
    if ([_outlineView isExpandable: item])
        return;
    if ([dataSource isEnabledItem: item])
        [self _selectFile: sender];
}

- (void) _prepareOutline {
    if (_browser != nil) {
        if ([[self title] length] == 0 || [[self title] isEqualToString: @"Window"])
            [super setTitle: _dialogTitle];
        [_browser prepareForRun];
        [self center];
        return;
    }

    id dataSource = [_outlineView dataSource];
    if (![dataSource isKindOfClass: [_NSFileSystemDataSource class]])
        return;

    [dataSource setPanel: self];
    [dataSource reset];
    if ([_prompt length] > 0) {
        for (NSView *view in [[self contentView] subviews])
            if ([view isKindOfClass: [NSButton class]] &&
                [(NSButton *) view action] == @selector(_selectFile:))
                [(NSButton *) view setTitle: _prompt];
    }
    [_outlineView setAllowsMultipleSelection: [self respondsToSelector:
                                    @selector(allowsMultipleSelection)] &&
                                    [(id) self allowsMultipleSelection]];
    [_outlineView reloadData];

    // Expand down to the initial directory and select the initial file.
    NSString *path = [_filename length] > 0 ? _filename : _directory;
    if ([path length] == 0)
        return;
    if (![path isAbsolutePath])
        path = [_directory stringByAppendingPathComponent: path];

    NSString *walk = @"/";
    NSArray *components = [path pathComponents];
    id target = nil;
    for (NSString *component in components) {
        if ([component isEqualToString: @"/"])
            continue;
        walk = [walk stringByAppendingPathComponent: component];
        id item = [dataSource itemForPath: walk];
        if (![[NSFileManager defaultManager] fileExistsAtPath: walk])
            break;
        if (![_outlineView isExpandable: item]) {
            target = item;
            break;
        }
        target = item;
        if (![walk isEqualToString: path])
            [_outlineView expandItem: item];
    }
    if (target != nil) {
        NSInteger row = [_outlineView rowForItem: target];
        if (row >= 0) {
            [_outlineView selectRowIndexes: [NSIndexSet indexSetWithIndex: row]
                      byExtendingSelection: NO];
            [_outlineView scrollRowToVisible: row];
        }
    }
}

- (void) _setSelectedURLs: (NSArray *) urls {
    [self _setFilename: [[urls objectAtIndex: 0] path]];
}

- (BOOL) isExpanded {
    return _expanded;
}

- (void) setExpanded: (BOOL) flag {
    _expanded = flag;
}

- (void) validateVisibleColumns {
}

- (IBAction) ok: (id) sender {
    [self _selectFile: sender];
}

static NSSavePanel *_newPanel = nil;

+ (void) set_newPanel: (NSSavePanel *) newPanel {
    _newPanel = newPanel;
}

+ (NSSavePanel *) savePanel {
    if ([[NSDisplay currentDisplay] implementsCustomPanelForClass: self]) {
        _newPanel = [[self alloc]
                initWithContentRect: NSMakeRect(0, 0, 1, 1)
                          styleMask: NSTitledWindowMask | NSResizableWindowMask
                            backing: NSBackingStoreBuffered
                              defer: YES];
    } else {
        _newPanel = [self _newPanelWithFileBrowser];
    }
    // FIXME: release it?
    return [_newPanel resetToDefaultValues];
}

- init {
    [self release];
    return [[NSSavePanel savePanel] retain];
}

- (void) dealloc {
    [_dialogTitle release];
    [_nameFieldStringValue release];
    [_filename release];
    [_directory release];
    [_requiredFileType release];
    [_accessoryView release];
    [_nameFieldLabel release];
    [_completionHandler release];
    [_browser release];
    [super dealloc];
}

- (void) _setFilename: (NSString *) filename {
    @synchronized(self) {
        if (filename != _filename) {
            [_filename release];
            _filename = [filename copy];
            if (_filename == nil) {
                _filename = @"";
            }
        }
    }
}

- (NSURL *) URL {
    return [NSURL fileURLWithPath: [self filename]];
}

- (NSString *) filename {
    id ret = nil;
    @synchronized(self) {
        ret = [[_filename copy] autorelease];
    }
    return ret;
}

- (NSString *) nameFieldStringValue {
    id ret = [_nameFieldStringValue copy];
    return ret;
}

- (void) setNameFieldStringValue: (NSString *) value {
    [_nameFieldStringValue release];
    _nameFieldStringValue = [value copy];

    if (_nameFieldStringValue == nil) {
        _nameFieldStringValue = @"";
    }
}

- (IBAction) _selectFile: (id) sender {
    NSMutableArray *urls = [NSMutableArray array];

    if (_browser != nil) {
        NSArray *chosen = [_browser chosenURLs];
        if (chosen == nil)
            return; // the browser beeped, navigated or asked; stay up
        [urls addObjectsFromArray: chosen];
    } else {
        _NSFileSystemDataSource *dataSource = [_outlineView dataSource];
        BOOL filtered = [dataSource isKindOfClass: [_NSFileSystemDataSource class]];
        NSIndexSet *rows = [_outlineView selectedRowIndexes];

        for (NSUInteger row = [rows firstIndex]; row != NSNotFound;
             row = [rows indexGreaterThanIndex: row]) {
            NSURL *url = [_outlineView itemAtRow: row];
            if (![url isKindOfClass: [NSURL class]])
                continue;
            if (filtered && ![dataSource isEnabledItem: url])
                continue;
            [urls addObject: url];
        }
    }

    // Nothing selectable is selected: the panel stays up.
    if ([urls count] == 0) {
        NSBeep();
        return;
    }

    id delegate = [self delegate];
    if ([delegate respondsToSelector: @selector(panel:validateURL:error:)]) {
        for (NSURL *url in urls) {
            NSError *error = nil;
            if (![delegate panel: self validateURL: url error: &error]) {
                if (error != nil)
                    [self presentError: error];
                return;
            }
        }
    }

    [self _setSelectedURLs: urls];

    if (_completionHandler != nil && !_usesModalCompletionHandler) {
        [self orderOut: nil];
        [self _completeWithResult: (NSModalResponse) NSOKButton];
    } else {
        [NSApp stopModalWithCode: NSOKButton];
    }
}

- (IBAction) cancel: (id) sender {
    [self _cancel: sender];
}

- (void) selectText: (id) sender {
    id responder = [self firstResponder];
    if (responder != self && [responder respondsToSelector: @selector(selectText:)])
        [responder selectText: sender];
}

- (NSString *) nameFieldLabel {
    return _nameFieldLabel != nil ? _nameFieldLabel : @"Save As:";
}

- (void) setNameFieldLabel: (NSString *) label {
    label = [label copy];
    [_nameFieldLabel release];
    _nameFieldLabel = label;
}

- (BOOL) canSelectHiddenExtension {
    return _canSelectHiddenExtension;
}

- (void) setCanSelectHiddenExtension: (BOOL) flag {
    _canSelectHiddenExtension = flag;
}

- (BOOL) isExtensionHidden {
    return _extensionHidden;
}

- (void) setExtensionHidden: (BOOL) flag {
    _extensionHidden = flag;
}

- (BOOL) showsTagField {
    return _showsTagField;
}

- (void) setShowsTagField: (BOOL) flag {
    _showsTagField = flag;
}

- (IBAction) _cancel: (id) sender {
    if (_completionHandler != nil && !_usesModalCompletionHandler) {
        [self orderOut: nil];
        [self _completeWithResult: (NSModalResponse) NSCancelButton];
    } else {
        [NSApp stopModalWithCode: NSCancelButton];
    }
}

- (void) beginWithCompletionHandler: (void (^)(NSModalResponse result)) handler {
    if (_completionHandler != nil)
        [self _completeWithResult: (NSModalResponse) NSCancelButton];
    [_completionHandler release];
    _completionHandler = [handler copy];

    if ([[NSDisplay currentDisplay]
                implementsCustomPanelForClass: [self class]]) {
        // Custom panels only expose a synchronous runModal hook in Cocotron.
        _usesModalCompletionHandler = YES;
        NSInteger result = [self runModal];
        _usesModalCompletionHandler = NO;
        [self _completeWithResult: (NSModalResponse) result];
    } else {
        _usesModalCompletionHandler = NO;
        [self _prepareOutline];
        [self makeKeyAndOrderFront: nil];
    }
}

- (void) beginSheetModalForWindow: (NSWindow *) window
                completionHandler: (void (^)(NSModalResponse result)) handler
{
    // There is no sheet presentation here, the panel is shown on its own.
    [self beginWithCompletionHandler: handler];
}

- (void) _completeWithResult: (NSModalResponse) result {
    void (^handler)(NSModalResponse) = [_completionHandler copy];
    [_completionHandler release];
    _completionHandler = nil;
    // On macOS the panel runs in another process and its accessory view is
    // out of any window once the panel is done: Xcode's completion handler
    // invalidates the view controller of the accessory and asserts that its
    // view has no window. The next run puts it back.
    if (_accessoryView != nil && [_accessoryView window] == self)
        [_accessoryView removeFromSuperview];
    if (handler != nil) {
        handler(result);
        [handler release];
    }
}

- (void) close {
    BOOL shouldComplete =
            _completionHandler != nil && !_usesModalCompletionHandler;
    [super close];
    if (shouldComplete && _completionHandler != nil)
        [self _completeWithResult: (NSModalResponse) NSCancelButton];
}

- (NSInteger) runModalForDirectory: (NSString *) directory
                              file: (NSString *) file
{
    [self _setFilename: file];
    [self setDirectory: directory];

    return [self runModal];
}

- (NSInteger) runModal {
    NSInteger res;
    if ([[NSDisplay currentDisplay]
                implementsCustomPanelForClass: [self class]]) {
        res = [[NSDisplay currentDisplay] savePanel: self
                               runModalForDirectory: [self directory]
                                               file: [self filename]];
    } else {
        [self _prepareOutline];
        res = [NSApp runModalForWindow: self];
        [self close];
    }
    return res;
}

- (NSString *) directory {
    return _directory;
}

- (BOOL) treatsFilePackagesAsDirectories {
    return _treatsFilePackagesAsDirectories;
}

- (NSView *) accessoryView {
    return _accessoryView;
}

- (void) setTitle: (NSString *) title {
    title = [title copy];
    [_dialogTitle release];
    _dialogTitle = title;
    [super setTitle: title];
}

- (void) setDirectory: (NSString *) directory {
    directory = [directory copy];
    [_directory release];
    _directory = directory;

    // As on macOS, a panel that is showing goes to the new directory (the
    // browser sets the directory too when it navigates: nothing to do then).
    if (_browser != nil && [self isVisible] && [_directory length] > 0) {
        NSString *standardized = [[_directory stringByExpandingTildeInPath]
                stringByStandardizingPath];
        if (![[_browser directory] isEqualToString: standardized])
            [_browser goToDirectory: standardized];
    }
}

- (void) setDirectoryURL: (NSURL *) url {
    [self setDirectory: [url path]];
}

- (NSURL *) directoryURL {
    return [NSURL fileURLWithPath: [self directory]];
}

- (void) setRequiredFileType: (NSString *) type {
    @synchronized(self) {
        type = [type copy];
        [_requiredFileType release];
        _requiredFileType = type;
    }
}

- (NSString *) requiredFileType {
    id ret = nil;
    @synchronized(self) {
        ret = [[_requiredFileType copy] autorelease];
    }
    return ret;
}

- (void) setMessage: (NSString *) message; {
    @synchronized(self) {
        if (_message != message) {
            [_message release];
            _message = [message copy];
        }
    }
}

- (NSString *) message; {
    id ret = nil;
    @synchronized(self) {
        ret = [[_message copy] autorelease];
    }
    return ret;
}

- (void) setPrompt: (NSString *) prompt; {
    @synchronized(self) {
        if (_prompt != prompt) {
            [_prompt release];
            _prompt = [prompt copy];
        }
    }
}

- (NSString *) prompt; {
    id ret = nil;
    @synchronized(self) {
        ret = [[_prompt copy] autorelease];
    }
    return ret;
}

- (void) setTreatsFilePackagesAsDirectories: (BOOL) flag {
    _treatsFilePackagesAsDirectories = flag;
}

- (void) setAccessoryView: (NSView *) view {
    view = [view retain];
    [_accessoryView release];
    _accessoryView = view;
}

- (void) setCanCreateDirectories: (BOOL) value {
    _canCreateDirectories = value;
}

- (BOOL) canCreateDirectories {
    return _canCreateDirectories;
}

- (void) setAllowedFileTypes: (NSArray *) value {
    [_allowedFileTypes release];
    _allowedFileTypes = [value copy];
}

- (NSArray *) allowedFileTypes {
    return [[_allowedFileTypes copy] autorelease];
}

- (void) setAllowsOtherFileTypes: (BOOL) value {
    _allowsOtherFileTypes = value;
}

- (BOOL) allowsOtherFileTypes {
    return _allowsOtherFileTypes;
}

- (void) beginSheetForDirectory: (NSString *) path
                           file: (NSString *) name
                 modalForWindow: (NSWindow *) docWindow
                  modalDelegate: (id) modalDelegate
                 didEndSelector: (SEL) didEndSelector
                    contextInfo: (void *) contextInfo
{
    id inv = [NSInvocation
            invocationWithMethodSignature:
                    [self methodSignatureForSelector: @selector
                            (_background_beginSheetForDirectory:
                                                           file:modalForWindow
                                                               :modalDelegate
                                                               :didEndSelector
                                                               :contextInfo:)]];
    [inv setTarget: self];
    [inv setSelector: @selector
            (_background_beginSheetForDirectory:
                                           file:modalForWindow:modalDelegate
                                               :didEndSelector:contextInfo:)];
    [inv setArgument: &path atIndex: 2];
    [inv setArgument: &name atIndex: 3];
    [inv setArgument: &docWindow atIndex: 4];
    [inv setArgument: &modalDelegate atIndex: 5];
    [inv setArgument: &didEndSelector atIndex: 6];
    [inv setArgument: &contextInfo atIndex: 7];
    [inv retainArguments];
    [inv performSelectorInBackground: @selector(invoke) withObject: nil];
}

- (void) _selector_savePanelDidEnd: (NSSavePanel *) sheet
                        returnCode: (int) returnCode
                       contextInfo: (void *) contextInfo;
{
}

- (void) _background_beginSheetForDirectory: (NSString *) path
                                       file: (NSString *) name
                             modalForWindow: (NSWindow *) docWindow
                              modalDelegate: (id) modalDelegate
                             didEndSelector: (SEL) didEndSelector
                                contextInfo: (void *) contextInfo
{
    id pool = [NSAutoreleasePool new];
    int ret = [self runModalForDirectory: path file: name];

    id inv = [NSInvocation
            invocationWithMethodSignature:
                    [self methodSignatureForSelector: @selector
                            (_selector_savePanelDidEnd:
                                            returnCode:contextInfo:)]];

    [inv setTarget: modalDelegate];
    [inv setSelector: didEndSelector];
    [inv setArgument: &self atIndex: 2];
    [inv setArgument: &ret atIndex: 3];
    [inv setArgument: &contextInfo atIndex: 4];
    [inv retainArguments];

    [inv performSelectorOnMainThread: @selector(invoke)
                          withObject: nil
                       waitUntilDone: YES];
    [pool release];
}

@end
