#import <AppKit/NSAssetCatalog.h>

#import <AppKit/NSBitmapImageRep.h>
#import <AppKit/NSImage.h>

#include <lzfse.h>
#include <zlib.h>
#include <limits.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

enum {
    NSAssetCatalogCSIHeaderSize = 184,
    NSAssetCatalogLayoutInternalLink = 1003,
    NSAssetCatalogTLVInternalLink = 0x3f2,
    NSAssetCatalogCompressionRaw = 0,
    NSAssetCatalogCompressionRLE = 1,
    NSAssetCatalogCompressionZIP = 2,
    NSAssetCatalogCompressionLZVN = 3,
    NSAssetCatalogCompressionLZFSE = 4
};

static BOOL NSAssetCatalogHasRange(NSData *data, NSUInteger offset,
                                  NSUInteger length) {
    return offset <= [data length] && length <= [data length] - offset;
}

static uint16_t NSAssetCatalogReadBE16(const uint8_t *bytes) {
    return ((uint16_t)bytes[0] << 8) | (uint16_t)bytes[1];
}

static uint32_t NSAssetCatalogReadBE32(const uint8_t *bytes) {
    return ((uint32_t)bytes[0] << 24) | ((uint32_t)bytes[1] << 16) |
           ((uint32_t)bytes[2] << 8) | (uint32_t)bytes[3];
}

static uint16_t NSAssetCatalogReadLE16(const uint8_t *bytes) {
    return ((uint16_t)bytes[1] << 8) | (uint16_t)bytes[0];
}

static uint32_t NSAssetCatalogReadLE32(const uint8_t *bytes) {
    return ((uint32_t)bytes[3] << 24) | ((uint32_t)bytes[2] << 16) |
           ((uint32_t)bytes[1] << 8) | (uint32_t)bytes[0];
}

static void NSAssetCatalogWriteLE16(uint8_t *bytes, uint16_t value) {
    bytes[0] = (uint8_t)(value & 0xff);
    bytes[1] = (uint8_t)(value >> 8);
}

static BOOL NSAssetCatalogSizeForPixels(NSUInteger width, NSUInteger height,
                                        NSUInteger bytesPerPixel,
                                        NSUInteger *sizeOut) {
    if (width == 0 || height == 0 || bytesPerPixel == 0 ||
        width > NSUIntegerMax / bytesPerPixel)
        return NO;
    NSUInteger rowBytes = width * bytesPerPixel;
    if (height > NSUIntegerMax / rowBytes)
        return NO;
    if (sizeOut != NULL)
        *sizeOut = rowBytes * height;
    return YES;
}

@interface NSAssetCatalog (Private)
- (id)initWithData:(NSData *)data;
- (NSData *)_blockForIndex:(NSUInteger)index;
- (NSArray *)_treeRowsNamed:(NSString *)name;
- (NSData *)_renditionForAttributes:(NSDictionary *)attributes
                              scale:(CGFloat)scale;
- (NSData *)_renditionForTokenBytes:(const uint8_t *)bytes
                             length:(NSUInteger)length;
- (NSData *)_decodedPixelsForRendition:(NSData *)rendition
                                 depth:(NSUInteger)depth
                                 width:(NSUInteger *)widthOut
                                height:(NSUInteger *)heightOut
                                flags:(uint32_t *)flagsOut;
- (NSData *)_bitmapImageDataForName:(NSString *)name
                               scale:(CGFloat)scale
                               width:(NSUInteger *)widthOut
                              height:(NSUInteger *)heightOut
                               flags:(uint32_t *)flagsOut;
- (NSBitmapImageRep *)_bitmapImageRepForName:(NSString *)name
                                       scale:(CGFloat)scale
                                       flags:(uint32_t *)flagsOut;
@end

@implementation NSAssetCatalog

+ (NSImage *)imageNamed:(NSString *)name inBundles:(NSArray *)bundles {
    static NSMutableDictionary *cache = nil;
    NSImage *result = nil;

    if (name == nil)
        return nil;
    @synchronized([NSAssetCatalog class]) {
        if (cache == nil)
            cache = [[NSMutableDictionary alloc] init];
        for (NSBundle *bundle in bundles) {
            NSString *path = [bundle pathForResource: @"Assets" ofType: @"car"];
            if (path == nil)
                continue;
            id catalog = [cache objectForKey: path];
            if (catalog == nil) {
                catalog = [NSAssetCatalog catalogWithPath: path];
                [cache setObject: (catalog != nil ? catalog : [NSNull null]) forKey: path];
            }
            if (catalog == [NSNull null])
                continue;
            result = [catalog imageNamed: name];
            if (result != nil)
                break;
        }
    }
    return result;
}

+ (NSAssetCatalog *)catalogWithPath:(NSString *)carPath {
    if (carPath == nil)
        return nil;

    NSData *data = [NSData dataWithContentsOfFile:carPath];
    if (data == nil)
        return nil;

    return [[[self alloc] initWithData:data] autorelease];
}

