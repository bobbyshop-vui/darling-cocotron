/* Copyright (c) 2006-2009 Christopher J. W. Lloyd <cjwl@objc.net>

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

#import <AppKit/NSAttributedString.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSFont.h>
#import <AppKit/NSParagraphStyle.h>
#import <AppKit/NSRaise.h>
#import <AppKit/NSRichTextReader.h>
#import <AppKit/NSRichTextWriter.h>
#import <AppKit/NSStringDrawer.h>
#import <AppKit/NSPasteboard.h>
#import <AppKit/NSTextAttachment.h>
#import <AppKit/NSTextList.h>
#import <AppKit/NSTextTable.h>
#import <AppKit/NSTextTableBlock.h>
#import <CoreFoundation/CFLocale.h>
#import <CoreFoundation/CFString.h>
#import <Foundation/NSFileWrapper.h>

NSAttributedStringKey NSFontAttributeName = @"NSFontAttributeName";
NSAttributedStringKey NSParagraphStyleAttributeName = @"NSParagraphStyleAttributeName";
NSAttributedStringKey NSForegroundColorAttributeName = @"NSForegroundColorAttributeName";
NSAttributedStringKey NSBackgroundColorAttributeName = @"NSBackgroundColorAttributeName";
NSAttributedStringKey NSUnderlineStyleAttributeName = @"NSUnderlineStyleAttributeName";
NSAttributedStringKey NSUnderlineColorAttributeName = @"NSUnderlineColorAttributeName";
NSAttributedStringKey NSAttachmentAttributeName = @"NSAttachmentAttributeName";
NSAttributedStringKey NSKernAttributeName = @"NSKernAttributeName";
NSAttributedStringKey NSLigatureAttributeName = @"NSLigatureAttributeName";
NSAttributedStringKey NSStrikethroughStyleAttributeName = @"NSStrikethroughStyleAttributeName";
NSAttributedStringKey NSStrikethroughColorAttributeName = @"NSStrikethroughColorAttributeName";
NSAttributedStringKey NSObliquenessAttributeName = @"NSObliquenessAttributeName";
NSAttributedStringKey NSStrokeWidthAttributeName = @"NSStrokeWidthAttributeName";
NSAttributedStringKey NSStrokeColorAttributeName = @"NSStrokeColorAttributeName";
NSAttributedStringKey NSBaselineOffsetAttributeName = @"NSBaselineOffsetAttributeName";
NSAttributedStringKey NSSuperscriptAttributeName = @"NSSuperscriptAttributeName";
NSAttributedStringKey NSLinkAttributeName = @"NSLinkAttributeName";
NSAttributedStringKey NSShadowAttributeName = @"NSShadowAttributeName";
NSAttributedStringKey NSExpansionAttributeName = @"NSExpansionAttributeName";
NSAttributedStringKey NSCursorAttributeName = @"NSCursorAttributeName";
NSAttributedStringKey NSMarkedClauseSegmentAttributeName = @"NSMarkedClauseSegment";
NSAttributedStringKey NSToolTipAttributeName = @"NSToolTipAttributeName";
NSAttributedStringKey NSSpellingStateAttributeName = @"NSSpellingStateAttributeName"; // temporary attribute

NSAttributedStringDocumentAttributeKey NSDocumentTypeDocumentAttribute = @"DocumentType";
NSAttributedStringDocumentAttributeKey NSConvertedDocumentAttribute = @"Converted";
NSAttributedStringDocumentAttributeKey NSFileTypeDocumentAttribute = @"UTI";
NSAttributedStringDocumentAttributeKey NSTitleDocumentAttribute = @"NSTitleDocumentAttribute";
NSAttributedStringDocumentAttributeKey NSCompanyDocumentAttribute = @"NSCompanyDocumentAttribute";
NSAttributedStringDocumentAttributeKey NSCopyrightDocumentAttribute = @"NSCopyrightDocumentAttribute";
NSAttributedStringDocumentAttributeKey NSSubjectDocumentAttribute = @"NSSubjectDocumentAttribute";
NSAttributedStringDocumentAttributeKey NSAuthorDocumentAttribute = @"NSAuthorDocumentAttribute";
NSAttributedStringDocumentAttributeKey NSKeywordsDocumentAttribute = @"NSKeywordsDocumentAttribute";
NSAttributedStringDocumentAttributeKey NSCommentDocumentAttribute = @"NSCommentDocumentAttribute";
NSAttributedStringDocumentAttributeKey NSEditorDocumentAttribute = @"NSEditorDocumentAttribute";
NSAttributedStringDocumentAttributeKey NSCreationTimeDocumentAttribute = @"NSCreationTimeDocumentAttribute";
NSAttributedStringKey NSModificationTimeDocumentAttribute = @"NSModificationTimeDocumentAttribute";
NSAttributedStringDocumentAttributeKey NSManagerDocumentAttribute = @"NSManagerDocumentAttribute";
NSAttributedStringDocumentAttributeKey NSCategoryDocumentAttribute = @"NSCategoryDocumentAttribute";
NSAttributedStringDocumentAttributeKey NSAppearanceDocumentAttribute = @"NSAppearanceDocumentAttribute";
NSAttributedStringDocumentAttributeKey NSCharacterEncodingDocumentAttribute = @"CharacterEncoding";
NSAttributedStringDocumentAttributeKey NSDefaultAttributesDocumentAttribute = @"DefaultAttributes";
NSAttributedStringDocumentAttributeKey NSPaperSizeDocumentAttribute = @"PaperSize";
NSAttributedStringDocumentAttributeKey NSLeftMarginDocumentAttribute = @"LeftMargin";
NSAttributedStringDocumentAttributeKey NSRightMarginDocumentAttribute = @"RightMargin";
NSAttributedStringDocumentAttributeKey NSTopMarginDocumentAttribute = @"TopMargin";
NSAttributedStringDocumentAttributeKey NSBottomMarginDocumentAttribute = @"BottomMargin";
NSAttributedStringDocumentAttributeKey NSViewSizeDocumentAttribute = @"ViewSize";
NSAttributedStringDocumentAttributeKey NSViewZoomDocumentAttribute = @"ViewZoom";
NSAttributedStringDocumentAttributeKey NSViewModeDocumentAttribute = @"ViewMode";
NSAttributedStringDocumentAttributeKey NSReadOnlyDocumentAttribute = @"ReadOnly";
NSAttributedStringDocumentAttributeKey NSBackgroundColorDocumentAttribute = @"BackgroundColor";
NSAttributedStringDocumentAttributeKey NSHyphenationFactorDocumentAttribute = @"HyphenationFactor";
NSAttributedStringDocumentAttributeKey NSDefaultTabIntervalDocumentAttribute = @"DefaultTabInterval";
NSAttributedStringDocumentAttributeKey NSTextLayoutSectionsAttribute = @"NSTextLayoutSectionsAttribute";
NSAttributedStringDocumentAttributeKey NSExcludedElementsDocumentAttribute = @"ExcludedElements";
NSAttributedStringDocumentAttributeKey NSTextEncodingNameDocumentAttribute = @"TextEncodingName";
NSAttributedStringDocumentAttributeKey NSPrefixSpacesDocumentAttribute = @"PrefixSpaces";
NSAttributedStringDocumentAttributeKey NSCocoaVersionDocumentAttribute = @"NSCocoaVersionDocumentAttribute";

NSAttributedStringDocumentReadingOptionKey NSDocumentTypeDocumentOption = @"DocumentType";
NSAttributedStringDocumentReadingOptionKey NSDefaultAttributesDocumentOption = @"DefaultAttributes";
NSAttributedStringDocumentReadingOptionKey NSCharacterEncodingDocumentOption = @"CharacterEncoding";
NSAttributedStringDocumentReadingOptionKey NSTextEncodingNameDocumentOption = @"TextEncodingName";
NSAttributedStringDocumentReadingOptionKey NSBaseURLDocumentOption = @"BaseURL";
NSAttributedStringDocumentReadingOptionKey NSTimeoutDocumentOption = @"Timeout";
NSAttributedStringDocumentReadingOptionKey NSWebPreferencesDocumentOption = @"WebPreferences";
NSAttributedStringDocumentReadingOptionKey NSWebResourceLoadDelegateDocumentOption = @"WebResourceLoadDelegate";
NSAttributedStringDocumentReadingOptionKey NSTextSizeMultiplierDocumentOption = @"TextSizeMultiplier";
NSAttributedStringDocumentReadingOptionKey NSFileTypeDocumentOption = @"UTI";

NSAttributedStringDocumentType NSPlainTextDocumentType = @"NSPlainText";
NSAttributedStringDocumentType NSRTFTextDocumentType = @"NSRTF";
NSAttributedStringDocumentType NSRTFDTextDocumentType = @"NSRTFD";
NSAttributedStringDocumentType NSHTMLTextDocumentType = @"NSHTML";
NSAttributedStringDocumentType NSMacSimpleTextDocumentType = @"NSMacSimpleText";
NSAttributedStringDocumentType NSDocFormatTextDocumentType = @"NSDocFormat";
NSAttributedStringDocumentType NSWordMLTextDocumentType = @"NSWordML";
NSAttributedStringDocumentType NSWebArchiveTextDocumentType = @"NSWebArchive";
NSAttributedStringDocumentType NSOfficeOpenXMLTextDocumentType = @"NSOfficeOpenXML";
NSAttributedStringDocumentType NSOpenDocumentTextDocumentType = @"NSOpenDocument";

NSTextLayoutSectionKey NSTextLayoutSectionOrientation = @"NSTextLayoutSectionOrientation";
NSTextLayoutSectionKey NSTextLayoutSectionRange = @"NSTextLayoutSectionRange";

NSAttributedStringKey NSCharacterShapeAttributeName = @"NSCharacterShape";
NSAttributedStringKey NSUsesScreenFontsDocumentAttribute = @"UsesScreenFonts";

const NSAttributedStringKey NSTextEffectAttributeName = @"NSTextEffect";
NSAttributedStringKey NSWritingDirectionAttributeName = @"NSWritingDirectionAttribute";

NSUInteger NSUnderlineStrikethroughMask = 0x4000;
NSUInteger NSUnderlineByWordMask = 0x8000;

static BOOL NSAttributedStringRangeIsValid(NSAttributedString *string,
                                           NSRange range)
{
    NSUInteger length = [string length];
    return range.location <= length && range.length <= length - range.location;
}

static BOOL NSAttributedStringRangeContainsAttachments(
        NSAttributedString *string, NSRange range)
{
    NSUInteger end = NSMaxRange(range);
    NSUInteger index = range.location;

    while (index < end) {
        NSRange effectiveRange = NSMakeRange(index, 1);
        id attachment = [string attribute: NSAttachmentAttributeName
                                  atIndex: index
                           effectiveRange: &effectiveRange];
        if (attachment != nil)
            return YES;

        NSUInteger nextIndex = NSMaxRange(effectiveRange);
        index = nextIndex > index && nextIndex <= end ? nextIndex : index + 1;
    }

    return NO;
}

static void NSAttributedStringSetImportError(NSError **error, NSInteger code,
                                             NSString *description)
{
    if (error != NULL)
        *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                     code: code
                                 userInfo: [NSDictionary dictionaryWithObject:
                                                    description
                                                                      forKey:
                                                    NSLocalizedDescriptionKey]];
}

typedef enum {
    NSAttributedStringParagraphBlock,
    NSAttributedStringParagraphList,
    NSAttributedStringParagraphTable
} NSAttributedStringParagraphItemKind;

static BOOL NSAttributedStringParagraphContainsItem(
        NSAttributedString *string, NSRange paragraph, id item,
        NSAttributedStringParagraphItemKind kind)
{
    NSParagraphStyle *style = [string attribute: NSParagraphStyleAttributeName
                                         atIndex: paragraph.location
                                  effectiveRange: NULL];
    if (style == nil)
        return NO;

    NSArray *items = kind == NSAttributedStringParagraphList
            ? [style textLists] : [style textBlocks];
    for (id candidate in items) {
        if (kind == NSAttributedStringParagraphTable) {
            if ([candidate isKindOfClass: [NSTextTableBlock class]] &&
                [(NSTextTableBlock *) candidate table] == item)
                return YES;
        } else if (candidate == item) {
            return YES;
        }
    }
    return NO;
}

static NSRange NSAttributedStringRangeOfParagraphItem(
        NSAttributedString *string, NSUInteger index, id item,
        NSAttributedStringParagraphItemKind kind)
{
    NSString *text = [string string];
    NSUInteger length = [text length];
    if (index >= length)
        return NSMakeRange(0, 0);

    NSRange paragraph = [text paragraphRangeForRange: NSMakeRange(index, 0)];
    if (paragraph.length == 0 ||
        !NSAttributedStringParagraphContainsItem(string, paragraph, item, kind))
        return NSMakeRange(0, 0);

    NSUInteger start = paragraph.location;
    NSUInteger end = NSMaxRange(paragraph);
    while (start > 0) {
        NSRange previous = [text paragraphRangeForRange:
                                    NSMakeRange(start - 1, 0)];
        if (previous.length == 0 || NSMaxRange(previous) > start ||
            !NSAttributedStringParagraphContainsItem(string, previous, item,
                                                     kind))
            break;
        start = previous.location;
    }
    while (end < length) {
        NSRange next = [text paragraphRangeForRange: NSMakeRange(end, 0)];
        if (next.length == 0 || next.location < end ||
            !NSAttributedStringParagraphContainsItem(string, next, item, kind))
            break;
        end = NSMaxRange(next);
    }
    return NSMakeRange(start, end - start);
}

static BOOL NSAttributedStringCharacterIsCJK(unichar character)
{
    return (character >= 0x2e80 && character <= 0x9fff) ||
           (character >= 0xac00 && character <= 0xd7af) ||
           (character >= 0xf900 && character <= 0xfaff) ||
           (character >= 0x3040 && character <= 0x30ff) ||
           (character >= 0x31f0 && character <= 0x31ff);
}

@implementation NSAttributedString (NSAttributedString_AppKit)

#pragma mark -
#pragma mark Creating an NSAttributedString

+ (NSAttributedString *) attributedStringWithAttachment:
        (NSTextAttachment *) attachment
{
    unichar unicode = NSAttachmentCharacter;
    NSString *string = [NSString stringWithCharacters: &unicode length: 1];
    NSDictionary *attributes =
            [NSDictionary dictionaryWithObject: attachment
                                        forKey: NSAttachmentAttributeName];

    return [[[self alloc] initWithString: string
                              attributes: attributes] autorelease];
}

- initWithData: (NSData *) data
                   options: (NSDictionary *) options
        documentAttributes: (NSDictionary **) attributes
                     error: (NSError **) error
{
    if (error != NULL)
        *error = nil;
    if (attributes != NULL)
        *attributes = nil;
    if (data == nil) {
        NSAttributedStringSetImportError(error, NSFileReadNoSuchFileError,
                                         @"No document data was supplied.");
        [self release];
        return nil;
    }

    NSString *docType = [options objectForKey: NSDocumentTypeDocumentOption];
    if (docType == nil)
        docType = [options objectForKey: NSDocumentTypeDocumentAttribute];
    if (docType == nil)
        docType = [options objectForKey: NSFileTypeDocumentOption];

    if (docType == nil) {
        char prefix[64] = {0};
        NSUInteger prefixLength = [data length] < sizeof(prefix) - 1
                ? [data length] : sizeof(prefix) - 1;
        if (prefixLength > 0)
            [data getBytes: prefix length: prefixLength];
        NSUInteger first = 0;
        while (first < prefixLength &&
               (prefix[first] == ' ' || prefix[first] == '\t' ||
                prefix[first] == '\r' || prefix[first] == '\n'))
            first++;
        const char *start = prefix + first;
        if (strncmp(start, "{\\rtf", 5) == 0)
            docType = NSRTFTextDocumentType;
        else if (strncasecmp(start, "<!doctype html", 14) == 0 ||
                 strncasecmp(start, "<head", 5) == 0 ||
                 strncasecmp(start, "<title", 6) == 0 ||
                 strncasecmp(start, "<html", 5) == 0 ||
                 strncmp(start, "<!--", 4) == 0 ||
                 strncasecmp(start, "<h1", 3) == 0)
            docType = NSHTMLTextDocumentType;
        else
            docType = NSPlainTextDocumentType;
    }

    if ([docType isEqual: NSRTFTextDocumentType] ||
        [docType isEqual: @"public.rtf"]) {
        NSDictionary *documentAttributes = nil;
        NSAttributedString *result = [self initWithRTF: data
                                   documentAttributes: &documentAttributes];
        if (result != nil && attributes != NULL)
            *attributes = documentAttributes;
        if (result == nil)
            NSAttributedStringSetImportError(error, NSFileReadCorruptFileError,
                                             @"The RTF document could not be read.");
        return result;
    }

    if ([docType isEqual: NSRTFDTextDocumentType] ||
        [docType isEqual: @"public.rtfd"]) {
        NSDictionary *documentAttributes = nil;
        NSAttributedString *result = [self initWithRTFD: data
                                    documentAttributes: &documentAttributes];
        if (result != nil && attributes != NULL)
            *attributes = documentAttributes;
        if (result == nil)
            NSAttributedStringSetImportError(error, NSFileReadCorruptFileError,
                                             @"The RTFD document could not be read.");
        return result;
    }

    if ([docType isEqual: NSHTMLTextDocumentType] ||
        [docType isEqual: @"public.html"]) {
        NSAttributedStringSetImportError(error, NSFileReadUnknownError,
                                         @"HTML import requires WebKit, which is unavailable.");
        [self release];
        return nil;
    }

    if (![docType isEqual: NSPlainTextDocumentType] &&
        ![docType isEqual: @"public.plain-text"] &&
        ![docType isEqual: NSMacSimpleTextDocumentType]) {
        NSAttributedStringSetImportError(error, NSFileReadUnknownError,
                [NSString stringWithFormat: @"Unsupported attributed string document type %@.", docType]);
        [self release];
        return nil;
    }

    NSNumber *encodingNumber = [options objectForKey:
            NSCharacterEncodingDocumentOption];
    NSStringEncoding encoding = encodingNumber != nil
            ? (NSStringEncoding) [encodingNumber unsignedIntegerValue]
            : NSUTF8StringEncoding;
    NSString *string = [[[NSString alloc] initWithData: data encoding: encoding]
            autorelease];
    if (string == nil && encodingNumber == nil) {
        string = [[[NSString alloc] initWithData: data
                                        encoding: NSUTF16StringEncoding]
                autorelease];
        if (string == nil)
            string = [[[NSString alloc] initWithData: data
                                            encoding: NSMacOSRomanStringEncoding]
                    autorelease];
    }
    if (string == nil) {
        NSAttributedStringSetImportError(error, NSFileReadCorruptFileError,
                                         @"The plain-text document encoding is invalid.");
        [self release];
        return nil;
    }

    NSDictionary *defaultAttributes = [options objectForKey:
            NSDefaultAttributesDocumentOption];
    NSAttributedString *result = [self initWithString: string
                                           attributes: defaultAttributes];
    if (attributes != NULL) {
        NSMutableDictionary *documentAttributes = [NSMutableDictionary
                dictionaryWithObject: docType
                              forKey: NSDocumentTypeDocumentAttribute];
        [documentAttributes setObject: [NSNumber numberWithUnsignedInteger: encoding]
                               forKey: NSCharacterEncodingDocumentAttribute];
        *attributes = documentAttributes;
    }
    return result;
}

- initWithDocFormat: (NSData *) werd
        documentAttributes: (NSDictionary **) attributes
{
    [self release];
    return nil;
}

- initWithHTML: (NSData *) html
                   baseURL: (NSURL *) url
        documentAttributes: (NSDictionary **) attributes
{
    return [self initWithHTML: html options: nil
            documentAttributes: attributes];
}

- initWithHTML: (NSData *) html
        documentAttributes: (NSDictionary **) attributes
{
    return [self initWithHTML: html baseURL: nil
            documentAttributes: attributes];
}

- initWithHTML: (NSData *) html
                   options: (NSDictionary *) options
        documentAttributes: (NSDictionary **) attributes
{
    NSMutableDictionary *htmlOptions = options != nil
            ? [[options mutableCopy] autorelease]
            : [NSMutableDictionary dictionary];
    [htmlOptions setObject: NSHTMLTextDocumentType
                    forKey: NSDocumentTypeDocumentOption];
    return [self initWithData: html options: htmlOptions
            documentAttributes: attributes error: NULL];
}

- initWithPath: (NSString *) path
        documentAttributes: (NSDictionary **) attributes
{
    NSAttributedString *string =
            [NSRichTextReader attributedStringWithContentsOfFile: path];
    if (string == nil) {
        [self release];
        return nil;
    }
    return [self initWithAttributedString: string];
}

- initWithRTF: (NSData *) rtf documentAttributes: (NSDictionary **) attributes {
    *attributes = [NSDictionary dictionaryWithObject: NSRTFTextDocumentType 
                                              forKey: NSDocumentTypeDocumentAttribute];
    NSAttributedString *string =
            [NSRichTextReader attributedStringWithData: rtf];
    if (string == nil) {
        [self release];
        return nil;
    }
    return [self initWithAttributedString: string];
}

- initWithRTFD: (NSData *) rtfd
        documentAttributes: (NSDictionary **) attributes
{
    if (rtfd == nil) {
        [self release];
        return nil;
    }
    NSFileWrapper *wrapper = [[[NSFileWrapper alloc]
            initWithSerializedRepresentation: rtfd] autorelease];
    return [self initWithRTFDFileWrapper: wrapper
                      documentAttributes: attributes];
}

- initWithRTFDFileWrapper: (NSFileWrapper *) wrapper
        documentAttributes: (NSDictionary **) attributes
{
    NSDictionary *children = [wrapper fileWrappers];
    NSFileWrapper *rtfFile = [children objectForKey: @"TXT.rtf"];
    if (![wrapper isDirectory] || ![rtfFile isRegularFile] ||
        [children count] != 1) {
        [self release];
        return nil;
    }

    NSAttributedString *string = [NSRichTextReader attributedStringWithData:
            [rtfFile regularFileContents]];
    if (string == nil) {
        [self release];
        return nil;
    }
    if (attributes != NULL)
        *attributes = [NSDictionary dictionaryWithObject: NSRTFDTextDocumentType
                                                  forKey: NSDocumentTypeDocumentAttribute];
    return [self initWithAttributedString: string];
}

- initWithURL: (NSURL *) url documentAttributes: (NSDictionary **) attributes {
    return [self initWithURL: url options: nil documentAttributes: attributes
                       error: NULL];
}

- initWithURL: (NSURL *) url
                   options: (NSDictionary *) options
        documentAttributes: (NSDictionary **) attributes
                     error: (NSError **) error
{
    NSData *data = [NSData dataWithContentsOfURL: url];
    return [self initWithData: data options: options documentAttributes: attributes error: error]; 
}

#pragma mark -
#pragma mark Retrieving Font Attribute Information

- (BOOL) containsAttachments {
    return NSAttributedStringRangeContainsAttachments(
            self, NSMakeRange(0, [self length]));
}

- (NSDictionary *) fontAttributesInRange: (NSRange) range {
    NSUInteger length = [self length];
    if (!NSAttributedStringRangeIsValid(self, range) || range.location >= length)
        return nil;

    NSMutableDictionary *attributes = [[self
            attributesAtIndex: range.location effectiveRange: NULL] mutableCopy];
    [attributes removeObjectForKey: NSParagraphStyleAttributeName];
    return [attributes autorelease];
}

- (NSDictionary *) rulerAttributesInRange: (NSRange) range {
    NSUInteger length = [self length];
    if (!NSAttributedStringRangeIsValid(self, range) || range.location >= length)
        return nil;

    id paragraphStyle = [self attribute: NSParagraphStyleAttributeName
                                atIndex: range.location
                         effectiveRange: NULL];
    if (paragraphStyle == nil)
        return [NSDictionary dictionary];
    return [NSDictionary dictionaryWithObject: paragraphStyle
                                       forKey: NSParagraphStyleAttributeName];
}

#pragma mark -
#pragma mark Calculating Linguistic Units

- (NSRange) doubleClickAtIndex: (NSUInteger) location {
    NSRange result = NSMakeRange(location, 0);
    NSString *string = [self string];
    unsigned length = [string length];

    if (length == 0) {
        return result;
    }

    unichar character = [string characterAtIndex: location];
    NSCharacterSet *set;
    BOOL expand = NO;

    set = [NSCharacterSet alphanumericCharacterSet];
    if ([set characterIsMember: character])
        expand = YES;
    else {
        set = [NSCharacterSet whitespaceCharacterSet];
        if ([set characterIsMember: character])
            expand = YES;
    }

    if (expand) {
        for (; result.location != 0; result.location--, result.length++) {
            if (![set characterIsMember:
                                [string characterAtIndex: result.location - 1]])
                break;
        }

        for (; NSMaxRange(result) < length; result.length++) {
            if (![set characterIsMember:
                                [string characterAtIndex: NSMaxRange(result)]])
                break;
        }
    } else if (location < length)
        result.length = 1;

    return result;
}

- (NSUInteger) lineBreakBeforeIndex: (NSUInteger) index
                        withinRange: (NSRange) range
{
    if (!NSAttributedStringRangeIsValid(self, range))
        [NSException raise: NSRangeException
                    format: @"lineBreakBeforeIndex:withinRange: received an "
                            @"invalid range %@ for a string of length %lu",
                            NSStringFromRange(range), (unsigned long) [self length]];

    NSUInteger end = NSMaxRange(range);
    if (index <= range.location)
        return range.location;
    if (index > end)
        index = end;

    NSString *string = [self string];
    NSCharacterSet *breakCharacters =
            [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for (NSUInteger candidate = index; candidate > range.location; --candidate) {
        unichar previous = [string characterAtIndex: candidate - 1];
        unichar current = candidate < end ? [string characterAtIndex: candidate]
                                          : 0;

        if (current == '\n' || current == '\r' || current == 0x2028 ||
            current == 0x2029)
            return candidate;

        if ([breakCharacters characterIsMember: previous] ||
            previous == '-' || previous == 0x2010 || previous == 0x2013 ||
            previous == '/' || previous == 0x200b || previous == 0x00ad)
            return candidate;

        if (candidate < end &&
            NSAttributedStringCharacterIsCJK(previous) &&
            NSAttributedStringCharacterIsCJK(current))
            return candidate;

        if (candidate < end && previous >= 0xd800 && previous <= 0xdbff &&
            current >= 0xdc00 && current <= 0xdfff)
            continue;
    }

    return range.location;
}

- (NSUInteger) lineBreakByHyphenatingBeforeIndex: (NSUInteger) index
                                     withinRange: (NSRange) range
{
    NSString *string = [self string];
    NSUInteger length = [string length];
    if (!NSAttributedStringRangeIsValid(self, range))
        [NSException raise: NSRangeException
                    format: @"lineBreakByHyphenatingBeforeIndex:withinRange: received an invalid range %@",
                            NSStringFromRange(range)];
    if (range.length == 0)
        return NSNotFound;
    if (index > NSMaxRange(range))
        index = NSMaxRange(range);
    if (index > length)
        index = length;
    if (index <= range.location)
        return NSNotFound;

    // Darling's CoreFoundation has no hyphenation dictionaries: use a simple
    // vowel/consonant rule that keeps at least two letters on each side of the break.
    NSCharacterSet *letters = [NSCharacterSet letterCharacterSet];
    NSCharacterSet *vowels = [NSCharacterSet characterSetWithCharactersInString: @"aeiouyAEIOUY"];
    NSUInteger position;

    for (position = index; position >= range.location + 2; position--) {
        unichar before = [string characterAtIndex: position - 1];
        unichar after = position < NSMaxRange(range) ? [string characterAtIndex: position] : 0;

        if (position + 2 > NSMaxRange(range))
            continue;
        if (![letters characterIsMember: before] || ![letters characterIsMember: after])
            continue;
        if ([vowels characterIsMember: before] && ![vowels characterIsMember: after] &&
            [letters characterIsMember: [string characterAtIndex: position - 2]] &&
            [letters characterIsMember: [string characterAtIndex: position + 1]])
            return position;
    }
    return NSNotFound;
}

/* as usual, the documentation says one thing and the system behaves
 * differently, this is the way i think it should work... (dwy 5/11/2003) */
