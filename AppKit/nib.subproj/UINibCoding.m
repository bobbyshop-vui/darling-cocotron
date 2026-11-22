#import "UINibCoding.h"
#import <Foundation/Foundation.h>

// Use the same UID objects and binary writer as NSKeyedArchiver.
CF_EXPORT CFTypeID _CFKeyedArchiverUIDGetTypeID(void);
CF_EXPORT CFKeyedArchiverUIDRef _CFKeyedArchiverUIDCreate(CFAllocatorRef allocator, uint32_t value);
CF_EXPORT CFIndex __CFBinaryPlistWriteToStream(CFPropertyListRef plist, CFTypeRef stream);

static const char nibSignature[] = "NIBArchive";

typedef struct {
    const uint8_t *next;
    const uint8_t *end;
    BOOL failed;
} NibReader;

static const uint8_t *readBytes(NibReader *reader, NSUInteger length) {
    if (reader->failed || length > (NSUInteger)(reader->end - reader->next)) {
        reader->failed = YES;
        return NULL;
    }

    const uint8_t *bytes = reader->next;
    reader->next += length;
    return bytes;
}

static uint64_t readLittleEndian(NibReader *reader, NSUInteger length) {
    const uint8_t *bytes = readBytes(reader, length);
    uint64_t value = 0;
    if (bytes != NULL) {
        for (NSUInteger i = 0; i < length; ++i)
            value |= (uint64_t)bytes[i] << (8 * i);
    }
    return value;
}

static uint32_t readVarint(NibReader *reader) {
    uint32_t value = 0;
    for (unsigned shift = 0; shift < 32; shift += 7) {
        uint8_t byte = (uint8_t)readLittleEndian(reader, 1);
        if (reader->failed || (shift == 28 && (byte & 0x70) != 0))
            break;
        value |= (uint32_t)(byte & 0x7f) << shift;
        if ((byte & 0x80) != 0)
            return value;
    }
    reader->failed = YES;
    return 0;
}

static NSString *readString(NibReader *reader, uint32_t length, BOOL terminated) {
    const uint8_t *bytes = readBytes(reader, length);
    if (bytes == NULL || (terminated && (length == 0 || bytes[length - 1] != 0)))
        return nil;
    if (terminated)
        --length;

    return [[[NSString alloc] initWithBytes: bytes
                                    length: length
                                  encoding: NSUTF8StringEncoding] autorelease];
}

static id archiveUID(uint32_t index) {
    return [(id)_CFKeyedArchiverUIDCreate(NULL, index) autorelease];
}

typedef NS_ENUM(uint8_t, NibValueType) {
    NibValueInt8 = 0,
    NibValueInt16,
    NibValueInt32,
    NibValueInt64,
    NibValueFalse,
    NibValueTrue,
    NibValueFloat,
    NibValueDouble,
    NibValueBytes,
    NibValueNil,
    NibValueReference,
};

static id readValue(NibReader *reader, NSArray *objectUIDs) {
    switch ((NibValueType)readLittleEndian(reader, 1)) {
        case NibValueInt8:
            return @((int8_t)readLittleEndian(reader, 1));
        case NibValueInt16:
            return @((int16_t)readLittleEndian(reader, 2));
        case NibValueInt32:
            return @((int32_t)readLittleEndian(reader, 4));
        case NibValueInt64:
            return @((int64_t)readLittleEndian(reader, 8));
        case NibValueFalse:
            return (id)kCFBooleanFalse;
        case NibValueTrue:
            return (id)kCFBooleanTrue;
        case NibValueFloat: {
            uint32_t bits = (uint32_t)readLittleEndian(reader, 4);
            float value;
            memcpy(&value, &bits, sizeof(value));
            return @(value);
        }
        case NibValueDouble: {
            uint64_t bits = readLittleEndian(reader, 8);
            double value;
            memcpy(&value, &bits, sizeof(value));
            return @(value);
        }
        case NibValueBytes: {
            uint32_t length = readVarint(reader);
            const uint8_t *bytes = readBytes(reader, length);
            return bytes == NULL ? nil : [NSData dataWithBytes: bytes length: length];
        }
        case NibValueNil:
            return objectUIDs[0];
        case NibValueReference: {
            uint32_t index = (uint32_t)readLittleEndian(reader, 4);
            return index < [objectUIDs count] - 1 ? objectUIDs[index + 1] : nil;
        }
    }
    return nil;
}

static NSDictionary *archiveClass(NSString *name, NSArray *fallbacks) {
    return @{@"$classname": name, @"$classes": [@[name] arrayByAddingObjectsFromArray: fallbacks]};
}