- (id)initWithData:(NSData *)data {
    self = [super init];
    if (self == nil)
        return nil;

    if (data == nil || [data length] < 32 ||
        memcmp([data bytes], "BOMStore", 8) != 0) {
        [self release];
        return nil;
    }

    const uint8_t *bytes = [data bytes];
    NSUInteger fileLength = [data length];
    uint32_t version = NSAssetCatalogReadBE32(bytes + 8);
    uint32_t indexOffset = NSAssetCatalogReadBE32(bytes + 16);
    uint32_t indexLength = NSAssetCatalogReadBE32(bytes + 20);
    uint32_t variablesOffset = NSAssetCatalogReadBE32(bytes + 24);
    uint32_t trailerLength = NSAssetCatalogReadBE32(bytes + 28);

    if (version != 1 || !NSAssetCatalogHasRange(data, indexOffset, 4) ||
        !NSAssetCatalogHasRange(data, indexOffset, indexLength) ||
        !NSAssetCatalogHasRange(data, variablesOffset, trailerLength) ||
        trailerLength < 4) {
        [self release];
        return nil;
    }

    uint32_t indexCount = NSAssetCatalogReadBE32(bytes + indexOffset);
    if (indexCount > (indexLength - 4) / 8 ||
        4 + (NSUInteger)indexCount * 8 > indexLength) {
        [self release];
        return nil;
    }

    _fileData = [data copy];
    NSMutableArray *ranges = [[NSMutableArray alloc] initWithCapacity:indexCount];
    NSUInteger tableOffset = (NSUInteger)indexOffset + 4;
    for (uint32_t index = 0; index < indexCount; index++) {
        uint32_t blockOffset = NSAssetCatalogReadBE32(bytes + tableOffset + index * 8);
        uint32_t blockLength = NSAssetCatalogReadBE32(bytes + tableOffset + index * 8 + 4);
        if (blockOffset <= fileLength && blockLength <= fileLength - blockOffset)
            [ranges addObject:[NSValue valueWithRange:NSMakeRange(blockOffset, blockLength)]];
        else
            [ranges addObject:[NSNull null]];
    }
    _blockRanges = ranges;

    uint32_t variableCount = NSAssetCatalogReadBE32(bytes + variablesOffset);
    NSUInteger variableCursor = (NSUInteger)variablesOffset + 4;
    NSUInteger variablesEnd = (NSUInteger)variablesOffset + trailerLength;
    NSMutableDictionary *namedIndices = [[NSMutableDictionary alloc] init];
    for (uint32_t variable = 0; variable < variableCount; variable++) {
        if (variableCursor > variablesEnd || variablesEnd - variableCursor < 5) {
            [namedIndices release];
            [self release];
            return nil;
        }
        uint32_t blockIndex = NSAssetCatalogReadBE32(bytes + variableCursor);
        uint8_t nameLength = bytes[variableCursor + 4];
        variableCursor += 5;
        if (nameLength > variablesEnd - variableCursor || blockIndex >= indexCount) {
            [namedIndices release];
            [self release];
            return nil;
        }
        NSString *blockName = [[[NSString alloc]
                initWithBytes:bytes + variableCursor
                       length:nameLength
                     encoding:NSUTF8StringEncoding] autorelease];
        if (blockName != nil)
            [namedIndices setObject:[NSNumber numberWithUnsignedInt:blockIndex]
                             forKey:blockName];
        variableCursor += nameLength;
    }
    _namedBlockIndices = namedIndices;

    NSData *carHeader = [self _blockForIndex:[[_namedBlockIndices
            objectForKey:@"CARHEADER"] unsignedIntegerValue]];
    NSData *keyFormat = [self _blockForIndex:[[_namedBlockIndices
            objectForKey:@"KEYFORMAT"] unsignedIntegerValue]];
    NSData *renditionTree = [self _blockForIndex:[[_namedBlockIndices
            objectForKey:@"RENDITIONS"] unsignedIntegerValue]];
    NSData *facetTree = [self _blockForIndex:[[_namedBlockIndices
            objectForKey:@"FACETKEYS"] unsignedIntegerValue]];

    if ([carHeader length] < 4 || memcmp([carHeader bytes], "RATC", 4) != 0 ||
        [keyFormat length] < 12 || [renditionTree length] < 21 ||
        [facetTree length] < 21) {
        [self release];
        return nil;
    }

    const uint8_t *formatBytes = [keyFormat bytes];
    uint32_t keyFormatCount = NSAssetCatalogReadLE32(formatBytes + 8);
    if (keyFormatCount == 0 || keyFormatCount > 128 ||
        [keyFormat length] < 12 + (NSUInteger)keyFormatCount * 4) {
        [self release];
        return nil;
    }
    NSMutableArray *keyFormatIDs = [[NSMutableArray alloc]
            initWithCapacity:keyFormatCount];
    for (uint32_t index = 0; index < keyFormatCount; index++) {
        [keyFormatIDs addObject:[NSNumber numberWithUnsignedInt:
                NSAssetCatalogReadLE32(formatBytes + 12 + index * 4)]];
    }
    _keyFormat = keyFormatIDs;

    NSMutableDictionary *facets = [[NSMutableDictionary alloc] init];
    for (NSArray *row in [self _treeRowsNamed:@"FACETKEYS"]) {
        NSUInteger keyIndex = [[row objectAtIndex:0] unsignedIntegerValue];
        NSUInteger valueIndex = [[row objectAtIndex:1] unsignedIntegerValue];
        NSData *keyData = [self _blockForIndex:keyIndex];
        NSData *valueData = [self _blockForIndex:valueIndex];
        if (keyData == nil || valueData == nil || [valueData length] < 6)
            continue;

        const uint8_t *keyBytes = [keyData bytes];
        NSUInteger nameLength = [keyData length];
        const uint8_t *terminator = memchr(keyBytes, 0, nameLength);
        if (terminator != NULL)
            nameLength = (NSUInteger)(terminator - keyBytes);
        NSString *facetName = [[[NSString alloc]
                initWithBytes:keyBytes
                       length:nameLength
                     encoding:NSUTF8StringEncoding] autorelease];
        if (facetName == nil)
            continue;

        const uint8_t *attributeBytes = [valueData bytes];
        uint16_t attributeCount = NSAssetCatalogReadLE16(attributeBytes + 4);
        if ([valueData length] < 6 + (NSUInteger)attributeCount * 4)
            continue;
        NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
        for (uint16_t attribute = 0; attribute < attributeCount; attribute++) {
            const uint8_t *entry = attributeBytes + 6 + attribute * 4;
            NSNumber *attributeID = [NSNumber numberWithUnsignedInt:
                    NSAssetCatalogReadLE16(entry)];
            NSNumber *attributeValue = [NSNumber numberWithUnsignedInt:
                    NSAssetCatalogReadLE16(entry + 2)];
            [attributes setObject:attributeValue forKey:attributeID];
        }
        [facets setObject:attributes forKey:facetName];
        [attributes release];
    }
    _facets = facets;

    NSMutableDictionary *renditions = [[NSMutableDictionary alloc] init];
    for (NSArray *row in [self _treeRowsNamed:@"RENDITIONS"]) {
        NSUInteger keyIndex = [[row objectAtIndex:0] unsignedIntegerValue];
        NSUInteger valueIndex = [[row objectAtIndex:1] unsignedIntegerValue];
        NSData *keyData = [self _blockForIndex:keyIndex];
        NSData *valueData = [self _blockForIndex:valueIndex];
        if (keyData == nil || valueData == nil ||
            [keyData length] < keyFormatCount * 2 ||
            [valueData length] < NSAssetCatalogCSIHeaderSize)
            continue;
        [renditions setObject:valueData forKey:keyData];
    }
    _renditions = renditions;

    if ([_facets count] == 0 || [_renditions count] == 0) {
        [self release];
        return nil;
    }
    return self;
}

