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

#import <AppKit/NSDisplay.h>
#import <AppKit/NSPasteboard.h>
#import <AppKit/NSPasteboardItem.h>
#import <AppKit/NSRaise.h>

const NSPasteboardType NSPasteboardTypeString = @"NSStringPboardType";
const NSPasteboardType NSPasteboardTypePDF = @"NSPDFPboardType";
const NSPasteboardType NSPasteboardTypePNG = @"NSPDFPboardType";
const NSPasteboardType NSPasteboardTypeTIFF = @"NSTIFFPboardType";
const NSPasteboardType NSPasteboardTypeRTF = @"NSRTFPboardType";
const NSPasteboardType NSPasteboardTypeRTFD = @"NSRTFDPboardType";
const NSPasteboardType NSPasteboardTypeHTML = @"NSPasteboardTypeHTML";
const NSPasteboardType NSPasteboardTypeTabularText = @"NSTabularTextPboardType";
const NSPasteboardType NSPasteboardTypeFont = @"NSFontPboardType";
const NSPasteboardType NSPasteboardTypeRuler = @"NSRulerPboardType";
const NSPasteboardType NSPasteboardTypeURL = @"public.url";
const NSPasteboardType NSPasteboardTypeColor = @"NSColorPboardType";
const NSPasteboardType NSPasteboardTypeFileURL = @"public.file-url";
const NSPasteboardType NSPasteboardTypeMultipleTextSelection = @"com.apple.cocoa.pasteboard.multiple-text-selection";

const NSPasteboardType NSColorPboardType = @"NSColorPboardType";
const NSPasteboardType NSFileContentsPboardType = @"NSFileContentsPboardType";
const NSPasteboardType NSFilenamesPboardType = @"NSFilenamesPboardType";
const NSPasteboardType NSFontPboardType = @"NSFontPboardType";
const NSPasteboardType NSPDFPboardType = @"NSPDFPboardType";
const NSPasteboardType NSPICTPboardType = @"NSPICTPboardType";
const NSPasteboardType NSPostScriptPboardType = @"NSPostScriptPboardType";
const NSPasteboardType NSRTFDPboardType = @"NSRTFDPboardType";
const NSPasteboardType NSRTFPboardType = @"NSRTFPboardType";
const NSPasteboardType NSRulerPboardType = @"NSRulerPboardType";
const NSPasteboardType NSStringPboardType = @"NSStringPboardType";
const NSPasteboardType NSTabularTextPboardType = @"NSTabularTextPboardType";
const NSPasteboardType NSTIFFPboardType = @"NSTIFFPboardType";
const NSPasteboardType NSURLPboardType = @"NSURLPboardType";
const NSPasteboardType NSHTMLPboardType = @"Apple HTML pasteboard type";
const NSPasteboardType NSVCardPboardType = @"NSVCardPboardType";
const NSPasteboardType NSInkTextPboardType = @"Apple InkText pasteboard type";
const NSPasteboardType NSMultipleTextSelectionPboardType = @"Apple multiple text selection pasteboard type";

const NSPasteboardType NSFilesPromisePboardType =
        @"Apple files promise pasteboard type";

const NSPasteboardName NSPasteboardNameDrag = @"Apple CFPasteboard drag";
NSString *const NSPasteboardURLReadingFileURLsOnlyKey =
        @"NSPasteboardURLReadingFileURLsOnlyKey";

const NSPasteboardName NSDragPboard = @"NSDragPboard";
const NSPasteboardName NSFindPboard = @"NSFindPboard";
const NSPasteboardName NSFontPboard = @"NSFontPboard";
const NSPasteboardName NSGeneralPboard = @"NSGeneralPboard";
const NSPasteboardName NSRulerPboard = @"NSRulerPboard";

const NSPasteboardName NSPasteboardNameFind = @"Apple CFPasteboard find";
const NSPasteboardName NSPasteboardNameFont = @"Apple CFPasteboard font";
const NSPasteboardName NSPasteboardNameGeneral = @"Apple CFPasteboard general";

const NSPasteboardReadingOptionKey
        NSPasteboardURLReadingContentsConformToTypesKey =
                @"NSPasteboardURLReadingContentsConformToTypesKey";

@interface NSPasteboardItem (DarlingPasteboardBinding)
- (void) _setPasteboard: (NSPasteboard *) pasteboard index: (NSUInteger) index;
- (NSPasteboard *) _pasteboard;
- (NSUInteger) _index;
@end

static BOOL NSPasteboardWriteValue(NSPasteboard *pboard, id value,
                                   NSPasteboardType type) {
    if (value == nil) {
        return NO;
    }
    if ([value isKindOfClass: [NSData class]]) {
        return [pboard setData: value forType: type];
    }
    if ([value isKindOfClass: [NSString class]]) {
        return [pboard setString: value forType: type];
    }
    return [pboard setPropertyList: value forType: type];
}

