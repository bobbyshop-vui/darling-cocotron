#import <AppKit/NSDisplay.h>
#import <AppKit/NSPanel.h>
#import <AppKit/NSPrintInfo.h>
#import <AppKit/NSPrintOperation.h>
#import <AppKit/NSPrintPanel.h>
#import <AppKit/NSViewController.h>
#import <AppKit/NSView.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSArray.h>

@implementation NSPrintPanel

+ (NSPrintPanel *) printPanel {
    return [[[self alloc] init] autorelease];
}

- (void) dealloc {
    [_attributes release];
    [_accessoryControllers release];
    [_defaultButtonTitle release];
    [_accessoryView release];
    [super dealloc];
}

- (void) setAccessoryView: (NSView *) view {
    view = [view retain];
    [_accessoryView release];
    _accessoryView = view;
}

- (NSView *) accessoryView {
    if (_accessoryView != nil)
        return _accessoryView;
    return [[_accessoryControllers firstObject] view];
}

- (void) addAccessoryController: (NSViewController *) accessoryController {
    if (accessoryController == nil)
        return;
    if (_accessoryControllers == nil)
        _accessoryControllers = [[NSMutableArray alloc] init];
    [_accessoryControllers addObject: accessoryController];
}

- (NSPrintInfo *) printInfo {
    return [[NSPrintOperation currentOperation] printInfo];
}

- (void) setDefaultButtonTitle: (NSString *) title {
    title = [title copy];
    [_defaultButtonTitle release];
    _defaultButtonTitle = title;
}

- (NSString *) defaultButtonTitle {
    return _defaultButtonTitle;
}

- (void) setOptions: (NSPrintPanelOptions) options {
    _options = options;
}

- (NSPrintPanelOptions) options {
    return _options;
}

- (int) runModal {
    int result;

    [self updateFromPrintInfo];
    result = [[NSDisplay currentDisplay]
            runModalPrintPanelWithPrintInfoDictionary: _attributes];
    if (result == NSOKButton)
        [self finalWritePrintInfo];

    return result;
}

- (void) updateFromPrintInfo {
    NSDictionary *source =
            [[[NSPrintOperation currentOperation] printInfo] dictionary];

    [_attributes release];
    _attributes = [source mutableCopy];
}

- (void) finalWritePrintInfo {
    NSMutableDictionary *destination =
            [[[NSPrintOperation currentOperation] printInfo] dictionary];

    [destination addEntriesFromDictionary: _attributes];
}

@end

NSString *const NSPrintPanelAccessorySummaryItemNameKey =
        @"NSPrintPanelAccessorySummaryItemName";
NSString *const NSPrintPanelAccessorySummaryItemDescriptionKey =
        @"NSPrintPanelAccessorySummaryItemDescription";