- (NSUInteger) nextWordFromIndex: (NSUInteger) location
                         forward: (BOOL) forward
{
    NSCharacterSet *alpha = [NSCharacterSet alphanumericCharacterSet];
    NSString *string = [self string];
    int i = location, length = [self length];
    enum {
        STATE_INIT,  // skipping all whitespace
        STATE_ALNUM, // body of word
        STATE_SPACE  // word delimiter
    } state = STATE_ALNUM;

    if (location == 0 && forward == NO) {
        //        NSLog(@"sanity check: location == 0 && forward == NO");
        return location;
    }
    if (location >= [self length]) {
        //        NSLog(@"sanity check: location >= [self length] && forward ==
        //        YES");
        if (forward == YES)
            return [self length];
        else
            location = [self length] - 1;
    }

    if (forward) {
        if (![alpha characterIsMember: [string characterAtIndex: location]])
            state = STATE_INIT;

        for (; i < length; ++i) {
            unichar ch = [string characterAtIndex: i];
            switch (state) {
            case STATE_INIT:
                if (![alpha characterIsMember: ch])
                    state = STATE_ALNUM;
                break;
            case STATE_ALNUM:
                if ([alpha characterIsMember: ch])
                    state = STATE_SPACE;
                break;
            case STATE_SPACE:
                if (![alpha characterIsMember: ch])
                    return i;
            }
        }

        return length;
    } else {
        i--;
        if (![alpha characterIsMember: [string characterAtIndex: location]])
            state = STATE_INIT;

        for (; i >= 0; i--) {
            unichar ch = [string characterAtIndex: i];
            switch (state) {
            case STATE_INIT:
                if (![alpha characterIsMember: ch])
                    state = STATE_ALNUM;
                break;
            case STATE_ALNUM:
                if ([alpha characterIsMember: ch])
                    state = STATE_SPACE;
                break;
            case STATE_SPACE:
                if (![alpha characterIsMember: ch])
                    return i + 1;
            }
        }

        return 0;
    }

    return NSNotFound;
}