static NSArray *NSPasteboardTypesReadableByClass(Class cls) {
    if ([cls isSubclassOfClass: [NSAttributedString class]]) {
        return [NSArray arrayWithObjects: NSPasteboardTypeRTFD,
                                          NSPasteboardTypeRTF,
                                          NSPasteboardTypeString, nil];
    }
    if ([cls isSubclassOfClass: [NSString class]]) {
        return [NSArray arrayWithObjects: NSPasteboardTypeString,
                                          NSStringPboardType, nil];
    }
    if ([cls isSubclassOfClass: [NSURL class]]) {
        return [NSArray arrayWithObjects: NSPasteboardTypeFileURL,
                                          NSPasteboardTypeURL,
                                          NSURLPboardType,
                                          NSFilenamesPboardType, nil];
    }
    if ([cls isSubclassOfClass: NSClassFromString(@"NSImage")]) {
        return [NSArray arrayWithObjects: NSPasteboardTypeTIFF,
                                          NSPasteboardTypePNG,
                                          NSPasteboardTypePDF, nil];
    }
    if ([cls isSubclassOfClass: NSClassFromString(@"NSColor")]) {
        return [NSArray arrayWithObject: NSPasteboardTypeColor];
    }
    return nil;
}

@implementation NSPasteboard

+ (NSPasteboard *) generalPasteboard {
    return [self pasteboardWithName: NSGeneralPboard];
}

+ (NSPasteboard *) pasteboardWithName: (NSPasteboardName) name {
    return [[NSDisplay currentDisplay] pasteboardWithName: name];
}

+ (NSPasteboard *) pasteboardWithUniqueName {
    NSString *name = [[NSProcessInfo processInfo] globallyUniqueString];
    return [self pasteboardWithName: name];
}

+ (NSArray<NSPasteboardType> *) typesFilterableTo: (NSPasteboardType) type {
    // No filter services are available, so a type can only be filtered to itself.
    if (type == nil) {
        return [NSArray array];
    }
    return [NSArray arrayWithObject: type];
}

+ (NSPasteboard *) pasteboardByFilteringFile: (NSString *) filename {
    NSPasteboard *pboard = [self pasteboardWithUniqueName];
    NSData *contents = [NSData dataWithContentsOfFile: filename];
    NSMutableArray *types = [NSMutableArray array];

    [types addObject: NSFilenamesPboardType];
    if (contents != nil) {
        [types addObject: NSFileContentsPboardType];
    }
    [pboard declareTypes: types owner: nil];
    [pboard setPropertyList: [NSArray arrayWithObject: filename]
                    forType: NSFilenamesPboardType];
    if (contents != nil) {
        [pboard setData: contents forType: NSFileContentsPboardType];
    }
    return pboard;
}

+ (NSPasteboard *) pasteboardByFilteringData: (NSData *) data
                                      ofType: (NSPasteboardType) type {
    NSPasteboard *pboard = [self pasteboardWithUniqueName];
    [pboard declareTypes: [NSArray arrayWithObject: type] owner: nil];
    [pboard setData: data forType: type];
    return pboard;
}

+ (NSPasteboard *) pasteboardByFilteringTypesInPasteboard:
        (NSPasteboard *) pboard {
    NSPasteboard *result = [self pasteboardWithUniqueName];
    NSArray *types = [pboard types];

    [result declareTypes: types owner: nil];
    for (NSPasteboardType type in types) {
        NSData *data = [pboard dataForType: type];
        if (data != nil) {
            [result setData: data forType: type];
        }
    }
    return result;
}

- (NSPasteboardName) name {
    NSUnimplementedMethod();
    return nil;
}

- (NSInteger) changeCount {
    NSUnimplementedMethod();
    return 0;
}

- (NSInteger) clearContents {
    NSUnimplementedMethod();
    return 0;
}

- (oneway void) releaseGlobally {
    NSUnimplementedMethod();
}

- (NSArray<NSPasteboardType> *) types {
    NSUnimplementedMethod();
    return nil;
}

- (NSPasteboardType) availableTypeFromArray: (NSArray<NSPasteboardType> *) types
{
    NSArray<NSPasteboardType> *available = [self types];
    for (NSPasteboardType type in types) {
        if ([available containsObject: type]) {
            return type;
        }
    }
    return nil;
}

- (NSData *) dataForType: (NSPasteboardType) type {
    NSUnimplementedMethod();
    return nil;
}

- (NSString *) stringForType: (NSPasteboardType) type {
    NSData *data = [self dataForType: type];

    return [[[NSString alloc] initWithData: data
                                  encoding: NSUnicodeStringEncoding]
            autorelease];
}

- (id) propertyListForType: (NSPasteboardType) type {
    NSData *data = [self dataForType: type];
    NSString *errorDesc = nil;
    id plist = [NSPropertyListSerialization
            propertyListFromData: data
                mutabilityOption: NSPropertyListImmutable
                          format: NULL
                errorDescription: &errorDesc];
    if (plist && errorDesc == nil) {
        return plist;
    }
    NSLog(@"propertyListForType: produced error: %@", errorDesc);
    return nil;
}

- (NSInteger) declareTypes: (NSArray<NSPasteboardType> *) types
                     owner: (id<NSPasteboardTypeOwner>) owner
{
    NSUnimplementedMethod();
    return 0;
}

