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

#import <AppKit/NSHelpManager.h>
#import <AppKit/NSRaise.h>
#import <AppKit/NSWorkspace.h>
#import <Foundation/NSMapTable.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSURL.h>

@implementation NSHelpManager

static BOOL _isContextHelpModeActive = NO;

+ (NSHelpManager *) sharedHelpManager {
    static NSHelpManager *shared = nil;

    if (shared == nil)
        shared = [[NSHelpManager alloc] init];

    return shared;
}

+ (BOOL) isContextHelpModeActive {
    return _isContextHelpModeActive;
}

+ (void) setContextHelpModeActive: (BOOL) flag {
    _isContextHelpModeActive = flag;
}

- init {
    _objectToText = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks,
                                     NSObjectMapValueCallBacks, 0);
    return self;
}

- (void) dealloc {
    NSFreeMapTable(_objectToText);
    [super dealloc];
}

- (NSAttributedString *) contextHelpForObject: object {
    return NSMapGet(_objectToText, object);
}

- (void) setContextHelp: (NSAttributedString *) text forObject: object {
    NSMapInsert(_objectToText, object, text);
}

- (void) removeContextHelpForObject: object {
    NSMapRemove(_objectToText, object);
}

- (void) showContextHelpForObject: object locationHint: (NSPoint) hintPoint {
    (void) object;
    (void) hintPoint;
}

- (void) findString: (NSString *) string inBook: (NSString *) bookName {
    (void) string;
    (void) bookName;
}

- (void) openHelpAnchor: (NSString *) anchor inBook: (NSString *) bookName {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSDictionary *mainInfo = [mainBundle infoDictionary];
    NSString *helpFolderName = [mainInfo objectForKey: @"CFBundleHelpBookFolder"];
    NSString *helpFolder = (helpFolderName != nil)
                                   ? [mainBundle pathForResource: helpFolderName
                                                          ofType: nil]
                                   : nil;
    NSBundle *helpBundle = (helpFolder != nil)
                                   ? [NSBundle bundleWithPath: helpFolder]
                                   : nil;

    NSString *requestedBook = (bookName != nil)
                                      ? bookName
                                      : [mainInfo objectForKey:
                                                 @"CFBundleHelpBookName"];
    if ([requestedBook length] > 0 && helpFolder != nil) {
        NSString *bookPath = [mainBundle pathForResource: requestedBook
                                                 ofType: @"help"
                                            inDirectory: helpFolder];
        if (bookPath == nil)
            bookPath = [mainBundle pathForResource: requestedBook
                                            ofType: nil
                                       inDirectory: helpFolder];
        if (bookPath != nil)
            helpBundle = [NSBundle bundleWithPath: bookPath];
    }

    if (helpBundle == nil)
        return;

    NSString *tocName = [[helpBundle infoDictionary]
            objectForKey: @"CFBundleHelpTOCFile"];
    NSString *helpPath = (tocName != nil)
                                 ? [helpBundle pathForResource: tocName
                                                       ofType: nil]
                                 : nil;
    if (helpPath == nil)
        helpPath = [helpBundle pathForResource: @"index" ofType: @"html"];
    if (helpPath == nil)
        return;

    NSString *urlString = [[NSURL fileURLWithPath: helpPath] absoluteString];
    if ([anchor length] > 0) {
        NSString *escapedAnchor = [anchor
                stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        urlString = [urlString stringByAppendingFormat: @"#%@", escapedAnchor];
    }
    NSURL *helpURL = [NSURL URLWithString: urlString];
    if (helpURL != nil)
        [[NSWorkspace sharedWorkspace] openURL: helpURL];
}

@end
