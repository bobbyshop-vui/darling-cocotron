#import <AppKit/NSApplication.h>
#import <AppKit/NSInputManager.h>
#import <AppKit/NSWindow.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSAttributedString.h>

static id NSInputManagerXcodeFirstResponder(void) {
    NSWindow *window = [[NSApplication sharedApplication] keyWindow];
    return [window firstResponder];
}

@implementation NSInputManager (XcodeProtocols)

- (NSAttributedString *) attributedSubstringFromRange: (NSRange) range {
    id client = NSInputManagerXcodeFirstResponder();
    if ([client respondsToSelector: @selector(attributedSubstringFromRange:)])
        return [client attributedSubstringFromRange: range];
    return nil;
}

- (NSUInteger) characterIndexForPoint: (NSPoint) point {
    id client = NSInputManagerXcodeFirstResponder();
    if ([client respondsToSelector: @selector(characterIndexForPoint:)])
        return [client characterIndexForPoint: point];
    return NSNotFound;
}

- (void) doCommandBySelector: (SEL) selector {
    id client = NSInputManagerXcodeFirstResponder();
    if ([client respondsToSelector: @selector(doCommandBySelector:)])
        [client doCommandBySelector: selector];
}

- (BOOL) hasMarkedText {
    id client = NSInputManagerXcodeFirstResponder();
    if ([client respondsToSelector: @selector(hasMarkedText)])
        return [client hasMarkedText];
    return NO;
}

- (void) insertText: (id) string {
    id client = NSInputManagerXcodeFirstResponder();
    if ([client respondsToSelector: @selector(insertText:)])
        [client insertText: string];
}

- (NSRange) markedRange {
    id client = NSInputManagerXcodeFirstResponder();
    if (![self hasMarkedText] ||
        ![client respondsToSelector: @selector(markedRange)])
        return NSMakeRange(NSNotFound, 0);
    return [client markedRange];
}

- (NSRange) selectedRange {
    id client = NSInputManagerXcodeFirstResponder();
    if ([client respondsToSelector: @selector(selectedRange)])
        return [client selectedRange];
    return NSMakeRange(NSNotFound, 0);
}

- (void) unmarkText {
    id client = NSInputManagerXcodeFirstResponder();
    if ([client respondsToSelector: @selector(unmarkText)])
        [client unmarkText];
}

- (NSArray *) validAttributesForMarkedText {
    id client = NSInputManagerXcodeFirstResponder();
    if ([client respondsToSelector: @selector(validAttributesForMarkedText)])
        return [client validAttributesForMarkedText];
    return [NSArray array];
}

@end
