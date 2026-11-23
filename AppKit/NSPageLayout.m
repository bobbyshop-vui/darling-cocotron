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

// Original - Christopher Lloyd <cjwl@objc.net>
#import <AppKit/NSApplication.h>
#import <AppKit/NSDisplay.h>
#import <AppKit/NSPageLayout.h>
#import <AppKit/NSPrintInfo.h>
#import <AppKit/NSView.h>
#import <AppKit/NSViewController.h>
#import <AppKit/NSWindow.h>

@implementation NSPageLayout

+ (NSPageLayout *) pageLayout {
    return NSThreadSharedInstance(@"NSPageLayout");
}

- (void) dealloc {
    [_accessoryControllers release];
    [_printInfo release];
    [super dealloc];
}

- (NSPrintInfo *) printInfo {
    return _printInfo;
}

- (void) addAccessoryController: (NSViewController *) accessoryController {
    if (accessoryController == nil)
        return;
    if (_accessoryControllers == nil)
        _accessoryControllers = [[NSMutableArray alloc] init];
    [_accessoryControllers addObject: accessoryController];
}

- (NSView *) accessoryView {
    return [[_accessoryControllers firstObject] view];
}

- (void) setAccessoryView: (NSView *) accessoryView {
    // Replaces all accessory controllers added so far.
    [_accessoryControllers removeAllObjects];
    if (accessoryView == nil)
        return;
    NSViewController *controller =
            [[[NSViewController alloc] initWithNibName: nil bundle: nil]
                    autorelease];
    [controller setView: accessoryView];
    [self addAccessoryController: controller];
}

- (int) runModalWithPrintInfo: (NSPrintInfo *) printInfo {
    if (_printInfo != printInfo) {
        [_printInfo release];
        _printInfo = [printInfo retain];
    }
    return [[NSDisplay currentDisplay]
            runModalPageLayoutWithPrintInfo: printInfo];
}

- (int) runModal {
    return [self runModalWithPrintInfo: [NSPrintInfo sharedPrintInfo]];
}

@end
