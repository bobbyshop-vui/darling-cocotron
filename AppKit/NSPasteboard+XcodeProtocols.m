/*
 * Copyright (C) 2026 Darling Developers
 *
 * Darling is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#import <AppKit/NSPasteboard.h>
#import <AppKit/NSAttributedString.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSSound.h>
#import <Foundation/NSItemProvider.h>
#import <Foundation/NSString.h>
#import <Foundation/NSURL.h>

/* Darling's Foundation NSItemProvider declarations are currently hidden for
 * the legacy Objective-C runtime used by this target. Match the 10.14 SDK
 * reading protocol there so the category can still adopt it. */
#if !defined(__OBJC2__) || !__OBJC2__
@protocol NSItemProviderReading <NSObject>
+ (NSArray<NSString *> *)readableTypeIdentifiersForItemProvider;
+ (nullable instancetype)objectWithItemProviderData:(NSData *)data
                                     typeIdentifier:(NSString *)typeIdentifier
                                              error:(NSError **)outError;
@end
#endif

/* The reading-option values from the 10.14 SDK are not declared in Darling's
 * NSPasteboard.h yet. */
enum {
    DarlingPasteboardReadingAsData = 0,
    DarlingPasteboardReadingAsString = 1 << 0,
    DarlingPasteboardReadingAsPropertyList = 1 << 1,
    DarlingPasteboardReadingAsKeyedArchive = 1 << 2
};

static NSString *const DarlingUTF8PlainTextType = @"public.utf8-plain-text";
static NSString *const DarlingRTFType = @"public.rtf";
static NSString *const DarlingItemProviderErrorDomain = @"NSItemProviderErrorDomain";

/* NSSound's old type is absent from Darling's pasteboard header. Keep the
 * existing Cocotron type alongside the SDK spelling for compatibility. */
static NSPasteboardType const DarlingNSSoundLegacyPboardType =
        @"NXSoundPboardType";
static NSPasteboardType const DarlingNSSoundPboardType = @"NSSoundPboardType";

static void DarlingSetItemProviderReadError(NSError **error,
                                            NSString *description) {
    if (error == NULL)
        return;

    NSDictionary *userInfo = [NSDictionary dictionaryWithObject: description
                                                          forKey: NSLocalizedDescriptionKey];
    *error = [NSError errorWithDomain: DarlingItemProviderErrorDomain
                                 code: -1100 /* NSItemProviderUnexpectedValueClassError */
                             userInfo: userInfo];
}

@interface NSString (XcodePasteboardProtocols) <NSPasteboardWriting,
                                                NSPasteboardReading,
                                                NSItemProviderReading>
@end

@interface NSURL (XcodePasteboardProtocols) <NSPasteboardWriting,
                                             NSPasteboardReading,
                                             NSItemProviderReading>
@end

@interface NSAttributedString (XcodePasteboardProtocols) <NSPasteboardWriting,
                                                          NSPasteboardReading>
@end

@interface NSColor (XcodePasteboardProtocols) <NSPasteboardWriting,
                                              NSPasteboardReading>
@end

@interface NSImage (XcodePasteboardProtocols) <NSPasteboardWriting,
                                              NSPasteboardReading>
@end

@interface NSSound (XcodePasteboardProtocols) <NSPasteboardWriting,
                                               NSPasteboardReading>
@end

@implementation NSString (XcodePasteboardProtocols)

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return [NSArray arrayWithObjects: NSStringPboardType,
                                      DarlingUTF8PlainTextType, nil];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSPasteboardType)type
                                          pasteboard:(NSPasteboard *)pasteboard {
    if ([type isEqualToString: NSStringPboardType] ||
        [type isEqualToString: DarlingUTF8PlainTextType])
        return DarlingPasteboardReadingAsString;
    return DarlingPasteboardReadingAsData;
}

- (NSArray<NSPasteboardType> *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return [NSArray arrayWithObjects: NSStringPboardType,
                                      DarlingUTF8PlainTextType, nil];
}

- (id)pasteboardPropertyListForType:(NSPasteboardType)type {
    if ([type isEqualToString: NSStringPboardType] ||
        [type isEqualToString: DarlingUTF8PlainTextType])
        return self;
    return nil;
}

- (id)initWithPasteboardPropertyList:(id)propertyList
                               ofType:(NSPasteboardType)type {
    NSString *string = nil;
    if ([propertyList isKindOfClass: [NSString class]])
        string = propertyList;
    else if ([propertyList isKindOfClass: [NSData class]])
        string = [[[NSString alloc] initWithData: propertyList
                                        encoding: NSUTF8StringEncoding] autorelease];
    if (string == nil) {
        [self release];
        return nil;
    }
    return [self initWithString: string];
}