#pragma mark -
#pragma mark Calculating Ranges

- (NSInteger) itemNumberInTextList: (NSTextList *) list
                           atIndex: (NSUInteger) index
{
    NSRange textListRange = [self rangeOfTextList: list atIndex: index];
    if (textListRange.length == 0 || index < textListRange.location)
        return 0;

    NSString *string = [self string];
    NSRange paragraph = [string paragraphRangeForRange: NSMakeRange(index, 0)];
    NSInteger itemNumber = 0;
    NSUInteger cursor = textListRange.location;
    NSUInteger end = MIN(NSMaxRange(paragraph), NSMaxRange(textListRange));
    while (cursor < end) {
        NSRange candidate = [string paragraphRangeForRange:
                                     NSMakeRange(cursor, 0)];
        if (candidate.length == 0 || NSMaxRange(candidate) <= cursor)
            break;
        if (NSAttributedStringParagraphContainsItem(
                    self, candidate, list, NSAttributedStringParagraphList))
            itemNumber++;
        cursor = NSMaxRange(candidate);
    }
    return itemNumber;
}

- (NSRange) rangeOfTextBlock: (NSTextBlock *) block
                     atIndex: (NSUInteger) index
{
    return NSAttributedStringRangeOfParagraphItem(
            self, index, block, NSAttributedStringParagraphBlock);
}