- (NSData *)_blockForIndex:(NSUInteger)index {
    if (index >= [_blockRanges count])
        return nil;
    id value = [_blockRanges objectAtIndex:index];
    if (value == [NSNull null])
        return nil;
    NSRange range = [value rangeValue];
    if (!NSAssetCatalogHasRange(_fileData, range.location, range.length))
        return nil;
    return [_fileData subdataWithRange:range];
}

- (NSArray *)_treeRowsNamed:(NSString *)name {
    NSNumber *treeIndexNumber = [_namedBlockIndices objectForKey:name];
    if (treeIndexNumber == nil)
        return [NSArray array];
    NSData *tree = [self _blockForIndex:[treeIndexNumber unsignedIntegerValue]];
    if ([tree length] < 21 || memcmp([tree bytes], "tree", 4) != 0)
        return [NSArray array];

    uint32_t rootIndex = NSAssetCatalogReadBE32((const uint8_t *)[tree bytes] + 8);
    NSMutableArray *pending = [[NSMutableArray alloc] initWithObjects:
            [NSNumber numberWithUnsignedInt:rootIndex], nil];
    NSMutableSet *visited = [[NSMutableSet alloc] init];
    NSMutableArray *rows = [[NSMutableArray alloc] init];

    while ([pending count] != 0 && [visited count] < 65536) {
        NSNumber *nodeIndexNumber = [[pending lastObject] retain];
        [pending removeLastObject];
        if ([visited containsObject:nodeIndexNumber]) {
            [nodeIndexNumber release];
            continue;
        }
        [visited addObject:nodeIndexNumber];
        NSData *node = [self _blockForIndex:[nodeIndexNumber unsignedIntegerValue]];
        [nodeIndexNumber release];
        if ([node length] < 12)
            continue;

        const uint8_t *nodeBytes = [node bytes];
        uint16_t isLeaf = NSAssetCatalogReadBE16(nodeBytes);
        uint16_t entryCount = NSAssetCatalogReadBE16(nodeBytes + 2);
        if ([node length] < 12 + (NSUInteger)entryCount * 8)
            continue;

        for (uint16_t entry = 0; entry < entryCount; entry++) {
            const uint8_t *entryBytes = nodeBytes + 12 + entry * 8;
            uint32_t valueIndex = NSAssetCatalogReadBE32(entryBytes);
            uint32_t keyIndex = NSAssetCatalogReadBE32(entryBytes + 4);
            if (isLeaf) {
                [rows addObject:[NSArray arrayWithObjects:
                        [NSNumber numberWithUnsignedInt:keyIndex],
                        [NSNumber numberWithUnsignedInt:valueIndex], nil]];
            } else {
                [pending addObject:[NSNumber numberWithUnsignedInt:valueIndex]];
            }
        }

        if (isLeaf) {
            uint32_t forwardIndex = NSAssetCatalogReadBE32(nodeBytes + 4);
            if (forwardIndex != 0)
                [pending addObject:[NSNumber numberWithUnsignedInt:forwardIndex]];
        }
    }

    [pending release];
    [visited release];
    return [rows autorelease];
}

