#import "_NSFileBrowser.h"
#import <AppKit/NSAlert.h>
#import <AppKit/NSAttributedString.h>
#import <AppKit/NSButton.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSFont.h>
#import <AppKit/NSGraphics.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSOpenPanel.h>
#import <AppKit/NSSavePanel.h>
#import <AppKit/NSScrollView.h>
#import <AppKit/NSTableColumn.h>
#import <AppKit/NSTableHeaderView.h>
#import <AppKit/NSTextField.h>
#import <AppKit/NSTextFieldCell.h>
#import <Foundation/Foundation.h>

@interface NSSavePanel (NSFileBrowserPrivate)
- (IBAction) _selectFile: (id) sender;
- (IBAction) _cancel: (id) sender;
@end

@interface _NSFileBrowserItem : NSObject {
  @public
    NSURL *url;
    NSString *name;
    NSDate *modified;
    BOOL isDirectory;
    BOOL isPackage;
}
@end

@implementation _NSFileBrowserItem
- (void) dealloc {
    [url release];
    [name release];
    [modified release];
    [super dealloc];
}
@end

static NSSet *NSFileBrowserPackageExtensions(void) {
    static NSSet *set = nil;
    if (set == nil)
        set = [[NSSet alloc] initWithObjects: @"app", @"bundle", @"framework",
                                              @"plugin", @"xpc", @"appex",
                                              @"kext", @"pkg", @"xcodeproj",
                                              @"xcworkspace", @"playground",
                                              @"xcarchive", @"dsym", @"xctest",
                                              @"prefpane", @"saver",
                                              @"qlgenerator", @"mdimporter",
                                              @"rtfd", @"xcframework",
                                              @"xcassets", @"xcdatamodeld",
                                              @"docarchive", nil];
    return set;
}

static NSString *NSFileBrowserKind(_NSFileBrowserItem *item) {
    NSString *ext = [[item->name pathExtension] lowercaseString];
    static NSDictionary *kinds = nil;
    if (kinds == nil)
        kinds = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"Xcode Project", @"xcodeproj",
                @"Xcode Workspace", @"xcworkspace",
                @"Playground", @"playground",
                @"Application", @"app",
                @"Framework", @"framework",
                @"Asset Catalog", @"xcassets",
                @"Swift Source", @"swift",
                @"Objective-C Source", @"m",
                @"Objective-C++ Source", @"mm",
                @"C Source", @"c",
                @"C++ Source", @"cpp",
                @"Header", @"h",
                @"Property List", @"plist",
                @"Interface Builder Storyboard", @"storyboard",
                @"Interface Builder Document", @"xib",
                @"Plain Text", @"txt",
                @"Markdown", @"md",
                @"JSON", @"json",
                @"Disk Image", @"dmg",
                @"Archive", @"zip",
                @"Archive", @"xip",
                nil];
    NSString *kind = [kinds objectForKey: ext];
    if (kind != nil)
        return kind;
    if (item->isPackage)
        return @"Package";
    if (item->isDirectory)
        return @"Folder";
    if ([ext length] > 0)
        return [NSString stringWithFormat: @"%@ File", [ext uppercaseString]];
    return @"Document";
}

static NSTextField *NSFileBrowserLabel(NSString *text) {
    NSTextField *label = [[NSTextField alloc] initWithFrame: NSMakeRect(0, 0, 10, 20)];
    [label setStringValue: text];
    [label setBezeled: NO];
    [label setDrawsBackground: NO];
    [label setEditable: NO];
    [label setSelectable: NO];
    return [label autorelease];
}

static NSButton *NSFileBrowserButton(NSString *title, id target, SEL action) {
    NSButton *button = [[NSButton alloc] initWithFrame: NSMakeRect(0, 0, 10, 28)];
    [button setTitle: title];
    [button setBezelStyle: NSRoundedBezelStyle];
    [button setTarget: target];
    [button setAction: action];
    return [button autorelease];
}

static NSTableColumn *NSFileBrowserColumn(NSString *identifier, NSString *title, CGFloat width) {
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier: identifier];
    [[column headerCell] setStringValue: title];
    [column setWidth: width];
    [column setEditable: NO];
    return [column autorelease];
}