- (NSRange) rangeOfTextList: (NSTextList *) list atIndex: (NSUInteger) index {
    return NSAttributedStringRangeOfParagraphItem(
            self, index, list, NSAttributedStringParagraphList);
}

- (NSRange) rangeOfTextTable: (NSTextTable *) table
                     atIndex: (NSUInteger) index
{
    return NSAttributedStringRangeOfParagraphItem(
            self, index, table, NSAttributedStringParagraphTable);
}

#pragma mark -
#pragma mark Generating Data

- (NSFileWrapper *) RTFDFileWrapperFromRange: (NSRange) range
                          documentAttributes: (NSDictionary *) attributes
{
    if (!NSAttributedStringRangeIsValid(self, range))
        [NSException raise: NSRangeException
                    format: @"RTFDFileWrapperFromRange:documentAttributes: "
                            @"received an invalid range %@ for a string of "
                            @"length %lu",
                            NSStringFromRange(range), (unsigned long) [self length]];

    // Cocotron's rich text writer does not yet encode the RTFD attachment
    // records and their file references. Returning a package without those
    // records would silently lose attachment data.
    if (NSAttributedStringRangeContainsAttachments(self, range))
        return nil;

    NSData *rtf = [NSRichTextWriter dataWithAttributedString: self range: range];
    if (rtf == nil)
        return nil;

    NSFileWrapper *textFile = [[[NSFileWrapper alloc]
            initRegularFileWithContents: rtf] autorelease];
    [textFile setPreferredFilename: @"TXT.rtf"];
    NSDictionary *children = [NSDictionary dictionaryWithObject: textFile
                                                         forKey: @"TXT.rtf"];
    return [[[NSFileWrapper alloc] initDirectoryWithFileWrappers: children]
            autorelease];
}