- (NSData *)_renditionForAttributes:(NSDictionary *)attributes
                              scale:(CGFloat)scale {
    NSArray *keys = [_renditions allKeys];
    NSData *fallback = nil;
    uint32_t wantedScale = scale > 0.0 ? (uint32_t)(scale * 100.0 + 0.5) : 0;

    for (NSData *key in keys) {
        if ([key length] < [_keyFormat count] * 2)
            continue;
        const uint8_t *keyBytes = [key bytes];
        BOOL matches = YES;
        for (NSNumber *attributeID in attributes) {
            NSUInteger attributeValue = [[attributes objectForKey:attributeID]
                    unsignedIntegerValue];
            BOOL foundPosition = NO;
            BOOL foundValue = NO;
            for (NSUInteger position = 0; position < [_keyFormat count]; position++) {
                if ([[_keyFormat objectAtIndex:position] unsignedIntegerValue] ==
                    [attributeID unsignedIntegerValue]) {
                    foundPosition = YES;
                    if (NSAssetCatalogReadLE16(keyBytes + position * 2) ==
                        attributeValue)
                        foundValue = YES;
                }
            }
            if (foundPosition && !foundValue) {
                matches = NO;
                break;
            }
        }
        if (!matches)
            continue;

        NSData *rendition = [_renditions objectForKey:key];
        if (rendition == nil || [rendition length] < NSAssetCatalogCSIHeaderSize)
            continue;
        const uint8_t *renditionBytes = [rendition bytes];
        uint32_t renditionScale = NSAssetCatalogReadLE32(renditionBytes + 20);
        if (wantedScale != 0 && renditionScale != 0 && renditionScale != wantedScale)
            continue;
        if (wantedScale != 0 && renditionScale == 0) {
            NSUInteger keyScale = 0;
            for (NSUInteger position = 0; position < [_keyFormat count]; position++) {
                if ([[_keyFormat objectAtIndex:position] unsignedIntegerValue] == 12) {
                    keyScale = NSAssetCatalogReadLE16(keyBytes + position * 2);
                    break;
                }
            }
            if (keyScale != 0 && keyScale != (NSUInteger)(scale + 0.5))
                continue;
        }
        if (wantedScale == 0 && renditionScale != 0 && renditionScale != 100)
            continue;
        if (fallback == nil)
            fallback = rendition;
        if (wantedScale == 0 || renditionScale == wantedScale)
            return rendition;
    }
    return fallback;
}

- (NSData *)_renditionForTokenBytes:(const uint8_t *)bytes
                             length:(NSUInteger)length {
    if (bytes == NULL || (length & 3) != 0 || [_keyFormat count] == 0)
        return nil;
    NSMutableData *key = [NSMutableData dataWithLength:[_keyFormat count] * 2];
    uint8_t *keyBytes = [key mutableBytes];
    NSUInteger tokenCount = length / 4;
    for (NSUInteger token = 0; token < tokenCount; token++) {
        const uint8_t *entry = bytes + token * 4;
        uint16_t attributeID = NSAssetCatalogReadLE16(entry);
        uint16_t attributeValue = NSAssetCatalogReadLE16(entry + 2);
        if (attributeID == 0 && attributeValue == 0)
            break;
        for (NSUInteger position = 0; position < [_keyFormat count]; position++) {
            if ([[_keyFormat objectAtIndex:position] unsignedIntegerValue] == attributeID)
                NSAssetCatalogWriteLE16(keyBytes + position * 2, attributeValue);
        }
    }
    return [_renditions objectForKey:key];
}