+ (NSArray<NSString *> *)readableTypeIdentifiersForItemProvider {
    return [NSArray arrayWithObject: DarlingUTF8PlainTextType];
}

+ (instancetype)objectWithItemProviderData:(NSData *)data
                             typeIdentifier:(NSString *)typeIdentifier
                                      error:(NSError **)error {
    if (error != NULL)
        *error = nil;
    if (![typeIdentifier isEqualToString: DarlingUTF8PlainTextType] || data == nil) {
        DarlingSetItemProviderReadError(error, @"The item provider data is not UTF-8 plain text.");
        return nil;
    }

    NSString *string = [[NSString alloc] initWithData: data
                                             encoding: NSUTF8StringEncoding];
    if (string == nil) {
        DarlingSetItemProviderReadError(error, @"The item provider data is not valid UTF-8.");
        return nil;
    }
    return [string autorelease];
}

@end

@implementation NSURL (XcodePasteboardProtocols)

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return [NSArray arrayWithObjects: NSPasteboardTypeFileURL,
                                      NSPasteboardTypeURL,
                                      NSURLPboardType,
                                      NSFilenamesPboardType, nil];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSPasteboardType)type
                                          pasteboard:(NSPasteboard *)pasteboard {
    if ([type isEqualToString: NSFilenamesPboardType])
        return DarlingPasteboardReadingAsPropertyList;
    if ([type isEqualToString: NSPasteboardTypeFileURL] ||
        [type isEqualToString: NSPasteboardTypeURL] ||
        [type isEqualToString: NSURLPboardType])
        return DarlingPasteboardReadingAsString;
    return DarlingPasteboardReadingAsData;
}

- (NSArray<NSPasteboardType> *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    if ([self isFileURL])
        return [NSArray arrayWithObjects: NSPasteboardTypeFileURL,
                                          NSPasteboardTypeURL,
                                          NSURLPboardType,
                                          NSFilenamesPboardType, nil];
    return [NSArray arrayWithObjects: NSPasteboardTypeURL,
                                      NSURLPboardType, nil];
}

- (id)pasteboardPropertyListForType:(NSPasteboardType)type {
    if ([type isEqualToString: NSFilenamesPboardType]) {
        if (![self isFileURL])
            return nil;
        NSString *path = [self path];
        return path == nil ? nil : [NSArray arrayWithObject: path];
    }

    if ([type isEqualToString: NSPasteboardTypeFileURL] ||
        [type isEqualToString: NSPasteboardTypeURL] ||
        [type isEqualToString: NSURLPboardType])
        return [self absoluteString];
    return nil;
}

- (id)initWithPasteboardPropertyList:(id)propertyList
                               ofType:(NSPasteboardType)type {
    if ([type isEqualToString: NSFilenamesPboardType]) {
        NSString *path = nil;
        if ([propertyList isKindOfClass: [NSArray class]] &&
            [propertyList count] > 0 &&
            [[propertyList objectAtIndex: 0] isKindOfClass: [NSString class]])
            path = [propertyList objectAtIndex: 0];
        if (path == nil) {
            [self release];
            return nil;
        }
        return [self initFileURLWithPath: path];
    }

    NSString *urlString = nil;
    if ([propertyList isKindOfClass: [NSString class]])
        urlString = propertyList;
    else if ([propertyList isKindOfClass: [NSURL class]])
        urlString = [propertyList absoluteString];
    else if ([propertyList isKindOfClass: [NSData class]])
        urlString = [[[NSString alloc] initWithData: propertyList
                                           encoding: NSUTF8StringEncoding] autorelease];

    if (urlString == nil) {
        [self release];
        return nil;
    }
    return [self initWithString: urlString];
}

+ (NSArray<NSString *> *)readableTypeIdentifiersForItemProvider {
    return [NSArray arrayWithObjects: @"public.file-url", @"public.url", nil];
}

+ (instancetype)objectWithItemProviderData:(NSData *)data
                             typeIdentifier:(NSString *)typeIdentifier
                                      error:(NSError **)error {
    if (error != NULL)
        *error = nil;
    BOOL fileURLType = [typeIdentifier isEqualToString: @"public.file-url"];
    if ((!fileURLType && ![typeIdentifier isEqualToString: @"public.url"]) ||
        data == nil) {
        DarlingSetItemProviderReadError(error, @"The item provider data is not a URL.");
        return nil;
    }

    NSString *urlString = [[[NSString alloc] initWithData: data
                                                encoding: NSUTF8StringEncoding] autorelease];
    NSURL *url = urlString == nil ? nil : [NSURL URLWithString: urlString];
    if (url == nil || (fileURLType && ![url isFileURL])) {
        DarlingSetItemProviderReadError(error, @"The item provider data is not a valid URL.");
        return nil;
    }
    return url;
}

@end