@implementation _NSFileBrowser

- (instancetype) initWithPanel: (NSSavePanel *) panel {
    if ((self = [super init])) {
        _panel = panel;
        _places = [[NSMutableArray alloc] init];
        _items = [[NSMutableArray alloc] init];
        _history = [[NSMutableArray alloc] init];
        _directory = [NSHomeDirectory() copy];
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle: NSDateFormatterMediumStyle];
        [_dateFormatter setTimeStyle: NSDateFormatterShortStyle];
    }
    return self;
}

- (void) dealloc {
    [_places release];
    [_items release];
    [_history release];
    [_directory release];
    [_dateFormatter release];
    [super dealloc];
}

- (BOOL) _isOpenPanel {
    return [_panel isKindOfClass: [NSOpenPanel class]];
}

- (NSScrollView *) _scrollViewWithTable: (NSTableView *) table {
    NSScrollView *scroll = [[NSScrollView alloc] initWithFrame: NSMakeRect(0, 0, 100, 100)];
    [scroll setHasVerticalScroller: YES];
    [scroll setBorderType: NSBezelBorder];
    [scroll setDocumentView: table];
    return [scroll autorelease];
}

#pragma mark - Building

- (void) install {
    NSView *content = [_panel contentView];

    // Drop whatever the nib put there.
    for (NSView *view in [[[content subviews] copy] autorelease])
        [view removeFromSuperview];

    _nameLabel = NSFileBrowserLabel(@"Save As:");
    [_nameLabel setAlignment: NSRightTextAlignment];
    _nameField = [[[NSTextField alloc] initWithFrame: NSMakeRect(0, 0, 10, 24)] autorelease];
    [_nameField setTarget: self];
    [_nameField setAction: @selector(_nameEntered:)];
    _messageField = NSFileBrowserLabel(@"");

    _backButton = NSFileBrowserButton(@"<", self, @selector(_goBack:));
    _upButton = NSFileBrowserButton(@"Up", self, @selector(_goUp:));
    _pathField = [[[NSTextField alloc] initWithFrame: NSMakeRect(0, 0, 10, 24)] autorelease];
    [_pathField setTarget: self];
    [_pathField setAction: @selector(_pathEntered:)];
    _newFolderButton = NSFileBrowserButton(@"New Folder", self, @selector(_newFolder:));

    _sidebar = [[[NSTableView alloc] initWithFrame: NSMakeRect(0, 0, 160, 100)] autorelease];
    [_sidebar addTableColumn: NSFileBrowserColumn(@"place", @"Places", 154)];
    [_sidebar setHeaderView: nil];
    [_sidebar setRowHeight: 22];
    [_sidebar setDataSource: self];
    [_sidebar setDelegate: self];
    [_sidebar setTarget: self];
    [_sidebar setAction: @selector(_placeClicked:)];

    _files = [[[NSTableView alloc] initWithFrame: NSMakeRect(0, 0, 500, 100)] autorelease];
    [_files addTableColumn: NSFileBrowserColumn(@"name", @"Name", 300)];
    [_files addTableColumn: NSFileBrowserColumn(@"date", @"Date Modified", 170)];
    [_files addTableColumn: NSFileBrowserColumn(@"kind", @"Kind", 130)];
    [_files setRowHeight: 20];
    [_files setUsesAlternatingRowBackgroundColors: YES];
    [_files setDataSource: self];
    [_files setDelegate: self];
    [_files setTarget: self];
    [_files setDoubleAction: @selector(_openItem:)];

    _mainArea = [[[NSView alloc] initWithFrame: NSMakeRect(0, 0, 100, 100)] autorelease];
    [_mainArea addSubview: [self _scrollViewWithTable: _sidebar]];
    [_mainArea addSubview: [self _scrollViewWithTable: _files]];

    _accessoryHost = [[[NSView alloc] initWithFrame: NSMakeRect(0, 0, 10, 10)] autorelease];

    _hiddenButton = NSFileBrowserButton(@"Show hidden files", self, @selector(_toggleHidden:));
    [_hiddenButton setButtonType: NSSwitchButton];
    _cancelButton = NSFileBrowserButton(@"Cancel", _panel, @selector(_cancel:));
    [_cancelButton setKeyEquivalent: @"\e"];
    _okButton = NSFileBrowserButton(@"Open", _panel, @selector(_selectFile:));

    for (NSView *view in @[ _nameLabel, _nameField, _messageField, _backButton, _upButton,
                            _pathField, _newFolderButton, _mainArea, _accessoryHost,
                            _hiddenButton, _cancelButton, _okButton ])
        [content addSubview: view];

    [_panel setContentSize: NSMakeSize(820, 520)];
    [_panel setContentMinSize: NSMakeSize(560, 360)];
    [self _layout];
}