- (NSData *) RTFDFromRange: (NSRange) range
        documentAttributes: (NSDictionary *) attributes
{
    return [NSRichTextWriter dataWithAttributedString: self range: range];
}

- (NSData *) RTFFromRange: (NSRange) range
        documentAttributes: (NSDictionary *) attributes
{
    return [NSRichTextWriter dataWithAttributedString: self range: range];
}

- (NSData *) dataFromRange: (NSRange) range
        documentAttributes: (NSDictionary *) attributes
                     error: (NSError **) error
{
    if (error != NULL)
        *error = nil;
    if (!NSAttributedStringRangeIsValid(self, range))
        [NSException raise: NSRangeException
                    format: @"dataFromRange:documentAttributes:error: received "
                            @"an invalid range %@ for a string of length %lu",
                            NSStringFromRange(range), (unsigned long) [self length]];

    NSString *documentType = [attributes objectForKey:
            NSDocumentTypeDocumentAttribute];
    if (documentType == nil)
        documentType = NSRTFTextDocumentType;

    if ([documentType isEqual: NSRTFTextDocumentType])
        return [NSRichTextWriter dataWithAttributedString: self range: range];

    if ([documentType isEqual: NSRTFDTextDocumentType]) {
        NSFileWrapper *wrapper = [self RTFDFileWrapperFromRange: range
                                             documentAttributes: attributes];
        if (wrapper != nil)
            return [wrapper serializedRepresentation];
    } else if ([documentType isEqual: NSPlainTextDocumentType]) {
        NSString *text = [[self string] substringWithRange: range];
        id encodingValue = [attributes objectForKey:
                NSCharacterEncodingDocumentAttribute];
        NSStringEncoding encoding = encodingValue != nil
                ? (NSStringEncoding) [encodingValue unsignedIntegerValue]
                : NSUTF8StringEncoding;
        NSData *data = [text dataUsingEncoding: encoding];
        if (data != nil)
            return data;
    } else {
        if (error != NULL)
            *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                         code: NSFileWriteUnknownError
                                     userInfo: [NSDictionary dictionaryWithObject:
                                                     [NSString stringWithFormat:
                                                             @"Unsupported attributed string document type %@",
                                                             documentType]
                                                               forKey: NSLocalizedDescriptionKey]];
        return nil;
    }

    if (error != NULL)
        *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                     code: NSFileWriteUnknownError
                                 userInfo: [NSDictionary dictionaryWithObject:
                                                 @"The attributed string could not be represented in the requested format."
                                                           forKey: NSLocalizedDescriptionKey]];
    return nil;
}

