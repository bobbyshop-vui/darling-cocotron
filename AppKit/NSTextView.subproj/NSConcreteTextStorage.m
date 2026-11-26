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

#import "NSConcreteTextStorage.h"
#import <Foundation/NSKeyedArchiver.h>

@implementation NSConcreteTextStorage

static inline void setAttributes(NSConcreteTextStorage *self,
                                 NSDictionary *attributes, NSRange range);

// Every initializer sets the storage up itself instead of calling another
// initializer on self: subclasses override them (Xcode's DVTTextStorage runs
// its own setup after each of -init, -initWithString:,
// -initWithString:attributes: and -initWithAttributedString:) and must see
// exactly one of them.
static void setUpStorage(NSConcreteTextStorage *self, NSString *string,
                         NSDictionary *attributes)
{
    self->_string = [(string != nil ? string : @"") mutableCopy];
    self->_rangeToAttributes = NSCreateRangeToCopiedObjectEntries(0);
    NSRangeEntryInsert(self->_rangeToAttributes,
                       NSMakeRange(0, [self->_string length]),
                       attributes != nil ? attributes : [NSDictionary dictionary]);
}

- init {
    self = [super initWithString: @""];
    setUpStorage(self, @"", nil);
    return self;
}

- initWithString: (NSString *) string {
    self = [super initWithString: string];
    setUpStorage(self, string, nil);
    return self;
}

- initWithString: (NSString *) string attributes: (NSDictionary *) attributes {
    self = [super initWithString: string];
    setUpStorage(self, string, attributes);
    return self;
}

- initWithAttributedString: (NSAttributedString *) attributedString {
    NSString *string = [attributedString string];
    NSUInteger location = 0, length = [string length];

    self = [super initWithString: string];
    setUpStorage(self, string, nil);
    while (location < length) {
        NSRange range;
        NSDictionary *attributes = [attributedString attributesAtIndex: location
                                                        effectiveRange: &range];
        setAttributes(self, attributes, range);
        location = NSMaxRange(range);
    }
    return self;
}

// Like Foundation's attributed strings, nibs hold the string and one
// attributes dictionary (strings with several runs keep an array of
// dictionaries and a run table, of which the first dictionary is used).
// Finish through -initWithString:attributes: so that subclasses set
// themselves up.
- initWithCoder: (NSCoder *) coder {
    if (![coder allowsKeyedCoding]) {
        [NSException raise: NSInvalidArgumentException
                    format: @"-[%@ %s] is not implemented for coder %@",
                            [self class], sel_getName(_cmd), coder];
        return nil;
    }

    NSKeyedUnarchiver *keyed = (NSKeyedUnarchiver *) coder;
    NSString *string = [keyed decodeObjectForKey: @"NSString"];
    id attributes = [keyed decodeObjectForKey: @"NSAttributes"];
    id delegate = [keyed decodeObjectForKey: @"NSDelegate"];

    if ([string isKindOfClass: [NSAttributedString class]])
        string = [(NSAttributedString *) string string];
    if (![string isKindOfClass: [NSString class]])
        string = @"";
    if ([attributes isKindOfClass: [NSArray class]])
        attributes = [(NSArray *) attributes count] > 0
                             ? [(NSArray *) attributes objectAtIndex: 0]
                             : nil;
    if (![attributes isKindOfClass: [NSDictionary class]])
        attributes = nil;

    self = [self initWithString: string attributes: attributes];
    _delegate = delegate;
    return self;
}

- (void) dealloc {
    [_string release];
    NSFreeRangeEntries(_rangeToAttributes);
    [super dealloc];
}

- (NSString *) string {
    return _string;
}

- (NSDictionary *) attributesAtIndex: (NSUInteger) location
                      effectiveRange: (NSRangePointer) effectiveRangep
{
    NSDictionary *result;

    NSAssert2(location <= [self length], @"index %lu beyond length %lu", (unsigned long) location,
              (unsigned long) [self length]);

    if ((result = NSRangeEntryAtIndex(_rangeToAttributes, location,
                                      effectiveRangep)) == nil)
        result = [NSDictionary dictionary];

    if (effectiveRangep != NULL && effectiveRangep->length == NSNotFound)
        effectiveRangep->length = [self length] - effectiveRangep->location;

    return [[result retain] autorelease];
}