// Frames for the current panel size and configuration; autoresizing masks
// keep them right while the panel is resized.
- (void) _layout {
    NSRect bounds = [[_panel contentView] bounds];
    CGFloat width = bounds.size.width, height = bounds.size.height;
    CGFloat margin = 14, top = height - margin;
    BOOL saving = ![self _isOpenPanel];

    [_nameLabel setHidden: !saving];
    [_nameField setHidden: !saving];
    if (saving) {
        [_nameLabel setFrame: NSMakeRect(margin, top - 22, 80, 20)];
        [_nameField setFrame: NSMakeRect(margin + 86, top - 24, MIN(360, width - margin * 2 - 86), 24)];
        top -= 24 + 10;
    }
    [_nameLabel setAutoresizingMask: NSViewMinYMargin];
    [_nameField setAutoresizingMask: NSViewMinYMargin];

    BOOL hasMessage = [[_panel message] length] > 0;
    [_messageField setHidden: !hasMessage];
    if (hasMessage) {
        [_messageField setStringValue: [_panel message]];
        [_messageField setFrame: NSMakeRect(margin, top - 20, width - margin * 2, 20)];
        top -= 20 + 8;
    }
    [_messageField setAutoresizingMask: NSViewWidthSizable | NSViewMinYMargin];

    BOOL canCreate = [_panel canCreateDirectories];
    CGFloat newFolderWidth = canCreate ? 120 : 0;
    [_newFolderButton setHidden: !canCreate];
    [_backButton setFrame: NSMakeRect(margin, top - 28, 36, 28)];
    [_upButton setFrame: NSMakeRect(margin + 40, top - 28, 44, 28)];
    [_pathField setFrame: NSMakeRect(margin + 92, top - 26,
                                     width - margin * 2 - 92 - (canCreate ? newFolderWidth + 8 : 0), 24)];
    [_newFolderButton setFrame: NSMakeRect(width - margin - newFolderWidth, top - 28, newFolderWidth, 28)];
    [_backButton setAutoresizingMask: NSViewMinYMargin];
    [_upButton setAutoresizingMask: NSViewMinYMargin];
    [_pathField setAutoresizingMask: NSViewWidthSizable | NSViewMinYMargin];
    [_newFolderButton setAutoresizingMask: NSViewMinXMargin | NSViewMinYMargin];
    top -= 28 + 8;

    [_okButton setFrame: NSMakeRect(width - margin - 100, 12, 100, 30)];
    [_cancelButton setFrame: NSMakeRect(width - margin - 208, 12, 100, 30)];
    [_hiddenButton setFrame: NSMakeRect(margin, 16, 180, 22)];
    [_okButton setAutoresizingMask: NSViewMinXMargin | NSViewMaxYMargin];
    [_cancelButton setAutoresizingMask: NSViewMinXMargin | NSViewMaxYMargin];
    [_hiddenButton setAutoresizingMask: NSViewMaxXMargin | NSViewMaxYMargin];
    CGFloat bottom = 12 + 30 + 10;

    NSView *accessory = [_panel accessoryView];
    for (NSView *view in [[[_accessoryHost subviews] copy] autorelease])
        if (view != accessory)
            [view removeFromSuperview];
    [_accessoryHost setHidden: accessory == nil];
    if (accessory != nil) {
        NSSize size = [accessory frame].size;
        [_accessoryHost setFrame: NSMakeRect(margin, bottom, width - margin * 2, size.height)];
        if ([accessory superview] != _accessoryHost)
            [_accessoryHost addSubview: accessory];
        [accessory setFrameOrigin: NSMakePoint(MAX(0, floor((width - margin * 2 - size.width) / 2)), 0)];
        [accessory setAutoresizingMask: NSViewMinXMargin | NSViewMaxXMargin];
        bottom += size.height + 8;
    }
    [_accessoryHost setAutoresizingMask: NSViewWidthSizable | NSViewMaxYMargin];

    NSRect main = NSMakeRect(margin, bottom, width - margin * 2, MAX(80, top - bottom));
    [_mainArea setFrame: main];
    [_mainArea setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
    NSArray *scrolls = [_mainArea subviews];
    if ([scrolls count] == 2) {
        NSView *sidebarScroll = [scrolls objectAtIndex: 0];
        NSView *filesScroll = [scrolls objectAtIndex: 1];
        [sidebarScroll setFrame: NSMakeRect(0, 0, 170, main.size.height)];
        [sidebarScroll setAutoresizingMask: NSViewHeightSizable | NSViewMaxXMargin];
        [filesScroll setFrame: NSMakeRect(178, 0, main.size.width - 178, main.size.height)];
        [filesScroll setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
    }
}

#pragma mark - Running

- (void) _addPlace: (NSString *) name path: (NSString *) path {
    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath: path isDirectory: &isDirectory] || !isDirectory)
        return;
    [_places addObject: @{ @"name" : name, @"path" : path }];
}