@implementation NSAttributedString (XcodePasteboardProtocols)

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return [NSArray arrayWithObjects: NSRTFPboardType,
                                      DarlingRTFType,
                                      NSStringPboardType,
                                      DarlingUTF8PlainTextType, nil];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSPasteboardType)type
                                          pasteboard:(NSPasteboard *)pasteboard {
    if ([type isEqualToString: NSStringPboardType] ||
        [type isEqualToString: DarlingUTF8PlainTextType])
        return DarlingPasteboardReadingAsString;
    return DarlingPasteboardReadingAsData;
}

- (NSArray<NSPasteboardType> *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return [NSArray arrayWithObjects: NSRTFPboardType,
                                      DarlingRTFType,
                                      NSStringPboardType,
                                      DarlingUTF8PlainTextType, nil];
}

- (id)pasteboardPropertyListForType:(NSPasteboardType)type {
    if ([type isEqualToString: NSRTFPboardType] ||
        [type isEqualToString: DarlingRTFType])
        return [self RTFFromRange: NSMakeRange(0, [self length])
               documentAttributes: nil];
    if ([type isEqualToString: NSStringPboardType] ||
        [type isEqualToString: DarlingUTF8PlainTextType])
        return [self string];
    return nil;
}

- (id)initWithPasteboardPropertyList:(id)propertyList
                               ofType:(NSPasteboardType)type {
    if ([type isEqualToString: NSRTFPboardType] ||
        [type isEqualToString: DarlingRTFType]) {
        if (![propertyList isKindOfClass: [NSData class]]) {
            [self release];
            return nil;
        }
        NSDictionary *attributes = nil;
        return [self initWithRTF: propertyList documentAttributes: &attributes];
    }

    if ([type isEqualToString: NSStringPboardType] ||
        [type isEqualToString: DarlingUTF8PlainTextType]) {
        NSString *string = [propertyList isKindOfClass: [NSString class]]
                ? propertyList : nil;
        if (string == nil) {
            [self release];
            return nil;
        }
        return [self initWithString: string];
    }

    [self release];
    return nil;
}

@end

@implementation NSColor (XcodePasteboardProtocols)

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return [NSArray arrayWithObject: NSColorPboardType];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSPasteboardType)type
                                          pasteboard:(NSPasteboard *)pasteboard {
    return DarlingPasteboardReadingAsKeyedArchive;
}

- (NSArray<NSPasteboardType> *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return [NSArray arrayWithObject: NSColorPboardType];
}

- (id)pasteboardPropertyListForType:(NSPasteboardType)type {
    if ([type isEqualToString: NSColorPboardType])
        return [NSKeyedArchiver archivedDataWithRootObject: self];
    return nil;
}

@end

@implementation NSImage (XcodePasteboardProtocols)

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return [NSArray arrayWithObject: NSTIFFPboardType];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSPasteboardType)type
                                          pasteboard:(NSPasteboard *)pasteboard {
    return DarlingPasteboardReadingAsData;
}

- (NSArray<NSPasteboardType> *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return [NSArray arrayWithObject: NSTIFFPboardType];
}

- (id)pasteboardPropertyListForType:(NSPasteboardType)type {
    if ([type isEqualToString: NSTIFFPboardType])
        return [self TIFFRepresentation];
    return nil;
}

- (id)initWithPasteboardPropertyList:(id)propertyList
                               ofType:(NSPasteboardType)type {
    if ([type isEqualToString: NSTIFFPboardType] &&
        [propertyList isKindOfClass: [NSData class]])
        return [self initWithData: propertyList];
    [self release];
    return nil;
}

@end

@implementation NSSound (XcodePasteboardProtocols)

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return [NSArray arrayWithObjects: DarlingNSSoundPboardType,
                                      DarlingNSSoundLegacyPboardType, nil];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSPasteboardType)type
                                          pasteboard:(NSPasteboard *)pasteboard {
    return DarlingPasteboardReadingAsData;
}

- (NSArray<NSPasteboardType> *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return [NSArray arrayWithObjects: DarlingNSSoundPboardType,
                                      DarlingNSSoundLegacyPboardType, nil];
}

- (id)pasteboardPropertyListForType:(NSPasteboardType)type {
    if ([type isEqualToString: DarlingNSSoundPboardType] ||
        [type isEqualToString: DarlingNSSoundLegacyPboardType])
        return _data;
    return nil;
}

- (id)initWithPasteboardPropertyList:(id)propertyList
                               ofType:(NSPasteboardType)type {
    if (([type isEqualToString: DarlingNSSoundPboardType] ||
         [type isEqualToString: DarlingNSSoundLegacyPboardType]) &&
        [propertyList isKindOfClass: [NSData class]])
        return [self initWithData: propertyList];
    [self release];
    return nil;
}

@end
