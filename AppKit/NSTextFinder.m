#import <AppKit/NSTextFinder.h>

@implementation NSTextFinder

- (instancetype) init {
    self = [super init];
    if (self != nil) {
        _darlingIncrementalSearchingShouldDimContentView = YES;
    }
    return self;
}

- (instancetype) initWithCoder: (NSCoder *) decoder {
    self = [self init];
    if (self != nil && [decoder allowsKeyedCoding]) {
        if ([decoder containsValueForKey: @"NSIncrementalSearchingEnabled"])
            _darlingIncrementalSearchingEnabled =
                    [decoder decodeBoolForKey: @"NSIncrementalSearchingEnabled"];
        if ([decoder containsValueForKey: @"NSIncrementalSearchingShouldDimContentView"])
            _darlingIncrementalSearchingShouldDimContentView = [decoder
                    decodeBoolForKey: @"NSIncrementalSearchingShouldDimContentView"];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder {
    if ([coder allowsKeyedCoding]) {
        [coder encodeBool: _darlingIncrementalSearchingEnabled
                   forKey: @"NSIncrementalSearchingEnabled"];
        [coder encodeBool: _darlingIncrementalSearchingShouldDimContentView
                   forKey: @"NSIncrementalSearchingShouldDimContentView"];
    }
}

- (void) dealloc {
    [_darlingSearchString release];
    [super dealloc];
}

- (id<NSTextFinderClient>) client {
    return _darlingClient;
}

- (void) setClient: (id<NSTextFinderClient>) client {
    _darlingClient = client;
}

- (BOOL) isIncrementalSearchingEnabled {
    return _darlingIncrementalSearchingEnabled;
}

- (void) setIncrementalSearchingEnabled: (BOOL) flag {
    _darlingIncrementalSearchingEnabled = flag;
}

- (BOOL) incrementalSearchingShouldDimContentView {
    return _darlingIncrementalSearchingShouldDimContentView;
}

- (void) setIncrementalSearchingShouldDimContentView: (BOOL) flag {
    _darlingIncrementalSearchingShouldDimContentView = flag;
}

- (void) cancelFindIndicator {
    // No find indicator is ever shown, so there is nothing to cancel.
}

- (BOOL) validateAction: (NSTextFinderAction) op {
    id client = _darlingClient;

    if (client == nil)
        return NO;

    switch (op) {
    case NSTextFinderActionNextMatch:
    case NSTextFinderActionPreviousMatch:
        return [client respondsToSelector: @selector(string)] &&
               _darlingSearchString != nil && [_darlingSearchString length] > 0;
    case NSTextFinderActionSetSearchString:
        return [client respondsToSelector: @selector(string)] &&
               [client respondsToSelector: @selector(selectedRanges)];
    default:
        // No find bar or replace support is available.
        return NO;
    }
}

- (void) performAction: (NSTextFinderAction) op {
    id client = _darlingClient;

    if (![self validateAction: op])
        return;

    NSString *string = [client string];
    NSArray *ranges = [client respondsToSelector: @selector(selectedRanges)]
                              ? [client selectedRanges]
                              : nil;
    NSRange selection = [ranges count] > 0 ? [[ranges objectAtIndex: 0] rangeValue]
                                           : NSMakeRange(0, 0);

    if (op == NSTextFinderActionSetSearchString) {
        if (selection.length > 0 && NSMaxRange(selection) <= [string length]) {
            [_darlingSearchString release];
            _darlingSearchString = [[string substringWithRange: selection] copy];
        }
        return;
    }

    NSRange found;
    if (op == NSTextFinderActionNextMatch) {
        NSUInteger start = NSMaxRange(selection);
        NSRange tail = NSMakeRange(start, [string length] - start);
        found = [string rangeOfString: _darlingSearchString
                              options: NSCaseInsensitiveSearch
                                range: tail];
        if (found.location == NSNotFound)
            found = [string rangeOfString: _darlingSearchString
                                  options: NSCaseInsensitiveSearch];
    } else {
        NSRange head = NSMakeRange(0, selection.location);
        found = [string rangeOfString: _darlingSearchString
                              options: NSCaseInsensitiveSearch | NSBackwardsSearch
                                range: head];
        if (found.location == NSNotFound)
            found = [string rangeOfString: _darlingSearchString
                                  options: NSCaseInsensitiveSearch | NSBackwardsSearch];
    }

    if (found.location == NSNotFound)
        return;

    if ([client respondsToSelector: @selector(setSelectedRanges:)])
        [client setSelectedRanges: [NSArray arrayWithObject: [NSValue valueWithRange: found]]];
    if ([client respondsToSelector: @selector(scrollRangeToVisible:)])
        [client scrollRangeToVisible: found];
}

@end