- (void) _rebuildPlaces {
    NSString *home = NSHomeDirectory();
    [_places removeAllObjects];
    [self _addPlace: [home lastPathComponent] path: home];
    [self _addPlace: @"Desktop" path: [home stringByAppendingPathComponent: @"Desktop"]];
    [self _addPlace: @"Documents" path: [home stringByAppendingPathComponent: @"Documents"]];
    [self _addPlace: @"Downloads" path: [home stringByAppendingPathComponent: @"Downloads"]];
    [self _addPlace: @"Developer" path: [home stringByAppendingPathComponent: @"Developer"]];
    [self _addPlace: @"Applications" path: @"/Applications"];
    // Darling links the Linux home folder into the macOS one.
    [self _addPlace: @"Linux Home" path: [home stringByAppendingPathComponent: @"LinuxHome"]];
    [self _addPlace: @"Linux (/)" path: @"/Volumes/SystemRoot"];
    [self _addPlace: @"Computer" path: @"/"];
    [_sidebar reloadData];
}

- (void) prepareForRun {
    BOOL opening = [self _isOpenPanel];

    [_okButton setTitle: [[_panel prompt] length] > 0 ? [_panel prompt] : (opening ? @"Open" : @"Save")];
    if (!opening) {
        [_nameLabel setStringValue: [_panel nameFieldLabel]];
        [_nameField setStringValue: [_panel nameFieldStringValue] ?: @""];
    }
    [(NSButton *) _hiddenButton setState: [_panel showsHiddenFiles] ? NSOnState : NSOffState];
    [_files setAllowsMultipleSelection: opening && [(NSOpenPanel *) _panel allowsMultipleSelection]];
    [self _layout];
    [self _rebuildPlaces];

    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *directory = [_panel directory];
    NSString *file = [_panel filename];
    if ([file length] > 0 && ![file isAbsolutePath] && [directory length] > 0)
        file = [directory stringByAppendingPathComponent: file];
    if ([directory length] == 0 && [file isAbsolutePath])
        directory = [file stringByDeletingLastPathComponent];

    BOOL isDirectory = NO;
    if ([directory length] == 0 ||
        ![manager fileExistsAtPath: [directory stringByExpandingTildeInPath] isDirectory: &isDirectory] ||
        !isDirectory)
        directory = NSHomeDirectory();

    [_history removeAllObjects];
    [_directory release];
    _directory = nil;
    [self _showDirectory: [directory stringByExpandingTildeInPath] remember: NO];

    if (opening && [file isAbsolutePath])
        [self _selectPath: file];

    [_panel makeFirstResponder: opening ? (NSResponder *) _files : (NSResponder *) _nameField];
    if (!opening)
        [_nameField selectText: nil];
}