// NSKeyedUnarchiver expects a different representation for these Foundation classes.
static BOOL translateFoundationObject(NSString *className, NSMutableDictionary *object,
                                      NSMutableArray *archiveObjects, id stringClassUID) {
    BOOL mutableString = [className isEqualToString: @"NSMutableString"];
    if ((mutableString || [className isEqualToString: @"NSString"]) && object[@"NS.bytes"] != nil) {
        NSData *data = object[@"NS.bytes"];
        if (CFGetTypeID((CFTypeRef)data) != CFDataGetTypeID())
            return NO;
        NSString *string = [[[NSString alloc] initWithData: data
                                                  encoding: NSUTF8StringEncoding] autorelease];
        if (string == nil)
            return NO;

        object[@"NS.string"] = string;
        if (mutableString) {
            // Darling's NSMutableString decoder obtains NS.bytes as an object.
            if ([archiveObjects count] > UINT32_MAX)
                return NO;
            object[@"NS.bytes"] = archiveUID((uint32_t)[archiveObjects count]);
            [archiveObjects addObject: @{@"$class": stringClassUID, @"NS.string": string}];
        } else {
            [object removeObjectForKey: @"NS.bytes"];
        }
    } else if ([className isEqualToString: @"NSNumber"]) {
        id number = object[@"NS.intval"] ?: object[@"NS.dblval"] ?: object[@"NS.boolval"];
        if (number != nil)
            object[@"NS.number"] = number;
    }
    return YES;
}

BOOL NSIsNibArchive(NSData *data) {
    NSUInteger length = sizeof(nibSignature) - 1;
    return [data length] >= length && memcmp([data bytes], nibSignature, length) == 0;
}