static inline int
replaceCharactersInRangeWithString(NSConcreteTextStorage *self, NSRange range,
                                   NSString *string)
{
    int delta = [string length] - range.length;

    [self->_string replaceCharactersInRange: range withString: string];

    // NSRangeEntriesDump(self->_rangeToAttributes);

    NSRangeEntriesExpandAndWipe(self->_rangeToAttributes, range, delta);
    if (NSCountRangeEntries(self->_rangeToAttributes) == 0)
        NSRangeEntryInsert(self->_rangeToAttributes,
                           NSMakeRange(0, [self->_string length]),
                           [NSDictionary dictionary]);

    NSRangeEntriesVerify(self->_rangeToAttributes, [self length]);

    return delta;
}

static inline void setAttributes(NSConcreteTextStorage *self,
                                 NSDictionary *attributes, NSRange range)
{
    if (attributes == nil)
        attributes = [NSDictionary dictionary];

    if ([self->_string length] == 0) {
        NSResetRangeEntries(self->_rangeToAttributes);
        NSRangeEntryInsert(self->_rangeToAttributes, range, attributes);
    } else if (range.length > 0) {
        NSRangeEntriesDivideAndConquer(self->_rangeToAttributes, range);
        NSRangeEntryInsert(self->_rangeToAttributes, range, attributes);
    }

    NSRangeEntriesVerify(self->_rangeToAttributes, [self length]);
}

static inline void
replaceCharactersInRangeWithAttributedString(NSConcreteTextStorage *self,
                                             NSRange replaced,
                                             NSAttributedString *other)
{
    NSString *string = [other string];
    unsigned location = 0;
    unsigned limit = [string length];
    int delta = replaceCharactersInRangeWithString(self, replaced, string);

    while (location < limit) {
        NSRange effectiveRange;
        NSDictionary *attributes = [other attributesAtIndex: location
                                             effectiveRange: &effectiveRange];
        NSRange range = NSMakeRange(replaced.location + location,
                                    effectiveRange.length);

        setAttributes(self, attributes, range);

        location = NSMaxRange(effectiveRange);
    }

    if (limit == 0) {
        // That will just try to merge attributes at the location when possible
        NSRangeEntryInsert(self->_rangeToAttributes,
                           NSMakeRange(replaced.location, 0), nil);
    }

    [self edited: NSTextStorageEditedAttributes | NSTextStorageEditedCharacters
                     range: replaced
            changeInLength: delta];
}

- (void) replaceCharactersInRange: (NSRange) range
                       withString: (NSString *) string
{
    int delta = replaceCharactersInRangeWithString(self, range, string);
    [self edited: NSTextStorageEditedAttributes | NSTextStorageEditedCharacters
                     range: range
            changeInLength: delta];
}

- (void) setAttributes: (NSDictionary *) attributes range: (NSRange) range {
    setAttributes(self, attributes, range);
    [self edited: NSTextStorageEditedAttributes range: range changeInLength: 0];
}

- (void) replaceCharactersInRange: (NSRange) replaced
             withAttributedString: (NSAttributedString *) other
{
    replaceCharactersInRangeWithAttributedString(self, replaced, other);
}

- (void) setAttributedString: (NSAttributedString *) attributedString {
    [self beginEditing];
    replaceCharactersInRangeWithAttributedString(
            self, NSMakeRange(0, [self length]), attributedString);
    [self endEditing];
}

- (NSMutableString *) mutableString {
    return [[[NSClassFromString(
            @"NSMutableStringProxyForMutableAttributedString")
            allocWithZone: NULL]
            performSelector: @selector(initWithMutableAttributedString:)
                 withObject: self] autorelease];
}

- (void) fixAttributesAfterEditingRange: (NSRange) range {
}

@end