- (NSString *) directory {
    return _directory;
}

- (void) goToDirectory: (NSString *) path {
    [self _showDirectory: path remember: YES];
}

- (void) _showDirectory: (NSString *) path remember: (BOOL) remember {
    path = [[path stringByExpandingTildeInPath] stringByStandardizingPath];
    if ([path length] == 0)
        path = @"/";

    if (remember && _directory != nil && ![_directory isEqualToString: path])
        [_history addObject: _directory];

    path = [path copy];
    [_directory release];
    _directory = path;

    [_pathField setStringValue: _directory];
    [_backButton setEnabled: [_history count] > 0];
    [_upButton setEnabled: ![_directory isEqualToString: @"/"]];
    [_panel setDirectory: _directory];
    [self _reload];

    NSUInteger place = [_places indexOfObjectPassingTest: ^BOOL(NSDictionary *entry, NSUInteger index, BOOL *stop) {
        return [[entry objectForKey: @"path"] isEqualToString: _directory];
    }];
    if (place != NSNotFound)
        [_sidebar selectRowIndexes: [NSIndexSet indexSetWithIndex: place] byExtendingSelection: NO];
    else
        [_sidebar deselectAll: nil];

    id delegate = [_panel delegate];
    if ([delegate respondsToSelector: @selector(panel:didChangeToDirectoryURL:)])
        [delegate panel: _panel didChangeToDirectoryURL: [NSURL fileURLWithPath: _directory isDirectory: YES]];
}

- (void) _reload {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *names = [manager contentsOfDirectoryAtPath: _directory error: NULL];
    BOOL showsHidden = [_panel showsHiddenFiles];
    id delegate = [_panel delegate];
    BOOL asksShow = [delegate respondsToSelector: @selector(panel:shouldShowFilename:)];

    [_items removeAllObjects];
    for (NSString *name in [names sortedArrayUsingSelector: @selector(localizedCaseInsensitiveCompare:)]) {
        if (!showsHidden && [name hasPrefix: @"."])
            continue;
        NSString *path = [_directory stringByAppendingPathComponent: name];
        if (asksShow && ![delegate panel: _panel shouldShowFilename: path])
            continue;

        BOOL isDirectory = NO;
        if (![manager fileExistsAtPath: path isDirectory: &isDirectory])
            continue; // dangling link

        _NSFileBrowserItem *item = [[_NSFileBrowserItem alloc] init];
        item->name = [name copy];
        item->isDirectory = isDirectory;
        item->url = [[NSURL fileURLWithPath: path isDirectory: isDirectory] retain];
        item->isPackage = isDirectory && [self _isPackageName: name];
        item->modified = [[[manager attributesOfItemAtPath: path error: NULL]
                objectForKey: NSFileModificationDate] retain];
        [_items addObject: item];
        [item release];
    }
    [_files deselectAll: nil];
    [_files reloadData];
    if ([_items count] > 0)
        [_files scrollRowToVisible: 0];
}

- (BOOL) _isPackageName: (NSString *) name {
    NSString *extension = [[name pathExtension] lowercaseString];
    if ([extension length] == 0)
        return NO;
    if ([NSFileBrowserPackageExtensions() containsObject: extension])
        return YES;
    for (NSString *type in [_panel allowedFileTypes])
        if ([type isKindOfClass: [NSString class]] &&
            [type caseInsensitiveCompare: extension] == NSOrderedSame)
            return YES;
    return NO;
}

// Folders the browser walks into instead of choosing.
- (BOOL) _isNavigable: (_NSFileBrowserItem *) item {
    return item->isDirectory && (!item->isPackage || [_panel treatsFilePackagesAsDirectories]);
}

