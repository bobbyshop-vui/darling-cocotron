/*
 This file is part of Darling.

 Copyright (C) 2025 Darling Developers

 Darling is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 Darling is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Darling.  If not, see <http://www.gnu.org/licenses/>.
*/

#import <AppKit/NSUserInterfaceCompressionOptions.h>

static NSString *const NSUCOHideImages = @"NSUserInterfaceCompressionOptionHideImages";
static NSString *const NSUCOHideText = @"NSUserInterfaceCompressionOptionHideText";
static NSString *const NSUCOReduceMetrics = @"NSUserInterfaceCompressionOptionReduceMetrics";
static NSString *const NSUCOBreakEqualWidths = @"NSUserInterfaceCompressionOptionBreakEqualWidths";
static NSString *const NSUCOCodingKey = @"NSIdentifiers";

@implementation NSUserInterfaceCompressionOptions

- (instancetype)init
{
    if ((self = [super init]) != nil)
        _identifiers = [[NSSet alloc] init];
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    if ((self = [super init]) != nil)
        _identifiers = identifier != nil ? [[NSSet alloc] initWithObjects:identifier, nil] : [[NSSet alloc] init];
    return self;
}

- (instancetype)initWithCompressionOptions:(NSSet *)options
{
    if ((self = [super init]) != nil) {
        NSMutableSet *all = [[NSMutableSet alloc] init];
        for (NSUserInterfaceCompressionOptions *option in options)
            [all unionSet:option->_identifiers];
        _identifiers = all;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if ((self = [super init]) != nil) {
        NSSet *set = nil;
        if ([coder allowsKeyedCoding])
            set = [coder decodeObjectForKey:NSUCOCodingKey];
        _identifiers = [set isKindOfClass:[NSSet class]] ? [set copy] : [[NSSet alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if ([coder allowsKeyedCoding])
        [coder encodeObject:_identifiers forKey:NSUCOCodingKey];
}

- (void)dealloc
{
    [_identifiers release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

- (BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    if (![object isKindOfClass:[NSUserInterfaceCompressionOptions class]])
        return NO;
    return [_identifiers isEqualToSet:((NSUserInterfaceCompressionOptions *)object)->_identifiers];
}

- (NSUInteger)hash
{
    return [_identifiers hash];
}

- (BOOL)isEmpty
{
    return [_identifiers count] == 0;
}

- (BOOL)containsOptions:(NSUserInterfaceCompressionOptions *)options
{
    return [options->_identifiers isSubsetOfSet:_identifiers];
}

- (BOOL)intersectsOptions:(NSUserInterfaceCompressionOptions *)options
{
    return [_identifiers intersectsSet:options->_identifiers];
}

- (NSUserInterfaceCompressionOptions *)optionsByAddingOptions:(NSUserInterfaceCompressionOptions *)options
{
    NSMutableSet *all = [NSMutableSet setWithSet:_identifiers];
    [all unionSet:options->_identifiers];
    NSUserInterfaceCompressionOptions *result = [[[[self class] alloc] init] autorelease];
    [result->_identifiers release];
    result->_identifiers = [all copy];
    return result;
}

- (NSUserInterfaceCompressionOptions *)optionsByRemovingOptions:(NSUserInterfaceCompressionOptions *)options
{
    NSMutableSet *all = [NSMutableSet setWithSet:_identifiers];
    [all minusSet:options->_identifiers];
    NSUserInterfaceCompressionOptions *result = [[[[self class] alloc] init] autorelease];
    [result->_identifiers release];
    result->_identifiers = [all copy];
    return result;
}

+ (NSUserInterfaceCompressionOptions *)hideImagesOption
{
    return [[[self alloc] initWithIdentifier:NSUCOHideImages] autorelease];
}

+ (NSUserInterfaceCompressionOptions *)hideTextOption
{
    return [[[self alloc] initWithIdentifier:NSUCOHideText] autorelease];
}

+ (NSUserInterfaceCompressionOptions *)reduceMetricsOption
{
    return [[[self alloc] initWithIdentifier:NSUCOReduceMetrics] autorelease];
}

+ (NSUserInterfaceCompressionOptions *)breakEqualWidthsOption
{
    return [[[self alloc] initWithIdentifier:NSUCOBreakEqualWidths] autorelease];
}

+ (NSUserInterfaceCompressionOptions *)standardOptions
{
    NSUserInterfaceCompressionOptions *result = [[[self alloc] init] autorelease];
    [result->_identifiers release];
    result->_identifiers = [[NSSet alloc] initWithObjects:NSUCOHideImages, NSUCOHideText, NSUCOReduceMetrics, NSUCOBreakEqualWidths, nil];
    return result;
}

@end