- (NSInteger) addTypes: (NSArray<NSPasteboardType> *) types
                 owner: (id<NSPasteboardTypeOwner>) owner
{
    NSUnimplementedMethod();
    return 0;
}

- (BOOL) setData: (NSData *) data forType: (NSPasteboardType) type {
    NSUnimplementedMethod();
    return NO;
}

- (BOOL) setString: (NSString *) string forType: (NSPasteboardType) type {
    NSData *data = [string dataUsingEncoding: NSUnicodeStringEncoding];
    return [self setData: data forType: type];
}

- (BOOL) setPropertyList: (id) plist forType: (NSPasteboardType) type {
    NSString *errorDesc = nil;
    NSData *data = [NSPropertyListSerialization
            dataFromPropertyList: plist
                          format: NSPropertyListXMLFormat_v1_0
                errorDescription: &errorDesc];
    if (data && errorDesc == nil) {
        return [self setData: data forType: type];
    }
    NSLog(@"setPropertyList:forType: produced error: %@", errorDesc);
    return NO;
}

- (BOOL) canReadItemWithDataConformingToTypes:(NSArray<NSString *> *) types {
    printf("STUB %s\n", __PRETTY_FUNCTION__);
    return NO;
}

- (BOOL) canReadObjectForClasses: (NSArray<Class> *) classArray
                         options: (NSDictionary<NSPasteboardReadingOptionKey, id> *) options
{
    BOOL fileURLsOnly = [[options objectForKey:
                                          NSPasteboardURLReadingFileURLsOnlyKey]
            boolValue];

    for (Class cls in classArray) {
        NSArray *readable = nil;

        if ([cls conformsToProtocol: @protocol(NSPasteboardReading)] &&
            [cls respondsToSelector: @selector(readableTypesForPasteboard:)]) {
            readable = [cls readableTypesForPasteboard: self];
        } else {
            readable = NSPasteboardTypesReadableByClass(cls);
            if (fileURLsOnly && [cls isSubclassOfClass: [NSURL class]]) {
                readable = [NSArray arrayWithObjects: NSPasteboardTypeFileURL,
                                                      NSFilenamesPboardType,
                                                      nil];
            }
        }
        if ([readable count] > 0 &&
            [self availableTypeFromArray: readable] != nil) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) writeObjects: (NSArray *) objects {
    NSMutableArray *types = [NSMutableArray array];
    NSMutableArray *values = [NSMutableArray array]; // parallel, NSNull when absent
    NSMutableArray *valueTypes = [NSMutableArray array];

    for (id object in objects) {
        NSArray *writable = nil;

        if ([object isKindOfClass: [NSPasteboardItem class]]) {
            writable = [object types];
            for (NSPasteboardType type in writable) {
                id value = [object dataForType: type];
                if (value != nil && ![valueTypes containsObject: type]) {
                    [valueTypes addObject: type];
                    [values addObject: value];
                }
            }
        } else if ([object respondsToSelector:
                                   @selector(writableTypesForPasteboard:)]) {
            writable = [object writableTypesForPasteboard: self];
            for (NSPasteboardType type in writable) {
                if ([valueTypes containsObject: type] ||
                    ![object respondsToSelector:
                                     @selector(pasteboardPropertyListForType:)]) {
                    continue;
                }
                id value = [object pasteboardPropertyListForType: type];
                if (value != nil) {
                    [valueTypes addObject: type];
                    [values addObject: value];
                }
            }
        } else if ([object isKindOfClass: [NSString class]]) {
            writable = [NSArray arrayWithObject: NSPasteboardTypeString];
            if (![valueTypes containsObject: NSPasteboardTypeString]) {
                [valueTypes addObject: NSPasteboardTypeString];
                [values addObject: object];
            }
        } else {
            return NO;
        }

        for (NSPasteboardType type in writable) {
            if (![types containsObject: type]) {
                [types addObject: type];
            }
        }
    }

    [self clearContents];
    [self addTypes: types owner: nil];

    BOOL ok = YES;
    for (NSUInteger i = 0; i < [valueTypes count]; i++) {
        if (!NSPasteboardWriteValue(self, [values objectAtIndex: i],
                                    [valueTypes objectAtIndex: i])) {
            ok = NO;
        }
    }
    return ok;
}

- (NSArray<NSPasteboardItem *> *) pasteboardItems {
    NSArray *types = [self types];
    if ([types count] == 0) {
        return [NSArray array];
    }

    // The backends expose a single item, so the pasteboard has exactly one item.
    NSPasteboardItem *item = [[[NSPasteboardItem alloc] init] autorelease];
    [item _setPasteboard: self index: 0];
    return [NSArray arrayWithObject: item];
}

- (NSUInteger) indexOfPasteboardItem: (NSPasteboardItem *) pasteboardItem {
    if ([pasteboardItem _pasteboard] != self) {
        return NSNotFound;
    }
    return [pasteboardItem _index];
}

- (nullable NSArray *)readObjectsForClasses:(NSArray<Class> *)classArray options:(nullable NSDictionary<NSPasteboardReadingOptionKey, id> *) options {
    printf("STUB %s\n", __PRETTY_FUNCTION__);
    return nil;
}

@end