- (NSData *) docFormatFromRange: (NSRange) range
             documentAttributes: (NSDictionary *) attributes
{
    return nil;
}

- (NSFileWrapper *) fileWrapperFromRange: (NSRange) range
                      documentAttributes: (NSDictionary *) attributes
                                   error: (NSError **) error
{
    if (error != NULL)
        *error = nil;
    if (!NSAttributedStringRangeIsValid(self, range))
        [NSException raise: NSRangeException
                    format: @"fileWrapperFromRange:documentAttributes:error: "
                            @"received an invalid range %@ for a string of "
                            @"length %lu",
                            NSStringFromRange(range), (unsigned long) [self length]];

    NSString *documentType = [attributes objectForKey:
            NSDocumentTypeDocumentAttribute];
    if ([documentType isEqual: NSRTFDTextDocumentType]) {
        NSFileWrapper *wrapper = [self RTFDFileWrapperFromRange: range
                                             documentAttributes: attributes];
        if (wrapper != nil)
            return wrapper;
    } else {
        NSData *data = [self dataFromRange: range
                        documentAttributes: attributes
                                     error: error];
        if (data != nil)
            return [[[NSFileWrapper alloc] initRegularFileWithContents: data]
                    autorelease];
    }

    if (error != NULL && *error == nil)
        *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                     code: NSFileWriteUnknownError
                                 userInfo: [NSDictionary dictionaryWithObject:
                                                 @"The attributed string could not be represented by a file wrapper."
                                                           forKey: NSLocalizedDescriptionKey]];
    return nil;
}