- (NSData *)_decodedPixelsForRendition:(NSData *)rendition
                                 depth:(NSUInteger)depth
                                 width:(NSUInteger *)widthOut
                                height:(NSUInteger *)heightOut
                                 flags:(uint32_t *)flagsOut {
    if (depth > 8 || [rendition length] < NSAssetCatalogCSIHeaderSize)
        return nil;
    const uint8_t *bytes = [rendition bytes];
    NSUInteger length = [rendition length];
    if (memcmp(bytes, "ISTC", 4) != 0 && memcmp(bytes, "CTSI", 4) != 0)
        return nil;

    uint32_t flags = NSAssetCatalogReadLE32(bytes + 8);
    NSUInteger width = NSAssetCatalogReadLE32(bytes + 12);
    NSUInteger height = NSAssetCatalogReadLE32(bytes + 16);
    uint16_t layout = NSAssetCatalogReadLE16(bytes + 36);
    uint32_t tlvLength = NSAssetCatalogReadLE32(bytes + 168);
    uint32_t bitmapCount = NSAssetCatalogReadLE32(bytes + 172);

    if (flagsOut != NULL)
        *flagsOut = flags;
    if (width == 0 || height == 0 ||
        tlvLength > length - NSAssetCatalogCSIHeaderSize)
        return nil;

    NSUInteger dataOffset = NSAssetCatalogCSIHeaderSize + tlvLength;
    if (layout == NSAssetCatalogLayoutInternalLink) {
        NSUInteger cursor = NSAssetCatalogCSIHeaderSize;
        NSUInteger end = cursor + tlvLength;
        while (cursor + 8 <= end) {
            uint32_t type = NSAssetCatalogReadLE32(bytes + cursor);
            uint32_t valueLength = NSAssetCatalogReadLE32(bytes + cursor + 4);
            if (valueLength > end - cursor - 8)
                return nil;
            const uint8_t *value = bytes + cursor + 8;
            if (type == NSAssetCatalogTLVInternalLink && valueLength >= 38) {
                uint32_t keyLength = NSAssetCatalogReadLE32(value + 26);
                if (keyLength > valueLength - 30 || (keyLength & 3) != 0)
                    return nil;
                NSUInteger cropX = NSAssetCatalogReadLE32(value + 8);
                NSUInteger cropY = NSAssetCatalogReadLE32(value + 12);
                NSUInteger cropWidth = NSAssetCatalogReadLE32(value + 16);
                NSUInteger cropHeight = NSAssetCatalogReadLE32(value + 20);
                NSData *target = [self _renditionForTokenBytes:value + 30
                                                        length:keyLength];
                if (target == nil)
                    return nil;
                NSUInteger targetWidth = 0, targetHeight = 0;
                uint32_t targetFlags = 0;
                NSData *targetPixels = [self _decodedPixelsForRendition:target
                                                                 depth:depth + 1
                                                                 width:&targetWidth
                                                                height:&targetHeight
                                                                 flags:&targetFlags];
                if (targetPixels == nil || cropWidth == 0 || cropHeight == 0 ||
                    cropX > targetWidth || cropY > targetHeight ||
                    cropWidth > targetWidth - cropX ||
                    cropHeight > targetHeight - cropY)
                    return nil;
                NSUInteger targetLength = 0;
                if (!NSAssetCatalogSizeForPixels(targetWidth, targetHeight, 4,
                                                 &targetLength) ||
                    [targetPixels length] < targetLength)
                    return nil;
                NSUInteger cropLength = 0;
                if (!NSAssetCatalogSizeForPixels(cropWidth, cropHeight, 4,
                                                 &cropLength))
                    return nil;
                NSMutableData *cropped = [NSMutableData dataWithLength:cropLength];
                const uint8_t *source = [targetPixels bytes];
                uint8_t *destination = [cropped mutableBytes];
                NSUInteger sourceRowBytes = targetWidth * 4;
                NSUInteger cropRowBytes = cropWidth * 4;
                for (NSUInteger row = 0; row < cropHeight; row++) {
                    memcpy(destination + row * cropRowBytes,
                           source + (cropY + row) * sourceRowBytes + cropX * 4,
                           cropRowBytes);
                }
                if (widthOut != NULL)
                    *widthOut = cropWidth;
                if (heightOut != NULL)
                    *heightOut = cropHeight;
                if (flagsOut != NULL)
                    *flagsOut = flags | targetFlags;
                return cropped;
            }
            cursor += 8 + valueLength;
        }
        return nil;
    }

    if (bitmapCount == 0 ||
        (NSUInteger)bitmapCount > (length - 176) / 4)
        return nil;
    NSUInteger bitmapOffset = NSAssetCatalogReadLE32(bytes + 176);
    NSUInteger renditionLengthOffset = 176 + (NSUInteger)bitmapCount * 4;
    if (!NSAssetCatalogHasRange(rendition, renditionLengthOffset, 4))
        return nil;
    uint32_t renditionLength = NSAssetCatalogReadLE32(bytes + renditionLengthOffset);
    if (renditionLength > length - NSAssetCatalogCSIHeaderSize - tlvLength)
        return nil;
    if (bitmapOffset > renditionLength)
        return nil;
    NSUInteger payloadOffset = dataOffset + bitmapOffset;
    NSUInteger renditionEnd = dataOffset + renditionLength;
    if (payloadOffset > renditionEnd || renditionEnd > length ||
        renditionEnd - payloadOffset < 4)
        return nil;

    const uint8_t *payload = bytes + payloadOffset;
    NSUInteger payloadLength = renditionEnd - payloadOffset;
    BOOL isCELM = memcmp(payload, "CELM", 4) == 0;
    BOOL isMLEC = memcmp(payload, "MLEC", 4) == 0;
    if (!isCELM && !isMLEC)
        return nil;
    if (payloadLength < 16)
        return nil;

    uint32_t compressionType = NSAssetCatalogReadLE32(payload + 8);
    const uint8_t *compressedBytes = payload + 16;
    NSUInteger compressedLength = payloadLength - 16;
    NSUInteger sourceBytesPerPixel = 0;
    BOOL grayAlpha = NO;
    BOOL grayAlpha16 = NO;
    BOOL rgb555 = NO;
    if (memcmp(bytes + 24, "BGRA", 4) == 0 ||
        memcmp(bytes + 24, "ARGB", 4) == 0 ||
        memcmp(bytes + 24, "RGBW", 4) == 0) {
        sourceBytesPerPixel = 4;
    } else if (memcmp(bytes + 24, "GA8 ", 4) == 0) {
        sourceBytesPerPixel = 2;
        grayAlpha = YES;
    } else if (memcmp(bytes + 24, "GA16", 4) == 0) {
        sourceBytesPerPixel = 4;
        grayAlpha16 = YES;
    } else if (memcmp(bytes + 24, "RGB5", 4) == 0) {
        sourceBytesPerPixel = 2;
        rgb555 = YES;
    } else {
        return nil;
    }

    NSUInteger sourceSize = 0;
    if (!NSAssetCatalogSizeForPixels(width, height, sourceBytesPerPixel,
                                     &sourceSize))
        return nil;
    NSMutableData *sourcePixels = [NSMutableData dataWithLength:sourceSize];
    uint8_t *sourceDestination = [sourcePixels mutableBytes];
    BOOL decoded = NO;

    if (compressionType == NSAssetCatalogCompressionRaw) {
        if (compressedLength >= sourceSize) {
            memcpy(sourceDestination, compressedBytes, sourceSize);
            decoded = YES;
        }
    } else if (compressionType == NSAssetCatalogCompressionZIP) {
        uLongf outputLength = (uLongf)sourceSize;
        if (uncompress(sourceDestination, &outputLength, compressedBytes,
                       (uLong)compressedLength) == Z_OK && outputLength == sourceSize)
            decoded = YES;
    } else if (compressionType == NSAssetCatalogCompressionRLE) {
        NSUInteger offsetTableBytes = (height + 3) * 4;
        if (height <= (NSUIntegerMax / 4) - 3 && compressedLength >= offsetTableBytes) {
            decoded = YES;
            NSUInteger sourceRowBytes = width * sourceBytesPerPixel;
            for (NSUInteger row = 0; row < height && decoded; row++) {
                const uint8_t *offsetBytes = compressedBytes + (3 + row) * 4;
                NSUInteger rowOffset = isCELM
                        ? NSAssetCatalogReadBE32(offsetBytes)
                        : NSAssetCatalogReadLE32(offsetBytes);
                if (rowOffset >= compressedLength) {
                    decoded = NO;
                    break;
                }
                NSUInteger cursor = rowOffset;
                NSUInteger x = 0;
                while (x < width) {
                    if (cursor > compressedLength || compressedLength - cursor < 4) {
                        decoded = NO;
                        break;
                    }
                    uint32_t run = isCELM
                            ? NSAssetCatalogReadBE32(compressedBytes + cursor)
                            : NSAssetCatalogReadLE32(compressedBytes + cursor);
                    cursor += 4;
                    NSUInteger count = run & 0x00ffffff;
                    if (count == 0 || count > width - x) {
                        decoded = NO;
                        break;
                    }
                    uint8_t *rowDestination = sourceDestination + row * sourceRowBytes;
                    if ((run >> 24) == 0x80) {
                        if (sourceBytesPerPixel > compressedLength - cursor) {
                            decoded = NO;
                            break;
                        }
                        for (NSUInteger pixel = 0; pixel < count; pixel++)
                            memcpy(rowDestination + (x + pixel) * sourceBytesPerPixel,
                                   compressedBytes + cursor, sourceBytesPerPixel);
                        cursor += sourceBytesPerPixel;
                    } else {
                        NSUInteger runBytes = count * sourceBytesPerPixel;
                        if (runBytes > compressedLength - cursor) {
                            decoded = NO;
                            break;
                        }
                        memcpy(rowDestination + x * sourceBytesPerPixel,
                               compressedBytes + cursor, runBytes);
                        cursor += runBytes;
                    }
                    x += count;
                }
            }
        }
    } else if (compressionType == NSAssetCatalogCompressionLZFSE ||
               compressionType == NSAssetCatalogCompressionLZVN) {
        if (compressedLength >= 20 && memcmp(compressedBytes, "KCBC", 4) == 0) {
            NSUInteger cursor = 0;
            NSUInteger outputY = 0;
            decoded = YES;
            NSUInteger rowBytes = width * sourceBytesPerPixel;
            while (cursor + 20 <= compressedLength && outputY < height) {
                const uint8_t *chunk = compressedBytes + cursor;
                if (memcmp(chunk, "KCBC", 4) != 0) {
                    decoded = NO;
                    break;
                }
                NSUInteger chunkHeight = NSAssetCatalogReadLE32(chunk + 12);
                NSUInteger chunkLength = NSAssetCatalogReadLE32(chunk + 16);
                if (chunkHeight == 0 || chunkHeight > height - outputY ||
                    chunkLength > compressedLength - cursor - 20) {
                    decoded = NO;
                    break;
                }
                if (rowBytes > NSUIntegerMax - 256 ||
                    chunkHeight > NSUIntegerMax / (rowBytes + 256)) {
                    decoded = NO;
                    break;
                }
                NSUInteger chunkCapacity = chunkHeight * (rowBytes + 256);
                NSMutableData *chunkPixels = [NSMutableData dataWithLength:chunkCapacity];
                size_t decodedLength = lzfse_decode_buffer(
                        [chunkPixels mutableBytes], chunkCapacity,
                        chunk + 20, chunkLength, NULL);
                if (decodedLength < rowBytes * chunkHeight ||
                    decodedLength % chunkHeight != 0) {
                    decoded = NO;
                    break;
                }
                NSUInteger decodedRowBytes = decodedLength / chunkHeight;
                if (decodedRowBytes < rowBytes) {
                    decoded = NO;
                    break;
                }
                const uint8_t *chunkSource = [chunkPixels bytes];
                for (NSUInteger row = 0; row < chunkHeight; row++) {
                    memcpy(sourceDestination + (outputY + row) * rowBytes,
                           chunkSource + row * decodedRowBytes, rowBytes);
                }
                outputY += chunkHeight;
                cursor += 20 + chunkLength;
            }
            if (outputY != height)
                decoded = NO;
        } else {
            if (height <= (NSUIntegerMax / 256) &&
                sourceSize <= NSUIntegerMax - height * 256) {
                NSUInteger capacity = sourceSize + height * 256;
                NSMutableData *decodedBuffer = [NSMutableData dataWithLength:capacity];
                size_t decodedLength = lzfse_decode_buffer(
                        [decodedBuffer mutableBytes], capacity,
                        compressedBytes, compressedLength, NULL);
                NSUInteger rowBytes = width * sourceBytesPerPixel;
                if (decodedLength >= sourceSize && decodedLength % height == 0 &&
                    decodedLength / height >= rowBytes) {
                    NSUInteger decodedRowBytes = decodedLength / height;
                    const uint8_t *decodedBytes = [decodedBuffer bytes];
                    for (NSUInteger row = 0; row < height; row++)
                        memcpy(sourceDestination + row * rowBytes,
                               decodedBytes + row * decodedRowBytes, rowBytes);
                    decoded = YES;
                }
            }
        }
    }

    if (!decoded)
        return nil;

    NSUInteger outputSize = 0;
    if (!NSAssetCatalogSizeForPixels(width, height, 4, &outputSize))
        return nil;
    NSMutableData *pixels = [NSMutableData dataWithLength:outputSize];
    const uint8_t *source = [sourcePixels bytes];
    uint8_t *destination = [pixels mutableBytes];
    NSUInteger pixelCount = width * height;
    if (sourceBytesPerPixel == 4 && !grayAlpha16 && !rgb555) {
        memcpy(destination, source, outputSize);
    } else if (grayAlpha) {
        for (NSUInteger pixel = 0; pixel < pixelCount; pixel++) {
            uint8_t gray = source[pixel * 2];
            uint8_t alpha = source[pixel * 2 + 1];
            destination[pixel * 4] = gray;
            destination[pixel * 4 + 1] = gray;
            destination[pixel * 4 + 2] = gray;
            destination[pixel * 4 + 3] = alpha;
        }
    } else if (grayAlpha16) {
        for (NSUInteger pixel = 0; pixel < pixelCount; pixel++) {
            uint8_t gray = source[pixel * 4 + 1];
            uint8_t alpha = source[pixel * 4 + 3];
            destination[pixel * 4] = gray;
            destination[pixel * 4 + 1] = gray;
            destination[pixel * 4 + 2] = gray;
            destination[pixel * 4 + 3] = alpha;
        }
    } else if (rgb555) {
        for (NSUInteger pixel = 0; pixel < pixelCount; pixel++) {
            uint16_t value = NSAssetCatalogReadLE16(source + pixel * 2);
            uint8_t red = (uint8_t)(((value >> 11) & 0x1f) * 255 / 31);
            uint8_t green = (uint8_t)(((value >> 6) & 0x1f) * 255 / 31);
            uint8_t blue = (uint8_t)(((value >> 1) & 0x1f) * 255 / 31);
            destination[pixel * 4] = blue;
            destination[pixel * 4 + 1] = green;
            destination[pixel * 4 + 2] = red;
            destination[pixel * 4 + 3] = (value & 1) ? 255 : 0;
        }
    }

    if (widthOut != NULL)
        *widthOut = width;
    if (heightOut != NULL)
        *heightOut = height;
    return pixels;
}

