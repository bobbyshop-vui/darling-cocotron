#import <AppKit/NSBezierPath.h>
#import <AppKit/NSBitmapImageRep.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSColorList.h>
#import <AppKit/NSColorSpace.h>
#import <AppKit/NSFont.h>
#import <AppKit/NSFontDescriptor.h>
#import <AppKit/NSGlyphInfo.h>
#import <AppKit/NSGradient.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSParagraphStyle.h>
#import <AppKit/NSShadow.h>
#import <AppKit/NSSound.h>
#import <AppKit/NSTextStorage.h>
#import <AppKit/NSTextTab.h>
#import <Foundation/NSAffineTransform.h>
#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSFileWrapper.h>
#import <Foundation/NSNumber.h>
#import <Foundation/NSString.h>
#import <Foundation/NSSet.h>

@implementation NSBezierPath (XcodeSecureCoding)
+ (BOOL) supportsSecureCoding {
    return YES;
}
@end

@implementation NSBitmapImageRep (XcodeSecureCoding)
+ (BOOL) supportsSecureCoding {
    return YES;
}
@end

@implementation NSColor (XcodeSecureCoding)
+ (BOOL) supportsSecureCoding {
    return YES;
}
@end

@implementation NSColorList (XcodeSecureCoding)
+ (BOOL) supportsSecureCoding {
    return YES;
}
@end

@implementation NSColorSpace (XcodeSecureCoding)
+ (BOOL) supportsSecureCoding {
    return YES;
}
@end

@implementation NSFont (XcodeSecureCoding)
+ (BOOL) supportsSecureCoding {
    return YES;
}
@end

@implementation NSFontDescriptor (XcodeSecureCoding)
+ (BOOL) supportsSecureCoding {
    return YES;
}

- (id) initWithCoder: (NSCoder *) coder {
    if (![coder allowsKeyedCoding]) {
        [NSException raise: NSInvalidArgumentException
                    format: @"%@ requires a keyed coder", [self class]];
        return nil;
    }

    NSSet *allowedClasses = [NSSet setWithObjects:
            [NSDictionary class], [NSArray class], [NSSet class],
            [NSString class], [NSNumber class], [NSAffineTransform class],
            [NSCharacterSet class], [NSFontDescriptor class], nil];
    NSDictionary *attributes =
            [coder decodeObjectOfClasses: allowedClasses
                                  forKey: @"NSFontDescriptorAttributes"];
    if (attributes != nil && ![attributes isKindOfClass: [NSDictionary class]]) {
        [NSException raise: NSInvalidArgumentException
                    format: @"%@ archive contains invalid font attributes",
                            [self class]];
        return nil;
    }

    return [self initWithFontAttributes: attributes];
}

- (void) encodeWithCoder: (NSCoder *) coder {
    if (![coder allowsKeyedCoding]) {
        [NSException raise: NSInvalidArgumentException
                    format: @"%@ requires a keyed coder", [self class]];
        return;
    }

    [coder encodeObject: [self fontAttributes]
                 forKey: @"NSFontDescriptorAttributes"];
}
@end

@implementation NSGlyphInfo (XcodeSecureCoding)
+ (BOOL) supportsSecureCoding {
    return YES;
}

- (id) initWithCoder: (NSCoder *) coder {
    if (![coder allowsKeyedCoding]) {
        [NSException raise: NSInvalidArgumentException
                    format: @"%@ requires a keyed coder", [self class]];
        return nil;
    }

    NSUInteger identifier = (NSUInteger) [coder decodeInt64ForKey: @"NSGlyphInfoCharacterIdentifier"];
    NSCharacterCollection collection =
            (NSCharacterCollection) [coder decodeIntegerForKey: @"NSGlyphInfoCharacterCollection"];
    NSString *glyphName = [coder decodeObjectOfClass: [NSString class]
                                               forKey: @"NSGlyphInfoGlyphName"];
    self = [super init];
    if (self != nil) {
        _identifier = identifier;
        _collection = collection;
        _glyphName = [glyphName copy];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder {
    if (![coder allowsKeyedCoding]) {
        [NSException raise: NSInvalidArgumentException
                    format: @"%@ requires a keyed coder", [self class]];
        return;
    }

    [coder encodeInt64: (int64_t) [self characterIdentifier]
                forKey: @"NSGlyphInfoCharacterIdentifier"];
    [coder encodeInteger: (NSInteger) [self characterCollection]
                  forKey: @"NSGlyphInfoCharacterCollection"];
    [coder encodeObject: [self glyphName] forKey: @"NSGlyphInfoGlyphName"];
}
@end

@implementation NSGradient (XcodeSecureCoding)
+ (BOOL) supportsSecureCoding {
    return YES;
}
@end

@implementation NSImage (XcodeSecureCoding)
+ (BOOL) supportsSecureCoding {
    return YES;
}
@end

@implementation NSParagraphStyle (XcodeSecureCoding)
+ (BOOL) supportsSecureCoding {
    return YES;
}
@end

@implementation NSShadow (XcodeSecureCoding)
+ (BOOL) supportsSecureCoding {
    return YES;
}
@end

@implementation NSSound (XcodeSecureCoding)
+ (BOOL) supportsSecureCoding {
    return YES;
}
@end

@implementation NSTextStorage (XcodeSecureCoding)
+ (BOOL) supportsSecureCoding {
    return YES;
}
@end

@implementation NSTextTab (XcodeSecureCoding)
+ (BOOL) supportsSecureCoding {
    return YES;
}
@end

@implementation NSFileWrapper (XcodeSecureCoding)
+ (BOOL) supportsSecureCoding {
    return YES;
}
@end