NSData *NSKeyedArchiveFromNibArchive(NSData *data) {
    enum { Objects, Keys, Values, Classes, TableCount };
    const NSUInteger headerLength = sizeof(nibSignature) - 1 + 2 * sizeof(uint32_t) +
                                    TableCount * 2 * sizeof(uint32_t);
    if ([data length] < headerLength || !NSIsNibArchive(data))
        return nil;

    const uint8_t *bytes = [data bytes];
    NibReader header = {bytes + sizeof(nibSignature) - 1, bytes + headerLength, NO};
    uint32_t formatVersion = (uint32_t)readLittleEndian(&header, 4);
    uint32_t coderVersion = (uint32_t)readLittleEndian(&header, 4);
    if (formatVersion != 1 || (coderVersion != 9 && coderVersion != 10))
        return nil;

    uint32_t counts[TableCount];
    NSUInteger offsets[TableCount + 1];
    for (NSUInteger i = 0; i < TableCount; ++i) {
        counts[i] = (uint32_t)readLittleEndian(&header, 4);
        offsets[i] = (NSUInteger)readLittleEndian(&header, 4);
    }
    offsets[TableCount] = [data length];
    if (offsets[0] < headerLength || counts[Objects] == 0 ||
        (uint64_t)counts[Objects] + counts[Classes] + 1 > UINT32_MAX)
        return nil;

    const NSUInteger minimumEntryLength[TableCount] = {3, 1, 2, 3};
    NibReader tables[TableCount];
    for (NSUInteger i = 0; i < TableCount; ++i) {
        if (offsets[i] > offsets[i + 1] || offsets[i + 1] > [data length] ||
            counts[i] > (offsets[i + 1] - offsets[i]) / minimumEntryLength[i])
            return nil;
        tables[i] = (NibReader){bytes + offsets[i], bytes + offsets[i + 1], NO};
    }

    NSMutableArray *keys = [NSMutableArray arrayWithCapacity: counts[Keys]];
    for (uint32_t i = 0; i < counts[Keys]; ++i) {
        NibReader *reader = &tables[Keys];
        uint32_t length = readVarint(reader);
        NSString *key = readString(reader, length, NO);
        if (key == nil)
            return nil;
        [keys addObject: key];
    }

    NSUInteger objectCount = counts[Objects];
    NSMutableArray *objectUIDs = [NSMutableArray arrayWithCapacity: objectCount + 1];
    NSMutableArray *archiveObjects = [NSMutableArray arrayWithCapacity: objectCount + 1];
    for (NSUInteger i = 0; i <= objectCount; ++i) {
        [objectUIDs addObject: archiveUID((uint32_t)i)];
        [archiveObjects addObject: @"$null"];
    }

    NSMutableArray *classNames = [NSMutableArray arrayWithCapacity: counts[Classes]];
    NSMutableArray *classFallbacks = [NSMutableArray arrayWithCapacity: counts[Classes]];
    NibReader *classesReader = &tables[Classes];
    for (uint32_t i = 0; i < counts[Classes]; ++i) {
        uint32_t length = readVarint(classesReader);
        uint32_t fallbackCount = readVarint(classesReader);
        if (classesReader->failed || fallbackCount > (NSUInteger)(classesReader->end - classesReader->next) / 4)
            return nil;

        NSMutableArray *fallbacks = [NSMutableArray arrayWithCapacity: fallbackCount];
        for (uint32_t j = 0; j < fallbackCount; ++j) {
            uint32_t index = (uint32_t)readLittleEndian(classesReader, 4);
            if (index >= counts[Classes])
                return nil;
            [fallbacks addObject: @(index)];
        }
        NSString *name = readString(classesReader, length, YES);
        if ([name length] == 0)
            return nil;
        [classNames addObject: name];
        [classFallbacks addObject: fallbacks];
    }

    NSMutableArray *classUIDs = [NSMutableArray arrayWithCapacity: counts[Classes]];
    for (uint32_t i = 0; i < counts[Classes]; ++i) {
        NSMutableArray *fallbacks = [NSMutableArray array];
        for (NSNumber *index in classFallbacks[i])
            [fallbacks addObject: classNames[[index unsignedIntValue]]];
        [classUIDs addObject: archiveUID((uint32_t)[archiveObjects count])];
        [archiveObjects addObject: archiveClass(classNames[i], fallbacks)];
    }

    NSUInteger stringClass = [classNames indexOfObject: @"NSString"];
    id stringClassUID;
    if (stringClass != NSNotFound) {
        stringClassUID = classUIDs[stringClass];
    } else {
        stringClassUID = archiveUID((uint32_t)[archiveObjects count]);
        [archiveObjects addObject: archiveClass(@"NSString", @[])];
    }

    NSMutableArray *values = [NSMutableArray arrayWithCapacity: counts[Values]];
    NibReader *valuesReader = &tables[Values];
    for (uint32_t i = 0; i < counts[Values]; ++i) {
        uint32_t keyIndex = readVarint(valuesReader);
        id value = readValue(valuesReader, objectUIDs);
        if (valuesReader->failed || keyIndex >= counts[Keys] || value == nil)
            return nil;
        [values addObject: @[keys[keyIndex], value]];
    }

    NibReader *objectsReader = &tables[Objects];
    for (uint32_t i = 0; i < objectCount; ++i) {
        uint32_t classIndex = readVarint(objectsReader);
        uint32_t start = readVarint(objectsReader);
        uint32_t count = readVarint(objectsReader);
        if (objectsReader->failed || classIndex >= counts[Classes] ||
            start > counts[Values] || count > counts[Values] - start)
            return nil;

        NSString *className = classNames[classIndex];
        NSMutableDictionary *object = [NSMutableDictionary dictionaryWithObject: classUIDs[classIndex]
                                                                         forKey: @"$class"];
        NSMutableArray *items = nil;
        if (count != 0 && [values[start][0] isEqualToString: @"NSInlinedValue"] &&
            values[start][1] == (id)kCFBooleanTrue) {
            items = [NSMutableArray arrayWithCapacity: count - 1];
            ++start;
            --count;
        }

        NSUInteger unkeyedIndex = 0;
        for (uint32_t j = start; j < start + count; ++j) {
            NSString *key = values[j][0];
            id value = values[j][1];
            if ([key isEqualToString: @"UINibEncoderEmptyKey"]) {
                if (items != nil) {
                    if (CFGetTypeID((CFTypeRef)value) != _CFKeyedArchiverUIDGetTypeID())
                        return nil;
                    [items addObject: value];
                    continue;
                }
                key = [NSString stringWithFormat: @"$%lu", (unsigned long)unkeyedIndex++];
            } else if ([key hasPrefix: @"$"]) {
                key = [@"$" stringByAppendingString: key];
            }
            object[key] = value;
        }

        if (items != nil) {
            if ([className isEqualToString: @"NSDictionary"] || [className isEqualToString: @"NSMutableDictionary"]) {
                if ([items count] % 2 != 0)
                    return nil;
                NSMutableArray *itemKeys = [NSMutableArray arrayWithCapacity: [items count] / 2];
                NSMutableArray *itemValues = [NSMutableArray arrayWithCapacity: [items count] / 2];
                for (NSUInteger j = 0; j < [items count]; j += 2) {
                    [itemKeys addObject: items[j]];
                    [itemValues addObject: items[j + 1]];
                }
                object[@"NS.keys"] = itemKeys;
                object[@"NS.objects"] = itemValues;
            } else {
                object[@"NS.objects"] = items;
            }
        }

        if (!translateFoundationObject(className, object, archiveObjects, stringClassUID))
            return nil;
        archiveObjects[i + 1] = object;
    }

    // NIBArchive stores the top-level keys in its first object.
    NSMutableDictionary *top = [[archiveObjects[1] mutableCopy] autorelease];
    [top removeObjectForKey: @"$class"];
    NSDictionary *archive = @{@"$archiver": @"NSKeyedArchiver", @"$version": @100000,
                              @"$objects": archiveObjects, @"$top": top};
    NSMutableData *result = [NSMutableData data];
    if (__CFBinaryPlistWriteToStream((CFPropertyListRef)archive, (CFMutableDataRef)result) <= 0)
        return nil;
    return result;
}

@interface UINibEncoder : NSCoder
@end

@implementation UINibEncoder

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [NSMethodSignature signatureWithObjCTypes: "v@:"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"Stub called: %@ in %@", NSStringFromSelector([anInvocation selector]), [self class]);
}

@end