- (NSData *)_bitmapImageDataForName:(NSString *)name
                              scale:(CGFloat)scale
                              width:(NSUInteger *)widthOut
                             height:(NSUInteger *)heightOut
                              flags:(uint32_t *)flagsOut {
    NSDictionary *attributes = [_facets objectForKey:name];
    if (attributes == nil)
        return nil;
    NSData *rendition = [self _renditionForAttributes:attributes scale:scale];
    if (rendition == nil)
        return nil;
    NSUInteger width = 0, height = 0;
    uint32_t flags = 0;
    NSData *pixels = [self _decodedPixelsForRendition:rendition
                                                depth:0
                                                width:&width
                                               height:&height
                                                flags:&flags];
    if (pixels == nil)
        return nil;
    if (widthOut != NULL)
        *widthOut = width;
    if (heightOut != NULL)
        *heightOut = height;
    if (flagsOut != NULL)
        *flagsOut = flags;
    return pixels;
}

- (NSBitmapImageRep *)_bitmapImageRepForName:(NSString *)name
                                       scale:(CGFloat)scale
                                       flags:(uint32_t *)flagsOut {
    NSUInteger width = 0, height = 0;
    uint32_t flags = 0;
    NSData *pixels = [self _bitmapImageDataForName:name
                                             scale:scale
                                             width:&width
                                            height:&height
                                             flags:&flags];
    if (pixels == nil || width > INT_MAX || height > INT_MAX || width > INT_MAX / 4)
        return nil;

    unsigned char *planes[1] = {NULL};
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
            initWithBitmapDataPlanes:planes
                          pixelsWide:(int)width
                          pixelsHigh:(int)height
                       bitsPerSample:8
                     samplesPerPixel:4
                            hasAlpha:YES
                            isPlanar:NO
                      colorSpaceName:NSDeviceRGBColorSpace
                         bitmapFormat:NSAlphaFirstBitmapFormat
                          bytesPerRow:(int)(width * 4)
                         bitsPerPixel:32];
    if (rep == nil)
        return nil;
    memcpy([rep bitmapData], [pixels bytes], [pixels length]);
    CGFloat representationScale = scale > 0.0 ? scale : 1.0;
    [rep setSize:NSMakeSize(width / representationScale,
                            height / representationScale)];
    if (flagsOut != NULL)
        *flagsOut = flags;
    return rep;
}

