#import <AppKit/NSAttributedString.h>
#import <AppKit/NSLayoutManager.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSTextContainer.h>
#import <AppKit/NSTextStorage.h>
#import <AppKit/NSTextView.h>
#import <objc/runtime.h>

static char NSTextViewXcodeMarkedRangeKey;

static NSRange NSTextViewXcodeClampedRange(NSRange range, NSUInteger length) {
    if (range.location == NSNotFound || range.location > length)
        return NSMakeRange(NSNotFound, 0);

    if (range.length > length - range.location)
        range.length = length - range.location;
    return range;
}

@interface NSTextView (XcodeProtocolsPrivate)
- (NSRect) _viewRectForCharacterRange: (NSRange) range;
- (void) _replaceCharactersInRange: (NSRange) range
                         withString: (id) string
            allowsTypingCoalescing: (BOOL) allowsTypingCoalescing;
@end

@implementation NSTextView (XcodeProtocols)

- (NSAttributedString *) attributedSubstringForProposedRange: (NSRange) range
                                                  actualRange: (NSRangePointer) actualRange
{
    NSUInteger length = [[self textStorage] length];
    range = NSTextViewXcodeClampedRange(range, length);
    if (range.location == NSNotFound) {
        if (actualRange != NULL)
            *actualRange = range;
        return nil;
    }

    if (actualRange != NULL)
        *actualRange = range;
    return [[self textStorage] attributedSubstringFromRange: range];
}

- (NSRect) firstRectForCharacterRange: (NSRange) range
                          actualRange: (NSRangePointer) actualRange
{
    NSRange adjustedRange = NSTextViewXcodeClampedRange(
            range, [[self textStorage] length]);
    if (adjustedRange.location == NSNotFound) {
        if (actualRange != NULL)
            *actualRange = adjustedRange;
        return NSZeroRect;
    }

    NSRange layoutRange = adjustedRange;
    if (adjustedRange.length > 0) {
        [[self layoutManager] glyphRangeForCharacterRange: adjustedRange
                                     actualCharacterRange: &layoutRange];
        layoutRange = NSTextViewXcodeClampedRange(
                layoutRange, [[self textStorage] length]);
        if (layoutRange.location == NSNotFound)
            layoutRange = adjustedRange;
    }
    if (actualRange != NULL)
        *actualRange = layoutRange;

    NSRect rect = [self _viewRectForCharacterRange: layoutRange];
    NSWindow *window = [self window];
    if (window == nil)
        return NSZeroRect;

    rect = [self convertRect: rect toView: nil];
    return [window convertRectToScreen: rect];
}

- (BOOL) hasMarkedText {
    NSValue *value = objc_getAssociatedObject(self, &NSTextViewXcodeMarkedRangeKey);
    return value != nil && [value rangeValue].location != NSNotFound;
}

- (void) insertText: (id) string replacementRange: (NSRange) replacementRange {
    if (string == nil)
        return;

    NSUInteger documentLength = [[self textStorage] length];
    NSRange range = replacementRange;
    if (range.location == NSNotFound) {
        range = [self hasMarkedText] ? [self markedRange] : [self selectedRange];
    }
    if (range.location == NSNotFound)
        range = [self selectedRange];
    if (range.location == NSNotFound || range.location > documentLength)
        range = NSMakeRange(documentLength, 0);
    else if (range.length > documentLength - range.location)
        range.length = documentLength - range.location;

    NSString *replacementString = string;
    if ([string isKindOfClass: [NSAttributedString class]])
        replacementString = [string string];
    if (![self shouldChangeTextInRange: range replacementString: replacementString])
        return;

    if ([self hasMarkedText])
        [self unmarkText];
    [self _replaceCharactersInRange: range
                         withString: string
            allowsTypingCoalescing: NO];
    [self didChangeText];
    [self scrollRangeToVisible: [self selectedRange]];
}

- (NSRange) markedRange {
    NSValue *value = objc_getAssociatedObject(self, &NSTextViewXcodeMarkedRangeKey);
    if (value == nil)
        return NSMakeRange(NSNotFound, 0);

    NSRange range = NSTextViewXcodeClampedRange(
            [value rangeValue], [[self textStorage] length]);
    return range.location == NSNotFound ? NSMakeRange(NSNotFound, 0) : range;
}

- (void) setMarkedText: (id) string
         selectedRange: (NSRange) selectedRange
       replacementRange: (NSRange) replacementRange
{
    if (string == nil)
        return;

    NSUInteger documentLength = [[self textStorage] length];
    NSRange range = replacementRange;
    if (range.location == NSNotFound)
        range = [self hasMarkedText] ? [self markedRange] : [self selectedRange];
    if (range.location == NSNotFound || range.location > documentLength)
        range = NSMakeRange(documentLength, 0);
    else if (range.length > documentLength - range.location)
        range.length = documentLength - range.location;

    NSString *replacementString = string;
    if ([string isKindOfClass: [NSAttributedString class]])
        replacementString = [string string];
    if (![self shouldChangeTextInRange: range replacementString: replacementString])
        return;

    if ([self hasMarkedText])
        [self unmarkText];
    [self _replaceCharactersInRange: range
                         withString: string
            allowsTypingCoalescing: NO];
    [self didChangeText];

    NSUInteger markedLength = [string length];
    NSRange marked = NSMakeRange(range.location, markedLength);
    objc_setAssociatedObject(self, &NSTextViewXcodeMarkedRangeKey,
                             [NSValue valueWithRange: marked],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (markedLength > 0) {
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:
                [NSNumber numberWithInteger: NSUnderlineStyleSingle]
                                       forKey: NSUnderlineStyleAttributeName];
        [[self layoutManager] addTemporaryAttributes: attributes
                                  forCharacterRange: marked];
    }

    if (selectedRange.location == NSNotFound || selectedRange.location > markedLength)
        selectedRange = NSMakeRange(markedLength, 0);
    else if (selectedRange.length > markedLength - selectedRange.location)
        selectedRange.length = markedLength - selectedRange.location;
    [self setSelectedRange: NSMakeRange(marked.location + selectedRange.location,
                                        selectedRange.length)];
    [self scrollRangeToVisible: [self selectedRange]];
}

- (void) unmarkText {
    NSRange range = [self markedRange];
    if (range.location != NSNotFound && range.length > 0) {
        [[self layoutManager] removeTemporaryAttribute: NSUnderlineStyleAttributeName
                                    forCharacterRange: range];
    }
    objc_setAssociatedObject(self, &NSTextViewXcodeMarkedRangeKey, nil,
                             OBJC_ASSOCIATION_ASSIGN);
}

- (NSArray *) validAttributesForMarkedText {
    return [NSArray arrayWithObjects: NSFontAttributeName,
            NSForegroundColorAttributeName, NSBackgroundColorAttributeName,
            NSUnderlineStyleAttributeName, NSUnderlineColorAttributeName,
            NSMarkedClauseSegmentAttributeName, nil];
}

- (NSAttributedString *) attributedSubstringFromRange: (NSRange) range {
    NSUInteger length = [[self textStorage] length];
    range = NSTextViewXcodeClampedRange(range, length);
    if (range.location == NSNotFound)
        return nil;
    return [[self textStorage] attributedSubstringFromRange: range];
}

@end
