#import <AppKit/NSPDFInfo.h>
#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSValue.h>

@implementation NSPDFInfo

@synthesize URL = _URL;
@synthesize fileExtensionHidden = _fileExtensionHidden;
@synthesize tagNames = _tagNames;
@synthesize attributes = _attributes;

- (instancetype)init {
    if ((self = [super init])) {
        _tagNames = [[NSArray alloc] init];
        _orientation = NSPaperOrientationPortrait;
        _paperSize = NSMakeSize(612.0, 792.0); /* US Letter in points */
        _attributes = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if ((self = [self init])) {
        if ([coder allowsKeyedCoding]) {
            [_URL release];
            _URL = [[coder decodeObjectForKey:@"NSPDFInfoURL"] copy];
            NSArray *tags = [coder decodeObjectForKey:@"NSPDFInfoTagNames"];
            if (tags != nil) {
                [_tagNames release];
                _tagNames = [tags copy];
            }
            _orientation = [coder decodeIntegerForKey:@"NSPDFInfoOrientation"];
            if ([coder containsValueForKey:@"NSPDFInfoPaperSize"])
                _paperSize = [coder decodeSizeForKey:@"NSPDFInfoPaperSize"];
            NSDictionary *attrs = [coder decodeObjectForKey:@"NSPDFInfoAttributes"];
            if (attrs != nil)
                [_attributes addEntriesFromDictionary:attrs];
            _fileExtensionHidden = [coder decodeBoolForKey:@"NSPDFInfoFileExtensionHidden"];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    if ([coder allowsKeyedCoding]) {
        [coder encodeObject:_URL forKey:@"NSPDFInfoURL"];
        [coder encodeObject:_tagNames forKey:@"NSPDFInfoTagNames"];
        [coder encodeInteger:_orientation forKey:@"NSPDFInfoOrientation"];
        [coder encodeSize:_paperSize forKey:@"NSPDFInfoPaperSize"];
        [coder encodeObject:_attributes forKey:@"NSPDFInfoAttributes"];
        [coder encodeBool:_fileExtensionHidden forKey:@"NSPDFInfoFileExtensionHidden"];
    }
}

- (id)copyWithZone:(NSZone *)zone {
    NSPDFInfo *copy = [[NSPDFInfo allocWithZone:zone] init];
    copy->_URL = [_URL copy];
    [copy->_tagNames release];
    copy->_tagNames = [_tagNames copy];
    copy->_orientation = _orientation;
    copy->_paperSize = _paperSize;
    [copy->_attributes addEntriesFromDictionary:_attributes];
    copy->_fileExtensionHidden = _fileExtensionHidden;
    return copy;
}

- (void)dealloc {
    [_URL release];
    [_tagNames release];
    [_attributes release];
    [super dealloc];
}

- (NSPaperOrientation)orientation {
    return _orientation;
}

- (void)setOrientation:(NSPaperOrientation)orientation {
    _orientation = orientation;
}

- (NSSize)paperSize {
    return _paperSize;
}

- (void)setPaperSize:(NSSize)paperSize {
    _paperSize = paperSize;
}

@end