#pragma mark -
#pragma mark Drawing the string

- (void) drawAtPoint: (NSPoint) point {
    NSStringDrawer *drawer = [NSStringDrawer sharedStringDrawer];
    [drawer drawAttributedString: self atPoint: point inSize: NSZeroSize];
}

- (void) drawInRect: (NSRect) rect {
    NSStringDrawer *drawer = [NSStringDrawer sharedStringDrawer];
    [drawer drawAttributedString: self inRect: rect];
}

- (void) drawWithRect: (NSRect) rect options: (NSStringDrawingOptions) options {
    NSStringDrawer *drawer = [NSStringDrawer sharedStringDrawer];
    [drawer drawAttributedString: self inRect: rect];
}

- (NSSize) size {
    NSStringDrawer *drawer = [NSStringDrawer sharedStringDrawer];
    NSSize size = [drawer sizeOfAttributedString: self inSize: NSZeroSize];
    return size;
}

#pragma mark -
#pragma mark Getting the Bounding Rectangle of Rendered Strings

- (NSRect) boundingRectWithSize: (NSSize) size
                        options: (NSStringDrawingOptions) options
{
    NSSize measured = [[NSStringDrawer sharedStringDrawer]
            sizeOfAttributedString: self inSize: size];
    return NSMakeRect(0, 0, measured.width, measured.height);
}