- (BOOL) _allowedTypesMatch: (NSString *) name {
    NSArray *types = [_panel allowedFileTypes];
    if ([types count] == 0)
        return YES;
    NSString *extension = [name pathExtension];
    for (NSString *type in types) {
        if (![type isKindOfClass: [NSString class]])
            continue;
        // Uniform type identifiers can't be resolved here; don't filter on them.
        if ([type rangeOfString: @"."].location != NSNotFound || [type isEqualToString: @"*"])
            return YES;
        if ([type caseInsensitiveCompare: extension] == NSOrderedSame)
            return YES;
    }
    return NO;
}

- (BOOL) _isEnabled: (_NSFileBrowserItem *) item {
    if (![self _isOpenPanel])
        return YES;

    NSOpenPanel *open = (NSOpenPanel *) _panel;
    BOOL enabled;
    if ([self _isNavigable: item])
        enabled = [open canChooseDirectories];
    else
        enabled = ([open canChooseFiles] || (item->isDirectory && [open canChooseDirectories])) &&
                  [self _allowedTypesMatch: item->name];

    id delegate = [_panel delegate];
    if (enabled && [delegate respondsToSelector: @selector(panel:shouldEnableURL:)])
        enabled = [delegate panel: _panel shouldEnableURL: item->url];
    return enabled;
}

- (void) _selectPath: (NSString *) path {
    NSString *name = [path lastPathComponent];
    for (NSUInteger index = 0; index < [_items count]; index++) {
        _NSFileBrowserItem *item = [_items objectAtIndex: index];
        if ([item->name isEqualToString: name]) {
            [_files selectRowIndexes: [NSIndexSet indexSetWithIndex: index] byExtendingSelection: NO];
            [_files scrollRowToVisible: index];
            return;
        }
    }
}

- (NSArray *) _selectedItems {
    NSMutableArray *items = [NSMutableArray array];
    NSIndexSet *rows = [_files selectedRowIndexes];
    for (NSUInteger row = [rows firstIndex]; row != NSNotFound; row = [rows indexGreaterThanIndex: row])
        if (row < [_items count])
            [items addObject: [_items objectAtIndex: row]];
    return items;
}

#pragma mark - Choosing

- (NSArray *) chosenURLs {
    if ([self _isOpenPanel])
        return [self _chosenOpenURLs];
    return [self _chosenSaveURLs];
}

- (NSArray *) _chosenOpenURLs {
    NSOpenPanel *open = (NSOpenPanel *) _panel;
    NSArray *selected = [self _selectedItems];
    NSMutableArray *urls = [NSMutableArray array];

    for (_NSFileBrowserItem *item in selected)
        if ([self _isEnabled: item])
            [urls addObject: item->url];

    if ([urls count] == 0) {
        // Like Finder: "Open" on a folder that can't be chosen walks into it.
        if ([selected count] == 1 && [self _isNavigable: [selected objectAtIndex: 0]]) {
            [self goToDirectory: [((_NSFileBrowserItem *) [selected objectAtIndex: 0])->url path]];
            return nil;
        }
        if ([selected count] == 0 && [open canChooseDirectories]) {
            NSURL *url = [NSURL fileURLWithPath: _directory isDirectory: YES];
            id delegate = [_panel delegate];
            if (![delegate respondsToSelector: @selector(panel:shouldEnableURL:)] ||
                [delegate panel: _panel shouldEnableURL: url])
                return @[ url ];
        }
        NSBeep();
        return nil;
    }

    if (![open allowsMultipleSelection] && [urls count] > 1)
        return @[ [urls objectAtIndex: 0] ];
    return urls;
}

- (NSString *) _nameWithExtension: (NSString *) name {
    NSString *extension = [name pathExtension];
    NSString *required = [_panel requiredFileType];
    NSMutableArray *types = [NSMutableArray array];
    for (NSString *type in [_panel allowedFileTypes])
        if ([type isKindOfClass: [NSString class]] && [type rangeOfString: @"."].location == NSNotFound &&
            ![type isEqualToString: @"*"] && [type length] > 0)
            [types addObject: type];
    if ([required length] > 0 && [required rangeOfString: @"."].location == NSNotFound && [types count] == 0)
        [types addObject: required];
    if ([types count] == 0)
        return name;

    for (NSString *type in types)
        if ([type caseInsensitiveCompare: extension] == NSOrderedSame)
            return name;
    if ([extension length] > 0 && [_panel allowsOtherFileTypes])
        return name;
    return [name stringByAppendingPathExtension: [types objectAtIndex: 0]];
}