- (NSData *)imageDataForName:(NSString *)name scale:(CGFloat)scale {
    if (name == nil)
        return nil;
    NSBitmapImageRep *rep = [self _bitmapImageRepForName:name scale:scale flags:NULL];
    if (rep == nil)
        return nil;
    NSData *imageData = [rep representationUsingType:NSPNGFileType properties:nil];
    [rep release];
    return imageData;
}

- (NSImage *)imageNamed:(NSString *)name {
    if (name == nil)
        return nil;
    NSImage *image = nil;
    uint32_t imageFlags = 0;
    CGFloat scales[] = {1.0, 2.0};
    for (NSUInteger index = 0; index < sizeof(scales) / sizeof(scales[0]); index++) {
        uint32_t renditionFlags = 0;
        NSBitmapImageRep *rep = [self _bitmapImageRepForName:name
                                                       scale:scales[index]
                                                       flags:&renditionFlags];
        if (rep == nil)
            continue;
        if (image == nil) {
            image = [[NSImage alloc] initWithSize:[rep size]];
            imageFlags = renditionFlags;
        }
        [image addRepresentation:rep];
        [rep release];
    }

    if (image == nil)
        return nil;
    [image setTemplate:(imageFlags & 0x08) != 0];
    return [image autorelease];
}

- (void)dealloc {
    [_fileData release];
    [_blockRanges release];
    [_namedBlockIndices release];
    [_keyFormat release];
    [_facets release];
    [_renditions release];
    [super dealloc];
}

@end