#pragma mark -
#pragma mark Testing String Data Sources

+ (NSArray *) textTypes {
    return [NSArray arrayWithObjects: NSPasteboardTypeRTF,
                                     NSPasteboardTypeRTFD,
                                     NSPasteboardTypeString, nil];
}

+ (NSArray *) textUnfilteredTypes {
    return [self textTypes];
}

#pragma mark -
#pragma mark Deprecated in 10.5

+ (NSArray *) textFileTypes {
    return [self textTypes];
}

+ (NSArray *) textPasteboardTypes {
    return [self textTypes];
}

+ (NSArray *) textUnfilteredFileTypes {
    return [self textUnfilteredTypes];
}

+ (NSArray *) textUnfilteredPasteboardTypes {
    return [self textUnfilteredTypes];
}

@end

#pragma mark -
#pragma mark Private

NSFont *NSFontAttributeInDictionary(NSDictionary *dictionary) {
    NSFont *font = [dictionary objectForKey: NSFontAttributeName];

    if (font == nil)
        font = [NSFont fontWithName: @"Arial" size: 12.0];

    return font;
}

NSColor *NSForegroundColorAttributeInDictionary(NSDictionary *dictionary) {
    NSColor *color = [dictionary objectForKey: NSForegroundColorAttributeName];

    if (color == nil)
        color = [NSColor blackColor];

    return color;
}

NSParagraphStyle *
NSParagraphStyleAttributeInDictionary(NSDictionary *dictionary)
{
    NSParagraphStyle *style =
            [dictionary objectForKey: NSParagraphStyleAttributeName];

    if (style == nil)
        style = [NSParagraphStyle defaultParagraphStyle];

    return style;
}