- (NSArray *) _chosenSaveURLs {
    NSString *name = [[_nameField stringValue] stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([name length] == 0) {
        NSArray *selected = [self _selectedItems];
        if ([selected count] == 1 && [self _isNavigable: [selected objectAtIndex: 0]]) {
            [self goToDirectory: [((_NSFileBrowserItem *) [selected objectAtIndex: 0])->url path]];
            return nil;
        }
        NSBeep();
        return nil;
    }

    id delegate = [_panel delegate];
    if ([delegate respondsToSelector: @selector(panel:userEnteredFilename:confirmed:)]) {
        name = [delegate panel: _panel userEnteredFilename: name confirmed: YES];
        if ([name length] == 0)
            return nil;
    }

    NSString *path;
    if ([name hasPrefix: @"/"] || [name hasPrefix: @"~"])
        path = [[name stringByExpandingTildeInPath] stringByStandardizingPath];
    else
        path = [_directory stringByAppendingPathComponent: name];
    path = [[path stringByDeletingLastPathComponent]
            stringByAppendingPathComponent: [self _nameWithExtension: [path lastPathComponent]]];

    NSString *parent = [path stringByDeletingLastPathComponent];
    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath: parent isDirectory: &isDirectory] || !isDirectory) {
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText: [NSString stringWithFormat: @"The folder “%@” doesn’t exist.", parent]];
        [alert runModal];
        return nil;
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath: path]) {
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText: [NSString stringWithFormat: @"“%@” already exists. Do you want to replace it?",
                                                          [path lastPathComponent]]];
        [alert setInformativeText: @"A file or folder with the same name already exists in this location. Replacing it will overwrite its current contents."];
        [alert addButtonWithTitle: @"Replace"];
        [alert addButtonWithTitle: @"Cancel"];
        if ([alert runModal] != NSAlertFirstButtonReturn)
            return nil;
    }

    [_panel setNameFieldStringValue: [path lastPathComponent]];
    [_panel setDirectory: parent];
    return @[ [NSURL fileURLWithPath: path] ];
}

#pragma mark - Actions

- (void) _goBack: (id) sender {
    if ([_history count] == 0)
        return;
    NSString *previous = [[[_history lastObject] retain] autorelease];
    [_history removeLastObject];
    [self _showDirectory: previous remember: NO];
}

- (void) _goUp: (id) sender {
    if ([_directory isEqualToString: @"/"])
        return;
    NSString *child = [[_directory retain] autorelease];
    [self goToDirectory: [_directory stringByDeletingLastPathComponent]];
    [self _selectPath: child];
}

- (void) _pathEntered: (id) sender {
    NSString *path = [[_pathField stringValue] stringByExpandingTildeInPath];
    if (![path isAbsolutePath])
        path = [_directory stringByAppendingPathComponent: path];
    path = [path stringByStandardizingPath];

    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath: path isDirectory: &isDirectory]) {
        NSBeep();
        [_pathField setStringValue: _directory];
        return;
    }
    if (isDirectory) {
        [self goToDirectory: path];
    } else {
        [self goToDirectory: [path stringByDeletingLastPathComponent]];
        [self _selectPath: path];
    }
}

- (void) _nameEntered: (id) sender {
    [_panel _selectFile: sender];
}

- (void) _placeClicked: (id) sender {
    NSInteger row = [_sidebar selectedRow];
    if (row < 0 || row >= (NSInteger) [_places count])
        return;
    [self goToDirectory: [[_places objectAtIndex: row] objectForKey: @"path"]];
}

- (void) _openItem: (id) sender {
    NSInteger row = [_files clickedRow];
    if (row < 0)
        row = [_files selectedRow];
    if (row < 0 || row >= (NSInteger) [_items count])
        return;
    _NSFileBrowserItem *item = [_items objectAtIndex: row];
    if ([self _isNavigable: item]) {
        [self goToDirectory: [item->url path]];
        return;
    }
    if ([self _isOpenPanel] && ![self _isEnabled: item]) {
        NSBeep();
        return;
    }
    if (![self _isOpenPanel])
        [_nameField setStringValue: item->name];
    [_files selectRowIndexes: [NSIndexSet indexSetWithIndex: row] byExtendingSelection: NO];
    [_panel _selectFile: sender];
}

- (void) _toggleHidden: (id) sender {
    [_panel setShowsHiddenFiles: [(NSButton *) _hiddenButton state] == NSOnState];
    [self _reload];
}

- (void) _newFolder: (id) sender {
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText: @"New Folder"];
    [alert setInformativeText: [NSString stringWithFormat: @"Create a folder in “%@”:", [_directory lastPathComponent]]];
    [alert addButtonWithTitle: @"Create"];
    [alert addButtonWithTitle: @"Cancel"];
    NSTextField *field = [[[NSTextField alloc] initWithFrame: NSMakeRect(0, 0, 280, 24)] autorelease];
    [field setStringValue: @"untitled folder"];
    [alert setAccessoryView: field];
    if ([alert runModal] != NSAlertFirstButtonReturn)
        return;

    NSString *name = [[field stringValue] stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([name length] == 0 || [name rangeOfString: @"/"].location != NSNotFound) {
        NSBeep();
        return;
    }

    NSString *path = [_directory stringByAppendingPathComponent: name];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath: path
                                   withIntermediateDirectories: NO
                                                    attributes: nil
                                                         error: &error]) {
        NSAlert *failure = [[[NSAlert alloc] init] autorelease];
        [failure setMessageText: [NSString stringWithFormat: @"The folder “%@” couldn’t be created.", name]];
        if ([error localizedDescription] != nil)
            [failure setInformativeText: [error localizedDescription]];
        [failure runModal];
        return;
    }
    [self _reload];
    [self _selectPath: path];
}

#pragma mark - Table data

- (NSInteger) numberOfRowsInTableView: (NSTableView *) tableView {
    return tableView == _sidebar ? (NSInteger) [_places count] : (NSInteger) [_items count];
}

- (id) tableView: (NSTableView *) tableView
        objectValueForTableColumn: (NSTableColumn *) column
                              row: (NSInteger) row
{
    if (tableView == _sidebar) {
        if (row < 0 || row >= (NSInteger) [_places count])
            return nil;
        return [[_places objectAtIndex: row] objectForKey: @"name"];
    }

    if (row < 0 || row >= (NSInteger) [_items count])
        return nil;
    _NSFileBrowserItem *item = [_items objectAtIndex: row];
    NSString *identifier = [column identifier];
    NSString *text;

    if ([identifier isEqualToString: @"date"])
        text = item->modified ? [_dateFormatter stringFromDate: item->modified] : @"--";
    else if ([identifier isEqualToString: @"kind"])
        text = NSFileBrowserKind(item);
    else
        text = item->name;

    if ([self _isNavigable: item] || [self _isEnabled: item])
        return text;

    NSDictionary *attributes = [NSDictionary dictionaryWithObject: [NSColor disabledControlTextColor]
                                                           forKey: NSForegroundColorAttributeName];
    return [[[NSAttributedString alloc] initWithString: text attributes: attributes] autorelease];
}

- (void) tableViewSelectionDidChange: (NSNotification *) note {
    if ([note object] != _files)
        return;

    NSArray *selected = [self _selectedItems];
    if (![self _isOpenPanel] && [selected count] == 1) {
        _NSFileBrowserItem *item = [selected objectAtIndex: 0];
        if (![self _isNavigable: item])
            [_nameField setStringValue: item->name];
    }

    id delegate = [_panel delegate];
    if ([delegate respondsToSelector: @selector(panelSelectionDidChange:)])
        [delegate panelSelectionDidChange: _panel];
}

@end
